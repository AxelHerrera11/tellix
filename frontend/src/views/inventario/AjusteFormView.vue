<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Ajuste de inventario</h2>
      <router-link to="/inventario" class="btn btn-ghost">← Volver al inventario</router-link>
    </div>

    <!-- Paso 1: Explorar y seleccionar producto -->
    <div class="form-card">
      <div class="form-section">
        <h3 class="section-title" v-if="!seleccionado">1. Buscar y seleccionar producto</h3>
        <h3 class="section-title" v-else>1. Producto seleccionado</h3>

        <!-- Filtros del explorador (solo si no hay selección) -->
        <template v-if="!seleccionado">
          <div class="explorador-filtros">
            <input
              v-model="busquedaProducto"
              type="text"
              class="input filtro-busqueda"
              placeholder="Buscar por nombre o código..."
              @input="buscarConDebounce"
            />
            <select v-model="filtroCategoria" class="input filtro-select" @change="buscar">
              <option value="">Todas las categorías</option>
              <option v-for="c in categorias" :key="c.codigo" :value="c.codigo">{{ c.descripcion }}</option>
            </select>
            <span class="explorador-contador">{{ paginadoProductos?.total ?? 0 }} productos</span>
          </div>

          <div v-if="cargandoProductos" class="explorador-vacio">Cargando productos...</div>
          <div v-else-if="!productos.length" class="explorador-vacio">No se encontraron productos con esos criterios.</div>
          <div v-else class="explorador-tabla">
            <table class="data-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Producto</th>
                  <th>Marca</th>
                  <th>Medida</th>
                  <th>Categoría</th>
                  <th>Stock actual</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="p in productos" :key="p.codigo" class="row-clickeable" @click="seleccionarProducto(p)">
                  <td class="td-id">{{ p.codigo }}</td>
                  <td><span class="cell-main">{{ p.nombre }}</span></td>
                  <td class="td-sec">{{ p.marca || '—' }}</td>
                  <td class="td-sec">{{ p.medida || '—' }}</td>
                  <td class="td-sec">{{ p.categoria || '—' }}</td>
                  <td class="td-monto">{{ formatNum(p.stockActual) }}</td>
                  <td class="td-actions">
                    <button type="button" class="btn btn-xs btn-primary-outline" @click.stop="seleccionarProducto(p)">Seleccionar</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-if="paginadoProductos && paginadoProductos.totalPaginas > 1" class="explorador-paginacion">
            <button class="btn btn-ghost btn-xs" :disabled="paginaProductos <= 1" @click="irPagina(paginaProductos - 1)">← Anterior</button>
            <span class="pag-info">Página {{ paginaProductos }} de {{ paginadoProductos.totalPaginas }}</span>
            <button class="btn btn-ghost btn-xs" :disabled="paginaProductos >= paginadoProductos.totalPaginas" @click="irPagina(paginaProductos + 1)">Siguiente →</button>
          </div>
        </template>

        <!-- Producto seleccionado -->
        <div v-if="seleccionado" class="producto-seleccionado">
          <div class="ps-header">
            <div class="ps-info">
              <strong class="ps-nombre">{{ seleccionado.nombre }}</strong>
              <span class="ps-detalle">
                <template v-if="seleccionado.marca || seleccionado.medida">
                  {{ seleccionado.marca || '' }}{{ seleccionado.marca && seleccionado.medida ? ' — ' : '' }}{{ seleccionado.medida || '' }}
                </template>
                <template v-else>
                  Código: #{{ seleccionado.codigo }}
                </template>
              </span>
              <span class="ps-categoria" v-if="seleccionado.categoria">{{ seleccionado.categoria }}</span>
            </div>
            <div class="ps-stock">
              <span class="ps-stock-label">Stock actual</span>
              <span class="ps-stock-num">{{ formatNum(seleccionado.stockActual) }}</span>
            </div>
            <button type="button" class="ps-quitar" @click="quitarSeleccion" title="Cambiar producto">✕</button>
          </div>
        </div>
      </div>

      <!-- Paso 2: Cantidad y motivo -->
      <div v-if="seleccionado" class="form-section">
        <h3 class="section-title">2. Cantidad y motivo</h3>
        <div class="form-grid">
          <div class="field">
            <label class="label">Cantidad <span class="required">*</span></label>
            <div class="cantidad-control">
              <button type="button" class="btn-cantidad" @click="decrementarCantidad" :disabled="!cantidadNumerica">−</button>
              <input
                v-model="cantidadTexto"
                type="text"
                class="input input-monto"
                placeholder="0"
                @input="validarCantidad"
              />
              <button type="button" class="btn-cantidad" @click="incrementarCantidad">+</button>
            </div>
            <div v-if="errorCantidad" class="field-error">{{ errorCantidad }}</div>
            <div v-if="cantidadValida && seleccionado" class="field-preview">
              <span class="preview-tipo" :class="cantidadNumerica > 0 ? 'text-entrada' : 'text-salida'">
                {{ cantidadNumerica > 0 ? 'Entrada' : 'Salida' }}
              </span>
              de <strong>{{ formatNum(Math.abs(cantidadNumerica)) }}</strong> unidades
              — Nuevo stock: <strong class="text-primary">{{ formatNum(seleccionado.stockActual + cantidadNumerica) }}</strong>
            </div>
          </div>

          <div class="field">
            <label class="label">Motivo <span class="required">*</span></label>
            <select v-model="motivo" class="input">
              <option value="">Seleccione un motivo...</option>
              <option value="Ajuste por conteo físico">Ajuste por conteo físico</option>
              <option value="Merma / deterioro">Merma / deterioro</option>
              <option value="Producto dañado">Producto dañado</option>
              <option value="Donación">Donación</option>
              <option value="Devolución">Devolución</option>
              <option value="Corrección de inventario">Corrección de inventario</option>
              <option value="Otro">Otro</option>
            </select>
            <input v-if="motivo === 'Otro'" v-model="otroMotivo" type="text" class="input" placeholder="Describa el motivo..." />
          </div>
        </div>
      </div>

      <!-- Confirmación y envío -->
      <div v-if="seleccionado" class="form-footer">
        <router-link to="/inventario" class="btn btn-ghost">Cancelar</router-link>
        <button
          class="btn btn-primary"
          :disabled="!puedeGuardar"
          @click="confirmarAjuste"
        >
          {{ guardando ? 'Ajustando...' : 'Ajustar stock' }}
        </button>
      </div>
    </div>

    <!-- Modal de confirmación -->
    <div v-if="mostrarConfirmacion" class="modal-overlay" @click.self="mostrarConfirmacion = false">
      <div class="modal">
        <h3 class="modal-title">Confirmar ajuste</h3>
        <div class="modal-body">
          <div class="conf-item">
            <span class="conf-label">Producto</span>
            <span class="conf-value">{{ seleccionado?.nombre }}</span>
          </div>
          <div class="conf-item">
            <span class="conf-label">Stock actual</span>
            <span class="conf-value">{{ formatNum(seleccionado?.stockActual ?? 0) }}</span>
          </div>
          <div class="conf-item">
            <span class="conf-label">Ajuste</span>
            <span class="conf-value" :class="cantidadNumerica > 0 ? 'text-entrada' : 'text-salida'">
              {{ cantidadNumerica > 0 ? '+' : '' }}{{ formatNum(cantidadNumerica) }}
            </span>
          </div>
          <div class="conf-item conf-item--total">
            <span class="conf-label">Nuevo stock</span>
            <span class="conf-value text-primary">{{ formatNum((seleccionado?.stockActual ?? 0) + cantidadNumerica) }}</span>
          </div>
          <div class="conf-item">
            <span class="conf-label">Motivo</span>
            <span class="conf-value">{{ motivoFinal }}</span>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="mostrarConfirmacion = false">Cancelar</button>
          <button class="btn btn-primary" :disabled="guardando" @click="ejecutarAjuste">
            {{ guardando ? 'Ajustando...' : 'Confirmar y ajustar' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { inventarioService } from '@/services/inventario.service'
import { productoService, type ProductoResumen, type CategoriaDto } from '@/services/producto.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'

const router            = useRouter()
const toast             = useToast()

const busquedaProducto  = ref('')
const filtroCategoria   = ref('')
const productos         = ref<ProductoResumen[]>([])
const paginadoProductos = ref<PagedResponse<ProductoResumen> | null>(null)
const paginaProductos   = ref(1)
const categorias        = ref<CategoriaDto[]>([])
const cargandoProductos = ref(false)
const seleccionado      = ref<ProductoResumen | null>(null)
const cantidadTexto     = ref('')
const errorCantidad     = ref('')
const motivo            = ref('')
const otroMotivo        = ref('')
const guardando         = ref(false)
const mostrarConfirmacion = ref(false)

let timeoutBusqueda: ReturnType<typeof setTimeout> | null = null

const cantidadNumerica = computed(() => {
  const v = parseFloat(cantidadTexto.value.replace(/,/g, ''))
  return isNaN(v) ? 0 : v
})

const cantidadValida = computed(() => {
  return cantidadNumerica.value !== 0 && !errorCantidad.value
})

const motivoFinal = computed(() => motivo.value === 'Otro' ? otroMotivo.value : motivo.value)

const puedeGuardar = computed(() => {
  return seleccionado.value && cantidadValida.value && motivoFinal.value
})

function validarCantidad() {
  const v = parseFloat(cantidadTexto.value.replace(/,/g, ''))
  if (isNaN(v) || cantidadTexto.value === '') {
    errorCantidad.value = ''
    return
  }
  if (v === 0) {
    errorCantidad.value = 'La cantidad no puede ser cero.'
    return
  }
  errorCantidad.value = ''
}

function incrementarCantidad() {
  const actual = cantidadNumerica.value
  const paso = actual >= 0 ? 1 : -1
  cantidadTexto.value = String(actual + paso)
  validarCantidad()
}

function decrementarCantidad() {
  const actual = cantidadNumerica.value
  if (actual === 0) return
  const paso = actual > 0 ? -1 : 1
  cantidadTexto.value = String(actual + paso)
  validarCantidad()
}

async function cargarCatalogos() {
  try { categorias.value = await productoService.listarCategorias() } catch { }
}

async function buscar() {
  cargandoProductos.value = true
  try {
    const resp = await productoService.listar({
      busqueda: busquedaProducto.value || undefined,
      categoria: filtroCategoria.value ? Number(filtroCategoria.value) : undefined,
      estado: 'A',
      pagina: paginaProductos.value,
      tamano: 10
    })
    productos.value = resp.data
    paginadoProductos.value = resp
  } catch {
    productos.value = []
    toast.error('Error al buscar productos.')
  } finally { cargandoProductos.value = false }
}

function buscarConDebounce() {
  if (timeoutBusqueda) clearTimeout(timeoutBusqueda)
  paginaProductos.value = 1
  timeoutBusqueda = setTimeout(buscar, 300)
}

function irPagina(n: number) {
  paginaProductos.value = n
  buscar()
}

function seleccionarProducto(p: ProductoResumen) {
  seleccionado.value = p
  busquedaProducto.value = ''
  filtroCategoria.value = ''
  productos.value = []
  cantidadTexto.value = ''
  errorCantidad.value = ''
  motivo.value = ''
}

function quitarSeleccion() {
  seleccionado.value = null
  cantidadTexto.value = ''
  errorCantidad.value = ''
  motivo.value = ''
  paginaProductos.value = 1
  buscar()
}

function confirmarAjuste() {
  if (!puedeGuardar.value) return
  mostrarConfirmacion.value = true
}

async function ejecutarAjuste() {
  if (!seleccionado.value) return
  try {
    guardando.value = true
    await inventarioService.ajustar({
      fkProducto: seleccionado.value.codigo,
      cantidad:   cantidadNumerica.value,
      motivo:     motivoFinal.value
    })
    toast.exito(`Stock ajustado. Nuevo stock de "${seleccionado.value.nombre}": ${formatNum(seleccionado.value.stockActual + cantidadNumerica.value)}`)
    router.push('/inventario')
  } catch { toast.error('Error al ajustar el stock. Verifique los datos e intente de nuevo.') }
  finally {
    guardando.value = false
    mostrarConfirmacion.value = false
  }
}

function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(() => { cargarCatalogos(); buscar() })
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.form-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1.5rem }
.form-section { margin-bottom:1.5rem; padding-bottom:1.5rem; border-bottom:1px solid var(--color-border) }
.form-section:last-child { border-bottom:none; margin-bottom:0; padding-bottom:0 }
.section-title { font-size:.95rem; font-weight:600; margin-bottom:1rem; color:var(--color-text-secondary) }

/* ── Explorador de productos ── */
.explorador-filtros { display:flex; gap:8px; margin-bottom:12px; align-items:center }
.filtro-busqueda { flex:1; max-width:380px }
.filtro-select { min-width:200px }
.explorador-contador { font-size:.8rem; color:var(--color-text-muted); white-space:nowrap }
.explorador-tabla { border:1px solid var(--color-border); border-radius:10px; overflow:hidden }
.explorador-vacio { padding:2rem; text-align:center; color:var(--color-text-muted); font-size:.9rem }
.explorador-paginacion { display:flex; align-items:center; justify-content:center; gap:12px; margin-top:10px }
.pag-info { font-size:.8rem; color:var(--color-text-muted) }
.row-clickeable { cursor:pointer; transition:background .1s }
.row-clickeable:hover td { background:var(--color-primary-light) }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { background:var(--color-bg-page); padding:.6rem .75rem; text-align:left; font-weight:600; font-size:.8rem; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.data-table td { padding:.5rem .75rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.td-id { color:var(--color-text-muted); font-size:.8rem; width:50px }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums; white-space:nowrap }
.td-sec { color:var(--color-text-muted); font-size:.82rem }
.td-actions { width:90px; text-align:right }
.cell-main { font-weight:500 }

/* ── Producto seleccionado ── */
.producto-seleccionado { background:var(--color-primary-light); border:2px solid var(--color-primary); border-radius:12px; padding:1rem }
.ps-header { display:flex; align-items:center; gap:12px }
.ps-info { display:flex; flex-direction:column; gap:3px; flex:1; min-width:0 }
.ps-nombre { font-size:.95rem; font-weight:600; color:var(--color-text) }
.ps-detalle { font-size:.8rem; color:var(--color-text-secondary) }
.ps-categoria { display:inline-block; font-size:.7rem; padding:1px 8px; background:var(--color-primary-light); color:var(--color-primary); border:1px solid var(--color-primary); border-radius:4px; width:fit-content }
.ps-stock { display:flex; flex-direction:column; align-items:flex-end; gap:2px; flex-shrink:0 }
.ps-stock-label { font-size:.7rem; color:var(--color-text-muted); text-transform:uppercase }
.ps-stock-num { font-size:1.2rem; font-weight:700; color:var(--color-primary) }
.ps-quitar { width:28px; height:28px; border-radius:8px; border:1px solid var(--color-border); background:var(--color-bg-card); cursor:pointer; font-size:.8rem; color:var(--color-text-muted); display:flex; align-items:center; justify-content:center; flex-shrink:0 }
.ps-quitar:hover { background:var(--color-danger-bg); color:var(--color-danger); border-color:var(--color-danger-border) }

/* ── Formulario ── */
.field { display:flex; flex-direction:column; gap:4px }
.label { font-size:.85rem; font-weight:500; color:var(--color-text-secondary) }
.required { color:var(--color-danger) }
.input { padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-page); color:var(--color-text) }
.input:focus { outline:2px solid var(--color-primary); outline-offset:-1px; border-color:transparent }
.input-monto { font-size:1.1rem; font-weight:600 }
.field-error { font-size:.8rem; color:var(--color-danger) }
.field-preview { font-size:.85rem; color:var(--color-text-secondary); padding:.5rem .75rem; background:var(--color-bg-page); border-radius:8px }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem }
.form-footer { display:flex; justify-content:flex-end; gap:8px; padding-top:1rem }

