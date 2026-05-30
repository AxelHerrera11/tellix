import api from './api'
import type { ApiResponse, PagedResponse } from './api'

export interface PrecioResumen { id: number; fkProducto: number; producto: string; descripcionProducto: string | null; aplicacion: string; precioVenta: number; inicioVigencia: string; finVigencia: string | null; estado: string; estadoDescripcion: string | null; vigente: boolean; creadoPor: number | null; usuario: string | null; creadoEn: string }
export interface PrecioDetalle extends PrecioResumen { categoria: string; marca: string; medida: string }
export interface CrearPrecioRequest { fkProducto: number; aplicacion: string; precioVenta: number; inicioVigencia?: string; cerrarVigentes?: boolean }
export interface ActualizarPrecioRequest { aplicacion: string; precioVenta: number; inicioVigencia: string; finVigencia?: string | null }
export interface CambiarEstadoPrecioRequest { estado: 'A' | 'I' }
export interface ProductoPrecioDto { codigo: number; nombre: string; descripcion: string; stockActual: number; medida: string }
export interface FiltrosPrecio { producto?: number; busqueda?: string; aplicacion?: string; estado?: string; vigentes?: boolean; fecha?: string; pagina?: number; tamano?: number }

export const precioService = {
  async listar(filtros: FiltrosPrecio = {}): Promise<PagedResponse<PrecioResumen>> {
    const params = new URLSearchParams()
    if (filtros.producto) params.append('producto', String(filtros.producto))
    if (filtros.busqueda) params.append('busqueda', filtros.busqueda)
    if (filtros.aplicacion) params.append('aplicacion', filtros.aplicacion)
    if (filtros.estado) params.append('estado', filtros.estado)
    if (filtros.vigentes !== undefined) params.append('vigentes', String(filtros.vigentes))
    if (filtros.fecha) params.append('fecha', filtros.fecha)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))
    const { data } = await api.get<ApiResponse<PagedResponse<PrecioResumen>>>(`/precios?${params.toString()}`)
    return data.data
  },
  async obtener(id: number): Promise<PrecioDetalle> { const { data } = await api.get<ApiResponse<PrecioDetalle>>(`/precios/${id}`); return data.data },
  async crear(req: CrearPrecioRequest): Promise<number> { const { data } = await api.post<ApiResponse<number>>('/precios', req); return data.data },
  async actualizar(id: number, req: ActualizarPrecioRequest): Promise<void> { await api.put(`/precios/${id}`, req) },
  async cambiarEstado(id: number, estado: 'A'|'I'): Promise<void> { await api.patch(`/precios/${id}/estado`, { estado } as CambiarEstadoPrecioRequest) },
  async obtenerVigente(producto: number, aplicacion?: string, fecha?: string): Promise<PrecioResumen> {
    const params = new URLSearchParams(); params.append('producto', String(producto)); if (aplicacion) params.append('aplicacion', aplicacion); if (fecha) params.append('fecha', fecha)
    const { data } = await api.get<ApiResponse<PrecioResumen>>(`/precios/vigente?${params.toString()}`)
    return data.data
  },
  async listarProductos(): Promise<ProductoPrecioDto[]> { const { data } = await api.get<ApiResponse<ProductoPrecioDto[]>>('/precios/productos'); return data.data }
}
