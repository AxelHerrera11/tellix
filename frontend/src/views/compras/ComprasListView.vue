<template>
    <div class="page">
      <div class="page-header">
        <h2 class="page-title">Compras</h2>
        <router-link to="/compras/nueva" class="btn btn-primary">+ Nueva compra</router-link>
      </div>

      <div class="filters-bar">
        <input v-model="filtros.proveedor" type="text" placeholder="Proveedor o NIT..." class="filter-input" @keyup.enter="buscar" />
        <select v-model="filtros.estado" class="filter-select">
          <option value="">Todos los estados</option>
          <option value="P">Pendiente</option>
          <option value="A">Aprobada</option>
          <option value="C">Completada</option>
          <option value="X">Cancelada</option>
        </select>
        <input v-model="filtros.desde" type="date" class="filter-input filter-date" />
        <input v-model="filtros.hasta" type="date" class="filter-input filter-date" />
        <button class="btn btn-secondary" @click="buscar">Buscar</button>
        <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
      </div>

      <div class="table-card">
        <div v-if="cargando" class="table-empty">Cargando...</div>
        <div v-else-if="!compras.length" class="table-empty">No se encontraron compras.</div>
        <table v-else class="data-table">
          <thead>
            <tr>
              <th>#</th><th>Documento</th><th>Proveedor</th><th>Fecha</th><th>Total</th><th>Método</th><th>Estado</th><th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in compras" :key="c.id">
              <td class="td-id">{{ c.id }}</td>
              <td>{{ c.noDocumento }}</td>
              <td><div class="cell-main">{{ c.nombreProveedor }}</div></td>
              <td>{{ formatFecha(c.fechaOperacion) }}</td>
              <td class="td-monto">Q {{ formatNum(c.total) }}</td>
              <td>{{ c.metodoPago }}</td>
              <td><span class="badge" :class="`badge--${c.estado.toLowerCase()}`">{{ c.estadoDescripcion }}</span></td>
              <td class="td-actions"><router-link :to="`/compras/${c.id}`" class="action-btn">Ver</router-link></td>
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
import { compraService, type CompraResumen, type FiltrosCompra } from '@/services/compra.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'

const toast    = useToast()
const compras  = ref<CompraResumen[]>([])
const paginado = ref<PagedResponse<CompraResumen> | null>(null)
const cargando = ref(false)
const pagina   = ref(1)
const filtros  = ref<FiltrosCompra>({ proveedor: '', estado: '', desde: '', hasta: '' })

async function cargar() {
  try {
    cargando.value = true
    const resp = await compraService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 })
    compras.value   = resp.data
    paginado.value  = resp
  } catch { toast.error('Error al cargar las compras.') }
  finally { cargando.value = false }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() { filtros.value = { proveedor: '', estado: '', desde: '', hasta: '' }; buscar() }
function irPagina(n: number) { pagina.value = n; cargar() }
function formatFecha(f: string) { return f ? new Date(f + 'T00:00:00').toLocaleDateString('es-GT') : '—' }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
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
.td-actions { width:80px }
.cell-main { font-weight:500 }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--c { background:rgba(96,165,250,0.15); color:#60a5fa }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
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
