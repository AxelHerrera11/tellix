/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />
import { ref, computed, onMounted } from 'vue';
import { useRouter, useRoute, RouterLink } from 'vue-router';
import { productoService } from '@/services/producto.service';
import { useToast } from '@/composables/useToast';
const router = useRouter();
const route = useRoute();
const toast = useToast();
const esEdicion = computed(() => !!route.params.id);
const guardando = ref(false);
const categorias = ref([]);
const marcas = ref([]);
const medidas = ref([]);
const form = ref({
    nombre: '',
    descripcion: '',
    fkCategoria: undefined,
    fkMarca: undefined,
    fkMedida: undefined,
    cantidadMedida: undefined,
    stockMinimo: undefined,
    precioVenta: undefined,
    aplicacion: ''
});
async function cargarCatalogos() {
    try {
        const [cat, mar, med] = await Promise.all([
            productoService.listarCategorias(),
            productoService.listarMarcas(),
            productoService.listarMedidas()
        ]);
        categorias.value = cat;
        marcas.value = mar;
        medidas.value = med;
    }
    catch {
        toast.error('Error al cargar catálogos.');
    }
}
async function cargarProducto() {
    if (!esEdicion.value)
        return;
    try {
        const p = await productoService.obtener(Number(route.params.id));
        form.value = {
            nombre: p.nombre,
            descripcion: p.descripcion ?? '',
            fkCategoria: p.categoriaCodigo ?? undefined,
            fkMarca: p.marcaCodigo ?? undefined,
            fkMedida: p.medidaCodigo ?? undefined,
            cantidadMedida: p.cantidadMedida ?? undefined,
            stockMinimo: p.stockMinimo ?? undefined,
            precioVenta: undefined,
            aplicacion: ''
        };
    }
    catch {
        toast.error('Error al cargar el producto.');
    }
}
async function guardar() {
    try {
        guardando.value = true;
        if (esEdicion.value) {
            await productoService.actualizar(Number(route.params.id), {
                nombre: form.value.nombre,
                descripcion: form.value.descripcion || undefined,
                stockMinimo: form.value.stockMinimo,
                fkCategoria: form.value.fkCategoria,
                fkMarca: form.value.fkMarca,
                fkMedida: form.value.fkMedida,
                cantidadMedida: form.value.cantidadMedida
            });
            toast.exito('Producto actualizado correctamente.');
        }
        else {
            const id = await productoService.crear({
                nombre: form.value.nombre,
                descripcion: form.value.descripcion || undefined,
                stockMinimo: form.value.stockMinimo,
                fkCategoria: form.value.fkCategoria,
                fkMarca: form.value.fkMarca,
                fkMedida: form.value.fkMedida,
                cantidadMedida: form.value.cantidadMedida,
                precioVenta: form.value.precioVenta,
                aplicacion: form.value.aplicacion || undefined
            });
            toast.exito('Producto creado correctamente.');
            router.push(`/catalogos/productos/${id}`);
            return;
        }
        router.push('/catalogos/productos');
    }
    catch {
        toast.error('Error al guardar el producto.');
    }
    finally {
        guardando.value = false;
    }
}
onMounted(() => { cargarCatalogos(); cargarProducto(); });
debugger; /* PartiallyEnd: #3632/scriptSetup.vue */
const __VLS_ctx = {};
let __VLS_components;
let __VLS_directives;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
// CSS variable injection 
// CSS variable injection end 
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "page" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "page-header" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.h2, __VLS_intrinsicElements.h2)({
    ...{ class: "page-title" },
});
(__VLS_ctx.esEdicion ? 'Editar producto' : 'Nuevo producto');
const __VLS_0 = {}.RouterLink;
/** @type {[typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, ]} */ ;
// @ts-ignore
const __VLS_1 = __VLS_asFunctionalComponent(__VLS_0, new __VLS_0({
    to: "/catalogos/productos",
    ...{ class: "btn btn-ghost" },
}));
const __VLS_2 = __VLS_1({
    to: "/catalogos/productos",
    ...{ class: "btn btn-ghost" },
}, ...__VLS_functionalComponentArgsRest(__VLS_1));
__VLS_3.slots.default;
var __VLS_3;
__VLS_asFunctionalElement(__VLS_intrinsicElements.form, __VLS_intrinsicElements.form)({
    ...{ onSubmit: (__VLS_ctx.guardar) },
    ...{ class: "form-card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "form-grid" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "required" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    value: (__VLS_ctx.form.nombre),
    type: "text",
    ...{ class: "input" },
    required: true,
    placeholder: "Nombre del producto",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    value: (__VLS_ctx.form.descripcion),
    type: "text",
    ...{ class: "input" },
    placeholder: "Descripción opcional",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
    value: (__VLS_ctx.form.fkCategoria),
    ...{ class: "input" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (undefined),
});
for (const [c] of __VLS_getVForSourceType((__VLS_ctx.categorias))) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        key: (c.codigo),
        value: (c.codigo),
    });
    (c.descripcion);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
    value: (__VLS_ctx.form.fkMarca),
    ...{ class: "input" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (undefined),
});
for (const [m] of __VLS_getVForSourceType((__VLS_ctx.marcas))) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        key: (m.codigo),
        value: (m.codigo),
    });
    (m.nombre);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
    value: (__VLS_ctx.form.fkMedida),
    ...{ class: "input" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (undefined),
});
for (const [m] of __VLS_getVForSourceType((__VLS_ctx.medidas))) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        key: (m.codigo),
        value: (m.codigo),
    });
    (m.descripcion);
    (m.codigo);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    type: "number",
    step: "0.01",
    min: "0",
    ...{ class: "input" },
    placeholder: "1.00",
});
(__VLS_ctx.form.cantidadMedida);
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    type: "number",
    step: "0.01",
    min: "0",
    ...{ class: "input" },
    placeholder: "0",
});
(__VLS_ctx.form.stockMinimo);
if (!__VLS_ctx.esEdicion) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "field" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
        ...{ class: "label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
        type: "number",
        step: "0.01",
        min: "0",
        ...{ class: "input" },
        placeholder: "0.00",
    });
    (__VLS_ctx.form.precioVenta);
}
if (!__VLS_ctx.esEdicion) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "field" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
        ...{ class: "label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
        value: (__VLS_ctx.form.aplicacion),
        ...{ class: "input" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "VENTA",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "COMPRA",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "AMBOS",
    });
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "form-actions" },
});
const __VLS_4 = {}.RouterLink;
/** @type {[typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, ]} */ ;
// @ts-ignore
const __VLS_5 = __VLS_asFunctionalComponent(__VLS_4, new __VLS_4({
    to: "/catalogos/productos",
    ...{ class: "btn btn-ghost" },
}));
const __VLS_6 = __VLS_5({
    to: "/catalogos/productos",
    ...{ class: "btn btn-ghost" },
}, ...__VLS_functionalComponentArgsRest(__VLS_5));
__VLS_7.slots.default;
var __VLS_7;
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    type: "submit",
    ...{ class: "btn btn-primary" },
    disabled: (__VLS_ctx.guardando),
});
(__VLS_ctx.guardando ? 'Guardando...' : (__VLS_ctx.esEdicion ? 'Actualizar' : 'Crear producto'));
/** @type {__VLS_StyleScopedClasses['page']} */ ;
/** @type {__VLS_StyleScopedClasses['page-header']} */ ;
/** @type {__VLS_StyleScopedClasses['page-title']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['form-card']} */ ;
/** @type {__VLS_StyleScopedClasses['form-grid']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['required']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['form-actions']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
var __VLS_dollars;
const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            RouterLink: RouterLink,
            esEdicion: esEdicion,
            guardando: guardando,
            categorias: categorias,
            marcas: marcas,
            medidas: medidas,
            form: form,
            guardar: guardar,
        };
    },
});
export default (await import('vue')).defineComponent({
    setup() {
        return {};
    },
});
; /* PartiallyEnd: #4569/main.vue */
