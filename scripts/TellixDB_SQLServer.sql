-- ============================================================
--  TELLIX DB — SQL Server Migration
--  Versión: 2.0
--  Motor:   SQL Server 2019+
--  Autor:   Migración desde Oracle (revisada y optimizada)
-- ============================================================

-- ============================================================
-- 0. BASE DE DATOS Y CONFIGURACIÓN
-- ============================================================
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TellixDB')
    CREATE DATABASE TellixDB
        COLLATE Modern_Spanish_CI_AI;   -- soporte completo de español
GO

USE TellixDB;
GO

-- ============================================================
-- 1. CATÁLOGOS / TABLAS MAESTRAS
-- ============================================================

-- Categoría de productos
CREATE TABLE categoria (
    codigo      INT             NOT NULL IDENTITY(1,1),
    descripcion NVARCHAR(200),
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_categoria PRIMARY KEY (codigo)
);
GO

-- Marcas
CREATE TABLE marca (
    codigo      INT             NOT NULL IDENTITY(1,1),
    nombre      NVARCHAR(100)   NOT NULL,
    descripcion NVARCHAR(200),
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_marca PRIMARY KEY (codigo),
    CONSTRAINT uq_marca_nombre UNIQUE (nombre)
);
GO

-- Unidades de medida
CREATE TABLE medida (
    codigo      NVARCHAR(50)    NOT NULL,   -- Ej: KG, LT, UND
    descripcion NVARCHAR(200),
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_medida PRIMARY KEY (codigo)
);
GO

-- Tipos de contacto (Teléfono, Email, WhatsApp…)
CREATE TABLE tipo_contacto (
    codigo      INT             NOT NULL IDENTITY(1,1),
    descripcion NVARCHAR(100)   NOT NULL,
    CONSTRAINT pk_tipo_contacto PRIMARY KEY (codigo)
);
GO

-- Tipos de cliente (Mayorista, Minorista, VIP…)
CREATE TABLE tipo_cliente (
    codigo      INT             NOT NULL IDENTITY(1,1),
    descripcion NVARCHAR(100)   NOT NULL,
    CONSTRAINT pk_tipo_cliente PRIMARY KEY (codigo)
);
GO

-- Bancos
CREATE TABLE banco (
    codigo      INT             NOT NULL IDENTITY(1,1),
    nombre      NVARCHAR(100)   NOT NULL,
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_banco PRIMARY KEY (codigo)
);
GO

-- Tipos de cuenta bancaria
CREATE TABLE tipo_cuenta (
    codigo      NVARCHAR(50)    NOT NULL,   -- Ej: MON, AHO
    descripcion NVARCHAR(200),
    CONSTRAINT pk_tipo_cuenta PRIMARY KEY (codigo)
);
GO

-- Métodos de liquidación / pago
CREATE TABLE metodo_liquidacion (
    codigo      INT             NOT NULL IDENTITY(1,1),
    descripcion NVARCHAR(200)   NOT NULL,
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_metodo_liquidacion PRIMARY KEY (codigo)
);
GO

-- Roles del sistema
CREATE TABLE rol (
    codigo      INT             NOT NULL IDENTITY(1,1),
    nombre      NVARCHAR(100)   NOT NULL,
    descripcion NVARCHAR(200),
    nivel       INT             NOT NULL DEFAULT 99,  -- menor = más privilegio
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_rol PRIMARY KEY (codigo),
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
);
GO

-- Opciones / módulos del sistema
CREATE TABLE opcion_sistema (
    codigo      INT             NOT NULL IDENTITY(1,1),
    descripcion NVARCHAR(200)   NOT NULL,
    ruta        NVARCHAR(200),              -- ruta frontend (ej: /inventario)
    icono       NVARCHAR(100),
    padre       INT,                        -- jerarquía de menú
    orden       INT             NOT NULL DEFAULT 0,
    activo      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_opcion_sistema PRIMARY KEY (codigo),
    CONSTRAINT fk_opcion_padre FOREIGN KEY (padre) REFERENCES opcion_sistema(codigo)
);
GO

-- ============================================================
-- 2. ENTIDADES PRINCIPALES
-- ============================================================

-- Cuentas bancarias de la empresa
CREATE TABLE cuenta (
    numero      NVARCHAR(50)    NOT NULL,
    fk_banco    INT             NOT NULL,
    titular     NVARCHAR(200),
    fk_tipo     NVARCHAR(50)    NOT NULL,
    estado      CHAR(1)         NOT NULL DEFAULT 'A'
                    CHECK (estado IN ('A','I')),
    descripcion NVARCHAR(200),
    CONSTRAINT pk_cuenta PRIMARY KEY (numero),
    CONSTRAINT fk_cuenta_banco      FOREIGN KEY (fk_banco) REFERENCES banco(codigo),
    CONSTRAINT fk_cuenta_tipo       FOREIGN KEY (fk_tipo)  REFERENCES tipo_cuenta(codigo)
);
GO

