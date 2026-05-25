package com.tellix.modules.producto;

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
public class ProductoRepository {

    private final JdbcTemplate jdbc;

    public ProductoRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Listar productos paginado ─────────────────────────────
    public PagedResponse<ProductoDto.ProductoResumen> listar(
        String busqueda, Integer categoria, Integer marca,
        String estado, int pagina, int tamano
    ) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_listar_productos @p_busqueda=?, @p_categoria=?, @p_marca=?, @p_estado=?, @p_pagina=?, @p_tamano=?"
            )) {
                cs.setString(1, busqueda);
                if (categoria != null) cs.setInt(2, categoria);
                else cs.setNull(2, Types.INTEGER);
                if (marca != null) cs.setInt(3, marca);
                else cs.setNull(3, Types.INTEGER);
                cs.setString(4, estado);
                cs.setInt(5, pagina);
                cs.setInt(6, tamano);

                long total = 0;
                List<ProductoDto.ProductoResumen> datos = new ArrayList<>();

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

    // ── Obtener producto completo ─────────────────────────────
    public Optional<ProductoDto.ProductoDetalle> obtener(int id) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_obtener_producto @p_id=?"
            )) {
                cs.setInt(1, id);

                ProductoDto.ProductoDetalle cabecera = null;
                List<ProductoDto.PrecioProducto> precios = new ArrayList<>();
                List<ProductoDto.ImpuestoAsignado> impuestos = new ArrayList<>();
                List<ProductoDto.DescuentoAsignado> descuentos = new ArrayList<>();

                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) cabecera = mapDetalle(rs);
                    }
                }

                int rsIndex = 0;
                while (cs.getMoreResults()) {
                    rsIndex++;
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rsIndex == 1) {
                            while (rs.next()) precios.add(mapPrecio(rs));
                        } else if (rsIndex == 2) {
                            while (rs.next()) impuestos.add(mapImpuesto(rs));
                        } else if (rsIndex == 3) {
                            while (rs.next()) descuentos.add(mapDescuento(rs));
                        }
                    }
                }

                if (cabecera == null) return Optional.empty();

                ProductoDto.ProductoDetalle completa = new ProductoDto.ProductoDetalle(
                    cabecera.codigo(), cabecera.nombre(), cabecera.descripcion(),
                    cabecera.stockActual(), cabecera.stockMinimo(),
                    cabecera.estado(), estadoDesc(cabecera.estado()),
                    cabecera.categoriaCodigo(), cabecera.categoria(),
                    cabecera.marcaCodigo(), cabecera.marca(),
                    cabecera.medidaCodigo(), cabecera.medida(),
                    cabecera.cantidadMedida(),
                    cabecera.creadoEn(), cabecera.actualizadoEn(),
                    precios, impuestos, descuentos
                );
                return Optional.of(completa);
            }
        });
    }

    // ── Crear producto ────────────────────────────────────────
    public int crear(ProductoDto.CrearProductoRequest req, int usuario) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_crear_producto @p_nombre=?, @p_descripcion=?, @p_stock_minimo=?, " +
                "@p_fk_categoria=?, @p_fk_marca=?, @p_fk_medida=?, @p_cantidad_medida=?, " +
                "@p_precio_venta=?, @p_aplicacion=?, @p_usuario=?, @p_id=?"
            )) {
                cs.setString(1,  req.nombre());
                cs.setString(2,  req.descripcion());
                cs.setBigDecimal(3, req.stockMinimo());
                if (req.fkCategoria() != null) cs.setInt(4, req.fkCategoria());
                else cs.setNull(4, Types.INTEGER);
                if (req.fkMarca() != null) cs.setInt(5, req.fkMarca());
                else cs.setNull(5, Types.INTEGER);
                cs.setString(6,  req.fkMedida());
                if (req.cantidadMedida() != null) cs.setBigDecimal(7, req.cantidadMedida());
                else cs.setNull(7, Types.DECIMAL);
                if (req.precioVenta() != null) cs.setBigDecimal(8, req.precioVenta());
                else cs.setNull(8, Types.DECIMAL);
                cs.setString(9,  req.aplicacion());
                cs.setInt(10,    usuario);
                cs.registerOutParameter(11, Types.INTEGER);

                cs.execute();
                return cs.getInt(11);
            }
        });
    }

    // ── Actualizar producto ───────────────────────────────────
    public void actualizar(int id, ProductoDto.ActualizarProductoRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_actualizar_producto @p_id=?, @p_nombre=?, @p_descripcion=?, " +
                "@p_stock_minimo=?, @p_fk_categoria=?, @p_fk_marca=?, @p_fk_medida=?, @p_cantidad_medida=?"
            )) {
                cs.setInt(1,    id);
                cs.setString(2, req.nombre());
                cs.setString(3, req.descripcion());
                cs.setBigDecimal(4, req.stockMinimo());
                if (req.fkCategoria() != null) cs.setInt(5, req.fkCategoria());
                else cs.setNull(5, Types.INTEGER);
                if (req.fkMarca() != null) cs.setInt(6, req.fkMarca());
                else cs.setNull(6, Types.INTEGER);
                cs.setString(7,  req.fkMedida());
                if (req.cantidadMedida() != null) cs.setBigDecimal(8, req.cantidadMedida());
                else cs.setNull(8, Types.DECIMAL);
                cs.execute();
                return null;
            }
        });
    }

    // ── Cambiar estado ────────────────────────────────────────
    public void cambiarEstado(int id, ProductoDto.CambiarEstadoRequest req) {
        jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_cambiar_estado_producto @p_id=?, @p_estado=?"
            )) {
                cs.setInt(1,    id);
                cs.setString(2, req.estado());
                cs.execute();
                return null;
            }
        });
    }

    // ── Asignar precio ────────────────────────────────────────
    public int asignarPrecio(int productoId, ProductoDto.AsignarPrecioRequest req, int usuario) {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall(
                "EXEC sp_asignar_precio_producto @p_producto=?, @p_precio_venta=?, " +
                "@p_aplicacion=?, @p_inicio_vigencia=?, @p_usuario=?, @p_id=?"
            )) {
                cs.setInt(1,       productoId);
                cs.setBigDecimal(2, req.precioVenta());
                cs.setString(3,    req.aplicacion());
                if (req.inicioVigencia() != null) cs.setDate(4, Date.valueOf(req.inicioVigencia()));
                else cs.setNull(4, Types.DATE);
                cs.setInt(5,    usuario);
                cs.registerOutParameter(6, Types.INTEGER);
                cs.execute();
                return cs.getInt(6);
            }
        });
    }

    // ── Catálogos auxiliares ──────────────────────────────────
    public List<ProductoDto.CategoriaDto> listarCategorias() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_categorias")) {
                return mapList(cs, this::mapCategoria);
            }
        });
    }

    public List<ProductoDto.MarcaDto> listarMarcas() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_marcas")) {
                return mapList(cs, this::mapMarca);
            }
        });
    }

    public List<ProductoDto.MedidaDto> listarMedidas() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_medidas")) {
                return mapList(cs, this::mapMedida);
            }
        });
    }

    public List<ProductoDto.ImpuestoDto> listarImpuestos() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_impuestos")) {
                return mapList(cs, this::mapImpuestoDto);
            }
        });
    }

    public List<ProductoDto.DescuentoDto> listarDescuentos() {
        return jdbc.execute((Connection con) -> {
            try (CallableStatement cs = con.prepareCall("EXEC sp_listar_descuentos")) {
                return mapList(cs, this::mapDescuentoDto);
            }
        });
    }

    // ── Helper para listas simples ────────────────────────────
    private <T> List<T> mapList(CallableStatement cs, RowMapper<T> mapper) throws SQLException {
        List<T> lista = new ArrayList<>();
        boolean hasResult = cs.execute();
        while (true) {
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) lista.add(mapper.map(rs));
                }
                break;
            }
            int uc = cs.getUpdateCount();
            if (!hasResult && uc == -1) break;
            hasResult = cs.getMoreResults();
        }
        return lista;
    }

    @FunctionalInterface
    private interface RowMapper<T> {
        T map(ResultSet rs) throws SQLException;
    }

    // ── Mappers ───────────────────────────────────────────────
    private ProductoDto.ProductoResumen mapResumen(ResultSet rs) throws SQLException {
        return new ProductoDto.ProductoResumen(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getBigDecimal("stock_actual"),
            rs.getBigDecimal("stock_minimo"),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getObject("categoria_codigo", Integer.class),
            rs.getString("categoria"),
            rs.getObject("marca_codigo", Integer.class),
            rs.getString("marca"),
            rs.getString("medida_codigo"),
            rs.getString("medida"),
            rs.getBigDecimal("cantidad_medida"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en"))
        );
    }

    private ProductoDto.ProductoDetalle mapDetalle(ResultSet rs) throws SQLException {
        return new ProductoDto.ProductoDetalle(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getBigDecimal("stock_actual"),
            rs.getBigDecimal("stock_minimo"),
            rs.getString("estado"),
            estadoDesc(rs.getString("estado")),
            rs.getObject("categoria_codigo", Integer.class),
            rs.getString("categoria"),
            rs.getObject("marca_codigo", Integer.class),
            rs.getString("marca"),
            rs.getString("medida_codigo"),
            rs.getString("medida"),
            rs.getBigDecimal("cantidad_medida"),
            toLocalDateTime(rs.getTimestamp("creado_en")),
            toLocalDateTime(rs.getTimestamp("actualizado_en")),
            new ArrayList<>(),
            new ArrayList<>(),
            new ArrayList<>()
        );
    }

    private ProductoDto.PrecioProducto mapPrecio(ResultSet rs) throws SQLException {
        return new ProductoDto.PrecioProducto(
            rs.getInt("id"),
            rs.getInt("fk_producto"),
            rs.getBigDecimal("precio_venta"),
            rs.getString("aplicacion"),
            toLocalDate(rs.getDate("inicio_vigencia")),
            toLocalDate(rs.getDate("fin_vigencia")),
            rs.getString("estado"),
            rs.getObject("creado_por", Integer.class),
            toLocalDateTime(rs.getTimestamp("creado_en"))
        );
    }

    private ProductoDto.ImpuestoAsignado mapImpuesto(ResultSet rs) throws SQLException {
        return new ProductoDto.ImpuestoAsignado(
            rs.getInt("id"),
            rs.getInt("fk_impuesto"),
            rs.getString("impuesto"),
            rs.getString("tipo_calculo"),
            rs.getBigDecimal("valor_base"),
            rs.getBigDecimal("valor_override"),
            rs.getString("aplicaciones"),
            toLocalDate(rs.getDate("fecha_inicio")),
            toLocalDate(rs.getDate("fecha_fin")),
            rs.getString("estado")
        );
    }

    private ProductoDto.DescuentoAsignado mapDescuento(ResultSet rs) throws SQLException {
        return new ProductoDto.DescuentoAsignado(
            rs.getInt("id"),
            rs.getInt("fk_descuento"),
            rs.getString("descuento"),
            rs.getString("tipo_calculo"),
            rs.getBigDecimal("valor_base"),
            rs.getBigDecimal("valor_override"),
            rs.getString("aplicaciones"),
            toLocalDate(rs.getDate("fecha_inicio")),
            toLocalDate(rs.getDate("fecha_fin")),
            rs.getString("estado")
        );
    }

    private ProductoDto.CategoriaDto mapCategoria(ResultSet rs) throws SQLException {
        return new ProductoDto.CategoriaDto(
            rs.getInt("codigo"),
            rs.getString("descripcion"),
            rs.getBoolean("activo")
        );
    }

    private ProductoDto.MarcaDto mapMarca(ResultSet rs) throws SQLException {
        return new ProductoDto.MarcaDto(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getBoolean("activo")
        );
    }

    private ProductoDto.MedidaDto mapMedida(ResultSet rs) throws SQLException {
        return new ProductoDto.MedidaDto(
            rs.getString("codigo"),
            rs.getString("descripcion")
        );
    }

    private ProductoDto.ImpuestoDto mapImpuestoDto(ResultSet rs) throws SQLException {
        return new ProductoDto.ImpuestoDto(
            rs.getInt("codigo"),
            rs.getString("descripcion"),
            rs.getString("tipo_calculo"),
            rs.getBigDecimal("valor"),
            rs.getBoolean("activo")
        );
    }

    private ProductoDto.DescuentoDto mapDescuentoDto(ResultSet rs) throws SQLException {
        return new ProductoDto.DescuentoDto(
            rs.getInt("codigo"),
            rs.getString("descripcion"),
            rs.getString("tipo_calculo"),
            rs.getBigDecimal("valor"),
            rs.getBoolean("activo")
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
            case "A" -> "Activo";
            case "I" -> "Inactivo";
            default  -> estado;
        };
    }
}
