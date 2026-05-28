-- ============================================================
--  TELLIX — Stored Procedures módulo CLIENTES
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_clientes ────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_clientes
    @p_busqueda  NVARCHAR(200) = NULL,
    @p_estado    CHAR(1)       = NULL,
    @p_tipo      INT           = NULL,
    @p_pagina    INT           = 1,
    @p_tamano    INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;
    DECLARE @busqueda NVARCHAR(210) = CASE WHEN @p_busqueda IS NOT NULL THEN '%' + @p_busqueda + '%' ELSE NULL END;

    SELECT COUNT(*) AS total
    FROM cliente c
    WHERE (@p_busqueda IS NULL OR CONCAT(c.nombre_1, ' ', c.nombre_2, ' ', c.nombre_3, ' ', c.apellido_1, ' ', c.apellido_2, ' ', c.apellido_casada) LIKE @busqueda OR c.nit LIKE @busqueda)
      AND (@p_estado   IS NULL OR c.estado = @p_estado)
      AND (@p_tipo     IS NULL OR c.fk_tipo_cliente = @p_tipo);

    SELECT
        c.codigo,
        c.nit,
        TRIM(CONCAT(c.nombre_1, ' ', c.nombre_2, ' ', c.nombre_3, ' ', c.apellido_1, ' ', c.apellido_2, ' ', c.apellido_casada)) AS nombre,
        c.nombre_1,
        c.nombre_2,
        c.nombre_3,
        c.apellido_1,
        c.apellido_2,
        c.apellido_casada,
        c.direccion,
        tc.codigo AS tipo_codigo,
        tc.descripcion AS tipo_cliente,
        c.limite_credito,
        c.estado,
        CASE c.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE c.estado END AS estado_descripcion,
        (SELECT TOP 1 info_contacto FROM contacto_cliente WHERE fk_cliente = c.nit AND fk_tipo = 1 AND principal = 1) AS telefono,
        (SELECT TOP 1 info_contacto FROM contacto_cliente WHERE fk_cliente = c.nit AND fk_tipo = 2 AND principal = 1) AS email,
        c.creado_en,
        c.actualizado_en
    FROM cliente c
    LEFT JOIN tipo_cliente tc ON tc.codigo = c.fk_tipo_cliente
    WHERE (@p_busqueda IS NULL OR CONCAT(c.nombre_1, ' ', c.nombre_2, ' ', c.nombre_3, ' ', c.apellido_1, ' ', c.apellido_2, ' ', c.apellido_casada) LIKE @busqueda OR c.nit LIKE @busqueda)
      AND (@p_estado   IS NULL OR c.estado = @p_estado)
      AND (@p_tipo     IS NULL OR c.fk_tipo_cliente = @p_tipo)
    ORDER BY c.nombre_1 ASC, c.apellido_1 ASC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_cliente ────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_obtener_cliente
    @p_codigo INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.codigo,
        c.nit,
        TRIM(CONCAT(c.nombre_1, ' ', c.nombre_2, ' ', c.nombre_3, ' ', c.apellido_1, ' ', c.apellido_2, ' ', c.apellido_casada)) AS nombre,
        c.nombre_1,
        c.nombre_2,
        c.nombre_3,
        c.apellido_1,
        c.apellido_2,
        c.apellido_casada,
        c.direccion,
        tc.codigo AS tipo_codigo,
        tc.descripcion AS tipo_cliente,
        c.limite_credito,
        c.estado,
        CASE c.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE c.estado END AS estado_descripcion,
        (SELECT TOP 1 info_contacto FROM contacto_cliente WHERE fk_cliente = c.nit AND fk_tipo = 1 AND principal = 1) AS telefono,
        (SELECT TOP 1 info_contacto FROM contacto_cliente WHERE fk_cliente = c.nit AND fk_tipo = 2 AND principal = 1) AS email,
        c.creado_en,
        c.actualizado_en
    FROM cliente c
    LEFT JOIN tipo_cliente tc ON tc.codigo = c.fk_tipo_cliente
    WHERE c.codigo = @p_codigo;
END;
GO

