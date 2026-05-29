package com.tellix.modules.cliente;

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
@RequestMapping("/api/clientes")
@Tag(name = "Clientes", description = "Gestión de clientes")
@SecurityRequirement(name = "bearerAuth")
public class ClienteController {

    private final ClienteService service;

    public ClienteController(ClienteService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar clientes", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<ClienteDto.ClienteResumen>>> listar(
        @RequestParam(required = false) String busqueda,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) Integer tipo,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(busqueda, estado, tipo, pagina, tamano)
        ));
    }

    @GetMapping("/{codigo}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Obtener cliente", description = "Devuelve detalle de un cliente por su código.")
    public ResponseEntity<ApiResponse<ClienteDto.ClienteDetalle>> obtener(@PathVariable int codigo) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(codigo)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Crear cliente", description = "Registra un nuevo cliente.")
    public ResponseEntity<ApiResponse<Integer>> crear(
        @Valid @RequestBody ClienteDto.CrearClienteRequest req
    ) {
        int id = service.crear(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Cliente creado correctamente.", id));
    }

    @PutMapping("/{codigo}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR')")
    @Operation(summary = "Actualizar cliente", description = "Actualiza los datos de un cliente existente.")
    public ResponseEntity<ApiResponse<Void>> actualizar(
        @PathVariable int codigo,
        @Valid @RequestBody ClienteDto.ActualizarClienteRequest req
    ) {
        service.actualizar(codigo, req);
        return ResponseEntity.ok(ApiResponse.ok("Cliente actualizado correctamente.", null));
    }

    @PatchMapping("/{codigo}/estado")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Cambiar estado", description = "Activa o inactiva un cliente.")
    public ResponseEntity<ApiResponse<Void>> cambiarEstado(
        @PathVariable int codigo,
        @Valid @RequestBody ClienteDto.CambiarEstadoRequest req
    ) {
        service.cambiarEstado(codigo, req.estado());
        return ResponseEntity.ok(ApiResponse.ok("Estado actualizado correctamente.", null));
    }
}
