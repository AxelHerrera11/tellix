<template>
  <div class="page">
    <div class="page-header"><h2 class="page-title">Detalle CXC #{{ detalle?.id ?? '' }}</h2><router-link to="/cxc" class="btn btn-ghost">Volver</router-link></div>
    <div v-if="cargando" class="card">Cargando...</div>
    <template v-else-if="detalle">
      <div class="card detail-grid">
        <div><span class="label">Cliente</span><div>{{ detalle.cliente }} ({{ detalle.fkCliente }})</div></div>
        <div><span class="label">Venta asociada</span><div>#{{ detalle.fkVenta }}</div></div>
        <div><span class="label">Fecha operacion</span><div>{{ formatFecha(detalle.fechaOperacion) }}</div></div>
        <div><span class="label">Fecha limite</span><div>{{ formatFecha(detalle.fechaLimite) }}</div></div>
        <div><span class="label">Valor total</span><div>Q {{ formatNum(detalle.valorTotal) }}</div></div>
        <div><span class="label">Valor cobrado</span><div>Q {{ formatNum(detalle.valorCobrado) }}</div></div>
        <div><span class="label">Saldo</span><div>Q {{ formatNum(detalle.saldo) }}</div></div>
        <div><span class="label">Estado</span><div><span class="badge" :class="`badge--${detalle.estado.toLowerCase()}`">{{ detalle.estadoDescripcion }}</span><span v-if="detalle.vencida" class="badge badge--x">Vencida</span></div></div>
      </div>
      <div v-if="puedeCobrar" class="card">
        <h3>Registrar cobro</h3>
        <div class="form-grid">
          <input v-model.number="form.monto" class="field" type="number" step="0.01" min="0.01" placeholder="Monto" />
          <select v-model.number="form.fkMetodoPago" class="field"><option :value="0">Metodo de cobro</option><option v-for="m in metodos" :key="m.codigo" :value="m.codigo">{{ m.descripcion }}</option></select>
          <select v-model="form.fkCuenta" class="field"><option value="">Cuenta bancaria</option><option v-for="c in cuentas" :key="c.numero" :value="c.numero">{{ c.numero }} - {{ c.banco }}</option></select>
          <input v-model="form.descripcion" class="field" type="text" placeholder="Descripcion" />
        </div>
        <button class="btn btn-primary" @click="registrarCobro">Registrar cobro</button>
      </div>
      <div v-if="puedeAnular" class="card"><button class="btn btn-danger" @click="anular">Anular CXC</button></div>
      <div class="card">
        <h3>Movimientos de cobro</h3>
        <div v-if="!detalle.movimientos.length" class="table-empty">Sin movimientos registrados.</div>
        <table v-else class="data-table"><thead><tr><th>ID</th><th>Fecha</th><th>Cuenta</th><th>Monto</th><th>Descripcion</th><th>Usuario</th></tr></thead><tbody><tr v-for="m in detalle.movimientos" :key="m.id"><td>{{ m.id }}</td><td>{{ formatFecha(m.fechaOperacion) }}</td><td>{{ m.fkCuenta }}</td><td>Q {{ formatNum(m.monto) }}</td><td>{{ m.descripcion }}</td><td>{{ m.usuario }}</td></tr></tbody></table>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { useToast } from '@/composables/useToast'
import { cxcService, type CxcDetalle, type CuentaBancariaDto, type MetodoCobroDto } from '@/services/cxc.service'

const route = useRoute(); const toast = useToast()
const detalle = ref<CxcDetalle | null>(null); const metodos = ref<MetodoCobroDto[]>([]); const cuentas = ref<CuentaBancariaDto[]>([]); const cargando = ref(false)
const form = ref({ monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' })
const cxcId = computed(() => Number(route.params.id)); const puedeCobrar = computed(() => !!detalle.value && detalle.value.saldo > 0 && detalle.value.estado !== 'X'); const puedeAnular = computed(() => !!detalle.value && detalle.value.valorCobrado === 0 && detalle.value.estado !== 'X')
async function cargar() { try { cargando.value = true; const [d,m,c] = await Promise.all([cxcService.obtener(cxcId.value), cxcService.listarMetodosCobro(), cxcService.listarCuentasBancarias()]); detalle.value=d; metodos.value=m; cuentas.value=c } catch { toast.error('No fue posible cargar la CXC.') } finally { cargando.value = false } }
async function registrarCobro() { if (form.value.monto <= 0 || !form.value.fkMetodoPago || !form.value.fkCuenta) { toast.error('Complete monto, metodo y cuenta.'); return } try { await cxcService.registrarCobro(cxcId.value, { ...form.value, descripcion: form.value.descripcion || undefined }); toast.exito('Cobro registrado correctamente.'); form.value = { monto: 0, fkMetodoPago: 0, fkCuenta: '', descripcion: '' }; await cargar() } catch { toast.error('No fue posible registrar el cobro.') } }
async function anular() { try { await cxcService.anular(cxcId.value, 'Anulacion manual desde detalle CXC'); toast.exito('CXC anulada correctamente.'); await cargar() } catch { toast.error('No fue posible anular la CXC.') } }
function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }
onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem } .page-header { display:flex; justify-content:space-between; align-items:center } .page-title { font-size:1.3rem; font-weight:600 }
.card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.detail-grid { display:grid; grid-template-columns:repeat(2,minmax(230px,1fr)); gap:.9rem }
.label { color:var(--color-text-muted); font-size:.8rem; display:block; margin-bottom:4px }
.form-grid { display:grid; grid-template-columns:repeat(2,minmax(220px,1fr)); gap:8px; margin:.75rem 0 }
.field { padding:.45rem .75rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); color:var(--color-text) }
.badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:.75rem; font-weight:600; margin-right:6px }
.badge--a { background:rgba(45,212,160,0.15); color:#2dd4a0 } .badge--p { background:rgba(251,191,36,0.15); color:#fbbf24 } .badge--x { background:rgba(248,113,113,0.15); color:#f87171 }
.data-table { width:100%; border-collapse:collapse; font-size:.875rem } .data-table th,.data-table td { border-bottom:1px solid var(--color-border); padding:.65rem; text-align:left }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; border:1px solid transparent; cursor:pointer; text-decoration:none; display:inline-flex }
.btn-primary { background:var(--color-primary); color:#fff } .btn-danger { background:#ef4444; color:#fff } .btn-ghost { border-color:var(--color-border); color:var(--color-text-secondary) }
</style>
