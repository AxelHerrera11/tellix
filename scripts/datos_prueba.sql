-- ============================================================
--  TELLIX — Datos de prueba
--  Ejecutar después de TellixDB_SQLServer.sql
--  y después de los datos iniciales (roles + usuario admin)
-- ============================================================

USE TellixDB;
GO

-- ============================================================
-- 1. CATÁLOGOS BASE
-- ============================================================

-- Tipos de cliente
INSERT INTO tipo_cliente (descripcion) VALUES
('Consumidor final'),
('Pequeño contribuyente'),
('Régimen general');

-- Tipos de contacto
INSERT INTO tipo_contacto (descripcion) VALUES
('Teléfono'),
('Email'),
('WhatsApp'),
('Dirección');

-- Bancos
INSERT INTO banco (nombre) VALUES
('Banco Industrial'),
('BAC Credomatic'),
('Banrural'),
('G&T Continental');

-- Tipos de cuenta bancaria
INSERT INTO tipo_cuenta (codigo, descripcion) VALUES
('MON', 'Monetaria'),
('AHO', 'Ahorro'),
('CHE', 'Cheques');

-- Métodos de liquidación
INSERT INTO metodo_liquidacion (descripcion) VALUES
('Contado - Efectivo'),
('Crédito'),
('Transferencia bancaria'),
('Tarjeta de débito'),
('Tarjeta de crédito');

-- Categorías de productos
INSERT INTO categoria (descripcion) VALUES
('Bebidas'),
('Lácteos'),
('Granos y cereales'),
('Limpieza del hogar'),
('Cuidado personal'),
('Snacks y dulces'),
('Carnes y embutidos'),
('Frutas y verduras');

-- Marcas
INSERT INTO marca (nombre, descripcion) VALUES
('Nestlé',       'Nestlé Guatemala'),
('Coca-Cola',    'The Coca-Cola Company'),
('Dos Pinos',    'Cooperativa Dos Pinos'),
('Buen Provecho','Productos Buen Provecho S.A.'),
('Maseca',       'Grupo Bimbo'),
('Colgate',      'Colgate-Palmolive'),
('Lala',         'Grupo Lala'),
('Pringles',     'Kellanova'),
('Genérico',     'Sin marca específica');

-- Unidades de medida
INSERT INTO medida (codigo, descripcion) VALUES
('UND',  'Unidad'),
('KG',   'Kilogramo'),
('GR',   'Gramo'),
('LT',   'Litro'),
('ML',   'Mililitro'),
('PZA',  'Pieza'),
('PAQ',  'Paquete'),
('CJA',  'Caja'),
('DOC',  'Docena'),
('LB',   'Libra');

-- Impuestos
INSERT INTO impuesto (descripcion, tipo_calculo, valor) VALUES
('IVA 12%',        'PORCENTAJE', 12.00),
('Timbre fiscal',   'FIJO',       0.50);

-- Descuentos
INSERT INTO descuento (descripcion, tipo_calculo, valor) VALUES
('Descuento cliente frecuente', 'PORCENTAJE', 5.00),
('Descuento mayorista',         'PORCENTAJE', 10.00),
('Descuento por volumen',       'FIJO',       5.00);

GO

-- ============================================================
-- 2. CUENTAS BANCARIAS DE LA EMPRESA
-- ============================================================

INSERT INTO cuenta (numero, fk_banco, titular, fk_tipo, estado, descripcion) VALUES
('1234-5678-9012', 1, 'Tellix Comercial S.A.', 'MON', 'A', 'Cuenta principal operaciones'),
('9876-5432-1098', 2, 'Tellix Comercial S.A.', 'AHO', 'A', 'Cuenta de ahorros'),
('1111-2222-3333', 1, 'Tellix Comercial S.A.', 'CHE', 'A', 'Cuenta de cheques proveedores');

GO

-- ============================================================
-- 3. PRODUCTOS CON PRECIOS VIGENTES
-- ============================================================

