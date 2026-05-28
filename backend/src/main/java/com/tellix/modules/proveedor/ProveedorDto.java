package com.tellix.modules.proveedor;

import jakarta.validation.constraints.NotBlank;

import java.time.LocalDateTime;

public class ProveedorDto {

    public record ProveedorResumen(
        String nit,
        String nombre,
        String direccionFiscal,
        String estado,
        String estadoDescripcion,
        String representante,
        String telefono,
        String email,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn
    ) {}

    public record ProveedorDetalle(
        String nit,
        String nombre,
        String direccionFiscal,
        String estado,
        String estadoDescripcion,
        String representante,
        String telefono,
        String email,
        LocalDateTime creadoEn,
        LocalDateTime actualizadoEn
    ) {}

    public record CrearProveedorRequest(
        @NotBlank(message = "El NIT es requerido")
        String nit,

        @NotBlank(message = "El nombre es requerido")
        String nombre,

        String direccion
    ) {}

    public record ActualizarProveedorRequest(
        @NotBlank(message = "El nombre es requerido")
        String nombre,

        String direccion
    ) {}

    public record CambiarEstadoRequest(
        @NotBlank(message = "El estado es requerido")
        String estado
    ) {}
}
