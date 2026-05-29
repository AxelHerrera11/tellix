<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">Detalle precio #{{ detalle?.id ?? '' }}</h2>
      <div class="header-actions">
        <router-link v-if="auth.tieneRol('ADMINISTRADOR') && detalle" :to="`/precios/${detalle.id}/editar`" class="btn btn-secondary">Editar</router-link>
        <button v-if="auth.tieneRol('ADMINISTRADOR') && detalle" class="btn btn-secondary" @click="toggleEstado">{{ detalle.estado === 'A' ? 'Inactivar' : 'Activar' }}</button>
        <router-link to="/precios" class="btn btn-ghost">Volver</router-link>
      </div>
    </div>
    <div v-if="cargando" class="card">Cargando...</div>
    <div v-else-if="detalle" class="card info-grid">
      <div><span class="label">Producto</span><div>{{ detalle.producto }}</div></div>
      <div><span class="label">Aplicacion</span><div>{{ detalle.aplicacion }}</div></div>
      <div><span class="label">Precio</span><div>Q {{ formatNum(detalle.precioVenta) }}</div></div>
      <div><span class="label">Vigencia</span><div>{{ formatFecha(detalle.inicioVigencia) }} - {{ formatFecha(detalle.finVigencia || undefined) }}</div></div>
      <div><span class="label">Estado</span><div>{{ detalle.estadoDescripcion }}</div></div>
      <div><span class="label">Usuario creador</span><div>{{ detalle.usuario || '—' }}</div></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { useToast } from '@/composables/useToast'
import { useAuthStore } from '@/stores/auth.store'
import { precioService, type PrecioDetalle } from '@/services/precio.service'

const route = useRoute(); const toast = useToast(); const auth = useAuthStore()
const detalle = ref<PrecioDetalle | null>(null); const cargando = ref(false)
async function cargar() { try { cargando.value = true; detalle.value = await precioService.obtener(Number(route.params.id)) } catch { toast.error('Error al cargar precio.') } finally { cargando.value = false } }
async function toggleEstado() { if (!detalle.value) return; try { await precioService.cambiarEstado(detalle.value.id, detalle.value.estado === 'A' ? 'I' : 'A'); toast.exito('Estado actualizado.'); await cargar() } catch { toast.error('No fue posible cambiar el estado.') } }
function formatFecha(f?: string) { return f ? new Date(f).toLocaleDateString('es-GT') : '—' }
function formatNum(n?: number) { return Number(n ?? 0).toFixed(2) }
onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem } .page-header { display:flex; justify-content:space-between; align-items:center } .page-title { font-size:1.3rem; font-weight:600 }
.header-actions { display:flex; gap:8px } .card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.info-grid { display:grid; grid-template-columns:repeat(2,minmax(240px,1fr)); gap:1rem } .label { color:var(--color-text-muted); font-size:.8rem; display:block; margin-bottom:4px }
.btn { padding:.5rem 1rem; border-radius:8px; border:1px solid transparent; text-decoration:none; cursor:pointer } .btn-secondary,.btn-ghost { border-color:var(--color-border); color:var(--color-text-secondary) }
</style>
