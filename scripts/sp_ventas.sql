-- ============================================================
--  TELLIX — Stored Procedures módulo VENTAS
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- Agregar columna tipo_plazo a la tabla venta
ALTER TABLE venta
ADD tipo_plazo NVARCHAR(50) NULL DEFAULT 'DIAS';
GO

-- ── sp_listar_ventas ─────────────────────────────────────────
-- Listado paginado con filtros opcionales
CREATE OR ALTER PROCEDURE sp_listar_ventas
    @p_cliente      NVARCHAR(50)  = NULL,
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
    FROM venta v
    WHERE (@p_cliente    IS NULL OR v.fk_cliente     LIKE '%' + @p_cliente + '%')
      AND (@p_estado     IS NULL OR v.estado          = @p_estado)
      AND (@p_fecha_desde IS NULL OR v.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR v.fecha_operacion <= @p_fecha_hasta);

    -- Datos paginados
    SELECT
        v.id,
        v.fk_cliente,
        cl.nombre_1 + ' ' + cl.apellido_1          AS nombre_cliente,
        v.fecha_operacion,
        v.estado,
        v.subtotal,
        v.total_descuentos,
        v.total_impuestos,
        v.total,
        v.plazo_credito,
        ml.descripcion                              AS metodo_pago,
        u.user_name                                 AS usuario,
        v.creado_en
    FROM venta v
    LEFT JOIN cliente           cl ON cl.nit    = v.fk_cliente
    LEFT JOIN metodo_liquidacion ml ON ml.codigo = v.fk_metodo_pago
    LEFT JOIN usuario            u  ON u.codigo  = v.fk_usuario
    WHERE (@p_cliente     IS NULL OR v.fk_cliente      LIKE '%' + @p_cliente + '%')
      AND (@p_estado      IS NULL OR v.estado           = @p_estado)
      AND (@p_fecha_desde IS NULL OR v.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR v.fecha_operacion <= @p_fecha_hasta)
    ORDER BY v.id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_venta ─────────────────────────────────────────
-- Cabecera + detalle de una venta
CREATE OR ALTER PROCEDURE sp_obtener_venta
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cabecera
    SELECT
        v.id,
        v.fk_cliente,
        cl.nombre_1 + ' ' + cl.apellido_1          AS nombre_cliente,
        cl.nit,
        v.fecha_operacion,
        v.hora_operacion,
        v.estado,
        v.subtotal,
        v.total_descuentos,
        v.total_impuestos,
        v.total,
        v.plazo_credito,
        v.tipo_plazo,
        v.fk_metodo_pago,
        ml.descripcion                              AS metodo_pago,
        v.fk_usuario,
        u.user_name                                 AS usuario,
        e.nombre_1 + ' ' + e.apellido_1            AS nombre_empleado,
        v.creado_en
    FROM venta v
    LEFT JOIN cliente            cl ON cl.nit    = v.fk_cliente
    LEFT JOIN metodo_liquidacion ml ON ml.codigo = v.fk_metodo_pago
    LEFT JOIN usuario             u ON u.codigo  = v.fk_usuario
    LEFT JOIN empleado            e ON e.codigo  = u.fk_empleado
    WHERE v.id = @p_id;

    -- Detalle
    SELECT
        dv.id,
        dv.fk_venta,
        dv.fk_producto,
        p.nombre                                    AS nombre_producto,
        p.fk_medida,
        m.descripcion                               AS medida,
        dv.cantidad,
        dv.precio_unitario,
        dv.descuentos,
        dv.impuestos,
        dv.subtotal
    FROM detalle_venta dv
    JOIN producto p ON p.codigo = dv.fk_producto
    LEFT JOIN medida m ON m.codigo = p.fk_medida
    WHERE dv.fk_venta = @p_id
    ORDER BY dv.id;
END;
GO

