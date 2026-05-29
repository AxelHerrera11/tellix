export const compraRoutes = [
    { path: '/compras', name: 'compras', component: () => import('@/views/compras/ComprasListView.vue'), meta: { titulo: 'Compras', roles: ['ADMINISTRADOR', 'BODEGUERO'] } },
    { path: '/compras/nueva', name: 'compra-nueva', component: () => import('@/views/compras/CompraFormView.vue'), meta: { titulo: 'Nueva compra', roles: ['ADMINISTRADOR', 'BODEGUERO'] } },
    { path: '/compras/:id', name: 'compra-detalle', component: () => import('@/views/compras/CompraDetailView.vue'), meta: { titulo: 'Detalle de compra', roles: ['ADMINISTRADOR', 'BODEGUERO'] } }
];
