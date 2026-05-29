<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import api, { type ApiResponse } from '@/services/api'

interface AuditoriaResumen {
  modulo: string
  accion: string
  descripcion: string
  usuario: string | null
  fecha: string | null
}

const eventos = ref<AuditoriaResumen[]>([])
const cargando = ref(false)
const error = ref<string | null>(null)
const busqueda = ref('')

const eventosFiltrados = computed(() => {
  const texto = busqueda.value.toLowerCase().trim()
  if (!texto) return eventos.value

  return eventos.value.filter(e =>
    e.modulo.toLowerCase().includes(texto) ||
    e.accion.toLowerCase().includes(texto) ||
    e.descripcion.toLowerCase().includes(texto) ||
    (e.usuario ?? '').toLowerCase().includes(texto)
  )
})

async function cargarAuditoria() {
  cargando.value = true
  error.value = null

  try {
    const { data } = await api.get<ApiResponse<AuditoriaResumen[]>>('/admin/auditoria')
    eventos.value = data.data
  } catch (e) {
    error.value = 'No se pudo cargar la actividad reciente.'
    console.error(e)
  } finally {
    cargando.value = false
  }
}

function formatoFecha(fecha: string | null) {
  if (!fecha) return '—'
  return new Date(fecha).toLocaleString('es-GT')
}

function claseAccion(accion: string) {
  const a = accion.toUpperCase()
  if (a.includes('CREACIÓN')) return 'create'
  if (a.includes('ACTUALIZACIÓN')) return 'update'
  if (a.includes('MOVIMIENTO')) return 'move'
  return 'default'
}

onMounted(() => {
  cargarAuditoria()
})
</script>

<template>
  <section class="auditoria-view">
    <div class="header">
      <div>
        <h2>Actividad reciente del sistema</h2>
        <p>Consulta eventos generados desde registros, movimientos de inventario y movimientos de cuenta.</p>
      </div>

      <button type="button" @click="cargarAuditoria">
        Actualizar
      </button>
    </div>

    <div class="toolbar">
      <input
        v-model="busqueda"
        type="text"
        placeholder="Buscar por módulo, acción, usuario o descripción..."
      >
    </div>

    <div v-if="cargando" class="state-card">
      Cargando actividad reciente...
    </div>

    <div v-else-if="error" class="state-card error">
      {{ error }}
    </div>

    <div v-else class="table-card">
      <table>
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Módulo</th>
            <th>Acción</th>
            <th>Usuario</th>
            <th>Descripción</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="(evento, index) in eventosFiltrados" :key="index">
            <td>{{ formatoFecha(evento.fecha) }}</td>
            <td class="strong">{{ evento.modulo }}</td>
            <td>
              <span class="badge" :class="claseAccion(evento.accion)">
                {{ evento.accion }}
              </span>
            </td>
            <td>{{ evento.usuario ?? 'Sistema' }}</td>
            <td>{{ evento.descripcion }}</td>
          </tr>

          <tr v-if="eventosFiltrados.length === 0">
            <td colspan="5" class="empty">
              No se encontraron eventos.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<style scoped>
.auditoria-view {
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

.toolbar input {
  width: 100%;
  max-width: 520px;
  padding: .7rem .9rem;
  border-radius: .6rem;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.06);
  color: var(--color-text);
  outline: none;
}

.table-card,
.state-card {
  border: 1px solid rgba(255,255,255,.12);
  border-radius: .8rem;
  background: rgba(255,255,255,.055);
  overflow: hidden;
}

.state-card {
  padding: 1rem;
  color: var(--color-text-muted);
}

.state-card.error {
  color: #ffb4b4;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: .85rem 1rem;
  text-align: left;
  border-bottom: 1px solid rgba(255,255,255,.08);
}

th {
  font-size: .78rem;
  text-transform: uppercase;
  letter-spacing: .05em;
  color: var(--color-text-muted);
  background: rgba(0,0,0,.18);
}

.strong {
  font-weight: 700;
}

.badge {
  display: inline-flex;
  align-items: center;
  padding: .25rem .55rem;
  border-radius: 999px;
  font-size: .78rem;
  font-weight: 700;
}

.badge.create {
  background: rgba(60, 190, 130, .16);
  color: #7ee0ad;
}

.badge.update {
  background: rgba(80, 150, 255, .16);
  color: #9dc2ff;
}

.badge.move {
  background: rgba(255, 190, 90, .16);
  color: #ffd08a;
}

.badge.default {
  background: rgba(255,255,255,.12);
  color: var(--color-text);
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
}
</style>
