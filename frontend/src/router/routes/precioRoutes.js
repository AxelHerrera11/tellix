export const precioRoutes = [
    { path: '/precios', name: 'precios', component: () => import('@/views/precios/PreciosView.vue'), meta: { titulo: 'Precios', roles: ['ADMINISTRADOR', 'VENDEDOR', 'CONTADOR'] } },
    { path: '/precios/nuevo', name: 'precio-nuevo', component: () => import('@/views/precios/PrecioFormView.vue'), meta: { titulo: 'Nuevo precio', roles: ['ADMINISTRADOR'] } },
    { path: '/precios/:id', name: 'precio-detalle', component: () => import('@/views/precios/PrecioDetailView.vue'), meta: { titulo: 'Detalle precio', roles: ['ADMINISTRADOR', 'VENDEDOR', 'CONTADOR'] } },
    { path: '/precios/:id/editar', name: 'precio-editar', component: () => import('@/views/precios/PrecioFormView.vue'), meta: { titulo: 'Editar precio', roles: ['ADMINISTRADOR'] } }
];