-- Empleados (auto-referencia para jerarquía de jefes)
CREATE TABLE empleado (
    codigo                  INT             NOT NULL IDENTITY(1,1),
    documento_identificacion NVARCHAR(100),
    nombre_1                NVARCHAR(100)   NOT NULL,
    nombre_2                NVARCHAR(100),
    apellido_1              NVARCHAR(100)   NOT NULL,
    apellido_2              NVARCHAR(100),
    apellido_casada         NVARCHAR(100),
    estado                  CHAR(1)         NOT NULL DEFAULT 'A'
                                CHECK (estado IN ('A','I')),
    fk_jefe                 INT,            -- auto-referencia
    fecha_ingreso           DATE,
    -- Auditoría
    creado_en               DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_empleado      PRIMARY KEY (codigo),
    CONSTRAINT fk_empleado_jefe FOREIGN KEY (fk_jefe) REFERENCES empleado(codigo)
);
GO

-- Usuarios del sistema
CREATE TABLE usuario (
    codigo          INT             NOT NULL IDENTITY(1,1),
    fk_empleado     INT             NOT NULL,
    user_name       NVARCHAR(100)   NOT NULL,
    -- Contraseña: hash bcrypt/argon2 gestionado desde la app, NUNCA texto plano
    contrasena_hash NVARCHAR(256)   NOT NULL,
    fk_rol          INT             NOT NULL,
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    ultimo_acceso   DATETIME2,
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_usuario           PRIMARY KEY (codigo),
    CONSTRAINT uq_usuario_username  UNIQUE (user_name),
    CONSTRAINT fk_usuario_empleado  FOREIGN KEY (fk_empleado) REFERENCES empleado(codigo),
    CONSTRAINT fk_usuario_rol       FOREIGN KEY (fk_rol)      REFERENCES rol(codigo)
);
GO

-- Clientes
CREATE TABLE cliente (
    nit             NVARCHAR(50)    NOT NULL,
    codigo          INT             NOT NULL IDENTITY(1,1),
    nombre_1        NVARCHAR(100),
    nombre_2        NVARCHAR(100),
    nombre_3        NVARCHAR(100),
    apellido_1      NVARCHAR(100),
    apellido_2      NVARCHAR(100),
    apellido_casada NVARCHAR(100),
    fk_tipo_cliente INT,
    limite_credito  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    direccion       NVARCHAR(200),
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_cliente               PRIMARY KEY (nit),
    CONSTRAINT uq_cliente_codigo        UNIQUE (codigo),
    CONSTRAINT fk_cliente_tipo_cliente  FOREIGN KEY (fk_tipo_cliente) REFERENCES tipo_cliente(codigo)
);
GO

-- Contactos de clientes
CREATE TABLE contacto_cliente (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_cliente      NVARCHAR(50)    NOT NULL,
    fk_tipo         INT             NOT NULL,
    info_contacto   NVARCHAR(200)   NOT NULL,
    principal       BIT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_contacto_cliente  PRIMARY KEY (id),
    CONSTRAINT fk_cc_cliente        FOREIGN KEY (fk_cliente) REFERENCES cliente(nit),
    CONSTRAINT fk_cc_tipo           FOREIGN KEY (fk_tipo)    REFERENCES tipo_contacto(codigo)
);
GO

-- Proveedores
CREATE TABLE proveedor (
    nit             NVARCHAR(50)    NOT NULL,
    nombre          NVARCHAR(200)   NOT NULL,
    direccion_fiscal NVARCHAR(200),
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_proveedor PRIMARY KEY (nit)
);
GO

-- Representantes de proveedores
CREATE TABLE representante (
    nit             NVARCHAR(50)    NOT NULL,
    fk_proveedor    NVARCHAR(50)    NOT NULL,
    codigo          INT             NOT NULL IDENTITY(1,1),
    nombre_1        NVARCHAR(100)   NOT NULL,
    nombre_2        NVARCHAR(100),
    apellido_1      NVARCHAR(100)   NOT NULL,
    apellido_2      NVARCHAR(100),
    apellido_casada NVARCHAR(100),
    activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_representante         PRIMARY KEY (nit),
    CONSTRAINT uq_representante_codigo  UNIQUE (codigo),
    CONSTRAINT fk_rep_proveedor         FOREIGN KEY (fk_proveedor) REFERENCES proveedor(nit)
);
GO

