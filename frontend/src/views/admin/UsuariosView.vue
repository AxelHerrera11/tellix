<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import api, { type ApiResponse } from '@/services/api'

interface UsuarioResumen {
  codigo: number
  userName: string
  empleadoCodigo: number
  nombres: string
  apellidos: string
  rolCodigo: number
  rol: string
  estado: string
  ultimoAcceso: string | null
  creadoEn: string | null
}

interface RolResumen {
  codigo: number
  nombre: string
  descripcion: string
  nivel: number
  activo: boolean
}

const usuarios = ref<UsuarioResumen[]>([])
const roles = ref<RolResumen[]>([])

const cargando = ref(false)
const guardando = ref(false)
const error = ref<string | null>(null)
const busqueda = ref('')
const mostrarModal = ref(false)

const form = ref({
  documentoIdentificacion: '',
  nombre1: '',
  nombre2: '',
  apellido1: '',
  apellido2: '',
  userName: '',
  password: '',
  fkRol: 2,
  estado: 'A'
})

const usuariosFiltrados = computed(() => {
  const texto = busqueda.value.toLowerCase().trim()
  if (!texto) return usuarios.value

  return usuarios.value.filter(usuario =>
    usuario.userName.toLowerCase().includes(texto) ||
    usuario.nombres.toLowerCase().includes(texto) ||
    usuario.apellidos.toLowerCase().includes(texto) ||
    usuario.rol.toLowerCase().includes(texto)
  )
})

async function cargarUsuarios() {
  cargando.value = true
  error.value = null

  try {
    const { data } = await api.get<ApiResponse<UsuarioResumen[]>>('/admin/usuarios')
    usuarios.value = data.data
  } catch (e) {
    error.value = 'No se pudieron cargar los usuarios.'
    console.error(e)
  } finally {
    cargando.value = false
  }
}

async function cargarRoles() {
  try {
    const { data } = await api.get<ApiResponse<RolResumen[]>>('/admin/roles')
    roles.value = data.data
  } catch (e) {
    console.error('No se pudieron cargar roles', e)
  }
}

function abrirModal() {
  form.value = {
    documentoIdentificacion: '',
    nombre1: '',
    nombre2: '',
    apellido1: '',
    apellido2: '',
    userName: '',
    password: '',
    fkRol: 2,
    estado: 'A'
  }

  mostrarModal.value = true
}

function cerrarModal() {
  mostrarModal.value = false
}

async function guardarUsuario() {
  if (!form.value.nombre1 || !form.value.apellido1 || !form.value.userName || !form.value.password) {
    alert('Complete nombre, apellido, usuario y contraseña.')
    return
  }

  guardando.value = true

  try {
    await api.post('/admin/usuarios', form.value)
    cerrarModal()
    await cargarUsuarios()
  } catch (e) {
    console.error(e)
    alert('No se pudo crear el usuario. Revise la consola o el backend.')
  } finally {
    guardando.value = false
  }
}

function estadoTexto(estado: string) {
  if (estado === 'A') return 'Activo'
  if (estado === 'I') return 'Inactivo'
  return estado
}

function formatoFecha(fecha: string | null) {
  if (!fecha) return '—'
  return new Date(fecha).toLocaleString('es-GT')
}

onMounted(() => {
  cargarUsuarios()
  cargarRoles()
})
</script>

