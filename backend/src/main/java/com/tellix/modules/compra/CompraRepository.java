package com.tellix.modules.compra;

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
public class CompraRepository {

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public CompraRepository(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc   = jdbc;
        this.mapper = mapper;
    }

    // ── Listar compras paginado ────────────────────────────────
    public PagedResponse<CompraDto.CompraResumen> listar(
        String proveedor, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_compras @p_proveedor=?, @p_estado=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, proveedor);
                cs.setString(2, estado);
                cs.setDate(3,   desde != null ? Date.valueOf(desde) : null);
                cs.setDate(4,   hasta != null ? Date.valueOf(hasta) : null);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<CompraDto.CompraResumen> datos = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) total = rs.getLong("total");
                    }
                }
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

    // ── Obtener compra completa ────────────────────────────────
    public Optional<CompraDto.CompraDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_obtener_compra @p_id=?"
            )) {
                cs.setInt(1, id);

                CompraDto.CompraDetalle cabecera = null;
                List<CompraDto.DetalleCompra> items = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) cabecera = mapDetalle(rs);
                    }
                }
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) items.add(mapItem(rs));
                    }
                }

                if (cabecera == null) return Optional.empty();

                CompraDto.CompraDetalle completa = new CompraDto.CompraDetalle(
                    cabecera.id(), cabecera.noDocumento(),
                    cabecera.fkProveedor(), cabecera.nombreProveedor(),
                    cabecera.direccionProveedor(),
                    cabecera.fkRepresentante(), cabecera.nombreRepresentante(),
                    cabecera.fechaOperacion(), cabecera.horaOperacion(),
                    cabecera.estado(), estadoDesc(cabecera.estado()),
                    cabecera.subtotal(), cabecera.totalDescuentos(),
                    cabecera.totalImpuestos(), cabecera.total(),
                    cabecera.plazoCredito(), cabecera.fkMetodoPago(),
                    cabecera.metodoPago(), cabecera.usuario(),
                    cabecera.nombreEmpleado(),
                    cabecera.creadoEn(), cabecera.actualizadoEn(),
                    items
                );
                return Optional.of(completa);
            }
        });
    }

    // ── Registrar compra ───────────────────────────────────────
    public int registrar(CompraDto.CrearCompraRequest req, int fkUsuario) {
        String itemsJson;
        try {
            itemsJson = mapper.writeValueAsString(req.items());
        } catch (JsonProcessingException e) {
            throw new TellixException("Error al serializar los ítems.", HttpStatus.BAD_REQUEST);
        }

        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_registrar_compra @p_no_documento=?, @p_fk_proveedor=?, " +
                "@p_fk_representante=?, @p_fk_metodo_pago=?, @p_plazo_credito=?, " +
                "@p_usuario=?, @p_items=?, @p_id=?"
            )) {
                cs.setString(1,  req.noDocumento());
                cs.setString(2,  req.fkProveedor());
                cs.setString(3,  req.fkRepresentante());
                cs.setInt(4,     req.fkMetodoPago());
                cs.setInt(5,     req.plazoCredito() != null ? req.plazoCredito() : 0);
                cs.setInt(6,     fkUsuario);
                cs.setString(7,  itemsJson);
                cs.registerOutParameter(8, Types.INTEGER);

                cs.execute();
                return cs.getInt(8);
            }
        });
    }

    // ── Aprobar compra ─────────────────────────────────────────
    public void aprobar(int id, int fkUsuario) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_aprobar_compra @p_id=?, @p_usuario=?"
            )) {
                cs.setInt(1, id);
                cs.setInt(2, fkUsuario);
                cs.execute();
                return null;
            }
        });
    }

    // ── Completar compra ───────────────────────────────────────
    public void completar(int id) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_completar_compra @p_id=?"
            )) {
                cs.setInt(1, id);
                cs.execute();
                return null;
            }
        });
    }

    // ── Anular compra ──────────────────────────────────────────
    public void anular(int id, int fkUsuario, String motivo) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_anular_compra @p_id=?, @p_usuario=?, @p_motivo=?"
            )) {
                cs.setInt(1,    id);
                cs.setInt(2,    fkUsuario);
                cs.setString(3, motivo != null ? motivo : "Anulación manual");
                cs.execute();
                return null;
            }
        });
    }

    // ── Búsqueda de productos para compras ─────────────────────
    public List<CompraDto.ProductoCompra> buscarProductos(String busqueda) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_buscar_productos_compra @p_busqueda=?"
            )) {
                cs.setString(1, busqueda);

                List<CompraDto.ProductoCompra> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new CompraDto.ProductoCompra(
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getString("descripcion"),
                                    rs.getBigDecimal("stock_actual"),
                                    rs.getString("fk_medida"),
                                    rs.getString("medida"),
                                    rs.getString("estado")
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

    // ── Búsqueda de proveedores para compras ──────────────────
    public List<CompraDto.ProveedorCompra> buscarProveedores(String busqueda) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_buscar_proveedores_compra @p_busqueda=?"
            )) {
                cs.setString(1, busqueda);

                List<CompraDto.ProveedorCompra> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new CompraDto.ProveedorCompra(
                                    rs.getString("nit"),
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getString("direccion"),
                                    rs.getString("telefono"),
                                    rs.getString("email")
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

    // ── Listar métodos de pago ─────────────────────────────────
    public List<CompraDto.MetodoPagoDto> listarMetodosPago() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_metodos_pago")) {
                List<CompraDto.MetodoPagoDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new CompraDto.MetodoPagoDto(
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getString("descripcion"),
                                    rs.getObject("dias_credito", Integer.class),
                                    rs.getBoolean("activo")
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

    // ── Listar representantes ─────────────────────────────────
    public List<CompraDto.RepresentanteDto> buscarRepresentantes(String busqueda) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_representantes @p_busqueda=?"
            )) {
                cs.setString(1, busqueda);

                List<CompraDto.RepresentanteDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new CompraDto.RepresentanteDto(
                                    rs.getString("nit"),
                                    rs.getInt("codigo"),
                                    rs.getString("nombre"),
                                    rs.getString("telefono"),
                                    rs.getString("email")
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
    private CompraDto.CompraResumen mapResumen(ResultSet rs) throws SQLException {
        return new CompraDto.CompraResumen(
            rs.getInt("id"),
            rs.getString("no_documento"),
            rs.getString("fk_proveedor"),
            rs.getString("nombre_proveedor"),
            rs.getString("fk_representante"),
            rs.getString("nombre_representante"),
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

    private CompraDto.CompraDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new CompraDto.CompraDetalle(
            rs.getInt("id"),
            rs.getString("no_documento"),
            rs.getString("fk_proveedor"),
            rs.getString("nombre_proveedor"),
            rs.getString("direccion_proveedor"),
            rs.getString("fk_representante"),
            rs.getString("nombre_representante"),
            toLocalDate(rs.getDate("fecha_operacion")),
            toLocalDateTime(rs.getTimestamp("hora_operacion")),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getBigDecimal("subtotal"),
            rs.getBigDecimal("total_descuentos"),
            rs.getBigDecimal("total_impuestos"),
            rs.getBigDecimal("total"),
            rs.getInt("plazo_credito"),
            rs.getObject("fk_metodo_pago", Integer.class),
            rs.getString("metodo_pago"),
            rs.getString("usuario"),
            rs.getString("nombre_empleado"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en")),
            new ArrayList<>()
        );
    }

    private CompraDto.DetalleCompra mapItem(ResultSet rs) throws SQLException {
        return new CompraDto.DetalleCompra(
            rs.getInt("id"),
            rs.getInt("fk_compra"),
            rs.getInt("fk_producto"),
            rs.getString("nombre_producto"),
            rs.getString("descripcion_producto"),
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
            case "A" -> "Aprobada";
            case "C" -> "Completada";
            case "X" -> "Cancelada";
            default  -> estado;
        };
    }
}