-- Contactos de representantes
CREATE TABLE contacto_representante (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_representante NVARCHAR(50)  NOT NULL,
    fk_tipo         INT             NOT NULL,
    info_contacto   NVARCHAR(200)   NOT NULL,
    principal       BIT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_contacto_rep  PRIMARY KEY (id),
    CONSTRAINT fk_cr_rep        FOREIGN KEY (fk_representante) REFERENCES representante(nit),
    CONSTRAINT fk_cr_tipo       FOREIGN KEY (fk_tipo)          REFERENCES tipo_contacto(codigo)
);
GO

-- Contactos de empleados
CREATE TABLE contacto_empleado (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_empleado     INT             NOT NULL,
    fk_tipo         INT             NOT NULL,
    info_contacto   NVARCHAR(200)   NOT NULL,
    principal       BIT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_contacto_empleado PRIMARY KEY (id),
    CONSTRAINT fk_ce_empleado       FOREIGN KEY (fk_empleado) REFERENCES empleado(codigo),
    CONSTRAINT fk_ce_tipo           FOREIGN KEY (fk_tipo)     REFERENCES tipo_contacto(codigo)
);
GO

-- ============================================================
-- 3. CATÁLOGO DE PRODUCTOS
-- ============================================================

CREATE TABLE producto (
    codigo          INT             NOT NULL IDENTITY(1,1),
    nombre          NVARCHAR(200)   NOT NULL,
    descripcion     NVARCHAR(300),
    stock_minimo    DECIMAL(18,4)   NOT NULL DEFAULT 0,
    stock_actual    DECIMAL(18,4)   NOT NULL DEFAULT 0,
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    fk_categoria    INT,
    fk_marca        INT,
    fk_medida       NVARCHAR(50),
    cantidad_medida DECIMAL(18,4),               -- factor de conversión
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_producto          PRIMARY KEY (codigo),
    CONSTRAINT fk_prod_categoria    FOREIGN KEY (fk_categoria) REFERENCES categoria(codigo),
    CONSTRAINT fk_prod_marca        FOREIGN KEY (fk_marca)     REFERENCES marca(codigo),
    CONSTRAINT fk_prod_medida       FOREIGN KEY (fk_medida)    REFERENCES medida(codigo)
);
GO

-- Impuestos
CREATE TABLE impuesto (
    codigo          INT             NOT NULL IDENTITY(1,1),
    descripcion     NVARCHAR(200)   NOT NULL,
    tipo_calculo    NVARCHAR(20)    NOT NULL    -- 'PORCENTAJE' | 'FIJO'
                        CHECK (tipo_calculo IN ('PORCENTAJE','FIJO')),
    valor           DECIMAL(18,4)   NOT NULL,
    activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_impuesto PRIMARY KEY (codigo)
);
GO

-- Descuentos
CREATE TABLE descuento (
    codigo          INT             NOT NULL IDENTITY(1,1),
    descripcion     NVARCHAR(200)   NOT NULL,
    tipo_calculo    NVARCHAR(20)    NOT NULL
                        CHECK (tipo_calculo IN ('PORCENTAJE','FIJO')),
    valor           DECIMAL(18,4)   NOT NULL,
    activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT pk_descuento PRIMARY KEY (codigo)
);
GO

-- Asignación de impuestos a productos (1 producto → N impuestos vigentes)
CREATE TABLE asignacion_impuesto (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_producto     INT             NOT NULL,
    fk_impuesto     INT             NOT NULL,
    valor_override  DECIMAL(18,4),              -- NULL = usa valor del impuesto
    aplicaciones    NVARCHAR(200),
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE,
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    CONSTRAINT pk_asig_impuesto     PRIMARY KEY (id),
    CONSTRAINT uq_prod_imp          UNIQUE (fk_producto, fk_impuesto, fecha_inicio),
    CONSTRAINT fk_ai_producto       FOREIGN KEY (fk_producto) REFERENCES producto(codigo),
    CONSTRAINT fk_ai_impuesto       FOREIGN KEY (fk_impuesto) REFERENCES impuesto(codigo)
);
GO

-- Asignación de descuentos a productos
CREATE TABLE asignacion_descuento (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_producto     INT             NOT NULL,
    fk_descuento    INT             NOT NULL,
    valor_override  DECIMAL(18,4),
    aplicaciones    NVARCHAR(200),
    fecha_inicio    DATE            NOT NULL,
    fecha_fin       DATE,
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    CONSTRAINT pk_asig_descuento    PRIMARY KEY (id),
    CONSTRAINT uq_prod_desc         UNIQUE (fk_producto, fk_descuento, fecha_inicio),
    CONSTRAINT fk_ad_producto       FOREIGN KEY (fk_producto)  REFERENCES producto(codigo),
    CONSTRAINT fk_ad_descuento      FOREIGN KEY (fk_descuento) REFERENCES descuento(codigo)
);
GO

