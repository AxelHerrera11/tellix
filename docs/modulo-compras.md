# Módulo Compras

## Descripción

Gestión de compras y órdenes de compra: registro de compras a proveedores con detalle de productos, control de inventario y flujo de estados (Pendiente → Aprobada → Completada / Cancelada).

## Estados de compra

| Estado | Código | Descripción |
|--------|--------|-------------|
| Pendiente | `P` | Recién creada, no afecta inventario |
| Aprobada | `A` | Stock incrementado, movimientos registrados |
| Completada | `C` | Compra finalizada (solo tracking) |
| Cancelada | `X` | Anulada, stock restaurado si estaba A/C |

## Flujo de estados

```
[P] Pendiente ──→ [A] Aprobada ──→ [C] Completada
       │                                │
       └────────→ [X] Cancelada ←───────┘
```

- **Pendiente → Aprobada**: Incrementa `stock_actual` de cada producto y registra movimientos de inventario (operación `COMPRA`)
- **Aprobada → Completada**: Solo marca el estado (no afecta stock)
- **Aprobada/Completada → Cancelada**: Restaura `stock_actual` restando las cantidades y registra movimiento de salida (cantidad negativa)
- **Pendiente → Cancelada**: No afecta stock (nunca se aprobó)

## Endpoints API

