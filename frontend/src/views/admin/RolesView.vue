<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import api, { type ApiResponse } from '@/services/api'

interface RolResumen {
  codigo: number
  nombre: string
  descripcion: string
  nivel: number
  activo: boolean
}

const roles = ref<RolResumen[]>([])
const cargando = ref(false)
const error = ref<string | null>(null)
const busqueda = ref('')

const rolesFiltrados = computed(() => {
  const texto = busqueda.value.toLowerCase().trim()
  if (!texto) return roles.value

  return roles.value.filter(rol =>
    rol.nombre.toLowerCase().includes(texto) ||
    rol.descripcion.toLowerCase().includes(texto)
  )
})

async function cargarRoles() {
  cargando.value = true
  error.value = null

  try {
    const { data } = await api.get<ApiResponse<RolResumen[]>>('/admin/roles')
    roles.value = data.data
  } catch (e) {
    error.value = 'No se pudieron cargar los roles.'
    console.error(e)
  } finally {
    cargando.value = false
  }
}

onMounted(() => {
  cargarRoles()
})
</script>

<template>
  <section class="roles-view">
    <div class="header">
      <div>
        <h2>Roles y permisos</h2>
        <p>Consulta los roles disponibles y su nivel de acceso en el sistema.</p>
      </div>
    </div>

    <div class="toolbar">
      <input
        v-model="busqueda"
        type="text"
        placeholder="Buscar rol..."
      >

      <button type="button" @click="cargarRoles">
        Actualizar
      </button>
    </div>

    <div v-if="cargando" class="state-card">
      Cargando roles...
    </div>

    <div v-else-if="error" class="state-card error">
      {{ error }}
    </div>

    <div v-else class="table-card">
      <table>
        <thead>
          <tr>
            <th>Código</th>
            <th>Rol</th>
            <th>Descripción</th>
            <th>Nivel</th>
            <th>Estado</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="rol in rolesFiltrados" :key="rol.codigo">
            <td>{{ rol.codigo }}</td>
            <td class="strong">{{ rol.nombre }}</td>
            <td>{{ rol.descripcion }}</td>
            <td>
              <span class="badge level">Nivel {{ rol.nivel }}</span>
            </td>
            <td>
              <span class="badge" :class="rol.activo ? 'active' : 'inactive'">
                {{ rol.activo ? 'Activo' : 'Inactivo' }}
              </span>
            </td>
          </tr>

          <tr v-if="rolesFiltrados.length === 0">
            <td colspan="5" class="empty">
              No se encontraron roles.
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<style scoped>
.roles-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h2 {
  font-size: 1.3rem;
  font-weight: 700;
}

.header p {
  margin-top: .35rem;
  color: var(--color-text-muted);
}

.toolbar {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.toolbar input {
  width: 100%;
  max-width: 420px;
  padding: .7rem .9rem;
  border-radius: .6rem;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.06);
  color: var(--color-text);
  outline: none;
}

.toolbar button {
  border: 1px solid rgba(255,255,255,.14);
  background: #2f7d7b;
  color: white;
  padding: .65rem .9rem;
  border-radius: .6rem;
  cursor: pointer;
  font-weight: 600;
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

.badge.level {
  background: rgba(80, 150, 255, .16);
  color: #9dc2ff;
}

.badge.active {
  background: rgba(60, 190, 130, .16);
  color: #7ee0ad;
}

.badge.inactive {
  background: rgba(255, 90, 90, .16);
  color: #ff9b9b;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
}
</style>