-- ── sp_registrar_venta ───────────────────────────────────────
-- Registra cabecera + detalle, descuenta inventario, crea CXC si aplica
CREATE OR ALTER PROCEDURE sp_registrar_venta
    @p_cliente      NVARCHAR(50),
    @p_usuario      INT,
    @p_metodo_pago  INT,
    @p_plazo        INT,
    @p_tipo_plazo   NVARCHAR(50) = 'DIAS',
    @p_items        NVARCHAR(MAX)   -- JSON: [{fkProducto,cantidad,precioUnitario,descuentos,impuestos}]
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar stock suficiente para cada ítem
        IF EXISTS (
            SELECT 1
            FROM OPENJSON(@p_items) WITH (
                fkProducto    INT           '$.fkProducto',
                cantidad      DECIMAL(18,4) '$.cantidad'
            ) AS items
            JOIN producto p ON p.codigo = items.fkProducto
            WHERE p.stock_actual < items.cantidad
        )
        BEGIN
            RAISERROR('Stock insuficiente para uno o más productos.', 16, 1);
        END

        -- Insertar cabecera
        INSERT INTO venta (fk_cliente, fk_usuario, fk_metodo_pago, plazo_credito, tipo_plazo, estado)
        VALUES (@p_cliente, @p_usuario, @p_metodo_pago, @p_plazo, @p_tipo_plazo, 'A');

        DECLARE @ventaId INT = SCOPE_IDENTITY();

        -- Insertar detalle
        INSERT INTO detalle_venta (fk_venta, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
        SELECT
            @ventaId,
            items.fkProducto,
            items.cantidad,
            items.precioUnitario,
            ISNULL(items.descuentos, 0),
            ISNULL(items.impuestos,  0),
            (items.cantidad * items.precioUnitario)
                - ISNULL(items.descuentos, 0)
                + ISNULL(items.impuestos,  0)
        FROM OPENJSON(@p_items) WITH (
            fkProducto     INT           '$.fkProducto',
            cantidad       DECIMAL(18,4) '$.cantidad',
            precioUnitario DECIMAL(18,4) '$.precioUnitario',
            descuentos     DECIMAL(18,2) '$.descuentos',
            impuestos      DECIMAL(18,2) '$.impuestos'
        ) AS items;

        -- Recalcular totales en cabecera
        UPDATE venta SET
            subtotal         = t.sub,
            total_descuentos = t.desc_total,
            total_impuestos  = t.imp_total,
            total            = t.sub - t.desc_total + t.imp_total,
            actualizado_en   = SYSDATETIME()
        FROM venta
        CROSS JOIN (
            SELECT
                SUM(cantidad * precio_unitario) AS sub,
                SUM(descuentos)                 AS desc_total,
                SUM(impuestos)                  AS imp_total
            FROM detalle_venta WHERE fk_venta = @ventaId
        ) t
        WHERE venta.id = @ventaId;

        -- Descontar stock
        UPDATE p SET
            p.stock_actual   = p.stock_actual - d.total_qty,
            p.actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_venta WHERE fk_venta = @ventaId
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        -- Registrar movimiento de inventario
        INSERT INTO movimiento_inventario (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            -cantidad,
            'Venta #' + CAST(@ventaId AS NVARCHAR),
            'SALIDA',
            @p_usuario,
            'VENTA',
            CAST(@ventaId AS NVARCHAR)
        FROM detalle_venta WHERE fk_venta = @ventaId;

        -- Crear CXC si es a crédito
        IF @p_plazo > 0
        BEGIN
            INSERT INTO cuenta_por_cobrar (fk_venta, fk_cliente, estado, fk_metodo_pago, valor_total, valor_cobrado, fecha_limite)
            SELECT
                @ventaId,
                @p_cliente,
                'P',
                @p_metodo_pago,
                total,
                0,
                CASE @p_tipo_plazo
                    WHEN 'DIAS'  THEN DATEADD(DAY,   @p_plazo, CAST(SYSDATETIME() AS DATE))
                    WHEN 'MESES' THEN DATEADD(MONTH,  @p_plazo, CAST(SYSDATETIME() AS DATE))
                    ELSE              DATEADD(DAY,   @p_plazo, CAST(SYSDATETIME() AS DATE))
                END
            FROM venta WHERE id = @ventaId;
        END

        COMMIT TRANSACTION;

        -- Devolver el ID de la venta creada
        SELECT @ventaId AS id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_anular_venta ──────────────────────────────────────────
-- Anula una venta y restaura el stock
CREATE OR ALTER PROCEDURE sp_anular_venta
    @p_id       INT,
    @p_usuario  INT,
    @p_motivo   NVARCHAR(200) = 'Anulación manual'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar que existe y está activa
        IF NOT EXISTS (SELECT 1 FROM venta WHERE id = @p_id AND estado = 'A')
        BEGIN
            RAISERROR('La venta no existe o ya fue anulada.', 16, 1);
        END

        -- Anular
        UPDATE venta SET
            estado         = 'X',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        -- Restaurar stock
        UPDATE p SET
            p.stock_actual   = p.stock_actual + d.total_qty,
            p.actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_venta WHERE fk_venta = @p_id
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        -- Movimiento de inventario (devolución)
        INSERT INTO movimiento_inventario (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            cantidad,
            'Anulación venta #' + CAST(@p_id AS NVARCHAR) + ' — ' + @p_motivo,
            'DEVOLUCION',
            @p_usuario,
            'VENTA',
            CAST(@p_id AS NVARCHAR)
        FROM detalle_venta WHERE fk_venta = @p_id;

        -- Anular CXC asociada si existe
        UPDATE cuenta_por_cobrar SET
            estado         = 'X',
            actualizado_en = SYSDATETIME()
        WHERE fk_venta = @p_id AND estado = 'P';

        COMMIT TRANSACTION;

        SELECT @p_id AS id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_precio_vigente ────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_precio_vigente
    @p_producto   INT,
    @p_aplicacion NVARCHAR(50) = NULL,
    @p_fecha      DATE         = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);

    SELECT TOP 1
        id,
        precio_venta,
        aplicacion,
        inicio_vigencia,
        fin_vigencia
    FROM precio
    WHERE fk_producto    = @p_producto
      AND estado         = 'A'
      AND inicio_vigencia <= @p_fecha
      AND (fin_vigencia IS NULL OR fin_vigencia >= @p_fecha)
      AND (@p_aplicacion IS NULL OR aplicacion = @p_aplicacion)
    ORDER BY inicio_vigencia DESC;
END;
GO

-- ── sp_buscar_productos_venta ────────────────────────────────
-- Búsqueda rápida de productos con precio vigente para el POS
CREATE OR ALTER PROCEDURE sp_buscar_productos_venta
    @p_busqueda   NVARCHAR(200) = NULL,
    @p_aplicacion NVARCHAR(50)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT TOP 50
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        p.fk_medida,
        m.descripcion   AS medida,
        pr.precio_venta,
        pr.aplicacion
    FROM producto p
    LEFT JOIN medida m ON m.codigo = p.fk_medida
    OUTER APPLY (
        SELECT TOP 1 precio_venta, aplicacion
        FROM precio
        WHERE fk_producto    = p.codigo
          AND estado         = 'A'
          AND inicio_vigencia <= @hoy
          AND (fin_vigencia IS NULL OR fin_vigencia >= @hoy)
          AND (@p_aplicacion IS NULL OR aplicacion = @p_aplicacion)
        ORDER BY inicio_vigencia DESC
    ) pr
    WHERE p.estado = 'A'
      AND (@p_busqueda IS NULL
           OR p.nombre      LIKE '%' + @p_busqueda + '%'
           OR p.codigo      = TRY_CAST(@p_busqueda AS INT))
    ORDER BY p.nombre;
END;
GO

-- ── sp_buscar_clientes_venta ─────────────────────────────────
-- Búsqueda rápida de clientes para el POS
CREATE OR ALTER PROCEDURE sp_buscar_clientes_venta
    @p_busqueda NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 20
        cl.nit,
        cl.codigo,
        cl.nombre_1 + ' ' + ISNULL(cl.apellido_1, '') AS nombre,
        cl.limite_credito,
        cl.direccion,
        tc.descripcion AS tipo_cliente
    FROM cliente cl
    LEFT JOIN tipo_cliente tc ON tc.codigo = cl.fk_tipo_cliente
    WHERE cl.estado = 'A'
      AND (@p_busqueda IS NULL
           OR cl.nit     LIKE '%' + @p_busqueda + '%'
           OR cl.nombre_1 LIKE '%' + @p_busqueda + '%'
           OR cl.apellido_1 LIKE '%' + @p_busqueda + '%')
    ORDER BY cl.nombre_1;
END;
GO
