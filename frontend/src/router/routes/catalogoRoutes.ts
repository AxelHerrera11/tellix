import type { RouteRecordRaw } from 'vue-router'

const rolesVer = ['ADMINISTRADOR', 'VENDEDOR', 'CONTADOR']

export const catalogoRoutes: RouteRecordRaw[] = [
  // ── Productos ────────────────────────────────────────────
  {
    path: '/catalogos/productos',
    name: 'productos',
    component: () => import('@/views/catalogos/ProductosView.vue'),
    meta: { titulo: 'Productos', roles: rolesVer }
  },
  {
    path: '/catalogos/productos/nuevo',
    name: 'producto-nuevo',
    component: () => import('@/views/catalogos/ProductoFormView.vue'),
    meta: { titulo: 'Nuevo producto', roles: ['ADMINISTRADOR'] }
  },
  {
    path: '/catalogos/productos/:id',
    name: 'producto-detalle',
    component: () => import('@/views/catalogos/ProductoDetailView.vue'),
    meta: { titulo: 'Detalle del producto', roles: rolesVer }
  },
  {
    path: '/catalogos/productos/:id/editar',
    name: 'producto-editar',
    component: () => import('@/views/catalogos/ProductoFormView.vue'),
    meta: { titulo: 'Editar producto', roles: ['ADMINISTRADOR'] }
  },

  // ── Otros catálogos ──────────────────────────────────────
  { path: '/catalogos/clientes',    name: 'clientes',    component: () => import('@/views/catalogos/ClientesView.vue'),    meta: { titulo: 'Clientes', roles: rolesVer } },
  { path: '/catalogos/proveedores', name: 'proveedores', component: () => import('@/views/catalogos/ProveedoresView.vue'), meta: { titulo: 'Proveedores', roles: rolesVer } },
  { path: '/catalogos/categorias',  name: 'categorias',  component: () => import('@/views/catalogos/CategoriasView.vue'),  meta: { titulo: 'Categorías', roles: rolesVer } },
  { path: '/catalogos/marcas',      name: 'marcas',      component: () => import('@/views/catalogos/MarcasView.vue'),      meta: { titulo: 'Marcas', roles: rolesVer } },
  { path: '/catalogos/impuestos',   name: 'impuestos',   component: () => import('@/views/catalogos/ImpuestosView.vue'),   meta: { titulo: 'Impuestos', roles: rolesVer } }
]
