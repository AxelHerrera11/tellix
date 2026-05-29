-- ============================================================
--  TELLIX — Stored Procedures módulo PROVEEDORES
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_proveedores ─────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_proveedores
    @p_busqueda  NVARCHAR(200) = NULL,
    @p_estado    CHAR(1)       = NULL,
    @p_pagina    INT           = 1,
    @p_tamano    INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;
    DECLARE @busqueda NVARCHAR(210) = CASE WHEN @p_busqueda IS NOT NULL THEN '%' + @p_busqueda + '%' ELSE NULL END;

    SELECT COUNT(*) AS total
    FROM proveedor p
    WHERE (@p_busqueda IS NULL OR p.nombre LIKE @busqueda OR p.nit LIKE @busqueda)
      AND (@p_estado   IS NULL OR p.estado = @p_estado);

    SELECT
        p.nit,
        p.nombre,
        p.direccion_fiscal,
        p.estado,
        CASE p.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE p.estado END AS estado_descripcion,
        (SELECT TOP 1 r.nombre_1 + ' ' + r.apellido_1 FROM representante r WHERE r.fk_proveedor = p.nit AND r.activo = 1) AS representante,
        (SELECT TOP 1 cr.info_contacto FROM representante r JOIN contacto_representante cr ON cr.fk_representante = r.nit WHERE r.fk_proveedor = p.nit AND r.activo = 1 AND cr.fk_tipo = 1 AND cr.principal = 1) AS telefono,
        (SELECT TOP 1 cr.info_contacto FROM representante r JOIN contacto_representante cr ON cr.fk_representante = r.nit WHERE r.fk_proveedor = p.nit AND r.activo = 1 AND cr.fk_tipo = 2 AND cr.principal = 1) AS email,
        p.creado_en,
        p.actualizado_en
    FROM proveedor p
    WHERE (@p_busqueda IS NULL OR p.nombre LIKE @busqueda OR p.nit LIKE @busqueda)
      AND (@p_estado   IS NULL OR p.estado = @p_estado)
    ORDER BY p.nombre ASC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_proveedor ──────────────────────────────────
CREATE OR ALTER PROCEDURE sp_obtener_proveedor
    @p_nit NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.nit,
        p.nombre,
        p.direccion_fiscal,
        p.estado,
        CASE p.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE p.estado END AS estado_descripcion,
        (SELECT TOP 1 r.nombre_1 + ' ' + r.apellido_1 FROM representante r WHERE r.fk_proveedor = p.nit AND r.activo = 1) AS representante,
        (SELECT TOP 1 cr.info_contacto FROM representante r JOIN contacto_representante cr ON cr.fk_representante = r.nit WHERE r.fk_proveedor = p.nit AND r.activo = 1 AND cr.fk_tipo = 1 AND cr.principal = 1) AS telefono,
        (SELECT TOP 1 cr.info_contacto FROM representante r JOIN contacto_representante cr ON cr.fk_representante = r.nit WHERE r.fk_proveedor = p.nit AND r.activo = 1 AND cr.fk_tipo = 2 AND cr.principal = 1) AS email,
        p.creado_en,
        p.actualizado_en
    FROM proveedor p
    WHERE p.nit = @p_nit;
END;
GO

-- ── sp_crear_proveedor ────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_crear_proveedor
    @p_nit            NVARCHAR(50),
    @p_nombre         NVARCHAR(200),
    @p_direccion      NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM proveedor WHERE nit = @p_nit)
    BEGIN
        RAISERROR('Ya existe un proveedor con ese NIT.', 16, 1);
        RETURN;
    END

    INSERT INTO proveedor (nit, nombre, direccion_fiscal, estado)
    VALUES (@p_nit, @p_nombre, @p_direccion, 'A');
END;
GO

-- ── sp_actualizar_proveedor ───────────────────────────────
CREATE OR ALTER PROCEDURE sp_actualizar_proveedor
    @p_nit            NVARCHAR(50),
    @p_nombre         NVARCHAR(200),
    @p_direccion      NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE nit = @p_nit)
    BEGIN
        RAISERROR('Proveedor no encontrado.', 16, 1);
        RETURN;
    END

    UPDATE proveedor SET
        nombre          = @p_nombre,
        direccion_fiscal = @p_direccion,
        actualizado_en  = SYSDATETIME()
    WHERE nit = @p_nit;
END;
GO

-- ── sp_cambiar_estado_proveedor ───────────────────────────
CREATE OR ALTER PROCEDURE sp_cambiar_estado_proveedor
    @p_nit    NVARCHAR(50),
    @p_estado CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_estado NOT IN ('A', 'I')
    BEGIN
        RAISERROR('Estado inválido. Use A (Activo) o I (Inactivo).', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM proveedor WHERE nit = @p_nit)
    BEGIN
        RAISERROR('Proveedor no encontrado.', 16, 1);
        RETURN;
    END

    UPDATE proveedor SET estado = @p_estado, actualizado_en = SYSDATETIME()
    WHERE nit = @p_nit;
END;
GO

PRINT 'sp_proveedor.sql ejecutado correctamente.';
GO
