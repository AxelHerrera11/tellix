package com.tellix.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

@Configuration
@EnableConfigurationProperties(HaProperties.class)
public class JdbcConfig {

    /**
     * DataSource principal con failover automático.
     * Reemplaza la auto-configuración de Spring Boot para tener control total
     * sobre los dos pools (primario PC2 y secundario PC3).
     */
    @Bean
    @Primary
    public DataSource dataSource(HaProperties ha) {
        HikariDataSource primary   = buildPool(ha.getPrimaryUrl(),   ha.getUsername(), ha.getPassword(), "TellixPrimary");
        HikariDataSource secondary = buildPool(ha.getSecondaryUrl(), ha.getUsername(), ha.getPassword(), "TellixSecondary");
        return new FailoverDataSource(primary, secondary, ha);
    }

    @Bean
    public JdbcTemplate jdbcTemplate(DataSource dataSource) {
        JdbcTemplate template = new JdbcTemplate(dataSource);
        template.setResultsMapCaseInsensitive(true);
        return template;
    }

    // ── Construcción de pool HikariCP ─────────────────────────────────────

    private HikariDataSource buildPool(String url, String username, String password, String poolName) {
        HikariConfig cfg = new HikariConfig();
        cfg.setJdbcUrl(url);
        cfg.setUsername(username);
        cfg.setPassword(password);
        cfg.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        cfg.setMaximumPoolSize(10);
        cfg.setMinimumIdle(2);
        cfg.setConnectionTimeout(30_000);
        cfg.setIdleTimeout(600_000);
        cfg.setPoolName(poolName);
        // Inicializar el pool sin fallar si el servidor no está disponible al arrancar
        cfg.setInitializationFailTimeout(-1);
        return new HikariDataSource(cfg);
    }
}