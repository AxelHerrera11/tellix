<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Inventario</h2>
      <router-link to="/inventario/ajuste" class="btn btn-primary">+ Ajustar stock</router-link>
    </div>

    <div class="stats-row" v-if="!cargando">
      <div class="stat-card stat-card--critico" @click="filtroCritico = true; buscar()">
        <span class="stat-num">{{ statsCr }}</span>
        <span class="stat-label">Críticos</span>
      </div>
      <div class="stat-card stat-card--bajo">
        <span class="stat-num">{{ statsBajos }}</span>
        <span class="stat-label">Stock bajo</span>
      </div>
      <div class="stat-card stat-card--total">
        <span class="stat-num">{{ statsTotal }}</span>
        <span class="stat-label">Total productos</span>
      </div>
      <button v-if="filtroCritico" class="btn btn-sm btn-warning" @click="filtroCritico = false; buscar()">Mostrar todos</button>
    </div>

    <div class="filters-bar">
      <input v-model="busqueda" type="text" placeholder="Buscar producto..." class="filter-input" @keyup.enter="buscar" />
      <select v-model="filtroCategoria" class="filter-select">
        <option value="">Todas las categorías</option>
        <option v-for="c in categorias" :key="c.codigo" :value="c.codigo">{{ c.descripcion }}</option>
      </select>
      <select v-model="filtroEstado" class="filter-select">
        <option value="A">Solo activos</option>
        <option value="I">Solo inactivos</option>
        <option value="">Todos</option>
      </select>
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="error" class="table-empty table-error">{{ error }}</div>
      <div v-else-if="!productos.length" class="table-empty">
        {{ filtroCritico ? 'No hay productos con stock crítico.' : 'No se encontraron productos.' }}
      </div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>Producto</th><th>Categoría</th><th>Stock actual</th><th>Stock mínimo</th><th>Nivel</th><th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in productos" :key="p.codigo" :class="`row-${p.nivelStock.toLowerCase()}`">
            <td class="td-id">{{ p.codigo }}</td>
            <td><div class="cell-main">{{ p.nombre }}</div></td>
            <td>{{ p.categoria || '—' }}</td>
            <td class="td-monto">{{ formatNum(p.stockActual) }}</td>
            <td class="td-monto">{{ formatNum(p.stockMinimo) }}</td>
            <td><span class="nivel-badge" :class="`nivel--${p.nivelStock.toLowerCase()}`">{{ p.nivelStock }}</span></td>
            <td class="td-actions">
              <router-link :to="`/catalogos/productos/${p.codigo}`" class="action-btn">Ver</router-link>
            </td>
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
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { inventarioService, type StockProducto, type StockCritico } from '@/services/inventario.service'
import { productoService, type CategoriaDto } from '@/services/producto.service'
import type { PagedResponse } from '@/services/api'

const productos      = ref<StockProducto[]>([])
const categorias     = ref<CategoriaDto[]>([])
const criticos       = ref<StockCritico[]>([])
const paginado       = ref<PagedResponse<StockProducto> | null>(null)
const cargando       = ref(false)
const error          = ref('')
const pagina         = ref(1)
const busqueda       = ref('')
const filtroCategoria = ref('')
const filtroEstado   = ref('A')
const filtroCritico  = ref(false)

const statsCr = computed(() => criticos.value.length)
const statsBajos = computed(() => productos.value.filter(p => p.nivelStock === 'BAJO').length)
const statsTotal = computed(() => paginado.value?.total ?? 0)

async function cargarCatalogos() {
  try { categorias.value = await productoService.listarCategorias() } catch { }
}

async function cargarCriticos() {
  try { criticos.value = await inventarioService.stockCritico() } catch { }
}

async function cargar() {
  try {
    cargando.value = true
    error.value = ''
    const resp = await inventarioService.listarStock({
      busqueda: busqueda.value || undefined,
      categoria: filtroCategoria.value ? Number(filtroCategoria.value) : undefined,
      estado: filtroEstado.value || undefined,
      critico: filtroCritico.value,
      pagina: pagina.value,
      tamano: 20
    })
    productos.value = resp.data
    paginado.value  = resp
    if (!resp.data.length && !filtroCritico.value) error.value = 'No hay productos registrados en el inventario.'
  } catch {
    error.value = 'Error al cargar el inventario. Intente de nuevo.'
  } finally { cargando.value = false }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() {
  busqueda.value = ''
  filtroCategoria.value = ''
  filtroEstado.value = 'A'
  filtroCritico.value = false
  pagina.value = 1
  cargar()
}
function irPagina(n: number) { pagina.value = n; cargar() }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(() => { cargarCatalogos(); cargarCriticos(); cargar() })
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.stats-row { display:flex; gap:10px; align-items:center; flex-wrap:wrap }
.stat-card { display:flex; align-items:center; gap:8px; padding:.6rem 1rem; border-radius:10px; font-size:.875rem; cursor:pointer; transition:opacity .15s; font-weight:500 }
.stat-card:hover { opacity:.8 }
.stat-card--critico { background:var(--color-danger-bg); border:1px solid var(--color-danger-border); color:var(--color-danger) }
.stat-card--bajo { background:var(--color-warning-bg); border:1px solid #fde68a; color:var(--color-warning) }
.stat-card--total { background:var(--color-primary-light); border:1px solid var(--color-primary); color:var(--color-primary) }
.stat-num { font-size:1.2rem; font-weight:700 }
.stat-label { font-size:.8rem }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.filter-input { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text); min-width:200px }
.filter-select { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text) }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-empty { padding:3rem; text-align:center; color:var(--color-text-muted) }
.table-error { color:var(--color-danger) }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { background:var(--color-bg-page); padding:.75rem 1rem; text-align:left; font-weight:600; font-size:.8rem; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.td-id { color:var(--color-text-muted); font-size:.8rem; width:60px }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums }
.td-actions { width:80px }
.cell-main { font-weight:500 }
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none }
.action-btn:hover { text-decoration:underline }
.row-critico td { background:#fecaca; color:#991b1b }
.row-bajo td { background:#fde68a; color:#92400e }
.row-medio td { background:#bfdbfe; color:#1e40af }
.nivel-badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.nivel--critico { background:var(--color-danger-bg); color:var(--color-danger); border:1px solid var(--color-danger-border) }
.nivel--bajo { background:var(--color-warning-bg); color:var(--color-warning); border:1px solid #fde68a }
.nivel--medio { background:var(--color-info-bg); color:var(--color-info); border:1px solid #bfdbfe }
.nivel--ok { background:var(--color-success-bg); color:var(--color-success); border:1px solid #bbf7d0 }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-secondary { background:var(--color-bg-card); color:var(--color-text); border-color:var(--color-border) }
.btn-secondary:hover { background:var(--color-bg-page) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-warning { background:var(--color-warning); color:#fff }
.btn-warning:hover { background:#b45309 }
.btn-sm { padding:.35rem .75rem; font-size:.8rem }
.btn:disabled { opacity:.5; cursor:not-allowed }
.pagination { display:flex; align-items:center; justify-content:center; gap:1rem }
.pagination-info { font-size:.85rem; color:var(--color-text-muted) }
</style>
