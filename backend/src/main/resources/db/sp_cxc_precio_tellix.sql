-- ============================================================
--  TELLIX — Stored Procedures módulos CXC y PRECIO
--  Ejecutar sobre la base de datos TellixDB
-- ============================================================

USE TellixDB;
GO

/* ============================================================
   UTILIDAD DE NOMBRE DE CLIENTE
   Nota: se usa CONCAT_WS, disponible en SQL Server 2017+.
   ============================================================ */

-- ============================================================
--  CXC — CUENTAS POR COBRAR
-- ============================================================

CREATE OR ALTER PROCEDURE sp_listar_cxc
    @p_cliente     NVARCHAR(200) = NULL,
    @p_estado      CHAR(1)       = NULL,
    @p_fecha_desde DATE          = NULL,
    @p_fecha_hasta DATE          = NULL,
    @p_vencidas    BIT           = 0,
    @p_pagina      INT           = 1,
    @p_tamano      INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_pagina < 1 SET @p_pagina = 1;
    IF @p_tamano < 1 SET @p_tamano = 20;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;
    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    ;WITH base AS (
        SELECT
            cxc.id,
            cxc.fk_venta,
            cxc.fk_cliente,
            LTRIM(RTRIM(CONCAT_WS(' ',
                NULLIF(cl.nombre_1, ''),
                NULLIF(cl.nombre_2, ''),
                NULLIF(cl.nombre_3, ''),
                NULLIF(cl.apellido_1, ''),
                NULLIF(cl.apellido_2, ''),
                NULLIF(cl.apellido_casada, '')
            ))) AS cliente,
            v.fecha_operacion,
            cxc.fecha_limite,
            cxc.estado,
            CASE cxc.estado
                WHEN 'P' THEN 'Pendiente'
                WHEN 'A' THEN 'Abonada'
                WHEN 'X' THEN 'Anulada'
                ELSE cxc.estado
            END AS estado_descripcion,
            cxc.valor_total,
            cxc.valor_cobrado,
            cxc.valor_total - cxc.valor_cobrado AS saldo,
            CAST(CASE WHEN cxc.valor_total - cxc.valor_cobrado <= 0 THEN 1 ELSE 0 END AS BIT) AS cobrada,
            CAST(CASE WHEN cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X' THEN 1 ELSE 0 END AS BIT) AS vencida,
            CASE WHEN cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X'
                 THEN DATEDIFF(DAY, cxc.fecha_limite, @hoy)
                 ELSE 0
            END AS dias_vencida,
            cxc.fk_metodo_pago,
            ml.descripcion AS metodo_pago,
            cxc.fk_cuenta,
            cxc.creado_en
        FROM cuenta_por_cobrar cxc
        JOIN venta v ON v.id = cxc.fk_venta
        JOIN cliente cl ON cl.nit = cxc.fk_cliente
        JOIN metodo_liquidacion ml ON ml.codigo = cxc.fk_metodo_pago
        WHERE (@p_cliente IS NULL OR @p_cliente = ''
               OR cxc.fk_cliente LIKE '%' + @p_cliente + '%'
               OR LTRIM(RTRIM(CONCAT_WS(' ', cl.nombre_1, cl.nombre_2, cl.nombre_3, cl.apellido_1, cl.apellido_2, cl.apellido_casada))) LIKE '%' + @p_cliente + '%')
          AND (@p_estado IS NULL OR cxc.estado = @p_estado)
          AND (@p_fecha_desde IS NULL OR v.fecha_operacion >= @p_fecha_desde)
          AND (@p_fecha_hasta IS NULL OR v.fecha_operacion <= @p_fecha_hasta)
          AND (@p_vencidas = 0 OR (cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X'))
    )
    SELECT COUNT(*) AS total FROM base;

    ;WITH base AS (
        SELECT
            cxc.id,
            cxc.fk_venta,
            cxc.fk_cliente,
            LTRIM(RTRIM(CONCAT_WS(' ',
                NULLIF(cl.nombre_1, ''),
                NULLIF(cl.nombre_2, ''),
                NULLIF(cl.nombre_3, ''),
                NULLIF(cl.apellido_1, ''),
                NULLIF(cl.apellido_2, ''),
                NULLIF(cl.apellido_casada, '')
            ))) AS cliente,
            v.fecha_operacion,
            cxc.fecha_limite,
            cxc.estado,
            CASE cxc.estado
                WHEN 'P' THEN 'Pendiente'
                WHEN 'A' THEN 'Abonada'
                WHEN 'X' THEN 'Anulada'
                ELSE cxc.estado
            END AS estado_descripcion,
            cxc.valor_total,
            cxc.valor_cobrado,
            cxc.valor_total - cxc.valor_cobrado AS saldo,
            CAST(CASE WHEN cxc.valor_total - cxc.valor_cobrado <= 0 THEN 1 ELSE 0 END AS BIT) AS cobrada,
            CAST(CASE WHEN cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X' THEN 1 ELSE 0 END AS BIT) AS vencida,
            CASE WHEN cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X'
                 THEN DATEDIFF(DAY, cxc.fecha_limite, @hoy)
                 ELSE 0
            END AS dias_vencida,
            cxc.fk_metodo_pago,
            ml.descripcion AS metodo_pago,
            cxc.fk_cuenta,
            cxc.creado_en
        FROM cuenta_por_cobrar cxc
        JOIN venta v ON v.id = cxc.fk_venta
        JOIN cliente cl ON cl.nit = cxc.fk_cliente
        JOIN metodo_liquidacion ml ON ml.codigo = cxc.fk_metodo_pago
        WHERE (@p_cliente IS NULL OR @p_cliente = ''
               OR cxc.fk_cliente LIKE '%' + @p_cliente + '%'
               OR LTRIM(RTRIM(CONCAT_WS(' ', cl.nombre_1, cl.nombre_2, cl.nombre_3, cl.apellido_1, cl.apellido_2, cl.apellido_casada))) LIKE '%' + @p_cliente + '%')
          AND (@p_estado IS NULL OR cxc.estado = @p_estado)
          AND (@p_fecha_desde IS NULL OR v.fecha_operacion >= @p_fecha_desde)
          AND (@p_fecha_hasta IS NULL OR v.fecha_operacion <= @p_fecha_hasta)
          AND (@p_vencidas = 0 OR (cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X'))
    )
    SELECT *
    FROM base
    ORDER BY vencida DESC, fecha_limite ASC, id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE sp_obtener_cxc
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT
        cxc.id,
        cxc.fk_venta,
        cxc.fk_cliente,
        LTRIM(RTRIM(CONCAT_WS(' ',
            NULLIF(cl.nombre_1, ''),
            NULLIF(cl.nombre_2, ''),
            NULLIF(cl.nombre_3, ''),
            NULLIF(cl.apellido_1, ''),
            NULLIF(cl.apellido_2, ''),
            NULLIF(cl.apellido_casada, '')
        ))) AS cliente,
        cl.direccion,
        v.fecha_operacion,
        cxc.fecha_limite,
        cxc.estado,
        CASE cxc.estado
            WHEN 'P' THEN 'Pendiente'
            WHEN 'A' THEN 'Abonada'
            WHEN 'X' THEN 'Anulada'
            ELSE cxc.estado
        END AS estado_descripcion,
        cxc.valor_total,
        cxc.valor_cobrado,
        cxc.valor_total - cxc.valor_cobrado AS saldo,
        CAST(CASE WHEN cxc.valor_total - cxc.valor_cobrado <= 0 THEN 1 ELSE 0 END AS BIT) AS cobrada,
        CAST(CASE WHEN cxc.fecha_limite < @hoy AND cxc.valor_total - cxc.valor_cobrado > 0 AND cxc.estado <> 'X' THEN 1 ELSE 0 END AS BIT) AS vencida,
        cxc.fk_metodo_pago,
        ml.descripcion AS metodo_pago,
        cxc.fk_cuenta,
        b.nombre AS banco,
        cxc.creado_en
    FROM cuenta_por_cobrar cxc
    JOIN venta v ON v.id = cxc.fk_venta
    JOIN cliente cl ON cl.nit = cxc.fk_cliente
    JOIN metodo_liquidacion ml ON ml.codigo = cxc.fk_metodo_pago
    LEFT JOIN cuenta cu ON cu.numero = cxc.fk_cuenta
    LEFT JOIN banco b ON b.codigo = cu.fk_banco
    WHERE cxc.id = @p_id;

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
    WHERE mc.tipo_documento = 'CXC'
      AND mc.no_documento = CAST(@p_id AS NVARCHAR(50))
    ORDER BY mc.fecha_operacion DESC, mc.id DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_registrar_cobro_cxc
    @p_cxc_id       INT,
    @p_monto        DECIMAL(18,2),
    @p_metodo_pago  INT,
    @p_cuenta       NVARCHAR(50),
    @p_usuario      INT,
    @p_descripcion  NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @estado CHAR(1),
            @valor_total DECIMAL(18,2),
            @valor_cobrado DECIMAL(18,2),
            @saldo DECIMAL(18,2),
            @venta_id INT,
            @saldo_final DECIMAL(18,2);

        SELECT
            @estado = estado,
            @valor_total = valor_total,
            @valor_cobrado = valor_cobrado,
            @venta_id = fk_venta
        FROM cuenta_por_cobrar WITH (UPDLOCK, ROWLOCK)
        WHERE id = @p_cxc_id;

        IF @estado IS NULL
            THROW 51000, 'CXC no encontrada.', 1;

        IF @estado = 'X'
            THROW 51001, 'No se puede registrar cobro sobre una CXC anulada.', 1;

        IF @p_monto IS NULL OR @p_monto <= 0
            THROW 51002, 'El monto del cobro debe ser mayor a cero.', 1;

        IF @p_metodo_pago IS NULL OR NOT EXISTS (SELECT 1 FROM metodo_liquidacion WHERE codigo = @p_metodo_pago AND activo = 1)
            THROW 51003, 'Método de cobro inválido o inactivo.', 1;

        IF @p_cuenta IS NULL OR LTRIM(RTRIM(@p_cuenta)) = ''
            THROW 51004, 'La cuenta bancaria es requerida.', 1;

        IF NOT EXISTS (SELECT 1 FROM cuenta WHERE numero = @p_cuenta AND estado = 'A')
            THROW 51005, 'Cuenta bancaria inválida o inactiva.', 1;

        SET @saldo = @valor_total - @valor_cobrado;

        IF @p_monto > @saldo
            THROW 51006, 'El monto del cobro no puede superar el saldo pendiente.', 1;

        UPDATE cuenta_por_cobrar
        SET
            valor_cobrado = valor_cobrado + @p_monto,
            estado = 'A',
            fk_metodo_pago = @p_metodo_pago,
            fk_cuenta = @p_cuenta,
            actualizado_en = SYSDATETIME()
        WHERE id = @p_cxc_id;

        INSERT INTO movimiento_cuenta
            (fk_cuenta, tipo_documento, no_documento, fecha_operacion, monto, descripcion, fk_usuario)
        VALUES
            (
                @p_cuenta,
                'CXC',
                CAST(@p_cxc_id AS NVARCHAR(50)),
                CAST(SYSDATETIME() AS DATE),
                @p_monto,
                COALESCE(@p_descripcion, 'Cobro CXC #' + CAST(@p_cxc_id AS NVARCHAR(50))),
                @p_usuario
            );

        SELECT @saldo_final = valor_total - valor_cobrado
        FROM cuenta_por_cobrar
        WHERE id = @p_cxc_id;

        UPDATE venta
        SET
            estado = CASE WHEN @saldo_final <= 0 THEN 'C' ELSE 'A' END,
            actualizado_en = SYSDATETIME()
        WHERE id = @venta_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_anular_cxc
    @p_cxc_id  INT,
    @p_usuario INT,
    @p_motivo  NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @valor_cobrado DECIMAL(18,2), @estado CHAR(1);

        SELECT @valor_cobrado = valor_cobrado, @estado = estado
        FROM cuenta_por_cobrar WITH (UPDLOCK, ROWLOCK)
        WHERE id = @p_cxc_id;

        IF @estado IS NULL
            THROW 51100, 'CXC no encontrada.', 1;

        IF @estado = 'X'
            THROW 51101, 'La CXC ya está anulada.', 1;

        IF @valor_cobrado > 0
            THROW 51102, 'No se puede anular una CXC con cobros registrados.', 1;

        UPDATE cuenta_por_cobrar
        SET estado = 'X', actualizado_en = SYSDATETIME()
        WHERE id = @p_cxc_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_reporte_cxc_vencidas
    @p_fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);

    SELECT
        cxc.id,
        cxc.fk_venta,
        cxc.fk_cliente,
        LTRIM(RTRIM(CONCAT_WS(' ', cl.nombre_1, cl.nombre_2, cl.nombre_3, cl.apellido_1, cl.apellido_2, cl.apellido_casada))) AS cliente,
        cxc.valor_total,
        cxc.valor_cobrado,
        cxc.valor_total - cxc.valor_cobrado AS saldo,
        cxc.fecha_limite,
        DATEDIFF(DAY, cxc.fecha_limite, @p_fecha) AS dias_vencida
    FROM cuenta_por_cobrar cxc
    JOIN cliente cl ON cl.nit = cxc.fk_cliente
    WHERE cxc.estado <> 'X'
      AND cxc.fecha_limite < @p_fecha
      AND cxc.valor_total > cxc.valor_cobrado
    ORDER BY dias_vencida DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_resumen_cxc
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT
        COALESCE(SUM(CASE WHEN estado <> 'X' AND valor_total - valor_cobrado > 0 THEN valor_total ELSE 0 END), 0) AS totalPendiente,
        COALESCE(SUM(CASE WHEN estado <> 'X' THEN valor_cobrado ELSE 0 END), 0) AS totalCobrado,
        COALESCE(SUM(CASE WHEN estado <> 'X' THEN valor_total - valor_cobrado ELSE 0 END), 0) AS saldoTotal,
        COUNT(CASE WHEN estado <> 'X' AND valor_total - valor_cobrado > 0 THEN 1 END) AS cuentasPendientes,
        COUNT(CASE WHEN estado <> 'X' AND fecha_limite < @hoy AND valor_total - valor_cobrado > 0 THEN 1 END) AS cuentasVencidas,
        COUNT(CASE WHEN estado <> 'X' AND valor_total - valor_cobrado <= 0 THEN 1 END) AS cuentasCobradas
    FROM cuenta_por_cobrar;
END;
GO

CREATE OR ALTER PROCEDURE sp_generar_cxc_desde_venta
    @p_venta_id INT,
    @p_cxc_id   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @cliente NVARCHAR(50),
            @metodo_pago INT,
            @plazo INT,
            @fecha DATE,
            @total DECIMAL(18,2),
            @estado CHAR(1);

        SELECT
            @cliente = fk_cliente,
            @metodo_pago = fk_metodo_pago,
            @plazo = plazo_credito,
            @fecha = fecha_operacion,
            @total = total,
            @estado = estado
        FROM venta WITH (UPDLOCK, ROWLOCK)
        WHERE id = @p_venta_id;

        IF @cliente IS NULL
            THROW 51200, 'Venta no encontrada.', 1;

        IF EXISTS (SELECT 1 FROM cuenta_por_cobrar WHERE fk_venta = @p_venta_id)
            THROW 51201, 'Ya existe una CXC para esta venta.', 1;

        IF ISNULL(@plazo, 0) <= 0
            THROW 51202, 'La venta es de contado; no genera CXC.', 1;

        IF ISNULL(@total, 0) <= 0
            THROW 51203, 'La venta no tiene total válido para generar CXC.', 1;

        INSERT INTO cuenta_por_cobrar
            (fk_venta, fk_cliente, estado, fk_metodo_pago, valor_total, valor_cobrado, fecha_limite)
        VALUES
            (@p_venta_id, @cliente, 'P', @metodo_pago, @total, 0, DATEADD(DAY, @plazo, @fecha));

        SET @p_cxc_id = SCOPE_IDENTITY();

        UPDATE venta
        SET estado = 'A', actualizado_en = SYSDATETIME()
        WHERE id = @p_venta_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_listar_metodos_cobro_cxc
AS
BEGIN
    SET NOCOUNT ON;
    SELECT codigo, descripcion
    FROM metodo_liquidacion
    WHERE activo = 1
    ORDER BY descripcion;
END;
GO

CREATE OR ALTER PROCEDURE sp_listar_cuentas_bancarias_cxc
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
    JOIN banco b ON b.codigo = c.fk_banco
    WHERE c.estado = 'A'
      AND b.activo = 1
    ORDER BY b.nombre, c.numero;
END;
GO

-- ============================================================
--  PRECIO — GESTIÓN HISTÓRICA DE PRECIOS
-- ============================================================

CREATE OR ALTER PROCEDURE sp_listar_precios
    @p_producto   INT           = NULL,
    @p_busqueda   NVARCHAR(200) = NULL,
    @p_aplicacion NVARCHAR(50)  = NULL,
    @p_estado     CHAR(1)       = NULL,
    @p_vigentes   BIT           = NULL,
    @p_fecha      DATE          = NULL,
    @p_pagina     INT           = 1,
    @p_tamano     INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);
    IF @p_pagina < 1 SET @p_pagina = 1;
    IF @p_tamano < 1 SET @p_tamano = 20;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    ;WITH base AS (
        SELECT
            pr.id,
            pr.fk_producto,
            p.nombre AS producto,
            p.descripcion AS descripcion_producto,
            pr.aplicacion,
            pr.precio_venta,
            pr.inicio_vigencia,
            pr.fin_vigencia,
            pr.estado,
            CASE pr.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE pr.estado END AS estado_descripcion,
            CAST(CASE WHEN pr.estado = 'A'
                       AND pr.inicio_vigencia <= @p_fecha
                       AND (pr.fin_vigencia IS NULL OR pr.fin_vigencia >= @p_fecha)
                      THEN 1 ELSE 0 END AS BIT) AS vigente,
            pr.creado_por,
            u.user_name AS usuario,
            pr.creado_en
        FROM precio pr
        JOIN producto p ON p.codigo = pr.fk_producto
        LEFT JOIN usuario u ON u.codigo = pr.creado_por
        WHERE (@p_producto IS NULL OR pr.fk_producto = @p_producto)
          AND (@p_busqueda IS NULL OR @p_busqueda = '' OR p.nombre LIKE '%' + @p_busqueda + '%' OR pr.aplicacion LIKE '%' + @p_busqueda + '%')
          AND (@p_aplicacion IS NULL OR pr.aplicacion = @p_aplicacion)
          AND (@p_estado IS NULL OR pr.estado = @p_estado)
    )
    SELECT COUNT(*) AS total
    FROM base
    WHERE (@p_vigentes IS NULL OR vigente = @p_vigentes);

    ;WITH base AS (
        SELECT
            pr.id,
            pr.fk_producto,
            p.nombre AS producto,
            p.descripcion AS descripcion_producto,
            pr.aplicacion,
            pr.precio_venta,
            pr.inicio_vigencia,
            pr.fin_vigencia,
            pr.estado,
            CASE pr.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE pr.estado END AS estado_descripcion,
            CAST(CASE WHEN pr.estado = 'A'
                       AND pr.inicio_vigencia <= @p_fecha
                       AND (pr.fin_vigencia IS NULL OR pr.fin_vigencia >= @p_fecha)
                      THEN 1 ELSE 0 END AS BIT) AS vigente,
            pr.creado_por,
            u.user_name AS usuario,
            pr.creado_en
        FROM precio pr
        JOIN producto p ON p.codigo = pr.fk_producto
        LEFT JOIN usuario u ON u.codigo = pr.creado_por
        WHERE (@p_producto IS NULL OR pr.fk_producto = @p_producto)
          AND (@p_busqueda IS NULL OR @p_busqueda = '' OR p.nombre LIKE '%' + @p_busqueda + '%' OR pr.aplicacion LIKE '%' + @p_busqueda + '%')
          AND (@p_aplicacion IS NULL OR pr.aplicacion = @p_aplicacion)
          AND (@p_estado IS NULL OR pr.estado = @p_estado)
    )
    SELECT *
    FROM base
    WHERE (@p_vigentes IS NULL OR vigente = @p_vigentes)
    ORDER BY fk_producto, aplicacion, inicio_vigencia DESC, id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE sp_obtener_precio
    @p_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

    SELECT
        pr.id,
        pr.fk_producto,
        p.nombre AS producto,
        p.descripcion AS descripcion_producto,
        c.descripcion AS categoria,
        m.nombre AS marca,
        md.descripcion AS medida,
        pr.aplicacion,
        pr.precio_venta,
        pr.inicio_vigencia,
        pr.fin_vigencia,
        pr.estado,
        CASE pr.estado WHEN 'A' THEN 'Activo' WHEN 'I' THEN 'Inactivo' ELSE pr.estado END AS estado_descripcion,
        CAST(CASE WHEN pr.estado = 'A'
                   AND pr.inicio_vigencia <= @hoy
                   AND (pr.fin_vigencia IS NULL OR pr.fin_vigencia >= @hoy)
                  THEN 1 ELSE 0 END AS BIT) AS vigente,
        pr.creado_por,
        u.user_name AS usuario,
        pr.creado_en
    FROM precio pr
    JOIN producto p ON p.codigo = pr.fk_producto
    LEFT JOIN categoria c ON c.codigo = p.fk_categoria
    LEFT JOIN marca m ON m.codigo = p.fk_marca
    LEFT JOIN medida md ON md.codigo = p.fk_medida
    LEFT JOIN usuario u ON u.codigo = pr.creado_por
    WHERE pr.id = @p_id;
END;
GO

CREATE OR ALTER PROCEDURE sp_crear_precio
    @p_producto         INT,
    @p_aplicacion       NVARCHAR(50),
    @p_precio_venta     DECIMAL(18,4),
    @p_inicio_vigencia  DATE = NULL,
    @p_cerrar_vigentes  BIT = 1,
    @p_usuario          INT,
    @p_id               INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @p_inicio_vigencia IS NULL SET @p_inicio_vigencia = CAST(SYSDATETIME() AS DATE);

        IF @p_producto IS NULL OR NOT EXISTS (SELECT 1 FROM producto WHERE codigo = @p_producto)
            THROW 52000, 'Producto no encontrado.', 1;

        IF NOT EXISTS (SELECT 1 FROM producto WHERE codigo = @p_producto AND estado = 'A')
            THROW 52001, 'El producto está inactivo.', 1;

        IF @p_aplicacion IS NULL OR LTRIM(RTRIM(@p_aplicacion)) = ''
            THROW 52002, 'La aplicación del precio es requerida.', 1;

        IF @p_precio_venta IS NULL OR @p_precio_venta <= 0
            THROW 52003, 'El precio de venta debe ser mayor a cero.', 1;

        IF EXISTS (
            SELECT 1
            FROM precio
            WHERE fk_producto = @p_producto
              AND aplicacion = @p_aplicacion
              AND inicio_vigencia = @p_inicio_vigencia
              AND estado = 'A'
        )
            THROW 52004, 'Ya existe un precio activo para ese producto, aplicación y fecha de inicio.', 1;

        IF @p_cerrar_vigentes = 1
        BEGIN
            UPDATE precio
            SET
                fin_vigencia = DATEADD(DAY, -1, @p_inicio_vigencia),
                estado = 'I'
            WHERE fk_producto = @p_producto
              AND aplicacion = @p_aplicacion
              AND estado = 'A'
              AND inicio_vigencia <= @p_inicio_vigencia
              AND (fin_vigencia IS NULL OR fin_vigencia >= @p_inicio_vigencia);
        END

        INSERT INTO precio
            (fk_producto, aplicacion, precio_venta, inicio_vigencia, fin_vigencia, estado, creado_por)
        VALUES
            (@p_producto, @p_aplicacion, @p_precio_venta, @p_inicio_vigencia, NULL, 'A', @p_usuario);

        SET @p_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_actualizar_precio
    @p_id              INT,
    @p_aplicacion      NVARCHAR(50),
    @p_precio_venta    DECIMAL(18,4),
    @p_inicio_vigencia DATE,
    @p_fin_vigencia    DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM precio WHERE id = @p_id)
        THROW 52100, 'Precio no encontrado.', 1;

    IF @p_aplicacion IS NULL OR LTRIM(RTRIM(@p_aplicacion)) = ''
        THROW 52101, 'La aplicación del precio es requerida.', 1;

    IF @p_precio_venta IS NULL OR @p_precio_venta <= 0
        THROW 52102, 'El precio de venta debe ser mayor a cero.', 1;

    IF @p_inicio_vigencia IS NULL
        THROW 52103, 'La fecha de inicio de vigencia es requerida.', 1;

    IF @p_fin_vigencia IS NOT NULL AND @p_fin_vigencia < @p_inicio_vigencia
        THROW 52104, 'La fecha fin no puede ser menor que la fecha de inicio.', 1;

    UPDATE precio
    SET
        aplicacion = @p_aplicacion,
        precio_venta = @p_precio_venta,
        inicio_vigencia = @p_inicio_vigencia,
        fin_vigencia = @p_fin_vigencia
    WHERE id = @p_id;
END;
GO

CREATE OR ALTER PROCEDURE sp_cambiar_estado_precio
    @p_id     INT,
    @p_estado CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_estado NOT IN ('A','I')
        THROW 52200, 'Estado inválido. Use A o I.', 1;

    IF NOT EXISTS (SELECT 1 FROM precio WHERE id = @p_id)
        THROW 52201, 'Precio no encontrado.', 1;

    UPDATE precio
    SET estado = @p_estado
    WHERE id = @p_id;
END;
GO

CREATE OR ALTER PROCEDURE sp_precio_vigente
    @p_producto   INT,
    @p_aplicacion NVARCHAR(50) = NULL,
    @p_fecha      DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);

    SELECT TOP 1
        pr.id,
        pr.fk_producto,
        p.nombre AS producto,
        pr.precio_venta,
        pr.aplicacion,
        pr.inicio_vigencia,
        pr.fin_vigencia,
        pr.estado,
        pr.creado_por,
        pr.creado_en
    FROM precio pr
    JOIN producto p ON p.codigo = pr.fk_producto
    WHERE pr.fk_producto = @p_producto
      AND pr.estado = 'A'
      AND pr.inicio_vigencia <= @p_fecha
      AND (pr.fin_vigencia IS NULL OR pr.fin_vigencia >= @p_fecha)
      AND (@p_aplicacion IS NULL OR pr.aplicacion = @p_aplicacion)
    ORDER BY pr.inicio_vigencia DESC, pr.id DESC;
END;
GO

CREATE OR ALTER PROCEDURE sp_listar_productos_precio
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.codigo,
        p.nombre,
        p.descripcion,
        p.stock_actual,
        md.descripcion AS medida
    FROM producto p
    LEFT JOIN medida md ON md.codigo = p.fk_medida
    WHERE p.estado = 'A'
    ORDER BY p.nombre;
END;
GO

-- Compatibilidad con el módulo Producto existente.
CREATE OR ALTER PROCEDURE sp_asignar_precio_producto
    @p_producto        INT,
    @p_precio_venta    DECIMAL(18,4),
    @p_aplicacion      NVARCHAR(50) = 'MINORISTA',
    @p_inicio_vigencia DATE = NULL,
    @p_usuario         INT,
    @p_id              INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC sp_crear_precio
        @p_producto = @p_producto,
        @p_aplicacion = @p_aplicacion,
        @p_precio_venta = @p_precio_venta,
        @p_inicio_vigencia = @p_inicio_vigencia,
        @p_cerrar_vigentes = 1,
        @p_usuario = @p_usuario,
        @p_id = @p_id OUTPUT;
END;
GO

PRINT 'sp_cxc_precio_tellix.sql ejecutado correctamente.';
GO