-- Historial de precios (1 producto → N vigencias, sólo 1 activa a la vez)
-- CORREGIDO: en el original la PK era codigo_producto, lo que impedía el historial
CREATE TABLE precio (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_producto     INT             NOT NULL,
    aplicacion      NVARCHAR(50),               -- canal: 'MAYORISTA','MINORISTA'…
    precio_venta    DECIMAL(18,4)   NOT NULL,
    inicio_vigencia DATE            NOT NULL,
    fin_vigencia    DATE,
    estado          CHAR(1)         NOT NULL DEFAULT 'A'
                        CHECK (estado IN ('A','I')),
    creado_por      INT,                        -- FK usuario
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_precio        PRIMARY KEY (id),
    CONSTRAINT fk_precio_prod   FOREIGN KEY (fk_producto) REFERENCES producto(codigo),
    CONSTRAINT fk_precio_usr    FOREIGN KEY (creado_por)  REFERENCES usuario(codigo)
);
GO

-- ============================================================
-- 4. INVENTARIO
-- ============================================================

CREATE TABLE movimiento_inventario (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_producto     INT             NOT NULL,
    cantidad        DECIMAL(18,4)   NOT NULL,   -- positivo=entrada, negativo=salida
    motivo          NVARCHAR(200),
    operacion       NVARCHAR(50)    NOT NULL
                        CHECK (operacion IN ('ENTRADA','SALIDA','AJUSTE','DEVOLUCION')),
    fk_usuario      INT             NOT NULL,
    fecha_operacion DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    -- referencia opcional al documento origen
    tipo_documento  NVARCHAR(50),               -- 'COMPRA','VENTA','AJUSTE'
    no_documento    NVARCHAR(50),
    CONSTRAINT pk_mov_inv       PRIMARY KEY (id),
    CONSTRAINT fk_inv_producto  FOREIGN KEY (fk_producto) REFERENCES producto(codigo),
    CONSTRAINT fk_inv_usuario   FOREIGN KEY (fk_usuario)  REFERENCES usuario(codigo)
);
GO

-- ============================================================
-- 5. COMPRAS
-- ============================================================

CREATE TABLE compra (
    id              INT             NOT NULL IDENTITY(1,1),
    no_documento    NVARCHAR(50)    NOT NULL,   -- número de factura del proveedor
    fk_proveedor    NVARCHAR(50)    NOT NULL,
    fk_representante NVARCHAR(50),
    fecha_operacion DATE            NOT NULL DEFAULT CAST(SYSDATETIME() AS DATE),
    hora_operacion  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    fk_usuario      INT             NOT NULL,
    fk_metodo_pago  INT             NOT NULL,
    plazo_credito   INT             NOT NULL DEFAULT 0,  -- en días
    estado          CHAR(1)         NOT NULL DEFAULT 'P'
                        CHECK (estado IN ('P','A','C','X')),  -- Pendiente/Aprobada/Completada/Cancelada
    subtotal        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total_descuentos DECIMAL(18,2)  NOT NULL DEFAULT 0,
    total_impuestos DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total           DECIMAL(18,2)   NOT NULL DEFAULT 0,
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_compra            PRIMARY KEY (id),
    CONSTRAINT uq_compra_documento  UNIQUE (no_documento, fk_proveedor),
    CONSTRAINT fk_compra_proveedor  FOREIGN KEY (fk_proveedor)      REFERENCES proveedor(nit),
    CONSTRAINT fk_compra_rep        FOREIGN KEY (fk_representante)  REFERENCES representante(nit),
    CONSTRAINT fk_compra_usuario    FOREIGN KEY (fk_usuario)        REFERENCES usuario(codigo),
    CONSTRAINT fk_compra_metodo     FOREIGN KEY (fk_metodo_pago)    REFERENCES metodo_liquidacion(codigo)
);
GO

CREATE TABLE detalle_compra (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_compra       INT             NOT NULL,
    fk_producto     INT             NOT NULL,
    cantidad        DECIMAL(18,4)   NOT NULL,
    precio_unitario DECIMAL(18,4)   NOT NULL,
    descuentos      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    impuestos       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    subtotal        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT pk_detalle_compra    PRIMARY KEY (id),
    CONSTRAINT fk_dc_compra         FOREIGN KEY (fk_compra)   REFERENCES compra(id),
    CONSTRAINT fk_dc_producto       FOREIGN KEY (fk_producto)  REFERENCES producto(codigo),
    CONSTRAINT ck_dc_cantidad       CHECK (cantidad > 0)
);
GO

-- ============================================================
-- 6. VENTAS
-- ============================================================

