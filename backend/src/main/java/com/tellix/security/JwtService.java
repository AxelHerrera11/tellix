package com.tellix.security;

import com.tellix.config.JwtProperties;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {

    private static final Logger log = LoggerFactory.getLogger(JwtService.class);

    private final JwtProperties props;
    private final SecretKey signingKey;

    public JwtService(JwtProperties props) {
        this.props = props;
        this.signingKey = Keys.hmacShaKeyFor(
            props.getSecret().getBytes(StandardCharsets.UTF_8)
        );
    }

    /**
     * Genera un access token con los datos del usuario autenticado.
     * Claims incluidos: sub, userName, rol, nivel, nombreEmpleado.
     */
    public String generarToken(TellixUserDetails user) {
        return buildToken(user, props.getExpirationMs());
    }

    public String generarRefreshToken(TellixUserDetails user) {
        return buildToken(user, props.getRefreshExpirationMs());
    }

    private String buildToken(TellixUserDetails user, long expirationMs) {
        return Jwts.builder()
            .subject(String.valueOf(user.getCodigoUsuario()))
            .claims(Map.of(
                "userName",      user.getUsername(),
                "rol",           user.getRol(),
                "nivel",         user.getNivel(),
                "nombreEmpleado", user.getNombreEmpleado()
            ))
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + expirationMs))
            .signWith(signingKey)
            .compact();
    }

    public boolean esValido(String token) {
        try {
            parsear(token);
            return true;
        } catch (JwtException | IllegalArgumentException ex) {
            log.warn("Token JWT inválido: {}", ex.getMessage());
            return false;
        }
    }

    public String extraerSubject(String token) {
        return parsear(token).getPayload().getSubject();
    }

    public String extraerRol(String token) {
        return (String) parsear(token).getPayload().get("rol");
    }

    public String extraerUserName(String token) {
        return (String) parsear(token).getPayload().get("userName");
    }

    public Integer extraerNivel(String token) {
        return (Integer) parsear(token).getPayload().get("nivel");
    }

    public String extraerNombreEmpleado(String token) {
        return (String) parsear(token).getPayload().get("nombreEmpleado");
    }

    private Jws<Claims> parsear(String token) {
        return Jwts.parser()
            .verifyWith(signingKey)
            .build()
            .parseSignedClaims(token);
    }
}
