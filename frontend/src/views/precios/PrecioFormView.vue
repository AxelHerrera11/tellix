<template>
  <div class="page">
    <div class="header"><h2 class="page-title">{{ esEdicion ? 'Editar precio' : 'Nuevo precio' }}</h2><router-link to="/precios" class="btn">Volver</router-link></div>
    <form class="card" @submit.prevent="guardar">
      <div class="grid">
        <div class="field"><label>Producto</label><select v-model.number="form.fkProducto" class="input" :disabled="esEdicion"><option :value="0">Seleccionar...</option><option v-for="p in productos" :key="p.codigo" :value="p.codigo">{{ p.nombre }}</option></select></div>
        <div class="field"><label>Aplicacion</label><input v-model="form.aplicacion" class="input" required /></div>
        <div class="field"><label>Precio venta</label><input v-model.number="form.precioVenta" class="input" type="number" min="0.01" step="0.01" required /></div>
        <div class="field"><label>Inicio vigencia</label><input v-model="form.inicioVigencia" class="input" type="date" required /></div>
        <div v-if="esEdicion" class="field"><label>Fin vigencia</label><input v-model="form.finVigencia" class="input" type="date" /></div>
        <div v-else class="field"><label><input v-model="form.cerrarVigentes" type="checkbox" /> Cerrar vigentes anteriores</label></div>
      </div>
      <div class="actions"><button class="btn" :disabled="guardando">{{ guardando ? 'Guardando...' : 'Guardar' }}</button></div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { precioService, type ProductoPrecioDto } from '@/services/precio.service'
import { useToast } from '@/composables/useToast'

const route = useRoute(); const router = useRouter(); const toast = useToast()
const esEdicion = computed(() => !!route.params.id)
const guardando = ref(false)
const productos = ref<ProductoPrecioDto[]>([])
const form = ref({ fkProducto: 0, aplicacion: '', precioVenta: 0, inicioVigencia: new Date().toISOString().slice(0,10), finVigencia: '', cerrarVigentes: true })

async function cargar() {
  try {
    productos.value = await precioService.listarProductos()
    if (esEdicion.value) {
      const d = await precioService.obtener(Number(route.params.id))
      form.value = {
        fkProducto: d.fkProducto,
        aplicacion: d.aplicacion,
        precioVenta: d.precioVenta,
        inicioVigencia: d.inicioVigencia?.slice(0,10) || '',
        finVigencia: d.finVigencia?.slice(0,10) || '',
        cerrarVigentes: true
      }
    }
  } catch { toast.error('Error al cargar formulario de precio.') }
}

async function guardar() {
  if (!esEdicion.value && form.value.fkProducto <= 0) {
    toast.error('Debe seleccionar un producto.')
    return
  }
  if (form.value.finVigencia && form.value.finVigencia < form.value.inicioVigencia) {
    toast.error('La fecha fin no puede ser menor a la fecha inicio.')
    return
  }
  try {
    guardando.value = true
    if (esEdicion.value) {
      await precioService.actualizar(Number(route.params.id), {
        aplicacion: form.value.aplicacion,
        precioVenta: form.value.precioVenta,
        inicioVigencia: form.value.inicioVigencia,
        finVigencia: form.value.finVigencia || null
      })
      toast.exito('Precio actualizado correctamente.')
      router.push(`/precios/${route.params.id}`)
    } else {
      const id = await precioService.crear({
        fkProducto: form.value.fkProducto,
        aplicacion: form.value.aplicacion,
        precioVenta: form.value.precioVenta,
        inicioVigencia: form.value.inicioVigencia,
        cerrarVigentes: form.value.cerrarVigentes
      })
      toast.exito('Precio creado correctamente.')
      router.push(`/precios/${id}`)
    }
  } catch { toast.error('No fue posible guardar el precio.') }
  finally { guardando.value = false }
}

onMounted(cargar)
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem }
.header { display:flex; justify-content:space-between; align-items:center }
.page-title { font-size:1.3rem; font-weight:600 }
.card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.grid { display:grid; grid-template-columns:repeat(2,minmax(220px,1fr)); gap:.8rem }
.field { display:flex; flex-direction:column; gap:4px }
.input { padding:.45rem .7rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-page); color:var(--color-text) }
.actions { margin-top:1rem; display:flex; justify-content:flex-end }
.btn { padding:.45rem .8rem; border:1px solid var(--color-border); border-radius:8px; background:transparent; color:var(--color-text); cursor:pointer; text-decoration:none }
</style>
