import type { RouteRecordRaw } from 'vue-router'
export const cxpRoutes: RouteRecordRaw[] = [
  { path: '/cxp', name: 'cxp', component: () => import('@/views/cxp/CxpView.vue'), meta: { titulo: 'Cuentas por pagar', roles: ['ADMINISTRADOR','CONTADOR'] } },
  { path: '/cxp/vencidas', name: 'cxp-vencidas', component: () => import('@/views/cxp/CxpView.vue'), meta: { titulo: 'CXP vencidas', roles: ['ADMINISTRADOR','CONTADOR'] }, props: { soloVencidas: true } },
  { path: '/cxp/:id', name: 'cxp-detalle', component: () => import('@/views/cxp/CxpDetailView.vue'), meta: { titulo: 'Detalle CXP', roles: ['ADMINISTRADOR','CONTADOR'] } }
]
