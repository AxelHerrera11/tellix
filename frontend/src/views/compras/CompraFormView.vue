<template>
    <div class="page">
      <div class="page-header">
        <div class="header-left">
          <router-link to="/compras" class="back-link">← Compras</router-link>
          <h2 class="page-title">Nueva compra</h2>
        </div>
      </div>

      <div class="pos-grid">
        <!-- Panel izquierdo: búsqueda y carrito -->
        <div class="pos-left">

          <!-- Número de documento -->
          <div class="card">
            <label class="label">Número de documento</label>
            <input
              v-model="form.noDocumento"
              type="text"
              placeholder="Ej: OC-2026-001"
              class="field-input"
            />
          </div>

          <!-- Búsqueda de proveedor -->
          <div class="card">
            <label class="label">Proveedor</label>
            <div class="search-row">
              <input
                v-model="proveedorBusqueda"
                type="text"
                placeholder="Buscar por nombre o NIT..."
                class="field-input"
                @input="buscarProveedores"
              />
              <button class="btn btn-ghost btn-sm" @click="proveedorSeleccionado = null">
                Limpiar
              </button>
            </div>
            <div v-if="proveedoresResultados.length && !proveedorSeleccionado" class="dropdown">
              <div
                v-for="p in proveedoresResultados"
                :key="p.nit"
                class="dropdown-item"
                @click="seleccionarProveedor(p)"
              >
                <span class="d-main">{{ p.nombre }}</span>
                <span class="d-sub">{{ p.nit }} — {{ p.direccion }}</span>
              </div>
            </div>
            <div v-if="proveedorSeleccionado" class="cliente-chip">
              <span class="chip-nombre">{{ proveedorSeleccionado.nombre }}</span>
              <span class="chip-nit">{{ proveedorSeleccionado.nit }}</span>
            </div>
          </div>

          <!-- Representante (opcional) -->
          <div class="card">
            <label class="label">Representante (opcional)</label>
            <div class="search-row">
              <input
                v-model="repBusqueda"
                type="text"
                placeholder="Buscar representante..."
                class="field-input"
                @input="buscarRepresentantes"
              />
              <button class="btn btn-ghost btn-sm" @click="repSeleccionado = null; repBusqueda = ''">
                Limpiar
              </button>
            </div>
            <div v-if="repsResultados.length && !repSeleccionado" class="dropdown">
              <div
                v-for="r in repsResultados"
                :key="r.nit"
                class="dropdown-item"
                @click="seleccionarRepresentante(r)"
              >
                <span class="d-main">{{ r.nombre }}</span>
                <span class="d-sub">{{ r.nit }}</span>
              </div>
            </div>
            <div v-if="repSeleccionado" class="cliente-chip">
              <span class="chip-nombre">{{ repSeleccionado.nombre }}</span>
              <span class="chip-nit">{{ repSeleccionado.nit }}</span>
            </div>
          </div>

          <!-- Búsqueda de productos -->
          <div class="card">
            <label class="label">Agregar producto</label>
            <div class="search-row">
              <input
                v-model="productoBusqueda"
                type="text"
                placeholder="Buscar producto por nombre o código..."
                class="field-input"
                @input="buscarProductos"
              />
            </div>
            <div v-if="productosResultados.length" class="dropdown">
              <div
                v-for="p in productosResultados"
                :key="p.codigo"
                class="dropdown-item"
                @click="agregarProducto(p)"
              >
                <span class="d-main">{{ p.nombre }}</span>
                <span class="d-sub">
                  Stock actual: {{ p.stockActual }} {{ p.medida || '' }}
                </span>
              </div>
            </div>
          </div>

          <!-- Carrito -->
          <div class="card card--grow">
            <label class="label">Detalle de la compra</label>
            <div v-if="!carrito.length" class="empty-cart">
              Agrega productos usando el buscador.
            </div>
            <table v-else class="cart-table">
              <thead>
                <tr>
                  <th>Producto</th><th>Cant.</th><th>Precio</th><th>Desc.</th><th>Imp.</th><th>Subtotal</th><th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, i) in carrito" :key="i">
                  <td class="td-nombre">{{ item.nombre }}</td>
                  <td>
                    <input
                      v-model.number="item.cantidad"
                      type="number"
                      min="0.0001"
                      step="1"
                      class="qty-input"
                      @change="recalcular"
                    />
                  </td>
                  <td>
                    <input
                      v-model.number="item.precioUnitario"
                      type="number"
                      min="0"
                      step="0.01"
                      class="qty-input"
                      @change="recalcular"
                    />
                  </td>
                  <td>
                    <input
                      v-model.number="item.descuentos"
                      type="number"
                      min="0"
                      step="0.01"
                      class="qty-input"
                      @change="recalcular"
                    />
                  </td>
                  <td>
                    <input
                      v-model.number="item.impuestos"
                      type="number"
                      min="0"
                      step="0.01"
                      class="qty-input"
                      @change="recalcular"
                    />
                  </td>
                  <td class="td-sub">Q {{ formatNum(item.subtotal) }}</td>
                  <td>
                    <button class="remove-btn" @click="quitarProducto(i)" title="Quitar">✕</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Panel derecho: totales y pago -->
        <div class="pos-right">
          <div class="card">
            <label class="label">Método de pago</label>
            <select v-model="form.fkMetodoPago" class="field-input">
              <option v-for="mp in metodosPago" :key="mp.codigo" :value="mp.codigo">
                {{ mp.nombre }}
              </option>
            </select>

            <div v-if="esCredito" class="plazo-row">
              <div class="plazo-field">
                <label class="label-sm">Plazo (días)</label>
                <input v-model.number="form.plazoCredito" type="number" min="1" class="field-input" />
              </div>
            </div>
          </div>

          <!-- Totales -->
          <div class="card totales-card">
            <div class="total-row">
              <span>Subtotal</span>
              <span>Q {{ formatNum(totales.subtotal) }}</span>
            </div>
            <div class="total-row">
              <span>Descuentos</span>
              <span>- Q {{ formatNum(totales.descuentos) }}</span>
            </div>
            <div class="total-row">
              <span>Impuestos</span>
              <span>Q {{ formatNum(totales.impuestos) }}</span>
            </div>
            <div class="total-row total-final">
              <span>TOTAL</span>
              <span>Q {{ formatNum(totales.total) }}</span>
            </div>
          </div>

          <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>

          <button
            class="btn btn-primary btn-full"
            :disabled="!puedeRegistrar || guardando"
            @click="registrar"
          >
            <span v-if="guardando" class="spinner" aria-hidden="true"></span>
            {{ guardando ? 'Registrando...' : 'Registrar compra' }}
          </button>
        </div>
      </div>
    </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { compraService, type ProductoCompra, type ProveedorCompra, type RepresentanteDto, type MetodoPagoDto } from '@/services/compra.service'
