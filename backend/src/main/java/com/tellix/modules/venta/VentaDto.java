package com.tellix.modules.venta;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class VentaDto {

    // ── Request: crear venta ──────────────────────────────────
    public record CrearVentaRequest(
        @NotBlank(message = "El cliente es requerido")
        String fkCliente,

        @NotNull(message = "El método de pago es requerido")
        Integer fkMetodoPago,

        @NotNull(message = "El plazo es requerido")
        @Min(value = 0, message = "El plazo no puede ser negativo")
        Integer plazoCredito,

        String tipoPlazo,

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

    // ── Request: anular venta ─────────────────────────────────
    public record AnularVentaRequest(
        String motivo
    ) {}

    // ── Response: listado ─────────────────────────────────────
    public record VentaResumen(
        Integer id,
        String  fkCliente,
        String  nombreCliente,
        LocalDate fechaOperacion,
        String  estado,
        String  estadoDescripcion,
        BigDecimal subtotal,
        BigDecimal totalDescuentos,
        BigDecimal totalImpuestos,
        BigDecimal total,
        Integer plazoCredito,
        String  metodoPago,
        String  usuario,
        LocalDateTime creadoEn
    ) {}

    // ── Response: detalle completo ────────────────────────────
    public record VentaDetalle(
        Integer id,
        String  fkCliente,
        String  nombreCliente,
        String  nit,
        LocalDate  fechaOperacion,
        LocalDateTime horaOperacion,
        String  estado,
        String  estadoDescripcion,
        BigDecimal subtotal,
        BigDecimal totalDescuentos,
        BigDecimal totalImpuestos,
        BigDecimal total,
        Integer plazoCredito,
        String  tipoPlazo,
        Integer fkMetodoPago,
        String  metodoPago,
        String  usuario,
        String  nombreEmpleado,
        LocalDateTime creadoEn,
        List<DetalleVenta> items
    ) {}

    public record DetalleVenta(
        Integer id,
        Integer fkVenta,
        Integer fkProducto,
        String  nombreProducto,
        String  fkMedida,
        String  medida,
        BigDecimal cantidad,
        BigDecimal precioUnitario,
        BigDecimal descuentos,
        BigDecimal impuestos,
        BigDecimal subtotal
    ) {}

    // ── Response: búsqueda de productos para POS ──────────────
    public record ProductoVenta(
        Integer    codigo,
        String     nombre,
        String     descripcion,
        BigDecimal stockActual,
        String     fkMedida,
        String     medida,
        BigDecimal precioVenta,
        String     aplicacion
    ) {}

    // ── Response: búsqueda de clientes para POS ───────────────
    public record ClienteVenta(
        String  nit,
        Integer codigo,
        String  nombre,
        BigDecimal limiteCredito,
        String  direccion,
        String  tipoCliente
    ) {}
}
