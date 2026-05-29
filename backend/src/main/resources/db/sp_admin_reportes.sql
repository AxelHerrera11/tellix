USE TellixDB;
GO

/* ============================================================
   STORED PROCEDURES - ADMIN Y REPORTES
   Autor: Javier Fajardo / MacJavifa
   Módulos: Admin, Auditoría visual y Reportes
   ============================================================ */

-- ============================================================
-- ADMIN: LISTAR USUARIOS
-- ============================================================
CREATE OR ALTER PROCEDURE sp_admin_listar_usuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.codigo,
        u.user_name,
        e.codigo AS empleado_codigo,
        CONCAT(e.nombre_1, ' ', ISNULL(e.nombre_2, '')) AS nombres,
        CONCAT(e.apellido_1, ' ', ISNULL(e.apellido_2, '')) AS apellidos,
        r.codigo AS rol_codigo,
        r.nombre AS rol,
        u.estado,
        u.ultimo_acceso,
        u.creado_en
    FROM usuario u
    INNER JOIN empleado e ON u.fk_empleado = e.codigo
    INNER JOIN rol r ON u.fk_rol = r.codigo
    ORDER BY u.codigo;
END;
GO

-- ============================================================
-- ADMIN: LISTAR ROLES
-- ============================================================
CREATE OR ALTER PROCEDURE sp_admin_listar_roles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        codigo,
        nombre,
        descripcion,
        nivel,
        activo
    FROM rol
    ORDER BY nivel;
END;
GO

-- ============================================================
-- ADMIN: CREAR USUARIO
-- La contraseña llega hasheada desde Java.
-- ============================================================
CREATE OR ALTER PROCEDURE sp_admin_crear_usuario
    @documento_identificacion NVARCHAR(100),
    @nombre_1 NVARCHAR(100),
    @nombre_2 NVARCHAR(100) = NULL,
    @apellido_1 NVARCHAR(100),
    @apellido_2 NVARCHAR(100) = NULL,
    @user_name NVARCHAR(100),
    @contrasena_hash NVARCHAR(255),
    @fk_rol INT,
    @estado CHAR(1) = 'A',
    @id_usuario INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_empleado INT;

    INSERT INTO empleado (
        documento_identificacion,
        nombre_1,
        nombre_2,
        apellido_1,
        apellido_2,
        estado
    )
    VALUES (
        @documento_identificacion,
        @nombre_1,
        @nombre_2,
        @apellido_1,
        @apellido_2,
        'A'
    );

    SET @id_empleado = SCOPE_IDENTITY();

    INSERT INTO usuario (
        fk_empleado,
        user_name,
        contrasena_hash,
        fk_rol,
        estado
    )
    VALUES (
        @id_empleado,
        @user_name,
        @contrasena_hash,
        @fk_rol,
        @estado
    );

    SET @id_usuario = SCOPE_IDENTITY();
END;
GO

-- ============================================================
-- ADMIN: AUDITORÍA / ACTIVIDAD RECIENTE
-- No existe tabla de auditoría real.
-- Se construye con registros y movimientos existentes.
-- ============================================================
CREATE OR ALTER PROCEDURE sp_admin_listar_auditoria
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 100
        modulo,
        accion,
        descripcion,
        usuario,
        fecha
    FROM (
        SELECT
            'Usuarios' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se creó el usuario ', user_name) AS descripcion,
            user_name AS usuario,
            creado_en AS fecha
        FROM usuario
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Usuarios' AS modulo,
            'INICIO DE SESIÓN' AS accion,
            CONCAT('El usuario ', user_name, ' inició sesión') AS descripcion,
            user_name AS usuario,
            ultimo_acceso AS fecha
        FROM usuario
        WHERE ultimo_acceso IS NOT NULL

        UNION ALL

        SELECT
            'Empleados' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se creó el empleado ', nombre_1, ' ', apellido_1) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM empleado
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Productos' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se creó el producto ', nombre) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM producto
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Clientes' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se creó el cliente ', codigo) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM cliente
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Proveedores' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se creó el proveedor ', nombre) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM proveedor
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Ventas' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se registró la venta ', id) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM venta
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Compras' AS modulo,
            'CREACIÓN' AS accion,
            CONCAT('Se registró la compra ', id) AS descripcion,
            NULL AS usuario,
            creado_en AS fecha
        FROM compra
        WHERE creado_en IS NOT NULL

        UNION ALL

        SELECT
            'Inventario' AS modulo,
            operacion AS accion,
            CONCAT('Movimiento de inventario: ', motivo, ' - Documento: ', ISNULL(no_documento, 'N/A')) AS descripcion,
            u.user_name AS usuario,
            mi.fecha_operacion AS fecha
        FROM movimiento_inventario mi
        INNER JOIN usuario u ON mi.fk_usuario = u.codigo

        UNION ALL

        SELECT
            'Cuentas' AS modulo,
            'MOVIMIENTO' AS accion,
            CONCAT('Movimiento de cuenta ', fk_cuenta, ' por monto ', monto) AS descripcion,
            u.user_name AS usuario,
            mc.fecha_operacion AS fecha
        FROM movimiento_cuenta mc
        INNER JOIN usuario u ON mc.fk_usuario = u.codigo
    ) auditoria
    ORDER BY fecha DESC;
END;
GO

-- ============================================================
-- REPORTES: RESUMEN GENERAL
-- ============================================================
CREATE OR ALTER PROCEDURE sp_reporte_resumen_general
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM producto) AS total_productos,
        (SELECT COUNT(*) FROM cliente) AS total_clientes,
        (SELECT COUNT(*) FROM proveedor) AS total_proveedores,
        (SELECT COUNT(*) FROM venta) AS total_ventas,
        (SELECT COUNT(*) FROM compra) AS total_compras,

        (
            SELECT COUNT(*)
            FROM cuenta_por_cobrar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_cobrado, 0)
        ) AS cxc_pendientes,

        (
            SELECT COUNT(*)
            FROM cuenta_por_pagar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_pagado, 0)
        ) AS cxp_pendientes,

        (
            SELECT COALESCE(SUM(COALESCE(valor_total, 0) - COALESCE(valor_cobrado, 0)), 0)
            FROM cuenta_por_cobrar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_cobrado, 0)
        ) AS monto_cxc_pendiente,

        (
            SELECT COALESCE(SUM(COALESCE(valor_total, 0) - COALESCE(valor_pagado, 0)), 0)
            FROM cuenta_por_pagar
            WHERE COALESCE(valor_total, 0) > COALESCE(valor_pagado, 0)
        ) AS monto_cxp_pendiente;
END;
GO