import { useToast } from '@/composables/useToast'

const router = useRouter()
const toast  = useToast()

// ── Estado ────────────────────────────────────────────────────
interface CartItem {
  fkProducto:     number
  nombre:         string
  cantidad:       number
  precioUnitario: number
  descuentos:     number
  impuestos:      number
  subtotal:       number
}

const proveedorBusqueda     = ref('')
const proveedoresResultados = ref<ProveedorCompra[]>([])
const proveedorSeleccionado = ref<ProveedorCompra | null>(null)

const repBusqueda     = ref('')
const repsResultados  = ref<RepresentanteDto[]>([])
const repSeleccionado = ref<RepresentanteDto | null>(null)

const productoBusqueda    = ref('')
const productosResultados = ref<ProductoCompra[]>([])

const metodosPago = ref<MetodoPagoDto[]>([])

const carrito   = ref<CartItem[]>([])
const guardando = ref(false)
const errorMsg  = ref('')

const form = ref({
  noDocumento:   '',
  fkMetodoPago:  1,
  plazoCredito:  0
})

// ── Init ──────────────────────────────────────────────────────
onMounted(async () => {
  try {
    metodosPago.value = await compraService.listarMetodosPago()
  } catch {
    toast.error('Error al cargar métodos de pago.')
  }
})

const esCredito = computed(() => {
  const mp = metodosPago.value.find(m => m.codigo === form.value.fkMetodoPago)
  return mp?.nombre?.toLowerCase().includes('credito') ?? false
})

// ── Totales reactivos ─────────────────────────────────────────
const totales = computed(() => {
  const subtotal   = carrito.value.reduce((s, i) => s + i.cantidad * i.precioUnitario, 0)
  const descuentos = carrito.value.reduce((s, i) => s + i.descuentos, 0)
  const impuestos  = carrito.value.reduce((s, i) => s + i.impuestos, 0)
  return { subtotal, descuentos, impuestos, total: subtotal - descuentos + impuestos }
})

