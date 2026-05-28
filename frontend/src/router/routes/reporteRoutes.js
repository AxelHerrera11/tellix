export const reporteRoutes = [
    { path: '/reportes', name: 'reportes', component: () => import('@/views/reportes/ReportesView.vue'), meta: { titulo: 'Reportes', roles: ['ADMINISTRADOR', 'CONTADOR'] } }
];