-- Bebidas
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Coca-Cola 500ml',     'Bebida carbonatada 500ml',        24,  120, 'A', 1, 2, 'UND', 500),
('Coca-Cola 1.5L',      'Bebida carbonatada 1.5 litros',   12,   60, 'A', 1, 2, 'UND', 1500),
('Pepsi 500ml',         'Bebida carbonatada 500ml',        24,   80, 'A', 1, 9, 'UND', 500),
('Agua pura 500ml',     'Agua purificada 500ml',           48,  200, 'A', 1, 9, 'UND', 500),
('Jugo Hit 250ml',      'Jugo de frutas 250ml',            36,   90, 'A', 1, 9, 'UND', 250);

-- Lácteos
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Leche entera 1L',     'Leche entera pasteurizada',       24,   48, 'A', 2, 3, 'UND', 1000),
('Leche descremada 1L', 'Leche descremada pasteurizada',   12,   30, 'A', 2, 3, 'UND', 1000),
('Queso fresco 454g',   'Queso fresco blanco',             10,   25, 'A', 2, 9, 'UND', 454),
('Crema 200ml',         'Crema para cocinar',              12,   40, 'A', 2, 3, 'UND', 200),
('Yogurt natural 1kg',  'Yogurt natural sin azúcar',        8,   20, 'A', 2, 7, 'UND', 1000);

-- Granos y cereales
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Arroz blanco 1lb',    'Arroz blanco de grano largo',     50,  150, 'A', 3, 9, 'LB',  1),
('Frijol negro 1lb',    'Frijol negro seco',               50,  120, 'A', 3, 9, 'LB',  1),
('Harina de maíz 1kg',  'Masa para tortillas',             24,   60, 'A', 3, 5, 'KG',  1),
('Avena 500g',          'Avena en hojuelas',               12,   35, 'A', 3, 1, 'UND', 500),
('Cereal Corn Flakes',  'Cereal de maíz 500g',             12,   28, 'A', 3, 1, 'UND', 500);

-- Limpieza
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Cloro 1L',            'Cloro desinfectante',             12,   50, 'A', 4, 9, 'UND', 1000),
('Detergente 1kg',      'Detergente para ropa en polvo',   12,   40, 'A', 4, 9, 'KG',  1),
('Jabón lavaplatos',    'Jabón líquido lavar trastes',     12,   35, 'A', 4, 9, 'UND', 500),
('Suavizante 1L',       'Suavizante para ropa',             8,   22, 'A', 4, 9, 'UND', 1000);

-- Cuidado personal
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Pasta dental 75ml',   'Pasta dental con flúor',          12,   45, 'A', 5, 6, 'UND', 75),
('Shampoo 200ml',       'Shampoo para cabello normal',      8,   30, 'A', 5, 9, 'UND', 200),
('Jabón de baño',       'Jabón antibacterial 100g',        24,   80, 'A', 5, 9, 'UND', 100),
('Desodorante 50g',     'Desodorante en barra',            12,   25, 'A', 5, 9, 'UND', 50);

-- Snacks
INSERT INTO producto (nombre, descripcion, stock_minimo, stock_actual, estado, fk_categoria, fk_marca, fk_medida, cantidad_medida)
VALUES
('Pringles Original',   'Papas fritas en tubo 124g',       12,   40, 'A', 6, 8, 'UND', 124),
('Galletas María 200g', 'Galletas dulces de vainilla',     12,   50, 'A', 6, 9, 'UND', 200),
('Chicle Trident',      'Chicle sin azúcar blister 12u',   24,   60, 'A', 6, 9, 'UND', 12),
('Chocolate Nestlé 40g','Chocolate con leche 40g',         24,   55, 'A', 6, 1, 'UND', 40);

GO

-- ============================================================
-- 4. PRECIOS VIGENTES (desde hoy, sin fecha de vencimiento)
-- ============================================================

DECLARE @hoy DATE = CAST(SYSDATETIME() AS DATE);

-- Bebidas
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(1,  'MINORISTA', 6.50,  @hoy, 'A'),
(2,  'MINORISTA', 14.00, @hoy, 'A'),
(3,  'MINORISTA', 5.75,  @hoy, 'A'),
(4,  'MINORISTA', 3.50,  @hoy, 'A'),
(5,  'MINORISTA', 5.00,  @hoy, 'A');

-- Lácteos
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(6,  'MINORISTA', 12.50, @hoy, 'A'),
(7,  'MINORISTA', 13.00, @hoy, 'A'),
(8,  'MINORISTA', 18.00, @hoy, 'A'),
(9,  'MINORISTA', 8.50,  @hoy, 'A'),
(10, 'MINORISTA', 22.00, @hoy, 'A');