const puedeRegistrar = computed(() =>
  form.value.noDocumento.trim() !== '' &&
  !!proveedorSeleccionado.value &&
  carrito.value.length > 0
)

// ── Búsquedas ─────────────────────────────────────────────────
let proveedorTimer: ReturnType<typeof setTimeout>
async function buscarProveedores() {
  clearTimeout(proveedorTimer)
  if (!proveedorBusqueda.value || proveedorBusqueda.value.length < 2) {
    proveedoresResultados.value = []
    return
  }
  proveedorTimer = setTimeout(async () => {
    proveedoresResultados.value = await compraService.buscarProveedores(proveedorBusqueda.value)
  }, 300)
}

let repTimer: ReturnType<typeof setTimeout>
async function buscarRepresentantes() {
  clearTimeout(repTimer)
  if (!repBusqueda.value || repBusqueda.value.length < 2) {
    repsResultados.value = []
    return
  }
  repTimer = setTimeout(async () => {
    repsResultados.value = await compraService.buscarRepresentantes(repBusqueda.value)
  }, 300)
}

let productoTimer: ReturnType<typeof setTimeout>
async function buscarProductos() {
  clearTimeout(productoTimer)
  if (!productoBusqueda.value || productoBusqueda.value.length < 2) {
    productosResultados.value = []
    return
  }
  productoTimer = setTimeout(async () => {
    productosResultados.value = await compraService.buscarProductos(productoBusqueda.value)
  }, 300)
}

// ── Acciones ──────────────────────────────────────────────────
function seleccionarProveedor(p: ProveedorCompra) {
  proveedorSeleccionado.value = p
  proveedoresResultados.value = []
  proveedorBusqueda.value     = p.nombre
}

function seleccionarRepresentante(r: RepresentanteDto) {
  repSeleccionado.value = r
  repsResultados.value  = []
  repBusqueda.value     = r.nombre
}

function agregarProducto(p: ProductoCompra) {
  const existente = carrito.value.find(i => i.fkProducto === p.codigo)
  if (existente) {
    existente.cantidad++
    recalcularItem(existente)
  } else {
    carrito.value.push({
      fkProducto:     p.codigo,
      nombre:         p.nombre,
      cantidad:       1,
      precioUnitario: 0,
      descuentos:     0,
      impuestos:      0,
      subtotal:       0
    })
  }
  productoBusqueda.value    = ''
  productosResultados.value = []
}

function quitarProducto(i: number) {
  carrito.value.splice(i, 1)
}

function recalcularItem(item: CartItem) {
  item.subtotal = (item.cantidad * item.precioUnitario) - item.descuentos + item.impuestos
}

function recalcular() {
  carrito.value.forEach(recalcularItem)
}

// ── Registrar ─────────────────────────────────────────────────
async function registrar() {
  errorMsg.value = ''
  if (!form.value.noDocumento.trim()) { errorMsg.value = 'Ingrese el número de documento.'; return }
  if (!proveedorSeleccionado.value)   { errorMsg.value = 'Seleccione un proveedor.'; return }
  if (!carrito.value.length)          { errorMsg.value = 'Agregue al menos un producto.'; return }

  try {
    guardando.value = true
    const id = await compraService.registrar({
      noDocumento:    form.value.noDocumento.trim(),
      fkProveedor:    proveedorSeleccionado.value.nit,
      fkRepresentante: repSeleccionado.value?.nit,
      fkMetodoPago:   form.value.fkMetodoPago,
      plazoCredito:   esCredito.value ? form.value.plazoCredito : 0,
      items: carrito.value.map(i => ({
        fkProducto:     i.fkProducto,
        cantidad:       i.cantidad,
        precioUnitario: i.precioUnitario,
        descuentos:     i.descuentos,
        impuestos:      i.impuestos
      }))
    })
    toast.exito(`Compra #${id} registrada correctamente.`)
    router.push(`/compras/${id}`)
  } catch (err: any) {
    errorMsg.value = err.response?.data?.mensaje ?? 'Error al registrar la compra.'
  } finally {
    guardando.value = false
  }
}

