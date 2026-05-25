# Módulo Producto

## Descripción

Módulo CRUD para la gestión de productos, incluyendo asignación de precios y visualización de impuestos/descuentos asignados.

## Endpoints

| Método | Ruta | Descripción | Roles |
|--------|------|-------------|-------|
| GET | `/api/productos` | Listado paginado con filtros | ADMINISTRADOR, VENDEDOR, CONTADOR |
| GET | `/api/productos/{id}` | Detalle completo | ADMINISTRADOR, VENDEDOR, CONTADOR |
| POST | `/api/productos` | Crear producto | ADMINISTRADOR |
| PUT | `/api/productos/{id}` | Actualizar producto | ADMINISTRADOR |
| PATCH | `/api/productos/{id}/estado` | Activar/Inactivar | ADMINISTRADOR |
| POST | `/api/productos/{id}/precios` | Asignar precio | ADMINISTRADOR |
| GET | `/api/productos/categorias` | Catálogo categorías | ADMINISTRADOR, VENDEDOR, CONTADOR |
| GET | `/api/productos/marcas` | Catálogo marcas | ADMINISTRADOR, VENDEDOR, CONTADOR |
| GET | `/api/productos/medidas` | Catálogo medidas | ADMINISTRADOR, VENDEDOR, CONTADOR |
| GET | `/api/productos/impuestos` | Catálogo impuestos | ADMINISTRADOR, VENDEDOR, CONTADOR |
| GET | `/api/productos/descuentos` | Catálogo descuentos | ADMINISTRADOR, VENDEDOR, CONTADOR |

## Vistas Frontend

| Ruta | Vista | Descripción |
|------|-------|-------------|
| `/catalogos/productos` | `ProductosView` | Listado con filtros por categoría, marca y estado |
| `/catalogos/productos/nuevo` | `ProductoFormView` | Formulario de creación |
| `/catalogos/productos/{id}` | `ProductoDetailView` | Detalle con precios, impuestos y descuentos |
| `/catalogos/productos/{id}/editar` | `ProductoFormView` | Formulario de edición |

## Stored Procedures

Archivo: `backend/src/main/resources/db/sp_producto.sql`

- `sp_listar_productos` — Listado paginado con LEFT JOIN a catálogos
- `sp_obtener_producto` — Producto + precios + impuestos + descuentos (4 resultsets)
- `sp_crear_producto` — Inserta producto y precio inicial opcional
- `sp_actualizar_producto` — Actualiza datos generales
- `sp_cambiar_estado_producto` — Activa/Inactiva
- `sp_asignar_precio_producto` — Registra nuevo precio con vigencia
- `sp_listar_categorias`, `sp_listar_marcas`, `sp_listar_medidas`, `sp_listar_impuestos`, `sp_listar_descuentos` — Catálogos auxiliares

## Backend

Clases en `backend/src/main/java/com/tellix/modules/producto/`:
- `ProductoDto.java` — DTOs con records anidados (request/response)
- `ProductoRepository.java` — Llamadas a stored procedures vía JdbcTemplate
- `ProductoService.java` — Lógica de negocio + seguridad
- `ProductoController.java` — REST controller con Swagger y `@PreAuthorize`

## Frontend

- `frontend/src/services/producto.service.ts` — Tipos + llamadas HTTP
- `frontend/src/views/catalogos/ProductosView.vue` — Listado con filtros
- `frontend/src/views/catalogos/ProductoFormView.vue` — Crear/Editar
- `frontend/src/views/catalogos/ProductoDetailView.vue` — Detalle + asignar precio
