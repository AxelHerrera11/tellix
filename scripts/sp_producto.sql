-- ============================================================
--  TELLIX — Stored Procedures módulo PRODUCTOS
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_productos ──────────────────────────────────────
-- Listado paginado con filtros opcionales
CREATE OR ALTER PROCEDURE sp_listar_productos
    @p_busqueda  NVARCHAR(200) = NULL,
    @p_categoria INT           = NULL,
    @p_marca     INT           = NULL,
    @p_estado    CHAR(1)       = NULL,
    @p_pagina    INT           = 1,
    @p_tamano    INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    SELECT COUNT(*) AS total
    FROM producto p
    WHERE (@p_busqueda  IS NULL OR p.nombre        LIKE '%' + @p_busqueda + '%')
      AND (@p_categoria IS NULL OR p.fk_categoria   = @p_categoria)
      AND (@p_marca     IS NULL OR p.fk_marca       = @p_marca)
      AND (@p_estado    IS NULL OR p.estado         = @p_estado);

    SELECT
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        p.stock_minimo,
        p.estado,
        c.codigo          AS categoria_codigo,
        c.descripcion     AS categoria,
        m.codigo          AS marca_codigo,
        m.nombre          AS marca,
        md.codigo         AS medida_codigo,
        md.descripcion    AS medida,
        p.cantidad_medida,
        p.creado_en,
        p.actualizado_en
    FROM producto p
    LEFT JOIN categoria c  ON c.codigo = p.fk_categoria
    LEFT JOIN marca     m  ON m.codigo = p.fk_marca
    LEFT JOIN medida    md ON md.codigo = p.fk_medida
    WHERE (@p_busqueda  IS NULL OR p.nombre        LIKE '%' + @p_busqueda + '%')
      AND (@p_categoria IS NULL OR p.fk_categoria   = @p_categoria)
      AND (@p_marca     IS NULL OR p.fk_marca       = @p_marca)
      AND (@p_estado    IS NULL OR p.estado         = @p_estado)
    ORDER BY p.codigo DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_producto ──────────────────────────────────────
-- Producto individual con precios, impuestos y descuentos
CREATE OR ALTER PROCEDURE sp_obtener_producto
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cabecera del producto
    SELECT
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        p.stock_minimo,
        p.estado,
        c.codigo          AS categoria_codigo,
        c.descripcion     AS categoria,
        m.codigo          AS marca_codigo,
        m.nombre          AS marca,
        md.codigo         AS medida_codigo,
        md.descripcion    AS medida,
        p.cantidad_medida,
        p.creado_en,
        p.actualizado_en
    FROM producto p
    LEFT JOIN categoria c  ON c.codigo = p.fk_categoria
    LEFT JOIN marca     m  ON m.codigo = p.fk_marca
    LEFT JOIN medida    md ON md.codigo = p.fk_medida
    WHERE p.codigo = @p_id;

    -- Precios vigentes e históricos
    SELECT
        pr.id,
        pr.fk_producto,
        pr.precio_venta,
        pr.aplicacion,
        pr.inicio_vigencia,
        pr.fin_vigencia,
        pr.estado,
        pr.creado_por,
        pr.creado_en
    FROM precio pr
    WHERE pr.fk_producto = @p_id
    ORDER BY pr.inicio_vigencia DESC;

    -- Impuestos asignados
    SELECT
        ai.id,
        ai.fk_impuesto,
        i.descripcion     AS impuesto,
        i.tipo_calculo,
        i.valor           AS valor_base,
        ai.valor_override,
        ai.aplicaciones,
        ai.fecha_inicio,
        ai.fecha_fin,
        ai.estado
    FROM asignacion_impuesto ai
    JOIN impuesto i ON i.codigo = ai.fk_impuesto
    WHERE ai.fk_producto = @p_id
    ORDER BY ai.fecha_inicio DESC;

    -- Descuentos asignados
    SELECT
        ad.id,
        ad.fk_descuento,
        d.descripcion     AS descuento,
        d.tipo_calculo,
        d.valor           AS valor_base,
        ad.valor_override,
        ad.aplicaciones,
        ad.fecha_inicio,
        ad.fecha_fin,
        ad.estado
    FROM asignacion_descuento ad
    JOIN descuento d ON d.codigo = ad.fk_descuento
    WHERE ad.fk_producto = @p_id
    ORDER BY ad.fecha_inicio DESC;
END;
GO

