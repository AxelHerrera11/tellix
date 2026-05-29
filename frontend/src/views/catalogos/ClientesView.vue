<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Clientes</h2>
      <button class="btn btn-primary" @click="abrirModalNuevo">+ Nuevo cliente</button>
    </div>

    <div class="filters-bar">
      <input v-model="filtros.busqueda" type="text" placeholder="Buscar por nombre o NIT..." class="filter-input" @keyup.enter="buscar" />
      <select v-model="filtros.estado" class="filter-select">
        <option value="">Todos los estados</option>
        <option value="A">Activo</option>
        <option value="I">Inactivo</option>
      </select>
      <select v-model="filtros.tipo" class="filter-select">
        <option :value="undefined">Todos los tipos</option>
        <option :value="1">Consumidor final</option>
        <option :value="2">Pequeño contribuyente</option>
        <option :value="3">Régimen general</option>
      </select>
      <button class="btn btn-secondary" @click="buscar">Buscar</button>
      <button class="btn btn-ghost" @click="limpiar">Limpiar</button>
    </div>

    <div class="table-card">
      <div v-if="cargando" class="table-empty">Cargando...</div>
      <div v-else-if="!clientes.length" class="table-empty">No se encontraron clientes.</div>
      <table v-else class="data-table">
        <thead>
          <tr>
            <th>#</th><th>NIT</th><th>Nombre</th><th>Teléfono</th><th>Email</th><th>Límite crédito</th><th>Tipo</th><th>Estado</th><th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in clientes" :key="c.codigo">
            <td class="td-id">{{ c.codigo }}</td>
            <td>{{ c.nit }}</td>
            <td><div class="cell-main">{{ c.nombre }}</div></td>
            <td>{{ c.telefono || '—' }}</td>
            <td>{{ c.email || '—' }}</td>
            <td class="td-monto">{{ formatNum(c.limiteCredito) }}</td>
            <td>{{ c.tipoCliente || '—' }}</td>
            <td><span class="badge" :class="`badge--${c.estado.toLowerCase()}`">{{ c.estadoDescripcion }}</span></td>
            <td class="td-actions">
              <button class="action-btn" @click="abrirModalEditar(c)">Editar</button>
              <label v-if="auth.tieneRol('ADMINISTRADOR')" class="switch" :class="{ 'switch--loading': cambiandoId === c.codigo }">
                <input type="checkbox" :checked="c.estado === 'A'" :disabled="cambiandoId === c.codigo" @click.prevent="toggleEstado(c.codigo, c.estado)" />
                <span class="switch-slider"></span>
              </label>
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

    <div v-if="modalVisible" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-content">
        <h3>{{ editando ? 'Editar cliente' : 'Nuevo cliente' }}</h3>
        <form @submit.prevent="guardar" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label>NIT *</label>
              <input v-model="form.nit" type="text" :disabled="editando" :required="!editando" class="form-input" />
            </div>
            <div class="form-group">
              <label>1er nombre *</label>
              <input v-model="form.nombre1" type="text" required class="form-input" />
            </div>
            <div class="form-group">
              <label>2do nombre</label>
              <input v-model="form.nombre2" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>3er nombre</label>
              <input v-model="form.nombre3" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>1er apellido *</label>
              <input v-model="form.apellido1" type="text" required class="form-input" />
            </div>
            <div class="form-group">
              <label>2do apellido</label>
              <input v-model="form.apellido2" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>Apellido casada</label>
              <input v-model="form.apellidoCasada" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>Dirección</label>
              <input v-model="form.direccion" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>Tipo de cliente *</label>
              <select v-model="form.fkTipoCliente" required class="form-input">
                <option :value="1">Consumidor final</option>
                <option :value="2">Pequeño contribuyente</option>
                <option :value="3">Régimen general</option>
              </select>
            </div>
            <div class="form-group">
              <label>Límite de crédito *</label>
              <input v-model="form.limiteCredito" type="number" step="0.01" min="0" required class="form-input" />
            </div>
            <div class="form-group">
              <label>Teléfono</label>
              <input v-model="form.telefono" type="text" class="form-input" />
            </div>
            <div class="form-group">
              <label>Email</label>
              <input v-model="form.email" type="email" class="form-input" />
            </div>
          </div>
          <div class="modal-actions">
            <button type="button" class="btn btn-ghost" @click="cerrarModal">Cancelar</button>
            <button type="submit" class="btn btn-primary" :disabled="guardando">
              {{ guardando ? 'Guardando...' : (editando ? 'Actualizar' : 'Crear') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { clienteService, type ClienteResumen, type FiltrosCliente } from '@/services/cliente.service'
import type { PagedResponse } from '@/services/api'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'

const toast       = useToast()
const auth        = useAuthStore()
const clientes    = ref<ClienteResumen[]>([])
const paginado    = ref<PagedResponse<ClienteResumen> | null>(null)
const cargando    = ref(false)
const cambiandoId = ref<number | null>(null)
const pagina      = ref(1)
const filtros     = ref<FiltrosCliente>({ busqueda: '', estado: '', tipo: undefined })

const modalVisible = ref(false)
const editando     = ref(false)
const editandoId   = ref<number | null>(null)
const guardando    = ref(false)
const form = ref({
  nit: '',
  nombre1: '',
  nombre2: '',
  nombre3: '',
  apellido1: '',
  apellido2: '',
  apellidoCasada: '',
  direccion: '',
  fkTipoCliente: 1,
  limiteCredito: 0,
  telefono: '',
  email: ''
})

async function cargar() {
  try {
    cargando.value = true
    const resp = await clienteService.listar({ ...filtros.value, pagina: pagina.value, tamano: 20 })
    clientes.value = resp.data
    paginado.value = resp
  } catch { toast.error('Error al cargar los clientes.') }
  finally { cargando.value = false }
}

async function toggleEstado(codigo: number, estadoActual: string) {
  try {
    cambiandoId.value = codigo
    await clienteService.cambiarEstado(codigo, { estado: estadoActual === 'A' ? 'I' : 'A' })
    toast.exito('Estado actualizado.')
    await cargar()
  } catch { toast.error('Error al cambiar estado.') }
  finally { cambiandoId.value = null }
}

function abrirModalNuevo() {
  editando.value = false
  editandoId.value = null
  form.value = { nit: '', nombre1: '', nombre2: '', nombre3: '', apellido1: '', apellido2: '', apellidoCasada: '', direccion: '', fkTipoCliente: 1, limiteCredito: 0, telefono: '', email: '' }
  modalVisible.value = true
}

function abrirModalEditar(c: ClienteResumen) {
  editando.value = true
  editandoId.value = c.codigo
  form.value = {
    nit: c.nit,
    nombre1: c.nombre1,
    nombre2: c.nombre2 || '',
    nombre3: c.nombre3 || '',
    apellido1: c.apellido1,
    apellido2: c.apellido2 || '',
    apellidoCasada: c.apellidoCasada || '',
    direccion: c.direccion || '',
    fkTipoCliente: c.tipoCodigo ?? 1,
    limiteCredito: Number(c.limiteCredito),
    telefono: c.telefono || '',
    email: c.email || ''
  }
  modalVisible.value = true
}

function cerrarModal() {
  modalVisible.value = false
  editando.value = false
  editandoId.value = null
}

async function guardar() {
  try {
    guardando.value = true
    const f = (o: Record<string,any>) => ({ nombre1: o.nombre1, nombre2: o.nombre2||undefined, nombre3: o.nombre3||undefined, apellido1: o.apellido1, apellido2: o.apellido2||undefined, apellidoCasada: o.apellidoCasada||undefined, direccion: o.direccion||undefined, fkTipoCliente: Number(o.fkTipoCliente), limiteCredito: Number(o.limiteCredito), telefono: o.telefono||undefined, email: o.email||undefined })
    if (editando.value && editandoId.value) {
      await clienteService.actualizar(editandoId.value, f(form.value))
      toast.exito('Cliente actualizado.')
    } else {
      await clienteService.crear({ nit: form.value.nit, ...f(form.value) })
      toast.exito('Cliente creado.')
    }
    cerrarModal()
    await cargar()
  } catch { toast.error('Error al guardar el cliente.') }
  finally { guardando.value = false }
}

function buscar() { pagina.value = 1; cargar() }
function limpiar() { filtros.value = { busqueda: '', estado: '', tipo: undefined }; buscar() }
function irPagina(n: number) { pagina.value = n; cargar() }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }

onMounted(() => cargar())
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
.td-actions { display:flex; align-items:center; gap:8px; width:120px }
.cell-main { font-weight:500 }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--i { background:rgba(248,113,113,0.15); color:#f87171 }
.action-btn { color:var(--color-primary); font-size:.85rem; font-weight:500; text-decoration:none; background:none; border:none; cursor:pointer; padding:0 }
.action-btn:hover { text-decoration:underline }
.switch { position:relative; display:inline-flex; align-items:center; width:36px; height:20px; vertical-align:middle }
.switch input { opacity:0; width:0; height:0 }
.switch-slider { position:absolute; inset:0; background:#cbd5e1; border-radius:20px; cursor:pointer; transition:background .2s }
.switch-slider::before { content:''; position:absolute; left:2px; top:2px; width:16px; height:16px; background:#fff; border-radius:50%; transition:transform .2s }
.switch input:checked + .switch-slider { background:#2dd4a0 }
.switch input:checked + .switch-slider::before { transform:translateX(16px) }
.switch--loading { opacity:.5; pointer-events:none }
.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,.6); display:flex; align-items:center; justify-content:center; z-index:1000 }
.modal-content { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1.5rem; width:640px; max-width:90vw; max-height:85vh; overflow-y:auto }
.modal-content h3 { font-size:1.1rem; font-weight:600; margin-bottom:1rem }
.modal-form { display:flex; flex-direction:column; gap:1rem }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem }
.form-group { display:flex; flex-direction:column; gap:4px }
.form-group label { font-size:.8rem; font-weight:500; color:var(--color-text-secondary) }
.form-input { padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-input); color:var(--color-text) }
.form-input:focus { outline:2px solid var(--color-primary); outline-offset:-1px }
.modal-actions { display:flex; justify-content:flex-end; gap:8px; margin-top:.5rem }
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
