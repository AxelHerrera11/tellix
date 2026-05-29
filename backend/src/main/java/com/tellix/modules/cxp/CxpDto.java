package com.tellix.modules.cxp;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CxpDto {

    public record RegistrarPagoRequest(
        @NotNull(message = "El monto es requerido")
        @DecimalMin(value = "0.01", message = "El monto debe ser mayor a cero")
        BigDecimal monto,

        String descripcion
    ) {}

    public record AnularCxpRequest(
        String motivo
    ) {}

    public record CxpResumen(
        Integer id,
        Integer fkCompra,
        String  noDocumento,
        String  proveedorNit,
        String  proveedor,
        String  estado,
        String  estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorPagado,
        BigDecimal saldo,
        LocalDate  fechaLimite,
        String  metodoPago,
        LocalDate  fechaCompra,
        LocalDateTime creadoEn
    ) {}

    public record CxpDetalle(
        Integer id,
        Integer fkCompra,
        String  noDocumento,
        String  proveedorNit,
        String  proveedor,
        String  proveedorDireccion,
        String  estado,
        String  estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorPagado,
        BigDecimal saldo,
        LocalDate  fechaLimite,
        Integer fkMetodoPago,
        String  metodoPago,
        String  fkCuenta,
        String  cuentaNumero,
        String  banco,
        LocalDate  fechaCompra,
        BigDecimal compraSubtotal,
        BigDecimal compraDescuentos,
        BigDecimal compraImpuestos,
        BigDecimal compraTotal,
        String  usuario,
        String  nombreEmpleado,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn,
        List<DetalleCompra> items
    ) {}

    public record DetalleCompra(
        Integer id,
        Integer fkCompra,
        Integer fkProducto,
        String  nombreProducto,
        BigDecimal cantidad,
        BigDecimal precioUnitario,
        BigDecimal descuentos,
        BigDecimal impuestos,
        BigDecimal subtotal
    ) {}

    public record CxpVencida(
        Integer id,
        Integer fkCompra,
        String  noDocumento,
        String  proveedor,
        BigDecimal valorTotal,
        BigDecimal valorPagado,
        BigDecimal saldo,
        LocalDate  fechaLimite,
        Integer diasVencida
    ) {}
}