CREATE TABLE venta (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_cliente      NVARCHAR(50)    NOT NULL,
    fecha_operacion DATE            NOT NULL DEFAULT CAST(SYSDATETIME() AS DATE),
    hora_operacion  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    fk_usuario      INT             NOT NULL,
    fk_metodo_pago  INT             NOT NULL,
    plazo_credito   INT             NOT NULL DEFAULT 0,
    estado          CHAR(1)         NOT NULL DEFAULT 'P'
                        CHECK (estado IN ('P','A','C','X')),
    subtotal        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total_descuentos DECIMAL(18,2)  NOT NULL DEFAULT 0,
    total_impuestos DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total           DECIMAL(18,2)   NOT NULL DEFAULT 0,
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_venta             PRIMARY KEY (id),
    CONSTRAINT fk_venta_cliente     FOREIGN KEY (fk_cliente)    REFERENCES cliente(nit),
    CONSTRAINT fk_venta_usuario     FOREIGN KEY (fk_usuario)    REFERENCES usuario(codigo),
    CONSTRAINT fk_venta_metodo      FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_liquidacion(codigo)
);
GO

CREATE TABLE detalle_venta (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_venta        INT             NOT NULL,
    fk_producto     INT             NOT NULL,
    cantidad        DECIMAL(18,4)   NOT NULL,
    precio_unitario DECIMAL(18,4)   NOT NULL,
    descuentos      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    impuestos       DECIMAL(18,2)   NOT NULL DEFAULT 0,
    subtotal        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    CONSTRAINT pk_detalle_venta     PRIMARY KEY (id),
    CONSTRAINT fk_dv_venta          FOREIGN KEY (fk_venta)     REFERENCES venta(id),
    CONSTRAINT fk_dv_producto       FOREIGN KEY (fk_producto)   REFERENCES producto(codigo),
    CONSTRAINT ck_dv_cantidad       CHECK (cantidad > 0)
);
GO

-- ============================================================
-- 7. CUENTAS POR PAGAR / COBRAR
-- ============================================================

CREATE TABLE cuenta_por_pagar (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_compra       INT             NOT NULL,
    estado          CHAR(1)         NOT NULL DEFAULT 'P'
                        CHECK (estado IN ('P','A','X')),  -- Pendiente/Abonada/Cancelada
    fk_metodo_pago  INT             NOT NULL,
    valor_total     DECIMAL(18,2)   NOT NULL,
    valor_pagado    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    fecha_limite    DATE            NOT NULL,
    fk_cuenta       NVARCHAR(50),
    fk_banco        INT,
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_cxp               PRIMARY KEY (id),
    CONSTRAINT fk_cxp_compra        FOREIGN KEY (fk_compra)     REFERENCES compra(id),
    CONSTRAINT fk_cxp_metodo        FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_liquidacion(codigo),
    CONSTRAINT fk_cxp_cuenta        FOREIGN KEY (fk_cuenta)     REFERENCES cuenta(numero),
    CONSTRAINT fk_cxp_banco         FOREIGN KEY (fk_banco)      REFERENCES banco(codigo)
);
GO

CREATE TABLE cuenta_por_cobrar (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_venta        INT             NOT NULL,
    fk_cliente      NVARCHAR(50)    NOT NULL,
    estado          CHAR(1)         NOT NULL DEFAULT 'P'
                        CHECK (estado IN ('P','A','X')),
    fk_metodo_pago  INT             NOT NULL,
    valor_total     DECIMAL(18,2)   NOT NULL,
    valor_cobrado   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    fecha_limite    DATE            NOT NULL,
    fk_cuenta       NVARCHAR(50),
    -- Auditoría
    creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    actualizado_en  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT pk_cxc               PRIMARY KEY (id),
    CONSTRAINT fk_cxc_venta         FOREIGN KEY (fk_venta)      REFERENCES venta(id),
    CONSTRAINT fk_cxc_cliente       FOREIGN KEY (fk_cliente)    REFERENCES cliente(nit),
    CONSTRAINT fk_cxc_metodo        FOREIGN KEY (fk_metodo_pago) REFERENCES metodo_liquidacion(codigo),
    CONSTRAINT fk_cxc_cuenta        FOREIGN KEY (fk_cuenta)     REFERENCES cuenta(numero)
);
GO

-- ============================================================
-- 8. MOVIMIENTOS DE CUENTA BANCARIA
-- ============================================================

CREATE TABLE movimiento_cuenta (
    id              INT             NOT NULL IDENTITY(1,1),
    fk_cuenta       NVARCHAR(50)    NOT NULL,
    tipo_documento  NVARCHAR(50),
    no_documento    NVARCHAR(50),
    fecha_operacion DATE            NOT NULL DEFAULT CAST(SYSDATETIME() AS DATE),
    monto           DECIMAL(18,2)   NOT NULL,   -- positivo=crédito, negativo=débito
    descripcion     NVARCHAR(400),
    fk_usuario      INT             NOT NULL,
    CONSTRAINT pk_movimiento_cuenta PRIMARY KEY (id),
    CONSTRAINT fk_mc_cuenta         FOREIGN KEY (fk_cuenta)   REFERENCES cuenta(numero),
    CONSTRAINT fk_mc_usuario        FOREIGN KEY (fk_usuario)  REFERENCES usuario(codigo)
);
GO

