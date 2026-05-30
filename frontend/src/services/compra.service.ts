import api from './api'
import type { PagedResponse, ApiResponse } from './api'

export interface DetalleRequest {
  fkProducto:     number
  cantidad:       number
  precioUnitario: number
  descuentos?:    number
  impuestos?:     number
}

export interface CrearCompraRequest {
  noDocumento:   string
  fkProveedor:   string
  fkRepresentante?: string
  fkMetodoPago:  number
  plazoCredito:  number
  items:         DetalleRequest[]
}

export interface CompraResumen {
  id:                number
  noDocumento:       string
  fkProveedor:       string
  proveedor:         string
  fkRepresentante:   string | null
  representante:     string | null
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
  id:             number
  fkCompra:       number
  fkProducto:     number
  nombreProducto: string
  fkMedida:       string | null
  medida:         string | null
  cantidad:       number
  precioUnitario: number
  descuentos:     number
  impuestos:      number
  subtotal:       number
}

export interface CompraDetalle extends CompraResumen {
  direccionFiscal: string | null
  horaOperacion:   string
  fkMetodoPago:    number
  nombreEmpleado:  string
  items:           DetalleCompra[]
}

export interface ProductoCompra {
  codigo:      number
  nombre:      string
  descripcion: string | null
  stockActual: number
  stockMinimo: number
  fkMedida:    string | null
  medida:      string | null
}

export interface ProveedorCompra {
  nit:            string
  nombre:         string
  direccionFiscal: string | null
}

export interface RepresentanteCompra {
  nit:            string
  codigo:         number
  nombreCompleto: string
  nombre1:        string
  apellido1:      string
  telefono:       string | null
  email:          string | null
}

export interface FiltrosCompra {
  proveedor?: string
  estado?:   string
  desde?:    string
  hasta?:    string
  pagina?:   number
  tamano?:   number
}

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

  async listarRepresentantes(nit: string): Promise<RepresentanteCompra[]> {
    const { data } = await api.get<ApiResponse<RepresentanteCompra[]>>(
      `/compras/proveedores/${encodeURIComponent(nit)}/representantes`
    )
    return data.data
  }
}
