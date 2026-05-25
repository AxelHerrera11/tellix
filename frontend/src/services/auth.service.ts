import api from './api'
import { sha256 } from 'js-sha256'

export interface LoginRequest {
  userName: string
  contrasenaHash: string
}

export interface LoginResponse {
  token: string
  refreshToken: string
  codigoUsuario: number
  userName: string
  rol: string
  nivel: number
  nombreEmpleado: string
}

export interface ApiResponse<T> {
  ok: boolean
  mensaje: string | null
  data: T
}

/**
 * Hashea la contraseña en el cliente antes de enviarla.
 * El backend valida contra el hash almacenado en BD.
 */
export function hashPassword(password: string): string {
  return sha256(password)
}

export const authService = {
  async login(userName: string, password: string): Promise<LoginResponse> {
    const req: LoginRequest = {
      userName,
      contrasenaHash: hashPassword(password)
    }
    const { data } = await api.post<ApiResponse<LoginResponse>>('/auth/login', req)
    return data.data
  },

  async logout(): Promise<void> {
    await api.post('/auth/logout')
  },

  async refresh(refreshToken: string): Promise<LoginResponse> {
    const { data } = await api.post<ApiResponse<LoginResponse>>('/auth/refresh', null, {
      headers: { 'X-Refresh-Token': refreshToken }
    })
    return data.data
  }
}
