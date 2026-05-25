package com.tellix.modules.auth;

import com.tellix.shared.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login, logout y renovación de token")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    @Operation(summary = "Iniciar sesión", description = "Devuelve JWT + refresh token si las credenciales son válidas.")
    public ResponseEntity<ApiResponse<LoginResponse>> login(
        @Valid @RequestBody LoginRequest req
    ) {
        LoginResponse resp = authService.login(req);
        return ResponseEntity.ok(ApiResponse.ok("Bienvenido, " + resp.nombreEmpleado(), resp));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Renovar token", description = "Usa el refresh token para obtener un nuevo access token.")
    public ResponseEntity<ApiResponse<LoginResponse>> refresh(
        @RequestHeader("X-Refresh-Token") String refreshToken
    ) {
        LoginResponse resp = authService.refresh(refreshToken);
        return ResponseEntity.ok(ApiResponse.ok(resp));
    }

    @PostMapping("/logout")
    @Operation(summary = "Cerrar sesión", description = "El cliente debe eliminar el token localmente.")
    public ResponseEntity<ApiResponse<Void>> logout() {
        return ResponseEntity.ok(ApiResponse.ok("Sesión cerrada correctamente.", null));
    }
}