-- ── sp_crear_producto ────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_crear_producto
    @p_nombre         NVARCHAR(200),
    @p_descripcion    NVARCHAR(300) = NULL,
    @p_stock_minimo   DECIMAL(18,4) = 0,
    @p_fk_categoria   INT           = NULL,
    @p_fk_marca       INT           = NULL,
    @p_fk_medida      NVARCHAR(50)  = NULL,
    @p_cantidad_medida DECIMAL(18,4) = NULL,
    @p_precio_venta   DECIMAL(18,4) = NULL,
    @p_aplicacion     NVARCHAR(50)  = NULL,
    @p_usuario        INT,
    @p_id             INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
        VALUES (@p_nombre, @p_descripcion, ISNULL(@p_stock_minimo, 0), 0, 'A', @p_fk_categoria, @p_fk_marca, @p_fk_medida, @p_cantidad_medida);

        SET @p_id = SCOPE_IDENTITY();

        -- Si se proporcionó un precio inicial, crearlo
        IF @p_precio_venta IS NOT NULL
        BEGIN
            INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado, creado_por)
            VALUES (@p_id, COALESCE(@p_aplicacion, 'MINORISTA'), @p_precio_venta, CAST(SYSDATETIME() AS DATE), 'A', @p_usuario);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_actualizar_producto ───────────────────────────────────
CREATE OR ALTER PROCEDURE sp_actualizar_producto
    @p_id             INT,
    @p_nombre         NVARCHAR(200),
    @p_descripcion    NVARCHAR(300) = NULL,
    @p_stock_minimo   DECIMAL(18,4) = 0,
    @p_fk_categoria   INT           = NULL,
    @p_fk_marca       INT           = NULL,
    @p_fk_medida      NVARCHAR(50)  = NULL,
    @p_cantidad_medida DECIMAL(18,4) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo = @p_id)
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        RETURN;
    END

    UPDATE producto SET
        nombre          = @p_nombre,
        descripcion     = @p_descripcion,
        stock_minimo    = @p_stock_minimo,
        fk_categoria    = @p_fk_categoria,
        fk_marca        = @p_fk_marca,
        fk_medida       = @p_fk_medida,
        cantidad_medida = @p_cantidad_medida,
        actualizado_en  = SYSDATETIME()
    WHERE codigo = @p_id;
END;
GO

-- ── sp_cambiar_estado_producto ───────────────────────────────
CREATE OR ALTER PROCEDURE sp_cambiar_estado_producto
    @p_id     INT,
    @p_estado CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_estado NOT IN ('A','I')
    BEGIN
        RAISERROR('Estado inválido. Use A (Activo) o I (Inactivo).', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo = @p_id)
    BEGIN
        RAISERROR('Producto no encontrado.', 16, 1);
        RETURN;
    END

    UPDATE producto SET estado = @p_estado, actualizado_en = SYSDATETIME()
    WHERE codigo = @p_id;
END;
GO

-- ── sp_asignar_precio_producto ───────────────────────────────
CREATE OR ALTER PROCEDURE sp_asignar_precio_producto
    @p_producto      INT,
    @p_precio_venta  DECIMAL(18,4),
    @p_aplicacion    NVARCHAR(50) = 'MINORISTA',
    @p_inicio_vigencia DATE = NULL,
    @p_usuario       INT,
    @p_id            INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_inicio_vigencia IS NULL SET @p_inicio_vigencia = CAST(SYSDATETIME() AS DATE);

    INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado, creado_por)
    VALUES (@p_producto, @p_aplicacion, @p_precio_venta, @p_inicio_vigencia, 'A', @p_usuario);

    SET @p_id = SCOPE_IDENTITY();
END;
GO

-- ── sp_listar_categorias ─────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_categorias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, descripcion, activo FROM categoria WHERE activo = 1 ORDER BY descripcion;
END;
GO

-- ── sp_listar_marcas ─────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_marcas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, nombre, descripcion, activo FROM marca WHERE activo = 1 ORDER BY nombre;
END;
GO

-- ── sp_listar_medidas ────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_medidas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, descripcion FROM medida WHERE activo = 1 ORDER BY descripcion;
END;
GO

-- ── sp_listar_impuestos ──────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_impuestos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, descripcion, tipo_calculo, valor, activo FROM impuesto WHERE activo = 1 ORDER BY descripcion;
END;
GO

-- ── sp_listar_descuentos ─────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_descuentos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, descripcion, tipo_calculo, valor, activo FROM descuento WHERE activo = 1 ORDER BY descripcion;
END;
GO