package com.tellix.modules.precio;

import com.tellix.shared.dto.PagedResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class PrecioRepository {

    private final JdbcTemplate jdbc;

    public PrecioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PagedResponse<PrecioDto.PrecioResumen> listar(Integer producto, String busqueda, String aplicacion, String estado, Boolean vigentes, LocalDate fecha, int pagina, int tamano) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_precios @p_producto=?, @p_busqueda=?, @p_aplicacion=?, @p_estado=?, @p_vigentes=?, @p_fecha=?, @p_pagina=?, @p_tamano=?")) {
                if (producto != null) cs.setInt(1, producto); else cs.setNull(1, Types.INTEGER);
                cs.setString(2, busqueda);
                cs.setString(3, aplicacion);
                cs.setString(4, estado);
                if (vigentes != null) cs.setBoolean(5, vigentes);
                else cs.setNull(5, Types.BIT);
                cs.setDate(6, fecha != null ? Date.valueOf(fecha) : null);
                cs.setInt(7, pagina);
                cs.setInt(8, tamano);
                long total = 0;
                List<PrecioDto.PrecioResumen> datos = new ArrayList<>();
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) total = rs.getLong("total");
                    }
                }
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) datos.add(mapResumen(rs));
                    }
                }
                return PagedResponse.of(datos, pagina, tamano, total);
            }
        });
    }

    public Optional<PrecioDto.PrecioDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_obtener_precio @p_id=?")) {
                cs.setInt(1, id);
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) return Optional.of(mapDetalle(rs));
                    }
                }
                return Optional.empty();
            }
        });
    }

    public int crear(PrecioDto.CrearPrecioRequest req, int usuario) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("{call sp_crear_precio(?, ?, ?, ?, ?, ?, ?)}")) {
                cs.setInt(1, req.fkProducto());
                cs.setString(2, req.aplicacion());
                cs.setBigDecimal(3, req.precioVenta());
                cs.setDate(4, req.inicioVigencia() != null ? Date.valueOf(req.inicioVigencia()) : null);
                cs.setBoolean(5, Boolean.TRUE.equals(req.cerrarVigentes()));
                cs.setInt(6, usuario);
                cs.registerOutParameter(7, Types.INTEGER);
                cs.execute();
                return cs.getInt(7);
            }
        });
    }

    public void actualizar(int id, PrecioDto.ActualizarPrecioRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_actualizar_precio @p_id=?, @p_aplicacion=?, @p_precio_venta=?, @p_inicio_vigencia=?, @p_fin_vigencia=?")) {
                cs.setInt(1, id);
                cs.setString(2, req.aplicacion());
                cs.setBigDecimal(3, req.precioVenta());
                cs.setDate(4, Date.valueOf(req.inicioVigencia()));
                cs.setDate(5, req.finVigencia() != null ? Date.valueOf(req.finVigencia()) : null);
                cs.execute();
                return null;
            }
        });
    }

    public void cambiarEstado(int id, String estado) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_cambiar_estado_precio @p_id=?, @p_estado=?")) {
                cs.setInt(1, id);
                cs.setString(2, estado);
                cs.execute();
                return null;
            }
        });
    }

    public Optional<PrecioDto.PrecioResumen> obtenerVigente(int producto, String aplicacion, LocalDate fecha) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_precio_vigente @p_producto=?, @p_aplicacion=?, @p_fecha=?")) {
                cs.setInt(1, producto);
                cs.setString(2, aplicacion);
                cs.setDate(3, fecha != null ? Date.valueOf(fecha) : null);
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) return Optional.of(mapVigente(rs));
                    }
                }
                return Optional.empty();
            }
        });
    }

    public List<PrecioDto.ProductoPrecioDto> listarProductos() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_productos_precio")) {
                List<PrecioDto.ProductoPrecioDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) {
                            lista.add(new PrecioDto.ProductoPrecioDto(
                                rs.getInt("codigo"), rs.getString("nombre"), rs.getString("descripcion"), rs.getBigDecimal("stock_actual"), rs.getString("medida")
                            ));
                        }
                    }
                }
                return lista;
            }
        });
    }

    private PrecioDto.PrecioResumen mapResumen(ResultSet rs) throws SQLException {
        return new PrecioDto.PrecioResumen(
            rs.getInt("id"), rs.getInt("fk_producto"), rs.getString("producto"), rs.getString("descripcion_producto"),
            rs.getString("aplicacion"), rs.getBigDecimal("precio_venta"), toLocalDate(rs.getDate("inicio_vigencia")), toLocalDate(rs.getDate("fin_vigencia")),
            rs.getString("estado"), rs.getString("estado_descripcion"), rs.getBoolean("vigente"), rs.getObject("creado_por", Integer.class),
            rs.getString("usuario"), toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private PrecioDto.PrecioDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new PrecioDto.PrecioDetalle(
            rs.getInt("id"), rs.getInt("fk_producto"), rs.getString("producto"), rs.getString("descripcion_producto"), rs.getString("categoria"), rs.getString("marca"),
            rs.getString("medida"), rs.getString("aplicacion"), rs.getBigDecimal("precio_venta"), toLocalDate(rs.getDate("inicio_vigencia")), toLocalDate(rs.getDate("fin_vigencia")),
            rs.getString("estado"), rs.getString("estado_descripcion"), rs.getBoolean("vigente"), rs.getObject("creado_por", Integer.class),
            rs.getString("usuario"), toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private PrecioDto.PrecioResumen mapVigente(ResultSet rs) throws SQLException {
        return new PrecioDto.PrecioResumen(
            rs.getInt("id"), rs.getInt("fk_producto"), rs.getString("producto"), null,
            rs.getString("aplicacion"), rs.getBigDecimal("precio_venta"), toLocalDate(rs.getDate("inicio_vigencia")), toLocalDate(rs.getDate("fin_vigencia")),
            rs.getString("estado"), null, true, rs.getObject("creado_por", Integer.class),
            null, toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private LocalDate toLocalDate(Date d) { return d != null ? d.toLocalDate() : null; }
    private LocalDateTime toLocalDateTime(Timestamp ts) { return ts != null ? ts.toLocalDateTime() : null; }
}
