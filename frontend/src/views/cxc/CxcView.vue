<template>
  <div class="page">
    <h2 class="page-title">Cuentas por cobrar</h2>

    <div class="resume-grid">
      <div class="card"><div class="label">Saldo total</div><div class="value">Q {{ formatNum(resumen?.saldoTotal) }}</div></div>
      <div class="card"><div class="label">Total cobrado</div><div class="value">Q {{ formatNum(resumen?.totalCobrado) }}</div></div>
      <div class="card"><div class="label">Cuentas pendientes</div><div class="value">{{ resumen?.cuentasPendientes ?? 0 }}</div></div>
      <div class="card"><div class="label">Cuentas vencidas</div><div class="value">{{ resumen?.cuentasVencidas ?? 0 }}</div></div>
      <div class="card"><div class="label">Cuentas cobradas</div><div class="value">{{ resumen?.cuentasCobradas ?? 0 }}</div></div>
    </div>

    <div class="filters">
      <input v-model="filtros.cliente" class="field" placeholder="Cliente o NIT..." @keyup.enter="buscar" />
      <select v-model="filtros.estado" class="field"><option value="">Todos</option><option value="P">Pendiente</option><option value="A">Abonada</option><option value="X">Anulada</option></select>
      <input v-model="filtros.desde" class="field" type="date" />
      <input v-model="filtros.hasta" class="field" type="date" />
      <label><input v-model="filtros.vencidas" type="checkbox" /> Solo vencidas</label>
      <button class="btn" @click="buscar">Buscar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="empty">Cargando...</div>
      <div v-else-if="!registros.length" class="empty">No se encontraron cuentas por cobrar.</div>
      <table v-else class="table">
        <thead><tr><th>ID</th><th>Cliente</th><th>Venta</th><th>Fecha limite</th><th>Total</th><th>Cobrado</th><th>Saldo</th><th>Estado</th><th>Vencida</th><th></th></tr></thead>
        <tbody>
          <tr v-for="r in registros" :key="r.id">
            <td>{{ r.id }}</td><td>{{ r.cliente }}</td><td>{{ r.fkVenta }}</td><td>{{ formatFecha(r.fechaLimite) }}</td>
            <td>Q {{ formatNum(r.valorTotal) }}</td><td>Q {{ formatNum(r.valorCobrado) }}</td><td>Q {{ formatNum(r.saldo) }}</td><td>{{ r.estadoDescripcion }}</td>
            <td>{{ r.vencida ? `${r.diasVencida} dias` : 'No' }}</td>
            <td><router-link :to="`/cxc/${r.id}`">Ver</router-link></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="paginado" class="pager">
      <button class="btn" :disabled="pagina===1" @click="irPagina(pagina-1)">Anterior</button>
      <span>Pagina {{ pagina }} de {{ paginado.totalPaginas }}</span>
      <button class="btn" :disabled="pagina>=paginado.totalPaginas" @click="irPagina(pagina+1)">Siguiente</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { cxcService, type CxcResumen, type CxcResumenFinanciero, type FiltrosCxc } from '@/services/cxc.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'

const toast = useToast()
const registros = ref<CxcResumen[]>([])
const paginado = ref<PagedResponse<CxcResumen> | null>(null)
const resumen = ref<CxcResumenFinanciero | null>(null)
const cargando = ref(false)
const pagina = ref(1)
const filtros = ref<FiltrosCxc>({ cliente: '', estado: '', desde: '', hasta: '', vencidas: false })

async function cargar() {
  try {
    cargando.value = true
    const [lista, sum] = await Promise.all([
      cxcService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 }),
      cxcService.resumen()
    ])
    registros.value = lista.data
    paginado.value = lista
    resumen.value = sum
  } catch {
    toast.error('Error al cargar CXC.')
  } finally {
    cargando.value = false
  }
}
function buscar() { pagina.value = 1; cargar() }
function irPagina(n: number) { pagina.value = n; cargar() }
function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem }
.page-title { font-size:1.3rem; font-weight:600 }
.resume-grid { display:grid; grid-template-columns:repeat(5,minmax(130px,1fr)); gap:8px }
.card { border:1px solid var(--color-border); border-radius:10px; background:var(--color-bg-card); padding:.7rem }
.label { font-size:.75rem; color:var(--color-text-muted) }
.value { font-size:1.1rem; font-weight:700 }
.filters { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.field { padding:.45rem .7rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); color:var(--color-text) }
.table-card { border:1px solid var(--color-border); border-radius:10px; overflow:auto; background:var(--color-bg-card) }
.table { width:100%; border-collapse:collapse }
.table th,.table td { padding:.65rem; border-bottom:1px solid var(--color-border); text-align:left; font-size:.85rem }
.empty { padding:2rem; text-align:center; color:var(--color-text-muted) }
.pager { display:flex; justify-content:center; gap:1rem; align-items:center }
.btn { padding:.4rem .8rem; border:1px solid var(--color-border); border-radius:8px; background:transparent; color:var(--color-text); cursor:pointer }
</style>
