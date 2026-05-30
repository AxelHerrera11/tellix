<template>
  <div class="page">
    <div class="header">
      <h2 class="page-title">Detalle CXC #{{ detalle?.id ?? '' }}</h2>
      <router-link to="/cxc" class="btn">Volver</router-link>
    </div>

    <div v-if="cargando" class="card">Cargando...</div>
    <template v-else-if="detalle">
      <div class="card grid">
        <div><span class="label">Cliente</span><div>{{ detalle.cliente }} ({{ detalle.fkCliente }})</div></div>
        <div><span class="label">Venta</span><div>#{{ detalle.fkVenta }}</div></div>
        <div><span class="label">Fecha operacion</span><div>{{ formatFecha(detalle.fechaOperacion) }}</div></div>
        <div><span class="label">Fecha limite</span><div>{{ formatFecha(detalle.fechaLimite) }}</div></div>
        <div><span class="label">Total</span><div>Q {{ formatNum(detalle.valorTotal) }}</div></div>
        <div><span class="label">Cobrado</span><div>Q {{ formatNum(detalle.valorCobrado) }}</div></div>
        <div><span class="label">Saldo</span><div>Q {{ formatNum(detalle.saldo) }}</div></div>
        <div><span class="label">Estado</span><div>{{ detalle.estadoDescripcion }}</div></div>
      </div>

      <div v-if="puedeCobrar" class="card">
        <h3>Registrar cobro</h3>
        <div class="form-grid">
          <input v-model.number="form.monto" class="field" type="number" step="0.01" min="0.01" placeholder="Monto" />
          <select v-model.number="form.fkMetodoPago" class="field"><option :value="0">Metodo de cobro</option><option v-for="m in metodos" :key="m.codigo" :value="m.codigo">{{ m.descripcion }}</option></select>
          <select v-model="form.fkCuenta" class="field"><option value="">Cuenta bancaria</option><option v-for="c in cuentas" :key="c.numero" :value="c.numero">{{ c.numero }} - {{ c.banco }}</option></select>
          <input v-model="form.descripcion" class="field" placeholder="Descripcion" />
        </div>
        <button class="btn" @click="registrarCobro">Registrar cobro</button>
      </div>

      <div v-if="puedeAnular" class="card"><button class="btn btn-danger" @click="anular">Anular CXC</button></div>

      <div class="card">
        <h3>Movimientos de cobro</h3>
        <div v-if="!detalle.movimientos.length" class="empty">Sin movimientos.</div>
        <table v-else class="table"><thead><tr><th>ID</th><th>Fecha</th><th>Cuenta</th><th>Monto</th><th>Descripcion</th><th>Usuario</th></tr></thead><tbody><tr v-for="m in detalle.movimientos" :key="m.id"><td>{{ m.id }}</td><td>{{ formatFecha(m.fechaOperacion) }}</td><td>{{ m.fkCuenta }}</td><td>Q {{ formatNum(m.monto) }}</td><td>{{ m.descripcion }}</td><td>{{ m.usuario }}</td></tr></tbody></table>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { cxcService, type CxcDetalle, type CuentaBancariaDto, type MetodoCobroDto } from '@/services/cxc.service'
import { useToast } from '@/composables/useToast'

const route = useRoute()
const toast = useToast()
const detalle = ref<CxcDetalle | null>(null)
const metodos = ref<MetodoCobroDto[]>([])
const cuentas = ref<CuentaBancariaDto[]>([])
const cargando = ref(false)
const form = ref({ monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' })

const cxcId = computed(() => Number(route.params.id))
const puedeCobrar = computed(() => !!detalle.value && detalle.value.estado !== 'X' && detalle.value.saldo > 0)
const puedeAnular = computed(() => !!detalle.value && detalle.value.estado !== 'X' && detalle.value.valorCobrado === 0)

async function cargar() {
  try {
    cargando.value = true
    const [d, m, c] = await Promise.all([cxcService.obtener(cxcId.value), cxcService.listarMetodosCobro(), cxcService.listarCuentasBancarias()])
    detalle.value = d
    metodos.value = m
    cuentas.value = c
  } catch {
    toast.error('Error al cargar el detalle de CXC.')
  } finally {
    cargando.value = false
  }
}

async function registrarCobro() {
  if (form.value.monto <= 0 || !form.value.fkMetodoPago || !form.value.fkCuenta) {
    toast.error('Complete monto, metodo de cobro y cuenta bancaria.')
    return
  }
  if (detalle.value && form.value.monto > detalle.value.saldo) {
    toast.error('El monto no puede ser mayor al saldo pendiente.')
    return
  }
  try {
    await cxcService.registrarCobro(cxcId.value, {
      monto: form.value.monto,
      fkMetodoPago: form.value.fkMetodoPago,
      fkCuenta: form.value.fkCuenta,
      descripcion: form.value.descripcion || undefined
    })
    toast.exito('Cobro registrado correctamente.')
    form.value = { monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' }
    await cargar()
  } catch {
    toast.error('No fue posible registrar el cobro.')
  }
}

async function anular() {
  try {
    await cxcService.anular(cxcId.value, { motivo: 'Anulacion manual desde detalle CXC' })
    toast.exito('CXC anulada correctamente.')
    await cargar()
  } catch {
    toast.error('No fue posible anular la CXC.')
  }
}

function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem }
.header { display:flex; justify-content:space-between; align-items:center }
.page-title { font-size:1.3rem; font-weight:600 }
.card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.grid { display:grid; grid-template-columns:repeat(2,minmax(220px,1fr)); gap:.8rem }
.label { color:var(--color-text-muted); font-size:.8rem; display:block; margin-bottom:4px }
.form-grid { display:grid; grid-template-columns:repeat(2,minmax(220px,1fr)); gap:8px; margin:.75rem 0 }
.field { padding:.45rem .7rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-page); color:var(--color-text) }
.table { width:100%; border-collapse:collapse }
.table th,.table td { padding:.65rem; border-bottom:1px solid var(--color-border); text-align:left; font-size:.85rem }
.btn { padding:.45rem .8rem; border:1px solid var(--color-border); border-radius:8px; background:transparent; color:var(--color-text); cursor:pointer; text-decoration:none }
.btn-danger { background:#ef4444; color:#fff; border-color:#ef4444 }
.empty { color:var(--color-text-muted) }
</style>
