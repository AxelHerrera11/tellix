USE TellixDB;
GO

-- ── sp_listar_cxp ────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_listar_cxp
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

    SELECT COUNT(*) AS total
    FROM cuenta_por_pagar cxp
    JOIN compra       c  ON c.id = cxp.fk_compra
    JOIN proveedor    p  ON p.nit = c.fk_proveedor
    WHERE (@p_proveedor   IS NULL OR p.nombre LIKE '%' + @p_proveedor + '%')
      AND (@p_estado      IS NULL OR cxp.estado = @p_estado)
      AND (@p_fecha_desde IS NULL OR cxp.fecha_limite >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR cxp.fecha_limite <= @p_fecha_hasta);

    SELECT
        cxp.id,
        cxp.fk_compra,
        c.no_documento,
        p.nit               AS proveedor_nit,
        p.nombre            AS proveedor,
        cxp.estado,
        cxp.valor_total,
        cxp.valor_pagado,
        cxp.valor_total - cxp.valor_pagado AS saldo,
        cxp.fecha_limite,
        ml.descripcion      AS metodo_pago,
        c.fecha_operacion   AS fecha_compra,
        cxp.creado_en
    FROM cuenta_por_pagar cxp
    JOIN compra            c   ON c.id  = cxp.fk_compra
    JOIN proveedor         p   ON p.nit = c.fk_proveedor
    LEFT JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
    WHERE (@p_proveedor   IS NULL OR p.nombre LIKE '%' + @p_proveedor + '%')
      AND (@p_estado      IS NULL OR cxp.estado = @p_estado)
      AND (@p_fecha_desde IS NULL OR cxp.fecha_limite >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR cxp.fecha_limite <= @p_fecha_hasta)
    ORDER BY cxp.fecha_limite ASC, cxp.id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_obtener_cxp ───────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_obtener_cxp
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        cxp.id,
        cxp.fk_compra,
        c.no_documento,
        p.nit               AS proveedor_nit,
        p.nombre            AS proveedor,
        p.direccion_fiscal  AS proveedor_direccion,
        cxp.estado,
        cxp.valor_total,
        cxp.valor_pagado,
        cxp.valor_total - cxp.valor_pagado AS saldo,
        cxp.fecha_limite,
        cxp.fk_metodo_pago,
        ml.descripcion      AS metodo_pago,
        cxp.fk_cuenta,
        cb.numero           AS cuenta_numero,
        b.nombre            AS banco,
        c.fecha_operacion   AS fecha_compra,
        c.subtotal          AS compra_subtotal,
        c.total_descuentos  AS compra_descuentos,
        c.total_impuestos   AS compra_impuestos,
        c.total             AS compra_total,
        u.user_name         AS usuario,
        e.nombre_1 + ' ' + e.apellido_1 AS nombre_empleado,
        cxp.creado_en,
        cxp.actualizado_en
    FROM cuenta_por_pagar cxp
    JOIN compra            c   ON c.id  = cxp.fk_compra
    JOIN proveedor         p   ON p.nit = c.fk_proveedor
    LEFT JOIN metodo_liquidacion ml ON ml.codigo = cxp.fk_metodo_pago
    LEFT JOIN cuenta       cb  ON cb.numero = cxp.fk_cuenta
    LEFT JOIN banco        b   ON b.codigo  = cxp.fk_banco
    LEFT JOIN usuario      u   ON u.codigo  = c.fk_usuario
    LEFT JOIN empleado     e   ON e.codigo  = u.fk_empleado
    WHERE cxp.id = @p_id;

    SELECT
        dc.id,
        dc.fk_compra,
        dc.fk_producto,
        pr.nombre           AS nombre_producto,
        dc.cantidad,
        dc.precio_unitario,
        dc.descuentos,
        dc.impuestos,
        dc.subtotal
    FROM detalle_compra dc
    JOIN producto pr ON pr.codigo = dc.fk_producto
    WHERE dc.fk_compra = (SELECT fk_compra FROM cuenta_por_pagar WHERE id = @p_id)
    ORDER BY dc.id;
END;
GO

-- ── sp_registrar_pago_cxp ────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_registrar_pago_cxp
    @p_id           INT,
    @p_monto        DECIMAL(18,2),
    @p_usuario      INT,
    @p_descripcion  NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @valor_total DECIMAL(18,2), @valor_pagado DECIMAL(18,2), @saldo DECIMAL(18,2);

        SELECT @valor_total = valor_total, @valor_pagado = valor_pagado
        FROM cuenta_por_pagar WHERE id = @p_id;

        IF @valor_total IS NULL
            THROW 50000, 'La cuenta por pagar no existe.', 1;

        IF @p_monto <= 0
            THROW 50000, 'El monto del pago debe ser mayor a cero.', 1;

        SET @saldo = @valor_total - @valor_pagado;

        IF @p_monto > @saldo
            THROW 50000, 'El monto del pago excede el saldo pendiente.', 1;

        UPDATE cuenta_por_pagar SET
            valor_pagado  = valor_pagado + @p_monto,
            estado        = CASE
                              WHEN valor_pagado + @p_monto >= valor_total THEN 'A'
                              ELSE 'P'
                            END,
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        COMMIT TRANSACTION;

        SELECT @p_id AS id, @p_monto AS monto_pagado;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_anular_cxp ────────────────────────────────────────────
CREATE OR ALTER PROCEDURE sp_anular_cxp
    @p_id       INT,
    @p_usuario  INT,
    @p_motivo   NVARCHAR(200) = 'Anulación manual'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM cuenta_por_pagar WHERE id = @p_id AND estado IN ('P', 'A'))
            THROW 50000, 'La cuenta por pagar no existe o ya fue cancelada.', 1;

        UPDATE cuenta_por_pagar SET
            estado         = 'X',
            actualizado_en = SYSDATETIME()
        WHERE id = @p_id;

        COMMIT TRANSACTION;

        SELECT @p_id AS id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── sp_reporte_cxp_vencidas ──────────────────────────────────
CREATE OR ALTER PROCEDURE sp_reporte_cxp_vencidas
    @p_fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);

    SELECT
        cxp.id,
        cxp.fk_compra,
        c.no_documento,
        p.nombre            AS proveedor,
        cxp.valor_total,
        cxp.valor_pagado,
        cxp.valor_total - cxp.valor_pagado AS saldo,
        cxp.fecha_limite,
        DATEDIFF(DAY, cxp.fecha_limite, @p_fecha) AS dias_vencida
    FROM cuenta_por_pagar cxp
    JOIN compra     c ON c.id  = cxp.fk_compra
    JOIN proveedor  p ON p.nit = c.fk_proveedor
    WHERE cxp.estado IN ('P', 'A')
      AND cxp.fecha_limite < @p_fecha
      AND cxp.valor_total > cxp.valor_pagado
    ORDER BY dias_vencida DESC;
END;
GO
