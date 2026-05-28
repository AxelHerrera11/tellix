package com.tellix.modules.proveedor;

import com.tellix.shared.dto.ApiResponse;
import com.tellix.shared.dto.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/proveedores")
@Tag(name = "Proveedores", description = "Gestión de proveedores")
@SecurityRequirement(name = "bearerAuth")
public class ProveedorController {

    private final ProveedorService service;

    public ProveedorController(ProveedorService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','CONTADOR')")
    @Operation(summary = "Listar proveedores", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<ProveedorDto.ProveedorResumen>>> listar(
        @RequestParam(required = false) String busqueda,
        @RequestParam(required = false) String estado,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(busqueda, estado, pagina, tamano)
        ));
    }

    @GetMapping("/{nit}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO','CONTADOR')")
    @Operation(summary = "Obtener proveedor", description = "Devuelve detalle de un proveedor por su NIT.")
    public ResponseEntity<ApiResponse<ProveedorDto.ProveedorDetalle>> obtener(@PathVariable String nit) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(nit)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Crear proveedor", description = "Registra un nuevo proveedor.")
    public ResponseEntity<ApiResponse<Void>> crear(
        @Valid @RequestBody ProveedorDto.CrearProveedorRequest req
    ) {
        service.crear(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Proveedor creado correctamente.", null));
    }

    @PutMapping("/{nit}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','BODEGUERO')")
    @Operation(summary = "Actualizar proveedor", description = "Actualiza los datos de un proveedor existente.")
    public ResponseEntity<ApiResponse<Void>> actualizar(
        @PathVariable String nit,
        @Valid @RequestBody ProveedorDto.ActualizarProveedorRequest req
    ) {
        service.actualizar(nit, req);
        return ResponseEntity.ok(ApiResponse.ok("Proveedor actualizado correctamente.", null));
    }

    @PatchMapping("/{nit}/estado")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Cambiar estado", description = "Activa o inactiva un proveedor.")
    public ResponseEntity<ApiResponse<Void>> cambiarEstado(
        @PathVariable String nit,
        @Valid @RequestBody ProveedorDto.CambiarEstadoRequest req
    ) {
        service.cambiarEstado(nit, req.estado());
        return ResponseEntity.ok(ApiResponse.ok("Estado actualizado correctamente.", null));
    }
}
