/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />
import { ref, computed, onMounted } from 'vue';
import { useRouter, RouterLink } from 'vue-router';
import { inventarioService } from '@/services/inventario.service';
import { productoService } from '@/services/producto.service';
import { useToast } from '@/composables/useToast';
const router = useRouter();
const toast = useToast();
const busquedaProducto = ref('');
const filtroCategoria = ref('');
const productos = ref([]);
const paginadoProductos = ref(null);
const paginaProductos = ref(1);
const categorias = ref([]);
const cargandoProductos = ref(false);
const seleccionado = ref(null);
const cantidadTexto = ref('');
const errorCantidad = ref('');
const motivo = ref('');
const otroMotivo = ref('');
const guardando = ref(false);
const mostrarConfirmacion = ref(false);
let timeoutBusqueda = null;
const cantidadNumerica = computed(() => {
    const v = parseFloat(cantidadTexto.value.replace(/,/g, ''));
    return isNaN(v) ? 0 : v;
});
const cantidadValida = computed(() => {
    return cantidadNumerica.value !== 0 && !errorCantidad.value;
});
const motivoFinal = computed(() => motivo.value === 'Otro' ? otroMotivo.value : motivo.value);
const puedeGuardar = computed(() => {
    return seleccionado.value && cantidadValida.value && motivoFinal.value;
});
function validarCantidad() {
    const v = parseFloat(cantidadTexto.value.replace(/,/g, ''));
    if (isNaN(v) || cantidadTexto.value === '') {
        errorCantidad.value = '';
        return;
    }
    if (v === 0) {
        errorCantidad.value = 'La cantidad no puede ser cero.';
        return;
    }
    errorCantidad.value = '';
}
function incrementarCantidad() {
    const actual = cantidadNumerica.value;
    const paso = actual >= 0 ? 1 : -1;
    cantidadTexto.value = String(actual + paso);
    validarCantidad();
}
function decrementarCantidad() {
    const actual = cantidadNumerica.value;
    if (actual === 0)
        return;
    const paso = actual > 0 ? -1 : 1;
    cantidadTexto.value = String(actual + paso);
    validarCantidad();
}
async function cargarCatalogos() {
    try {
        categorias.value = await productoService.listarCategorias();
    }
    catch { }
}
async function buscar() {
    cargandoProductos.value = true;
    try {
        const resp = await productoService.listar({
            busqueda: busquedaProducto.value || undefined,
            categoria: filtroCategoria.value ? Number(filtroCategoria.value) : undefined,
            estado: 'A',
            pagina: paginaProductos.value,
            tamano: 10
        });
        productos.value = resp.data;
        paginadoProductos.value = resp;
    }
    catch {
        productos.value = [];
        toast.error('Error al buscar productos.');
    }
    finally {
        cargandoProductos.value = false;
    }
}
function buscarConDebounce() {
    if (timeoutBusqueda)
        clearTimeout(timeoutBusqueda);
    paginaProductos.value = 1;
    timeoutBusqueda = setTimeout(buscar, 300);
}
function irPagina(n) {
    paginaProductos.value = n;
    buscar();
}
function seleccionarProducto(p) {
    seleccionado.value = p;
    busquedaProducto.value = '';
    filtroCategoria.value = '';
    productos.value = [];
    cantidadTexto.value = '';
    errorCantidad.value = '';
    motivo.value = '';
}
function quitarSeleccion() {
    seleccionado.value = null;
    cantidadTexto.value = '';
    errorCantidad.value = '';
    motivo.value = '';
    paginaProductos.value = 1;
    buscar();
}
function confirmarAjuste() {
    if (!puedeGuardar.value)
        return;
    mostrarConfirmacion.value = true;
}
async function ejecutarAjuste() {
    if (!seleccionado.value)
        return;
    try {
        guardando.value = true;
        await inventarioService.ajustar({
            fkProducto: seleccionado.value.codigo,
            cantidad: cantidadNumerica.value,
            motivo: motivoFinal.value
        });
        toast.exito(`Stock ajustado. Nuevo stock de "${seleccionado.value.nombre}": ${formatNum(seleccionado.value.stockActual + cantidadNumerica.value)}`);
        router.push('/inventario');
    }
    catch {
        toast.error('Error al ajustar el stock. Verifique los datos e intente de nuevo.');
    }
    finally {
        guardando.value = false;
        mostrarConfirmacion.value = false;
    }
}
function formatNum(n) { return Number(n ?? 0).toFixed(2); }
onMounted(() => { cargarCatalogos(); buscar(); });
debugger; /* PartiallyEnd: #3632/scriptSetup.vue */
const __VLS_ctx = {};
let __VLS_components;
let __VLS_directives;
/** @type {__VLS_StyleScopedClasses['form-section']} */ ;
/** @type {__VLS_StyleScopedClasses['row-clickeable']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-quitar']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['input-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['input-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['input-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary-outline']} */ ;
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
const __VLS_0 = {}.RouterLink;
/** @type {[typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, ]} */ ;
// @ts-ignore
const __VLS_1 = __VLS_asFunctionalComponent(__VLS_0, new __VLS_0({
    to: "/inventario",
    ...{ class: "btn btn-ghost" },
}));
const __VLS_2 = __VLS_1({
    to: "/inventario",
    ...{ class: "btn btn-ghost" },
}, ...__VLS_functionalComponentArgsRest(__VLS_1));
__VLS_3.slots.default;
var __VLS_3;
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "form-card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "form-section" },
});
if (!__VLS_ctx.seleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.h3, __VLS_intrinsicElements.h3)({
        ...{ class: "section-title" },
    });
}
else {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.h3, __VLS_intrinsicElements.h3)({
        ...{ class: "section-title" },
    });
}
if (!__VLS_ctx.seleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "explorador-filtros" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
        ...{ onInput: (__VLS_ctx.buscarConDebounce) },
        value: (__VLS_ctx.busquedaProducto),
        type: "text",
        ...{ class: "input filtro-busqueda" },
        placeholder: "Buscar por nombre o código...",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
        ...{ onChange: (__VLS_ctx.buscar) },
        value: (__VLS_ctx.filtroCategoria),
        ...{ class: "input filtro-select" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "",
    });
    for (const [c] of __VLS_getVForSourceType((__VLS_ctx.categorias))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
            key: (c.codigo),
            value: (c.codigo),
        });
        (c.descripcion);
    }
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "explorador-contador" },
    });
    (__VLS_ctx.paginadoProductos?.total ?? 0);
    if (__VLS_ctx.cargandoProductos) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "explorador-vacio" },
        });
    }
    else if (!__VLS_ctx.productos.length) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "explorador-vacio" },
        });
    }
    else {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "explorador-tabla" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.table, __VLS_intrinsicElements.table)({
            ...{ class: "data-table" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.thead, __VLS_intrinsicElements.thead)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.tr, __VLS_intrinsicElements.tr)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.tbody, __VLS_intrinsicElements.tbody)({});
        for (const [p] of __VLS_getVForSourceType((__VLS_ctx.productos))) {
            __VLS_asFunctionalElement(__VLS_intrinsicElements.tr, __VLS_intrinsicElements.tr)({
                ...{ onClick: (...[$event]) => {
                        if (!(!__VLS_ctx.seleccionado))
                            return;
                        if (!!(__VLS_ctx.cargandoProductos))
                            return;
                        if (!!(!__VLS_ctx.productos.length))
                            return;
                        __VLS_ctx.seleccionarProducto(p);
                    } },
                key: (p.codigo),
                ...{ class: "row-clickeable" },
            });
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-id" },
            });
            (p.codigo);
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
            __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
                ...{ class: "cell-main" },
            });
            (p.nombre);
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-sec" },
            });
            (p.marca || '—');
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-sec" },
            });
            (p.medida || '—');
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-sec" },
            });
            (p.categoria || '—');
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-monto" },
            });
            (__VLS_ctx.formatNum(p.stockActual));
            __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
                ...{ class: "td-actions" },
            });
            __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
                ...{ onClick: (...[$event]) => {
                        if (!(!__VLS_ctx.seleccionado))
                            return;
                        if (!!(__VLS_ctx.cargandoProductos))
                            return;
                        if (!!(!__VLS_ctx.productos.length))
                            return;
                        __VLS_ctx.seleccionarProducto(p);
                    } },
                type: "button",
                ...{ class: "btn btn-xs btn-primary-outline" },
            });
        }
    }
    if (__VLS_ctx.paginadoProductos && __VLS_ctx.paginadoProductos.totalPaginas > 1) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "explorador-paginacion" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
            ...{ onClick: (...[$event]) => {
                    if (!(!__VLS_ctx.seleccionado))
                        return;
                    if (!(__VLS_ctx.paginadoProductos && __VLS_ctx.paginadoProductos.totalPaginas > 1))
                        return;
                    __VLS_ctx.irPagina(__VLS_ctx.paginaProductos - 1);
                } },
            ...{ class: "btn btn-ghost btn-xs" },
            disabled: (__VLS_ctx.paginaProductos <= 1),
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "pag-info" },
        });
        (__VLS_ctx.paginaProductos);
        (__VLS_ctx.paginadoProductos.totalPaginas);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
            ...{ onClick: (...[$event]) => {
                    if (!(!__VLS_ctx.seleccionado))
                        return;
                    if (!(__VLS_ctx.paginadoProductos && __VLS_ctx.paginadoProductos.totalPaginas > 1))
                        return;
                    __VLS_ctx.irPagina(__VLS_ctx.paginaProductos + 1);
                } },
            ...{ class: "btn btn-ghost btn-xs" },
            disabled: (__VLS_ctx.paginaProductos >= __VLS_ctx.paginadoProductos.totalPaginas),
        });
    }
}
if (__VLS_ctx.seleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "producto-seleccionado" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "ps-header" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "ps-info" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.strong, __VLS_intrinsicElements.strong)({
        ...{ class: "ps-nombre" },
    });
    (__VLS_ctx.seleccionado.nombre);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "ps-detalle" },
    });
    if (__VLS_ctx.seleccionado.marca || __VLS_ctx.seleccionado.medida) {
        (__VLS_ctx.seleccionado.marca || '');
        (__VLS_ctx.seleccionado.marca && __VLS_ctx.seleccionado.medida ? ' — ' : '');
        (__VLS_ctx.seleccionado.medida || '');
    }
    else {
        (__VLS_ctx.seleccionado.codigo);
    }
    if (__VLS_ctx.seleccionado.categoria) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "ps-categoria" },
        });
        (__VLS_ctx.seleccionado.categoria);
    }
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "ps-stock" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "ps-stock-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "ps-stock-num" },
    });
    (__VLS_ctx.formatNum(__VLS_ctx.seleccionado.stockActual));
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.quitarSeleccion) },
        type: "button",
        ...{ class: "ps-quitar" },
        title: "Cambiar producto",
    });
}
if (__VLS_ctx.seleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "form-section" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.h3, __VLS_intrinsicElements.h3)({
        ...{ class: "section-title" },
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
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "cantidad-control" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.decrementarCantidad) },
        type: "button",
        ...{ class: "btn-cantidad" },
        disabled: (!__VLS_ctx.cantidadNumerica),
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
        ...{ onInput: (__VLS_ctx.validarCantidad) },
        value: (__VLS_ctx.cantidadTexto),
        type: "text",
        ...{ class: "input input-monto" },
        placeholder: "0",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.incrementarCantidad) },
        type: "button",
        ...{ class: "btn-cantidad" },
    });
    if (__VLS_ctx.errorCantidad) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "field-error" },
        });
        (__VLS_ctx.errorCantidad);
    }
    if (__VLS_ctx.cantidadValida && __VLS_ctx.seleccionado) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "field-preview" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "preview-tipo" },
            ...{ class: (__VLS_ctx.cantidadNumerica > 0 ? 'text-entrada' : 'text-salida') },
        });
        (__VLS_ctx.cantidadNumerica > 0 ? 'Entrada' : 'Salida');
        __VLS_asFunctionalElement(__VLS_intrinsicElements.strong, __VLS_intrinsicElements.strong)({});
        (__VLS_ctx.formatNum(Math.abs(__VLS_ctx.cantidadNumerica)));
        __VLS_asFunctionalElement(__VLS_intrinsicElements.strong, __VLS_intrinsicElements.strong)({
            ...{ class: "text-primary" },
        });
        (__VLS_ctx.formatNum(__VLS_ctx.seleccionado.stockActual + __VLS_ctx.cantidadNumerica));
    }
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "field" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
        ...{ class: "label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "required" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
        value: (__VLS_ctx.motivo),
        ...{ class: "input" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Ajuste por conteo físico",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Merma / deterioro",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Producto dañado",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Donación",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Devolución",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Corrección de inventario",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "Otro",
    });
    if (__VLS_ctx.motivo === 'Otro') {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
            value: (__VLS_ctx.otroMotivo),
            type: "text",
            ...{ class: "input" },
            placeholder: "Describa el motivo...",
        });
    }
}
if (__VLS_ctx.seleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "form-footer" },
    });
    const __VLS_4 = {}.RouterLink;
    /** @type {[typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, ]} */ ;
    // @ts-ignore
    const __VLS_5 = __VLS_asFunctionalComponent(__VLS_4, new __VLS_4({
        to: "/inventario",
        ...{ class: "btn btn-ghost" },
    }));
    const __VLS_6 = __VLS_5({
        to: "/inventario",
        ...{ class: "btn btn-ghost" },
    }, ...__VLS_functionalComponentArgsRest(__VLS_5));
    __VLS_7.slots.default;
    var __VLS_7;
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.confirmarAjuste) },
        ...{ class: "btn btn-primary" },
        disabled: (!__VLS_ctx.puedeGuardar),
    });
    (__VLS_ctx.guardando ? 'Ajustando...' : 'Ajustar stock');
}
if (__VLS_ctx.mostrarConfirmacion) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ onClick: (...[$event]) => {
                if (!(__VLS_ctx.mostrarConfirmacion))
                    return;
                __VLS_ctx.mostrarConfirmacion = false;
            } },
        ...{ class: "modal-overlay" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "modal" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.h3, __VLS_intrinsicElements.h3)({
        ...{ class: "modal-title" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "modal-body" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "conf-item" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-value" },
    });
    (__VLS_ctx.seleccionado?.nombre);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "conf-item" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-value" },
    });
    (__VLS_ctx.formatNum(__VLS_ctx.seleccionado?.stockActual ?? 0));
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "conf-item" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-value" },
        ...{ class: (__VLS_ctx.cantidadNumerica > 0 ? 'text-entrada' : 'text-salida') },
    });
    (__VLS_ctx.cantidadNumerica > 0 ? '+' : '');
    (__VLS_ctx.formatNum(__VLS_ctx.cantidadNumerica));
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "conf-item conf-item--total" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-value text-primary" },
    });
    (__VLS_ctx.formatNum((__VLS_ctx.seleccionado?.stockActual ?? 0) + __VLS_ctx.cantidadNumerica));
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "conf-item" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-label" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "conf-value" },
    });
    (__VLS_ctx.motivoFinal);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "modal-footer" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (...[$event]) => {
                if (!(__VLS_ctx.mostrarConfirmacion))
                    return;
                __VLS_ctx.mostrarConfirmacion = false;
            } },
        ...{ class: "btn btn-ghost" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.ejecutarAjuste) },
        ...{ class: "btn btn-primary" },
        disabled: (__VLS_ctx.guardando),
    });
    (__VLS_ctx.guardando ? 'Ajustando...' : 'Confirmar y ajustar');
}
/** @type {__VLS_StyleScopedClasses['page']} */ ;
/** @type {__VLS_StyleScopedClasses['page-header']} */ ;
/** @type {__VLS_StyleScopedClasses['page-title']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['form-card']} */ ;
/** @type {__VLS_StyleScopedClasses['form-section']} */ ;
/** @type {__VLS_StyleScopedClasses['section-title']} */ ;
/** @type {__VLS_StyleScopedClasses['section-title']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-filtros']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-busqueda']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-select']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-contador']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-vacio']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-vacio']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-tabla']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['row-clickeable']} */ ;
/** @type {__VLS_StyleScopedClasses['td-id']} */ ;
/** @type {__VLS_StyleScopedClasses['cell-main']} */ ;
/** @type {__VLS_StyleScopedClasses['td-sec']} */ ;
/** @type {__VLS_StyleScopedClasses['td-sec']} */ ;
/** @type {__VLS_StyleScopedClasses['td-sec']} */ ;
/** @type {__VLS_StyleScopedClasses['td-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['td-actions']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-xs']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary-outline']} */ ;
/** @type {__VLS_StyleScopedClasses['explorador-paginacion']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-xs']} */ ;
/** @type {__VLS_StyleScopedClasses['pag-info']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-xs']} */ ;
/** @type {__VLS_StyleScopedClasses['producto-seleccionado']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-header']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-info']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-nombre']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-detalle']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-categoria']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-stock']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-stock-label']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-stock-num']} */ ;
/** @type {__VLS_StyleScopedClasses['ps-quitar']} */ ;
/** @type {__VLS_StyleScopedClasses['form-section']} */ ;
/** @type {__VLS_StyleScopedClasses['section-title']} */ ;
/** @type {__VLS_StyleScopedClasses['form-grid']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['required']} */ ;
/** @type {__VLS_StyleScopedClasses['cantidad-control']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['input-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-cantidad']} */ ;
/** @type {__VLS_StyleScopedClasses['field-error']} */ ;
/** @type {__VLS_StyleScopedClasses['field-preview']} */ ;
/** @type {__VLS_StyleScopedClasses['preview-tipo']} */ ;
/** @type {__VLS_StyleScopedClasses['text-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['required']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['input']} */ ;
/** @type {__VLS_StyleScopedClasses['form-footer']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['modal-overlay']} */ ;
/** @type {__VLS_StyleScopedClasses['modal']} */ ;
/** @type {__VLS_StyleScopedClasses['modal-title']} */ ;
/** @type {__VLS_StyleScopedClasses['modal-body']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-label']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-value']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-label']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-value']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-label']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-value']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item--total']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-label']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-value']} */ ;
/** @type {__VLS_StyleScopedClasses['text-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-item']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-label']} */ ;
/** @type {__VLS_StyleScopedClasses['conf-value']} */ ;
/** @type {__VLS_StyleScopedClasses['modal-footer']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
var __VLS_dollars;
const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            RouterLink: RouterLink,
            busquedaProducto: busquedaProducto,
            filtroCategoria: filtroCategoria,
            productos: productos,
            paginadoProductos: paginadoProductos,
            paginaProductos: paginaProductos,
            categorias: categorias,
            cargandoProductos: cargandoProductos,
            seleccionado: seleccionado,
            cantidadTexto: cantidadTexto,
            errorCantidad: errorCantidad,
            motivo: motivo,
            otroMotivo: otroMotivo,
            guardando: guardando,
            mostrarConfirmacion: mostrarConfirmacion,
            cantidadNumerica: cantidadNumerica,
            cantidadValida: cantidadValida,
            motivoFinal: motivoFinal,
            puedeGuardar: puedeGuardar,
            validarCantidad: validarCantidad,
            incrementarCantidad: incrementarCantidad,
            decrementarCantidad: decrementarCantidad,
            buscar: buscar,
            buscarConDebounce: buscarConDebounce,
            irPagina: irPagina,
            seleccionarProducto: seleccionarProducto,
            quitarSeleccion: quitarSeleccion,
            confirmarAjuste: confirmarAjuste,
            ejecutarAjuste: ejecutarAjuste,
            formatNum: formatNum,
        };
    },
});
export default (await import('vue')).defineComponent({
    setup() {
        return {};
    },
});
; /* PartiallyEnd: #4569/main.vue */
