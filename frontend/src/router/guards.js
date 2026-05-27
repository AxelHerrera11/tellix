import { useAuthStore } from '@/stores/auth.store';
export function setupGuards(router) {
    router.beforeEach((to, _from, next) => {
        const auth = useAuthStore();
        // Rutas públicas — sin guard
        if (to.meta.publica) {
            // Si ya está logueado y va al login, redirigir al dashboard
            if (to.name === 'login' && auth.estaAutenticado) {
                return next({ name: 'dashboard' });
            }
            return next();
        }
        // Requiere autenticación
        if (!auth.estaAutenticado) {
            return next({ name: 'login', query: { redirigir: to.fullPath } });
        }
        // Verificar nivel mínimo requerido (menor = más privilegio)
        const nivelRequerido = to.meta.nivel;
        if (nivelRequerido !== undefined && !auth.tieneNivel(nivelRequerido)) {
            return next({ name: 'error-403' });
        }
        // Verificar roles permitidos
        const rolesPermitidos = to.meta.roles;
        if (rolesPermitidos?.length && !auth.tieneRol(...rolesPermitidos)) {
            return next({ name: 'error-403' });
        }
        next();
    });
}
