-- ============================================================
-- DATOS INICIALES TELLIX
-- Usuario administrador para primer acceso
-- ============================================================

USE TellixDB;
GO

-- 1. Rol administrador
INSERT INTO rol (nombre, descripcion, nivel)
VALUES ('ADMINISTRADOR', 'Acceso total al sistema', 1);

-- 2. Empleado vinculado al usuario
INSERT INTO empleado (nombre_1, apellido_1, estado)
VALUES ('Admin', 'Sistema', 'A');

-- 3. Usuario administrador
--    Contraseña: Admin123
--    SHA-256 de "Admin123" = 3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2
INSERT INTO usuario (fk_empleado, user_name, contrasena_hash, fk_rol, estado)
VALUES (
    1,                    -- fk_empleado (el que acabamos de insertar)
    'admin',              -- user_name
    '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2',  -- SHA-256 de "Admin123"
    1,                    -- fk_rol (Administrador)
    'A'                   -- Activo
);

GO

INSERT INTO rol (nombre, descripcion, nivel) VALUES
('VENDEDOR',   'Acceso a ventas y clientes',              2),
('BODEGUERO',  'Acceso a compras e inventario',           3),
('CONTADOR',   'Acceso a CXC, CXP y reportes',           4);