function formatNum(n: number) {
  return Number(n ?? 0).toFixed(2)
}
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center }
.header-left { display:flex; flex-direction:column; gap:2px }
.back-link { font-size:.85rem; color:var(--color-primary); text-decoration:none }
.back-link:hover { text-decoration:underline }
.page-title { font-size:1.3rem; font-weight:600 }

.pos-grid { display:grid; grid-template-columns:1fr 300px; gap:1rem; align-items:start }

.card {
  background:var(--color-bg-card);
  border:1px solid var(--color-border);
  border-radius:12px;
  padding:1rem;
  margin-bottom:1rem;
}
.card--grow { flex:1 }
.pos-left { display:flex; flex-direction:column }
.pos-right { display:flex; flex-direction:column; position:sticky; top:1rem }

.label { display:block; font-size:.8rem; font-weight:600; color:var(--color-text-secondary); margin-bottom:6px; text-transform:uppercase; letter-spacing:.04em }
.label-sm { display:block; font-size:.75rem; color:var(--color-text-muted); margin-bottom:4px }

.field-input { width:100%; padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-input); color:var(--color-text); box-sizing:border-box }
.field-input:focus { outline:none; border-color:var(--color-primary) }

.search-row { display:flex; gap:8px; align-items:center }
.search-row .field-input { flex:1 }

.dropdown { border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-card); margin-top:4px; max-height:200px; overflow-y:auto }
.dropdown-item { padding:.6rem .75rem; cursor:pointer; display:flex; flex-direction:column; gap:2px; border-bottom:1px solid var(--color-border) }
.dropdown-item:last-child { border-bottom:none }
.dropdown-item:hover { background:var(--color-bg-page) }
.d-main { font-size:.875rem; font-weight:500 }
.d-sub { font-size:.75rem; color:var(--color-text-muted) }

.cliente-chip { display:flex; gap:8px; align-items:center; background:var(--color-primary-light); border-radius:8px; padding:.5rem .75rem; margin-top:8px }
.chip-nombre { font-weight:600; font-size:.875rem; color:var(--color-primary) }
.chip-nit { font-size:.75rem; color:var(--color-text-muted) }

.empty-cart { padding:2rem; text-align:center; color:var(--color-text-muted); font-size:.875rem }

.cart-table { width:100%; border-collapse:collapse; font-size:.85rem }
.cart-table th { padding:.5rem .5rem; text-align:left; font-size:.75rem; font-weight:600; color:var(--color-text-secondary); border-bottom:1px solid var(--color-border) }
.cart-table td { padding:.5rem .5rem; border-bottom:1px solid var(--color-border); vertical-align:middle }
.cart-table tbody tr:last-child td { border-bottom:none }
.td-nombre { max-width:160px }
.td-precio,.td-sub { font-variant-numeric:tabular-nums }
.qty-input { width:70px; padding:.3rem .5rem; border:1px solid var(--color-border); border-radius:6px; font-size:.85rem; background:var(--color-bg-input); color:var(--color-text) }
.remove-btn { background:none; border:none; cursor:pointer; color:var(--color-danger); font-size:.9rem; padding:2px 6px; border-radius:4px }
.remove-btn:hover { background:var(--color-danger-bg) }

.plazo-row { margin-top:10px }

.totales-card .total-row { display:flex; justify-content:space-between; padding:.4rem 0; font-size:.875rem; border-bottom:1px solid var(--color-border) }
.totales-card .total-row:last-child { border-bottom:none }
.total-final { font-size:1.1rem; font-weight:700; padding-top:.75rem !important }

.error-msg { background:var(--color-danger-bg); color:var(--color-danger); border:1px solid var(--color-danger-border); border-radius:8px; padding:.6rem .75rem; font-size:.85rem; margin-bottom:.5rem }

.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover:not(:disabled) { background:var(--color-primary-hover) }
.btn-primary:disabled { opacity:.55; cursor:not-allowed }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn-sm { padding:.35rem .65rem; font-size:.8rem }
.btn-full { width:100%; justify-content:center; margin-top:.25rem }

.spinner { width:15px; height:15px; border:2px solid rgba(255,255,255,.4); border-top-color:#fff; border-radius:50%; animation:spin .7s linear infinite }
@keyframes spin { to { transform:rotate(360deg) } }

@media (max-width: 768px) {
  .pos-grid { grid-template-columns:1fr }
  .pos-right { position:static }
}
</style>
