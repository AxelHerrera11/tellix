<template>
  <div class="page">
    <div class="header">
      <h2 class="page-title">Precios</h2>
      <router-link v-if="auth.tieneRol('ADMINISTRADOR')" to="/precios/nuevo" class="btn">+ Nuevo precio</router-link>
    </div>

    <div class="filters">
      <select v-model.number="filtros.producto" class="field"><option :value="undefined">Todos los productos</option><option v-for="p in productos" :key="p.codigo" :value="p.codigo">{{ p.nombre }}</option></select>
      <input v-model="filtros.busqueda" class="field" placeholder="Buscar producto o aplicacion" />
      <input v-model="filtros.aplicacion" class="field" placeholder="Aplicacion" />
      <select v-model="filtros.estado" class="field"><option value="">Todos</option><option value="A">Activo</option><option value="I">Inactivo</option></select>
      <label><input v-model="filtros.vigentes" type="checkbox" /> Vigentes</label>
      <input v-model="filtros.fecha" class="field" type="date" />
      <button class="btn" @click="buscar">Buscar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="empty">Cargando...</div>
      <div v-else-if="!registros.length" class="empty">No hay precios registrados.</div>
      <table v-else class="table">
        <thead><tr><th>ID</th><th>Producto</th><th>Aplicacion</th><th>Precio</th><th>Inicio</th><th>Fin</th><th>Estado</th><th>Vigente</th><th></th></tr></thead>
        <tbody>
          <tr v-for="p in registros" :key="p.id">
            <td>{{ p.id }}</td><td>{{ p.producto }}</td><td>{{ p.aplicacion }}</td><td>Q {{ formatNum(p.precioVenta) }}</td><td>{{ formatFecha(p.inicioVigencia) }}</td><td>{{ formatFecha(p.finVigencia || undefined) }}</td><td>{{ p.estadoDescripcion || p.estado }}</td><td>{{ p.vigente ? 'Si' : 'No' }}</td>
            <td><router-link :to="`/precios/${p.id}`">Ver</router-link></td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="paginado" class="pager"><button class="btn" :disabled="pagina===1" @click="irPagina(pagina-1)">Anterior</button><span>Pagina {{ pagina }} de {{ paginado.totalPaginas }}</span><button class="btn" :disabled="pagina>=paginado.totalPaginas" @click="irPagina(pagina+1)">Siguiente</button></div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { precioService, type FiltrosPrecio, type PrecioResumen, type ProductoPrecioDto } from '@/services/precio.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'

const toast = useToast(); const auth = useAuthStore()
const registros = ref<PrecioResumen[]>([])
const productos = ref<ProductoPrecioDto[]>([])
const paginado = ref<PagedResponse<PrecioResumen> | null>(null)
const cargando = ref(false)
const pagina = ref(1)
const filtros = ref<FiltrosPrecio>({ estado: '', vigentes: false, busqueda: '', aplicacion: '', fecha: '' })

async function cargar() {
  try {
    cargando.value = true
    const [lista, prods] = await Promise.all([
      precioService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 }),
      precioService.listarProductos()
    ])
    registros.value = lista.data
    paginado.value = lista
    productos.value = prods
  } catch {
    toast.error('Error al cargar precios.')
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
.header { display:flex; justify-content:space-between; align-items:center }
.page-title { font-size:1.3rem; font-weight:600 }
.filters { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.field { padding:.45rem .7rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); color:var(--color-text) }
.table-card { border:1px solid var(--color-border); border-radius:10px; overflow:auto; background:var(--color-bg-card) }
.table { width:100%; border-collapse:collapse }
.table th,.table td { padding:.65rem; border-bottom:1px solid var(--color-border); text-align:left; font-size:.85rem }
.empty { padding:2rem; text-align:center; color:var(--color-text-muted) }
.pager { display:flex; justify-content:center; gap:1rem; align-items:center }
.btn { padding:.45rem .8rem; border:1px solid var(--color-border); border-radius:8px; background:transparent; color:var(--color-text); cursor:pointer; text-decoration:none }
</style>
