package com.tellix.modules.auth;

import com.tellix.security.JwtService;
import com.tellix.security.TellixUserDetails;
import com.tellix.shared.exception.TellixException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthRepository authRepository;
    private final JwtService jwtService;

    public AuthService(AuthRepository authRepository, JwtService jwtService) {
        this.authRepository = authRepository;
        this.jwtService     = jwtService;
    }

    public LoginResponse login(LoginRequest req) {
        TellixUserDetails user = authRepository
            .login(req.userName(), req.contrasenaHash())
            .orElseThrow(() -> new TellixException(
                "Usuario o contraseña incorrectos.", HttpStatus.UNAUTHORIZED
            ));

        String token        = jwtService.generarToken(user);
        String refreshToken = jwtService.generarRefreshToken(user);

        return new LoginResponse(
            token,
            refreshToken,
            user.getCodigoUsuario(),
            user.getUsername(),
            user.getRol(),
            user.getNivel(),
            user.getNombreEmpleado()
        );
    }

    public LoginResponse refresh(String refreshToken) {
        if (!jwtService.esValido(refreshToken)) {
            throw new TellixException("Token de renovación inválido o expirado.", HttpStatus.UNAUTHORIZED);
        }

        TellixUserDetails user = new TellixUserDetails(
            Integer.parseInt(jwtService.extraerSubject(refreshToken)),
            jwtService.extraerUserName(refreshToken),
            jwtService.extraerRol(refreshToken),
            jwtService.extraerNivel(refreshToken),
            jwtService.extraerNombreEmpleado(refreshToken)
        );

        return new LoginResponse(
            jwtService.generarToken(user),
            refreshToken,
            user.getCodigoUsuario(),
            user.getUsername(),
            user.getRol(),
            user.getNivel(),
            user.getNombreEmpleado()
        );
    }
}
