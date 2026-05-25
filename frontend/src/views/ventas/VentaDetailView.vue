<template>
    <div class="page">
      <div v-if="cargando" class="loading">Cargando venta...</div>
      <div v-else-if="!venta" class="loading">Venta no encontrada.</div>
      <template v-else>

        <!-- Encabezado -->
        <div class="page-header">
          <div class="header-left">
            <router-link to="/ventas" class="back-link">← Ventas</router-link>
            <div class="header-title-row">
              <h2 class="page-title">Venta #{{ venta.id }}</h2>
              <span class="badge" :class="`badge--${venta.estado.toLowerCase()}`">
                {{ venta.estadoDescripcion }}
              </span>
            </div>
          </div>
          <button
            v-if="venta.estado === 'A'"
            class="btn btn-danger"
            @click="confirmarAnular"
            :disabled="anulando"
          >
            {{ anulando ? 'Anulando...' : 'Anular venta' }}
          </button>
        </div>

        <!-- Info cabecera -->
        <div class="info-grid">
          <div class="info-card">
            <span class="info-label">Cliente</span>
            <span class="info-value">{{ venta.nombreCliente || venta.fkCliente }}</span>
            <span class="info-sub">NIT: {{ venta.nit || venta.fkCliente }}</span>
          </div>
          <div class="info-card">
            <span class="info-label">Fecha</span>
            <span class="info-value">{{ formatFecha(venta.fechaOperacion) }}</span>
          </div>
          <div class="info-card">
            <span class="info-label">Método de pago</span>
            <span class="info-value">{{ venta.metodoPago }}</span>
            <span v-if="venta.plazoCredito > 0" class="info-sub">
              Plazo: {{ venta.plazoCredito }} {{ venta.tipoPlazo }}
            </span>
          </div>
          <div class="info-card">
            <span class="info-label">Registrado por</span>
            <span class="info-value">{{ venta.nombreEmpleado || venta.usuario }}</span>
          </div>
        </div>

        <!-- Detalle -->
        <div class="table-card">
          <div class="table-card-header">
            <span class="label">Productos</span>
          </div>
          <table class="data-table">
            <thead>
              <tr>
                <th>Producto</th>
                <th>Cantidad</th>
                <th>Precio unit.</th>
                <th>Descuentos</th>
                <th>Impuestos</th>
                <th>Subtotal</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in venta.items" :key="item.id">
                <td>
                  <div class="cell-main">{{ item.nombreProducto }}</div>
                  <div class="cell-sub">{{ item.medida }}</div>
                </td>
                <td>{{ item.cantidad }} {{ item.fkMedida }}</td>
                <td class="td-num">Q {{ formatNum(item.precioUnitario) }}</td>
                <td class="td-num">Q {{ formatNum(item.descuentos) }}</td>
                <td class="td-num">Q {{ formatNum(item.impuestos) }}</td>
                <td class="td-num td-bold">Q {{ formatNum(item.subtotal) }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Totales -->
        <div class="totales-wrap">
          <div class="totales-card">
            <div class="total-row">
              <span>Subtotal</span>
              <span>Q {{ formatNum(venta.subtotal) }}</span>
            </div>
            <div class="total-row">
              <span>Descuentos</span>
              <span>- Q {{ formatNum(venta.totalDescuentos) }}</span>
            </div>
            <div class="total-row">
              <span>Impuestos</span>
              <span>Q {{ formatNum(venta.totalImpuestos) }}</span>
            </div>
            <div class="total-row total-final">
              <span>TOTAL</span>
              <span>Q {{ formatNum(venta.total) }}</span>
            </div>
          </div>
        </div>

        <!-- Modal de confirmación de anulación -->
        <div v-if="modalAnular" class="modal-overlay" @click.self="modalAnular = false">
          <div class="modal">
            <h3 class="modal-title">Anular venta #{{ venta.id }}</h3>
            <p class="modal-desc">Esta acción restaurará el stock y no puede revertirse.</p>
            <div class="modal-field">
              <label class="label-sm">Motivo (opcional)</label>
              <input v-model="motivoAnulacion" type="text" class="field-input" placeholder="Ej: Error en el pedido" />
            </div>
            <div class="modal-actions">
              <button class="btn btn-ghost" @click="modalAnular = false">Cancelar</button>
              <button class="btn btn-danger" @click="ejecutarAnulacion" :disabled="anulando">
                {{ anulando ? 'Anulando...' : 'Confirmar anulación' }}
              </button>
            </div>
          </div>
        </div>

      </template>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { ventaService, type VentaDetalle } from '@/services/venta.service'
import { useToast } from '@/composables/useToast'

const route  = useRoute()
const toast  = useToast()

const venta          = ref<VentaDetalle | null>(null)
const cargando       = ref(true)
const anulando       = ref(false)
const modalAnular    = ref(false)
const motivoAnulacion = ref('')

onMounted(async () => {
  try {
    venta.value = await ventaService.obtener(Number(route.params.id))
  } catch {
    toast.error('Error al cargar la venta.')
  } finally {
    cargando.value = false
  }
})

function confirmarAnular() {
  motivoAnulacion.value = ''
  modalAnular.value     = true
}

async function ejecutarAnulacion() {
  try {
    anulando.value = true
    await ventaService.anular(venta.value!.id, motivoAnulacion.value)
    toast.exito('Venta anulada correctamente.')
    venta.value = await ventaService.obtener(venta.value!.id)
    modalAnular.value = false
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al anular la venta.')
  } finally {
    anulando.value = false
  }
}

function formatFecha(f: string) {
  return f ? new Date(f).toLocaleDateString('es-GT') : '—'
}

function formatNum(n: number) {
  return Number(n ?? 0).toFixed(2)
}
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.loading { padding:3rem; text-align:center; color:var(--color-text-muted) }

.page-header { display:flex; align-items:flex-start; justify-content:space-between }
.header-left { display:flex; flex-direction:column; gap:4px }
.back-link { font-size:.85rem; color:var(--color-primary); text-decoration:none }
.back-link:hover { text-decoration:underline }
.header-title-row { display:flex; align-items:center; gap:10px }
.page-title { font-size:1.3rem; font-weight:600 }

.info-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem }
.info-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem; display:flex; flex-direction:column; gap:3px }
.info-label { font-size:.75rem; font-weight:600; color:var(--color-text-muted); text-transform:uppercase; letter-spacing:.04em }
.info-value { font-size:.95rem; font-weight:600; color:var(--color-text) }
.info-sub { font-size:.8rem; color:var(--color-text-muted) }

