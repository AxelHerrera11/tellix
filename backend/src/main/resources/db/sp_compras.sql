-- ============================================================
--  TELLIX — Stored Procedures módulo COMPRAS
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_compras ─────────────────────────────────────────
-- Listado paginado con filtros opcionales
CREATE OR ALTER PROCEDURE sp_listar_compras
    @p_proveedor    NVARCHAR(200) = NULL,
    @p_estado       CHAR(1)       = NULL,
    @p_fecha_desde  DATE          = NULL,
    @p_fecha_hasta  DATE          = NULL,
    @p_pagina       INT           = 1,
    @p_tamano       INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    -- Total para paginación
    SELECT COUNT(*) AS total
    FROM compra c
    WHERE (@p_proveedor   IS NULL OR c.fk_proveedor  LIKE '%' + @p_proveedor + '%')
      AND (@p_estado      IS NULL OR c.estado         = @p_estado)
      AND (@p_fecha_desde IS NULL OR c.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR c.fecha_operacion <= @p_fecha_hasta);

    -- Datos paginados
    SELECT
        c.id,
        c.no_documento,
        c.fk_proveedor,
        p.nombre                                    AS proveedor,
        c.fk_representante,
        r.nombre_1 + ' ' + r.apellido_1             AS representante,
        c.fecha_operacion,
        c.estado,
        CASE c.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Aprobada'
            WHEN 'C' THEN 'Completada'
            WHEN 'X' THEN 'Anulada'
            ELSE 'Desconocido'
        END                                         AS estado_descripcion,
        c.subtotal,
        c.total_descuentos,
        c.total_impuestos,
        c.total,
        c.plazo_credito,
        ml.descripcion                              AS metodo_pago,
        u.user_name                                 AS usuario,
        c.creado_en
    FROM compra c
    LEFT JOIN proveedor          p  ON p.nit    = c.fk_proveedor
    LEFT JOIN representante      r  ON r.nit    = c.fk_representante
    LEFT JOIN metodo_liquidacion ml ON ml.codigo = c.fk_metodo_pago
    LEFT JOIN usuario            u  ON u.codigo  = c.fk_usuario
    WHERE (@p_proveedor   IS NULL OR c.fk_proveedor  LIKE '%' + @p_proveedor + '%')
      AND (@p_estado      IS NULL OR c.estado         = @p_estado)
      AND (@p_fecha_desde IS NULL OR c.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR c.fecha_operacion <= @p_fecha_hasta)
    ORDER BY c.id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_compra ─────────────────────────────────────────
-- Cabecera + detalle de una compra
CREATE OR ALTER PROCEDURE sp_obtener_compra
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cabecera
    SELECT
        c.id,
        c.no_documento,
        c.fk_proveedor,
        p.nombre                                    AS proveedor,
        p.direccion_fiscal,
        c.fk_representante,
        r.nombre_1 + ' ' + r.apellido_1             AS representante,
        c.fecha_operacion,
        c.hora_operacion,
        c.estado,
        CASE c.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Aprobada'
            WHEN 'C' THEN 'Completada'
            WHEN 'X' THEN 'Anulada'
            ELSE 'Desconocido'
        END                                         AS estado_descripcion,
        c.subtotal,
        c.total_descuentos,
        c.total_impuestos,
        c.total,
        c.plazo_credito,
        c.fk_metodo_pago,
        ml.descripcion                              AS metodo_pago,
        c.fk_usuario,
        u.user_name                                 AS usuario,
        e.nombre_1 + ' ' + e.apellido_1             AS nombre_empleado,
        c.creado_en
    FROM compra c
    LEFT JOIN proveedor            p  ON p.nit    = c.fk_proveedor
    LEFT JOIN representante        r  ON r.nit    = c.fk_representante
    LEFT JOIN metodo_liquidacion   ml ON ml.codigo = c.fk_metodo_pago
    LEFT JOIN usuario              u  ON u.codigo  = c.fk_usuario
    LEFT JOIN empleado             e  ON e.codigo  = u.fk_empleado
    WHERE c.id = @p_id;

    -- Detalle
    SELECT
        dc.id,
        dc.fk_compra,
        dc.fk_producto,
        pr.nombre                                   AS nombre_producto,
        pr.fk_medida,
        m.descripcion                               AS medida,
        dc.cantidad,
        dc.precio_unitario,
        dc.descuentos,
        dc.impuestos,
        dc.subtotal
    FROM detalle_compra dc
    JOIN producto pr ON pr.codigo = dc.fk_producto
    LEFT JOIN medida m ON m.codigo = pr.fk_medida
    WHERE dc.fk_compra = @p_id
    ORDER BY dc.id;
