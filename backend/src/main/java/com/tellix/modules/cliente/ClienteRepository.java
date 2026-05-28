package com.tellix.modules.cliente;

import com.tellix.shared.dto.PagedResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class ClienteRepository {

    private final JdbcTemplate jdbc;

    public ClienteRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PagedResponse<ClienteDto.ClienteResumen> listar(String busqueda, String estado, Integer tipo, int pagina, int tamano) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_clientes @p_busqueda=?, @p_estado=?, @p_tipo=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, busqueda);
                cs.setString(2, estado);
                if (tipo != null) cs.setInt(3, tipo); else cs.setNull(3, Types.INTEGER);
                cs.setInt(4, pagina);
                cs.setInt(5, tamano);

                long total = 0;
                List<ClienteDto.ClienteResumen> datos = new ArrayList<>();

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

    public Optional<ClienteDto.ClienteDetalle> obtener(int codigo) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_obtener_cliente @p_codigo=?")) {
                cs.setInt(1, codigo);

                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs.next()) {
                                return Optional.of(mapDetalle(rs));
                            }
                        }
                        break;
                    }
                    int uc = cs.getUpdateCount();
                    if (!hasResult && uc == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return Optional.empty();
            }
        });
    }

    public int crear(ClienteDto.CrearClienteRequest req) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("{call sp_crear_cliente(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
                cs.setString(1,  req.nit());
                cs.setString(2,  req.nombre1());
                cs.setString(3,  req.nombre2());
                cs.setString(4,  req.nombre3());
                cs.setString(5,  req.apellido1());
                cs.setString(6,  req.apellido2());
                cs.setString(7,  req.apellidoCasada());
                cs.setString(8,  req.direccion());
                cs.setInt(9,     req.fkTipoCliente());
                cs.setBigDecimal(10, req.limiteCredito());
                cs.setString(11, req.telefono());
                cs.setString(12, req.email());
                cs.registerOutParameter(13, Types.INTEGER);
                cs.execute();
                return cs.getInt(13);
            }
        });
    }

    public void actualizar(int codigo, ClienteDto.ActualizarClienteRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_actualizar_cliente @p_codigo=?, @p_nombre_1=?, @p_nombre_2=?, @p_nombre_3=?, @p_apellido_1=?, @p_apellido_2=?, @p_apellido_casada=?, @p_direccion=?, @p_fk_tipo_cliente=?, @p_limite_credito=?, @p_telefono=?, @p_email=?"
            )) {
                cs.setInt(1,      codigo);
                cs.setString(2,   req.nombre1());
                cs.setString(3,   req.nombre2());
                cs.setString(4,   req.nombre3());
                cs.setString(5,   req.apellido1());
                cs.setString(6,   req.apellido2());
                cs.setString(7,   req.apellidoCasada());
                cs.setString(8,   req.direccion());
                cs.setInt(9,      req.fkTipoCliente());
                cs.setBigDecimal(10, req.limiteCredito());
                cs.setString(11,  req.telefono());
                cs.setString(12,  req.email());
                cs.execute();
                return null;
            }
        });
    }

    public void cambiarEstado(int codigo, String estado) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_cambiar_estado_cliente @p_codigo=?, @p_estado=?")) {
                cs.setInt(1, codigo);
                cs.setString(2, estado);
                cs.execute();
                return null;
            }
        });
    }

    private ClienteDto.ClienteResumen mapResumen(ResultSet rs) throws SQLException {
        return new ClienteDto.ClienteResumen(
            rs.getInt("codigo"),
            rs.getString("nit"),
            rs.getString("nombre"),
            rs.getString("nombre_1"),
            rs.getString("nombre_2"),
            rs.getString("nombre_3"),
            rs.getString("apellido_1"),
            rs.getString("apellido_2"),
            rs.getString("apellido_casada"),
            rs.getString("direccion"),
            rs.getObject("tipo_codigo", Integer.class),
            rs.getString("tipo_cliente"),
            rs.getBigDecimal("limite_credito"),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getString("telefono"),
            rs.getString("email"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en"))
        );
    }

    private ClienteDto.ClienteDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new ClienteDto.ClienteDetalle(
            rs.getInt("codigo"),
            rs.getString("nit"),
            rs.getString("nombre"),
            rs.getString("nombre_1"),
            rs.getString("nombre_2"),
            rs.getString("nombre_3"),
            rs.getString("apellido_1"),
            rs.getString("apellido_2"),
            rs.getString("apellido_casada"),
            rs.getString("direccion"),
            rs.getObject("tipo_codigo", Integer.class),
            rs.getString("tipo_cliente"),
            rs.getBigDecimal("limite_credito"),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getString("telefono"),
            rs.getString("email"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en"))
        );
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }
}
