package com.tellix.modules.precio;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class PrecioDto {

    public record PrecioResumen(
        Integer id,
        Integer fkProducto,
        String producto,
        String descripcionProducto,
        String aplicacion,
        BigDecimal precioVenta,
        LocalDate inicioVigencia,
        LocalDate finVigencia,
        String estado,
        String estadoDescripcion,
        Boolean vigente,
        Integer creadoPor,
        String usuario,
        LocalDateTime creadoEn
    ) {}

    public record PrecioDetalle(
        Integer id,
        Integer fkProducto,
        String producto,
        String descripcionProducto,
        String categoria,
        String marca,
        String medida,
        String aplicacion,
        BigDecimal precioVenta,
        LocalDate inicioVigencia,
        LocalDate finVigencia,
        String estado,
        String estadoDescripcion,
        Boolean vigente,
        Integer creadoPor,
        String usuario,
        LocalDateTime creadoEn
    ) {}

    public record CrearPrecioRequest(
        @NotNull Integer fkProducto,
        @NotBlank String aplicacion,
        @NotNull @DecimalMin(value = "0.01") BigDecimal precioVenta,
        LocalDate inicioVigencia,
        Boolean cerrarVigentes
    ) {}

    public record ActualizarPrecioRequest(
        @NotBlank String aplicacion,
        @NotNull @DecimalMin(value = "0.01") BigDecimal precioVenta,
        @NotNull LocalDate inicioVigencia,
        LocalDate finVigencia
    ) {}

    public record CambiarEstadoPrecioRequest(
        @NotBlank @Pattern(regexp = "A|I") String estado
    ) {}

    public record ProductoPrecioDto(
        Integer codigo,
        String nombre,
        String descripcion,
        BigDecimal stockActual,
        String medida
    ) {}
}
