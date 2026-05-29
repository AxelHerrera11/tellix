package com.tellix.modules.cxp;

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
public class CxpRepository {

    private final JdbcTemplate jdbc;

    public CxpRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PagedResponse<CxpDto.CxpResumen> listar(
        String proveedor, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_cxp @p_proveedor=?, @p_estado=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, proveedor);
                cs.setString(2, estado);
                cs.setDate(3,   desde != null ? Date.valueOf(desde) : null);
                cs.setDate(4,   hasta != null ? Date.valueOf(hasta) : null);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<CxpDto.CxpResumen> datos = new ArrayList<>();

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

    public Optional<CxpDto.CxpDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_obtener_cxp @p_id=?"
            )) {
                cs.setInt(1, id);

                CxpDto.CxpDetalle cabecera = null;
                List<CxpDto.DetalleCompra> items = new ArrayList<>();

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

                CxpDto.CxpDetalle completa = new CxpDto.CxpDetalle(
                    cabecera.id(), cabecera.fkCompra(), cabecera.noDocumento(),
                    cabecera.proveedorNit(), cabecera.proveedor(),
                    cabecera.proveedorDireccion(),
                    cabecera.estado(), estadoDesc(cabecera.estado()),
                    cabecera.valorTotal(), cabecera.valorPagado(), cabecera.saldo(),
                    cabecera.fechaLimite(), cabecera.fkMetodoPago(), cabecera.metodoPago(),
                    cabecera.fkCuenta(), cabecera.cuentaNumero(), cabecera.banco(),
                    cabecera.fechaCompra(), cabecera.compraSubtotal(),
                    cabecera.compraDescuentos(), cabecera.compraImpuestos(),
                    cabecera.compraTotal(), cabecera.usuario(), cabecera.nombreEmpleado(),
                    cabecera.creadoEn(), cabecera.actualizadoEn(), items
                );
                return Optional.of(completa);
            }
        });
    }

    public void registrarPago(int id, java.math.BigDecimal monto, int fkUsuario, String descripcion) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_registrar_pago_cxp @p_id=?, @p_monto=?, @p_usuario=?, @p_descripcion=?"
            )) {
                cs.setInt(1, id);
                cs.setBigDecimal(2, monto);
                cs.setInt(3, fkUsuario);
                cs.setString(4, descripcion);
                cs.execute();
                return null;
            }
        });
    }

    public void anular(int id, int fkUsuario, String motivo) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_anular_cxp @p_id=?, @p_usuario=?, @p_motivo=?"
            )) {
                cs.setInt(1, id);
                cs.setInt(2, fkUsuario);
                cs.setString(3, motivo != null ? motivo : "Anulación manual");
                cs.execute();
                return null;
            }
        });
    }

    public List<CxpDto.CxpVencida> reporteVencidas(LocalDate fecha) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_reporte_cxp_vencidas @p_fecha=?"
            )) {
                cs.setDate(1, fecha != null ? Date.valueOf(fecha) : null);

                List<CxpDto.CxpVencida> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) {
                                lista.add(new CxpDto.CxpVencida(
                                    rs.getInt("id"),
                                    rs.getInt("fk_compra"),
                                    rs.getString("no_documento"),
                                    rs.getString("proveedor"),
                                    rs.getBigDecimal("valor_total"),
                                    rs.getBigDecimal("valor_pagado"),
                                    rs.getBigDecimal("saldo"),
                                    toLocalDate(rs.getDate("fecha_limite")),
                                    rs.getInt("dias_vencida")
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

    private CxpDto.CxpResumen mapResumen(ResultSet rs) throws SQLException {
        return new CxpDto.CxpResumen(
            rs.getInt("id"),
            rs.getInt("fk_compra"),
            rs.getString("no_documento"),
            rs.getString("proveedor_nit"),
            rs.getString("proveedor"),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getBigDecimal("valor_total"),
            rs.getBigDecimal("valor_pagado"),
            rs.getBigDecimal("saldo"),
            toLocalDate(rs.getDate("fecha_limite")),
            rs.getString("metodo_pago"),
            toLocalDate(rs.getDate("fecha_compra")),
            toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private CxpDto.CxpDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new CxpDto.CxpDetalle(
            rs.getInt("id"),
            rs.getInt("fk_compra"),
            rs.getString("no_documento"),
            rs.getString("proveedor_nit"),
            rs.getString("proveedor"),
            rs.getString("proveedor_direccion"),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getBigDecimal("valor_total"),
            rs.getBigDecimal("valor_pagado"),
            rs.getBigDecimal("saldo"),
            toLocalDate(rs.getDate("fecha_limite")),
            rs.getInt("fk_metodo_pago"),
            rs.getString("metodo_pago"),
            rs.getString("fk_cuenta"),
            rs.getString("cuenta_numero"),
            rs.getString("banco"),
            toLocalDate(rs.getDate("fecha_compra")),
            rs.getBigDecimal("compra_subtotal"),
            rs.getBigDecimal("compra_descuentos"),
            rs.getBigDecimal("compra_impuestos"),
            rs.getBigDecimal("compra_total"),
            rs.getString("usuario"),
            rs.getString("nombre_empleado"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en")),
            new ArrayList<>()
        );
    }

    private CxpDto.DetalleCompra mapItem(ResultSet rs) throws SQLException {
        return new CxpDto.DetalleCompra(
            rs.getInt("id"),
            rs.getInt("fk_compra"),
            rs.getInt("fk_producto"),
            rs.getString("nombre_producto"),
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
            case "A" -> "Abonada";
            case "X" -> "Cancelada";
            default  -> estado;
        };
    }
}
