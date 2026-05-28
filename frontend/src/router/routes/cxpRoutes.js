export const cxpRoutes = [
    { path: '/cxp', name: 'cxp', component: () => import('@/views/cxp/CxpView.vue'), meta: { titulo: 'Cuentas por pagar', roles: ['ADMINISTRADOR', 'CONTADOR'] } }
];