-- ============================================================
-- 9. SEGURIDAD — ACCESOS POR ROL
-- ============================================================

CREATE TABLE asignacion_acceso (
    fk_rol          INT             NOT NULL,
    fk_opcion       INT             NOT NULL,
    puede_ver       BIT             NOT NULL DEFAULT 0,
    puede_crear     BIT             NOT NULL DEFAULT 0,
    puede_editar    BIT             NOT NULL DEFAULT 0,
    puede_eliminar  BIT             NOT NULL DEFAULT 0,
    CONSTRAINT pk_asig_acceso   PRIMARY KEY (fk_rol, fk_opcion),
    CONSTRAINT fk_aa_rol        FOREIGN KEY (fk_rol)   REFERENCES rol(codigo),
    CONSTRAINT fk_aa_opcion     FOREIGN KEY (fk_opcion) REFERENCES opcion_sistema(codigo)
);
GO

-- ============================================================
-- 10. ÍNDICES DE RENDIMIENTO
-- ============================================================

-- Producto
CREATE INDEX ix_producto_categoria    ON producto (fk_categoria);
CREATE INDEX ix_producto_marca        ON producto (fk_marca);
CREATE INDEX ix_producto_nombre       ON producto (nombre);
CREATE INDEX ix_producto_estado       ON producto (estado);

-- Precio activo por producto
CREATE INDEX ix_precio_producto_estado ON precio (fk_producto, estado, inicio_vigencia);

-- Movimiento de inventario
CREATE INDEX ix_inv_producto_fecha    ON movimiento_inventario (fk_producto, fecha_operacion);

-- Ventas
CREATE INDEX ix_venta_cliente_fecha   ON venta (fk_cliente, fecha_operacion);
CREATE INDEX ix_venta_estado          ON venta (estado);
CREATE INDEX ix_detalle_venta_prod    ON detalle_venta (fk_producto);

-- Compras
CREATE INDEX ix_compra_proveedor_fecha ON compra (fk_proveedor, fecha_operacion);
CREATE INDEX ix_compra_estado         ON compra (estado);
CREATE INDEX ix_detalle_compra_prod   ON detalle_compra (fk_producto);

-- CXC / CXP
CREATE INDEX ix_cxc_cliente_estado    ON cuenta_por_cobrar (fk_cliente, estado);
CREATE INDEX ix_cxp_compra_estado     ON cuenta_por_pagar (fk_compra, estado);

-- Usuario
CREATE INDEX ix_usuario_username      ON usuario (user_name);
GO

-- ============================================================
-- 11. PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- ── 11.1 Obtener precio vigente de un producto ──────────────
CREATE OR ALTER PROCEDURE sp_precio_vigente
    @p_producto     INT,
    @p_aplicacion   NVARCHAR(50) = NULL,
    @p_fecha        DATE = NULL
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
    WHERE fk_producto   = @p_producto
      AND estado        = 'A'
      AND inicio_vigencia <= @p_fecha
      AND (fin_vigencia IS NULL OR fin_vigencia >= @p_fecha)
      AND (@p_aplicacion IS NULL OR aplicacion = @p_aplicacion)
    ORDER BY inicio_vigencia DESC;
END;
GO

