<template>
  <div class="page">
    <div class="page-header">
      <h2 class="page-title">{{ esEdicion ? 'Editar producto' : 'Nuevo producto' }}</h2>
      <router-link to="/catalogos/productos" class="btn btn-ghost">← Volver</router-link>
    </div>

    <form class="form-card" @submit.prevent="guardar">
      <div class="form-grid">
        <div class="field">
          <label class="label">Nombre <span class="required">*</span></label>
          <input v-model="form.nombre" type="text" class="input" required placeholder="Nombre del producto" />
        </div>
        <div class="field">
          <label class="label">Descripción</label>
          <input v-model="form.descripcion" type="text" class="input" placeholder="Descripción opcional" />
        </div>
        <div class="field">
          <label class="label">Categoría</label>
          <select v-model="form.fkCategoria" class="input">
            <option :value="undefined">Seleccionar...</option>
            <option v-for="c in categorias" :key="c.codigo" :value="c.codigo">{{ c.descripcion }}</option>
          </select>
        </div>
        <div class="field">
          <label class="label">Marca</label>
          <select v-model="form.fkMarca" class="input">
            <option :value="undefined">Seleccionar...</option>
            <option v-for="m in marcas" :key="m.codigo" :value="m.codigo">{{ m.nombre }}</option>
          </select>
        </div>
        <div class="field">
          <label class="label">Unidad de medida</label>
          <select v-model="form.fkMedida" class="input">
            <option :value="undefined">Seleccionar...</option>
            <option v-for="m in medidas" :key="m.codigo" :value="m.codigo">{{ m.descripcion }} ({{ m.codigo }})</option>
          </select>
        </div>
        <div class="field">
          <label class="label">Cantidad por unidad</label>
          <input v-model.number="form.cantidadMedida" type="number" step="0.01" min="0" class="input" placeholder="1.00" />
        </div>
        <div class="field">
          <label class="label">Stock mínimo</label>
          <input v-model.number="form.stockMinimo" type="number" step="0.01" min="0" class="input" placeholder="0" />
        </div>
        <div v-if="!esEdicion" class="field">
          <label class="label">Precio de venta</label>
          <input v-model.number="form.precioVenta" type="number" step="0.01" min="0" class="input" placeholder="0.00" />
        </div>
        <div v-if="!esEdicion" class="field">
          <label class="label">Aplicación del precio</label>
          <select v-model="form.aplicacion" class="input">
            <option value="">Seleccionar...</option>
            <option value="VENTA">Venta</option>
            <option value="COMPRA">Compra</option>
            <option value="AMBOS">Ambos</option>
          </select>
        </div>
      </div>

      <div class="form-actions">
        <router-link to="/catalogos/productos" class="btn btn-ghost">Cancelar</router-link>
        <button type="submit" class="btn btn-primary" :disabled="guardando">
          {{ guardando ? 'Guardando...' : (esEdicion ? 'Actualizar' : 'Crear producto') }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute, RouterLink } from 'vue-router'
import { productoService, type CategoriaDto, type MarcaDto, type MedidaDto } from '@/services/producto.service'
import { useToast } from '@/composables/useToast'

const router  = useRouter()
const route   = useRoute()
const toast   = useToast()

const esEdicion   = computed(() => !!route.params.id)
const guardando   = ref(false)
const categorias  = ref<CategoriaDto[]>([])
const marcas      = ref<MarcaDto[]>([])
const medidas     = ref<MedidaDto[]>([])

const form = ref({
  nombre:          '',
  descripcion:     '',
  fkCategoria:     undefined as number | undefined,
  fkMarca:         undefined as number | undefined,
  fkMedida:        undefined as string | undefined,
  cantidadMedida:  undefined as number | undefined,
  stockMinimo:     undefined as number | undefined,
  precioVenta:     undefined as number | undefined,
  aplicacion:      ''
})

