<template>
    <div class="page">
      <div v-if="cargando" class="loading">Cargando compra...</div>
      <div v-else-if="!compra" class="loading">Compra no encontrada.</div>
      <template v-else>

        <!-- Encabezado -->
        <div class="page-header">
          <div class="header-left">
            <router-link to="/compras" class="back-link">← Compras</router-link>
            <div class="header-title-row">
              <h2 class="page-title">Compra #{{ compra.id }}</h2>
              <span class="badge" :class="`badge--${compra.estado.toLowerCase()}`">
                {{ compra.estadoDescripcion }}
              </span>
            </div>
          </div>
          <div class="header-actions">
            <button
              v-if="compra.estado === 'P'"
              class="btn btn-success"
              @click="confirmarAprobar"
              :disabled="procesando"
            >
              {{ procesando ? 'Procesando...' : 'Aprobar compra' }}
            </button>
            <button
              v-if="compra.estado === 'A'"
              class="btn btn-primary-outline"
              @click="confirmarCompletar"
              :disabled="procesando"
            >
              {{ procesando ? 'Procesando...' : 'Completar compra' }}
            </button>
            <button
              v-if="compra.estado !== 'X'"
              class="btn btn-danger"
              @click="confirmarAnular"
              :disabled="procesando"
            >
              {{ procesando ? 'Procesando...' : 'Anular compra' }}
            </button>
          </div>
        </div>

        <!-- Info cabecera -->
        <div class="info-grid">
          <div class="info-card">
            <span class="info-label">Documento</span>
            <span class="info-value">{{ compra.noDocumento }}</span>
          </div>
          <div class="info-card">
            <span class="info-label">Proveedor</span>
            <span class="info-value">{{ compra.nombreProveedor }}</span>
            <span class="info-sub">NIT: {{ compra.fkProveedor }}</span>
          </div>
          <div class="info-card" v-if="compra.nombreRepresentante">
            <span class="info-label">Representante</span>
            <span class="info-value">{{ compra.nombreRepresentante }}</span>
          </div>
          <div class="info-card">
            <span class="info-label">Fecha</span>
            <span class="info-value">{{ formatFecha(compra.fechaOperacion) }}</span>
          </div>
          <div class="info-card">
            <span class="info-label">Método de pago</span>
            <span class="info-value">{{ compra.metodoPago }}</span>
            <span v-if="compra.plazoCredito > 0" class="info-sub">
              Plazo: {{ compra.plazoCredito }} días
            </span>
          </div>
          <div class="info-card">
            <span class="info-label">Registrado por</span>
            <span class="info-value">{{ compra.nombreEmpleado || compra.usuario }}</span>
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
              <tr v-for="item in compra.items" :key="item.id">
                <td>
                  <div class="cell-main">{{ item.nombreProducto }}</div>
                  <div class="cell-sub">{{ item.medida }}</div>
                </td>
                <td>{{ item.cantidad }} {{ item.fkMedida || '' }}</td>
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
              <span>Q {{ formatNum(compra.subtotal) }}</span>
            </div>
            <div class="total-row">
              <span>Descuentos</span>
              <span>- Q {{ formatNum(compra.totalDescuentos) }}</span>
            </div>
            <div class="total-row">
              <span>Impuestos</span>
              <span>Q {{ formatNum(compra.totalImpuestos) }}</span>
            </div>
            <div class="total-row total-final">
              <span>TOTAL</span>
              <span>Q {{ formatNum(compra.total) }}</span>
            </div>
          </div>
        </div>

        <!-- Modal aprobar -->
        <div v-if="modalAprobar" class="modal-overlay" @click.self="modalAprobar = false">
          <div class="modal">
            <h3 class="modal-title">Aprobar compra #{{ compra.id }}</h3>
            <p class="modal-desc">Al aprobar la compra se actualizará el stock de los productos. ¿Desea continuar?</p>
            <div class="modal-actions">
              <button class="btn btn-ghost" @click="modalAprobar = false">Cancelar</button>
              <button class="btn btn-success" @click="ejecutarAprobacion" :disabled="procesando">
                {{ procesando ? 'Aprobando...' : 'Confirmar aprobación' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Modal completar -->
        <div v-if="modalCompletar" class="modal-overlay" @click.self="modalCompletar = false">
          <div class="modal">
            <h3 class="modal-title">Completar compra #{{ compra.id }}</h3>
            <p class="modal-desc">Marcar la compra como completada. Esta acción no afecta el stock.</p>
            <div class="modal-actions">
              <button class="btn btn-ghost" @click="modalCompletar = false">Cancelar</button>
              <button class="btn btn-primary-outline" @click="ejecutarCompletar" :disabled="procesando">
                {{ procesando ? 'Completando...' : 'Confirmar' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Modal anular -->
        <div v-if="modalAnular" class="modal-overlay" @click.self="modalAnular = false">
          <div class="modal">
            <h3 class="modal-title">Anular compra #{{ compra.id }}</h3>
            <p class="modal-desc">
              <template v-if="compra.estado === 'P'">La compra será cancelada sin afectar el stock.</template>
              <template v-else>Se revertirá el stock de los productos. Esta acción no puede revertirse.</template>
            </p>
            <div class="modal-field">
              <label class="label-sm">Motivo (opcional)</label>
              <input v-model="motivoAnulacion" type="text" class="field-input" placeholder="Ej: Error en el pedido" />
            </div>
            <div class="modal-actions">
              <button class="btn btn-ghost" @click="modalAnular = false">Cancelar</button>
              <button class="btn btn-danger" @click="ejecutarAnulacion" :disabled="procesando">
                {{ procesando ? 'Anulando...' : 'Confirmar anulación' }}
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
import { compraService, type CompraDetalle } from '@/services/compra.service'
import { useToast } from '@/composables/useToast'

const route  = useRoute()
const toast  = useToast()

const compra         = ref<CompraDetalle | null>(null)
const cargando       = ref(true)
const procesando     = ref(false)

const modalAprobar   = ref(false)
const modalCompletar = ref(false)
const modalAnular    = ref(false)
const motivoAnulacion = ref('')

onMounted(async () => {
  try {
    compra.value = await compraService.obtener(Number(route.params.id))
  } catch {
    toast.error('Error al cargar la compra.')
  } finally {
    cargando.value = false
  }
})

async function recargar() {
  try {
    compra.value = await compraService.obtener(Number(route.params.id))
  } catch {
    toast.error('Error al recargar la compra.')
  }
}

// ── Aprobar ───────────────────────────────────────────────────
function confirmarAprobar() {
  modalAprobar.value = true
}

async function ejecutarAprobacion() {
  try {
    procesando.value = true
    await compraService.aprobar(compra.value!.id)
    toast.exito('Compra aprobada correctamente. Stock actualizado.')
    await recargar()
    modalAprobar.value = false
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al aprobar la compra.')
  } finally {
    procesando.value = false
  }
}

// ── Completar ─────────────────────────────────────────────────
function confirmarCompletar() {
  modalCompletar.value = true
}

async function ejecutarCompletar() {
  try {
    procesando.value = true
    await compraService.completar(compra.value!.id)
    toast.exito('Compra completada correctamente.')
    await recargar()
    modalCompletar.value = false
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al completar la compra.')
  } finally {
    procesando.value = false
  }
}

// ── Anular ────────────────────────────────────────────────────
function confirmarAnular() {
  motivoAnulacion.value = ''
  modalAnular.value     = true
}

async function ejecutarAnulacion() {
  try {
    procesando.value = true
    await compraService.anular(compra.value!.id, motivoAnulacion.value)
    toast.exito('Compra anulada correctamente.')
    await recargar()
    modalAnular.value = false
  } catch (err: any) {
    toast.error(err.response?.data?.mensaje ?? 'Error al anular la compra.')
  } finally {
    procesando.value = false
  }
}

function formatFecha(f: string) {
  return f ? new Date(f + 'T00:00:00').toLocaleDateString('es-GT') : '—'
}

function formatNum(n: number) {
  return Number(n ?? 0).toFixed(2)
}
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.loading { padding:3rem; text-align:center; color:var(--color-text-muted) }

.page-header { display:flex; align-items:flex-start; justify-content:space-between; flex-wrap:wrap; gap:.75rem }
.header-left { display:flex; flex-direction:column; gap:4px }
.header-actions { display:flex; gap:8px; flex-wrap:wrap }
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
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--c { background:rgba(96,165,250,0.15); color:#60a5fa }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }

.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; display:inline-flex; align-items:center; gap:4px }
.btn-success { background:rgba(45,212,160,0.2); color:#2dd4a0; border:1px solid rgba(45,212,160,0.3) }
.btn-success:hover:not(:disabled) { background:rgba(45,212,160,0.3) }
.btn-success:disabled { opacity:.55; cursor:not-allowed }
.btn-primary-outline { background:rgba(96,165,250,0.2); color:#60a5fa; border:1px solid rgba(96,165,250,0.3) }
.btn-primary-outline:hover:not(:disabled) { background:rgba(96,165,250,0.3) }
.btn-danger { background:rgba(248,113,113,0.2); color:#f87171; border:1px solid rgba(248,113,113,0.3) }
.btn-danger:hover:not(:disabled) { background:rgba(248,113,113,0.3) }
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
