package com.tellix.modules.inventario;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class InventarioDto {

    // ── Request: ajuste manual ───────────────────────────────
    public record AjustarStockRequest(
        @NotNull(message = "El producto es requerido")
        Integer fkProducto,

        @NotNull(message = "La cantidad es requerida")
        BigDecimal cantidad,

        @NotBlank(message = "El motivo es requerido")
        String motivo
    ) {}

    // ── Response: stock de un producto ───────────────────────
    public record StockProducto(
        Integer    codigo,
        String     nombre,
        String     categoria,
        String     marca,
        String     medidaCodigo,
        String     medida,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        String     estado,
        String     nivelStock
    ) {}

    // ── Response: movimiento ─────────────────────────────────
    public record MovimientoDto(
        Integer    id,
        Integer    fkProducto,
        String     producto,
        String     medidaCodigo,
        String     medida,
        BigDecimal cantidad,
        String     tipoMovimiento,
        String     operacion,
        String     motivo,
        String     tipoDocumento,
        String     noDocumento,
        Integer    fkUsuario,
        String     usuario,
        LocalDateTime     fechaOperacion
    ) {}

    // ── Response: producto crítico ───────────────────────────
    public record StockCritico(
        Integer    codigo,
        String     nombre,
        String     categoria,
        String     marca,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        BigDecimal faltante
    ) {}
}