async function cargarCatalogos() {
  try {
    const [cat, mar, med] = await Promise.all([
      productoService.listarCategorias(),
      productoService.listarMarcas(),
      productoService.listarMedidas()
    ])
    categorias.value = cat
    marcas.value     = mar
    medidas.value    = med
  } catch { toast.error('Error al cargar catálogos.') }
}

async function cargarProducto() {
  if (!esEdicion.value) return
  try {
    const p = await productoService.obtener(Number(route.params.id))
    form.value = {
      nombre:          p.nombre,
      descripcion:     p.descripcion ?? '',
      fkCategoria:     p.categoriaCodigo ?? undefined,
      fkMarca:         p.marcaCodigo ?? undefined,
      fkMedida:        p.medidaCodigo ?? undefined,
      cantidadMedida:  p.cantidadMedida ?? undefined,
      stockMinimo:     p.stockMinimo ?? undefined,
      precioVenta:     undefined,
      aplicacion:      ''
    }
  } catch { toast.error('Error al cargar el producto.') }
}

async function guardar() {
  try {
    guardando.value = true
    if (esEdicion.value) {
      await productoService.actualizar(Number(route.params.id), {
        nombre:          form.value.nombre,
        descripcion:     form.value.descripcion || undefined,
        stockMinimo:     form.value.stockMinimo,
        fkCategoria:     form.value.fkCategoria,
        fkMarca:         form.value.fkMarca,
        fkMedida:        form.value.fkMedida,
        cantidadMedida:  form.value.cantidadMedida
      })
      toast.exito('Producto actualizado correctamente.')
    } else {
      const id = await productoService.crear({
        nombre:          form.value.nombre,
        descripcion:     form.value.descripcion || undefined,
        stockMinimo:     form.value.stockMinimo,
        fkCategoria:     form.value.fkCategoria,
        fkMarca:         form.value.fkMarca,
        fkMedida:        form.value.fkMedida,
        cantidadMedida:  form.value.cantidadMedida,
        precioVenta:     form.value.precioVenta,
        aplicacion:      form.value.aplicacion || undefined
      })
      toast.exito('Producto creado correctamente.')
      router.push(`/catalogos/productos/${id}`)
      return
    }
    router.push('/catalogos/productos')
  } catch { toast.error('Error al guardar el producto.') }
  finally { guardando.value = false }
}

onMounted(() => { cargarCatalogos(); cargarProducto() })
</script>

<style scoped>
.page { display:flex; flex-direction:column; gap:1.25rem }
.page-header { display:flex; align-items:center; justify-content:space-between }
.page-title { font-size:1.3rem; font-weight:600 }
.form-card { background:var(--color-bg-card); border:1px solid var(--color-border); border-radius:12px; padding:1.5rem }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem }
.field { display:flex; flex-direction:column; gap:4px }
.label { font-size:.85rem; font-weight:500; color:var(--color-text-secondary) }
.required { color:var(--color-danger) }
.input { padding:.5rem .75rem; border:1px solid var(--color-border); border-radius:8px; font-size:.875rem; background:var(--color-bg-page); color:var(--color-text) }
.input:focus { outline:2px solid var(--color-primary); outline-offset:-1px; border-color:transparent }
.form-actions { display:flex; justify-content:flex-end; gap:8px; margin-top:1.5rem; padding-top:1rem; border-top:1px solid var(--color-border) }
.btn { padding:.5rem 1rem; border-radius:8px; font-size:.875rem; font-weight:500; cursor:pointer; border:1px solid transparent; transition:all .15s; text-decoration:none; display:inline-flex; align-items:center; gap:4px }
.btn-primary { background:var(--color-primary); color:#fff }
.btn-primary:hover { background:var(--color-primary-hover) }
.btn-ghost { background:transparent; color:var(--color-text-secondary); border-color:var(--color-border) }
.btn-ghost:hover { background:var(--color-bg-page) }
.btn:disabled { opacity:.5; cursor:not-allowed }
</style>
