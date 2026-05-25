import type { RouteRecordRaw } from 'vue-router'
export const ventaRoutes: RouteRecordRaw[] = [
  { path: '/ventas', name: 'ventas', component: () => import('@/views/ventas/VentasListView.vue'), meta: { titulo: 'Ventas', roles: ['ADMINISTRADOR','VENDEDOR'] } },
  { path: '/ventas/nueva', name: 'venta-nueva', component: () => import('@/views/ventas/VentaFormView.vue'), meta: { titulo: 'Nueva venta', roles: ['ADMINISTRADOR','VENDEDOR'] } },
  { path: '/ventas/:id', name: 'venta-detalle', component: () => import('@/views/ventas/VentaDetailView.vue'), meta: { titulo: 'Detalle de venta', roles: ['ADMINISTRADOR','VENDEDOR'] } }
]
