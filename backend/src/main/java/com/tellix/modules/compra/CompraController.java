package com.tellix.modules.compra;

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
@RequestMapping("/api/compras")
@Tag(name = "Compras", description = "Gestión de compras y órdenes de compra")
@SecurityRequirement(name = "bearerAuth")
public class CompraController {

    private final CompraService service;

    public CompraController(CompraService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','CONTADOR')")
    @Operation(summary = "Listar compras", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<CompraDto.CompraResumen>>> listar(
        @RequestParam(required = false) String proveedor,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(proveedor, estado, desde, hasta, pagina, tamano)
        ));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','CONTADOR')")
    @Operation(summary = "Obtener compra", description = "Devuelve cabecera y detalle de una compra.")
    public ResponseEntity<ApiResponse<CompraDto.CompraDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Registrar compra", description = "Crea la compra en estado Pendiente.")
    public ResponseEntity<ApiResponse<Integer>> registrar(
        @Valid @RequestBody CompraDto.CrearCompraRequest req
    ) {
        int id = service.registrar(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Compra registrada correctamente.", id));
    }

    @PatchMapping("/{id}/aprobar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Aprobar compra", description = "Aprueba la compra y actualiza el stock.")
    public ResponseEntity<ApiResponse<Void>> aprobar(@PathVariable int id) {
        service.aprobar(id);
        return ResponseEntity.ok(ApiResponse.ok("Compra aprobada correctamente.", null));
    }

    @PatchMapping("/{id}/completar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Completar compra", description = "Marca la compra como completada.")
    public ResponseEntity<ApiResponse<Void>> completar(@PathVariable int id) {
        service.completar(id);
        return ResponseEntity.ok(ApiResponse.ok("Compra completada correctamente.", null));
    }

    @PatchMapping("/{id}/anular")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Anular compra", description = "Anula la compra y restaura el stock si estaba aprobada.")
    public ResponseEntity<ApiResponse<Void>> anular(
        @PathVariable int id,
        @RequestBody(required = false) CompraDto.AnularCompraRequest req
    ) {
        service.anular(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Compra anulada correctamente.", null));
    }

    // ── Endpoints auxiliares ───────────────────────────────────

    @GetMapping("/productos/buscar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Buscar productos", description = "Búsqueda de productos para el formulario de compras.")
    public ResponseEntity<ApiResponse<List<CompraDto.ProductoCompra>>> buscarProductos(
        @RequestParam(required = false) String q
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.buscarProductos(q)));
    }

    @GetMapping("/proveedores/buscar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Buscar proveedores", description = "Búsqueda rápida de proveedores.")
    public ResponseEntity<ApiResponse<List<CompraDto.ProveedorCompra>>> buscarProveedores(
        @RequestParam(required = false) String q
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.buscarProveedores(q)));
    }

    @GetMapping("/metodos-pago")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','CONTADOR')")
    @Operation(summary = "Listar métodos de pago", description = "Devuelve los métodos de liquidación activos.")
    public ResponseEntity<ApiResponse<List<CompraDto.MetodoPagoDto>>> listarMetodosPago() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarMetodosPago()));
    }

    @GetMapping("/representantes/buscar")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Buscar representantes", description = "Búsqueda de representantes de proveedores.")
    public ResponseEntity<ApiResponse<List<CompraDto.RepresentanteDto>>> buscarRepresentantes(
        @RequestParam(required = false) String q
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.buscarRepresentantes(q)));
    }
}
