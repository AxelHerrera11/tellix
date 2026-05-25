import type { RouteRecordRaw } from 'vue-router'
export const catalogoRoutes: RouteRecordRaw[] = [
  { path: '/catalogos/productos',   name: 'productos',   component: () => import('@/views/catalogos/ProductosView.vue'),   meta: { titulo: 'Productos' } },
  { path: '/catalogos/clientes',    name: 'clientes',    component: () => import('@/views/catalogos/ClientesView.vue'),    meta: { titulo: 'Clientes' } },
  { path: '/catalogos/proveedores', name: 'proveedores', component: () => import('@/views/catalogos/ProveedoresView.vue'), meta: { titulo: 'Proveedores' } },
  { path: '/catalogos/categorias',  name: 'categorias',  component: () => import('@/views/catalogos/CategoriasView.vue'),  meta: { titulo: 'Categorías' } },
  { path: '/catalogos/marcas',      name: 'marcas',      component: () => import('@/views/catalogos/MarcasView.vue'),      meta: { titulo: 'Marcas' } },
  { path: '/catalogos/impuestos',   name: 'impuestos',   component: () => import('@/views/catalogos/ImpuestosView.vue'),   meta: { titulo: 'Impuestos' } }
]
