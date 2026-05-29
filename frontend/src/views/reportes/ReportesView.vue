<script setup lang="ts">
import { onMounted, ref } from 'vue'
import api, { type ApiResponse } from '@/services/api'

interface ResumenGeneral {
  totalProductos: number
  totalClientes: number
  totalProveedores: number
  totalVentas: number
  totalCompras: number
  cxcPendientes: number
  cxpPendientes: number
  montoCxcPendiente: number
  montoCxpPendiente: number
}

const resumen = ref<ResumenGeneral | null>(null)
const cargando = ref(false)
const error = ref<string | null>(null)

async function cargarResumen() {
  cargando.value = true
  error.value = null

  try {
    const { data } = await api.get<ApiResponse<ResumenGeneral>>('/reportes/resumen')
    resumen.value = data.data
  } catch (e) {
    error.value = 'No se pudo cargar el resumen de reportes.'
    console.error(e)
  } finally {
    cargando.value = false
  }
}

function formatoMoneda(valor: number | null | undefined) {
  return new Intl.NumberFormat('es-GT', {
    style: 'currency',
    currency: 'GTQ'
  }).format(valor ?? 0)
}

onMounted(() => {
  cargarResumen()
})
</script>

<template>
  <section class="reportes-view">
    <div class="header">
      <div>
        <h2>Reportes</h2>
        <p>Resumen general de productos, clientes, compras, ventas y cuentas.</p>
      </div>

      <button type="button" @click="cargarResumen">
        Actualizar
      </button>
    </div>

    <div v-if="cargando" class="state-card">
      Cargando resumen...
    </div>

    <div v-else-if="error" class="state-card error">
      {{ error }}
    </div>

    <div v-else-if="resumen" class="content">
      <div class="cards-grid">
        <article class="card">
          <span class="label">Productos</span>
          <strong>{{ resumen.totalProductos }}</strong>
          <small>Productos registrados</small>
        </article>

        <article class="card">
          <span class="label">Clientes</span>
          <strong>{{ resumen.totalClientes }}</strong>
          <small>Clientes registrados</small>
        </article>

        <article class="card">
          <span class="label">Proveedores</span>
          <strong>{{ resumen.totalProveedores }}</strong>
          <small>Proveedores registrados</small>
        </article>

        <article class="card">
          <span class="label">Ventas</span>
          <strong>{{ resumen.totalVentas }}</strong>
          <small>Ventas registradas</small>
        </article>

        <article class="card">
          <span class="label">Compras</span>
          <strong>{{ resumen.totalCompras }}</strong>
          <small>Compras registradas</small>
        </article>

        <article class="card">
          <span class="label">CXC pendientes</span>
          <strong>{{ resumen.cxcPendientes }}</strong>
          <small>{{ formatoMoneda(resumen.montoCxcPendiente) }}</small>
        </article>

        <article class="card">
          <span class="label">CXP pendientes</span>
          <strong>{{ resumen.cxpPendientes }}</strong>
          <small>{{ formatoMoneda(resumen.montoCxpPendiente) }}</small>
        </article>
      </div>

      <div class="info-card">
        <h3>Resumen del módulo</h3>
        <p>
          Este reporte consolida información de productos, clientes, proveedores,
          ventas, compras, cuentas por cobrar y cuentas por pagar.
        </p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.reportes-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.header h2 {
  font-size: 1.3rem;
  font-weight: 700;
}

.header p {
  margin-top: .35rem;
  color: var(--color-text-muted);
}

.header button {
  border: 1px solid rgba(255,255,255,.14);
  background: #2f7d7b;
  color: white;
  padding: .65rem .9rem;
  border-radius: .6rem;
  cursor: pointer;
  font-weight: 600;
}

.state-card,
.info-card,
.card {
  border: 1px solid rgba(255,255,255,.12);
  border-radius: .9rem;
  background: rgba(255,255,255,.055);
}

.state-card {
  padding: 1rem;
  color: var(--color-text-muted);
}

.state-card.error {
  color: #ffb4b4;
}

.content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 1rem;
}

.card {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: .45rem;
}

.card .label {
  color: var(--color-text-muted);
  font-size: .85rem;
}

.card strong {
  font-size: 1.8rem;
  line-height: 1;
}

.card small {
  color: var(--color-text-muted);
}

.info-card {
  padding: 1rem;
}

.info-card h3 {
  font-size: 1.05rem;
  font-weight: 700;
  margin-bottom: .35rem;
}

.info-card p {
  color: var(--color-text-muted);
}

@media (max-width: 1100px) {
  .cards-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  .header {
    flex-direction: column;
    align-items: stretch;
  }

  .cards-grid {
    grid-template-columns: 1fr;
  }
}
</style>
