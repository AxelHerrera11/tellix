-- ============================================================
--  TELLIX — Script completo de base de datos
--  Crea la base de datos, tablas, índices, datos iniciales y
--  todos los procedimientos almacenados del sistema.
--  Ejecutar una sola vez en SQL Server Management Studio
--  o Azure Data Studio.
-- ============================================================

-- ── Crear base de datos ─────────────────────────────────────
IF DB_ID('TellixDB') IS NULL
BEGIN
    CREATE DATABASE TellixDB;
    PRINT 'Base de datos TellixDB creada.';
END
ELSE
    PRINT 'La base de datos TellixDB ya existe.';
GO

USE TellixDB;
GO

-- ════════════════════════════════════════════════════════════
--  1. TABLAS DE CATÁLOGO (sin dependencias externas)
-- ════════════════════════════════════════════════════════════

-- ── categoria ──────────────────────────────────────────────
IF OBJECT_ID('dbo.categoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.categoria (
        codigo      INT             IDENTITY(1,1) NOT NULL,
        descripcion NVARCHAR(200)   NOT NULL,
        activo      BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_categoria PRIMARY KEY (codigo)
    );
    PRINT 'Tabla categoria creada.';
END
GO

-- ── marca ──────────────────────────────────────────────────
IF OBJECT_ID('dbo.marca', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.marca (
        codigo      INT             IDENTITY(1,1) NOT NULL,
        nombre      NVARCHAR(200)   NOT NULL,
        descripcion NVARCHAR(300)   NULL,
        activo      BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_marca PRIMARY KEY (codigo)
    );
    PRINT 'Tabla marca creada.';
END
GO

-- ── medida ─────────────────────────────────────────────────
IF OBJECT_ID('dbo.medida', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.medida (
        codigo      NVARCHAR(50)    NOT NULL,
        descripcion NVARCHAR(200)   NOT NULL,
        activo      BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_medida PRIMARY KEY (codigo)
    );
    PRINT 'Tabla medida creada.';
END
GO

-- ── impuesto ───────────────────────────────────────────────
IF OBJECT_ID('dbo.impuesto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.impuesto (
        codigo      INT             IDENTITY(1,1) NOT NULL,
        descripcion NVARCHAR(200)   NOT NULL,
        tipo_calculo NVARCHAR(50)   NOT NULL DEFAULT 'PORCENTAJE',
        valor       DECIMAL(18,4)   NOT NULL DEFAULT 0,
        activo      BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_impuesto PRIMARY KEY (codigo)
    );
    PRINT 'Tabla impuesto creada.';
END
GO

-- ── descuento ──────────────────────────────────────────────
IF OBJECT_ID('dbo.descuento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.descuento (
        codigo      INT             IDENTITY(1,1) NOT NULL,
        descripcion NVARCHAR(200)   NOT NULL,
        tipo_calculo NVARCHAR(50)   NOT NULL DEFAULT 'PORCENTAJE',
        valor       DECIMAL(18,4)   NOT NULL DEFAULT 0,
        activo      BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_descuento PRIMARY KEY (codigo)
    );
    PRINT 'Tabla descuento creada.';
END
GO

-- ── metodo_liquidacion ─────────────────────────────────────
IF OBJECT_ID('dbo.metodo_liquidacion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.metodo_liquidacion (
        codigo       INT             IDENTITY(1,1) NOT NULL,
        nombre       NVARCHAR(100)   NOT NULL,
        descripcion  NVARCHAR(300)   NULL,
        dias_credito INT             NOT NULL DEFAULT 0,
        activo       BIT             NOT NULL DEFAULT 1,
        CONSTRAINT pk_metodo_liquidacion PRIMARY KEY (codigo)
    );
    PRINT 'Tabla metodo_liquidacion creada.';
END
GO

-- ════════════════════════════════════════════════════════════
--  2. TABLAS PRINCIPALES (dependen de catálogos)
-- ════════════════════════════════════════════════════════════

-- ── proveedor ──────────────────────────────────────────────
IF OBJECT_ID('dbo.proveedor', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.proveedor (
        nit         NVARCHAR(50)    NOT NULL,
        codigo      INT             IDENTITY(1,1) NOT NULL,
        nombre      NVARCHAR(200)   NOT NULL,
        direccion   NVARCHAR(300)   NULL,
        telefono    NVARCHAR(50)    NULL,
        email       NVARCHAR(200)   NULL,
        activo      BIT             NOT NULL DEFAULT 1,
        creado_en   DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        actualizado_en DATETIME2    NULL,
        CONSTRAINT pk_proveedor PRIMARY KEY (nit),
        CONSTRAINT uq_proveedor_codigo UNIQUE (codigo)
    );
    PRINT 'Tabla proveedor creada.';
END
GO

-- ── representante ──────────────────────────────────────────
IF OBJECT_ID('dbo.representante', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.representante (
        nit         NVARCHAR(50)    NOT NULL,
        codigo      INT             IDENTITY(1,1) NOT NULL,
        nombre      NVARCHAR(200)   NOT NULL,
        telefono    NVARCHAR(50)    NULL,
        email       NVARCHAR(200)   NULL,
        activo      BIT             NOT NULL DEFAULT 1,
        creado_en   DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        actualizado_en DATETIME2    NULL,
        CONSTRAINT pk_representante PRIMARY KEY (nit),
        CONSTRAINT uq_representante_codigo UNIQUE (codigo)
    );
    PRINT 'Tabla representante creada.';
END
GO

-- ── producto ───────────────────────────────────────────────
IF OBJECT_ID('dbo.producto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.producto (
        codigo          INT             IDENTITY(1,1) NOT NULL,
        nombre          NVARCHAR(200)   NOT NULL,
        descripcion     NVARCHAR(300)   NULL,
        stock_actual    DECIMAL(18,4)   NOT NULL DEFAULT 0,
        stock_minimo    DECIMAL(18,4)   NOT NULL DEFAULT 0,
        estado          CHAR(1)         NOT NULL DEFAULT 'A',
        fk_categoria    INT             NULL,
        fk_marca        INT             NULL,
        fk_medida       NVARCHAR(50)    NULL,
        cantidad_medida DECIMAL(18,4)   NULL,
        creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        actualizado_en  DATETIME2       NULL,
        CONSTRAINT pk_producto PRIMARY KEY (codigo),
        CONSTRAINT fk_producto_categoria FOREIGN KEY (fk_categoria) REFERENCES dbo.categoria(codigo),
        CONSTRAINT fk_producto_marca     FOREIGN KEY (fk_marca)     REFERENCES dbo.marca(codigo),
        CONSTRAINT fk_producto_medida    FOREIGN KEY (fk_medida)    REFERENCES dbo.medida(codigo),
        CONSTRAINT ck_producto_estado CHECK (estado IN ('A', 'I'))
    );
    PRINT 'Tabla producto creada.';
END
GO

-- ── usuario ────────────────────────────────────────────────
IF OBJECT_ID('dbo.usuario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.usuario (
        codigo           INT             IDENTITY(1,1) NOT NULL,
        user_name        NVARCHAR(50)    NOT NULL,
        contrasena_hash  NVARCHAR(256)   NOT NULL,
        nombre_empleado  NVARCHAR(200)   NOT NULL,
        email            NVARCHAR(200)   NULL,
        rol_nombre       NVARCHAR(50)    NOT NULL,
        rol_nivel        INT             NOT NULL DEFAULT 4,
        activo           BIT             NOT NULL DEFAULT 1,
        creado_en        DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        actualizado_en   DATETIME2       NULL,
        ultimo_acceso    DATETIME2       NULL,
        CONSTRAINT pk_usuario PRIMARY KEY (codigo),
        CONSTRAINT uq_usuario_user_name UNIQUE (user_name)
    );
    PRINT 'Tabla usuario creada.';
END
GO

-- ════════════════════════════════════════════════════════════
--  3. TABLAS DE TRANSACCIÓN (dependen de principales)
-- ════════════════════════════════════════════════════════════

-- ── precio ─────────────────────────────────────────────────
IF OBJECT_ID('dbo.precio', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.precio (
        id              INT             IDENTITY(1,1) NOT NULL,
        fk_producto     INT             NOT NULL,
        aplicacion      NVARCHAR(50)    NOT NULL DEFAULT 'MINORISTA',
        precio_venta    DECIMAL(18,4)   NOT NULL,
        inicio_vigencia DATE            NOT NULL,
        fin_vigencia    DATE            NULL,
        estado          CHAR(1)         NOT NULL DEFAULT 'A',
        creado_por      INT             NOT NULL,
        creado_en       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT pk_precio PRIMARY KEY (id),
        CONSTRAINT fk_precio_producto FOREIGN KEY (fk_producto) REFERENCES dbo.producto(codigo),
        CONSTRAINT fk_precio_usuario  FOREIGN KEY (creado_por)  REFERENCES dbo.usuario(codigo),
        CONSTRAINT ck_precio_estado CHECK (estado IN ('A', 'I'))
    );
    PRINT 'Tabla precio creada.';
END
GO

-- ── asignacion_impuesto ────────────────────────────────────
IF OBJECT_ID('dbo.asignacion_impuesto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.asignacion_impuesto (
        id              INT             IDENTITY(1,1) NOT NULL,
        fk_producto     INT             NOT NULL,
        fk_impuesto     INT             NOT NULL,
        valor_override  DECIMAL(18,4)   NULL,
        aplicaciones    NVARCHAR(200)   NULL,
        fecha_inicio    DATE            NOT NULL,
        fecha_fin       DATE            NULL,
        estado          CHAR(1)         NOT NULL DEFAULT 'A',
        CONSTRAINT pk_asignacion_impuesto PRIMARY KEY (id),
        CONSTRAINT fk_ai_producto FOREIGN KEY (fk_producto) REFERENCES dbo.producto(codigo),
        CONSTRAINT fk_ai_impuesto FOREIGN KEY (fk_impuesto) REFERENCES dbo.impuesto(codigo),
        CONSTRAINT ck_ai_estado CHECK (estado IN ('A', 'I'))
    );
    PRINT 'Tabla asignacion_impuesto creada.';
END
GO

-- ── asignacion_descuento ───────────────────────────────────
IF OBJECT_ID('dbo.asignacion_descuento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.asignacion_descuento (
        id              INT             IDENTITY(1,1) NOT NULL,
        fk_producto     INT             NOT NULL,
        fk_descuento    INT             NOT NULL,
        valor_override  DECIMAL(18,4)   NULL,
        aplicaciones    NVARCHAR(200)   NULL,
        fecha_inicio    DATE            NOT NULL,
        fecha_fin       DATE            NULL,
        estado          CHAR(1)         NOT NULL DEFAULT 'A',
        CONSTRAINT pk_asignacion_descuento PRIMARY KEY (id),
        CONSTRAINT fk_ad_producto  FOREIGN KEY (fk_producto)  REFERENCES dbo.producto(codigo),
        CONSTRAINT fk_ad_descuento FOREIGN KEY (fk_descuento) REFERENCES dbo.descuento(codigo),
        CONSTRAINT ck_ad_estado CHECK (estado IN ('A', 'I'))
    );
    PRINT 'Tabla asignacion_descuento creada.';
END
GO

-- ── compra ─────────────────────────────────────────────────
IF OBJECT_ID('dbo.compra', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.compra (
        id               INT             IDENTITY(1,1) NOT NULL,
        no_documento     NVARCHAR(50)    NOT NULL,
        fk_proveedor     NVARCHAR(50)    NOT NULL,
        fk_representante NVARCHAR(50)    NULL,
        fecha_operacion  DATE            NOT NULL,
        hora_operacion   DATETIME2       NULL,
        fk_usuario       INT             NOT NULL,
        fk_metodo_pago   INT             NOT NULL,
        plazo_credito    INT             NOT NULL DEFAULT 0,
        estado           CHAR(1)         NOT NULL DEFAULT 'P',
        subtotal         DECIMAL(18,2)   NOT NULL DEFAULT 0,
        total_descuentos DECIMAL(18,2)   NOT NULL DEFAULT 0,
        total_impuestos  DECIMAL(18,2)   NOT NULL DEFAULT 0,
        total            DECIMAL(18,2)   NOT NULL DEFAULT 0,
        creado_en        DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        actualizado_en   DATETIME2       NULL,
        CONSTRAINT pk_compra PRIMARY KEY (id),
        CONSTRAINT fk_compra_proveedor      FOREIGN KEY (fk_proveedor)     REFERENCES dbo.proveedor(nit),
        CONSTRAINT fk_compra_representante  FOREIGN KEY (fk_representante) REFERENCES dbo.representante(nit),
        CONSTRAINT fk_compra_usuario        FOREIGN KEY (fk_usuario)       REFERENCES dbo.usuario(codigo),
        CONSTRAINT fk_compra_metodo_pago    FOREIGN KEY (fk_metodo_pago)   REFERENCES dbo.metodo_liquidacion(codigo),
        CONSTRAINT ck_compra_estado CHECK (estado IN ('P', 'A', 'C', 'X'))
    );
    PRINT 'Tabla compra creada.';
END
GO

-- ── detalle_compra ─────────────────────────────────────────
IF OBJECT_ID('dbo.detalle_compra', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.detalle_compra (
        id              INT             IDENTITY(1,1) NOT NULL,
        fk_compra       INT             NOT NULL,
        fk_producto     INT             NOT NULL,
        cantidad        DECIMAL(18,4)   NOT NULL,
        precio_unitario DECIMAL(18,4)   NOT NULL,
        descuentos      DECIMAL(18,2)   NOT NULL DEFAULT 0,
        impuestos       DECIMAL(18,2)   NOT NULL DEFAULT 0,
        subtotal        DECIMAL(18,2)   NOT NULL DEFAULT 0,
        CONSTRAINT pk_detalle_compra PRIMARY KEY (id),
        CONSTRAINT fk_dc_compra   FOREIGN KEY (fk_compra)   REFERENCES dbo.compra(id),
        CONSTRAINT fk_dc_producto FOREIGN KEY (fk_producto) REFERENCES dbo.producto(codigo)
    );
    PRINT 'Tabla detalle_compra creada.';
END
GO

-- ── movimiento_inventario ──────────────────────────────────
IF OBJECT_ID('dbo.movimiento_inventario', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.movimiento_inventario (
        id              INT             IDENTITY(1,1) NOT NULL,
        fk_producto     INT             NOT NULL,
        cantidad        DECIMAL(18,4)   NOT NULL,
        operacion       NVARCHAR(50)    NOT NULL,
        motivo          NVARCHAR(500)   NULL,
        tipo_documento  NVARCHAR(50)    NOT NULL,
        no_documento    NVARCHAR(50)    NULL,
        fk_usuario      INT             NULL,
        fecha_operacion DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT pk_movimiento_inventario PRIMARY KEY (id),
        CONSTRAINT fk_mi_producto FOREIGN KEY (fk_producto) REFERENCES dbo.producto(codigo),
        CONSTRAINT fk_mi_usuario  FOREIGN KEY (fk_usuario)  REFERENCES dbo.usuario(codigo)
    );
    PRINT 'Tabla movimiento_inventario creada.';
END
GO

-- ════════════════════════════════════════════════════════════
--  4. ÍNDICES
-- ════════════════════════════════════════════════════════════

-- Índices para producto
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_producto_nombre')
    CREATE INDEX ix_producto_nombre ON dbo.producto(nombre);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_producto_categoria')
    CREATE INDEX ix_producto_categoria ON dbo.producto(fk_categoria);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_producto_marca')
    CREATE INDEX ix_producto_marca ON dbo.producto(fk_marca);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_producto_estado')
    CREATE INDEX ix_producto_estado ON dbo.producto(estado);

-- Índices para compra
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_compra_fecha')
    CREATE INDEX ix_compra_fecha ON dbo.compra(fecha_operacion DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_compra_proveedor')
    CREATE INDEX ix_compra_proveedor ON dbo.compra(fk_proveedor);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_compra_estado')
    CREATE INDEX ix_compra_estado ON dbo.compra(estado);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_compra_no_documento')
    CREATE INDEX ix_compra_no_documento ON dbo.compra(no_documento);

-- Índices para detalle_compra
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_detalle_compra_compra')
    CREATE INDEX ix_detalle_compra_compra ON dbo.detalle_compra(fk_compra);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_detalle_compra_producto')
    CREATE INDEX ix_detalle_compra_producto ON dbo.detalle_compra(fk_producto);

-- Índices para movimiento_inventario
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_movimiento_inventario_producto')
    CREATE INDEX ix_movimiento_inventario_producto ON dbo.movimiento_inventario(fk_producto);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_movimiento_inventario_fecha')
    CREATE INDEX ix_movimiento_inventario_fecha ON dbo.movimiento_inventario(fecha_operacion DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_movimiento_inventario_operacion')
    CREATE INDEX ix_movimiento_inventario_operacion ON dbo.movimiento_inventario(operacion);

-- Índices para precio
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_precio_producto')
    CREATE INDEX ix_precio_producto ON dbo.precio(fk_producto);

-- Índices para usuario
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_usuario_rol')
    CREATE INDEX ix_usuario_rol ON dbo.usuario(rol_nombre);

PRINT 'Índices creados.';
GO

-- ════════════════════════════════════════════════════════════
--  5. DATOS INICIALES (seed data)
-- ════════════════════════════════════════════════════════════

-- ── Medidas ────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.medida)
BEGIN
    INSERT INTO dbo.medida (codigo, descripcion) VALUES
        ('UN',   'Unidad'),
        ('KG',   'Kilogramo'),
        ('LT',   'Litro'),
        ('MT',   'Metro'),
        ('MT2',  'Metro cuadrado'),
        ('MT3',  'Metro cúbico'),
        ('LB',   'Libra'),
        ('OZ',   'Onza'),
        ('GAL',  'Galón'),
        ('PQ',   'Paquete'),
        ('BX',   'Caja'),
        ('DOC',  'Docena'),
        ('PAR',  'Par'),
        ('CM',   'Centímetro'),
        ('ML',   'Mililitro');
    PRINT 'Datos iniciales de medida insertados.';
END
GO

-- ── Categorías ─────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.categoria)
BEGIN
    INSERT INTO dbo.categoria (descripcion) VALUES
        ('Electrónicos'),
        ('Computación'),
        ('Oficina'),
        ('Papelería'),
        ('Limpieza'),
        ('Alimentos'),
        ('Bebidas'),
        ('Ropa y accesorios'),
        ('Herramientas'),
        ('Juguetes');
    PRINT 'Datos iniciales de categoria insertados.';
END
GO

-- ── Marcas ─────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.marca)
BEGIN
    INSERT INTO dbo.marca (nombre, descripcion) VALUES
        ('Genérico',   'Producto sin marca específica'),
        ('HP',         'Hewlett-Packard'),
        ('Dell',       'Dell Technologies'),
        ('Logitech',   'Logitech International'),
        ('Samsung',    'Samsung Electronics'),
        ('LG',         'LG Electronics'),
        ('Apple',      'Apple Inc.'),
        ('Bic',        'Bic Corporation'),
        ('3M',         '3M Company'),
        ('Avery',      'Avery Dennison');
    PRINT 'Datos iniciales de marca insertados.';
END
GO

-- ── Métodos de liquidación (pago) ──────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.metodo_liquidacion)
BEGIN
    INSERT INTO dbo.metodo_liquidacion (nombre, descripcion, dias_credito) VALUES
        ('Efectivo',       'Pago en efectivo',                   0),
        ('Tarjeta Débito', 'Pago con tarjeta de débito',         0),
        ('Tarjeta Crédito','Pago con tarjeta de crédito',        0),
        ('Transferencia',  'Transferencia bancaria',             0),
        ('Cheque',         'Pago con cheque',                    0),
        ('Crédito 15 días','Pago a crédito a 15 días',          15),
        ('Crédito 30 días','Pago a crédito a 30 días',          30),
        ('Crédito 45 días','Pago a crédito a 45 días',          45),
        ('Crédito 60 días','Pago a crédito a 60 días',          60);
    PRINT 'Datos iniciales de metodo_liquidacion insertados.';
END
GO

-- ── Impuestos ──────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.impuesto)
BEGIN
    INSERT INTO dbo.impuesto (descripcion, tipo_calculo, valor) VALUES
        ('IVA 12%',    'PORCENTAJE', 12.0000),
        ('IVA 8%',     'PORCENTAJE',  8.0000),
        ('ICE 5%',     'PORCENTAJE',  5.0000),
        ('Exento',     'PORCENTAJE',  0.0000),
        ('ISR 1%',     'PORCENTAJE',  1.0000);
    PRINT 'Datos iniciales de impuesto insertados.';
END
GO

-- ── Descuentos ─────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.descuento)
BEGIN
    INSERT INTO dbo.descuento (descripcion, tipo_calculo, valor) VALUES
        ('Sin descuento',     'PORCENTAJE', 0.0000),
        ('Descuento 5%',      'PORCENTAJE', 5.0000),
        ('Descuento 10%',     'PORCENTAJE', 10.0000),
        ('Descuento 15%',     'PORCENTAJE', 15.0000),
        ('Descuento 20%',     'PORCENTAJE', 20.0000),
        ('Descuento especial','PORCENTAJE', 25.0000);
    PRINT 'Datos iniciales de descuento insertados.';
END
GO

-- ── Proveedores ────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.proveedor)
BEGIN
    INSERT INTO dbo.proveedor (nit, nombre, direccion, telefono, email) VALUES
        ('123456789-0', 'Distribuidora XYZ S.A.',   'Av. Principal #123',     '5555-0101', 'ventas@xyz.com'),
        ('987654321-1', 'Importadora ABC Ltda.',    'Calle 10 #45-67',        '5555-0202', 'contacto@abc.com'),
        ('456789123-2', 'Comercial del Sur S.A.S.', 'Cra 8 #20-30',           '5555-0303', 'info@delsur.com'),
        ('321654987-3', 'Proveedora Total E.I.R.L.', 'Av. Central 789',       '5555-0404', 'ventas@total.com'),
        ('654321789-4', 'Suministros Global S.A.',   'Calle 50 #100-200',      '5555-0505', 'pedidos@global.com');
    PRINT 'Datos iniciales de proveedor insertados.';
END
GO

-- ── Representantes ─────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.representante)
BEGIN
    INSERT INTO dbo.representante (nit, nombre, telefono, email) VALUES
        ('RPT-001', 'Carlos Méndez',     '5555-1001', 'carlos@xyz.com'),
        ('RPT-002', 'María López',       '5555-1002', 'maria@abc.com'),
        ('RPT-003', 'José Martínez',     '5555-1003', 'jose@delsur.com'),
        ('RPT-004', 'Ana Rodríguez',     '5555-1004', 'ana@total.com'),
        ('RPT-005', 'Pedro Gómez',       '5555-1005', 'pedro@global.com');
    PRINT 'Datos iniciales de representante insertados.';
END
GO

-- ── Usuarios ───────────────────────────────────────────────
-- Las contraseñas están hasheadas con SHA-256.
-- Contraseña por defecto: 'Admin123' (para admin) y '123456' (para los demás)
-- Hash SHA-256 de 'Admin123': 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
-- Hash SHA-256 de '123456':  8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
IF NOT EXISTS (SELECT 1 FROM dbo.usuario)
BEGIN
    INSERT INTO dbo.usuario (user_name, contrasena_hash, nombre_empleado, email, rol_nombre, rol_nivel)
    VALUES
        ('admin',    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Administrador Sistema', 'admin@tellix.com', 'ADMINISTRADOR', 1),
        ('vendedor', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Juan Vendedor',         'juan@tellix.com',  'VENDEDOR',      2),
        ('bodeguero','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Pedro Bodeguero',       'pedro@tellix.com', 'BODEGUERO',     3),
        ('contador', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lucía Contadora',       'lucia@tellix.com', 'CONTADOR',      4);
    PRINT 'Datos iniciales de usuario insertados.';
END
GO

-- ── Productos ──────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.producto)
BEGIN
    INSERT INTO dbo.producto (nombre, descripcion, stock_actual, stock_minimo, fk_categoria, fk_marca, fk_medida, cantidad_medida)
    VALUES
        ('Laptop HP ProBook 450',   'Laptop empresarial 15.6" i5 16GB',        5,  3,  1, 2, 'UN', 1),
        ('Monitor Dell 24"',        'Monitor LED 24 pulgadas Full HD',         8,  5,  1, 3, 'UN', 1),
        ('Teclado Logitech K120',   'Teclado USB estándar',                   20, 10,  2, 4, 'UN', 1),
        ('Mouse Óptico USB',        'Mouse con cable USB 3 botones',          25, 15,  2, 1, 'UN', 1),
        ('Papel Bond Carta 500h',   'Resma de papel bond tamaño carta',       50, 20,  4, 8, 'UN', 1),
        ('Lapicero Bic Azul',       'Lapicero punta fina tinta azul',        100, 50,  4, 8, 'UN', 1),
        ('Archivador Oficio',       'Archivador tamaño oficio lomo ancho',     30, 15,  3, 1, 'UN', 1),
        ('Agua Purificada 500ml',   'Botella de agua purificada 500ml',       100, 30,  7, 1, 'ML', 500),
        ('Café Premium 250g',       'Café molido premium 250 gramos',          15, 10,  6, 1, 'KG', 0.25),
        ('Clips Metálicos x100',    'Caja de clips metálicos estándar',        40, 20,  4, 1, 'UN', 1);
    PRINT 'Datos iniciales de producto insertados.';
END
GO

-- ── Precios iniciales ──────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM dbo.precio)
BEGIN
    INSERT INTO dbo.precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, creado_por)
    VALUES
        (1, 'MINORISTA', 8500.0000, GETDATE(), 1),
        (2, 'MINORISTA', 3500.0000, GETDATE(), 1),
        (3, 'MINORISTA',  180.0000, GETDATE(), 1),
        (4, 'MINORISTA',   75.0000, GETDATE(), 1),
        (5, 'MINORISTA',   55.0000, GETDATE(), 1),
        (6, 'MINORISTA',   12.5000, GETDATE(), 1),
        (7, 'MINORISTA',   85.0000, GETDATE(), 1),
        (8, 'MINORISTA',   10.0000, GETDATE(), 1),
        (9, 'MINORISTA',  120.0000, GETDATE(), 1),
        (10,'MINORISTA',   18.0000, GETDATE(), 1);
    PRINT 'Datos iniciales de precio insertados.';
END
GO

PRINT '═══════════════════════════════════════════════════════';
PRINT '  Base de datos TellixDB creada/actualizada con éxito.';
PRINT '  A continuación ejecute los archivos de SP:';
PRINT '  - backend/src/main/resources/db/sp_compra.sql';
PRINT '  - backend/src/main/resources/db/sp_producto.sql';
PRINT '  - backend/src/main/resources/db/sp_inventario.sql';
PRINT '═══════════════════════════════════════════════════════';
GO
