package com.tellix.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Propiedades de alta disponibilidad (HA) para el failover automático entre
 * la base de datos primaria (PC2) y la secundaria (PC3).
 */
@ConfigurationProperties(prefix = "tellix.ha")
public class HaProperties {

    /** URL JDBC de la BD primaria (PC2 — 100.74.19.127) */
    private String primaryUrl;

    /** URL JDBC de la BD secundaria (PC3 — 100.90.132.63) */
    private String secondaryUrl;

    /** Usuario SQL Server compartido por ambas instancias */
    private String username;

    /** Contraseña SQL Server compartida por ambas instancias */
    private String password;

    /**
     * Intervalo en milisegundos entre cada health-check.
     * Por defecto: 10 000 ms (10 segundos).
     */
    private int checkIntervalMs = 10_000;

    /**
     * Número de fallos consecutivos antes de activar el failover.
     * Por defecto: 3 (≈ 30 s con el intervalo predeterminado).
     */
    private int failureThreshold = 3;

    // ── Getters y setters ──────────────────────────────────────────────────

    public String getPrimaryUrl()               { return primaryUrl; }
    public void   setPrimaryUrl(String v)       { this.primaryUrl = v; }

    public String getSecondaryUrl()             { return secondaryUrl; }
    public void   setSecondaryUrl(String v)     { this.secondaryUrl = v; }

    public String getUsername()                 { return username; }
    public void   setUsername(String v)         { this.username = v; }

    public String getPassword()                 { return password; }
    public void   setPassword(String v)         { this.password = v; }

    public int  getCheckIntervalMs()            { return checkIntervalMs; }
    public void setCheckIntervalMs(int v)       { this.checkIntervalMs = v; }

    public int  getFailureThreshold()           { return failureThreshold; }
    public void setFailureThreshold(int v)      { this.failureThreshold = v; }
}
