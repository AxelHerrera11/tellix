import api from './api'
import type { ApiResponse, PagedResponse } from './api'

export interface CxcResumen {
  id: number
  fkVenta: number
  fkCliente: string
  cliente: string
  fechaOperacion: string
  fechaLimite: string
  estado: string
  estadoDescripcion: string
  valorTotal: number
  valorCobrado: number
  saldo: number
  cobrada: boolean
  vencida: boolean
  diasVencida: number
  fkMetodoPago: number
  metodoPago: string
  fkCuenta: string | null
  creadoEn: string
}

export interface MovimientoCobro {
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

export interface CxcDetalle extends CxcResumen {
  direccion: string
  banco: string
  movimientos: MovimientoCobro[]
}

export interface RegistrarCobroRequest { fkMetodoPago: number; fkCuenta: string; monto: number; descripcion?: string }
export interface AnularCxcRequest { motivo?: string }
export interface CxcResumenFinanciero { totalPendiente: number; totalCobrado: number; saldoTotal: number; cuentasPendientes: number; cuentasVencidas: number; cuentasCobradas: number }
export interface MetodoCobroDto { codigo: number; descripcion: string }
export interface CuentaBancariaDto { numero: string; fkBanco: number; banco: string; titular: string; descripcion: string }
export interface FiltrosCxc { cliente?: string; estado?: string; desde?: string; hasta?: string; vencidas?: boolean; pagina?: number; tamano?: number }

export const cxcService = {
  async listar(filtros: FiltrosCxc = {}): Promise<PagedResponse<CxcResumen>> {
    const params = new URLSearchParams()
    if (filtros.cliente) params.append('cliente', filtros.cliente)
    if (filtros.estado) params.append('estado', filtros.estado)
    if (filtros.desde) params.append('desde', filtros.desde)
    if (filtros.hasta) params.append('hasta', filtros.hasta)
    if (filtros.vencidas) params.append('vencidas', 'true')
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))
    const { data } = await api.get<ApiResponse<PagedResponse<CxcResumen>>>(`/cxc?${params.toString()}`)
    return data.data
  },
  async obtener(id: number): Promise<CxcDetalle> { const { data } = await api.get<ApiResponse<CxcDetalle>>(`/cxc/${id}`); return data.data },
  async registrarCobro(id: number, req: RegistrarCobroRequest): Promise<void> { await api.post(`/cxc/${id}/cobros`, req) },
  async anular(id: number, motivo?: string): Promise<void> { await api.patch(`/cxc/${id}/anular`, { motivo } as AnularCxcRequest) },
  async vencidas(fecha?: string): Promise<CxcResumen[]> {
    const params = new URLSearchParams(); if (fecha) params.append('fecha', fecha)
    const { data } = await api.get<ApiResponse<CxcResumen[]>>(`/cxc/vencidas?${params.toString()}`)
    return data.data
  },
  async resumen(): Promise<CxcResumenFinanciero> { const { data } = await api.get<ApiResponse<CxcResumenFinanciero>>('/cxc/resumen'); return data.data },
  async generarDesdeVenta(ventaId: number): Promise<number> { const { data } = await api.post<ApiResponse<number>>(`/cxc/generar-desde-venta/${ventaId}`); return data.data },
  async listarMetodosCobro(): Promise<MetodoCobroDto[]> { const { data } = await api.get<ApiResponse<MetodoCobroDto[]>>('/cxc/catalogos/metodos-cobro'); return data.data },
  async listarCuentasBancarias(): Promise<CuentaBancariaDto[]> { const { data } = await api.get<ApiResponse<CuentaBancariaDto[]>>('/cxc/catalogos/cuentas-bancarias'); return data.data }
}
