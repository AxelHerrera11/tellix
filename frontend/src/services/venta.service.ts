import api from './api'
import type { PagedResponse, ApiResponse } from './api'

// ── Tipos ─────────────────────────────────────────────────────
export interface DetalleRequest {
  fkProducto:     number
  cantidad:       number
  precioUnitario: number
  descuentos?:    number
  impuestos?:     number
}

export interface CrearVentaRequest {
  fkCliente:    string
  fkMetodoPago: number
  plazoCredito: number
  tipoPlazo?:   string
  items:        DetalleRequest[]
}

export interface VentaResumen {
  id:               number
  fkCliente:        string
  nombreCliente:    string
  fechaOperacion:   string
  estado:           string
  estadoDescripcion: string
  subtotal:         number
  totalDescuentos:  number
  totalImpuestos:   number
  total:            number
  plazoCredito:     number
  metodoPago:       string
  usuario:          string
  creadoEn:         string
}

export interface DetalleVenta {
  id:             number
  fkVenta:        number
  fkProducto:     number
  nombreProducto: string
  fkMedida:       string
  medida:         string
  cantidad:       number
  precioUnitario: number
  descuentos:     number
  impuestos:      number
  subtotal:       number
}

export interface VentaDetalle extends VentaResumen {
  nit:             string
  horaOperacion:   string
  tipoPlazo:       string
  fkMetodoPago:    number
  nombreEmpleado:  string
  items:           DetalleVenta[]
}

export interface ProductoVenta {
  codigo:      number
  nombre:      string
  descripcion: string
  stockActual: number
  fkMedida:    string
  medida:      string
  precioVenta: number
  aplicacion:  string
}

export interface ClienteVenta {
  nit:           string
  codigo:        number
  nombre:        string
  limiteCredito: number
  direccion:     string
  tipoCliente:   string
}

export interface FiltrosVenta {
  cliente?:  string
  estado?:   string
  desde?:    string
  hasta?:    string
  pagina?:   number
  tamano?:   number
}

// ── Service ───────────────────────────────────────────────────
export const ventaService = {
  async listar(filtros: FiltrosVenta = {}): Promise<PagedResponse<VentaResumen>> {
    const params = new URLSearchParams()
    if (filtros.cliente) params.append('cliente', filtros.cliente)
    if (filtros.estado)  params.append('estado',  filtros.estado)
    if (filtros.desde)   params.append('desde',   filtros.desde)
    if (filtros.hasta)   params.append('hasta',   filtros.hasta)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<VentaResumen>>>(
      `/ventas?${params.toString()}`
    )
    return data.data
  },

  async obtener(id: number): Promise<VentaDetalle> {
    const { data } = await api.get<ApiResponse<VentaDetalle>>(`/ventas/${id}`)
    return data.data
  },

  async registrar(req: CrearVentaRequest): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>('/ventas', req)
    return data.data
  },

  async anular(id: number, motivo?: string): Promise<void> {
    await api.patch(`/ventas/${id}/anular`, { motivo })
  },

  async buscarProductos(q?: string, aplicacion?: string): Promise<ProductoVenta[]> {
    const params = new URLSearchParams()
    if (q)          params.append('q',          q)
    if (aplicacion) params.append('aplicacion', aplicacion)
    const { data } = await api.get<ApiResponse<ProductoVenta[]>>(
      `/ventas/productos/buscar?${params.toString()}`
    )
    return data.data
  },

  async buscarClientes(q?: string): Promise<ClienteVenta[]> {
    const params = new URLSearchParams()
    if (q) params.append('q', q)
    const { data } = await api.get<ApiResponse<ClienteVenta[]>>(
      `/ventas/clientes/buscar?${params.toString()}`
    )
    return data.data
  }
}
