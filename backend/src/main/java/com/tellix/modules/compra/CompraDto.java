package com.tellix.modules.compra;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CompraDto {

    public record CrearCompraRequest(
        @NotBlank(message = "El número de documento es requerido")
        String noDocumento,

        @NotBlank(message = "El proveedor es requerido")
        String fkProveedor,

        String fkRepresentante,

        @NotNull(message = "El método de pago es requerido")
        Integer fkMetodoPago,

        @NotNull(message = "El plazo es requerido")
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

    public record AnularCompraRequest(
        String motivo
    ) {}

    public record CompraResumen(
        Integer id,
        String  noDocumento,
        String  fkProveedor,
        String  proveedor,
        String  fkRepresentante,
        String  representante,
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

    public record CompraDetalle(
        Integer id,
        String  noDocumento,
        String  fkProveedor,
        String  proveedor,
        String  direccionFiscal,
        String  fkRepresentante,
        String  representante,
        LocalDate  fechaOperacion,
        LocalDateTime horaOperacion,
        String  estado,
        String  estadoDescripcion,
        BigDecimal subtotal,
        BigDecimal totalDescuentos,
        BigDecimal totalImpuestos,
        BigDecimal total,
        Integer plazoCredito,
        Integer fkMetodoPago,
        String  metodoPago,
        String  usuario,
        String  nombreEmpleado,
        LocalDateTime creadoEn,
        List<DetalleCompra> items
    ) {}

    public record DetalleCompra(
        Integer id,
        Integer fkCompra,
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

    public record ProductoCompra(
        Integer    codigo,
        String     nombre,
        String     descripcion,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        String     fkMedida,
        String     medida
    ) {}

    public record ProveedorCompra(
        String nit,
        String nombre,
        String direccionFiscal
    ) {}

    public record RepresentanteCompra(
        String nit,
        Integer codigo,
        String  nombreCompleto,
        String  nombre1,
        String  apellido1,
        String  telefono,
        String  email
    ) {}
}
