<template>
  <div class="page">
    <h2 class="page-title">CXC vencidas</h2>
    <div class="filters"><input v-model="fecha" class="field" type="date" /><button class="btn" @click="cargar">Consultar</button></div>
    <div class="table-card">
      <div v-if="cargando" class="empty">Cargando...</div>
      <div v-else-if="!registros.length" class="empty">No hay cuentas vencidas.</div>
      <table v-else class="table">
        <thead><tr><th>CXC</th><th>Cliente</th><th>Venta</th><th>Fecha limite</th><th>Dias vencida</th><th>Total</th><th>Cobrado</th><th>Saldo</th><th></th></tr></thead>
        <tbody>
          <tr v-for="r in registros" :key="r.id">
            <td>{{ r.id }}</td><td>{{ r.cliente }}</td><td>{{ r.fkVenta }}</td><td>{{ formatFecha(r.fechaLimite) }}</td><td>{{ r.diasVencida }}</td><td>Q {{ formatNum(r.valorTotal) }}</td><td>Q {{ formatNum(r.valorCobrado) }}</td><td>Q {{ formatNum(r.saldo) }}</td>
            <td><router-link :to="`/cxc/${r.id}`">Ver</router-link></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { cxcService, type CxcVencida } from '@/services/cxc.service'
import { useToast } from '@/composables/useToast'

const toast = useToast()
const registros = ref<CxcVencida[]>([])
const fecha = ref('')
const cargando = ref(false)

async function cargar() {
  try {
    cargando.value = true
    registros.value = await cxcService.vencidas(fecha.value || undefined)
  } catch {
    toast.error('Error al cargar CXC vencidas.')
  } finally {
    cargando.value = false
  }
}

function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }

cargar()
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem }
.page-title { font-size:1.3rem; font-weight:600 }
.filters { display:flex; gap:8px; align-items:center }
.field { padding:.45rem .7rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); color:var(--color-text) }
.btn { padding:.45rem .8rem; border:1px solid var(--color-border); border-radius:8px; background:transparent; color:var(--color-text); cursor:pointer }
.table-card { border:1px solid var(--color-border); border-radius:10px; overflow:auto; background:var(--color-bg-card) }
.table { width:100%; border-collapse:collapse }
.table th,.table td { padding:.65rem; border-bottom:1px solid var(--color-border); text-align:left; font-size:.85rem }
.empty { padding:2rem; text-align:center; color:var(--color-text-muted) }
</style>
