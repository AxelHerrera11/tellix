<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Precios</h2>
      <router-link v-if="auth.tieneRol('ADMINISTRADOR')" to="/precios/nuevo" class="btn btn-primary">+ Nuevo precio</router-link>
    </div>
    <div class="filters-bar">
      <input v-model="filtros.busqueda" class="filter-input" type="text" placeholder="Producto o aplicacion..." @keyup.enter="buscar" />
      <input v-model="filtros.aplicacion" class="filter-input" type="text" placeholder="Aplicacion" />
      <select v-model="filtros.estado" class="filter-select"><option value="">Todos</option><option value="A">Activo</option><option value="I">Inactivo</option></select>
      <label class="check-field"><input v-model="filtros.vigentes" type="checkbox" /> Vigentes</label>
      <input v-model="filtros.fecha" class="filter-input filter-date" type="date" />
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
    </div>
    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="!registros.length" class="table-empty">No hay precios.</div>
      <table v-else class="data-table"><thead><tr><th>ID</th><th>Producto</th><th>Aplicacion</th><th>Precio venta</th><th>Inicio</th><th>Fin</th><th>Estado</th><th>Vigente</th><th></th></tr></thead><tbody><tr v-for="p in registros" :key="p.id"><td>{{ p.id }}</td><td>{{ p.producto }}</td><td>{{ p.aplicacion }}</td><td class="td-monto">Q {{ formatNum(p.precioVenta) }}</td><td>{{ formatFecha(p.inicioVigencia) }}</td><td>{{ formatFecha(p.finVigencia || undefined) }}</td><td>{{ p.estadoDescripcion }}</td><td>{{ p.vigente ? 'Si' : 'No' }}</td><td><router-link :to="`/precios/${p.id}`" class="action-btn">Ver</router-link></td></tr></tbody></table>
    </div>
    <div v-if="paginado" class="pagination"><button class="btn btn-ghost btn-sm" :disabled="pagina===1" @click="irPagina(pagina-1)">← Anterior</button><span class="pagination-info">Pagina {{ pagina }} de {{ paginado.totalPaginas }}</span><button class="btn btn-ghost btn-sm" :disabled="pagina>=paginado.totalPaginas" @click="irPagina(pagina+1)">Siguiente →</button></div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { precioService, type FiltrosPrecio, type PrecioResumen } from '@/services/precio.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'

const toast = useToast(); const auth = useAuthStore()
const registros = ref<PrecioResumen[]>([]); const paginado = ref<PagedResponse<PrecioResumen> | null>(null); const cargando = ref(false); const pagina = ref(1)
const filtros = ref<FiltrosPrecio>({ busqueda: '', aplicacion: '', estado: '', vigentes: true, fecha: '' })
async function cargar() { try { cargando.value = true; const r = await precioService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 }); registros.value = r.data; paginado.value = r } catch { toast.error('Error al cargar precios.') } finally { cargando.value = false } }
function buscar() { pagina.value = 1; cargar() }
function irPagina(n: number) { pagina.value = n; cargar() }
function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }
onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem } .page-header { display:flex; justify-content:space-between; align-items:center } .page-title { font-size:1.3rem; font-weight:600 }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center } .filter-input,.filter-select { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); color:var(--color-text) }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:auto } .table-empty { padding:2rem; text-align:center; color:var(--color-text-muted) }
.data-table { width:100%; border-collapse:collapse; min-width:900px } .data-table th,.data-table td { padding:.7rem; border-bottom:1px solid var(--color-border); text-align:left }
.td-monto { font-weight:600 } .action-btn { color:var(--color-primary); text-decoration:none }
.btn { padding:.5rem 1rem; border-radius:8px; border:1px solid transparent; cursor:pointer; text-decoration:none } .btn-primary { background:var(--color-primary); color:#fff } .btn-secondary,.btn-ghost { border-color:var(--color-border); color:var(--color-text-secondary) }
</style>
