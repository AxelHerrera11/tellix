package com.tellix.modules.venta;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.TellixException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class VentaRepository {

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public VentaRepository(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc   = jdbc;
        this.mapper = mapper;
    }

    // ── Listar ventas paginado ────────────────────────────────
    public PagedResponse<VentaDto.VentaResumen> listar(
        String cliente, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_ventas @p_cliente=?, @p_estado=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, cliente);
                cs.setString(2, estado);
                cs.setDate(3,   desde != null ? Date.valueOf(desde) : null);
                cs.setDate(4,   hasta != null ? Date.valueOf(hasta) : null);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<VentaDto.VentaResumen> datos = new ArrayList<>();

                boolean hasResult = cs.execute();
                // Primer ResultSet: total
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) total = rs.getLong("total");
                    }
                }
                // Segundo ResultSet: datos
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) {
                            datos.add(mapResumen(rs));
                        }
                    }
                }
                return PagedResponse.of(datos, pagina, tamano, total);
            }
        });
    }

    // ── Obtener venta completa ────────────────────────────────
    public Optional<VentaDto.VentaDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_obtener_venta @p_id=?"
            )) {
                cs.setInt(1, id);

                VentaDto.VentaDetalle cabecera = null;
                List<VentaDto.DetalleVenta> items = new ArrayList<>();

                boolean hasResult = cs.execute();
                // Primer RS: cabecera
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) cabecera = mapDetalle(rs);
                    }
                }
                // Segundo RS: ítems
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) items.add(mapItem(rs));
                    }
                }

                if (cabecera == null) return Optional.empty();

                // Combinar cabecera con ítems (record no es mutable, reconstruir)
                VentaDto.VentaDetalle completa = new VentaDto.VentaDetalle(
                    cabecera.id(), cabecera.fkCliente(), cabecera.nombreCliente(),
                    cabecera.nit(), cabecera.fechaOperacion(), cabecera.horaOperacion(),
                    cabecera.estado(), estadoDesc(cabecera.estado()),
                    cabecera.subtotal(), cabecera.totalDescuentos(),
                    cabecera.totalImpuestos(), cabecera.total(),
                    cabecera.plazoCredito(), cabecera.tipoPlazo(),
                    cabecera.fkMetodoPago(), cabecera.metodoPago(),
                    cabecera.usuario(), cabecera.nombreEmpleado(),
                    cabecera.creadoEn(), items
                );
                return Optional.of(completa);
            }
        });
    }

    // ── Registrar venta ───────────────────────────────────────
    public int registrar(VentaDto.CrearVentaRequest req, int fkUsuario) {
        String itemsJson;
        try {
            itemsJson = mapper.writeValueAsString(req.items());
        } catch (JsonProcessingException e) {
            throw new TellixException("Error al serializar los ítems.", HttpStatus.BAD_REQUEST);
        }

        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_registrar_venta @p_cliente=?, @p_usuario=?, @p_metodo_pago=?, @p_plazo=?, @p_tipo_plazo=?, @p_items=?"
            )) {
                cs.setString(1, req.fkCliente());
                cs.setInt(2,    fkUsuario);
                cs.setInt(3,    req.fkMetodoPago());
                cs.setInt(4,    req.plazoCredito());
                cs.setString(5, req.tipoPlazo() != null ? req.tipoPlazo() : "DIAS");
                cs.setString(6, itemsJson);

                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs.next()) return rs.getInt("id");
                        }
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                throw new TellixException("No se pudo registrar la venta.", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        });
    }

    // ── Anular venta ──────────────────────────────────────────
    public void anular(int id, int fkUsuario, String motivo) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_anular_venta @p_id=?, @p_usuario=?, @p_motivo=?"
            )) {
                cs.setInt(1,    id);
                cs.setInt(2,    fkUsuario);
                cs.setString(3, motivo != null ? motivo : "Anulación manual");
                cs.execute();
                return null;
            }
        });
    }

    // ── Búsqueda de productos para POS ────────────────────────
    public List<VentaDto.ProductoVenta> buscarProductos(String busqueda, String aplicacion) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_buscar_productos_venta @p_busqueda=?, @p_aplicacion=?"
            )) {
                cs.setString(1, busqueda);
                cs.setString(2, aplicacion);

                List<VentaDto.ProductoVenta> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new VentaDto.ProductoVenta(
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getString("descripcion"),
                                    rs.getBigDecimal("stock_actual"),
                                    rs.getString("fk_medida"),
                                    rs.getString("medida"),
                                    rs.getBigDecimal("precio_venta"),
                                    rs.getString("aplicacion")
                                ));
                            }
                        }
                        break;
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return lista;
            }
        });
    }

    // ── Búsqueda de clientes para POS ────────────────────────
    public List<VentaDto.ClienteVenta> buscarClientes(String busqueda) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_buscar_clientes_venta @p_busqueda=?"
            )) {
                cs.setString(1, busqueda);

                List<VentaDto.ClienteVenta> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new VentaDto.ClienteVenta(
                                    rs.getString("nit"),
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getBigDecimal("limite_credito"),
                                    rs.getString("direccion"),
                                    rs.getString("tipo_cliente")
                                ));
                            }
                        }
                        break;
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return lista;
            }
        });
    }

    // ── Mappers ───────────────────────────────────────────────
    private VentaDto.VentaResumen mapResumen(ResultSet rs) throws SQLException {
        return new VentaDto.VentaResumen(
            rs.getInt("id"),
            rs.getString("fk_cliente"),
            rs.getString("nombre_cliente"),
            toLocalDate(rs.getDate("fecha_operacion")),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getBigDecimal("subtotal"),
            rs.getBigDecimal("total_descuentos"),
            rs.getBigDecimal("total_impuestos"),
            rs.getBigDecimal("total"),
            rs.getInt("plazo_credito"),
            rs.getString("metodo_pago"),
            rs.getString("usuario"),
            toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private VentaDto.VentaDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new VentaDto.VentaDetalle(
            rs.getInt("id"),
            rs.getString("fk_cliente"),
            rs.getString("nombre_cliente"),
            rs.getString("nit"),
            toLocalDate(rs.getDate("fecha_operacion")),
            toLocalDateTime(rs.getTimestamp("hora_operacion")),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getBigDecimal("subtotal"),
            rs.getBigDecimal("total_descuentos"),
            rs.getBigDecimal("total_impuestos"),
            rs.getBigDecimal("total"),
            rs.getInt("plazo_credito"),
            rs.getString("tipo_plazo"),
            rs.getInt("fk_metodo_pago"),
            rs.getString("metodo_pago"),
            rs.getString("usuario"),
            rs.getString("nombre_empleado"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            new ArrayList<>()
        );
    }

    private VentaDto.DetalleVenta mapItem(ResultSet rs) throws SQLException {
        return new VentaDto.DetalleVenta(
            rs.getInt("id"),
            rs.getInt("fk_venta"),
            rs.getInt("fk_producto"),
            rs.getString("nombre_producto"),
            rs.getString("fk_medida"),
            rs.getString("medida"),
            rs.getBigDecimal("cantidad"),
            rs.getBigDecimal("precio_unitario"),
            rs.getBigDecimal("descuentos"),
            rs.getBigDecimal("impuestos"),
            rs.getBigDecimal("subtotal")
        );
    }

    private LocalDate toLocalDate(Date d) {
        return d != null ? d.toLocalDate() : null;
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }

    private String estadoDesc(String estado) {
        if (estado == null) return "";
        return switch (estado) {
            case "P" -> "Pendiente";
            case "A" -> "Activa";
            case "C" -> "Completada";
            case "X" -> "Anulada";
            default  -> estado;
        };
    }
}
