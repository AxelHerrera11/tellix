import api from './api'
import type { PagedResponse, ApiResponse } from './api'

export interface ClienteResumen {
  codigo:           number
  nit:              string
  nombre:           string
  nombre1:          string
  nombre2:          string | null
  nombre3:          string | null
  apellido1:        string
  apellido2:        string | null
  apellidoCasada:   string | null
  direccion:        string | null
  tipoCodigo:       number | null
  tipoCliente:      string | null
  limiteCredito:    number
  estado:           string
  estadoDescripcion: string
  telefono:         string | null
  email:            string | null
  creadoEn:         string | null
  actualizadoEn:    string | null
}

export interface ClienteDetalle {
  codigo:           number
  nit:              string
  nombre:           string
  nombre1:          string
  nombre2:          string | null
  nombre3:          string | null
  apellido1:        string
  apellido2:        string | null
  apellidoCasada:   string | null
  direccion:        string | null
  tipoCodigo:       number | null
  tipoCliente:      string | null
  limiteCredito:    number
  estado:           string
  estadoDescripcion: string
  telefono:         string | null
  email:            string | null
  creadoEn:         string | null
  actualizadoEn:    string | null
}

export interface CrearClienteRequest {
  nit:           string
  nombre1:       string
  nombre2?:      string
  nombre3?:      string
  apellido1:     string
  apellido2?:    string
  apellidoCasada?: string
  direccion?:    string
  fkTipoCliente: number
  limiteCredito: number
  telefono?:     string
  email?:        string
}

export interface ActualizarClienteRequest {
  nombre1:       string
  nombre2?:      string
  nombre3?:      string
  apellido1:     string
  apellido2?:    string
  apellidoCasada?: string
  direccion?:    string
  fkTipoCliente: number
  limiteCredito: number
  telefono?:     string
  email?:        string
}

export interface CambiarEstadoRequest {
  estado: 'A' | 'I'
}

export interface FiltrosCliente {
  busqueda?: string
  estado?:   string
  tipo?:     number
  pagina?:   number
  tamano?:   number
}

export const clienteService = {
  async listar(filtros: FiltrosCliente = {}): Promise<PagedResponse<ClienteResumen>> {
    const params = new URLSearchParams()
    if (filtros.busqueda) params.append('busqueda', filtros.busqueda)
    if (filtros.estado)   params.append('estado',   filtros.estado)
    if (filtros.tipo)     params.append('tipo',     String(filtros.tipo))
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<ClienteResumen>>>(
      `/clientes?${params.toString()}`
    )
    return data.data
  },

  async obtener(codigo: number): Promise<ClienteDetalle> {
    const { data } = await api.get<ApiResponse<ClienteDetalle>>(`/clientes/${codigo}`)
    return data.data
  },

  async crear(req: CrearClienteRequest): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>('/clientes', req)
    return data.data
  },

  async actualizar(codigo: number, req: ActualizarClienteRequest): Promise<void> {
    await api.put(`/clientes/${codigo}`, req)
  },

  async cambiarEstado(codigo: number, req: CambiarEstadoRequest): Promise<void> {
    await api.patch(`/clientes/${codigo}/estado`, req)
  }
}
