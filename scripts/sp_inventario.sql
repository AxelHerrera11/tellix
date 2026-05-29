-- ============================================================
--  TELLIX — Stored Procedures módulo INVENTARIO
--  Ejecutar en TellixDB
-- ============================================================

USE TellixDB;
GO

-- ── sp_listar_stock ────────────────────────────────────────────
-- Listado de productos con nivel de stock (paginado, con filtros)
CREATE OR ALTER PROCEDURE sp_listar_stock
    @p_busqueda  NVARCHAR(200) = NULL,
    @p_categoria INT           = NULL,
    @p_estado    CHAR(1)       = 'A',
    @p_critico   BIT           = 0,
    @p_pagina    INT           = 1,
    @p_tamano    INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    SELECT COUNT(*) AS total
    FROM producto p
    WHERE p.estado = @p_estado
      AND (@p_busqueda  IS NULL OR p.nombre        LIKE '%' + @p_busqueda + '%')
      AND (@p_categoria IS NULL OR p.fk_categoria   = @p_categoria)
      AND (@p_critico   = 0     OR p.stock_actual  < p.stock_minimo);

    SELECT
        p.codigo,
        p.nombre,
        c.descripcion     AS categoria,
        m.nombre          AS marca,
        md.codigo         AS medida_codigo,
        md.descripcion    AS medida,
        p.stock_actual,
        p.stock_minimo,
        p.estado,
        CASE
            WHEN p.stock_actual <= 0                  THEN 'CRITICO'
            WHEN p.stock_actual <  p.stock_minimo     THEN 'BAJO'
            WHEN p.stock_actual <= p.stock_minimo * 2 THEN 'MEDIO'
            ELSE 'OK'
        END AS nivel_stock
    FROM producto p
    LEFT JOIN categoria c  ON c.codigo = p.fk_categoria
    LEFT JOIN marca     m  ON m.codigo = p.fk_marca
    LEFT JOIN medida    md ON md.codigo = p.fk_medida
    WHERE p.estado = @p_estado
      AND (@p_busqueda  IS NULL OR p.nombre        LIKE '%' + @p_busqueda + '%')
      AND (@p_categoria IS NULL OR p.fk_categoria   = @p_categoria)
      AND (@p_critico   = 0     OR p.stock_actual  < p.stock_minimo)
    ORDER BY
        CASE
            WHEN p.stock_actual <= 0                  THEN 0
            WHEN p.stock_actual <  p.stock_minimo     THEN 1
            WHEN p.stock_actual <= p.stock_minimo * 2 THEN 2
            ELSE 3
        END,
        p.nombre
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

-- ── sp_listar_movimientos ─────────────────────────────────────
-- Historial paginado de movimientos de inventario
CREATE OR ALTER PROCEDURE sp_listar_movimientos
    @p_producto   INT           = NULL,
    @p_operacion  NVARCHAR(50)  = NULL,
    @p_fecha_desde DATE         = NULL,
    @p_fecha_hasta DATE         = NULL,
    @p_pagina     INT           = 1,
    @p_tamano     INT           = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@p_pagina - 1) * @p_tamano;

    SELECT COUNT(*) AS total
    FROM movimiento_inventario m
    JOIN producto p ON p.codigo = m.fk_producto
    WHERE (@p_producto    IS NULL OR m.fk_producto    = @p_producto)
      AND (@p_operacion   IS NULL OR m.operacion      = @p_operacion)
      AND (@p_fecha_desde IS NULL OR m.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR m.fecha_operacion <  DATEADD(DAY, 1, @p_fecha_hasta));

    SELECT
        m.id,
        m.fk_producto,
        p.nombre            AS producto,
        md.codigo           AS medida_codigo,
        md.descripcion      AS medida,
        m.cantidad,
        CASE WHEN m.cantidad > 0 THEN 'ENTRADA' ELSE 'SALIDA' END AS tipo_movimiento,
        m.operacion,
        m.motivo,
        m.tipo_documento,
        m.no_documento,
        m.fk_usuario,
        u.user_name         AS usuario,
        m.fecha_operacion
    FROM movimiento_inventario m
    JOIN producto p  ON p.codigo  = m.fk_producto
    LEFT JOIN medida md ON md.codigo = p.fk_medida
    LEFT JOIN usuario u ON u.codigo = m.fk_usuario
    WHERE (@p_producto    IS NULL OR m.fk_producto    = @p_producto)
      AND (@p_operacion   IS NULL OR m.operacion      = @p_operacion)
      AND (@p_fecha_desde IS NULL OR m.fecha_operacion >= @p_fecha_desde)
      AND (@p_fecha_hasta IS NULL OR m.fecha_operacion <  DATEADD(DAY, 1, @p_fecha_hasta))
    ORDER BY m.fecha_operacion DESC, m.id DESC
    OFFSET @offset ROWS FETCH NEXT @p_tamano ROWS ONLY;
END;
GO

PRINT 'sp_inventario.sql ejecutado correctamente.';
GO
