package com.tellix.modules.producto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class ProductoDto {

    // ── Request: crear producto ───────────────────────────────
    public record CrearProductoRequest(
        @NotBlank(message = "El nombre es requerido")
        String nombre,

        String descripcion,

        @DecimalMin(value = "0", message = "El stock mínimo no puede ser negativo")
        BigDecimal stockMinimo,

        Integer fkCategoria,
        Integer fkMarca,
        String  fkMedida,

        @DecimalMin(value = "0", message = "La cantidad de medida no puede ser negativa")
        BigDecimal cantidadMedida,

        @DecimalMin(value = "0", message = "El precio no puede ser negativo")
        BigDecimal precioVenta,

        String  aplicacion
    ) {}

    // ── Request: actualizar producto ──────────────────────────
    public record ActualizarProductoRequest(
        @NotBlank(message = "El nombre es requerido")
        String nombre,

        String descripcion,

        @DecimalMin(value = "0", message = "El stock mínimo no puede ser negativo")
        BigDecimal stockMinimo,

        Integer fkCategoria,
        Integer fkMarca,
        String  fkMedida,

        @DecimalMin(value = "0", message = "La cantidad de medida no puede ser negativa")
        BigDecimal cantidadMedida
    ) {}

    // ── Request: cambiar estado ───────────────────────────────
    public record CambiarEstadoRequest(
        @NotBlank(message = "El estado es requerido")
        @Pattern(regexp = "A|I", message = "Estado debe ser A o I")
        String estado
    ) {}

    // ── Request: asignar precio ───────────────────────────────
    public record AsignarPrecioRequest(
        @NotNull(message = "El precio de venta es requerido")
        @DecimalMin(value = "0.01", message = "El precio debe ser mayor a cero")
        BigDecimal precioVenta,

        @NotBlank(message = "La aplicación es requerida")
        String aplicacion,

        LocalDate inicioVigencia
    ) {}

    // ── Response: listado resumen ────────────────────────────
    public record ProductoResumen(
        Integer    codigo,
        String     nombre,
        String     descripcion,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        String     estado,
        String     estadoDescripcion,
        Integer    categoriaCodigo,
        String     categoria,
        Integer    marcaCodigo,
        String     marca,
        String     medidaCodigo,
        String     medida,
        BigDecimal cantidadMedida,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn
    ) {}

    // ── Response: detalle completo ────────────────────────────
    public record ProductoDetalle(
        Integer    codigo,
        String     nombre,
        String     descripcion,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        String     estado,
        String     estadoDescripcion,
        Integer    categoriaCodigo,
        String     categoria,
        Integer    marcaCodigo,
        String     marca,
        String     medidaCodigo,
        String     medida,
        BigDecimal cantidadMedida,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn,
        List<PrecioProducto> precios,
        List<ImpuestoAsignado> impuestos,
        List<DescuentoAsignado> descuentos
    ) {}

    // ── Response: precio ──────────────────────────────────────
    public record PrecioProducto(
        Integer    id,
        Integer    fkProducto,
        BigDecimal precioVenta,
        String     aplicacion,
        LocalDate  inicioVigencia,
        LocalDate  finVigencia,
        String     estado,
        Integer    creadoPor,
        LocalDateTime creadoEn
    ) {}

    // ── Response: impuesto asignado ───────────────────────────
    public record ImpuestoAsignado(
        Integer    id,
        Integer    fkImpuesto,
        String     impuesto,
        String     tipoCalculo,
        BigDecimal valorBase,
        BigDecimal valorOverride,
        String     aplicaciones,
        LocalDate  fechaInicio,
        LocalDate  fechaFin,
        String     estado
    ) {}

    // ── Response: descuento asignado ──────────────────────────
    public record DescuentoAsignado(
        Integer    id,
        Integer    fkDescuento,
        String     descuento,
        String     tipoCalculo,
        BigDecimal valorBase,
        BigDecimal valorOverride,
        String     aplicaciones,
        LocalDate  fechaInicio,
        LocalDate  fechaFin,
        String     estado
    ) {}

    // ── Response: catálogos auxiliares ────────────────────────
    public record CategoriaDto(
        Integer codigo,
        String  descripcion,
        Boolean activo
    ) {}

    public record MarcaDto(
        Integer codigo,
        String  nombre,
        String  descripcion,
        Boolean activo
    ) {}

    public record MedidaDto(
        String codigo,
        String descripcion
    ) {}

    public record ImpuestoDto(
        Integer    codigo,
        String     descripcion,
        String     tipoCalculo,
        BigDecimal valor,
        Boolean    activo
    ) {}

    public record DescuentoDto(
        Integer    codigo,
        String     descripcion,
        String     tipoCalculo,
        BigDecimal valor,
        Boolean    activo
    ) {}
}
