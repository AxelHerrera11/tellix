import { createRouter, createWebHistory } from 'vue-router'
import { setupGuards } from './guards'
import { authRoutes }      from './routes/authRoutes'
import { dashboardRoutes } from './routes/dashboardRoutes'
import { ventaRoutes }     from './routes/ventaRoutes'
import { compraRoutes }    from './routes/compraRoutes'
import { inventarioRoutes }from './routes/inventarioRoutes'
import { cxcRoutes }       from './routes/cxcRoutes'
import { cxpRoutes }       from './routes/cxpRoutes'
import { reporteRoutes }   from './routes/reporteRoutes'
import { catalogoRoutes }  from './routes/catalogoRoutes'
import { adminRoutes }     from './routes/adminRoutes'
import AppLayout from '@/components/layout/AppLayout.vue'

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        // Rutas públicas sin layout
        ...authRoutes,

        // Rutas protegidas con layout compartido
        {
            path: '/',
            component: AppLayout,
            children: [
                ...dashboardRoutes,
                ...ventaRoutes,
                ...compraRoutes,
                ...inventarioRoutes,
                ...cxcRoutes,
                ...cxpRoutes,
                ...reporteRoutes,
                ...catalogoRoutes,
                ...adminRoutes,
            ]
        },

        // Errores sin layout
        {
            path: '/403',
            name: 'error-403',
            component: () => import('@/views/errors/Error403View.vue')
        },
        {
            path: '/:pathMatch(.*)*',
            name: 'error-404',
            component: () => import('@/views/errors/Error404View.vue')
        }
    ]
})

setupGuards(router)

export default router
