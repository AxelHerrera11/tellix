import api from './api'
import type { PagedResponse, ApiResponse } from './api'

// ── Tipos ─────────────────────────────────────────────────────
export interface DetalleCompraRequest {
  fkProducto:     number
  cantidad:       number
  precioUnitario: number
  descuentos?:    number
  impuestos?:     number
}

export interface CrearCompraRequest {
  noDocumento:    string
  fkProveedor:    string
  fkRepresentante?: string
  fkMetodoPago:   number
  plazoCredito:   number
  items:          DetalleCompraRequest[]
}

export interface CompraResumen {
  id:                number
  noDocumento:       string
  fkProveedor:       string
  nombreProveedor:   string
  fkRepresentante:   string | null
  nombreRepresentante: string | null
  fechaOperacion:    string
  estado:            string
  estadoDescripcion: string
  subtotal:          number
  totalDescuentos:   number
  totalImpuestos:    number
  total:             number
  plazoCredito:      number
  metodoPago:        string
  usuario:           string
  creadoEn:          string
}

export interface DetalleCompra {
  id:                 number
  fkCompra:           number
  fkProducto:         number
  nombreProducto:     string
  descripcionProducto: string | null
  fkMedida:           string | null
  medida:             string | null
  cantidad:           number
  precioUnitario:     number
  descuentos:         number
  impuestos:          number
  subtotal:           number
}

export interface CompraDetalle {
  id:                number
  noDocumento:       string
  fkProveedor:       string
  nombreProveedor:   string
  direccionProveedor: string | null
  fkRepresentante:   string | null
  nombreRepresentante: string | null
  fechaOperacion:    string
  horaOperacion:     string
  estado:            string
  estadoDescripcion: string
  subtotal:          number
  totalDescuentos:   number
  totalImpuestos:    number
  total:             number
  plazoCredito:      number
  fkMetodoPago:      number
  metodoPago:        string
  usuario:           string
  nombreEmpleado:    string
  creadoEn:          string
  actualizadoEn:     string | null
  items:             DetalleCompra[]
}

export interface ProductoCompra {
  codigo:      number
  nombre:      string
  descripcion: string | null
  stockActual: number
  fkMedida:    string | null
  medida:      string | null
  estado:      string
}

export interface ProveedorCompra {
  nit:       string
  codigo:    number
  nombre:    string
  direccion: string | null
  telefono:  string | null
  email:     string | null
}

export interface MetodoPagoDto {
  codigo:      number
  nombre:      string
  descripcion: string | null
  diasCredito: number | null
  activo:      boolean
}

export interface RepresentanteDto {
  nit:      string
  codigo:   number
  nombre:   string
  telefono: string | null
  email:    string | null
}

export interface FiltrosCompra {
  proveedor?: string
  estado?:    string
  desde?:     string
  hasta?:     string
  pagina?:    number
  tamano?:    number
}

// ── Service ───────────────────────────────────────────────────
export const compraService = {
  async listar(filtros: FiltrosCompra = {}): Promise<PagedResponse<CompraResumen>> {
    const params = new URLSearchParams()
    if (filtros.proveedor) params.append('proveedor', filtros.proveedor)
    if (filtros.estado)    params.append('estado',    filtros.estado)
    if (filtros.desde)     params.append('desde',     filtros.desde)
    if (filtros.hasta)     params.append('hasta',     filtros.hasta)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<CompraResumen>>>(
      `/compras?${params.toString()}`
    )
    return data.data
  },

  async obtener(id: number): Promise<CompraDetalle> {
    const { data } = await api.get<ApiResponse<CompraDetalle>>(`/compras/${id}`)
    return data.data
  },

  async registrar(req: CrearCompraRequest): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>('/compras', req)
    return data.data
  },

  async aprobar(id: number): Promise<void> {
    await api.patch(`/compras/${id}/aprobar`)
  },

  async completar(id: number): Promise<void> {
    await api.patch(`/compras/${id}/completar`)
  },

  async anular(id: number, motivo?: string): Promise<void> {
    await api.patch(`/compras/${id}/anular`, { motivo })
  },

  async buscarProductos(q?: string): Promise<ProductoCompra[]> {
    const params = new URLSearchParams()
    if (q) params.append('q', q)
    const { data } = await api.get<ApiResponse<ProductoCompra[]>>(
      `/compras/productos/buscar?${params.toString()}`
    )
    return data.data
  },

  async buscarProveedores(q?: string): Promise<ProveedorCompra[]> {
    const params = new URLSearchParams()
    if (q) params.append('q', q)
    const { data } = await api.get<ApiResponse<ProveedorCompra[]>>(
      `/compras/proveedores/buscar?${params.toString()}`
    )
    return data.data
  },

  async listarMetodosPago(): Promise<MetodoPagoDto[]> {
    const { data } = await api.get<ApiResponse<MetodoPagoDto[]>>('/compras/metodos-pago')
    return data.data
  },

  async buscarRepresentantes(q?: string): Promise<RepresentanteDto[]> {
    const params = new URLSearchParams()
    if (q) params.append('q', q)
    const { data } = await api.get<ApiResponse<RepresentanteDto[]>>(
      `/compras/representantes/buscar?${params.toString()}`
    )
    return data.data
  }
}
