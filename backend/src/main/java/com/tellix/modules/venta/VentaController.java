package com.tellix.modules.venta;

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
@RequestMapping("/api/ventas")
@Tag(name = "Ventas", description = "Gestión de ventas y POS")
@SecurityRequirement(name = "bearerAuth")
public class VentaController {

    private final VentaService service;

    public VentaController(VentaService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar ventas", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<VentaDto.VentaResumen>>> listar(
        @RequestParam(required = false) String cliente,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(cliente, estado, desde, hasta, pagina, tamano)
        ));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Obtener venta", description = "Devuelve cabecera y detalle de una venta.")
    public ResponseEntity<ApiResponse<VentaDto.VentaDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Registrar venta", description = "Crea la venta, descuenta stock y genera CXC si es a crédito.")
    public ResponseEntity<ApiResponse<Integer>> registrar(
        @Valid @RequestBody VentaDto.CrearVentaRequest req
    ) {
        int id = service.registrar(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Venta registrada correctamente.", id));
    }

    @PatchMapping("/{id}/anular")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Anular venta", description = "Anula la venta y restaura el stock.")
    public ResponseEntity<ApiResponse<Void>> anular(
        @PathVariable int id,
        @RequestBody(required = false) VentaDto.AnularVentaRequest req
    ) {
        service.anular(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Venta anulada correctamente.", null));
    }

    // ── Endpoints auxiliares para el POS ──────────────────────

    @GetMapping("/productos/buscar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Buscar productos", description = "Búsqueda de productos con precio vigente para el POS.")
    public ResponseEntity<ApiResponse<List<VentaDto.ProductoVenta>>> buscarProductos(
        @RequestParam(required = false) String q,
        @RequestParam(required = false) String aplicacion
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.buscarProductos(q, aplicacion)));
    }

    @GetMapping("/clientes/buscar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Buscar clientes", description = "Búsqueda rápida de clientes para el POS.")
    public ResponseEntity<ApiResponse<List<VentaDto.ClienteVenta>>> buscarClientes(
        @RequestParam(required = false) String q
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.buscarClientes(q)));
    }
}
