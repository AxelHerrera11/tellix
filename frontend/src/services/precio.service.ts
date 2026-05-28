import api from './api'
import type { ApiResponse, PagedResponse } from './api'

export interface PrecioResumen { id: number; fkProducto: number; producto: string; descripcionProducto: string; aplicacion: string; precioVenta: number; inicioVigencia: string; finVigencia: string | null; estado: string; estadoDescripcion: string; vigente: boolean; creadoPor: number | null; usuario: string; creadoEn: string }
export interface PrecioDetalle extends PrecioResumen { categoria: string; marca: string; medida: string }
export interface CrearPrecioRequest { fkProducto: number; aplicacion: string; precioVenta: number; inicioVigencia?: string; cerrarVigentes?: boolean }
export interface ActualizarPrecioRequest { aplicacion: string; precioVenta: number; inicioVigencia: string; finVigencia?: string | null }
export interface CambiarEstadoPrecioRequest { estado: 'A' | 'I' }
export interface ProductoPrecioDto { codigo: number; nombre: string; descripcion: string; stockActual: number; medida: string }
export interface FiltrosPrecio { producto?: number; busqueda?: string; aplicacion?: string; estado?: string; vigentes?: boolean; fecha?: string; pagina?: number; tamano?: number }

export const precioService = {
  async listar(f: FiltrosPrecio = {}): Promise<PagedResponse<PrecioResumen>> {
    const p = new URLSearchParams()
    if (f.producto) p.append('producto', String(f.producto))
    if (f.busqueda) p.append('busqueda', f.busqueda)
    if (f.aplicacion) p.append('aplicacion', f.aplicacion)
    if (f.estado) p.append('estado', f.estado)
    if (f.vigentes) p.append('vigentes', 'true')
    if (f.fecha) p.append('fecha', f.fecha)
    p.append('pagina', String(f.pagina ?? 1)); p.append('tamano', String(f.tamano ?? 20))
    const { data } = await api.get<ApiResponse<PagedResponse<PrecioResumen>>>(`/precios?${p.toString()}`)
    return data.data
  },
  async obtener(id: number): Promise<PrecioDetalle> { const { data } = await api.get<ApiResponse<PrecioDetalle>>(`/precios/${id}`); return data.data },
  async crear(req: CrearPrecioRequest): Promise<number> { const { data } = await api.post<ApiResponse<number>>('/precios', req); return data.data },
  async actualizar(id: number, req: ActualizarPrecioRequest): Promise<void> { await api.put(`/precios/${id}`, req) },
  async cambiarEstado(id: number, estado: 'A'|'I'): Promise<void> { await api.patch(`/precios/${id}/estado`, { estado } as CambiarEstadoPrecioRequest) },
  async obtenerVigente(producto: number, aplicacion?: string, fecha?: string): Promise<PrecioResumen> {
    const p = new URLSearchParams(); p.append('producto', String(producto)); if (aplicacion) p.append('aplicacion', aplicacion); if (fecha) p.append('fecha', fecha)
    const { data } = await api.get<ApiResponse<PrecioResumen>>(`/precios/vigente?${p.toString()}`)
    return data.data
  },
  async listarProductos(): Promise<ProductoPrecioDto[]> { const { data } = await api.get<ApiResponse<ProductoPrecioDto[]>>('/precios/catalogos/productos'); return data.data }
}
