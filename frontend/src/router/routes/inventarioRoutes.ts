import type { RouteRecordRaw } from 'vue-router'
export const inventarioRoutes: RouteRecordRaw[] = [
  { path: '/inventario', name: 'inventario', component: () => import('@/views/inventario/InventarioView.vue'), meta: { titulo: 'Inventario', roles: ['ADMINISTRADOR','BODEGUERO'] } },
  { path: '/inventario/ajuste', name: 'inventario-ajuste', component: () => import('@/views/inventario/AjusteFormView.vue'), meta: { titulo: 'Ajuste de inventario', roles: ['ADMINISTRADOR','BODEGUERO'] } },
  { path: '/inventario/movimientos', name: 'inventario-movimientos', component: () => import('@/views/inventario/MovimientosView.vue'), meta: { titulo: 'Movimientos', roles: ['ADMINISTRADOR','BODEGUERO'] } }
]
