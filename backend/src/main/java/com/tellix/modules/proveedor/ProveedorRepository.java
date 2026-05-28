package com.tellix.modules.proveedor;

import com.tellix.shared.dto.PagedResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Repository
public class ProveedorRepository {

    private final JdbcTemplate jdbc;

    public ProveedorRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PagedResponse<ProveedorDto.ProveedorResumen> listar(String busqueda, String estado, int pagina, int tamano) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_proveedores @p_busqueda=?, @p_estado=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, busqueda);
                cs.setString(2, estado);
                cs.setInt(3, pagina);
                cs.setInt(4, tamano);

                long total = 0;
                List<ProveedorDto.ProveedorResumen> datos = new ArrayList<>();

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

    public Optional<ProveedorDto.ProveedorDetalle> obtener(String nit) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_obtener_proveedor @p_nit=?")) {
                cs.setString(1, nit);

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

    public void crear(ProveedorDto.CrearProveedorRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_crear_proveedor @p_nit=?, @p_nombre=?, @p_direccion=?"
            )) {
                cs.setString(1, req.nit());
                cs.setString(2, req.nombre());
                cs.setString(3, req.direccion());
                cs.execute();
                return null;
            }
        });
    }

    public void actualizar(String nit, ProveedorDto.ActualizarProveedorRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_actualizar_proveedor @p_nit=?, @p_nombre=?, @p_direccion=?"
            )) {
                cs.setString(1, nit);
                cs.setString(2, req.nombre());
                cs.setString(3, req.direccion());
                cs.execute();
                return null;
            }
        });
    }

    public void cambiarEstado(String nit, String estado) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_cambiar_estado_proveedor @p_nit=?, @p_estado=?")) {
                cs.setString(1, nit);
                cs.setString(2, estado);
                cs.execute();
                return null;
            }
        });
    }

    private ProveedorDto.ProveedorResumen mapResumen(ResultSet rs) throws SQLException {
        return new ProveedorDto.ProveedorResumen(
            rs.getString("nit"),
            rs.getString("nombre"),
            rs.getString("direccion_fiscal"),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getString("representante"),
            rs.getString("telefono"),
            rs.getString("email"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en"))
        );
    }

    private ProveedorDto.ProveedorDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new ProveedorDto.ProveedorDetalle(
            rs.getString("nit"),
            rs.getString("nombre"),
            rs.getString("direccion_fiscal"),
            rs.getString("estado"),
            rs.getString("estado_descripcion"),
            rs.getString("representante"),
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
