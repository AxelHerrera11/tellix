<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Detalle CXP #{{ detalle?.id ?? '' }}</h2>
      <router-link to="/cxp" class="btn btn-ghost">Volver</router-link>
    </div>

    <div v-if="cargando" class="card">Cargando...</div>
    <template v-else-if="detalle">
      <div class="card detail-grid">
        <div><span class="label">Proveedor</span><div>{{ detalle.proveedor }} ({{ detalle.fkProveedor }})</div></div>
        <div><span class="label">Documento compra</span><div>{{ detalle.noDocumento }}</div></div>
        <div><span class="label">Fecha operacion</span><div>{{ formatFecha(detalle.fechaOperacion) }}</div></div>
        <div><span class="label">Fecha limite</span><div>{{ formatFecha(detalle.fechaLimite) }}</div></div>
        <div><span class="label">Valor total</span><div>Q {{ formatNum(detalle.valorTotal) }}</div></div>
        <div><span class="label">Valor pagado</span><div>Q {{ formatNum(detalle.valorPagado) }}</div></div>
        <div><span class="label">Saldo</span><div>Q {{ formatNum(detalle.saldo) }}</div></div>
        <div>
          <span class="label">Estado</span>
          <div>
            <span class="badge" :class="`badge--${detalle.estado.toLowerCase()}`">{{ detalle.estadoDescripcion }}</span>
            <span v-if="detalle.vencida" class="badge badge--x">Vencida</span>
          </div>
        </div>
      </div>

      <div v-if="puedePagar" class="card">
        <h3>Registrar pago</h3>
        <div class="form-grid">
          <input v-model.number="formPago.monto" type="number" step="0.01" min="0.01" class="field" placeholder="Monto" />
          <select v-model.number="formPago.fkMetodoPago" class="field">
            <option :value="0">Metodo de pago</option>
            <option v-for="m in metodos" :key="m.codigo" :value="m.codigo">{{ m.descripcion }}</option>
          </select>
          <select v-model="formPago.fkCuenta" class="field">
            <option value="">Cuenta bancaria</option>
            <option v-for="c in cuentas" :key="c.numero" :value="c.numero">{{ c.numero }} - {{ c.banco }}</option>
          </select>
          <input v-model="formPago.descripcion" type="text" class="field" placeholder="Descripcion" />
        </div>
        <button class="btn btn-primary" @click="registrarPago">Registrar pago</button>
      </div>

      <div v-if="puedeAnular" class="card">
        <button class="btn btn-danger" @click="anularCxp">Anular CXP</button>
      </div>

      <div class="card">
        <h3>Movimientos de pago</h3>
        <div v-if="!detalle.movimientos.length" class="table-empty">Sin movimientos registrados.</div>
        <table v-else class="data-table">
          <thead><tr><th>ID</th><th>Fecha</th><th>Cuenta</th><th>Monto</th><th>Descripcion</th><th>Usuario</th></tr></thead>
          <tbody>
          <tr v-for="m in detalle.movimientos" :key="m.id">
            <td>{{ m.id }}</td><td>{{ formatFecha(m.fechaOperacion) }}</td><td>{{ m.fkCuenta }}</td><td>Q {{ formatNum(m.monto) }}</td><td>{{ m.descripcion }}</td><td>{{ m.usuario }}</td>
          </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { cxpService, type CxpDetalle, type MetodoPagoDto, type CuentaBancariaDto } from '@/services/cxp.service'
import { useToast } from '@/composables/useToast'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const detalle = ref<CxpDetalle | null>(null)
const metodos = ref<MetodoPagoDto[]>([])
const cuentas = ref<CuentaBancariaDto[]>([])
const cargando = ref(false)
const formPago = ref({ monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' })

const cxpId = computed(() => Number(route.params.id))
const puedePagar = computed(() => !!detalle.value && detalle.value.saldo > 0 && detalle.value.estado !== 'X')
const puedeAnular = computed(() => !!detalle.value && detalle.value.valorPagado === 0 && detalle.value.estado !== 'X')

async function cargar() {
  try {
    cargando.value = true
    const [d, m, c] = await Promise.all([
      cxpService.obtener(cxpId.value),
      cxpService.listarMetodosPago(),
      cxpService.listarCuentasBancarias()
    ])
    detalle.value = d
    metodos.value = m
    cuentas.value = c
  } catch {
    toast.error('No fue posible cargar el detalle de CXP.')
    router.push('/cxp')
  } finally {
    cargando.value = false
  }
}

async function registrarPago() {
  if (formPago.value.monto <= 0 || !formPago.value.fkMetodoPago || !formPago.value.fkCuenta) {
    toast.error('Complete monto, metodo de pago y cuenta bancaria.')
    return
  }
  try {
    await cxpService.registrarPago(cxpId.value, {
      monto: formPago.value.monto,
      fkMetodoPago: formPago.value.fkMetodoPago,
      fkCuenta: formPago.value.fkCuenta,
      descripcion: formPago.value.descripcion || undefined
    })
    toast.exito('Pago registrado correctamente.')
    formPago.value = { monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' }
    await cargar()
  } catch {
    toast.error('No fue posible registrar el pago.')
  }
}

async function anularCxp() {
  try {
    await cxpService.anular(cxpId.value, 'Anulacion manual desde detalle CXP')
    toast.exito('CXP anulada correctamente.')
    await cargar()
  } catch {
    toast.error('No fue posible anular la CXP.')
  }
}

function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem }
.page-header { display:flex; justify-content:space-between; align-items:center }
.page-title { font-size:1.3rem; font-weight:600 }
.card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.detail-grid { display:grid; grid-template-columns:repeat(2,minmax(230px,1fr)); gap:.9rem }
.label { color:var(--color-text-muted); font-size:.8rem; display:block; margin-bottom:4px }
.form-grid { display:grid; grid-template-columns:repeat(2,minmax(220px,1fr)); gap:8px; margin:.75rem 0 }
.field { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-card); color:var(--color-text) }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600; margin-right:6px }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 }
.badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 }
.badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem }
.data-table th,.data-table td { border-bottom:1px solid var(--color-border); padding:.65rem; text-align:left }
.table-empty { color:var(--color-text-muted) }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; text-decoration:none; display:inline-flex; align-items:center }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-ghost { background:transparent; border-color:var(--color-border); color:var(--color-text-secondary) }
.btn-danger { background:#ef4444; color:#fff }
@media (max-width: 700px) { .detail-grid, .form-grid { grid-template-columns:1fr } }
</style>