-- Granos
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(11, 'MINORISTA', 5.00,  @hoy, 'A'),
(12, 'MINORISTA', 6.50,  @hoy, 'A'),
(13, 'MINORISTA', 9.00,  @hoy, 'A'),
(14, 'MINORISTA', 18.00, @hoy, 'A'),
(15, 'MINORISTA', 25.00, @hoy, 'A');

-- Limpieza
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(16, 'MINORISTA', 12.00, @hoy, 'A'),
(17, 'MINORISTA', 28.00, @hoy, 'A'),
(18, 'MINORISTA', 14.00, @hoy, 'A'),
(19, 'MINORISTA', 22.00, @hoy, 'A');

-- Cuidado personal
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(20, 'MINORISTA', 16.00, @hoy, 'A'),
(21, 'MINORISTA', 28.00, @hoy, 'A'),
(22, 'MINORISTA', 5.50,  @hoy, 'A'),
(23, 'MINORISTA', 24.00, @hoy, 'A');

-- Snacks
INSERT INTO precio (fk_producto, aplicacion, precio_venta, inicio_vigencia, estado) VALUES
(24, 'MINORISTA', 24.00, @hoy, 'A'),
(25, 'MINORISTA', 12.00, @hoy, 'A'),
(26, 'MINORISTA', 7.00,  @hoy, 'A'),
(27, 'MINORISTA', 6.50,  @hoy, 'A');

GO

-- ============================================================
-- 5. CLIENTES DE PRUEBA
-- ============================================================

INSERT INTO cliente (nit, nombre_1, apellido_1, fk_tipo_cliente, limite_credito, direccion, estado) VALUES
('CF',          'Consumidor',  'Final',       1,      0.00, 'Guatemala',                               'A'),
('1234567-8',   'Juan',        'García',      2,   5000.00, '5a Av. 10-20 zona 1, Guatemala',          'A'),
('9876543-2',   'María',       'López',       2,   3000.00, '12 Calle 5-10 zona 3, Mixco',             'A'),
('5555555-5',   'Carlos',      'Martínez',    3,  15000.00, '6a Av. 2-50 zona 9, Guatemala',           'A'),
('4444444-4',   'Ana',         'Pérez',       1,      0.00, '1a Calle 3-25 zona 7, Guatemala',         'A'),
('3333333-3',   'Roberto',     'González',    2,   8000.00, 'Calzada Roosevelt 25-30 zona 11, Mixco',  'A'),
('2222222-2',   'Sofía',       'Hernández',   3,  20000.00, '4a Av. 12-15 zona 14, Guatemala',         'A'),
('1111111-1',   'Pedro',       'Ramírez',     1,      0.00, 'Aldea El Naranjo, Villa Nueva',           'A');

-- Contactos de clientes
INSERT INTO contacto_cliente (fk_cliente, fk_tipo, info_contacto, principal) VALUES
('1234567-8', 1, '5555-1234', 1),
('1234567-8', 2, 'juan.garcia@email.com', 0),
('9876543-2', 1, '5555-5678', 1),
('9876543-2', 3, '5555-5678', 0),
('5555555-5', 1, '2345-6789', 1),
('5555555-5', 2, 'carlos.martinez@empresa.com', 0),
('4444444-4', 3, '4444-1234', 1),
('3333333-3', 1, '6666-7890', 1),
('2222222-2', 2, 'sofia.hernandez@empresa.gt', 1),
('1111111-1', 1, '7777-4321', 1);

GO

-- ============================================================
-- 6. PROVEEDORES DE PRUEBA
-- ============================================================

INSERT INTO proveedor (nit, nombre, direccion_fiscal, estado) VALUES
('1000000-1', 'Distribuidora Nacional S.A.',    '7a Av. 13-01 zona 9, Guatemala',           'A'),
('2000000-2', 'Importaciones del Sur Ltda.',    'Calz. Aguilar Batres 53-50 zona 12',       'A'),
('3000000-3', 'Productos Lácteos Centro S.A.',  '6a Calle 4-65 zona 1, Quetzaltenango',     'A'),
('4000000-4', 'Bebidas y Refrescos S.A.',       '13 Calle 6-60 zona 10, Guatemala',         'A'),
('5000000-5', 'Granos y Semillas del Norte',    '4a Av. 7-25 zona 3, Cobán, AV',            'A');

