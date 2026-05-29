<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Cuentas por pagar</h2>
    </div>

    <div class="stats-row" v-if="!cargando">
      <div class="stat-card stat-card--total" @click="filtroEstado = ''; buscar()">
        <span class="stat-num">{{ statsTotal }}</span>
        <span class="stat-label">Totales</span>
      </div>
      <div class="stat-card stat-card--pendiente" @click="filtroEstado = 'P'; buscar()">
        <span class="stat-num">{{ statsPendientes }}</span>
        <span class="stat-label">Pendientes</span>
      </div>
      <div class="stat-card stat-card--abonada" @click="filtroEstado = 'A'; buscar()">
        <span class="stat-num">{{ statsAbonadas }}</span>
        <span class="stat-label">Abonadas</span>
      </div>
      <div class="stat-card stat-card--vencida" @click="irVencidas">
        <span class="stat-num">{{ statsVencidas }}</span>
        <span class="stat-label">Vencidas</span>
      </div>
      <div v-if="filtroEstado" class="badge filtro-activo" @click="filtroEstado = ''; buscar()">
        {{ estadoLabel }} ✕
      </div>
    </div>

    <div class="filters-bar">
      <input v-model="filtros.proveedor" type="text" placeholder="Proveedor..." class="filter-input"
        @keyup.enter="buscar" />
      <select v-model="filtros.estado" class="filter-select">
        <option value="">Todos los estados</option>
        <option value="P">Pendiente</option>
        <option value="A">Abonada</option>
        <option value="X">Cancelada</option>
      </select>
      <input v-model="filtros.desde" type="date" class="filter-input filter-date" />
      <input v-model="filtros.hasta" type="date" class="filter-input filter-date" />
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="!items.length" class="table-empty">No se encontraron cuentas por pagar.</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>Proveedor</th><th>Factura</th><th>Total</th><th>Pagado</th><th>Saldo</th>
            <th>Vence</th><th>Estado</th><th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.id" :class="{ 'row-vencida': estaVencida(item) }">
            <td class="td-id">{{ item.id }}</td>
            <td><div class="cell-main">{{ item.proveedor }}</div></td>
            <td>{{ item.noDocumento }}</td>
            <td class="td-monto">Q {{ formatNum(item.valorTotal) }}</td>
            <td class="td-monto">Q {{ formatNum(item.valorPagado) }}</td>
            <td class="td-monto td-bold">Q {{ formatNum(item.saldo) }}</td>
            <td>{{ formatFecha(item.fechaLimite) }}</td>
            <td>
              <span v-if="estaVencida(item) && item.estado === 'P'"
                class="badge badge--vencida">Vencida</span>
              <span v-else class="badge" :class="`badge--${item.estado.toLowerCase()}`">
                {{ item.estadoDescripcion }}
              </span>
            </td>
            <td class="td-actions"><router-link :to="`/cxp/${item.id}`" class="action-btn">Ver</router-link></td>
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
import { RouterLink, useRouter } from 'vue-router'
import { cxpService, type CxpResumen, type FiltrosCxp } from '@/services/cxp.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'

const toast    = useToast()
const router   = useRouter()
const items    = ref<CxpResumen[]>([])
const paginado = ref<PagedResponse<CxpResumen> | null>(null)
const cargando = ref(false)
const pagina   = ref(1)
const filtroEstado = ref('')
const filtros  = ref<FiltrosCxp>({ proveedor: '', estado: '', desde: '', hasta: '' })

const statsTotal = computed(() => paginado.value?.total ?? 0)
const statsPendientes = computed(() => items.value.filter(i => i.estado === 'P').length)
const statsAbonadas = computed(() => items.value.filter(i => i.estado === 'A').length)
const statsVencidas = computed(() => items.value.filter(i => estaVencida(i)).length)

const estadoLabel = computed(() => {
  const m: Record<string, string> = { P: 'Pendientes', A: 'Abonadas', X: 'Canceladas' }
  return m[filtroEstado.value] || filtroEstado.value
})

function estaVencida(item: CxpResumen) {
  return item.estado === 'P' && item.fechaLimite && new Date(item.fechaLimite) < new Date(new Date().toDateString())
}

async function cargar() {
  try {
    cargando.value = true
    const resp = await cxpService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 })
    items.value   = resp.data
    paginado.value = resp
  } catch { toast.error('Error al cargar cuentas por pagar.') }
  finally { cargando.value = false }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() {
  filtros.value = { proveedor: '', estado: '', desde: '', hasta: '' }
  filtroEstado.value = ''
  pagina.value = 1
  cargar()
}
function irPagina(n: number) { pagina.value = n; cargar() }
function irVencidas() { router.push('/cxp/vencidas') }
function formatFecha(f: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.stats-row { display:flex; gap:10px; align-items:center; flex-wrap:wrap }
.stat-card { display:flex; align-items:center; gap:8px; padding:.6rem 1rem; border-radius:10px; font-size:.875rem; cursor:pointer; transition:opacity .15s; font-weight:500 }
.stat-card:hover { opacity:.8 }
.stat-card--total { background:var(--color-primary-light); border:1px solid var(--color-primary); color:var(--color-primary) }
.stat-card--pendiente { background:rgba(251,191,36,0.15); border:1px solid rgba(251,191,36,0.3); color:#fbbf24 }
.stat-card--abonada { background:rgba(45,212,160,0.15); border:1px solid rgba(45,212,160,0.3); color:#2dd4a0 }
.stat-card--vencida { background:rgba(248,113,113,0.15); border:1px solid rgba(248,113,113,0.3); color:#f87171 }
.filtro-activo { cursor:pointer; font-size:.8rem; padding:4px 12px; background:var(--color-bg-card); border:1px solid var(--color-border) }
.stat-num { font-size:1.2rem; font-weight:700 }
.stat-label { font-size:.8rem }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.filter-input { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text); min-width:200px }
.filter-date { min-width:140px }
.filter-select { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text) }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-empty { padding:3rem; text-align:center; color:var(--color-text-muted) }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { background:var(--color-bg-page); padding:.75rem 1rem; text-align:left; font-weight:600; font-size:.8rem; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.data-table tbody tr:hover { background:var(--color-bg-page) }
.td-id { color:var(--color-text-muted); font-size:.8rem; width:60px }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums }
.td-bold { font-weight:700 }
.td-actions { width:80px }
.cell-main { font-weight:500 }
.row-vencida td { background:rgba(248,113,113,0.05) }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
.badge--vencida { background:rgba(248,113,113,0.15); color:#f87171 }
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none }
.action-btn:hover { text-decoration:underline }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-secondary { background:var(--color-bg-card); color:var(--color-text); border-color:var(--color-border) }
.btn-secondary:hover { background:var(--color-bg-page) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-sm { padding:.35rem .75rem; font-size:.8rem }
.btn:disabled { opacity:.5; cursor:not-allowed }
.pagination { display:flex; align-items:center; justify-content:center; gap:1rem }
.pagination-info { font-size:.85rem; color:var(--color-text-muted) }
</style>