-- ── 11.2 Registrar una venta completa (transaccional) ───────
CREATE OR ALTER PROCEDURE sp_registrar_venta
    @p_cliente      NVARCHAR(50),
    @p_usuario      INT,
    @p_metodo_pago  INT,
    @p_plazo        INT,
    @p_items        NVARCHAR(MAX),  -- JSON: [{fk_producto,cantidad,precio_unitario,descuentos,impuestos}]
    @p_venta_id     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar cabecera
        INSERT INTO venta (fk_cliente, fk_usuario, fk_metodo_pago, plazo_credito, estado)
        VALUES (@p_cliente, @p_usuario, @p_metodo_pago, @p_plazo, 'P');

        SET @p_venta_id = SCOPE_IDENTITY();

        -- Parsear items desde JSON (SQL Server 2016+)
        INSERT INTO detalle_venta (fk_venta, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
        SELECT
            @p_venta_id,
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

        -- Recalcular totales en cabecera
        UPDATE v SET
            subtotal         = d.sub,
            total_descuentos = d.desc_total,
            total_impuestos  = d.imp_total,
            total            = d.sub - d.desc_total + d.imp_total,
            actualizado_en   = SYSDATETIME()
        FROM venta v
        CROSS JOIN (
            SELECT
                SUM(cantidad * precio_unitario) AS sub,
                SUM(descuentos)                 AS desc_total,
                SUM(impuestos)                  AS imp_total
            FROM detalle_venta WHERE fk_venta = @p_venta_id
        ) d
        WHERE v.id = @p_venta_id;

        -- Descontar inventario
        INSERT INTO movimiento_inventario
            (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            -cantidad,
            'Venta #' + CAST(@p_venta_id AS NVARCHAR),
            'SALIDA',
            @p_usuario,
            'VENTA',
            CAST(@p_venta_id AS NVARCHAR)
        FROM detalle_venta WHERE fk_venta = @p_venta_id;

        -- Actualizar stock en tabla producto
        UPDATE p SET
            stock_actual   = p.stock_actual - d.total_qty,
            actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_venta WHERE fk_venta = @p_venta_id
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── 11.3 Registrar compra completa (transaccional) ──────────
CREATE OR ALTER PROCEDURE sp_registrar_compra
    @p_no_documento     NVARCHAR(50),
    @p_proveedor        NVARCHAR(50),
    @p_representante    NVARCHAR(50) = NULL,
    @p_usuario          INT,
    @p_metodo_pago      INT,
    @p_plazo            INT,
    @p_items            NVARCHAR(MAX),  -- JSON igual que venta
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

        INSERT INTO detalle_compra (fk_compra, fk_producto, cantidad, precio_unitario, descuentos, impuestos, subtotal)
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
            FROM detalle_compra WHERE fk_compra = @p_compra_id
        ) d
        WHERE c.id = @p_compra_id;

        -- Sumar inventario
        INSERT INTO movimiento_inventario
            (fk_producto, cantidad, motivo, operacion, fk_usuario, tipo_documento, no_documento)
        SELECT
            fk_producto,
            cantidad,
            'Compra #' + CAST(@p_compra_id AS NVARCHAR),
            'ENTRADA',
            @p_usuario,
            'COMPRA',
            CAST(@p_compra_id AS NVARCHAR)
        FROM detalle_compra WHERE fk_compra = @p_compra_id;

        UPDATE p SET
            stock_actual   = p.stock_actual + d.total_qty,
            actualizado_en = SYSDATETIME()
        FROM producto p
        JOIN (
            SELECT fk_producto, SUM(cantidad) AS total_qty
            FROM detalle_compra WHERE fk_compra = @p_compra_id
            GROUP BY fk_producto
        ) d ON p.codigo = d.fk_producto;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── 11.4 Ajuste manual de inventario ────────────────────────
CREATE OR ALTER PROCEDURE sp_ajuste_inventario
    @p_producto     INT,
    @p_cantidad     DECIMAL(18,4),   -- positivo o negativo
    @p_motivo       NVARCHAR(200),
    @p_usuario      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO movimiento_inventario
            (fk_producto, cantidad, motivo, operacion, fk_usuario)
        VALUES
            (@p_producto, @p_cantidad, @p_motivo, 'AJUSTE', @p_usuario);

        UPDATE producto SET
            stock_actual   = stock_actual + @p_cantidad,
            actualizado_en = SYSDATETIME()
        WHERE codigo = @p_producto;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ── 11.5 Verificar usuario (login — devuelve datos sin hash) ─
CREATE OR ALTER PROCEDURE sp_login
    @p_username     NVARCHAR(100),
    @p_hash         NVARCHAR(256)   -- la app envía el hash ya calculado
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.codigo,
        u.user_name,
        u.fk_rol,
        r.nombre        AS rol_nombre,
        r.nivel         AS rol_nivel,
        e.nombre_1 + ' ' + e.apellido_1 AS nombre_empleado
    FROM usuario u
    JOIN rol      r ON r.codigo  = u.fk_rol
    JOIN empleado e ON e.codigo  = u.fk_empleado
    WHERE u.user_name       = @p_username
      AND u.contrasena_hash = @p_hash
      AND u.estado          = 'A';

    -- Actualizar último acceso si encontró resultado
    IF @@ROWCOUNT > 0
        UPDATE usuario SET ultimo_acceso = SYSDATETIME() WHERE user_name = @p_username;
END;
GO

-- ── 11.6 Reporte: stock bajo mínimo ─────────────────────────
CREATE OR ALTER PROCEDURE sp_reporte_stock_critico
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.codigo,
        p.nombre,
        c.descripcion   AS categoria,
        m.nombre        AS marca,
        p.stock_actual,
        p.stock_minimo,
        p.stock_minimo - p.stock_actual AS faltante
    FROM producto p
    LEFT JOIN categoria c ON c.codigo = p.fk_categoria
    LEFT JOIN marca     m ON m.codigo = p.fk_marca
    WHERE p.stock_actual < p.stock_minimo
      AND p.estado = 'A'
    ORDER BY faltante DESC;
END;
GO

-- ── 11.7 Reporte: CXC vencidas ───────────────────────────────
CREATE OR ALTER PROCEDURE sp_reporte_cxc_vencidas
    @p_fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @p_fecha IS NULL SET @p_fecha = CAST(SYSDATETIME() AS DATE);

    SELECT
        cxc.id,
        cxc.fk_venta,
        cl.nombre_1 + ' ' + cl.apellido_1 AS cliente,
        cxc.valor_total,
        cxc.valor_cobrado,
        cxc.valor_total - cxc.valor_cobrado AS saldo,
        cxc.fecha_limite,
        DATEDIFF(DAY, cxc.fecha_limite, @p_fecha) AS dias_vencida
    FROM cuenta_por_cobrar cxc
    JOIN cliente cl ON cl.nit = cxc.fk_cliente
    WHERE cxc.estado   <> 'X'
      AND cxc.fecha_limite < @p_fecha
      AND cxc.valor_total > cxc.valor_cobrado
    ORDER BY dias_vencida DESC;
END;
GO

-- ============================================================
-- 12. USUARIOS DE BASE DE DATOS Y PERMISOS
-- ============================================================

-- Usuario de aplicación (mínimos privilegios)
-- Ejecutar sólo si el login no existe aún
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'tellix_app')
BEGIN
    CREATE LOGIN tellix_app WITH PASSWORD = 'C4mbi4M3!Pr0nt0',
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = ON;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tellix_app')
BEGIN
    CREATE USER tellix_app FOR LOGIN tellix_app;
