<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Productos</h2>
      <router-link to="/catalogos/productos/nuevo" class="btn btn-primary">+ Nuevo producto</router-link>
    </div>

    <div class="filters-bar">
      <input v-model="filtros.busqueda" type="text" placeholder="Buscar producto..." class="filter-input" @keyup.enter="buscar" />
      <select v-model="filtros.categoria" class="filter-select">
        <option value="">Todas las categorías</option>
        <option v-for="c in categorias" :key="c.codigo" :value="c.codigo">{{ c.descripcion }}</option>
      </select>
      <select v-model="filtros.marca" class="filter-select">
        <option value="">Todas las marcas</option>
        <option v-for="m in marcas" :key="m.codigo" :value="m.codigo">{{ m.nombre }}</option>
      </select>
      <select v-model="filtros.estado" class="filter-select">
        <option value="">Todos los estados</option>
        <option value="A">Activo</option>
        <option value="I">Inactivo</option>
      </select>
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="!productos.length" class="table-empty">No se encontraron productos.</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>Nombre</th><th>Categoría</th><th>Marca</th><th>Medida</th><th>Stock</th><th>Estado</th><th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in productos" :key="p.codigo">
            <td class="td-id">{{ p.codigo }}</td>
            <td><div class="cell-main">{{ p.nombre }}</div></td>
            <td>{{ p.categoria || '—' }}</td>
            <td>{{ p.marca || '—' }}</td>
            <td>{{ p.medida || '—' }}</td>
            <td class="td-monto">{{ formatNum(p.stockActual) }}</td>
            <td><span class="badge" :class="`badge--${p.estado.toLowerCase()}`">{{ p.estadoDescripcion }}</span></td>
            <td class="td-actions">
              <label v-if="auth.tieneRol('ADMINISTRADOR')" class="switch" :class="{ 'switch--loading': cambiandoId === p.codigo }">
                <input type="checkbox" :checked="p.estado === 'A'" :disabled="cambiandoId === p.codigo" @click.prevent="toggleEstado(p.codigo, p.estado)" />
                <span class="switch-slider"></span>
              </label>
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
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { productoService, type ProductoResumen, type FiltrosProducto, type CategoriaDto, type MarcaDto } from '@/services/producto.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'

const toast       = useToast()
const auth        = useAuthStore()
const productos   = ref<ProductoResumen[]>([])
const categorias  = ref<CategoriaDto[]>([])
const marcas      = ref<MarcaDto[]>([])
const paginado    = ref<PagedResponse<ProductoResumen> | null>(null)
const cargando    = ref(false)
const cambiandoId = ref<number | null>(null)
const pagina      = ref(1)
const filtros     = ref<FiltrosProducto>({ busqueda: '', categoria: undefined, marca: undefined, estado: '' })

async function cargarCatalogos() {
  try {
    const [cat, mar] = await Promise.all([
      productoService.listarCategorias(),
      productoService.listarMarcas()
    ])
    categorias.value = cat
    marcas.value     = mar
  } catch { /* silent */ }
}

async function cargar() {
  try {
    cargando.value = true
    const resp = await productoService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 })
    productos.value = resp.data
    paginado.value  = resp
  } catch { toast.error('Error al cargar los productos.') }
  finally { cargando.value = false }
}

async function toggleEstado(codigo: number, estadoActual: string) {
  try {
    cambiandoId.value = codigo
    await productoService.cambiarEstado(codigo, { estado: estadoActual === 'A' ? 'I' : 'A' })
    toast.exito('Estado actualizado.')
    await cargar()
  } catch { toast.error('Error al cambiar estado.') }
  finally { cambiandoId.value = null }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() { filtros.value = { busqueda: '', categoria: undefined, marca: undefined, estado: '' }; buscar() }
function irPagina(n: number) { pagina.value = n; cargar() }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(() => { cargarCatalogos(); cargar() })
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.filters-bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center }
.filter-input { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text); min-width:200px }
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
.badge--a { background:#d1fae5; color:#065f46 }
.badge--i { background:#fee2e2; color:#991b1b }
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none }
.action-btn:hover { text-decoration:underline }
.switch { position:relative; display:inline-flex; align-items:center; width:36px; height:20px; margin-right:6px; vertical-align:middle }
.switch input { opacity:0; width:0; height:0 }
.switch-slider { position:absolute; inset:0; background:#cbd5e1; border-radius:20px; cursor:pointer; transition:background .2s }
.switch-slider::before { content:''; position:absolute; left:2px; top:2px; width:16px; height:16px; background:#fff; border-radius:50%; transition:transform .2s }
.switch input:checked + .switch-slider { background:#16a34a }
.switch input:checked + .switch-slider::before { transform:translateX(16px) }
.switch--loading { opacity:.5; pointer-events:none }
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
