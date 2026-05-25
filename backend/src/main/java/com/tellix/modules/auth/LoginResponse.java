package com.tellix.modules.auth;

public record LoginResponse(
    String token,
    String refreshToken,
    int    codigoUsuario,
    String userName,
    String rol,
    int    nivel,
    String nombreEmpleado
) {}
