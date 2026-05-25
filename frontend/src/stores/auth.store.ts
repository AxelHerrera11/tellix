import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { LoginResponse } from '@/services/auth.service'

const TOKEN_KEY   = 'tellix_token'
const REFRESH_KEY = 'tellix_refresh'
const USER_KEY    = 'tellix_user'

interface UsuarioSesion {
  codigoUsuario: number
  userName: string
  rol: string
  nivel: number
  nombreEmpleado: string
}

export const useAuthStore = defineStore('auth', () => {
  // ── Estado ──────────────────────────────────────────────
  const token        = ref<string | null>(sessionStorage.getItem(TOKEN_KEY))
  const refreshToken = ref<string | null>(sessionStorage.getItem(REFRESH_KEY))
  const usuario      = ref<UsuarioSesion | null>(
    JSON.parse(sessionStorage.getItem(USER_KEY) ?? 'null')
  )

  // ── Getters ─────────────────────────────────────────────
  const estaAutenticado = computed(() => !!token.value)
  const rol             = computed(() => usuario.value?.rol ?? '')
  const nivel           = computed(() => usuario.value?.nivel ?? 99)
  const nombreEmpleado  = computed(() => usuario.value?.nombreEmpleado ?? '')
  const esAdmin         = computed(() => nivel.value === 1)

  // ── Actions ─────────────────────────────────────────────
  function guardarSesion(resp: LoginResponse) {
    token.value        = resp.token
    refreshToken.value = resp.refreshToken

    usuario.value = {
      codigoUsuario: resp.codigoUsuario,
      userName:      resp.userName,
      rol:           resp.rol,
      nivel:         resp.nivel,
      nombreEmpleado: resp.nombreEmpleado
    }

    sessionStorage.setItem(TOKEN_KEY,   resp.token)
    sessionStorage.setItem(REFRESH_KEY, resp.refreshToken)
    sessionStorage.setItem(USER_KEY,    JSON.stringify(usuario.value))
  }

  function cerrarSesion() {
    token.value        = null
    refreshToken.value = null
    usuario.value      = null
    sessionStorage.removeItem(TOKEN_KEY)
    sessionStorage.removeItem(REFRESH_KEY)
    sessionStorage.removeItem(USER_KEY)
  }

  /**
   * Verifica si el usuario tiene un rol específico.
   * Útil en guards y directivas v-if.
   */
  function tieneRol(...roles: string[]): boolean {
    return roles.some(r => r.toUpperCase() === rol.value.toUpperCase())
  }

  /**
   * Verifica si el nivel de privilegio es suficiente.
   * Menor nivel = más privilegio (1 = Administrador).
   */
  function tieneNivel(nivelRequerido: number): boolean {
    return nivel.value <= nivelRequerido
  }

  return {
    token,
    refreshToken,
    usuario,
    estaAutenticado,
    rol,
    nivel,
    nombreEmpleado,
    esAdmin,
    guardarSesion,
    cerrarSesion,
    tieneRol,
    tieneNivel
  }
})
