USE TellixDB;
GO

/* ============================================================
   MÓDULO CXP — CUENTAS POR PAGAR
   Proyecto: Tellix
   Motor: SQL Server 2019+

   Este archivo crea/actualiza los stored procedures necesarios
   para el módulo de Cuentas por Pagar.

   Tablas utilizadas:
   - cuenta_por_pagar
   - compra
   - proveedor
   - metodo_liquidacion
   - cuenta
   - banco
   - movimiento_cuenta
   - usuario
   - empleado

   Nota importante:
   cuenta_por_pagar.estado solo permite: P, A, X.
   Una CXP totalmente pagada se identifica por saldo = 0.
   ============================================================ */

/* ============================================================
   1. Listar CXP paginadas
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_listar_cxp
    @p_proveedor    NVARCHAR(200) = NULL,
    @p_estado       CHAR(1)       = NULL,
    @p_fecha_desde  DATE          = NULL,
    @p_fecha_hasta  DATE          = NULL,
    @p_vencidas     BIT           = 0,
    @p_pagina       INT           = 1,
    @p_tamano       INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_pagina = CASE WHEN ISNULL(@p_pagina, 0) < 1 THEN 1 ELSE @p_pagina END;
    SET @p_tamano = CASE WHEN ISNULL(@p_tamano, 0) < 1 THEN 20 ELSE @p_tamano END;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;
    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    ;WITH base AS (
        SELECT
            cxp.id,
            cxp.fk_compra,
            c.no_documento,
            c.fk_proveedor,
            p.nombre AS proveedor,
            c.fecha_operacion,
            cxp.fecha_limite,
            cxp.estado,
            CASE cxp.estado
                WHEN 'P' THEN 'Pendiente'
                WHEN 'A' THEN 'Abonada'
                WHEN 'X' THEN 'Anulada'
                ELSE 'Desconocido'
            END AS estado_descripcion,
            cxp.valor_total,
            cxp.valor_pagado,
            CAST(cxp.valor_total - cxp.valor_pagado AS DECIMAL(18,2)) AS saldo,
            CAST(CASE WHEN (cxp.valor_total - cxp.valor_pagado) <= 0 THEN 1 ELSE 0 END AS BIT) AS pagada,
            CAST(CASE
                WHEN cxp.estado <> 'X'
                 AND cxp.fecha_limite < @hoy
                 AND (cxp.valor_total - cxp.valor_pagado) > 0
                THEN 1 ELSE 0
            END AS BIT) AS vencida,
            CASE
                WHEN cxp.estado <> 'X'
                 AND cxp.fecha_limite < @hoy
                 AND (cxp.valor_total - cxp.valor_pagado) > 0
                THEN DATEDIFF(DAY, cxp.fecha_limite, @hoy)
                ELSE 0
            END AS dias_vencida,
            cxp.fk_metodo_pago,
            ml.descripcion AS metodo_pago,
            cxp.fk_cuenta,
            cxp.fk_banco,
            cxp.creado_en
        FROM cuenta_por_pagar cxp
        INNER JOIN compra c ON c.id = cxp.fk_compra
        INNER JOIN proveedor p ON p.nit = c.fk_proveedor
        INNER JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
        WHERE (@p_proveedor IS NULL OR @p_proveedor = ''
               OR p.nombre LIKE '%' + @p_proveedor + '%'
               OR p.nit LIKE '%' + @p_proveedor + '%'
               OR c.no_documento LIKE '%' + @p_proveedor + '%')
          AND (@p_estado IS NULL OR @p_estado = '' OR cxp.estado = @p_estado)
          AND (@p_fecha_desde IS NULL OR cxp.fecha_limite >= @p_fecha_desde)
          AND (@p_fecha_hasta IS NULL OR cxp.fecha_limite <= @p_fecha_hasta)
          AND (@p_vencidas = 0 OR (
                cxp.estado <> 'X'
                AND cxp.fecha_limite < @hoy
                AND (cxp.valor_total - cxp.valor_pagado) > 0
          ))
    )
    SELECT COUNT(*) AS total
    FROM base;

    ;WITH base AS (
        SELECT
            cxp.id,
            cxp.fk_compra,
            c.no_documento,
            c.fk_proveedor,
            p.nombre AS proveedor,
            c.fecha_operacion,
            cxp.fecha_limite,
            cxp.estado,
            CASE cxp.estado
                WHEN 'P' THEN 'Pendiente'
                WHEN 'A' THEN 'Abonada'
                WHEN 'X' THEN 'Anulada'
                ELSE 'Desconocido'
            END AS estado_descripcion,
            cxp.valor_total,
            cxp.valor_pagado,
            CAST(cxp.valor_total - cxp.valor_pagado AS DECIMAL(18,2)) AS saldo,
            CAST(CASE WHEN (cxp.valor_total - cxp.valor_pagado) <= 0 THEN 1 ELSE 0 END AS BIT) AS pagada,
            CAST(CASE
                WHEN cxp.estado <> 'X'
                 AND cxp.fecha_limite < @hoy
                 AND (cxp.valor_total - cxp.valor_pagado) > 0
                THEN 1 ELSE 0
            END AS BIT) AS vencida,
            CASE
                WHEN cxp.estado <> 'X'
                 AND cxp.fecha_limite < @hoy
                 AND (cxp.valor_total - cxp.valor_pagado) > 0
                THEN DATEDIFF(DAY, cxp.fecha_limite, @hoy)
                ELSE 0
            END AS dias_vencida,
            cxp.fk_metodo_pago,
            ml.descripcion AS metodo_pago,
            cxp.fk_cuenta,
            cxp.fk_banco,
            cxp.creado_en
        FROM cuenta_por_pagar cxp
        INNER JOIN compra c ON c.id = cxp.fk_compra
        INNER JOIN proveedor p ON p.nit = c.fk_proveedor
        INNER JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
        WHERE (@p_proveedor IS NULL OR @p_proveedor = ''
               OR p.nombre LIKE '%' + @p_proveedor + '%'
               OR p.nit LIKE '%' + @p_proveedor + '%'
               OR c.no_documento LIKE '%' + @p_proveedor + '%')
          AND (@p_estado IS NULL OR @p_estado = '' OR cxp.estado = @p_estado)
          AND (@p_fecha_desde IS NULL OR cxp.fecha_limite >= @p_fecha_desde)
          AND (@p_fecha_hasta IS NULL OR cxp.fecha_limite <= @p_fecha_hasta)
          AND (@p_vencidas = 0 OR (
                cxp.estado <> 'X'
                AND cxp.fecha_limite < @hoy
                AND (cxp.valor_total - cxp.valor_pagado) > 0
          ))
    )
    SELECT *
    FROM base
    ORDER BY vencida DESC, fecha_limite ASC, id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

/* ============================================================
   2. Obtener detalle de una CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_obtener_cxp
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT
        cxp.id,
        cxp.fk_compra,
        c.no_documento,
        c.fk_proveedor,
        p.nombre AS proveedor,
        p.direccion_fiscal,
        c.fecha_operacion,
        cxp.fecha_limite,
        cxp.estado,
        CASE cxp.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Abonada'
            WHEN 'X' THEN 'Anulada'
            ELSE 'Desconocido'
        END AS estado_descripcion,
        cxp.valor_total,
        cxp.valor_pagado,
        CAST(cxp.valor_total - cxp.valor_pagado AS DECIMAL(18,2)) AS saldo,
        CAST(CASE WHEN (cxp.valor_total - cxp.valor_pagado) <= 0 THEN 1 ELSE 0 END AS BIT) AS pagada,
        CAST(CASE
            WHEN cxp.estado <> 'X'
             AND cxp.fecha_limite < @hoy
             AND (cxp.valor_total - cxp.valor_pagado) > 0
            THEN 1 ELSE 0
        END AS BIT) AS vencida,
        cxp.fk_metodo_pago,
        ml.descripcion AS metodo_pago,
        cxp.fk_cuenta,
        cxp.fk_banco,
        b.nombre AS banco,
        cxp.creado_en
    FROM cuenta_por_pagar cxp
    INNER JOIN compra c ON c.id = cxp.fk_compra
    INNER JOIN proveedor p ON p.nit = c.fk_proveedor
    INNER JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
    LEFT JOIN banco b ON b.codigo = cxp.fk_banco
    WHERE cxp.id = @p_id;

    SELECT
        mc.id,
        mc.fk_cuenta,
        mc.tipo_documento,
        mc.no_documento,
        mc.fecha_operacion,
        mc.monto,
        mc.descripcion,
        mc.fk_usuario,
        u.user_name AS usuario
    FROM movimiento_cuenta mc
    LEFT JOIN usuario u ON u.codigo = mc.fk_usuario
    WHERE mc.tipo_documento = 'CXP'
      AND mc.no_documento = CAST(@p_id AS NVARCHAR(50))
    ORDER BY mc.fecha_operacion DESC, mc.id DESC;
END;
GO

/* ============================================================
   3. Registrar pago de CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_registrar_pago_cxp
    @p_cxp_id      INT,
    @p_monto       DECIMAL(18,2),
    @p_metodo_pago INT,
    @p_cuenta      NVARCHAR(50),
    @p_usuario     INT,
    @p_descripcion NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @estado CHAR(1),
        @valor_total DECIMAL(18,2),
        @valor_pagado DECIMAL(18,2),
        @saldo DECIMAL(18,2),
        @saldo_final DECIMAL(18,2),
        @fk_compra INT,
        @fk_banco INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @estado = estado,
            @valor_total = valor_total,
            @valor_pagado = valor_pagado,
            @fk_compra = fk_compra
        FROM cuenta_por_pagar WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @p_cxp_id;

        IF @fk_compra IS NULL
            THROW 51000, 'La cuenta por pagar no existe.', 1;

        IF @estado = 'X'
            THROW 51001, 'No se puede pagar una cuenta por pagar anulada.', 1;

        IF @p_monto IS NULL OR @p_monto <= 0
            THROW 51002, 'El monto del pago debe ser mayor a cero.', 1;

        IF @p_metodo_pago IS NULL
            THROW 51003, 'El método de pago es requerido.', 1;

        IF @p_cuenta IS NULL OR LTRIM(RTRIM(@p_cuenta)) = ''
            THROW 51004, 'La cuenta bancaria es requerida.', 1;

        IF NOT EXISTS (SELECT 1 FROM metodo_liquidacion WHERE codigo = @p_metodo_pago AND activo = 1)
            THROW 51005, 'El método de pago no existe o no está activo.', 1;

        SELECT @fk_banco = fk_banco
        FROM cuenta
        WHERE numero = @p_cuenta
          AND estado = 'A';

        IF @fk_banco IS NULL
            THROW 51006, 'La cuenta bancaria no existe o no está activa.', 1;

        SET @saldo = @valor_total - @valor_pagado;

        IF @saldo <= 0
            THROW 51007, 'La cuenta por pagar ya no tiene saldo pendiente.', 1;

        IF @p_monto > @saldo
            THROW 51008, 'El monto del pago no puede ser mayor que el saldo pendiente.', 1;

        SET @saldo_final = @saldo - @p_monto;

        UPDATE cuenta_por_pagar
        SET
            valor_pagado = valor_pagado + @p_monto,
            estado = 'A',
            fk_metodo_pago = @p_metodo_pago,
            fk_cuenta = @p_cuenta,
            fk_banco = @fk_banco,
            actualizado_en = SYSDATETIME()
        WHERE id = @p_cxp_id;

        INSERT INTO movimiento_cuenta
            (fk_cuenta, tipo_documento, no_documento, fecha_operacion, monto, descripcion, fk_usuario)
        VALUES
            (
                @p_cuenta,
                'CXP',
                CAST(@p_cxp_id AS NVARCHAR(50)),
                CAST(SYSDATETIME() AS DATE),
                @p_monto * -1,
                COALESCE(@p_descripcion, 'Pago CXP #' + CAST(@p_cxp_id AS NVARCHAR(50))),
                @p_usuario
            );

        UPDATE compra
        SET
            estado = CASE WHEN @saldo_final <= 0 THEN 'C' ELSE 'A' END,
            actualizado_en = SYSDATETIME()
        WHERE id = @fk_compra;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* ============================================================
   4. Anular CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_anular_cxp
    @p_cxp_id  INT,
    @p_usuario INT,
    @p_motivo  NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @valor_pagado DECIMAL(18,2),
        @estado CHAR(1);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @valor_pagado = valor_pagado,
            @estado = estado
        FROM cuenta_por_pagar WITH (UPDLOCK, HOLDLOCK)
        WHERE id = @p_cxp_id;

        IF @estado IS NULL
            THROW 51100, 'La cuenta por pagar no existe.', 1;

        IF @estado = 'X'
            THROW 51101, 'La cuenta por pagar ya se encuentra anulada.', 1;

        IF ISNULL(@valor_pagado, 0) > 0
            THROW 51102, 'No se puede anular una cuenta por pagar con pagos registrados.', 1;

        UPDATE cuenta_por_pagar
        SET
            estado = 'X',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_cxp_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* ============================================================
   5. Reporte de CXP vencidas
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_reporte_cxp_vencidas
    @p_fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fecha DATE = COALESCE(@p_fecha, CAST(SYSDATETIME() AS DATE));

    SELECT
        cxp.id,
        cxp.fk_compra,
        c.no_documento,
        c.fk_proveedor,
        p.nombre AS proveedor,
        c.fecha_operacion,
        cxp.fecha_limite,
        cxp.estado,
        CASE cxp.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Abonada'
            WHEN 'X' THEN 'Anulada'
            ELSE 'Desconocido'
        END AS estado_descripcion,
        cxp.valor_total,
        cxp.valor_pagado,
        CAST(cxp.valor_total - cxp.valor_pagado AS DECIMAL(18,2)) AS saldo,
        CAST(CASE WHEN (cxp.valor_total - cxp.valor_pagado) <= 0 THEN 1 ELSE 0 END AS BIT) AS pagada,
        CAST(1 AS BIT) AS vencida,
        DATEDIFF(DAY, cxp.fecha_limite, @fecha) AS dias_vencida,
        cxp.fk_metodo_pago,
        ml.descripcion AS metodo_pago,
        cxp.fk_cuenta,
        cxp.fk_banco,
        cxp.creado_en
    FROM cuenta_por_pagar cxp
    INNER JOIN compra c ON c.id = cxp.fk_compra
    INNER JOIN proveedor p ON p.nit = c.fk_proveedor
    INNER JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
    WHERE cxp.estado <> 'X'
      AND cxp.fecha_limite < @fecha
      AND (cxp.valor_total - cxp.valor_pagado) > 0
    ORDER BY cxp.fecha_limite ASC, cxp.id DESC;
END;
GO

/* ============================================================
   6. Resumen financiero de CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_resumen_cxp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT
        CAST(ISNULL(SUM(CASE WHEN estado <> 'X' THEN valor_total ELSE 0 END), 0) AS DECIMAL(18,2)) AS total_pendiente,
        CAST(ISNULL(SUM(CASE WHEN estado <> 'X' THEN valor_pagado ELSE 0 END), 0) AS DECIMAL(18,2)) AS total_pagado,
        CAST(ISNULL(SUM(CASE WHEN estado <> 'X' THEN valor_total - valor_pagado ELSE 0 END), 0) AS DECIMAL(18,2)) AS saldo_total,
        SUM(CASE WHEN estado <> 'X' AND (valor_total - valor_pagado) > 0 THEN 1 ELSE 0 END) AS cuentas_pendientes,
        SUM(CASE WHEN estado <> 'X' AND fecha_limite < @hoy AND (valor_total - valor_pagado) > 0 THEN 1 ELSE 0 END) AS cuentas_vencidas,
        SUM(CASE WHEN estado <> 'X' AND (valor_total - valor_pagado) <= 0 THEN 1 ELSE 0 END) AS cuentas_pagadas
    FROM cuenta_por_pagar;
END;
GO

/* ============================================================
   7. Generar CXP desde compra existente
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_generar_cxp_desde_compra
    @p_compra_id INT,
    @p_cxp_id    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @metodo_pago INT,
        @total DECIMAL(18,2),
        @fecha_operacion DATE,
        @plazo_credito INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM cuenta_por_pagar WHERE fk_compra = @p_compra_id)
            THROW 51200, 'Ya existe una cuenta por pagar para esta compra.', 1;

        SELECT
            @metodo_pago = fk_metodo_pago,
            @total = total,
            @fecha_operacion = fecha_operacion,
            @plazo_credito = plazo_credito
        FROM compra
        WHERE id = @p_compra_id;

        IF @metodo_pago IS NULL
            THROW 51201, 'La compra no existe.', 1;

        INSERT INTO cuenta_por_pagar
            (fk_compra, estado, fk_metodo_pago, valor_total, valor_pagado, fecha_limite)
        VALUES
            (
                @p_compra_id,
                'P',
                @metodo_pago,
                @total,
                0,
                DATEADD(DAY, ISNULL(@plazo_credito, 0), @fecha_operacion)
            );

        SET @p_cxp_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* ============================================================
   8. Catálogo de métodos de pago para CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_listar_metodos_pago_cxp
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        codigo,
        descripcion
    FROM metodo_liquidacion
    WHERE activo = 1
    ORDER BY descripcion;
END;
GO

/* ============================================================
   9. Catálogo de cuentas bancarias para CXP
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_listar_cuentas_bancarias_cxp
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.numero,
        c.fk_banco,
        b.nombre AS banco,
        c.titular,
        c.descripcion
    FROM cuenta c
    INNER JOIN banco b ON b.codigo = c.fk_banco
    WHERE c.estado = 'A'
      AND b.activo = 1
    ORDER BY b.nombre, c.numero;
END;
GO

/* ============================================================
   10. Actualización de sp_registrar_compra
       Genera CXP automáticamente cuando @p_plazo > 0.

       Se conserva la firma original para no romper el backend.
   ============================================================ */
