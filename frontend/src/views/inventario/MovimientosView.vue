<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Movimientos de inventario</h2>
      <router-link to="/inventario" class="btn btn-ghost">← Volver al inventario</router-link>
    </div>

    <div class="filters-bar">
      <div class="filtro-producto">
        <input
          v-model="busquedaProducto"
          type="text"
          class="filter-input"
          placeholder="Filtrar por producto..."
          @input="buscarProductos"
          @focus="mostrarSugerencias = true"
          @blur="ocultarSugerencias"
        />
        <div v-if="mostrarSugerencias && sugerencias.length" class="sugerencias">
          <button
            v-for="p in sugerencias"
            :key="p.codigo"
            type="button"
            class="sugerencia-item"
            :class="{ activo: filtroProductoId === p.codigo }"
            @click="seleccionarProducto(p)"
          >
            {{ p.nombre }}
          </button>
        </div>
        <span v-if="filtroProductoNombre" class="filtro-activo">
          {{ filtroProductoNombre }}
          <button class="filtro-quitar" @click="quitarProducto">✕</button>
        </span>
      </div>

      <select v-model="filtroOperacion" class="filter-select">
        <option value="">Todas las operaciones</option>
        <option value="ENTRADA">Entrada</option>
        <option value="SALIDA">Salida</option>
        <option value="AJUSTE">Ajuste</option>
        <option value="DEVOLUCION">Devolución</option>
      </select>

      <div class="filtro-fechas">
        <label class="fecha-label">Desde</label>
        <input v-model="filtroDesde" type="date" class="filter-input filter-date" />
        <label class="fecha-label">Hasta</label>
        <input v-model="filtroHasta" type="date" class="filter-input filter-date" />
      </div>

      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="error" class="table-empty table-error">{{ error }}</div>
      <div v-else-if="!movimientos.length" class="table-empty">
        No se encontraron movimientos<template v-if="filtroProductoNombre"> para "{{ filtroProductoNombre }}"</template>.
      </div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>Fecha</th><th>Producto</th><th>Cantidad</th><th>Tipo</th><th>Operación</th><th>Motivo / Documento</th><th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="m in movimientos" :key="m.id">
            <td class="td-id">{{ m.id }}</td>
            <td class="td-fecha">{{ formatFecha(m.fechaOperacion) }}</td>
            <td><div class="cell-main">{{ m.producto }}</div></td>
            <td class="td-monto" :class="m.cantidad > 0 ? 'td-pos' : 'td-neg'">
              {{ m.cantidad > 0 ? '+' : '' }}{{ formatNum(m.cantidad) }}
            </td>
            <td><span class="badge" :class="`badge--${m.tipoMovimiento.toLowerCase()}`">{{ m.tipoMovimiento }}</span></td>
            <td>{{ m.operacion }}</td>
            <td class="td-motivo">{{ m.motivo || m.tipoDocumento || '—' }}{{ m.noDocumento ? ' #' + m.noDocumento : '' }}</td>
            <td class="td-usuario">{{ m.usuario || '—' }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="paginado" class="pagination">
      <button class="btn btn-ghost btn-sm" :disabled="pagina === 1" @click="irPagina(pagina - 1)">← Anterior</button>
      <span class="pagination-info">Página {{ pagina }} de {{ paginado.totalPaginas }} — {{ paginado.total }} registros</span>
      <button class="btn btn-ghost btn-sm" :disabled="pagina >= paginado.totalPaginas" @click="irPagina(pagina + 1)">Siguiente →</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { inventarioService, type MovimientoDto } from '@/services/inventario.service'
import { productoService, type ProductoResumen } from '@/services/producto.service'
import type { PagedResponse } from '@/services/api'

const movimientos        = ref<MovimientoDto[]>([])
const paginado           = ref<PagedResponse<MovimientoDto> | null>(null)
const cargando           = ref(false)
const error              = ref('')
const pagina             = ref(1)
const busquedaProducto   = ref('')
const sugerencias        = ref<ProductoResumen[]>([])
const mostrarSugerencias = ref(false)
const filtroProductoId   = ref<number | undefined>(undefined)
const filtroProductoNombre = ref('')
const filtroOperacion    = ref('')
const filtroDesde        = ref('')
const filtroHasta        = ref('')

let timeoutBusqueda: ReturnType<typeof setTimeout> | null = null

function ocultarSugerencias() { setTimeout(() => mostrarSugerencias.value = false, 200) }

async function buscarProductos() {
  if (timeoutBusqueda) clearTimeout(timeoutBusqueda)
  if (busquedaProducto.value.length < 2) {
    sugerencias.value = []
    return
  }
  timeoutBusqueda = setTimeout(async () => {
    try {
      const resp = await productoService.listar({ busqueda: busquedaProducto.value, estado: 'A', tamano: 8 })
      sugerencias.value = resp.data
    } catch { sugerencias.value = [] }
  }, 300)
}

function seleccionarProducto(p: ProductoResumen) {
  filtroProductoId.value = p.codigo
  filtroProductoNombre.value = p.nombre
  busquedaProducto.value = ''
  sugerencias.value = []
  mostrarSugerencias.value = false
  buscar()
}

function quitarProducto() {
  filtroProductoId.value = undefined
  filtroProductoNombre.value = ''
  busquedaProducto.value = ''
  buscar()
}

async function cargar() {
  try {
    cargando.value = true
    error.value = ''
    const resp = await inventarioService.listarMovimientos({
      producto: filtroProductoId.value,
      operacion: filtroOperacion.value || undefined,
      desde: filtroDesde.value || undefined,
      hasta: filtroHasta.value || undefined,
      pagina: pagina.value,
      tamano: 20
    })
    movimientos.value = resp.data
    paginado.value    = resp
  } catch {
    error.value = 'Error al cargar los movimientos. Intente de nuevo.'
  } finally { cargando.value = false }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() {
  filtroProductoId.value = undefined
  filtroProductoNombre.value = ''
  busquedaProducto.value = ''
  filtroOperacion.value = ''
  filtroDesde.value = ''
  filtroHasta.value = ''
  pagina.value = 1
  cargar()
}
function irPagina(n: number) { pagina.value = n; cargar() }
function formatFecha(f: string) { return f ? new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—' }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:flex-start }
.filter-input { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text); min-width:180px }
.filter-date { min-width:140px }
.filter-select { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text) }
.filtro-producto { position:relative; display:flex; flex-direction:column; gap:4px }
.filtro-activo { display:inline-flex; align-items:center; gap:6px; padding:.25rem .5rem; background:var(--color-primary-light); border:1px solid var(--color-primary); border-radius:6px; font-size:.8rem; color:var(--color-primary) }
.filtro-quitar { width:18px; height:18px; border-radius:4px; border:none; background:transparent; cursor:pointer; font-size:.7rem; display:flex; align-items:center; justify-content:center; color:var(--color-primary) }
.filtro-quitar:hover { background:rgba(79,70,229,.1) }
.filtro-fechas { display:flex; align-items:center; gap:4px }
.fecha-label { font-size:.8rem; color:var(--color-text-muted) }
.sugerencias { position:absolute; top:100%; left:0; right:0; z-index:20; background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:8px; margin-top:2px; max-height:200px; overflow-y:auto; box-shadow:0 4px 12px rgba(0,0,0,.1) }
.sugerencia-item { display:block; width:100%; padding:.45rem .75rem; border:none; background:transparent; cursor:pointer; text-align:left; font-size:.85rem; color:var(--color-text) }
.sugerencia-item:hover { background:var(--color-bg-page) }
.sugerencia-item.activo { background:var(--color-primary-light); color:var(--color-primary); font-weight:600 }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-empty { padding:3rem; text-align:center; color:var(--color-text-muted) }
.table-error { color:var(--color-danger) }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { background:var(--color-bg-page); padding:.75rem 1rem; text-align:left; font-weight:600; font-size:.8rem; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.data-table tbody tr:hover { background:var(--color-bg-page) }
.td-id { color:var(--color-text-muted); font-size:.8rem; width:50px }
.td-fecha { font-size:.82rem; white-space:nowrap }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums; white-space:nowrap }
.td-pos { color:var(--color-success); font-weight:700 }
.td-neg { color:var(--color-danger); font-weight:700 }
.td-motivo { font-size:.82rem; color:var(--color-text-secondary); max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap }
.td-usuario { font-size:.82rem; color:var(--color-text-muted) }
.cell-main { font-weight:500 }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--entrada { background:var(--color-success-bg); color:var(--color-success); border:1px solid rgba(45,212,160,0.3) }
.badge--salida { background:var(--color-danger-bg); color:var(--color-danger); border:1px solid var(--color-danger-border) }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-secondary { background:var(--color-bg-card); color:var(--color-text); border-color:var(--color-border) }
.btn-secondary:hover { background:var(--color-bg-page) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-sm { padding:.35rem .75rem; font-size:.8rem }
.btn:disabled { opacity:.5; cursor:not-allowed }
.pagination { display:flex; align-items:center; justify-content:center; gap:1rem }
.pagination-info { font-size:.85rem; color:var(--color-text-muted) }
</style>
