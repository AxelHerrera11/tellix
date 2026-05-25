import api from './api'
import type { PagedResponse, ApiResponse } from './api'

// ── Tipos ─────────────────────────────────────────────────────
export interface ProductoResumen {
  codigo:          number
  nombre:          string
  descripcion:     string | null
  stockActual:     number
  stockMinimo:     number | null
  estado:          string
  estadoDescripcion: string
  categoriaCodigo: number | null
  categoria:       string | null
  marcaCodigo:     number | null
  marca:           string | null
  medidaCodigo:    string | null
  medida:          string | null
  cantidadMedida:  number | null
  creadoEn:        string | null
  actualizadoEn:   string | null
}

export interface PrecioProducto {
  id:             number
  fkProducto:     number
  precioVenta:    number
  aplicacion:     string
  inicioVigencia: string | null
  finVigencia:    string | null
  estado:         string
  creadoPor:      number | null
  creadoEn:       string | null
}

export interface ImpuestoAsignado {
  id:             number
  fkImpuesto:     number
  impuesto:       string
  tipoCalculo:    string
  valorBase:      number
  valorOverride:  number | null
  aplicaciones:   string | null
  fechaInicio:    string | null
  fechaFin:       string | null
  estado:         string
}

export interface DescuentoAsignado {
  id:             number
  fkDescuento:    number
  descuento:      string
  tipoCalculo:    string
  valorBase:      number
  valorOverride:  number | null
  aplicaciones:   string | null
  fechaInicio:    string | null
  fechaFin:       string | null
  estado:         string
}

export interface ProductoDetalle {
  codigo:          number
  nombre:          string
  descripcion:     string | null
  stockActual:     number
  stockMinimo:     number | null
  estado:          string
  estadoDescripcion: string
  categoriaCodigo: number | null
  categoria:       string | null
  marcaCodigo:     number | null
  marca:           string | null
  medidaCodigo:    string | null
  medida:          string | null
  cantidadMedida:  number | null
  creadoEn:        string | null
  actualizadoEn:   string | null
  precios:         PrecioProducto[]
  impuestos:       ImpuestoAsignado[]
  descuentos:      DescuentoAsignado[]
}

export interface CategoriaDto {
  codigo:      number
  descripcion: string
  activo:      boolean
}

export interface MarcaDto {
  codigo:      number
  nombre:      string
  descripcion: string
  activo:      boolean
}

export interface MedidaDto {
  codigo:      string
  descripcion: string
}

export interface ImpuestoDto {
  codigo:      number
  descripcion: string
  tipoCalculo: string
  valor:       number
  activo:      boolean
}

export interface DescuentoDto {
  codigo:      number
  descripcion: string
  tipoCalculo: string
  valor:       number
  activo:      boolean
}

export interface CrearProductoRequest {
  nombre:          string
  descripcion?:    string
  stockMinimo?:    number
  fkCategoria?:    number
  fkMarca?:        number
  fkMedida?:       string
  cantidadMedida?: number
  precioVenta?:    number
  aplicacion?:     string
}

export interface ActualizarProductoRequest {
  nombre:          string
  descripcion?:    string
  stockMinimo?:    number
  fkCategoria?:    number
  fkMarca?:        number
  fkMedida?:       string
  cantidadMedida?: number
}

export interface CambiarEstadoRequest {
  estado: 'A' | 'I'
}

export interface AsignarPrecioRequest {
  precioVenta:    number
  aplicacion:     string
  inicioVigencia?: string
}

export interface FiltrosProducto {
  busqueda?:  string
  categoria?: number
  marca?:     number
  estado?:    string
  pagina?:    number
  tamano?:    number
}

// ── Service ───────────────────────────────────────────────────
export const productoService = {
  async listar(filtros: FiltrosProducto = {}): Promise<PagedResponse<ProductoResumen>> {
    const params = new URLSearchParams()
    if (filtros.busqueda)  params.append('busqueda',  filtros.busqueda)
    if (filtros.categoria) params.append('categoria', String(filtros.categoria))
    if (filtros.marca)     params.append('marca',     String(filtros.marca))
    if (filtros.estado)    params.append('estado',    filtros.estado)
    params.append('pagina', String(filtros.pagina ?? 1))
    params.append('tamano', String(filtros.tamano ?? 20))

    const { data } = await api.get<ApiResponse<PagedResponse<ProductoResumen>>>(
      `/productos?${params.toString()}`
    )
    return data.data
  },

  async obtener(id: number): Promise<ProductoDetalle> {
    const { data } = await api.get<ApiResponse<ProductoDetalle>>(`/productos/${id}`)
    return data.data
  },

  async crear(req: CrearProductoRequest): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>('/productos', req)
    return data.data
  },

  async actualizar(id: number, req: ActualizarProductoRequest): Promise<void> {
    await api.put(`/productos/${id}`, req)
  },

  async cambiarEstado(id: number, req: CambiarEstadoRequest): Promise<void> {
    await api.patch(`/productos/${id}/estado`, req)
  },

  async asignarPrecio(id: number, req: AsignarPrecioRequest): Promise<number> {
    const { data } = await api.post<ApiResponse<number>>(`/productos/${id}/precios`, req)
    return data.data
  },

  async listarCategorias(): Promise<CategoriaDto[]> {
    const { data } = await api.get<ApiResponse<CategoriaDto[]>>('/productos/categorias')
    return data.data
  },

  async listarMarcas(): Promise<MarcaDto[]> {
    const { data } = await api.get<ApiResponse<MarcaDto[]>>('/productos/marcas')
    return data.data
  },

  async listarMedidas(): Promise<MedidaDto[]> {
    const { data } = await api.get<ApiResponse<MedidaDto[]>>('/productos/medidas')
    return data.data
  },

  async listarImpuestos(): Promise<ImpuestoDto[]> {
    const { data } = await api.get<ApiResponse<ImpuestoDto[]>>('/productos/impuestos')
    return data.data
  },

  async listarDescuentos(): Promise<DescuentoDto[]> {
    const { data } = await api.get<ApiResponse<DescuentoDto[]>>('/productos/descuentos')
    return data.data
  }
}