-- Representantes
INSERT INTO representante (nit, fk_proveedor, nombre_1, apellido_1, activo) VALUES
('6000000-6', '1000000-1', 'Luis',    'Morales',  1),
('7000000-7', '2000000-2', 'Carmen',  'Salazar',  1),
('8000000-8', '3000000-3', 'Miguel',  'Torres',   1),
('9000000-9', '4000000-4', 'Diana',   'Fuentes',  1),
('1100000-0', '5000000-5', 'Rodrigo', 'Castillo', 1);

GO

-- ============================================================
-- 7. EMPLEADOS ADICIONALES (distintos roles)
-- ============================================================

-- Vendedor
INSERT INTO empleado (nombre_1, apellido_1, estado, fk_jefe)
VALUES ('Carlos', 'Ventas', 'A', 1);

-- Bodeguero
INSERT INTO empleado (nombre_1, apellido_1, estado, fk_jefe)
VALUES ('Pedro', 'Bodega', 'A', 1);

-- Contador
INSERT INTO empleado (nombre_1, apellido_1, estado, fk_jefe)
VALUES ('Ana', 'Contabilidad', 'A', 1);

-- Roles adicionales (si no los creaste antes)
IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'VENDEDOR')
    INSERT INTO rol (nombre, descripcion, nivel) VALUES ('VENDEDOR', 'Acceso a ventas y clientes', 2);
IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'BODEGUERO')
    INSERT INTO rol (nombre, descripcion, nivel) VALUES ('BODEGUERO', 'Acceso a compras e inventario', 3);
IF NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'CONTADOR')
    INSERT INTO rol (nombre, descripcion, nivel) VALUES ('CONTADOR', 'Acceso a CXC, CXP y reportes', 4);

-- Usuarios adicionales
-- Contraseña para todos: Tellix2024 → SHA-256
-- sha256('Tellix2024') = 1a2b3c... (calculado con js-sha256)
-- Para obtener el hash: abrir DevTools del navegador → consola → pegar:
--   const e=new TextEncoder(),d=e.encode('Tellix2024')
--   const h=await crypto.subtle.digest('SHA-256',d)
--   console.log(Array.from(new Uint8Array(h)).map(b=>b.toString(16).padStart(2,'0')).join(''))

-- NOTA: reemplaza el hash por el que obtengas en la consola del navegador
DECLARE @hashTellix2024 NVARCHAR(256) = 'd9ca0699aea2079d3472112114ff9f523c70a12d653da279547e78ee669cf26c';

INSERT INTO usuario (fk_empleado, user_name, contrasena_hash, fk_rol, estado)
VALUES
(2, 'vendedor',  @hashTellix2024, (SELECT codigo FROM rol WHERE nombre='VENDEDOR'),  'A'),
(3, 'bodeguero', @hashTellix2024, (SELECT codigo FROM rol WHERE nombre='BODEGUERO'), 'A'),
(4, 'contador',  @hashTellix2024, (SELECT codigo FROM rol WHERE nombre='CONTADOR'),  'A');

GO

-- ============================================================
-- 8. VERIFICACIÓN FINAL
-- ============================================================

SELECT 'Categorías'        AS tabla, COUNT(*) AS registros FROM categoria       UNION ALL
SELECT 'Marcas',                      COUNT(*)              FROM marca            UNION ALL
SELECT 'Medidas',                     COUNT(*)              FROM medida           UNION ALL
SELECT 'Productos',                   COUNT(*)              FROM producto         UNION ALL
SELECT 'Precios vigentes',            COUNT(*)              FROM precio           UNION ALL
SELECT 'Clientes',                    COUNT(*)              FROM cliente          UNION ALL
SELECT 'Proveedores',                 COUNT(*)              FROM proveedor        UNION ALL
SELECT 'Empleados',                   COUNT(*)              FROM empleado         UNION ALL
SELECT 'Usuarios',                    COUNT(*)              FROM usuario          UNION ALL
SELECT 'Roles',                       COUNT(*)              FROM rol              UNION ALL
SELECT 'Métodos de pago',             COUNT(*)              FROM metodo_liquidacion
ORDER BY tabla;

GO
