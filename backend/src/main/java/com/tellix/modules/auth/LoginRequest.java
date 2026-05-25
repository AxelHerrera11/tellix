package com.tellix.modules.auth;

import jakarta.validation.constraints.NotBlank;

/**
 * Request de login.
 * El frontend envía la contraseña ya hasheada con SHA-256.
 */
public record LoginRequest(
    @NotBlank(message = "El usuario es requerido")
    String userName,

    @NotBlank(message = "La contraseña es requerida")
    String contrasenaHash
) {}
