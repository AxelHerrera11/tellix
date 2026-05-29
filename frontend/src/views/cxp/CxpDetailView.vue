<template>
  <div class="page">
    <div v-if="cargando" class="loading">Cargando cuenta por pagar...</div>
    <div v-else-if="!item" class="loading">Cuenta por pagar no encontrada.</div>
    <template v-else>

      <div class="page-header">
        <div class="header-left">
          <router-link to="/cxp" class="back-link">← CXP</router-link>
          <div class="header-title-row">
            <h2 class="page-title">CXP #{{ item.id }}</h2>
            <span class="badge" :class="`badge--${item.estado.toLowerCase()}`">
              {{ item.estadoDescripcion }}
            </span>
            <span v-if="estaVencida && item.estado === 'P'" class="badge badge--vencida">Vencida</span>
          </div>
        </div>
        <div class="header-actions">
          <button
            v-if="item.estado === 'P'"
            class="btn btn-primary"
            @click="modalPago = true"
          >+ Registrar pago</button>
          <button
            v-if="item.estado !== 'X'"
            class="btn btn-danger"
            @click="confirmarAnular"
            :disabled="anulando"
          >
            {{ anulando ? 'Anulando...' : 'Anular' }}
          </button>
        </div>
      </div>

      <div class="info-grid">
        <div class="info-card">
          <span class="info-label">Proveedor</span>
          <span class="info-value">{{ item.proveedor }}</span>
          <span class="info-sub">NIT: {{ item.proveedorNit }}</span>
          <span v-if="item.proveedorDireccion" class="info-sub">{{ item.proveedorDireccion }}</span>
        </div>
        <div class="info-card">
          <span class="info-label">Factura / Documento</span>
          <span class="info-value">{{ item.noDocumento }}</span>
          <span class="info-sub">Compra #{{ item.fkCompra }}</span>
        </div>
        <div class="info-card">
          <span class="info-label">Fecha de compra</span>
          <span class="info-value">{{ formatFecha(item.fechaCompra) }}</span>
        </div>
        <div class="info-card">
          <span class="info-label">Vencimiento</span>
          <span class="info-value" :class="{ 'text-danger': estaVencida }">{{ formatFecha(item.fechaLimite) }}</span>
          <span v-if="estaVencida" class="info-sub text-danger">
            Vencida
          </span>
        </div>
        <div class="info-card">
          <span class="info-label">Método de pago</span>
          <span class="info-value">{{ item.metodoPago || '—' }}</span>
        </div>
        <div class="info-card">
          <span class="info-label">Registrado por</span>
          <span class="info-value">{{ item.nombreEmpleado || item.usuario }}</span>
        </div>
      </div>

      <div class="info-grid">
        <div class="info-card info-card--accent info-card--total">
          <span class="info-label">Valor total</span>
          <span class="info-value">Q {{ formatNum(item.valorTotal) }}</span>
        </div>
        <div class="info-card info-card--accent info-card--pagado">
          <span class="info-label">Pagado</span>
          <span class="info-value">Q {{ formatNum(item.valorPagado) }}</span>
        </div>
        <div class="info-card info-card--accent" :class="item.saldo > 0 ? 'info-card--saldo' : 'info-card--pagado'">
          <span class="info-label">Saldo pendiente</span>
          <span class="info-value">Q {{ formatNum(item.saldo) }}</span>
        </div>
      </div>

      <div class="table-card">
        <div class="table-card-header">
          <span class="label">Productos de la compra</span>
        </div>
        <table v-if="item.items?.length" class="data-table">
          <thead>
            <tr>
              <th>Producto</th><th>Cantidad</th><th>Precio unit.</th><th>Descuentos</th><th>Impuestos</th><th>Subtotal</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="det in item.items" :key="det.id">
              <td><div class="cell-main">{{ det.nombreProducto }}</div></td>
              <td>{{ det.cantidad }}</td>
              <td class="td-num">Q {{ formatNum(det.precioUnitario) }}</td>
              <td class="td-num">Q {{ formatNum(det.descuentos) }}</td>
              <td class="td-num">Q {{ formatNum(det.impuestos) }}</td>
              <td class="td-num td-bold">Q {{ formatNum(det.subtotal) }}</td>
            </tr>
          </tbody>
        </table>
        <div v-else class="table-empty">Sin detalle de productos.</div>
      </div>

      <div class="totales-wrap">
        <div class="totales-card">
          <div class="total-row"><span>Subtotal compra</span><span>Q {{ formatNum(item.compraSubtotal) }}</span></div>
          <div class="total-row"><span>Descuentos</span><span>- Q {{ formatNum(item.compraDescuentos) }}</span></div>
          <div class="total-row"><span>Impuestos</span><span>Q {{ formatNum(item.compraImpuestos) }}</span></div>
          <div class="total-row total-final"><span>TOTAL COMPRA</span><span>Q {{ formatNum(item.compraTotal) }}</span></div>
        </div>
      </div>

      <div v-if="modalPago" class="modal-overlay" @click.self="modalPago = false">
        <div class="modal">
          <h3 class="modal-title">Registrar pago — CXP #{{ item.id }}</h3>
          <p class="modal-desc">Saldo pendiente: Q {{ formatNum(item.saldo) }}</p>
          <div class="modal-field">
            <label class="label-sm">Monto del pago</label>
            <input v-model="montoPago" type="number" step="0.01" min="0.01" :max="item.saldo"
              class="field-input" placeholder="0.00" />
          </div>
          <div class="modal-field">
            <label class="label-sm">Descripción (opcional)</label>
            <input v-model="descripcionPago" type="text" class="field-input"
              placeholder="Ej: Pago factura" />
          </div>
          <div class="modal-actions">
            <button class="btn btn-ghost" @click="modalPago = false">Cancelar</button>
            <button class="btn btn-primary" @click="ejecutarPago" :disabled="pagando || !montoPago || montoPago <= 0">
              {{ pagando ? 'Registrando...' : 'Confirmar pago' }}
            </button>
          </div>
        </div>
      </div>

      <div v-if="modalAnular" class="modal-overlay" @click.self="modalAnular = false">
        <div class="modal">
          <h3 class="modal-title">Anular CXP #{{ item.id }}</h3>
          <p class="modal-desc">Esta acción no puede revertirse.</p>
          <div class="modal-field">
            <label class="label-sm">Motivo (opcional)</label>
            <input v-model="motivoAnulacion" type="text" class="field-input" placeholder="Ej: Error" />
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
import { ref, computed, onMounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { cxpService, type CxpDetalle } from '@/services/cxp.service'
import { useToast } from '@/composables/useToast'

const route = useRoute()
const toast = useToast()

const item             = ref<CxpDetalle | null>(null)
const cargando         = ref(true)
const anulando         = ref(false)
const modalAnular      = ref(false)
const motivoAnulacion  = ref('')
const modalPago        = ref(false)
const pagando          = ref(false)
const montoPago        = ref<number | null>(null)
const descripcionPago  = ref('')

const estaVencida = computed(() => {
  if (!item.value?.fechaLimite) return false
  return new Date(item.value.fechaLimite) < new Date(new Date().toDateString())
})

async function cargar() {
  try {
    item.value = await cxpService.obtener(Number(route.params.id))
  } catch {
    toast.error('Error al cargar la cuenta por pagar.')
  } finally { cargando.value = false }
}

onMounted(cargar)

function confirmarAnular() {
  motivoAnulacion.value = ''
  modalAnular.value = true
}

async function ejecutarAnulacion() {
  try {
    anulando.value = true
    await cxpService.anular(item.value!.id, motivoAnulacion.value)
    toast.exito('Cuenta por pagar anulada correctamente.')
    item.value = await cxpService.obtener(item.value!.id)
    modalAnular.value = false
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al anular.')
  } finally { anulando.value = false }
}

async function ejecutarPago() {
  if (!montoPago.value || montoPago.value <= 0) return
  try {
    pagando.value = true
    await cxpService.registrarPago(item.value!.id, {
      monto: montoPago.value,
      descripcion: descripcionPago.value || undefined
    })
    toast.exito('Pago registrado correctamente.')
    item.value = await cxpService.obtener(item.value!.id)
    modalPago.value = false
    montoPago.value = null
    descripcionPago.value = ''
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al registrar el pago.')
  } finally { pagando.value = false }
}

function formatFecha(f: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n: number) { return Number(n ?? 0).toFixed(2) }
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.loading { padding:3rem; text-align:center; color:var(--color-text-muted) }
.page-header { display:flex; align-items:flex-start; justify-content:space-between }
.header-left { display:flex; flex-direction:column; gap:4px }
.header-actions { display:flex; gap:8px }
.back-link { font-size:.85rem; color:var(--color-primary); text-decoration:none }
.back-link:hover { text-decoration:underline }
.header-title-row { display:flex; align-items:center; gap:10px; flex-wrap:wrap }
.page-title { font-size:1.3rem; font-weight:600 }
.info-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem }
.info-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem; display:flex; flex-direction:column; gap:3px }
.info-card--accent { min-width:150px }
.info-card--total { border-left:3px solid var(--color-primary) }
.info-card--pagado { border-left:3px solid #2dd4a0 }
.info-card--saldo { border-left:3px solid #fbbf24 }
.info-label { font-size:.75rem; font-weight:600; color:var(--color-text-muted); text-transform:uppercase; letter-spacing:.04em }
.info-value { font-size:.95rem; font-weight:600; color:var(--color-text) }
.info-sub { font-size:.8rem; color:var(--color-text-muted) }
.text-danger { color:#f87171 }
.table-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; overflow:hidden }
.table-card-header { padding:.75rem 1rem; border-bottom:1px solid var(--color-border) }
.label { font-size:.8rem; font-weight:600; color:var(--color-text-secondary); text-transform:uppercase; letter-spacing:.04em }
.label-sm { display:block; font-size:.8rem; color:var(--color-text-muted); margin-bottom:4px }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th { padding:.75rem 1rem; text-align:left; font-size:.75rem; font-weight:600; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border); background:var(--color-bg-page) }
.data-table td { padding:.75rem 1rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.data-table tbody tr:last-child td { border-bottom:none }
.cell-main { font-weight:500 }
.td-num { font-variant-numeric:tabular-nums; text-align:right }
.td-bold { font-weight:600 }
.table-empty { padding:2rem; text-align:center; color:var(--color-text-muted) }
.totales-wrap { display:flex; justify-content:flex-end }
.totales-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem; min-width:280px }
.total-row { display:flex; justify-content:space-between; padding:.4rem 0; font-size:.875rem; border-bottom:1px solid var(--color-border); font-variant-numeric:tabular-nums }
.total-row:last-child { border-bottom:none }
.total-final { font-size:1.1rem; font-weight:700; padding-top:.6rem !important }
.badge { display:inline-block; padding:3px 12px; border-radius:20px; font-size:.75rem; font-weight:600 }
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
.badge--vencida { background:rgba(248,113,113,0.15); color:#f87171 }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-danger { background:rgba(248,113,113,0.2); color:#f87171; border:1px solid rgba(248,113,113,0.3) }
.btn-danger:hover:not(:disabled) { background:rgba(248,113,113,0.3) }
.btn-danger:disabled { opacity:.55; cursor:not-allowed }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn:disabled { opacity:.5; cursor:not-allowed }
.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,.45); display:flex; align-items:center; justify-content:center; z-index:999 }
.modal { background:var(--color-bg-card); border-radius:16px; padding:1.5rem; width:100%; max-width:420px; display:flex; flex-direction:column; gap:1rem }
.modal-title { font-size:1.1rem; font-weight:600 }
.modal-desc { font-size:.875rem; color:var(--color-text-secondary) }
.modal-field { display:flex; flex-direction:column }
.field-input { width:100%; padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-input); color:var(--color-text); box-sizing:border-box }
.modal-actions { display:flex; justify-content:flex-end; gap:8px }
</style>