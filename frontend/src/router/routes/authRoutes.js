export const authRoutes = [
    {
        path: '/login',
        name: 'login',
        component: () => import('@/views/auth/LoginView.vue'),
        meta: { publica: true, titulo: 'Iniciar sesión' }
    },
    {
        path: '/',
        redirect: '/dashboard'
    }
];
