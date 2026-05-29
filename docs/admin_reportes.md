# Módulos Admin y Reportes

## Descripción

Módulos administrativos desarrollados para la gestión de usuarios, consulta de roles, visualización de actividad reciente del sistema y generación de reportes generales.

El módulo **Admin** permite administrar usuarios del sistema, visualizar roles disponibles y consultar actividad reciente basada en registros reales de la base de datos.

El módulo **Reportes** permite visualizar un resumen general del sistema, incluyendo productos, clientes, proveedores, ventas, compras, cuentas por cobrar y cuentas por pagar.

---

# Módulo Admin

## Descripción

Módulo para la administración de usuarios, roles y actividad reciente del sistema.

Incluye:

- Listado de usuarios.
- Creación de nuevos usuarios con empleado asociado.
- Consulta de roles.
- Visualización de actividad reciente usando datos existentes de la base de datos.

---

## Endpoints

| Método | Ruta | Descripción | Roles |
|---|---|---|---|
| GET | `/api/admin/usuarios` | Listado de usuarios con empleado y rol asignado | ADMINISTRADOR |
| POST | `/api/admin/usuarios` | Crear usuario y empleado asociado | ADMINISTRADOR |
| GET | `/api/admin/roles` | Listado de roles del sistema | ADMINISTRADOR |
| GET | `/api/admin/auditoria` | Actividad reciente del sistema | ADMINISTRADOR |

---

## Vistas Frontend

| Ruta | Vista | Descripción |
|---|---|---|
| `/admin/usuarios` | `UsuariosView` | Listado de usuarios, búsqueda y creación de usuario |
| `/admin/roles` | `RolesView` | Consulta de roles disponibles |
| `/admin/auditoria` | `AuditoriaView` | Actividad reciente del sistema |

---

## Stored Procedures

Archivo:

```text
backend/src/main/resources/db/sp_admin_reportes.sql
