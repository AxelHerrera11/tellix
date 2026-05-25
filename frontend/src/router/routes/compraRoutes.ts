import type { RouteRecordRaw } from 'vue-router'
export const compraRoutes: RouteRecordRaw[] = [
  { path: '/compras', name: 'compras', component: () => import('@/views/compras/ComprasListView.vue'), meta: { titulo: 'Compras', roles: ['ADMINISTRADOR','BODEGUERO'] } },
  { path: '/compras/nueva', name: 'compra-nueva', component: () => import('@/views/compras/CompraFormView.vue'), meta: { titulo: 'Nueva compra', roles: ['ADMINISTRADOR','BODEGUERO'] } }
]
