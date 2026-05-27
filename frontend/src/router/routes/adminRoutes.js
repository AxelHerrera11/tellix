export const adminRoutes = [
    { path: '/admin/usuarios', name: 'admin-usuarios', component: () => import('@/views/admin/UsuariosView.vue'), meta: { titulo: 'Usuarios', nivel: 1 } },
    { path: '/admin/roles', name: 'admin-roles', component: () => import('@/views/admin/RolesView.vue'), meta: { titulo: 'Roles y permisos', nivel: 1 } },
    { path: '/admin/auditoria', name: 'admin-auditoria', component: () => import('@/views/admin/AuditoriaView.vue'), meta: { titulo: 'Auditoría', nivel: 1 } }
];
