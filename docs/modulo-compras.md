# Módulo Compras

## Descripción

Gestión de compras: registro de órdenes de compra con ingreso de inventario, control de documentos por proveedor y generación automática de CXP para compras a crédito.

## Endpoints

| Método | Ruta | Descripción | Roles |
|--------|------|-------------|-------|
| GET | `/api/compras` | Listado paginado con filtros | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/{id}` | Cabecera + detalle de una compra | ADMINISTRADOR, BODEGUERO |
| POST | `/api/compras` | Registrar compra (agrega stock, genera CXP si aplica) | ADMINISTRADOR, BODEGUERO |
| PATCH | `/api/compras/{id}/anular` | Anular compra (restaura stock, anula CXP) | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/productos/buscar` | Búsqueda de productos para el formulario | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/proveedores/buscar` | Búsqueda de proveedores para el formulario | ADMINISTRADOR, BODEGUERO |
| GET | `/api/compras/proveedores/{nit}/representantes` | Lista representantes activos de un proveedor | ADMINISTRADOR, BODEGUERO |

## Vistas Frontend

| Ruta | Vista | Descripción |
|------|-------|-------------|
| `/compras` | `ComprasListView` | Listado paginado con filtros por proveedor, estado y fecha |
| `/compras/nueva` | `CompraFormView` | Formulario tipo POS con búsqueda de proveedor, representante y productos |
| `/compras/{id}` | `CompraDetailView` | Detalle completo con info del proveedor, productos y opción de anular |

## Stored Procedures

Archivo: `backend/src/main/resources/db/sp_compras.sql`

### Nuevos SPs

| SP | Descripción |
|----|-------------|
| `sp_listar_compras` | Listado paginado con filtros por proveedor, estado y rango de fechas |
| `sp_obtener_compra` | Cabecera + detalle de una compra (2 ResultSets) |
| `sp_registrar_compra` | Registro transaccional: cabecera, detalle (JSON), actualiza stock_actual, movimiento de inventario y CXP si plazo > 0 |
| `sp_anular_compra` | Anulación: cambia estado a X, resta stock_actual, inserta DEVOLUCION en inventario y anula CXP asociada |
| `sp_buscar_productos_compra` | Búsqueda de productos activos por nombre o código (top 50) |
| `sp_buscar_proveedores_compra` | Búsqueda de proveedores activos por nombre o NIT (top 20) |
| `sp_listar_representantes` | Lista representantes activos de un proveedor con teléfono y email |

### SP preexistente actualizado

`sp_registrar_compra` se actualizó para usar `OPENJSON` con esquema tipado (camelCase) en lugar de `JSON_VALUE`, consistente con el patrón del módulo de ventas. Incluye la generación automática de CXP del archivo `sp_cxp.sql`.

## Backend

Clases en `backend/src/main/java/com/tellix/modules/compra/`:
- `CompraDto.java` — DTOs: CrearCompraRequest, CompraResumen, CompraDetalle, DetalleCompra, ProductoCompra, ProveedorCompra, RepresentanteCompra
- `CompraRepository.java` — Llamadas a SPs vía JdbcTemplate + CallableStatement con manejo de múltiples ResultSets
- `CompraService.java` — Lógica de negocio, extrae usuario autenticado del SecurityContext
- `CompraController.java` — REST controller con Swagger, validación Jakarta y `@PreAuthorize`

## Frontend

- `frontend/src/services/compra.service.ts` — Tipos + llamadas HTTP con Axios
- `frontend/src/views/compras/ComprasListView.vue` — Listado con filtros y paginación
- `frontend/src/views/compras/CompraFormView.vue` — Formulario con búsqueda de proveedor, representante, productos, carrito y totales en tiempo real
- `frontend/src/views/compras/CompraDetailView.vue` — Detalle con tabla de productos, totales y modal de anulación

## Flujo de datos (registro de compra)

1. Frontend envía `POST /api/compras` con `{ noDocumento, fkProveedor, fkMetodoPago, plazoCredito, items[] }`
2. `CompraController` valida con Jakarta Bean Validation
3. `CompraService` extrae usuario autenticado del JWT
4. `CompraRepository` serializa items a JSON y ejecuta `sp_registrar_compra`
5. El SP ejecuta una transacción:
   - Inserta cabecera en `compra` (estado = 'P')
   - Inserta detalle en `detalle_compra` desde OPENJSON
   - Recalcula totales en cabecera
   - Suma `stock_actual` en `producto`
   - Registra movimiento de inventario (ENTRADA)
   - Si `plazo_credito > 0`, crea registro en `cuenta_por_pagar`
6. Retorna el ID de la compra creada

## Estados de compra

| Estado | Significado |
|--------|-------------|
| P | Pendiente |
| A | Aprobada |
| C | Completada |
| X | Anulada |
