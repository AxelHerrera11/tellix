import type { RouteRecordRaw } from 'vue-router'
export const reporteRoutes: RouteRecordRaw[] = [
  { path: '/reportes', name: 'reportes', component: () => import('@/views/reportes/ReportesView.vue'), meta: { titulo: 'Reportes', roles: ['ADMINISTRADOR','CONTADOR'] } }
]
