<template>
  <div class="page">
    <div class="page-header"><h2 class="page-title">{{ esEdicion ? 'Editar precio' : 'Nuevo precio' }}</h2><router-link to="/precios" class="btn btn-ghost">Volver</router-link></div>
    <form class="form-card" @submit.prevent="guardar">
      <div class="form-grid">
        <div class="field"><label class="label">Producto</label><select v-model.number="form.fkProducto" class="input" :disabled="esEdicion"><option :value="0">Seleccionar...</option><option v-for="p in productos" :key="p.codigo" :value="p.codigo">{{ p.nombre }}</option></select></div>
        <div class="field"><label class="label">Aplicacion</label><input v-model="form.aplicacion" class="input" required /></div>
        <div class="field"><label class="label">Precio venta</label><input v-model.number="form.precioVenta" class="input" type="number" step="0.01" min="0.01" required /></div>
        <div class="field"><label class="label">Inicio vigencia</label><input v-model="form.inicioVigencia" class="input" type="date" required /></div>
        <div v-if="esEdicion" class="field"><label class="label">Fin vigencia</label><input v-model="form.finVigencia" class="input" type="date" /></div>
        <div v-else class="field"><label><input v-model="form.cerrarVigentes" type="checkbox" /> Cerrar vigentes anteriores</label></div>
      </div>
      <div class="form-actions"><button class="btn btn-primary" type="submit" :disabled="guardando">{{ guardando ? 'Guardando...' : 'Guardar' }}</button></div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { useToast } from '@/composables/useToast'
import { precioService, type ProductoPrecioDto } from '@/services/precio.service'

const route = useRoute(); const router = useRouter(); const toast = useToast(); const esEdicion = computed(() => !!route.params.id)
const productos = ref<ProductoPrecioDto[]>([]); const guardando = ref(false)
const form = ref({ fkProducto: 0, aplicacion: '', precioVenta: 0, inicioVigencia: new Date().toISOString().slice(0,10), finVigencia: '', cerrarVigentes: true })

async function cargarCatalogos() { try { productos.value = await precioService.listarProductos() } catch { toast.error('Error al cargar productos.') } }
async function cargarDetalle() { if (!esEdicion.value) return; try { const d = await precioService.obtener(Number(route.params.id)); form.value = { fkProducto: d.fkProducto, aplicacion: d.aplicacion, precioVenta: d.precioVenta, inicioVigencia: d.inicioVigencia?.slice(0,10) || '', finVigencia: d.finVigencia?.slice(0,10) || '', cerrarVigentes: true } } catch { toast.error('Error al cargar precio.') } }
async function guardar() {
  try {
    guardando.value = true
    if (esEdicion.value) {
      await precioService.actualizar(Number(route.params.id), { aplicacion: form.value.aplicacion, precioVenta: form.value.precioVenta, inicioVigencia: form.value.inicioVigencia, finVigencia: form.value.finVigencia || null })
      toast.exito('Precio actualizado correctamente.')
    } else {
      const id = await precioService.crear({ fkProducto: form.value.fkProducto, aplicacion: form.value.aplicacion, precioVenta: form.value.precioVenta, inicioVigencia: form.value.inicioVigencia, cerrarVigentes: form.value.cerrarVigentes })
      toast.exito('Precio creado correctamente.')
      router.push(`/precios/${id}`)
      return
    }
    router.push('/precios')
  } catch { toast.error('No fue posible guardar el precio.') }
  finally { guardando.value = false }
}
onMounted(() => { cargarCatalogos(); cargarDetalle() })
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1rem } .page-header { display:flex; justify-content:space-between; align-items:center } .page-title { font-size:1.3rem; font-weight:600 }
.form-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1rem }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem } .field { display:flex; flex-direction:column; gap:4px } .input { padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; background:var(--color-bg-page); color:var(--color-text) }
.form-actions { display:flex; justify-content:flex-end; margin-top:1rem }
.btn { padding:.5rem 1rem; border-radius:8px; border:1px solid transparent; text-decoration:none; cursor:pointer } .btn-primary { background:var(--color-primary); color:#fff } .btn-ghost { border-color:var(--color-border); color:var(--color-text-secondary) }
</style>
