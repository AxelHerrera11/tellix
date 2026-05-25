package com.tellix.modules.inventario;

import com.tellix.shared.dto.PagedResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Repository
public class InventarioRepository {

    private final JdbcTemplate jdbc;

    public InventarioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Listar stock ─────────────────────────────────────────
    public PagedResponse<InventarioDto.StockProducto> listarStock(
        String busqueda, Integer categoria, String estado,
        boolean critico, int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_stock @p_busqueda=?, @p_categoria=?, @p_estado=?, @p_critico=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, busqueda);
                if (categoria != null) cs.setInt(2, categoria);
                else cs.setNull(2, Types.INTEGER);
                cs.setString(3, estado);
                cs.setBoolean(4, critico);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<InventarioDto.StockProducto> datos = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) total = rs.getLong("total");
                    }
                }
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) datos.add(mapStock(rs));
                    }
                }
                return PagedResponse.of(datos, pagina, tamano, total);
            }
        });
    }

    // ── Stock crítico ────────────────────────────────────────
    public List<InventarioDto.StockCritico> stockCritico() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_reporte_stock_critico")) {
                List<InventarioDto.StockCritico> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) lista.add(mapCritico(rs));
                    }
                }
                return lista;
            }
        });
    }

    // ── Listar movimientos ───────────────────────────────────
    public PagedResponse<InventarioDto.MovimientoDto> listarMovimientos(
        Integer producto, String operacion,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_movimientos @p_producto=?, @p_operacion=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_pagina=?, @p_tamano=?"
            )) {
                if (producto != null) cs.setInt(1, producto);
                else cs.setNull(1, Types.INTEGER);
                cs.setString(2, operacion);
                if (desde != null) cs.setDate(3, Date.valueOf(desde));
                else cs.setNull(3, Types.DATE);
                if (hasta != null) cs.setDate(4, Date.valueOf(hasta));
                else cs.setNull(4, Types.DATE);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<InventarioDto.MovimientoDto> datos = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) total = rs.getLong("total");
                    }
                }
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) datos.add(mapMovimiento(rs));
                    }
                }
                return PagedResponse.of(datos, pagina, tamano, total);
            }
        });
    }

    // ── Ajustar stock ────────────────────────────────────────
    public void ajustar(int productoId, BigDecimal cantidad, String motivo, int usuario) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_ajuste_inventario @p_producto=?, @p_cantidad=?, @p_motivo=?, @p_usuario=?"
            )) {
                cs.setInt(1, productoId);
                cs.setBigDecimal(2, cantidad);
                cs.setString(3, motivo);
                cs.setInt(4, usuario);
                cs.execute();
                return null;
            }
        });
    }

    // ── Mappers ──────────────────────────────────────────────
    private InventarioDto.StockProducto mapStock(ResultSet rs) throws SQLException {
        return new InventarioDto.StockProducto(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("categoria"),
            rs.getString("marca"),
            rs.getString("medida_codigo"),
            rs.getString("medida"),
            rs.getBigDecimal("stock_actual"),
            rs.getBigDecimal("stock_minimo"),
            rs.getString("estado"),
            rs.getString("nivel_stock")
        );
    }

    private InventarioDto.MovimientoDto mapMovimiento(ResultSet rs) throws SQLException {
        return new InventarioDto.MovimientoDto(
            rs.getInt("id"),
            rs.getInt("fk_producto"),
            rs.getString("producto"),
            rs.getString("medida_codigo"),
            rs.getString("medida"),
            rs.getBigDecimal("cantidad"),
            rs.getString("tipo_movimiento"),
            rs.getString("operacion"),
            rs.getString("motivo"),
            rs.getString("tipo_documento"),
            rs.getString("no_documento"),
            rs.getObject("fk_usuario", Integer.class),
            rs.getString("usuario"),
            toLocalDateTime(rs.getTimestamp("fecha_operacion"))
        );
    }

    private InventarioDto.StockCritico mapCritico(ResultSet rs) throws SQLException {
        return new InventarioDto.StockCritico(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("categoria"),
            rs.getString("marca"),
            rs.getBigDecimal("stock_actual"),
            rs.getBigDecimal("stock_minimo"),
            rs.getBigDecimal("faltante")
        );
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }
}