<template>
  <section class="usuarios-view">
    <div class="header">
      <div>
        <h2>Usuarios del sistema</h2>
        <p>Administración de usuarios, empleados y roles asignados.</p>
      </div>

      <button class="btn-primary" type="button" @click="abrirModal">
        + Nuevo usuario
      </button>
    </div>

    <div class="toolbar">
      <input
        v-model="busqueda"
        type="text"
        placeholder="Buscar por usuario, nombre o rol..."
      />

      <button type="button" @click="cargarUsuarios">
        Actualizar
      </button>
    </div>

    <div v-if="cargando" class="state-card">
      Cargando usuarios...
    </div>

    <div v-else-if="error" class="state-card error">
      {{ error }}
    </div>

    <div v-else class="table-card">
      <table>
        <thead>
          <tr>
            <th>Código</th>
            <th>Usuario</th>
            <th>Empleado</th>
            <th>Rol</th>
            <th>Estado</th>
            <th>Último acceso</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="usuario in usuariosFiltrados" :key="usuario.codigo">
            <td>{{ usuario.codigo }}</td>
            <td class="strong">{{ usuario.userName }}</td>
            <td>{{ usuario.nombres }} {{ usuario.apellidos }}</td>
            <td>
              <span class="badge role">{{ usuario.rol }}</span>
            </td>
            <td>
              <span
                class="badge"
                :class="usuario.estado === 'A' ? 'active' : 'inactive'"
              >
                {{ estadoTexto(usuario.estado) }}
              </span>
            </td>
            <td>{{ formatoFecha(usuario.ultimoAcceso) }}</td>
          </tr>

          <tr v-if="usuariosFiltrados.length === 0">
            <td colspan="6" class="empty">
              No se encontraron usuarios.
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="mostrarModal" class="modal-backdrop">
      <div class="modal">
        <div class="modal-header">
          <h3>Nuevo usuario</h3>
          <button type="button" class="close-btn" @click="cerrarModal">×</button>
        </div>

        <div class="form-grid">
          <label>
            DPI / Documento
            <input v-model="form.documentoIdentificacion" type="text" placeholder="Ej. 1234567890101">
          </label>

          <label>
            Primer nombre *
            <input v-model="form.nombre1" type="text" placeholder="Primer nombre">
          </label>

          <label>
            Segundo nombre
            <input v-model="form.nombre2" type="text" placeholder="Segundo nombre">
          </label>

          <label>
            Primer apellido *
            <input v-model="form.apellido1" type="text" placeholder="Primer apellido">
          </label>

          <label>
            Segundo apellido
            <input v-model="form.apellido2" type="text" placeholder="Segundo apellido">
          </label>

          <label>
            Usuario *
            <input v-model="form.userName" type="text" placeholder="usuario">
          </label>

          <label>
            Contraseña *
            <input v-model="form.password" type="password" placeholder="Contraseña">
          </label>

          <label>
            Rol
            <select v-model.number="form.fkRol">
              <option v-for="rol in roles" :key="rol.codigo" :value="rol.codigo">
                {{ rol.nombre }}
              </option>
            </select>
          </label>

          <label>
            Estado
            <select v-model="form.estado">
              <option value="A">Activo</option>
              <option value="I">Inactivo</option>
            </select>
          </label>
        </div>

        <div class="modal-actions">
          <button type="button" class="btn-secondary" @click="cerrarModal">
            Cancelar
          </button>

          <button type="button" class="btn-primary" :disabled="guardando" @click="guardarUsuario">
            {{ guardando ? 'Guardando...' : 'Guardar usuario' }}
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.usuarios-view {
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

.btn-primary,
.btn-secondary,
.toolbar button {
  border: 1px solid rgba(255,255,255,.14);
  padding: .65rem .9rem;
  border-radius: .6rem;
  cursor: pointer;
  font-weight: 600;
}

.btn-primary {
  background: #2f7d7b;
  color: white;
}

.btn-primary:disabled {
  opacity: .65;
  cursor: not-allowed;
}

.btn-secondary {
  background: rgba(255,255,255,.08);
  color: var(--color-text);
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

td {
  color: var(--color-text);
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

.badge.role {
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

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.55);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 100;
}

.modal {
  width: 100%;
  max-width: 720px;
  border-radius: 1rem;
  border: 1px solid rgba(255,255,255,.12);
  background: #151b22;
  padding: 1rem;
  box-shadow: 0 20px 70px rgba(0,0,0,.45);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.modal-header h3 {
  font-size: 1.15rem;
  font-weight: 700;
}

.close-btn {
  background: transparent;
  border: none;
  color: var(--color-text);
  font-size: 1.5rem;
  cursor: pointer;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: .9rem;
}

.form-grid label {
  display: flex;
  flex-direction: column;
  gap: .35rem;
  font-size: .85rem;
  color: var(--color-text-muted);
}

.form-grid input,
.form-grid select {
  padding: .7rem .8rem;
  border-radius: .6rem;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.06);
  color: var(--color-text);
  outline: none;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: .75rem;
  margin-top: 1rem;
}

@media (max-width: 720px) {
  .form-grid {
    grid-template-columns: 1fr;
  }

  .header,
  .toolbar {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
