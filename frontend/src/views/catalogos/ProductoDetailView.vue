<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">{{ producto?.nombre || 'Producto' }}</h2>
      <div class="header-actions">
        <router-link :to="`/catalogos/productos/${producto?.codigo}/editar`" class="btn btn-secondary" v-if="auth.tieneRol('ADMINISTRADOR')">Editar</router-link>
        <router-link to="/catalogos/productos" class="btn btn-ghost">← Volver</router-link>
      </div>
    </div>

    <div v-if="cargando" class="loading">Cargando...</div>
    <template v-else-if="producto">
      <div class="detail-grid">
        <div class="detail-card info-card">
          <h3 class="card-title">Información general</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Código</span>
              <span class="info-value">{{ producto.codigo }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Nombre</span>
              <span class="info-value">{{ producto.nombre }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Descripción</span>
              <span class="info-value">{{ producto.descripcion || '—' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Categoría</span>
              <span class="info-value">{{ producto.categoria || '—' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Marca</span>
              <span class="info-value">{{ producto.marca || '—' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Medida</span>
              <span class="info-value">{{ producto.medida || '—' }} ({{ producto.medidaCodigo || '—' }})</span>
            </div>
            <div class="info-item">
              <span class="info-label">Cantidad por unidad</span>
              <span class="info-value">{{ formatNum(producto.cantidadMedida) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Stock actual</span>
              <span class="info-value">{{ formatNum(producto.stockActual) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Stock mínimo</span>
              <span class="info-value">{{ formatNum(producto.stockMinimo) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Estado</span>
              <span class="info-value estado-row">
                <span class="badge" :class="`badge--${producto.estado.toLowerCase()}`">{{ producto.estadoDescripcion }}</span>
                <label v-if="auth.tieneRol('ADMINISTRADOR')" class="switch" :class="{ 'switch--loading': cambiandoEstado }">
                  <input type="checkbox" :checked="producto.estado === 'A'" :disabled="cambiandoEstado" @click.prevent="toggleEstado" />
                  <span class="switch-slider"></span>
                </label>
              </span>
            </div>
          </div>
        </div>

        <div class="detail-card precio-card">
          <h3 class="card-title">
            Precios
            <button v-if="auth.tieneRol('ADMINISTRADOR')" class="btn btn-sm btn-primary" @click="mostrarFormPrecio = !mostrarFormPrecio">
              {{ mostrarFormPrecio ? 'Cancelar' : '+ Asignar precio' }}
            </button>
          </h3>

          <form v-if="mostrarFormPrecio" class="precio-form" @submit.prevent="asignarPrecio">
            <div class="field">
              <label class="label">Precio <span class="required">*</span></label>
              <input v-model.number="precioForm.precioVenta" type="number" step="0.01" min="0.01" class="input" required placeholder="0.00" />
            </div>
            <div class="field">
              <label class="label">Aplicación <span class="required">*</span></label>
              <select v-model="precioForm.aplicacion" class="input" required>
                <option value="">Seleccionar...</option>
                <option value="VENTA">Venta</option>
                <option value="COMPRA">Compra</option>
                <option value="AMBOS">Ambos</option>
              </select>
            </div>
            <div class="field">
              <label class="label">Inicio de vigencia</label>
              <input v-model="precioForm.inicioVigencia" type="date" class="input" />
            </div>
            <button type="submit" class="btn btn-primary btn-sm" :disabled="guardandoPrecio">
              {{ guardandoPrecio ? 'Guardando...' : 'Guardar' }}
            </button>
          </form>

          <div v-if="!producto.precios.length" class="empty-section">Sin precios registrados.</div>
          <table v-else class="mini-table">
            <thead><tr><th>Precio</th><th>Aplicación</th><th>Vigencia</th><th>Estado</th></tr></thead>
            <tbody>
              <tr v-for="p in producto.precios" :key="p.id">
                <td class="td-monto">Q {{ formatNum(p.precioVenta) }}</td>
                <td>{{ p.aplicacion }}</td>
                <td>{{ formatFecha(p.inicioVigencia) }} — {{ formatFecha(p.finVigencia) || '∞' }}</td>
                <td><span class="badge" :class="`badge--${p.estado.toLowerCase()}`">{{ p.estado }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="detail-grid cols-2">
        <div class="detail-card">
          <h3 class="card-title">Impuestos asignados</h3>
          <div v-if="!producto.impuestos.length" class="empty-section">Sin impuestos asignados.</div>
          <table v-else class="mini-table">
            <thead><tr><th>Impuesto</th><th>Tipo</th><th>Valor</th><th>Estado</th></tr></thead>
            <tbody>
              <tr v-for="i in producto.impuestos" :key="i.id">
                <td>{{ i.impuesto }}</td>
                <td>{{ i.tipoCalculo }}</td>
                <td>{{ i.valorOverride ? formatNum(i.valorOverride) : formatNum(i.valorBase) }}%</td>
                <td><span class="badge" :class="`badge--${i.estado.toLowerCase()}`">{{ i.estado }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="detail-card">
          <h3 class="card-title">Descuentos asignados</h3>
          <div v-if="!producto.descuentos.length" class="empty-section">Sin descuentos asignados.</div>
          <table v-else class="mini-table">
            <thead><tr><th>Descuento</th><th>Tipo</th><th>Valor</th><th>Estado</th></tr></thead>
            <tbody>
              <tr v-for="d in producto.descuentos" :key="d.id">
                <td>{{ d.descuento }}</td>
                <td>{{ d.tipoCalculo }}</td>
                <td>{{ d.valorOverride ? formatNum(d.valorOverride) : formatNum(d.valorBase) }}%</td>
                <td><span class="badge" :class="`badge--${d.estado.toLowerCase()}`">{{ d.estado }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { productoService, type ProductoDetalle } from '@/services/producto.service'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'

const route   = useRoute()
const toast   = useToast()
const auth    = useAuthStore()

const producto         = ref<ProductoDetalle | null>(null)
const cargando         = ref(false)
const cambiandoEstado  = ref(false)
const mostrarFormPrecio = ref(false)
const guardandoPrecio  = ref(false)
const precioForm = ref({ precioVenta: undefined as number | undefined, aplicacion: '', inicioVigencia: '' })

async function cargar() {
  try {
    cargando.value = true
    producto.value = await productoService.obtener(Number(route.params.id))
  } catch { toast.error('Error al cargar el producto.') }
  finally { cargando.value = false }
}

async function asignarPrecio() {
  try {
    guardandoPrecio.value = true
    await productoService.asignarPrecio(Number(route.params.id), {
      precioVenta:    precioForm.value.precioVenta!,
      aplicacion:     precioForm.value.aplicacion,
      inicioVigencia: precioForm.value.inicioVigencia || undefined
    })
    toast.exito('Precio asignado correctamente.')
    mostrarFormPrecio.value = false
    precioForm.value = { precioVenta: undefined, aplicacion: '', inicioVigencia: '' }
    await cargar()
  } catch { toast.error('Error al asignar precio.') }
  finally { guardandoPrecio.value = false }
}

async function toggleEstado() {
  if (!producto.value) return
  const nuevoEstado = producto.value.estado === 'A' ? 'I' : 'A'
  try {
    cambiandoEstado.value = true
    await productoService.cambiarEstado(Number(route.params.id), { estado: nuevoEstado as 'A' | 'I' })
    toast.exito(nuevoEstado === 'A' ? 'Producto activado.' : 'Producto desactivado.')
    await cargar()
  } catch { toast.error('Error al cambiar el estado.') }
  finally { cambiandoEstado.value = false }
}

function formatNum(n: number | null | undefined) { return Number(n ?? 0).toFixed(2) }
function formatFecha(f: string | null | undefined) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.header-actions { display:flex; gap:8px }
.loading { padding:3rem; text-align:center; color:var(--color-text-muted) }
.detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem }
.cols-2 { grid-template-columns:1fr 1fr }
.detail-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1.25rem }
.card-title { font-size:1rem; font-weight:600; margin-bottom:1rem; display:flex; align-items:center; justify-content:space-between }
.info-grid { display:grid; grid-template-columns:1fr 1fr; gap:.75rem }
.info-item { display:flex; flex-direction:column; gap:2px }
.info-label { font-size:.75rem; font-weight:500; color:var(--color-text-muted); text-transform:uppercase; letter-spacing:.04em }
.info-value { font-size:.9rem; font-weight:500 }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--a { background:#d1fae5; color:#065f46 }
.badge--i { background:#fee2e2; color:#991b1b }
.mini-table { width:100%; border-collapse:collapse; font-size:.85rem }
.mini-table th { text-align:left; font-weight:600; font-size:.75rem; color:var(--color-text-muted); padding:.5rem .5rem .5rem 0; border-bottom:1px solid var(--color-border) }
.mini-table td { padding:.5rem .5rem .5rem 0; border-bottom:1px solid var(--color-border) }
.mini-table tbody tr:last-child td { border-bottom:none }
.td-monto { font-weight:600; font-variant-numeric:tabular-nums }
.empty-section { padding:1rem 0; text-align:center; color:var(--color-text-muted); font-size:.875rem }
.precio-form { display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap; margin-bottom:1rem; padding:.75rem; background:var(--color-bg-page); border-radius:8px }
.field { display:flex; flex-direction:column; gap:4px }
.label { font-size:.8rem; font-weight:500; color:var(--color-text-secondary) }
.required { color:#dc2626 }
.input { padding:.4rem .6rem; border:1px solid var(--color-border); border-radius:6px; font-size:.85rem; background:var(--color-bg-card); color:var(--color-text); min-width:120px }
.input:focus { outline:2px solid var(--color-primary); outline-offset:-1px; border-color:transparent }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-secondary { background:var(--color-bg-card); color:var(--color-text); border-color:var(--color-border) }
.btn-secondary:hover { background:var(--color-bg-page) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-sm { padding:.35rem .75rem; font-size:.8rem }
.btn:disabled { opacity:.5; cursor:not-allowed }
.estado-row { display:flex; align-items:center; gap:8px }
.switch { position:relative; display:inline-flex; align-items:center; width:36px; height:20px; vertical-align:middle }
.switch input { opacity:0; width:0; height:0 }
.switch-slider { position:absolute; inset:0; background:#cbd5e1; border-radius:20px; cursor:pointer; transition:background .2s }
.switch-slider::before { content:''; position:absolute; left:2px; top:2px; width:16px; height:16px; background:#fff; border-radius:50%; transition:transform .2s }
.switch input:checked + .switch-slider { background:#16a34a }
.switch input:checked + .switch-slider::before { transform:translateX(16px) }
.switch--loading { opacity:.5; pointer-events:none }
</style>