CREATE OR ALTER PROCEDURE sp_registrar_compra
    @p_no_documento     NVARCHAR(50),
    @p_proveedor        NVARCHAR(50),
    @p_representante    NVARCHAR(50) = NULL,
    @p_usuario          INT,
    @p_metodo_pago      INT,
    @p_plazo            INT,
    @p_items            NVARCHAR(MAX),
    @p_compra_id        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO compra
            (no_documento, fk_proveedor, fk_representante, fk_usuario, fk_metodo_pago, plazo_credito, estado)
        VALUES
            (@p_no_documento, @p_proveedor, @p_representante, @p_usuario, @p_metodo_pago, @p_plazo, 'P');

        SET @p_compra_id = SCOPE_IDENTITY();

        INSERT INTO detalle_compra
            (fk_compra, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
        SELECT
            @p_compra_id,
            JSON_VALUE(item.value, '$.fk_producto'),
            JSON_VALUE(item.value, '$.cantidad'),
            JSON_VALUE(item.value, '$.precio_unitario'),
            ISNULL(JSON_VALUE(item.value, '$.descuentos'), 0),
            ISNULL(JSON_VALUE(item.value, '$.impuestos'), 0),
            (CAST(JSON_VALUE(item.value, '$.cantidad') AS DECIMAL(18,4))
             * CAST(JSON_VALUE(item.value, '$.precio_unitario') AS DECIMAL(18,4)))
            - ISNULL(CAST(JSON_VALUE(item.value, '$.descuentos') AS DECIMAL(18,2)), 0)
            + ISNULL(CAST(JSON_VALUE(item.value, '$.impuestos') AS DECIMAL(18,2)), 0)
        FROM OPENJSON(@p_items) AS item;

        UPDATE c SET
            subtotal         = d.sub,
            total_descuentos = d.desc_total,
            total_impuestos  = d.imp_total,
            total            = d.sub - d.desc_total + d.imp_total,
            actualizado_en   = SYSDATETIME()
        FROM compra c
        CROSS JOIN (
            SELECT
                SUM(cantidad * precio_unitario) AS sub,
                SUM(descuentos)                 AS desc_total,
                SUM(impuestos)                  AS imp_total
            FROM detalle_compra
            WHERE fk_compra = @p_compra_id
        ) d
        WHERE c.id = @p_compra_id;

        INSERT INTO movimiento_inventario
            (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            cantidad,
            'Compra #' + CAST(@p_compra_id AS NVARCHAR(50)),
            'ENTRADA',
            @p_usuario,
            'COMPRA',
            CAST(@p_compra_id AS NVARCHAR(50))
        FROM detalle_compra
        WHERE fk_compra = @p_compra_id;

        UPDATE p SET
            stock_actual   = p.stock_actual + d.total_qty,
            actualizado_en = SYSDATETIME()
        FROM producto p
        INNER JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_compra
            WHERE fk_compra = @p_compra_id
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        IF ISNULL(@p_plazo, 0) > 0
        BEGIN
            INSERT INTO cuenta_por_pagar
                (fk_compra, estado, fk_metodo_pago, valor_total, valor_pagado, fecha_limite)
            SELECT
                c.id,
                'P',
                c.fk_metodo_pago,
                c.total,
                0,
                DATEADD(DAY, ISNULL(c.plazo_credito, 0), c.fecha_operacion)
            FROM compra c
            WHERE c.id = @p_compra_id
              AND NOT EXISTS (
                  SELECT 1
                  FROM cuenta_por_pagar cxp
                  WHERE cxp.fk_compra = c.id
              );
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