END;
GO

-- Permisos mínimos: SELECT, INSERT, UPDATE, DELETE en tablas; EXEC en SP
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO tellix_app;
GRANT EXECUTE ON SCHEMA::dbo TO tellix_app;
DENY ALTER ON SCHEMA::dbo TO tellix_app;
GO

-- Usuario de sólo lectura para reportes / BI
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'tellix_reportes')
BEGIN
    CREATE LOGIN tellix_reportes WITH PASSWORD = 'R3p0rt3sS0l0!',
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = ON;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tellix_reportes')
BEGIN
    CREATE USER tellix_reportes FOR LOGIN tellix_reportes;
END;
GO
GRANT SELECT ON SCHEMA::dbo TO tellix_reportes;
GO

-- Usuario DBA
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'tellix_dba')
BEGIN
    CREATE LOGIN tellix_dba WITH PASSWORD = 'Db4Adm!nStr0ng',
        CHECK_EXPIRATION = ON,
        CHECK_POLICY = ON;
END;
GO
ALTER SERVER ROLE sysadmin ADD MEMBER tellix_dba;
GO

-- ============================================================
-- 13. BACKUP — JOB SQL Server Agent (T-SQL script de ejemplo)
-- ============================================================
-- NOTA: Ejecutar como sysadmin. Adaptar rutas al servidor real.
-- Se recomienda complementar con SQL Server Maintenance Plans
-- o Ola Hallengren's Maintenance Solution.

/*
-- Full backup: cada domingo 01:00
EXEC msdb.dbo.sp_add_job @job_name = N'TellixDB - Full Backup';
EXEC msdb.dbo.sp_add_jobstep
    @job_name  = N'TellixDB - Full Backup',
    @step_name = N'Backup',
    @command   = N'BACKUP DATABASE TellixDB
                   TO DISK = N''D:\Backups\TellixDB_Full_'' + REPLACE(CONVERT(NVARCHAR,GETDATE(),112),'''','''') + ''.bak''
                   WITH COMPRESSION, STATS = 10;';
EXEC msdb.dbo.sp_add_schedule @schedule_name=N'Weekly Sunday 01:00',
    @freq_type=8, @freq_interval=1, @active_start_time=10000;
EXEC msdb.dbo.sp_attach_schedule @job_name=N'TellixDB - Full Backup',
    @schedule_name=N'Weekly Sunday 01:00';
EXEC msdb.dbo.sp_add_jobserver @job_name=N'TellixDB - Full Backup';

-- Diferencial: lunes a sábado 01:00
-- Log backup: cada 4 horas (si modelo de recuperación = FULL)
*/

-- ============================================================
-- 14. TRIGGER: actualizar actualizado_en automáticamente
-- ============================================================

CREATE OR ALTER TRIGGER tr_producto_audit ON producto
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE producto SET actualizado_en = SYSDATETIME()
    WHERE codigo IN (SELECT codigo FROM inserted);
END;
GO

CREATE OR ALTER TRIGGER tr_venta_audit ON venta
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE venta SET actualizado_en = SYSDATETIME()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

CREATE OR ALTER TRIGGER tr_compra_audit ON compra
AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE compra SET actualizado_en = SYSDATETIME()
    WHERE id IN (SELECT id FROM inserted);
END;
GO

-- ============================================================
-- FIN DEL SCRIPT TellixDB_SQLServer.sql
-- ============================================================