| Método | Ruta | Descripción | Roles |
|--------|------|-------------|-------|
| GET | `/api/compras` | Listado paginado con filtros | ADMINISTRADOR, BODEGUERO, CONTADOR |
| GET | `/api/compras/{id}` | Cabecera + detalle completo | ADMINISTRADOR, BODEGUERO, CONTADOR |
| POST | `/api/compras` | Registrar compra (estado Pendiente) | ADMINISTRADOR, BODEGUERO |
| PATCH | `/api/compras/{id}/aprobar` | Aprobar → actualiza stock | ADMINISTRADOR, BODEGUERO |
| PATCH | `/api/compras/{id}/completar` | Completar (solo estado) | ADMINISTRADOR, BODEGUERO |
| PATCH | `/api/compras/{id}/anular` | Anular → restaura stock si aplica | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/productos/buscar` | Búsqueda de productos (formulario) | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/proveedores/buscar` | Búsqueda de proveedores | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/metodos-pago` | Listar métodos de pago activos | ADMINISTRADOR, BODEGUERO, CONTADOR |
| GET | `/api/compras/representantes/buscar` | Búsqueda de representantes | ADMINISTRADOR, BODEGUERO |

## Vistas Frontend

| Ruta | Vista | Descripción |
|------|-------|-------------|
| `/compras` | `ComprasListView` | Listado paginado con filtros por proveedor, estado y rango de fechas |
| `/compras/nueva` | `CompraFormView` | Formulario POS-style: busca productos, agrega al carrito, ajusta cantidades/precios/impuestos, totales reactivos |
| `/compras/:id` | `CompraDetailView` | Detalle completo con info de cabecera, tabla de ítems, totales y botones de transición de estado (aprobar, completar, anular) |

## DTOs (CompraDto.java)

### Request
- `CrearCompraRequest` — noDocumento, fkProveedor, fkRepresentante (opcional), fkMetodoPago, plazoCredito (opcional), items[]
  - `DetalleRequest` — fkProducto, cantidad, precioUnitario, descuentos, impuestos
- `AnularCompraRequest` — motivo (opcional)

### Response
- `CompraResumen` — Para listados paginados (cabecera + totales)
- `CompraDetalle` — Cabecera completa + `List<DetalleCompra> items`
- `DetalleCompra` — Datos del producto + cantidades + precios + totales por línea
- `ProductoCompra` — Para búsqueda en formulario de compras
- `ProveedorCompra` — Para búsqueda en formulario de compras
- `MetodoPagoDto` — Método de pago
- `RepresentanteDto` — Representante de proveedor

## Stored Procedures

Archivo: `backend/src/main/resources/db/sp_compra.sql`

| SP | Propósito |
|----|-----------|
| `sp_listar_compras` | Listado paginado con filtros (proveedor, estado, fecha). Devuelve 2 resultsets: total + datos |
| `sp_obtener_compra` | Cabecera + detalle de una compra por ID. Devuelve 2 resultsets: cabecera + items |
| `sp_registrar_compra` | Crea cabecera + detalle en una transacción. Recibe items como JSON. Retorna el ID por OUTPUT |
| `sp_aprobar_compra` | Cambia estado P→A, incrementa `stock_actual` en producto, inserta movimientos de inventario |
| `sp_completar_compra` | Cambia estado A→C (solo tracking) |
| `sp_anular_compra` | Cambia estado a X, restaura stock si estaba A/C, inserta movimiento de salida |
| `sp_buscar_productos_compra` | Búsqueda de productos activos por nombre o código |
| `sp_buscar_proveedores_compra` | Búsqueda de proveedores activos por nombre o NIT |
| `sp_listar_metodos_pago` | Lista métodos de liquidación activos |
| `sp_listar_representantes` | Lista representantes activos con filtro opcional |

## Backend

Clases en `backend/src/main/java/com/tellix/modules/compra/`:

| Clase | Propósito |
|-------|-----------|
| `CompraDto.java` | 9 records anidados (request/response) |
| `CompraRepository.java` | Llamadas a SPs vía JdbcTemplate + CallableStatement |
| `CompraService.java` | Lógica de negocio + resuelve usuario actual desde SecurityContext |
| `CompraController.java` | REST controller con Swagger docs y `@PreAuthorize` por rol |

## Frontend

| Archivo | Propósito |
|---------|-----------|
| `frontend/src/services/compra.service.ts` | Interfaces TypeScript + llamadas Axios |
| `frontend/src/views/compras/ComprasListView.vue` | Tabla paginada con filtros |
| `frontend/src/views/compras/CompraFormView.vue` | Formulario POS con buscadores, carrito, totales reactivos |
| `frontend/src/views/compras/CompraDetailView.vue` | Detalle con transiciones de estado |
| `frontend/src/router/routes/compraRoutes.ts` | 3 rutas protegidas para ADMINISTRADOR y BODEGUERO |

## Tablas de base de datos

### compra
| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | INT IDENTITY PK | Identificador único |
| no_documento | NVARCHAR(50) | Número de factura/documento |
| fk_proveedor | NVARCHAR(50) FK→proveedor.nit | Proveedor |
| fk_representante | NVARCHAR(50) FK→representante.nit (nullable) | Representante |
| fecha_operacion | DATE | Fecha de la operación |
| hora_operacion | DATETIME2 | Hora de la operación |
| fk_usuario | INT FK→usuario.codigo | Usuario que registró |
| fk_metodo_pago | INT FK→metodo_liquidacion.codigo | Método de pago |
| plazo_credito | INT | Días de crédito (0 = contado) |
| estado | CHAR(1) | P=Aprobada, C=Completada, X=Cancelada |
| subtotal | DECIMAL(18,2) | Suma de (cantidad × precio) |
| total_descuentos | DECIMAL(18,2) | Suma de descuentos por línea |
| total_impuestos | DECIMAL(18,2) | Suma de impuestos por línea |
| total | DECIMAL(18,2) | Total neto = subtotal − descuentos + impuestos |
| creado_en | DATETIME2 | Fecha de creación |
| actualizado_en | DATETIME2 | Fecha de última modificación |

### detalle_compra
| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | INT IDENTITY PK | Identificador único |
| fk_compra | INT FK→compra.id | Compra padre |
| fk_producto | INT FK→producto.codigo | Producto |
| cantidad | DECIMAL(18,4) | Cantidad |
| precio_unitario | DECIMAL(18,4) | Precio unitario |
| descuentos | DECIMAL(18,2) | Descuentos aplicados |
| impuestos | DECIMAL(18,2) | Impuestos aplicados |
| subtotal | DECIMAL(18,2) | Total por línea |

## Instalación / Configuración

### 1. Base de datos

Ejecutar los scripts SQL en orden:
```sql
-- 1. Esquema de base de datos (tablas, índices, datos iniciales)
TellixDB_SQLServer.sql

-- 2. Stored procedures por módulo
sp_auth.sql
sp_producto.sql
sp_compra.sql
sp_inventario.sql
```

### 2. Backend

```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 3. Frontend

```bash
cd frontend
npm install
npm run dev
```

## Credenciales por defecto

| Usuario  | Contraseña | Rol |
|----------|-----------|-----|
| admin    | Admin123  | ADMINISTRADOR |
| vendedor | 123456    | VENDEDOR |
| bodeguero| 123456    | BODEGUERO |
| contador | 123456    | CONTADOR |
