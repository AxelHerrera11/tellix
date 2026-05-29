import api from './api'
import type { ApiResponse, PagedResponse } from './api'

export interface CxpResumen {
  id: number
  fkCompra: number
  noDocumento: string
  fkProveedor: string
  proveedor: string
  fechaOperacion: string
  fechaLimite: string
  estado: string
  estadoDescripcion: string
  valorTotal: number
  valorPagado: number
  saldo: number
  pagada: boolean
  vencida: boolean
  diasVencida: number
  fkMetodoPago: number
  metodoPago: string
  fkCuenta: string | null
  fkBanco: number | null
  creadoEn: string
}

export interface MovimientoPago {
  id: number
  fkCuenta: string
  tipoDocumento: string
  noDocumento: string
  fechaOperacion: string
  monto: number
  descripcion: string
  fkUsuario: number
  usuario: string
}

export interface CxpDetalle extends CxpResumen {
  direccionFiscal: string
  banco: string
  movimientos: MovimientoPago[]
}

export interface RegistrarPagoRequest {
  fkMetodoPago: number
  fkCuenta: string
  monto: number
  descripcion?: string
}

export interface AnularCxpRequest {
  motivo?: string
}

export interface CxpResumenFinanciero {
  totalPendiente: number
  totalPagado: number
  saldoTotal: number
  cuentasPendientes: number
  cuentasVencidas: number
  cuentasPagadas: number
}

export interface MetodoPagoDto {
  codigo: number
  descripcion: string
}

export interface CuentaBancariaDto {
  numero: string
  fkBanco: number
  banco: string
  titular: string
  descripcion: string
}

export interface FiltrosCxp {
  proveedor?: string
  estado?: string
  desde?: string
  hasta?: string
  vencidas?: boolean
  pagina?: number
  tamano?: number
}

export const cxpService = {
  async listar(filtros: FiltrosCxp = {}): Promise<PagedResponse<CxpResumen>> {
    const params = new URLSearchParams()
    if (filtros.proveedor) params.append('proveedor', filtros.proveedor)
    if (filtros.estado) params.append('estado', filtros.estado)
    if (filtros.desde) params.append('desde', filtros.desde)
    if (filtros.hasta) params.append('hasta', filtros.hasta)
    if (filtros.vencidas) params.append('vencidas', 'true')
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<CxpResumen>>>(`/cxp?${params.toString()}`)
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
    const req: AnularCxpRequest = { motivo }
    await api.patch(`/cxp/${id}/anular`, req)
  },

  async vencidas(fecha?: string): Promise<CxpResumen[]> {
    const params = new URLSearchParams()
    if (fecha) params.append('fecha', fecha)
    const { data } = await api.get<ApiResponse<CxpResumen[]>>(`/cxp/vencidas?${params.toString()}`)
    return data.data
  },

  async resumen(): Promise<CxpResumenFinanciero> {
    const { data } = await api.get<ApiResponse<CxpResumenFinanciero>>('/cxp/resumen')
    return data.data
  },

  async generarDesdeCompra(compraId: number): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>(`/cxp/generar-desde-compra/${compraId}`)
    return data.data
  },

  async listarMetodosPago(): Promise<MetodoPagoDto[]> {
    const { data } = await api.get<ApiResponse<MetodoPagoDto[]>>('/cxp/catalogos/metodos-pago')
    return data.data
  },

  async listarCuentasBancarias(): Promise<CuentaBancariaDto[]> {
    const { data } = await api.get<ApiResponse<CuentaBancariaDto[]>>('/cxp/catalogos/cuentas-bancarias')
    return data.data
  }
}
