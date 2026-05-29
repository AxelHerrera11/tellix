-- ============================================================
--  TELLIX — Stored Procedures módulo AUTENTICACIÓN
--  Ejecutar en TellixDB después del script de esquema
-- ============================================================

USE TellixDB;
GO

-- ── sp_login ──────────────────────────────────────────────────
-- Valida credenciales y devuelve los datos del usuario
CREATE OR ALTER PROCEDURE sp_login
    @p_username NVARCHAR(50),
    @p_hash     NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_username IS NULL OR @p_hash IS NULL
    BEGIN
        RAISERROR('Usuario y contraseña son requeridos.', 16, 1);
        RETURN;
    END

    SELECT
        codigo,
        user_name,
        rol_nombre,
        rol_nivel,
        nombre_empleado
    FROM usuario
    WHERE user_name = @p_username
      AND contrasena_hash = @p_hash
      AND activo = 1;

    -- Actualizar último acceso si encontró al usuario
    IF @@ROWCOUNT > 0
    BEGIN
        UPDATE usuario SET
            ultimo_acceso = SYSDATETIME()
        WHERE user_name = @p_username;
    END
END;
GO

PRINT 'sp_auth.sql ejecutado correctamente.';
GO
