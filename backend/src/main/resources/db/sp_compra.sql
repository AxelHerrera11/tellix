-- ============================================================
--  TELLIX — Stored Procedures módulo COMPRAS
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_compras ──────────────────────────────────────────
-- Listado paginado de compras con filtros opcionales
CREATE OR ALTER PROCEDURE sp_listar_compras
    @p_proveedor   NVARCHAR(50)  = NULL,
    @p_estado      CHAR(1)       = NULL,
    @p_fecha_desde DATE          = NULL,
    @p_fecha_hasta DATE          = NULL,
    @p_pagina      INT           = 1,
    @p_tamano      INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    SELECT COUNT(*) AS total
    FROM compra c
    WHERE (@p_proveedor   IS NULL OR c.fk_proveedor    = @p_proveedor)
      AND (@p_estado      IS NULL OR c.estado          = @p_estado)
      AND (@p_fecha_desde IS NULL OR c.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR c.fecha_operacion <  DATEADD(DAY, 1, @p_fecha_hasta));

    SELECT
        c.id,
        c.no_documento,
        c.fk_proveedor,
        pv.nombre           AS nombre_proveedor,
        c.fk_representante,
        r.nombre            AS nombre_representante,
        c.fecha_operacion,
        c.estado,
        CASE c.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Aprobada'
            WHEN 'C' THEN 'Completada'
            WHEN 'X' THEN 'Cancelada'
            ELSE c.estado
        END AS estado_descripcion,
        c.subtotal,
        c.total_descuentos,
        c.total_impuestos,
        c.total,
        c.plazo_credito,
        ml.nombre           AS metodo_pago,
        u.user_name         AS usuario,
        c.creado_en
    FROM compra c
    JOIN proveedor pv ON pv.nit = c.fk_proveedor
    LEFT JOIN representante r  ON r.nit = c.fk_representante
    JOIN metodo_liquidacion ml ON ml.codigo = c.fk_metodo_pago
    JOIN usuario u             ON u.codigo = c.fk_usuario
    WHERE (@p_proveedor   IS NULL OR c.fk_proveedor    = @p_proveedor)
      AND (@p_estado      IS NULL OR c.estado          = @p_estado)
      AND (@p_fecha_desde IS NULL OR c.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR c.fecha_operacion <  DATEADD(DAY, 1, @p_fecha_hasta))
    ORDER BY c.id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_compra ──────────────────────────────────────────
-- Devuelve cabecera + detalle de una compra
CREATE OR ALTER PROCEDURE sp_obtener_compra
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id,
        c.no_documento,
        c.fk_proveedor,
        pv.nombre           AS nombre_proveedor,
        pv.direccion        AS direccion_proveedor,
        c.fk_representante,
        r.nombre            AS nombre_representante,
        c.fecha_operacion,
        c.hora_operacion,
        c.estado,
        CASE c.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Aprobada'
            WHEN 'C' THEN 'Completada'
            WHEN 'X' THEN 'Cancelada'
            ELSE c.estado
        END AS estado_descripcion,
        c.subtotal,
        c.total_descuentos,
        c.total_impuestos,
        c.total,
        c.plazo_credito,
        c.fk_metodo_pago,
        ml.nombre           AS metodo_pago,
        u.user_name         AS usuario,
        u.nombre            AS nombre_empleado,
        c.creado_en,
        c.actualizado_en
    FROM compra c
    JOIN proveedor pv ON pv.nit = c.fk_proveedor
    LEFT JOIN representante r  ON r.nit = c.fk_representante
    JOIN metodo_liquidacion ml ON ml.codigo = c.fk_metodo_pago
    JOIN usuario u             ON u.codigo = c.fk_usuario
    WHERE c.id = @p_id;

    SELECT
        dc.id,
        dc.fk_compra,
        dc.fk_producto,
        p.nombre            AS nombre_producto,
        p.descripcion       AS descripcion_producto,
        md.codigo           AS fk_medida,
        md.descripcion      AS medida,
        dc.cantidad,
        dc.precio_unitario,
        dc.descuentos,
        dc.impuestos,
        dc.subtotal
    FROM detalle_compra dc
    JOIN producto p  ON p.codigo = dc.fk_producto
    LEFT JOIN medida md ON md.codigo = p.fk_medida
    WHERE dc.fk_compra = @p_id
    ORDER BY dc.id;
END;
GO