.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-card-header { padding:.75rem 1rem; border-bottom:1px solid var(--color-border) }
.label { font-size:.8rem; font-weight:600; color:var(--color-text-secondary); text-transform:uppercase; letter-spacing:.04em }
.label-sm { display:block; font-size:.8rem; color:var(--color-text-muted); margin-bottom:4px }

.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { padding:.75rem 1rem; text-align:left; font-size:.75rem; font-weight:600; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border); background:var(--color-bg-page) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.cell-main { font-weight:500 }
.cell-sub { font-size:.75rem; color:var(--color-text-muted) }
.td-num { font-variant-numeric:tabular-nums; text-align:right }
.td-bold { font-weight:600 }

.totales-wrap { display:flex; justify-content:flex-end }
.totales-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem; min-width:280px }
.total-row { display:flex; justify-content:space-between; padding:.4rem 0; font-size:.875rem; border-bottom:1px solid var(--color-border); font-variant-numeric:tabular-nums }
.total-row:last-child { border-bottom:none }
.total-final { font-size:1.1rem; font-weight:700; padding-top:.6rem !important }

.badge { display:inline-block; padding:3px 12px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--a { background:#d1fae5; color:#065f46 }
.badge--p { background:#fef9c3; color:#713f12 }
.badge--c { background:#dbeafe; color:#1e40af }
.badge--x { background:#fee2e2; color:#991b1b }

.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; display:inline-flex; align-items:center; gap:4px }
.btn-danger { background:#dc2626; color:#fff }
.btn-danger:hover:not(:disabled) { background:#b91c1c }
.btn-danger:disabled { opacity:.55; cursor:not-allowed }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }

.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; z-index:999 }
.modal { background:var(--color-bg-card); border-radius:16px; padding:1.5rem; width:100%; max-width:420px; display:flex; flex-direction:column; gap:1rem }
.modal-title { font-size:1.1rem; font-weight:600 }
.modal-desc { font-size:.875rem; color:var(--color-text-secondary) }
.modal-field { display:flex; flex-direction:column }
.field-input { width:100%; padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-input); color:var(--color-text); box-sizing:border-box }
.modal-actions { display:flex; justify-content:flex-end; gap:8px }
</style>
