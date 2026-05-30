package com.tellix.modules.admin;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import com.tellix.shared.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@Tag(name = "Admin", description = "Administración de usuarios, roles y accesos")
@SecurityRequirement(name = "bearerAuth")
public class AdminController {

    private final AdminService service;

    public AdminController(AdminService service) {
        this.service = service;
    }

    @GetMapping("/usuarios")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    @Operation(summary = "Listar usuarios", description = "Devuelve usuarios con empleado y rol asignado.")
    public ResponseEntity<ApiResponse<List<AdminDto.UsuarioResumen>>> listarUsuarios() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarUsuarios()));
    }

    @GetMapping("/roles")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    @Operation(summary = "Listar roles", description = "Devuelve los roles disponibles del sistema.")
    public ResponseEntity<ApiResponse<List<AdminDto.RolResumen>>> listarRoles() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarRoles()));
    }
@PostMapping("/usuarios")
@PreAuthorize("hasRole('ADMINISTRADOR')")
@Operation(summary = "Crear usuario", description = "Crea un empleado y usuario asociado.")
public ResponseEntity<ApiResponse<Integer>> crearUsuario(
    @Valid @RequestBody AdminDto.CrearUsuarioRequest req
) {
    int id = service.crearUsuario(req);

    return ResponseEntity.status(HttpStatus.CREATED)
        .body(ApiResponse.ok("Usuario creado correctamente.", id));
}

    @GetMapping("/auditoria")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    @Operation(summary = "Listar auditoría", description = "Muestra actividad reciente del sistema.")
    public ResponseEntity<ApiResponse<List<AdminDto.AuditoriaResumen>>> listarAuditoria() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarAuditoria()));
    }

}
