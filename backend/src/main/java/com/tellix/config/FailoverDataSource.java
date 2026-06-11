package com.tellix.config;

import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;

import javax.sql.DataSource;
import java.io.PrintWriter;
import java.sql.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * DataSource con failover automático entre primario (PC2) y secundario (PC3).
 *
 * Flujo normal:
 *   Todas las conexiones van a PC2 (primario).
 *
 * Cuando PC2 falla (≥ failureThreshold checks consecutivos):
 *   1. Se ejecuta RESTORE DATABASE TellixDB WITH RECOVERY en PC3 para
 *      promover la BD secundaria (Log Shipping → online).
 *   2. El pool activo cambia a PC3.
 *   3. La app sigue funcionando sin reinicio.
 *
 * Cuando PC2 vuelve:
 *   El health-check detecta que PC2 responde y conmuta de vuelta al primario.
 *   (Nota: Log Shipping deberá re-configurarse manualmente tras la recuperación.)
 */
public class FailoverDataSource implements DataSource {

    private static final Logger log = LoggerFactory.getLogger(FailoverDataSource.class);

    private final HikariDataSource primaryPool;
    private final HikariDataSource secondaryPool;
    private final HaProperties     props;

    /** true  → usando PC2 (primario)   |   false → usando PC3 (secundario) */
    private final AtomicBoolean usingPrimary       = new AtomicBoolean(true);
    private final AtomicInteger consecutiveFailures = new AtomicInteger(0);

    public FailoverDataSource(HikariDataSource primaryPool,
                              HikariDataSource secondaryPool,
                              HaProperties props) {
        this.primaryPool   = primaryPool;
        this.secondaryPool = secondaryPool;
        this.props         = props;
    }

    // ── Punto de entrada principal ─────────────────────────────────────────

    @Override
    public Connection getConnection() throws SQLException {
        return activePool().getConnection();
    }

    @Override
    public Connection getConnection(String username, String password) throws SQLException {
        return activePool().getConnection(username, password);
    }

    /** Devuelve el pool activo en este momento. */
    private HikariDataSource activePool() {
        return usingPrimary.get() ? primaryPool : secondaryPool;
    }

    /** Indica qué nodo está activo (útil para endpoints de monitoreo). */
    public boolean isUsingPrimary() {
        return usingPrimary.get();
    }

    // ── Health-check programado ────────────────────────────────────────────

    /**
     * Se ejecuta cada {@code tellix.ha.check-interval-ms} milisegundos.
     * Usa conexiones directas (DriverManager) con timeout corto para no
     * bloquear el pool de la aplicación durante la comprobación.
     */
    @Scheduled(fixedDelayString = "${tellix.ha.check-interval-ms:10000}")
    public void healthCheck() {
        if (usingPrimary.get()) {
            checkPrimary();
        } else {
            checkIfPrimaryRecovered();
        }
    }

    // ── Comprobación del primario ──────────────────────────────────────────

    private void checkPrimary() {
        String url = appendLoginTimeout(props.getPrimaryUrl(), 5);
        try (Connection c  = DriverManager.getConnection(url, props.getUsername(), props.getPassword());
             PreparedStatement ps = c.prepareStatement("SELECT 1")) {

            ps.setQueryTimeout(5);
            ps.executeQuery();
            consecutiveFailures.set(0); // OK — resetear contador

        } catch (SQLException e) {
            int failures = consecutiveFailures.incrementAndGet();
            log.warn("[HA] Primario no responde ({}/{}) — {}", failures, props.getFailureThreshold(), e.getMessage());

            if (failures >= props.getFailureThreshold()) {
                doFailover();
            }
        }
    }

    // ── Failover PC2 → PC3 ────────────────────────────────────────────────

    private synchronized void doFailover() {
        if (!usingPrimary.get()) return; // Ya se hizo failover, evitar doble ejecución

        log.error("[HA] ══════════════════════════════════════════════════");
        log.error("[HA] PRIMARIO CAÍDO — Iniciando failover a PC3...");
        log.error("[HA] ══════════════════════════════════════════════════");

        try {
            promoteSecondary();
            secondaryPool.getHikariPoolMXBean().softEvictConnections(); // Limpiar conexiones viejas
            usingPrimary.set(false);
            consecutiveFailures.set(0);
            log.info("[HA] Failover completado. App conectada a secundario: {}", props.getSecondaryUrl());

        } catch (Exception e) {
            log.error("[HA] ERROR al promover secundario — {}", e.getMessage(), e);
        }
    }