END;
GO

-- ── sp_registrar_compra ───────────────────────────────────────
-- Registra cabecera + detalle, suma inventario, crea CXP si aplica
CREATE OR ALTER PROCEDURE sp_registrar_compra
    @p_no_documento     NVARCHAR(50),
    @p_proveedor        NVARCHAR(50),
    @p_representante    NVARCHAR(50) = NULL,
    @p_usuario          INT,
    @p_metodo_pago      INT,
    @p_plazo            INT,
    @p_items            NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar cabecera
        INSERT INTO compra
            (no_documento, fk_proveedor, fk_representante, fk_usuario, fk_metodo_pago, plazo_credito, estado)
        VALUES
            (@p_no_documento, @p_proveedor, @p_representante, @p_usuario, @p_metodo_pago, @p_plazo, 'P');

        DECLARE @compraId INT = SCOPE_IDENTITY();

        -- Insertar detalle
        INSERT INTO detalle_compra (fk_compra, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
        SELECT
            @compraId,
            items.fkProducto,
            items.cantidad,
            items.precioUnitario,
            ISNULL(items.descuentos, 0),
            ISNULL(items.impuestos, 0),
            (items.cantidad * items.precioUnitario)
                - ISNULL(items.descuentos, 0)
                + ISNULL(items.impuestos, 0)
        FROM OPENJSON(@p_items) WITH (
            fkProducto     INT           '$.fkProducto',
            cantidad       DECIMAL(18,4) '$.cantidad',
            precioUnitario DECIMAL(18,4) '$.precioUnitario',
            descuentos     DECIMAL(18,2) '$.descuentos',
            impuestos      DECIMAL(18,2) '$.impuestos'
        ) AS items;

        -- Recalcular totales en cabecera
        UPDATE compra SET
            subtotal         = t.sub,
            total_descuentos = t.desc_total,
            total_impuestos  = t.imp_total,
            total            = t.sub - t.desc_total + t.imp_total,
            actualizado_en   = SYSDATETIME()
        FROM compra
        CROSS JOIN (
            SELECT
                SUM(cantidad * precio_unitario) AS sub,
                SUM(descuentos)                 AS desc_total,
                SUM(impuestos)                  AS imp_total
            FROM detalle_compra WHERE fk_compra = @compraId
        ) t
        WHERE compra.id = @compraId;

        -- Sumar inventario
        UPDATE p SET
            p.stock_actual   = p.stock_actual + d.total_qty,
            p.actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_compra WHERE fk_compra = @compraId
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        -- Registrar movimiento de inventario
        INSERT INTO movimiento_inventario (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            cantidad,
            'Compra #' + CAST(@compraId AS NVARCHAR(50)),
            'ENTRADA',
            @p_usuario,
            'COMPRA',
            CAST(@compraId AS NVARCHAR(50))
        FROM detalle_compra WHERE fk_compra = @compraId;

        -- Crear CXP si es a crédito
        IF ISNULL(@p_plazo, 0) > 0
        BEGIN
            INSERT INTO cuenta_por_pagar (fk_compra, estado, fk_metodo_pago, valor_total, valor_pagado, fecha_limite)
            SELECT
                @compraId,
                'P',
                fk_metodo_pago,
                total,
                0,
                DATEADD(DAY, ISNULL(plazo_credito, 0), CAST(SYSDATETIME() AS DATE))
            FROM compra WHERE id = @compraId;
        END

        COMMIT TRANSACTION;

        -- Devolver el ID de la compra creada
        SELECT @compraId AS id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_anular_compra ──────────────────────────────────────────
-- Anula una compra y restaura el stock
CREATE OR ALTER PROCEDURE sp_anular_compra
    @p_id       INT,
    @p_usuario  INT,
    @p_motivo   NVARCHAR(200) = 'Anulación manual'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar que existe y no está anulada
        IF NOT EXISTS (SELECT 1 FROM compra WHERE id = @p_id AND estado <> 'X')
        BEGIN
            RAISERROR('La compra no existe o ya fue anulada.', 16, 1);
        END

        -- Anular compra
        UPDATE compra SET
            estado         = 'X',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        -- Restaurar stock (restar lo que se había sumado)
        UPDATE p SET
            p.stock_actual   = p.stock_actual - d.total_qty,
            p.actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_compra WHERE fk_compra = @p_id
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        -- Movimiento de inventario (devolución)
        INSERT INTO movimiento_inventario (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            -cantidad,
            'Anulación compra #' + CAST(@p_id AS NVARCHAR(50)) + ' — ' + @p_motivo,
            'DEVOLUCION',
            @p_usuario,
            'COMPRA',
            CAST(@p_id AS NVARCHAR(50))
        FROM detalle_compra WHERE fk_compra = @p_id;

        -- Anular CXP asociada si existe
        UPDATE cuenta_por_pagar SET
            estado         = 'X',
            actualizado_en = SYSDATETIME()
        WHERE fk_compra = @p_id AND estado IN ('P', 'A');

        COMMIT TRANSACTION;

        SELECT @p_id AS id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_buscar_productos_compra ────────────────────────────────
-- Búsqueda rápida de productos para el formulario de compra
CREATE OR ALTER PROCEDURE sp_buscar_productos_compra
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 50
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        p.stock_minimo,
        p.fk_medida,
        m.descripcion AS medida
    FROM producto p
    LEFT JOIN medida m ON m.codigo = p.fk_medida
    WHERE p.estado = 'A'
      AND (@p_busqueda IS NULL
           OR p.nombre  LIKE '%' + @p_busqueda + '%'
           OR p.codigo  = TRY_CAST(@p_busqueda AS INT))
    ORDER BY p.nombre;
END;
GO

-- ── sp_buscar_proveedores_compra ──────────────────────────────
-- Búsqueda rápida de proveedores para el formulario de compra
CREATE OR ALTER PROCEDURE sp_buscar_proveedores_compra
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 20
        p.nit,
        p.nombre,
        p.direccion_fiscal
    FROM proveedor p
    WHERE p.estado = 'A'
      AND (@p_busqueda IS NULL
           OR p.nit     LIKE '%' + @p_busqueda + '%'
           OR p.nombre  LIKE '%' + @p_busqueda + '%')
    ORDER BY p.nombre;
END;
GO

-- ── sp_listar_representantes ──────────────────────────────────
-- Lista los representantes activos de un proveedor
CREATE OR ALTER PROCEDURE sp_listar_representantes
    @p_proveedor NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.nit,
        r.codigo,
        r.nombre_1 + ' ' + r.apellido_1 AS nombre_completo,
        r.nombre_1,
        r.apellido_1,
        (SELECT TOP 1 cr.info_contacto
         FROM contacto_representante cr
         WHERE cr.fk_representante = r.nit
           AND cr.fk_tipo = 1
           AND cr.principal = 1) AS telefono,
        (SELECT TOP 1 cr.info_contacto
         FROM contacto_representante cr
         WHERE cr.fk_representante = r.nit
           AND cr.fk_tipo = 2
           AND cr.principal = 1) AS email
    FROM representante r
    WHERE r.fk_proveedor = @p_proveedor
      AND r.activo = 1
    ORDER BY r.nombre_1;
END;
GO

-- ── sp_listar_metodos_pago ────────────────────────────────────
-- Catálogo de métodos de pago para el formulario de compra
CREATE OR ALTER PROCEDURE sp_listar_metodos_pago
AS
BEGIN
    SET NOCOUNT ON;

    SELECT codigo, descripcion
    FROM metodo_liquidacion
    WHERE activo = 1
    ORDER BY descripcion;
END;
GO

PRINT 'sp_compras.sql ejecutado correctamente.';
GO
