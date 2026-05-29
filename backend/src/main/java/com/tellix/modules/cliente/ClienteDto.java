package com.tellix.modules.cliente;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ClienteDto {

    public record ClienteResumen(
        Integer codigo,
        String nit,
        String nombre,
        String nombre1,
        String nombre2,
        String nombre3,
        String apellido1,
        String apellido2,
        String apellidoCasada,
        String direccion,
        Integer tipoCodigo,
        String tipoCliente,
        BigDecimal limiteCredito,
        String estado,
        String estadoDescripcion,
        String telefono,
        String email,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn
    ) {}

    public record ClienteDetalle(
        Integer codigo,
        String nit,
        String nombre,
        String nombre1,
        String nombre2,
        String nombre3,
        String apellido1,
        String apellido2,
        String apellidoCasada,
        String direccion,
        Integer tipoCodigo,
        String tipoCliente,
        BigDecimal limiteCredito,
        String estado,
        String estadoDescripcion,
        String telefono,
        String email,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn
    ) {}

    public record CrearClienteRequest(
        @NotBlank(message = "El NIT es requerido")
        String nit,

        @NotBlank(message = "El primer nombre es requerido")
        String nombre1,

        String nombre2,
        String nombre3,

        @NotBlank(message = "El primer apellido es requerido")
        String apellido1,

        String apellido2,
        String apellidoCasada,
        String direccion,

        @NotNull(message = "El tipo de cliente es requerido")
        Integer fkTipoCliente,

        @NotNull(message = "El límite de crédito es requerido")
        @DecimalMin(value = "0", message = "El límite de crédito no puede ser negativo")
        BigDecimal limiteCredito,

        String telefono,
        String email
    ) {}

    public record ActualizarClienteRequest(
        @NotBlank(message = "El primer nombre es requerido")
        String nombre1,

        String nombre2,
        String nombre3,

        @NotBlank(message = "El primer apellido es requerido")
        String apellido1,

        String apellido2,
        String apellidoCasada,
        String direccion,

        @NotNull(message = "El tipo de cliente es requerido")
        Integer fkTipoCliente,

        @NotNull(message = "El límite de crédito es requerido")
        @DecimalMin(value = "0", message = "El límite de crédito no puede ser negativo")
        BigDecimal limiteCredito,

        String telefono,
        String email
    ) {}

    public record CambiarEstadoRequest(
        @NotBlank(message = "El estado es requerido")
        String estado
    ) {}
}
