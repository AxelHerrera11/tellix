import api from './api'
import type { PagedResponse, ApiResponse } from './api'

// ── Tipos ─────────────────────────────────────────────────────
export interface StockProducto {
  codigo:       number
  nombre:       string
  categoria:    string | null
  marca:        string | null
  medidaCodigo: string | null
  medida:       string | null
  stockActual:  number
  stockMinimo:  number
  estado:       string
  nivelStock:   string
}

export interface MovimientoDto {
  id:              number
  fkProducto:      number
  producto:        string
  medidaCodigo:    string | null
  medida:          string | null
  cantidad:        number
  tipoMovimiento:  string
  operacion:       string
  motivo:          string | null
  tipoDocumento:   string | null
  noDocumento:     string | null
  fkUsuario:       number | null
  usuario:         string | null
  fechaOperacion:  string
}

export interface StockCritico {
  codigo:       number
  nombre:       string
  categoria:    string | null
  marca:        string | null
  stockActual:  number
  stockMinimo:  number
  faltante:     number
}

export interface AjustarStockRequest {
  fkProducto: number
  cantidad:   number
  motivo:     string
}

export interface FiltrosStock {
  busqueda?:  string
  categoria?: number
  estado?:    string
  critico?:   boolean
  pagina?:    number
  tamano?:    number
}

export interface FiltrosMovimiento {
  producto?:  number
  operacion?: string
  desde?:     string
  hasta?:     string
  pagina?:    number
  tamano?:    number
}

// ── Service ───────────────────────────────────────────────────
export const inventarioService = {
  async listarStock(filtros: FiltrosStock = {}): Promise<PagedResponse<StockProducto>> {
    const params = new URLSearchParams()
    if (filtros.busqueda)  params.append('busqueda',  filtros.busqueda)
    if (filtros.categoria) params.append('categoria', String(filtros.categoria))
    if (filtros.estado)    params.append('estado',    filtros.estado)
    if (filtros.critico)   params.append('critico',   'true')
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<StockProducto>>>(
      `/inventario/stock?${params.toString()}`
    )
    return data.data
  },

  async stockCritico(): Promise<StockCritico[]> {
    const { data } = await api.get<ApiResponse<StockCritico[]>>('/inventario/stock/critico')
    return data.data
  },

  async listarMovimientos(filtros: FiltrosMovimiento = {}): Promise<PagedResponse<MovimientoDto>> {
    const params = new URLSearchParams()
    if (filtros.producto)  params.append('producto',  String(filtros.producto))
    if (filtros.operacion) params.append('operacion', filtros.operacion)
    if (filtros.desde)     params.append('desde',     filtros.desde)
    if (filtros.hasta)     params.append('hasta',     filtros.hasta)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<MovimientoDto>>>(
      `/inventario/movimientos?${params.toString()}`
    )
    return data.data
  },

  async ajustar(req: AjustarStockRequest): Promise<void> {
    await api.post('/inventario/ajustes', req)
  }
}
