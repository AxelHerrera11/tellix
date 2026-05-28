package com.tellix.modules.compra;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CompraDto {

    // ── Request: crear compra ──────────────────────────────────
    public record CrearCompraRequest(
        @NotBlank(message = "El número de documento es requerido")
        String noDocumento,

        @NotBlank(message = "El proveedor es requerido")
        String fkProveedor,

        String fkRepresentante,

        @NotNull(message = "El método de pago es requerido")
        Integer fkMetodoPago,

        @Min(value = 0, message = "El plazo no puede ser negativo")
        Integer plazoCredito,

        @NotEmpty(message = "Debe incluir al menos un producto")
        @Valid
        List<DetalleRequest> items
    ) {}

    public record DetalleRequest(
        @NotNull(message = "El producto es requerido")
        Integer fkProducto,

        @NotNull(message = "La cantidad es requerida")
        @DecimalMin(value = "0.0001", message = "La cantidad debe ser mayor a cero")
        BigDecimal cantidad,

        @NotNull(message = "El precio unitario es requerido")
        @DecimalMin(value = "0", message = "El precio no puede ser negativo")
        BigDecimal precioUnitario,

        BigDecimal descuentos,
        BigDecimal impuestos
    ) {}

    // ── Request: anular compra ─────────────────────────────────
    public record AnularCompraRequest(
        String motivo
    ) {}

    // ── Response: listado ─────────────────────────────────────
    public record CompraResumen(
        Integer    id,
        String     noDocumento,
        String     fkProveedor,
        String     nombreProveedor,
        String     fkRepresentante,
        String     nombreRepresentante,
        LocalDate  fechaOperacion,
        String     estado,
        String     estadoDescripcion,
        BigDecimal subtotal,
        BigDecimal totalDescuentos,
        BigDecimal totalImpuestos,
        BigDecimal total,
        Integer    plazoCredito,
        String     metodoPago,
        String     usuario,
        LocalDateTime creadoEn
    ) {}

    // ── Response: detalle completo ────────────────────────────
    public record CompraDetalle(
        Integer    id,
        String     noDocumento,
        String     fkProveedor,
        String     nombreProveedor,
        String     direccionProveedor,
        String     fkRepresentante,
        String     nombreRepresentante,
        LocalDate  fechaOperacion,
        LocalDateTime horaOperacion,
        String     estado,
        String     estadoDescripcion,
        BigDecimal subtotal,
        BigDecimal totalDescuentos,
        BigDecimal totalImpuestos,
        BigDecimal total,
        Integer    plazoCredito,
        Integer    fkMetodoPago,
        String     metodoPago,
        String     usuario,
        String     nombreEmpleado,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn,
        List<DetalleCompra> items
    ) {}

    public record DetalleCompra(
        Integer    id,
        Integer    fkCompra,
        Integer    fkProducto,
        String     nombreProducto,
        String     descripcionProducto,
        String     fkMedida,
        String     medida,
        BigDecimal cantidad,
        BigDecimal precioUnitario,
        BigDecimal descuentos,
        BigDecimal impuestos,
        BigDecimal subtotal
    ) {}

    // ── Response: búsqueda de productos para compras ──────────
    public record ProductoCompra(
        Integer    codigo,
        String     nombre,
        String     descripcion,
        BigDecimal stockActual,
        String     fkMedida,
        String     medida,
        String     estado
    ) {}

    // ── Response: búsqueda de proveedores para compras ────────
    public record ProveedorCompra(
        String  nit,
        Integer codigo,
        String  nombre,
        String  direccion,
        String  telefono,
        String  email
    ) {}

    // ── Response: método de pago ──────────────────────────────
    public record MetodoPagoDto(
        Integer codigo,
        String  nombre,
        String  descripcion,
        Integer diasCredito,
        Boolean activo
    ) {}

    // ── Response: representante ───────────────────────────────
    public record RepresentanteDto(
        String  nit,
        Integer codigo,
        String  nombre,
        String  telefono,
        String  email
    ) {}
}