/* ── Controles de cantidad ── */
.cantidad-control { display:flex; align-items:center; gap:0 }
.cantidad-control .btn-cantidad { width:38px; height:38px; border:1px solid var(--color-border); background:var(--color-bg-card); cursor:pointer; font-size:1rem; font-weight:600; display:flex; align-items:center; justify-content:center; color:var(--color-text) }
.cantidad-control .btn-cantidad:first-child { border-radius:8px 0 0 8px; border-right:none }
.cantidad-control .btn-cantidad:last-child { border-radius:0 8px 8px 0; border-left:none }
.cantidad-control .btn-cantidad:hover { background:var(--color-bg-page) }
.cantidad-control .btn-cantidad:disabled { opacity:.3; cursor:not-allowed }
.cantidad-control .input-monto { border-radius:0; text-align:center; width:100px; -moz-appearance:textfield }
.cantidad-control .input-monto::-webkit-outer-spin-button,
.cantidad-control .input-monto::-webkit-inner-spin-button { -webkit-appearance:none; margin:0 }

/* ── Botones ── */
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-primary-outline { background:transparent; color:var(--color-primary); border-color:var(--color-primary); font-size:.8rem; padding:.3rem .7rem }
.btn-primary-outline:hover { background:var(--color-primary); color:#fff }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-xs { padding:.25rem .6rem; font-size:.75rem; border-radius:6px }
.btn:disabled { opacity:.5; cursor:not-allowed }

/* ── Modal ── */
.modal-overlay { position:fixed; inset:0; z-index:100; background:rgba(0,0,0,.4); display:flex; align-items:center; justify-content:center }
.modal { background:var(--color-bg-card); border-radius:14px; padding:1.5rem; width:420px; max-width:90vw; box-shadow:0 8px 32px rgba(0,0,0,.2) }
.modal-title { font-size:1.05rem; font-weight:600; margin-bottom:1rem }
.modal-body { display:flex; flex-direction:column; gap:8px; margin-bottom:1.25rem }
.conf-item { display:flex; justify-content:space-between; align-items:center; padding:.4rem 0; font-size:.9rem }
.conf-item--total { padding-top:.6rem; margin-top:.4rem; border-top:1px solid var(--color-border); font-weight:600 }
.conf-label { color:var(--color-text-muted) }
.conf-value { font-weight:500 }
.modal-footer { display:flex; justify-content:flex-end; gap:8px }

/* ── Texto auxiliar ── */
.text-primary { color:var(--color-primary) }
.text-entrada { color:var(--color-success); font-weight:600 }
.text-salida { color:var(--color-danger); font-weight:600 }
</style>