    /**
     * Promueve la BD secundaria ejecutando RESTORE … WITH RECOVERY.
     * Conecta a la base 'master' de PC3 para ejecutar el comando admin.
     */
    private void promoteSecondary() throws SQLException {
        // Construir URL apuntando a master (no a TellixDB, que está en RESTORING)
        String adminUrl = appendLoginTimeout(
                props.getSecondaryUrl().replaceAll("(?i)databaseName=[^;]+", "databaseName=master"),
                10
        );

        log.info("[HA] Conectando a master de PC3 para promover BD...");

        try (Connection c = DriverManager.getConnection(adminUrl, props.getUsername(), props.getPassword());
             Statement  s = c.createStatement()) {

            // 1. Deshabilitar jobs de Log Shipping en PC3 para que no intenten
            //    seguir restaurando después de abrir la base
            //    (tolerante a falta de permisos en msdb)
            try {
                log.info("[HA] Deshabilitando jobs de Log Shipping en PC3...");
                s.execute("""
                    USE msdb;
                    UPDATE msdb.dbo.sysjobs
                    SET enabled = 0
                    WHERE name LIKE 'LS%TellixDB%';
                    """);
            } catch (SQLException e) {
                log.warn("[HA] No se pudieron deshabilitar jobs de Log Shipping — continuando failover: {}", e.getMessage());
            }

            // 2. Forzar desconexión de cualquier conexión activa y restaurar
            s.execute("""
                ALTER DATABASE [TellixDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                RESTORE DATABASE [TellixDB] WITH RECOVERY;
                ALTER DATABASE [TellixDB] SET MULTI_USER;
                """);

            log.info("[HA] BD secundaria promovida exitosamente (RESTORE WITH RECOVERY)");

        } catch (SQLException e) {
            // Error 3117: la BD ya está online (no estaba en RESTORING)
            if (e.getErrorCode() == 3117 || (e.getMessage() != null &&
                    e.getMessage().toLowerCase().contains("not in a restoring state"))) {
                log.info("[HA] BD secundaria ya estaba online — continuando failover");
            } else {
                throw e;
            }
        }
    }

    // ── Recuperación PC3 → PC2 ────────────────────────────────────────────

    /**
     * Mientras la app usa PC3, comprueba periódicamente si PC2 volvió.
     * Cuando PC2 responde, conmuta de vuelta al primario.
     */
    private void checkIfPrimaryRecovered() {
        String url = appendLoginTimeout(props.getPrimaryUrl(), 5);
        try (Connection c  = DriverManager.getConnection(url, props.getUsername(), props.getPassword());
             PreparedStatement ps = c.prepareStatement("SELECT 1")) {

            ps.setQueryTimeout(5);
            ps.executeQuery();

            log.info("[HA] ══════════════════════════════════════════════════");
            log.info("[HA] PRIMARIO RECUPERADO — Volviendo a PC2...");
            log.info("[HA] ══════════════════════════════════════════════════");

            primaryPool.getHikariPoolMXBean().softEvictConnections();
            usingPrimary.set(true);
            consecutiveFailures.set(0);
            log.info("[HA] Recuperación completada. App conectada a primario: {}", props.getPrimaryUrl());
            log.warn("[HA] AVISO: Reconfigura el Log Shipping manualmente para restablecer la réplica.");

        } catch (SQLException ignored) {
            // PC2 sigue caído — próximo check lo reintentará
        }
    }

    // ── Utilidad ──────────────────────────────────────────────────────────

    /** Agrega loginTimeout a la URL si no lo tiene ya. */
    private String appendLoginTimeout(String url, int seconds) {
        if (url.toLowerCase().contains("logintimeout")) return url;
        return url + (url.endsWith(";") ? "" : ";") + "loginTimeout=" + seconds;
    }

    // ── Métodos obligatorios de DataSource ────────────────────────────────

    @Override
    public PrintWriter getLogWriter() throws SQLException {
        return activePool().getLogWriter();
    }

    @Override
    public void setLogWriter(PrintWriter out) throws SQLException {
        activePool().setLogWriter(out);
    }

    @Override
    public void setLoginTimeout(int seconds) throws SQLException {
        activePool().setLoginTimeout(seconds);
    }

    @Override
    public int getLoginTimeout() throws SQLException {
        return activePool().getLoginTimeout();
    }

    @Override
    public java.util.logging.Logger getParentLogger() throws SQLFeatureNotSupportedException {
        return activePool().getParentLogger();
    }

    @Override
    public <T> T unwrap(Class<T> iface) throws SQLException {
        return activePool().unwrap(iface);
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) throws SQLException {
        return activePool().isWrapperFor(iface);
    }
}
