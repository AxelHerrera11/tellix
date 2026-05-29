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

    public PagedResponse<CxpDto.CxpResumen> listar(String proveedor, String estado, LocalDate desde, LocalDate hasta, Boolean vencidas, int pagina, int tamano) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_cxp @p_proveedor=?, @p_estado=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_vencidas=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, proveedor);
                cs.setString(2, estado);
                cs.setDate(3, desde != null ? Date.valueOf(desde) : null);
                cs.setDate(4, hasta != null ? Date.valueOf(hasta) : null);
                cs.setBoolean(5, Boolean.TRUE.equals(vencidas));
                cs.setInt(6, pagina);
                cs.setInt(7, tamano);

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
            try (CallableStatement cs = con.prepareCall("EXEC sp_obtener_cxp @p_id=?")) {
                cs.setInt(1, id);

                CxpDto.CxpDetalle detalle = null;
                List<CxpDto.MovimientoPago> movimientos = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) detalle = mapDetalle(rs);
                    }
                }
                if (cs.getMoreResults()) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) movimientos.add(mapMovimiento(rs));
                    }
                }

                if (detalle == null) return Optional.empty();

                return Optional.of(new CxpDto.CxpDetalle(
                    detalle.id(), detalle.fkCompra(), detalle.noDocumento(), detalle.fkProveedor(), detalle.proveedor(),
                    detalle.direccionFiscal(), detalle.fechaOperacion(), detalle.fechaLimite(), detalle.estado(), detalle.estadoDescripcion(),
                    detalle.valorTotal(), detalle.valorPagado(), detalle.saldo(), detalle.pagada(), detalle.vencida(),
                    detalle.fkMetodoPago(), detalle.metodoPago(), detalle.fkCuenta(), detalle.fkBanco(), detalle.banco(), detalle.creadoEn(), movimientos
                ));
            }
        });
    }

    public void registrarPago(int id, CxpDto.RegistrarPagoRequest req, int usuario) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_registrar_pago_cxp @p_cxp_id=?, @p_monto=?, @p_metodo_pago=?, @p_cuenta=?, @p_usuario=?, @p_descripcion=?"
            )) {
                cs.setInt(1, id);
                cs.setBigDecimal(2, req.monto());
                cs.setInt(3, req.fkMetodoPago());
                cs.setString(4, req.fkCuenta());
                cs.setInt(5, usuario);
                cs.setString(6, req.descripcion());
                cs.execute();
                return null;
            }
        });
    }

    public void anular(int id, int usuario, String motivo) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_anular_cxp @p_cxp_id=?, @p_usuario=?, @p_motivo=?")) {
                cs.setInt(1, id);
                cs.setInt(2, usuario);
                cs.setString(3, motivo);
                cs.execute();
                return null;
            }
        });
    }

    public List<CxpDto.CxpResumen> vencidas(LocalDate fecha) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_reporte_cxp_vencidas @p_fecha=?")) {
                cs.setDate(1, fecha != null ? Date.valueOf(fecha) : null);
                List<CxpDto.CxpResumen> lista = new ArrayList<>();

                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) lista.add(mapResumen(rs));
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

    public CxpDto.CxpResumenFinanciero resumen() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_resumen_cxp")) {
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs.next()) {
                                return new CxpDto.CxpResumenFinanciero(
                                    rs.getBigDecimal("total_pendiente"),
                                    rs.getBigDecimal("total_pagado"),
                                    rs.getBigDecimal("saldo_total"),
                                    rs.getInt("cuentas_pendientes"),
                                    rs.getInt("cuentas_vencidas"),
                                    rs.getInt("cuentas_pagadas")
                                );
                            }
                        }
                        break;
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return new CxpDto.CxpResumenFinanciero(null, null, null, 0, 0, 0);
            }
        });
    }

    public int generarDesdeCompra(int compraId) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("{call sp_generar_cxp_desde_compra(?, ?)}")) {
                cs.setInt(1, compraId);
                cs.registerOutParameter(2, Types.INTEGER);
                cs.execute();
                return cs.getInt(2);
            }
        });
    }

    public List<CxpDto.MetodoPagoDto> listarMetodosPago() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_metodos_pago_cxp")) {
                List<CxpDto.MetodoPagoDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) lista.add(mapMetodoPago(rs));
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

    public List<CxpDto.CuentaBancariaDto> listarCuentasBancarias() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_cuentas_bancarias_cxp")) {
                List<CxpDto.CuentaBancariaDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) lista.add(mapCuentaBancaria(rs));
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
            rs.getString("fk_proveedor"),
            rs.getString("proveedor"),
            toLocalDate(rs.getDate("fecha_operacion")),
            toLocalDate(rs.getDate("fecha_limite")),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getBigDecimal("valor_total"),
            rs.getBigDecimal("valor_pagado"),
            rs.getBigDecimal("saldo"),
            rs.getBoolean("pagada"),
            rs.getBoolean("vencida"),
            rs.getInt("dias_vencida"),
            rs.getInt("fk_metodo_pago"),
            rs.getString("metodo_pago"),
            rs.getString("fk_cuenta"),
            rs.getObject("fk_banco", Integer.class),
            toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private CxpDto.CxpDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new CxpDto.CxpDetalle(
            rs.getInt("id"),
            rs.getInt("fk_compra"),
            rs.getString("no_documento"),
            rs.getString("fk_proveedor"),
            rs.getString("proveedor"),
            rs.getString("direccion_fiscal"),
            toLocalDate(rs.getDate("fecha_operacion")),
            toLocalDate(rs.getDate("fecha_limite")),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getBigDecimal("valor_total"),
            rs.getBigDecimal("valor_pagado"),
            rs.getBigDecimal("saldo"),
            rs.getBoolean("pagada"),
            rs.getBoolean("vencida"),
            rs.getInt("fk_metodo_pago"),
            rs.getString("metodo_pago"),
            rs.getString("fk_cuenta"),
            rs.getObject("fk_banco", Integer.class),
            rs.getString("banco"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            new ArrayList<>()
        );
    }

    private CxpDto.MovimientoPago mapMovimiento(ResultSet rs) throws SQLException {
        return new CxpDto.MovimientoPago(
            rs.getInt("id"),
            rs.getString("fk_cuenta"),
            rs.getString("tipo_documento"),
            rs.getString("no_documento"),
            toLocalDate(rs.getDate("fecha_operacion")),
            rs.getBigDecimal("monto"),
            rs.getString("descripcion"),
            rs.getInt("fk_usuario"),
            rs.getString("usuario")
        );
    }

    private CxpDto.MetodoPagoDto mapMetodoPago(ResultSet rs) throws SQLException {
        return new CxpDto.MetodoPagoDto(rs.getInt("codigo"), rs.getString("descripcion"));
    }

    private CxpDto.CuentaBancariaDto mapCuentaBancaria(ResultSet rs) throws SQLException {
        return new CxpDto.CuentaBancariaDto(
            rs.getString("numero"),
            rs.getInt("fk_banco"),
            rs.getString("banco"),
            rs.getString("titular"),
            rs.getString("descripcion")
        );
    }

    private LocalDate toLocalDate(Date d) {
        return d != null ? d.toLocalDate() : null;
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }
}
