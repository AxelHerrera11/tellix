package com.tellix.modules.admin;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

@Repository
public class AdminRepository {

    private final JdbcTemplate jdbc;

    public AdminRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<AdminDto.UsuarioResumen> listarUsuarios() {
        String sql = """
            SELECT 
                u.codigo,
                u.user_name,
                e.codigo AS empleado_codigo,
                CONCAT(e.nombre_1, ' ', ISNULL(e.nombre_2, '')) AS nombres,
                CONCAT(e.apellido_1, ' ', ISNULL(e.apellido_2, '')) AS apellidos,
                r.codigo AS rol_codigo,
                r.nombre AS rol,
                u.estado,
                u.ultimo_acceso,
                u.creado_en
            FROM usuario u
            INNER JOIN empleado e ON u.fk_empleado = e.codigo
            INNER JOIN rol r ON u.fk_rol = r.codigo
            ORDER BY u.codigo
            """;

        return jdbc.query(sql, (rs, rowNum) -> new AdminDto.UsuarioResumen(
            rs.getInt("codigo"),
            rs.getString("user_name"),
            rs.getInt("empleado_codigo"),
            rs.getString("nombres"),
            rs.getString("apellidos"),
            rs.getInt("rol_codigo"),
            rs.getString("rol"),
            rs.getString("estado"),
            rs.getTimestamp("ultimo_acceso") != null ? rs.getTimestamp("ultimo_acceso").toLocalDateTime() : null,
            rs.getTimestamp("creado_en") != null ? rs.getTimestamp("creado_en").toLocalDateTime() : null
        ));
    }

    public List<AdminDto.RolResumen> listarRoles() {
        String sql = """
            SELECT codigo, nombre, descripcion, nivel, activo
            FROM rol
            ORDER BY nivel
            """;

        return jdbc.query(sql, (rs, rowNum) -> new AdminDto.RolResumen(
            rs.getInt("codigo"),
            rs.getString("nombre"),
            rs.getString("descripcion"),
            rs.getInt("nivel"),
            rs.getBoolean("activo")
        ));
    }

    public int crearUsuario(AdminDto.CrearUsuarioRequest req) {
        String passwordHash = sha256(req.password());

        Integer empleadoId = jdbc.queryForObject("""
            SET NOCOUNT ON;

            INSERT INTO empleado (
                documento_identificacion,
                nombre_1,
                nombre_2,
                apellido_1,
                apellido_2,
                estado
            )
            VALUES (?, ?, ?, ?, ?, 'A');

            SELECT CAST(SCOPE_IDENTITY() AS INT);
            """,
            Integer.class,
            req.documentoIdentificacion(),
            req.nombre1(),
            req.nombre2(),
            req.apellido1(),
            req.apellido2()
        );

        return jdbc.queryForObject("""
            SET NOCOUNT ON;

            INSERT INTO usuario (
                fk_empleado,
                user_name,
                contrasena_hash,
                fk_rol,
                estado
            )
            VALUES (?, ?, ?, ?, ?);

            SELECT CAST(SCOPE_IDENTITY() AS INT);
            """,
            Integer.class,
            empleadoId,
            req.userName(),
            passwordHash,
            req.fkRol(),
            req.estado() == null ? "A" : req.estado()
        );
    }

    private String sha256(String texto) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(texto.getBytes(StandardCharsets.UTF_8));

            StringBuilder hex = new StringBuilder();

            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }

            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("No se pudo generar SHA-256", e);
        }
    }

    public List<AdminDto.AuditoriaResumen> listarAuditoria() {
        String sql = """
            SELECT TOP 100
                modulo,
                accion,
                descripcion,
                usuario,
                fecha
            FROM (
                SELECT
                    'Usuarios' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se creó el usuario ', user_name) AS descripcion,
                    user_name AS usuario,
                    creado_en AS fecha
                FROM usuario
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Usuarios' AS modulo,
                    'ACTUALIZACIÓN' AS accion,
                    CONCAT('Se actualizó el usuario ', user_name) AS descripcion,
                    user_name AS usuario,
                    actualizado_en AS fecha
                FROM usuario
                WHERE actualizado_en IS NOT NULL AND actualizado_en <> creado_en

                UNION ALL

                SELECT
                    'Usuarios' AS modulo,
                    'INICIO DE SESIÓN' AS accion,
                    CONCAT('El usuario ', user_name, ' inició sesión') AS descripcion,
                    user_name AS usuario,
                    ultimo_acceso AS fecha
                FROM usuario
                WHERE ultimo_acceso IS NOT NULL

                UNION ALL

                SELECT
                    'Empleados' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se creó el empleado ', nombre_1, ' ', apellido_1) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM empleado
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Productos' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se creó el producto ', nombre) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM producto
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Productos' AS modulo,
                    'ACTUALIZACIÓN' AS accion,
                    CONCAT('Se actualizó el producto ', nombre) AS descripcion,
                    NULL AS usuario,
                    actualizado_en AS fecha
                FROM producto
                WHERE actualizado_en IS NOT NULL AND actualizado_en <> creado_en

                UNION ALL

                SELECT
                    'Clientes' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se creó el cliente ', codigo) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM cliente
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Proveedores' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se creó el proveedor ', nombre) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM proveedor
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Ventas' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se registró la venta ', id) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM venta
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Compras' AS modulo,
                    'CREACIÓN' AS accion,
                    CONCAT('Se registró la compra ', id) AS descripcion,
                    NULL AS usuario,
                    creado_en AS fecha
                FROM compra
                WHERE creado_en IS NOT NULL

                UNION ALL

                SELECT
                    'Inventario' AS modulo,
                    operacion AS accion,
                    CONCAT('Movimiento de inventario: ', motivo, ' - Documento: ', ISNULL(no_documento, 'N/A')) AS descripcion,
                    u.user_name AS usuario,
                    mi.fecha_operacion AS fecha
                FROM movimiento_inventario mi
                INNER JOIN usuario u ON mi.fk_usuario = u.codigo

                UNION ALL

                SELECT
                    'Cuentas' AS modulo,
                    'MOVIMIENTO' AS accion,
                    CONCAT('Movimiento de cuenta ', fk_cuenta, ' por monto ', monto) AS descripcion,
                    u.user_name AS usuario,
                    mc.fecha_operacion AS fecha
                FROM movimiento_cuenta mc
                INNER JOIN usuario u ON mc.fk_usuario = u.codigo
            ) auditoria
            ORDER BY fecha DESC
            """;

        return jdbc.query(sql, (rs, rowNum) -> new AdminDto.AuditoriaResumen(
            rs.getString("modulo"),
            rs.getString("accion"),
            rs.getString("descripcion"),
            rs.getString("usuario"),
            rs.getTimestamp("fecha") != null ? rs.getTimestamp("fecha").toLocalDateTime() : null
        ));
    }

}
