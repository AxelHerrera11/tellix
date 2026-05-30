package com.tellix.modules.cxc;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class CxcDto {

    public record CxcResumen(
        Integer id,
        Integer fkVenta,
        String fkCliente,
        String cliente,
        LocalDate fechaOperacion,
        LocalDate fechaLimite,
        String estado,
        String estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorCobrado,
        BigDecimal saldo,
        Boolean cobrada,
        Boolean vencida,
        Integer diasVencida,
        Integer fkMetodoPago,
        String metodoPago,
        String fkCuenta,
        LocalDateTime creadoEn
    ) {}

    public record CxcDetalle(
        Integer id,
        Integer fkVenta,
        String fkCliente,
        String cliente,
        String direccion,
        LocalDate fechaOperacion,
        LocalDate fechaLimite,
        String estado,
        String estadoDescripcion,
        BigDecimal valorTotal,
        BigDecimal valorCobrado,
        BigDecimal saldo,
        Boolean cobrada,
        Boolean vencida,
        Integer fkMetodoPago,
        String metodoPago,
        String fkCuenta,
        String banco,
        LocalDateTime creadoEn,
        List<MovimientoCobro> movimientos
    ) {}

    public record MovimientoCobro(
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

    public record CxcVencida(
        Integer id,
        Integer fkVenta,
        String fkCliente,
        String cliente,
        BigDecimal valorTotal,
        BigDecimal valorCobrado,
        BigDecimal saldo,
        LocalDate fechaLimite,
        Integer diasVencida
    ) {}

    public record RegistrarCobroRequest(
        @NotNull(message = "El metodo de cobro es requerido")
        Integer fkMetodoPago,
        @NotBlank(message = "La cuenta bancaria es requerida")
        String fkCuenta,
        @NotNull(message = "El monto es requerido")
        @DecimalMin(value = "0.01", message = "El monto debe ser mayor a cero")
        BigDecimal monto,
        String descripcion
    ) {}

    public record AnularCxcRequest(String motivo) {}

    public record CxcResumenFinanciero(
        BigDecimal totalPendiente,
        BigDecimal totalCobrado,
        BigDecimal saldoTotal,
        Integer cuentasPendientes,
        Integer cuentasVencidas,
        Integer cuentasCobradas
    ) {}

    public record MetodoCobroDto(Integer codigo, String descripcion) {}

    public record CuentaBancariaDto(
        String numero,
        Integer fkBanco,
        String banco,
        String titular,
        String descripcion
    ) {}
}
