import { useAuthStore } from '@/stores/auth.store'
import { useUiStore }   from '@/stores/ui.store'
import { authService }  from '@/services/auth.service'
import router from '@/router'

export function useAuth() {
  const auth = useAuthStore()
  const ui   = useUiStore()

  async function login(userName: string, password: string) {
    try {
      ui.setCargando(true)
      const resp = await authService.login(userName, password)
      auth.guardarSesion(resp)
      ui.mostrarToast(`Bienvenido, ${resp.nombreEmpleado}`, 'exito')
      router.push('/dashboard')
    } finally {
      ui.setCargando(false)
    }
  }

  async function logout() {
    try {
      await authService.logout()
    } finally {
      auth.cerrarSesion()
      router.push('/login')
    }
  }

  return {
    login,
    logout,
    estaAutenticado: auth.estaAutenticado,
    usuario:         auth.usuario,
    rol:             auth.rol,
    esAdmin:         auth.esAdmin,
    tieneRol:        auth.tieneRol.bind(auth),
    tieneNivel:      auth.tieneNivel.bind(auth)
  }
}