-- ── sp_crear_cliente ──────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_crear_cliente
    @p_nit             NVARCHAR(50),
    @p_nombre_1        NVARCHAR(100),
    @p_nombre_2        NVARCHAR(100) = NULL,
    @p_nombre_3        NVARCHAR(100) = NULL,
    @p_apellido_1      NVARCHAR(100),
    @p_apellido_2      NVARCHAR(100) = NULL,
    @p_apellido_casada NVARCHAR(100) = NULL,
    @p_direccion       NVARCHAR(300) = NULL,
    @p_fk_tipo_cliente INT           = 1,
    @p_limite_credito  DECIMAL(18,2) = 0,
    @p_telefono        NVARCHAR(50)  = NULL,
    @p_email           NVARCHAR(100) = NULL,
    @p_codigo          INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM cliente WHERE nit = @p_nit)
    BEGIN
        RAISERROR('Ya existe un cliente con ese NIT.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO cliente (nit, nombre_1, nombre_2, nombre_3, apellido_1, apellido_2, apellido_casada, direccion, fk_tipo_cliente, limite_credito, estado)
        VALUES (@p_nit, @p_nombre_1, @p_nombre_2, @p_nombre_3, @p_apellido_1, @p_apellido_2, @p_apellido_casada, @p_direccion, @p_fk_tipo_cliente, @p_limite_credito, 'A');

        SET @p_codigo = SCOPE_IDENTITY();

        IF @p_telefono IS NOT NULL AND @p_telefono <> ''
        BEGIN
            INSERT INTO contacto_cliente (fk_cliente, fk_tipo, info_contacto, principal)
            VALUES (@p_nit, 1, @p_telefono, 1);
        END;

        IF @p_email IS NOT NULL AND @p_email <> ''
        BEGIN
            INSERT INTO contacto_cliente (fk_cliente, fk_tipo, info_contacto, principal)
            VALUES (@p_nit, 2, @p_email, 1);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_actualizar_cliente ─────────────────────────────────
CREATE OR ALTER PROCEDURE sp_actualizar_cliente
    @p_codigo          INT,
    @p_nombre_1        NVARCHAR(100),
    @p_nombre_2        NVARCHAR(100) = NULL,
    @p_nombre_3        NVARCHAR(100) = NULL,
    @p_apellido_1      NVARCHAR(100),
    @p_apellido_2      NVARCHAR(100) = NULL,
    @p_apellido_casada NVARCHAR(100) = NULL,
    @p_direccion       NVARCHAR(300) = NULL,
    @p_fk_tipo_cliente INT           = 1,
    @p_limite_credito  DECIMAL(18,2) = 0,
    @p_telefono        NVARCHAR(50)  = NULL,
    @p_email           NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE codigo = @p_codigo)
    BEGIN
        RAISERROR('Cliente no encontrado.', 16, 1);
        RETURN;
    END;

    DECLARE @current_nit NVARCHAR(50) = (SELECT nit FROM cliente WHERE codigo = @p_codigo);

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE cliente SET
            nombre_1        = @p_nombre_1,
            nombre_2        = @p_nombre_2,
            nombre_3        = @p_nombre_3,
            apellido_1      = @p_apellido_1,
            apellido_2      = @p_apellido_2,
            apellido_casada = @p_apellido_casada,
            direccion       = @p_direccion,
            fk_tipo_cliente = @p_fk_tipo_cliente,
            limite_credito  = @p_limite_credito,
            actualizado_en  = SYSDATETIME()
        WHERE codigo = @p_codigo;

        IF @p_telefono IS NOT NULL AND @p_telefono <> ''
        BEGIN
            IF EXISTS (SELECT 1 FROM contacto_cliente WHERE fk_cliente = @current_nit AND fk_tipo = 1 AND principal = 1)
                UPDATE contacto_cliente SET info_contacto = @p_telefono WHERE fk_cliente = @current_nit AND fk_tipo = 1 AND principal = 1
            ELSE
                INSERT INTO contacto_cliente (fk_cliente, fk_tipo, info_contacto, principal) VALUES (@current_nit, 1, @p_telefono, 1);
        END;

        IF @p_email IS NOT NULL AND @p_email <> ''
        BEGIN
            IF EXISTS (SELECT 1 FROM contacto_cliente WHERE fk_cliente = @current_nit AND fk_tipo = 2 AND principal = 1)
                UPDATE contacto_cliente SET info_contacto = @p_email WHERE fk_cliente = @current_nit AND fk_tipo = 2 AND principal = 1
            ELSE
                INSERT INTO contacto_cliente (fk_cliente, fk_tipo, info_contacto, principal) VALUES (@current_nit, 2, @p_email, 1);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_cambiar_estado_cliente ─────────────────────────────
CREATE OR ALTER PROCEDURE sp_cambiar_estado_cliente
    @p_codigo INT,
    @p_estado CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_estado NOT IN ('A', 'I')
    BEGIN
        RAISERROR('Estado inválido. Use A (Activo) o I (Inactivo).', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE codigo = @p_codigo)
    BEGIN
        RAISERROR('Cliente no encontrado.', 16, 1);
        RETURN;
    END

    UPDATE cliente SET estado = @p_estado, actualizado_en = SYSDATETIME()
    WHERE codigo = @p_codigo;
END;
GO

PRINT 'sp_cliente.sql ejecutado correctamente.';
GO
