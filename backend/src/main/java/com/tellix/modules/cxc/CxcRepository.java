package com.tellix.modules.cxc;

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
public class CxcRepository {

    private final JdbcTemplate jdbc;

    public CxcRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PagedResponse<CxcDto.CxcResumen> listar(String cliente, String estado, LocalDate desde, LocalDate hasta, Boolean vencidas, int pagina, int tamano) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_cxc @p_cliente=?, @p_estado=?, @p_fecha_desde=?, @p_fecha_hasta=?, @p_vencidas=?, @p_pagina=?, @p_tamano=?")) {
                cs.setString(1, cliente);
                cs.setString(2, estado);
                cs.setDate(3, desde != null ? Date.valueOf(desde) : null);
                cs.setDate(4, hasta != null ? Date.valueOf(hasta) : null);
                cs.setBoolean(5, Boolean.TRUE.equals(vencidas));
                cs.setInt(6, pagina);
                cs.setInt(7, tamano);

                long total = 0;
                List<CxcDto.CxcResumen> datos = new ArrayList<>();
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

    public Optional<CxcDto.CxcDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_obtener_cxc @p_id=?")) {
                cs.setInt(1, id);
                CxcDto.CxcDetalle detalle = null;
                List<CxcDto.MovimientoCobro> movimientos = new ArrayList<>();
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
                return Optional.of(new CxcDto.CxcDetalle(
                    detalle.id(), detalle.fkVenta(), detalle.fkCliente(), detalle.cliente(), detalle.direccion(),
                    detalle.fechaOperacion(), detalle.fechaLimite(), detalle.estado(), detalle.estadoDescripcion(),
                    detalle.valorTotal(), detalle.valorCobrado(), detalle.saldo(), detalle.cobrada(), detalle.vencida(),
                    detalle.fkMetodoPago(), detalle.metodoPago(), detalle.fkCuenta(), detalle.banco(), detalle.creadoEn(), movimientos
                ));
            }
        });
    }

    public void registrarCobro(int id, CxcDto.RegistrarCobroRequest req, int usuario) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_registrar_cobro_cxc @p_cxc_id=?, @p_monto=?, @p_metodo_pago=?, @p_cuenta=?, @p_usuario=?, @p_descripcion=?")) {
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
            try (CallableStatement cs = con.prepareCall("EXEC sp_anular_cxc @p_cxc_id=?, @p_usuario=?, @p_motivo=?")) {
                cs.setInt(1, id);
                cs.setInt(2, usuario);
                cs.setString(3, motivo);
                cs.execute();
                return null;
            }
        });
    }

    public List<CxcDto.CxcVencida> vencidas(LocalDate fecha) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_reporte_cxc_vencidas @p_fecha=?")) {
                cs.setDate(1, fecha != null ? Date.valueOf(fecha) : null);
                List<CxcDto.CxcVencida> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            while (rs.next()) lista.add(mapVencida(rs));
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

    public CxcDto.CxcResumenFinanciero resumen() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_resumen_cxc")) {
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs.next()) {
                                return new CxcDto.CxcResumenFinanciero(
                                    rs.getBigDecimal("totalPendiente"),
                                    rs.getBigDecimal("totalCobrado"),
                                    rs.getBigDecimal("saldoTotal"),
                                    rs.getInt("cuentasPendientes"),
                                    rs.getInt("cuentasVencidas"),
                                    rs.getInt("cuentasCobradas")
                                );
                            }
                        }
                        break;
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return new CxcDto.CxcResumenFinanciero(null, null, null, 0, 0, 0);
            }
        });
    }

    public int generarDesdeVenta(int ventaId) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("{call sp_generar_cxc_desde_venta(?, ?)}")) {
                cs.setInt(1, ventaId);
                cs.registerOutParameter(2, Types.INTEGER);
                cs.execute();
                return cs.getInt(2);
            }
        });
    }

    public List<CxcDto.MetodoCobroDto> listarMetodosCobro() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_metodos_cobro_cxc")) {
                List<CxcDto.MetodoCobroDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) lista.add(new CxcDto.MetodoCobroDto(rs.getInt("codigo"), rs.getString("descripcion")));
                    }
                }
                return lista;
            }
        });
    }

    public List<CxcDto.CuentaBancariaDto> listarCuentasBancarias() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_cuentas_bancarias_cxc")) {
                List<CxcDto.CuentaBancariaDto> lista = new ArrayList<>();
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        while (rs.next()) {
                            lista.add(new CxcDto.CuentaBancariaDto(
                                rs.getString("numero"),
                                rs.getInt("fk_banco"),
                                rs.getString("banco"),
                                rs.getString("titular"),
                                rs.getString("descripcion")
                            ));
                        }
                    }
                }
                return lista;
            }
        });
    }

    private CxcDto.CxcResumen mapResumen(ResultSet rs) throws SQLException {
        return new CxcDto.CxcResumen(
            rs.getInt("id"), rs.getInt("fk_venta"), rs.getString("fk_cliente"), rs.getString("cliente"),
            toLocalDate(rs.getDate("fecha_operacion")), toLocalDate(rs.getDate("fecha_limite")), rs.getString("estado"), rs.getString("estado_descripcion"),
            rs.getBigDecimal("valor_total"), rs.getBigDecimal("valor_cobrado"), rs.getBigDecimal("saldo"),
            rs.getBoolean("cobrada"), rs.getBoolean("vencida"), rs.getInt("dias_vencida"), rs.getInt("fk_metodo_pago"),
            rs.getString("metodo_pago"), rs.getString("fk_cuenta"), toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private CxcDto.CxcDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new CxcDto.CxcDetalle(
            rs.getInt("id"), rs.getInt("fk_venta"), rs.getString("fk_cliente"), rs.getString("cliente"), rs.getString("direccion"),
            toLocalDate(rs.getDate("fecha_operacion")), toLocalDate(rs.getDate("fecha_limite")), rs.getString("estado"), rs.getString("estado_descripcion"),
            rs.getBigDecimal("valor_total"), rs.getBigDecimal("valor_cobrado"), rs.getBigDecimal("saldo"), rs.getBoolean("cobrada"), rs.getBoolean("vencida"),
            rs.getInt("fk_metodo_pago"), rs.getString("metodo_pago"), rs.getString("fk_cuenta"), rs.getString("banco"), toLocalDateTime(rs.getTimestamp("creado_en")), new ArrayList<>()
        );
    }

    private CxcDto.MovimientoCobro mapMovimiento(ResultSet rs) throws SQLException {
        return new CxcDto.MovimientoCobro(
            rs.getInt("id"), rs.getString("fk_cuenta"), rs.getString("tipo_documento"), rs.getString("no_documento"),
            toLocalDate(rs.getDate("fecha_operacion")), rs.getBigDecimal("monto"), rs.getString("descripcion"), rs.getInt("fk_usuario"), rs.getString("usuario")
        );
    }

    private CxcDto.CxcVencida mapVencida(ResultSet rs) throws SQLException {
        return new CxcDto.CxcVencida(
            rs.getInt("id"),
            rs.getInt("fk_venta"),
            rs.getString("fk_cliente"),
            rs.getString("cliente"),
            rs.getBigDecimal("valor_total"),
            rs.getBigDecimal("valor_cobrado"),
            rs.getBigDecimal("saldo"),
            toLocalDate(rs.getDate("fecha_limite")),
            rs.getInt("dias_vencida")
        );
    }

    private LocalDate toLocalDate(Date d) {
        return d != null ? d.toLocalDate() : null;
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }
}
