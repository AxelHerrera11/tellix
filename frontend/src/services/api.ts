import axios from 'axios'

export interface ApiResponse<T> {
  ok:      boolean
  mensaje: string | null
  data:    T
}

export interface PagedResponse<T> {
  data:         T[]
  pagina:       number
  tamano:       number
  total:        number
  totalPaginas: number
}

import { useAuthStore } from '@/stores/auth.store'
import { useUiStore }   from '@/stores/ui.store'
import router from '@/router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? '/api',
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' }
})

// ── Request: inyectar Bearer token ────────────────────────
api.interceptors.request.use(config => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

// ── Response: manejar errores globalmente ─────────────────
api.interceptors.response.use(
  res => res,
  async err => {
    const auth = useAuthStore()
    const ui   = useUiStore()
    const status: number = err.response?.status

    if (status === 401) {
      // Intentar renovar con refresh token
      if (auth.refreshToken) {
        try {
          const { data } = await axios.post('/api/auth/refresh', null, {
            headers: { 'X-Refresh-Token': auth.refreshToken }
          })
          auth.guardarSesion(data.data)
          err.config.headers.Authorization = `Bearer ${data.data.token}`
          return api.request(err.config)
        } catch {
          auth.cerrarSesion()
          router.push('/login')
        }
      } else {
        auth.cerrarSesion()
        router.push('/login')
      }
    }

    if (status === 403) {
      ui.mostrarToast('No tiene permiso para realizar esta acción.', 'error')
    }

    if (status >= 500) {
      ui.mostrarToast('Error del servidor. Intente de nuevo.', 'error')
    }

    return Promise.reject(err)
  }
)

export default api
