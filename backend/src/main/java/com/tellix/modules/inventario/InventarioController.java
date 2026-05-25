package com.tellix.modules.inventario;

import com.tellix.shared.dto.ApiResponse;
import com.tellix.shared.dto.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/inventario")
@Tag(name = "Inventario", description = "Gestión de inventario, stock y movimientos")
@SecurityRequirement(name = "bearerAuth")
public class InventarioController {

    private final InventarioService service;

    public InventarioController(InventarioService service) {
        this.service = service;
    }

    @GetMapping("/stock")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar stock", description = "Listado paginado de productos con nivel de stock.")
    public ResponseEntity<ApiResponse<PagedResponse<InventarioDto.StockProducto>>> listarStock(
        @RequestParam(required = false) String busqueda,
        @RequestParam(required = false) Integer categoria,
        @RequestParam(defaultValue = "A") String estado,
        @RequestParam(defaultValue = "false") boolean critico,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listarStock(busqueda, categoria, estado, critico, pagina, tamano)
        ));
    }

    @GetMapping("/stock/critico")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Stock crítico", description = "Productos por debajo del stock mínimo.")
    public ResponseEntity<ApiResponse<List<InventarioDto.StockCritico>>> stockCritico() {
        return ResponseEntity.ok(ApiResponse.ok(service.stockCritico()));
    }

    @GetMapping("/movimientos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Listar movimientos", description = "Historial paginado con filtros.")
    public ResponseEntity<ApiResponse<PagedResponse<InventarioDto.MovimientoDto>>> listarMovimientos(
        @RequestParam(required = false) Integer producto,
        @RequestParam(required = false) String operacion,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listarMovimientos(producto, operacion, desde, hasta, pagina, tamano)
        ));
    }

    @PostMapping("/ajustes")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Ajustar stock", description = "Ajuste manual de stock (cantidad positiva o negativa).")
    public ResponseEntity<ApiResponse<Void>> ajustar(
        @Valid @RequestBody InventarioDto.AjustarStockRequest req
    ) {
        service.ajustar(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Stock ajustado correctamente.", null));
    }
}
