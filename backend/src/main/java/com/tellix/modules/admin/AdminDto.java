package com.tellix.modules.admin;

import java.time.LocalDateTime;

public class AdminDto {

    public record UsuarioResumen(
        Integer codigo,
        String userName,
        Integer empleadoCodigo,
        String nombres,
        String apellidos,
        Integer rolCodigo,
        String rol,
        String estado,
        LocalDateTime ultimoAcceso,
        LocalDateTime creadoEn
    ) {}

    public record RolResumen(
        Integer codigo,
        String nombre,
        String descripcion,
        Integer nivel,
        Boolean activo
    ) {}
public record CrearUsuarioRequest(
    String documentoIdentificacion,
    String nombre1,
    String nombre2,
    String apellido1,
    String apellido2,
    String userName,
    String password,
    Integer fkRol,
    String estado
) {}

    public record AuditoriaResumen(
        String modulo,
        String accion,
        String descripcion,
        String usuario,
        LocalDateTime fecha
    ) {}

}
