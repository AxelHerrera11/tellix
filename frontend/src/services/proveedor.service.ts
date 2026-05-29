import api from './api'
import type { PagedResponse, ApiResponse } from './api'

export interface ProveedorResumen {
  nit:               string
  nombre:            string
  direccionFiscal:   string | null
  estado:            string
  estadoDescripcion: string
  representante:     string | null
  telefono:          string | null
  email:             string | null
  creadoEn:          string | null
  actualizadoEn:     string | null
}

export interface ProveedorDetalle {
  nit:               string
  nombre:            string
  direccionFiscal:   string | null
  estado:            string
  estadoDescripcion: string
  representante:     string | null
  telefono:          string | null
  email:             string | null
  creadoEn:          string | null
  actualizadoEn:     string | null
}

export interface CrearProveedorRequest {
  nit:        string
  nombre:     string
  direccion?: string
}

export interface ActualizarProveedorRequest {
  nombre:     string
  direccion?: string
}

export interface CambiarEstadoRequest {
  estado: 'A' | 'I'
}

export interface FiltrosProveedor {
  busqueda?: string
  estado?:   string
  pagina?:   number
  tamano?:   number
}

export const proveedorService = {
  async listar(filtros: FiltrosProveedor = {}): Promise<PagedResponse<ProveedorResumen>> {
    const params = new URLSearchParams()
    if (filtros.busqueda) params.append('busqueda', filtros.busqueda)
    if (filtros.estado)   params.append('estado',   filtros.estado)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<ProveedorResumen>>>(
      `/proveedores?${params.toString()}`
    )
    return data.data
  },

  async obtener(nit: string): Promise<ProveedorDetalle> {
    const { data } = await api.get<ApiResponse<ProveedorDetalle>>(`/proveedores/${encodeURIComponent(nit)}`)
    return data.data
  },

  async crear(req: CrearProveedorRequest): Promise<void> {
    await api.post('/proveedores', req)
  },

  async actualizar(nit: string, req: ActualizarProveedorRequest): Promise<void> {
    await api.put(`/proveedores/${encodeURIComponent(nit)}`, req)
  },

  async cambiarEstado(nit: string, req: CambiarEstadoRequest): Promise<void> {
    await api.patch(`/proveedores/${encodeURIComponent(nit)}/estado`, req)
  }
}