-- ── sp_registrar_compra ────────────────────────────────────────
-- Crea cabecera + detalle en una transacción. Retorna el id.
CREATE OR ALTER PROCEDURE sp_registrar_compra
    @p_no_documento   NVARCHAR(50),
    @p_fk_proveedor   NVARCHAR(50),
    @p_fk_representante NVARCHAR(50) = NULL,
    @p_fk_metodo_pago INT,
    @p_plazo_credito  INT = 0,
    @p_usuario        INT,
    @p_items          NVARCHAR(MAX),
    @p_id             INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @subtotal         DECIMAL(18,2) = 0;
        DECLARE @total_descuentos DECIMAL(18,2) = 0;
        DECLARE @total_impuestos  DECIMAL(18,2) = 0;
        DECLARE @total            DECIMAL(18,2) = 0;

        -- Tabla temporal para procesar los items JSON
        DECLARE @items_tmp TABLE (
            fk_producto     INT,
            cantidad        DECIMAL(18,4),
            precio_unitario DECIMAL(18,4),
            descuentos      DECIMAL(18,2),
            impuestos       DECIMAL(18,2)
        );

        INSERT INTO @items_tmp (fk_producto, cantidad, precio_unitario, descuentos, impuestos)
        SELECT
            fk_producto,
            cantidad,
            precio_unitario,
            ISNULL(descuentos, 0),
            ISNULL(impuestos, 0)
        FROM OPENJSON(@p_items)
        WITH (
            fk_producto     INT             '$.fkProducto',
            cantidad        DECIMAL(18,4)   '$.cantidad',
            precio_unitario DECIMAL(18,4)   '$.precioUnitario',
            descuentos      DECIMAL(18,2)   '$.descuentos',
            impuestos       DECIMAL(18,2)   '$.impuestos'
        );

        -- Calcular totales
        SELECT
            @subtotal         = SUM(cantidad * precio_unitario),
            @total_descuentos = SUM(ISNULL(descuentos, 0)),
            @total_impuestos  = SUM(ISNULL(impuestos, 0))
        FROM @items_tmp;

        SET @total = ISNULL(@subtotal, 0) - ISNULL(@total_descuentos, 0) + ISNULL(@total_impuestos, 0);

        -- Insertar cabecera
        INSERT INTO compra (
            no_documento, fk_proveedor, fk_representante,
            fecha_operacion, hora_operacion,
            fk_usuario, fk_metodo_pago, plazo_credito,
            estado, subtotal, total_descuentos, total_impuestos, total
        ) VALUES (
            @p_no_documento, @p_fk_proveedor, @p_fk_representante,
            CAST(SYSDATETIME() AS DATE), SYSDATETIME(),
            @p_usuario, @p_fk_metodo_pago, @p_plazo_credito,
            'P', ISNULL(@subtotal, 0), ISNULL(@total_descuentos, 0),
            ISNULL(@total_impuestos, 0), ISNULL(@total, 0)
        );

        SET @p_id = SCOPE_IDENTITY();

        -- Insertar detalle
        INSERT INTO detalle_compra (fk_compra, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
        SELECT
            @p_id,
            i.fk_producto,
            i.cantidad,
            i.precio_unitario,
            i.descuentos,
            i.impuestos,
            (i.cantidad * i.precio_unitario) - i.descuentos + i.impuestos
        FROM @items_tmp i;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_aprobar_compra ─────────────────────────────────────────
-- Cambia estado P->A y actualiza stock (+)
CREATE OR ALTER PROCEDURE sp_aprobar_compra
    @p_id      INT,
    @p_usuario INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @estado_actual CHAR(1);
        SELECT @estado_actual = estado FROM compra WHERE id = @p_id;

        IF @estado_actual IS NULL
        BEGIN
            RAISERROR('Compra no encontrada.', 16, 1);
            RETURN;
        END

        IF @estado_actual != 'P'
        BEGIN
            RAISERROR('Solo se pueden aprobar compras en estado Pendiente.', 16, 1);
            RETURN;
        END

        -- Actualizar estado
        UPDATE compra SET
            estado = 'A',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        -- Actualizar stock de cada producto (incrementar)
        UPDATE p SET
            p.stock_actual = p.stock_actual + dc.cantidad
        FROM producto p
        INNER JOIN detalle_compra dc ON dc.fk_producto = p.codigo
        WHERE dc.fk_compra = @p_id;

        -- Registrar movimientos de inventario (entrada por compra)
        INSERT INTO movimiento_inventario (fk_producto, cantidad, operacion, motivo, tipo_documento, no_documento, fk_usuario, fecha_operacion)
        SELECT
            dc.fk_producto,
            dc.cantidad,
            'COMPRA',
            'Aprobación de compra #' + CAST(@p_id AS NVARCHAR),
            'COMPRA',
            c.no_documento,
            @p_usuario,
            SYSDATETIME()
        FROM detalle_compra dc
        INNER JOIN compra c ON c.id = dc.fk_compra
        WHERE dc.fk_compra = @p_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_completar_compra ────────────────────────────────────────
-- Cambia estado A->C (solo tracking, stock ya actualizado)
CREATE OR ALTER PROCEDURE sp_completar_compra
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @estado_actual CHAR(1);
    SELECT @estado_actual = estado FROM compra WHERE id = @p_id;

    IF @estado_actual IS NULL
    BEGIN
        RAISERROR('Compra no encontrada.', 16, 1);
        RETURN;
    END

    IF @estado_actual != 'A'
    BEGIN
        RAISERROR('Solo se pueden completar compras en estado Aprobada.', 16, 1);
        RETURN;
    END

    UPDATE compra SET
        estado = 'C',
        actualizado_en = SYSDATETIME()
    WHERE id = @p_id;
END;
GO

-- ── sp_anular_compra ───────────────────────────────────────────
-- Anula la compra, restaura stock si estaba Aprobada o Completada
CREATE OR ALTER PROCEDURE sp_anular_compra
    @p_id      INT,
    @p_usuario INT,
    @p_motivo  NVARCHAR(500) = 'Anulación manual'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @estado_actual CHAR(1);
        DECLARE @no_documento  NVARCHAR(50);

        SELECT @estado_actual = estado, @no_documento = no_documento
        FROM compra WHERE id = @p_id;

        IF @estado_actual IS NULL
        BEGIN
            RAISERROR('Compra no encontrada.', 16, 1);
            RETURN;
        END

        IF @estado_actual = 'X'
        BEGIN
            RAISERROR('La compra ya está cancelada.', 16, 1);
            RETURN;
        END

        -- Si estaba Aprobada o Completada, restaurar stock
        IF @estado_actual IN ('A', 'C')
        BEGIN
            UPDATE p SET
                p.stock_actual = p.stock_actual - dc.cantidad
            FROM producto p
            INNER JOIN detalle_compra dc ON dc.fk_producto = p.codigo
            WHERE dc.fk_compra = @p_id;

            -- Registrar movimiento de salida por anulación
            INSERT INTO movimiento_inventario (fk_producto, cantidad, operacion, motivo, tipo_documento, no_documento, fk_usuario, fecha_operacion)
            SELECT
                dc.fk_producto,
                -dc.cantidad,
                'COMPRA',
                @p_motivo + ' (anulación compra #' + CAST(@p_id AS NVARCHAR) + ')',
                'COMPRA',
                @no_documento,
                @p_usuario,
                SYSDATETIME()
            FROM detalle_compra dc
            WHERE dc.fk_compra = @p_id;
        END

        UPDATE compra SET
            estado = 'X',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_buscar_productos_compra ─────────────────────────────────
-- Búsqueda de productos para el formulario de compras
CREATE OR ALTER PROCEDURE sp_buscar_productos_compra
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        md.codigo   AS fk_medida,
        md.descripcion AS medida,
        p.estado
    FROM producto p
    LEFT JOIN medida md ON md.codigo = p.fk_medida
    WHERE p.estado = 'A'
      AND (@p_busqueda IS NULL OR p.nombre LIKE '%' + @p_busqueda + '%'
           OR CAST(p.codigo AS NVARCHAR) LIKE '%' + @p_busqueda + '%')
    ORDER BY p.nombre;
END;
GO

-- ── sp_buscar_proveedores_compra ───────────────────────────────
-- Búsqueda de proveedores para el formulario de compras
CREATE OR ALTER PROCEDURE sp_buscar_proveedores_compra
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        nit,
        codigo,
        nombre,
        direccion,
        telefono,
        email
    FROM proveedor
    WHERE activo = 1
      AND (@p_busqueda IS NULL OR nombre LIKE '%' + @p_busqueda + '%'
           OR nit LIKE '%' + @p_busqueda + '%')
    ORDER BY nombre;
END;
GO

-- ── sp_listar_metodos_pago ─────────────────────────────────────
-- Lista métodos de liquidación activos
CREATE OR ALTER PROCEDURE sp_listar_metodos_pago
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, nombre, descripcion, dias_credito, activo
    FROM metodo_liquidacion
    WHERE activo = 1
    ORDER BY nombre;
END;
GO

-- ── sp_listar_representantes ───────────────────────────────────
-- Lista representantes activos
CREATE OR ALTER PROCEDURE sp_listar_representantes
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nit, codigo, nombre, telefono, email
    FROM representante
    WHERE activo = 1
      AND (@p_busqueda IS NULL OR nombre LIKE '%' + @p_busqueda + '%'
           OR nit LIKE '%' + @p_busqueda + '%')
    ORDER BY nombre;
END;
GO

PRINT 'sp_compra.sql ejecutado correctamente.';
GO
