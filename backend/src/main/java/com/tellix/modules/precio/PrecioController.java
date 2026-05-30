package com.tellix.modules.precio;

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
@RequestMapping("/api/precios")
@Tag(name = "Precios", description = "Gestion historica de precios")
@SecurityRequirement(name = "bearerAuth")
public class PrecioController {

    private final PrecioService service;

    public PrecioController(PrecioService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar precios")
    public ResponseEntity<ApiResponse<PagedResponse<PrecioDto.PrecioResumen>>> listar(
        @RequestParam(required = false) Integer producto,
        @RequestParam(required = false) String busqueda,
        @RequestParam(required = false) String aplicacion,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) Boolean vigentes,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha,
        @RequestParam(defaultValue = "1") int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.listar(producto, busqueda, aplicacion, estado, vigentes, fecha, pagina, tamano)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Crear precio")
    public ResponseEntity<ApiResponse<Integer>> crear(@Valid @RequestBody PrecioDto.CrearPrecioRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Precio creado correctamente.", service.crear(req)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Actualizar precio")
    public ResponseEntity<ApiResponse<Void>> actualizar(@PathVariable int id, @Valid @RequestBody PrecioDto.ActualizarPrecioRequest req) {
        service.actualizar(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Precio actualizado correctamente.", null));
    }

    @PatchMapping("/{id}/estado")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Cambiar estado de precio")
    public ResponseEntity<ApiResponse<Void>> cambiarEstado(@PathVariable int id, @Valid @RequestBody PrecioDto.CambiarEstadoPrecioRequest req) {
        service.cambiarEstado(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Estado actualizado correctamente.", null));
    }

    @GetMapping("/vigente")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Obtener precio vigente")
    public ResponseEntity<ApiResponse<PrecioDto.PrecioResumen>> vigente(
        @RequestParam int producto,
        @RequestParam(required = false) String aplicacion,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtenerVigente(producto, aplicacion, fecha)));
    }

    @GetMapping("/productos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar productos para precios")
    public ResponseEntity<ApiResponse<List<PrecioDto.ProductoPrecioDto>>> listarProductos() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarProductos()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Obtener precio")
    public ResponseEntity<ApiResponse<PrecioDto.PrecioDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }
}
