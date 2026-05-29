import api from './api'
import type { PagedResponse, ApiResponse } from './api'

// ── Tipos ─────────────────────────────────────────────────────
export interface CxpResumen {
  id:                number
  fkCompra:          number
  noDocumento:       string
  proveedorNit:      string
  proveedor:         string
  estado:            string
  estadoDescripcion: string
  valorTotal:        number
  valorPagado:       number
  saldo:             number
  fechaLimite:       string
  metodoPago:        string
  fechaCompra:       string
  creadoEn:          string
}

export interface DetalleCompra {
  id:              number
  fkCompra:        number
  fkProducto:      number
  nombreProducto:  string
  cantidad:        number
  precioUnitario:  number
  descuentos:      number
  impuestos:       number
  subtotal:        number
}

export interface CxpDetalle {
  id:                 number
  fkCompra:           number
  noDocumento:        string
  proveedorNit:       string
  proveedor:          string
  proveedorDireccion: string | null
  estado:             string
  estadoDescripcion:  string
  valorTotal:         number
  valorPagado:        number
  saldo:              number
  fechaLimite:        string
  fkMetodoPago:       number
  metodoPago:         string | null
  fkCuenta:           string | null
  cuentaNumero:       string | null
  banco:              string | null
  fechaCompra:        string
  compraSubtotal:     number
  compraDescuentos:   number
  compraImpuestos:    number
  compraTotal:        number
  usuario:            string
  nombreEmpleado:     string
  creadoEn:           string
  actualizadoEn:      string
  items:              DetalleCompra[]
}

export interface CxpVencida {
  id:           number
  fkCompra:     number
  noDocumento:  string
  proveedor:    string
  valorTotal:   number
  valorPagado:  number
  saldo:        number
  fechaLimite:  string
  diasVencida:  number
}

export interface RegistrarPagoRequest {
  monto:        number
  descripcion?: string
}

export interface FiltrosCxp {
  proveedor?: string
  estado?:    string
  desde?:     string
  hasta?:     string
  pagina?:    number
  tamano?:    number
}

// ── Service ───────────────────────────────────────────────────
export const cxpService = {
  async listar(filtros: FiltrosCxp = {}): Promise<PagedResponse<CxpResumen>> {
    const params = new URLSearchParams()
    if (filtros.proveedor) params.append('proveedor', filtros.proveedor)
    if (filtros.estado)    params.append('estado',    filtros.estado)
    if (filtros.desde)     params.append('desde',     filtros.desde)
    if (filtros.hasta)     params.append('hasta',     filtros.hasta)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<CxpResumen>>>(
      `/cxp?${params.toString()}`
    )
    return data.data
  },

  async obtener(id: number): Promise<CxpDetalle> {
    const { data } = await api.get<ApiResponse<CxpDetalle>>(`/cxp/${id}`)
    return data.data
  },

  async registrarPago(id: number, req: RegistrarPagoRequest): Promise<void> {
    await api.post(`/cxp/${id}/pagos`, req)
  },

  async anular(id: number, motivo?: string): Promise<void> {
    await api.patch(`/cxp/${id}/anular`, { motivo })
  },

  async reporteVencidas(fecha?: string): Promise<CxpVencida[]> {
    const params = new URLSearchParams()
    if (fecha) params.append('fecha', fecha)
    const { data } = await api.get<ApiResponse<CxpVencida[]>>(
      `/cxp/reporte/vencidas?${params.toString()}`
    )
    return data.data
  }
}
