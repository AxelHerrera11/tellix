package com.tellix.modules.reporte;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

@Repository
public class ReporteRepository {

    private final JdbcTemplate jdbc;

    public ReporteRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public ReporteDto.ResumenGeneral obtenerResumenGeneral() {
        Integer totalProductos = contar("producto");
        Integer totalClientes = contar("cliente");
        Integer totalProveedores = contar("proveedor");
        Integer totalVentas = contar("venta");
        Integer totalCompras = contar("compra");

        Integer cxcPendientes = jdbc.queryForObject("""
            SELECT COUNT(*)
            FROM cuenta_por_cobrar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_cobrado, 0)
            """, Integer.class);

        Integer cxpPendientes = jdbc.queryForObject("""
            SELECT COUNT(*)
            FROM cuenta_por_pagar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_pagado, 0)
            """, Integer.class);

        BigDecimal montoCxcPendiente = jdbc.queryForObject("""
            SELECT COALESCE(SUM(COALESCE(valor_total, 0) - COALESCE(valor_cobrado, 0)), 0)
            FROM cuenta_por_cobrar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_cobrado, 0)
            """, BigDecimal.class);

        BigDecimal montoCxpPendiente = jdbc.queryForObject("""
            SELECT COALESCE(SUM(COALESCE(valor_total, 0) - COALESCE(valor_pagado, 0)), 0)
            FROM cuenta_por_pagar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_pagado, 0)
            """, BigDecimal.class);

        return new ReporteDto.ResumenGeneral(
            totalProductos,
            totalClientes,
            totalProveedores,
            totalVentas,
            totalCompras,
            cxcPendientes,
            cxpPendientes,
            montoCxcPendiente,
            montoCxpPendiente
        );
    }

    private Integer contar(String tabla) {
        return jdbc.queryForObject("SELECT COUNT(*) FROM " + tabla, Integer.class);
    }
}
