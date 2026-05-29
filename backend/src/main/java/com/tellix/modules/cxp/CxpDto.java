package com.tellix.modules.cxp;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CxpDto {

    public record CxpResumen(
        Integer id,
        Integer fkCompra,
        String noDocumento,
        String fkProveedor,
        String proveedor,
        LocalDate fechaOperacion,
        LocalDate fechaLimite,
        String estado,
        String estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorPagado,
        BigDecimal saldo,
        Boolean pagada,
        Boolean vencida,
        Integer diasVencida,
        Integer fkMetodoPago,
        String metodoPago,
        String fkCuenta,
        Integer fkBanco,
        LocalDateTime creadoEn
    ) {}

    public record CxpDetalle(
        Integer id,
        Integer fkCompra,
        String noDocumento,
        String fkProveedor,
        String proveedor,
        String direccionFiscal,
        LocalDate fechaOperacion,
        LocalDate fechaLimite,
        String estado,
        String estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorPagado,
        BigDecimal saldo,
        Boolean pagada,
        Boolean vencida,
        Integer fkMetodoPago,
        String metodoPago,
        String fkCuenta,
        Integer fkBanco,
        String banco,
        LocalDateTime creadoEn,
        List<MovimientoPago> movimientos
    ) {}

    public record MovimientoPago(
        Integer id,
        String fkCuenta,
        String tipoDocumento,
        String noDocumento,
        LocalDate fechaOperacion,
        BigDecimal monto,
        String descripcion,
        Integer fkUsuario,
        String usuario
    ) {}

    public record RegistrarPagoRequest(
        @NotNull(message = "El metodo de pago es requerido")
        Integer fkMetodoPago,

        @NotBlank(message = "La cuenta bancaria es requerida")
        String fkCuenta,

        @NotNull(message = "El monto es requerido")
        @DecimalMin(value = "0.01", message = "El monto debe ser mayor a cero")
        BigDecimal monto,

        String descripcion
    ) {}

    public record AnularCxpRequest(
        String motivo
    ) {}

    public record CxpResumenFinanciero(
        BigDecimal totalPendiente,
        BigDecimal totalPagado,
        BigDecimal saldoTotal,
        Integer cuentasPendientes,
        Integer cuentasVencidas,
        Integer cuentasPagadas
    ) {}

    public record MetodoPagoDto(
        Integer codigo,
        String descripcion
    ) {}

    public record CuentaBancariaDto(
        String numero,
        Integer fkBanco,
        String banco,
        String titular,
        String descripcion
    ) {}
}
