<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">CXP vencidas</h2>
      <router-link to="/cxp" class="btn btn-ghost">← Volver a CXP</router-link>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="error" class="table-empty table-error">{{ error }}</div>
      <div v-else-if="!items.length" class="table-empty">No hay cuentas por pagar vencidas.</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>Proveedor</th><th>Factura</th><th>Total</th><th>Pagado</th><th>Saldo</th>
            <th>Vence</th><th>Días vencida</th><th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.id">
            <td class="td-id">{{ item.id }}</td>
            <td><div class="cell-main">{{ item.proveedor }}</div></td>
            <td>{{ item.noDocumento }}</td>
            <td class="td-monto">Q {{ formatNum(item.valorTotal) }}</td>
            <td class="td-monto">Q {{ formatNum(item.valorPagado) }}</td>
            <td class="td-monto td-bold">Q {{ formatNum(item.saldo) }}</td>
            <td>{{ formatFecha(item.fechaLimite) }}</td>
            <td><span class="dias-badge" :class="diasClass(item.diasVencida)">{{ item.diasVencida }} días</span></td>
            <td class="td-actions"><router-link :to="`/cxp/${item.id}`" class="action-btn">Ver</router-link></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { cxpService, type CxpVencida } from '@/services/cxp.service'

const items    = ref<CxpVencida[]>([])
const cargando = ref(false)
const error    = ref('')

onMounted(async () => {
  try {
    cargando.value = true
    items.value = await cxpService.reporteVencidas()
  } catch {
    error.value = 'Error al cargar el reporte.'
  } finally { cargando.value = false }
})

function diasClass(dias: number) {
  if (dias > 90) return 'dias--critico'
  if (dias > 30) return 'dias--alto'
  return 'dias--medio'
}

function formatFecha(f: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-empty { padding:3rem; text-align:center; color:var(--color-text-muted) }
.table-error { color:var(--color-danger) }
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
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none }
.action-btn:hover { text-decoration:underline }
.dias-badge { display:inline-block; padding:3px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.dias--critico { background:rgba(248,113,113,0.15); color:#f87171 }
.dias--alto { background:rgba(251,191,36,0.15); color:#fbbf24 }
.dias--medio { background:rgba(96,165,250,0.15); color:#60a5fa }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
</style>