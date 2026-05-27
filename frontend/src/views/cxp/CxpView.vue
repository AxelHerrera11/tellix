<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Cuentas por pagar</h2>
    </div>

    <div class="resume-grid">
      <div class="resume-card">
        <div class="resume-label">Saldo total</div>
        <div class="resume-value">Q {{ formatNum(resumen?.saldoTotal) }}</div>
      </div>
      <div class="resume-card">
        <div class="resume-label">Total pagado</div>
        <div class="resume-value">Q {{ formatNum(resumen?.totalPagado) }}</div>
      </div>
      <div class="resume-card">
        <div class="resume-label">Cuentas vencidas</div>
        <div class="resume-value">{{ resumen?.cuentasVencidas ?? 0 }}</div>
      </div>
      <div class="resume-card">
        <div class="resume-label">Cuentas pagadas</div>
        <div class="resume-value">{{ resumen?.cuentasPagadas ?? 0 }}</div>
      </div>
    </div>

    <div class="filters-bar">
      <input v-model="filtros.proveedor" type="text" placeholder="Proveedor, NIT o documento..." class="filter-input" @keyup.enter="buscar" />
      <select v-model="filtros.estado" class="filter-select">
        <option value="">Todos los estados</option>
        <option value="P">Pendiente</option>
        <option value="A">Abonada</option>
        <option value="X">Anulada</option>
      </select>
      <input v-model="filtros.desde" type="date" class="filter-input filter-date" />
      <input v-model="filtros.hasta" type="date" class="filter-input filter-date" />
      <label class="check-field"><input v-model="filtros.vencidas" type="checkbox" /> Solo vencidas</label>
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="!registros.length" class="table-empty">No se encontraron cuentas por pagar.</div>
      <table v-else class="data-table">
        <thead>
        <tr>
          <th>ID</th><th>Proveedor</th><th>Doc. compra</th><th>Fecha limite</th><th>Valor total</th><th>Valor pagado</th><th>Saldo</th><th>Estado</th><th>Vencimiento</th><th></th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="r in registros" :key="r.id">
          <td class="td-id">{{ r.id }}</td>
          <td><div class="cell-main">{{ r.proveedor || r.fkProveedor }}</div></td>
          <td>{{ r.noDocumento }}</td>
          <td>{{ formatFecha(r.fechaLimite) }}</td>
          <td class="td-monto">Q {{ formatNum(r.valorTotal) }}</td>
          <td class="td-monto">Q {{ formatNum(r.valorPagado) }}</td>
          <td class="td-monto">Q {{ formatNum(r.saldo) }}</td>
          <td><span class="badge" :class="`badge--${r.estado.toLowerCase()}`">{{ r.estadoDescripcion }}</span></td>
          <td>
            <span v-if="r.vencida" class="badge badge--x">{{ r.diasVencida }} dias</span>
            <span v-else class="muted">Al dia</span>
          </td>
          <td class="td-actions"><router-link :to="`/cxp/${r.id}`" class="action-btn">Ver</router-link></td>
        </tr>
        </tbody>
      </table>
    </div>

    <div v-if="paginado" class="pagination">
      <button class="btn btn-ghost btn-sm" :disabled="pagina === 1" @click="irPagina(pagina - 1)">← Anterior</button>
      <span class="pagination-info">Pagina {{ pagina }} de {{ paginado.totalPaginas }} - {{ paginado.total }} registros</span>
      <button class="btn btn-ghost btn-sm" :disabled="pagina >= paginado.totalPaginas" @click="irPagina(pagina + 1)">Siguiente →</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { cxpService, type CxpResumen, type CxpResumenFinanciero, type FiltrosCxp } from '@/services/cxp.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'

const props = defineProps<{ soloVencidas?: boolean }>()
const route = useRoute()
const toast = useToast()
const registros = ref<CxpResumen[]>([])
const paginado = ref<PagedResponse<CxpResumen> | null>(null)
const resumen = ref<CxpResumenFinanciero | null>(null)
const cargando = ref(false)
const pagina = ref(1)
const filtros = ref<FiltrosCxp>({ proveedor: '', estado: '', desde: '', hasta: '', vencidas: !!props.soloVencidas })

async function cargar() {
  try {
    cargando.value = true
    const [listado, resumenData] = await Promise.all([
      cxpService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 }),
      cxpService.resumen()
    ])
    registros.value = listado.data
    paginado.value = listado
    resumen.value = resumenData
  } catch {
    toast.error('Error al cargar cuentas por pagar.')
  } finally {
    cargando.value = false
  }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() {
  filtros.value = { proveedor: '', estado: '', desde: '', hasta: '', vencidas: !!props.soloVencidas }
  buscar()
}
function irPagina(n: number) { pagina.value = n; cargar() }
function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }

watch(() => route.fullPath, () => {
  filtros.value.vencidas = !!props.soloVencidas
  buscar()
})

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.resume-grid { display:grid; gap:10px; grid-template-columns:repeat(4,minmax(180px,1fr)) }
.resume-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:.85rem 1rem }
.resume-label { color:var(--color-text-muted); font-size:.78rem; text-transform:uppercase; letter-spacing:.03em }
.resume-value { font-size:1.15rem; font-weight:700; margin-top:4px }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.filter-input { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text); min-width:200px }
.filter-date { min-width:140px }
.filter-select { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text) }
.check-field { display:flex; align-items:center; gap:6px; font-size:.85rem; color:var(--color-text-secondary) }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:auto }
.table-empty { padding:3rem; text-align:center; color:var(--color-text-muted) }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem; min-width:980px }
.data-table th { background:var(--color-bg-page); padding:.75rem 1rem; text-align:left; font-weight:600; font-size:.8rem; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.data-table tbody tr:hover { background:var(--color-bg-page) }
.td-id { color:var(--color-text-muted); font-size:.8rem; width:60px }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums }
.td-actions { width:80px }
.cell-main { font-weight:500 }
.muted { color:var(--color-text-muted); font-size:.8rem }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none }
.action-btn:hover { text-decoration:underline }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-secondary { background:var(--color-bg-card); color:var(--color-text); border-color:var(--color-border) }
.btn-secondary:hover { background:var(--color-bg-page) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-sm { padding:.35rem .75rem; font-size:.8rem }
.btn:disabled { opacity:.5; cursor:not-allowed }
.pagination { display:flex; align-items:center; justify-content:center; gap:1rem }
.pagination-info { font-size:.85rem; color:var(--color-text-muted) }
@media (max-width: 1000px) { .resume-grid { grid-template-columns:repeat(2,minmax(150px,1fr)) } }
@media (max-width: 640px) { .resume-grid { grid-template-columns:1fr } }
</style>
