# Módulo Inventario

## Descripción

Gestión de inventario: visualización de stock con alertas por nivel, ajustes manuales de existencias e historial de movimientos.

## Endpoints

| Método | Ruta | Descripción | Roles |
|--------|------|-------------|-------|
| GET | `/api/inventario/stock` | Listado paginado con nivel de stock | ADMINISTRADOR, BODEGUERO, VENDEDOR, CONTADOR |
| GET | `/api/inventario/stock/critico` | Productos por debajo del mínimo | ADMINISTRADOR, BODEGUERO |
| GET | `/api/inventario/movimientos` | Historial paginado de movimientos | ADMINISTRADOR, BODEGUERO |
| POST | `/api/inventario/ajustes` | Ajuste manual de stock (+/−) | ADMINISTRADOR, BODEGUERO |

## Vistas Frontend

| Ruta | Vista | Descripción |
|------|-------|-------------|
| `/inventario` | `InventarioView` | Tabla de stock con colores por nivel, alerta de críticos |
| `/inventario/ajuste` | `AjusteFormView` | Formulario con búsqueda de producto, cantidad y motivo |
| `/inventario/movimientos` | `MovimientosView` | Historial con filtros por fecha, producto y operación |

## Stored Procedures

Archivo: `backend/src/main/resources/db/sp_inventario.sql`

- `sp_listar_stock` — Listado paginado con nivel de stock calculado (CRITICO, BAJO, MEDIO, OK)
- `sp_listar_movimientos` — Historial paginado con filtros por producto, operación y fecha

### SPs existentes reutilizados

- `sp_ajuste_inventario` — Ajuste atómico (inserta movimiento + actualiza stock_actual)
- `sp_reporte_stock_critico` — Productos con stock por debajo del mínimo

## Backend

Clases en `backend/src/main/java/com/tellix/modules/inventario/`:
- `InventarioDto.java` — DTOs: StockProducto, MovimientoDto, StockCritico, AjustarStockRequest
- `InventarioRepository.java` — Llamadas a SPs vía JdbcTemplate + CallableStatement
- `InventarioService.java` — Lógica de negocio + seguridad
- `InventarioController.java` — REST controller con Swagger y `@PreAuthorize`

## Frontend

- `frontend/src/services/inventario.service.ts` — Tipos + llamadas HTTP
- `frontend/src/views/inventario/InventarioView.vue` — Stock overview con colores por nivel
- `frontend/src/views/inventario/AjusteFormView.vue` — Ajuste manual con buscador de productos
- `frontend/src/views/inventario/MovimientosView.vue` — Historial con filtros

## Niveles de stock

| Nivel | Condición | Color |
|-------|-----------|-------|
| CRITICO | stock_actual ≤ 0 | Rojo |
| BAJO | stock_actual < stock_minimo | Amarillo |
| MEDIO | stock_actual ≤ stock_minimo × 2 | Azul |
| OK | stock_actual > stock_minimo × 2 | Verde |
