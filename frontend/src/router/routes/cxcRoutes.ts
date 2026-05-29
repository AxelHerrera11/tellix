import type { RouteRecordRaw } from 'vue-router'
export const cxcRoutes: RouteRecordRaw[] = [
  { path: '/cxc', name: 'cxc', component: () => import('@/views/cxc/CxcView.vue'), meta: { titulo: 'Cuentas por cobrar', roles: ['ADMINISTRADOR','CONTADOR'] } },
  { path: '/cxc/vencidas', name: 'cxc-vencidas', component: () => import('@/views/cxc/CxcView.vue'), meta: { titulo: 'CXC vencidas', roles: ['ADMINISTRADOR','CONTADOR'] }, props: { soloVencidas: true } },
  { path: '/cxc/:id', name: 'cxc-detalle', component: () => import('@/views/cxc/CxcDetailView.vue'), meta: { titulo: 'Detalle CXC', roles: ['ADMINISTRADOR','CONTADOR'] } }
]
