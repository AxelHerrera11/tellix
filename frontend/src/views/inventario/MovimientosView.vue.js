/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { inventarioService } from '@/services/inventario.service';
import { productoService } from '@/services/producto.service';
const movimientos = ref([]);
const paginado = ref(null);
const cargando = ref(false);
const error = ref('');
const pagina = ref(1);
const busquedaProducto = ref('');
const sugerencias = ref([]);
const mostrarSugerencias = ref(false);
const filtroProductoId = ref(undefined);
const filtroProductoNombre = ref('');
const filtroOperacion = ref('');
const filtroDesde = ref('');
const filtroHasta = ref('');
let timeoutBusqueda = null;
function ocultarSugerencias() { setTimeout(() => mostrarSugerencias.value = false, 200); }
async function buscarProductos() {
    if (timeoutBusqueda)
        clearTimeout(timeoutBusqueda);
    if (busquedaProducto.value.length < 2) {
        sugerencias.value = [];
        return;
    }
    timeoutBusqueda = setTimeout(async () => {
        try {
            const resp = await productoService.listar({ busqueda: busquedaProducto.value, estado: 'A', tamano: 8 });
            sugerencias.value = resp.data;
        }
        catch {
            sugerencias.value = [];
        }
    }, 300);
}
function seleccionarProducto(p) {
    filtroProductoId.value = p.codigo;
    filtroProductoNombre.value = p.nombre;
    busquedaProducto.value = '';
    sugerencias.value = [];
    mostrarSugerencias.value = false;
    buscar();
}
function quitarProducto() {
    filtroProductoId.value = undefined;
    filtroProductoNombre.value = '';
    busquedaProducto.value = '';
    buscar();
}
async function cargar() {
    try {
        cargando.value = true;
        error.value = '';
        const resp = await inventarioService.listarMovimientos({
            producto: filtroProductoId.value,
            operacion: filtroOperacion.value || undefined,
            desde: filtroDesde.value || undefined,
            hasta: filtroHasta.value || undefined,
            pagina: pagina.value,
            tamano: 20
        });
        movimientos.value = resp.data;
        paginado.value = resp;
    }
    catch {
        error.value = 'Error al cargar los movimientos. Intente de nuevo.';
    }
    finally {
        cargando.value = false;
    }
}
function buscar() { pagina.value = 1; cargar(); }
function limpiar() {
    filtroProductoId.value = undefined;
    filtroProductoNombre.value = '';
    busquedaProducto.value = '';
    filtroOperacion.value = '';
    filtroDesde.value = '';
    filtroHasta.value = '';
    pagina.value = 1;
    cargar();
}
function irPagina(n) { pagina.value = n; cargar(); }
function formatFecha(f) { return f ? new Date(f).toLocaleDateString('es-GT', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—'; }
function formatNum(n) { return Number(n ?? 0).toFixed(2); }
onMounted(cargar);
debugger; /* PartiallyEnd: #3632/scriptSetup.vue */
const __VLS_ctx = {};
let __VLS_components;
let __VLS_directives;
/** @type {__VLS_StyleScopedClasses['filtro-quitar']} */ ;
/** @type {__VLS_StyleScopedClasses['sugerencia-item']} */ ;
/** @type {__VLS_StyleScopedClasses['sugerencia-item']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-secondary']} */ ;
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
    ...{ class: "filters-bar" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "filtro-producto" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    ...{ onInput: (__VLS_ctx.buscarProductos) },
    ...{ onFocus: (...[$event]) => {
            __VLS_ctx.mostrarSugerencias = true;
        } },
    ...{ onBlur: (__VLS_ctx.ocultarSugerencias) },
    value: (__VLS_ctx.busquedaProducto),
    type: "text",
    ...{ class: "filter-input" },
    placeholder: "Filtrar por producto...",
});
if (__VLS_ctx.mostrarSugerencias && __VLS_ctx.sugerencias.length) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "sugerencias" },
    });
    for (const [p] of __VLS_getVForSourceType((__VLS_ctx.sugerencias))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
            ...{ onClick: (...[$event]) => {
                    if (!(__VLS_ctx.mostrarSugerencias && __VLS_ctx.sugerencias.length))
                        return;
                    __VLS_ctx.seleccionarProducto(p);
                } },
            key: (p.codigo),
            type: "button",
            ...{ class: "sugerencia-item" },
            ...{ class: ({ activo: __VLS_ctx.filtroProductoId === p.codigo }) },
        });
        (p.nombre);
    }
}
if (__VLS_ctx.filtroProductoNombre) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "filtro-activo" },
    });
    (__VLS_ctx.filtroProductoNombre);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (__VLS_ctx.quitarProducto) },
        ...{ class: "filtro-quitar" },
    });
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
    value: (__VLS_ctx.filtroOperacion),
    ...{ class: "filter-select" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: "",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: "ENTRADA",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: "SALIDA",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: "AJUSTE",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: "DEVOLUCION",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "filtro-fechas" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "fecha-label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    type: "date",
    ...{ class: "filter-input filter-date" },
});
(__VLS_ctx.filtroDesde);
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "fecha-label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    type: "date",
    ...{ class: "filter-input filter-date" },
});
(__VLS_ctx.filtroHasta);
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    ...{ onClick: (__VLS_ctx.buscar) },
    ...{ class: "btn btn-secondary" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    ...{ onClick: (__VLS_ctx.limpiar) },
    ...{ class: "btn btn-ghost" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "table-card" },
});
if (__VLS_ctx.cargando) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "table-empty" },
    });
}
else if (__VLS_ctx.error) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "table-empty table-error" },
    });
    (__VLS_ctx.error);
}
else if (!__VLS_ctx.movimientos.length) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "table-empty" },
    });
    if (__VLS_ctx.filtroProductoNombre) {
        (__VLS_ctx.filtroProductoNombre);
    }
}
else {
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
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.tbody, __VLS_intrinsicElements.tbody)({});
    for (const [m] of __VLS_getVForSourceType((__VLS_ctx.movimientos))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.tr, __VLS_intrinsicElements.tr)({
            key: (m.id),
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-id" },
        });
        (m.id);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-fecha" },
        });
        (__VLS_ctx.formatFecha(m.fechaOperacion));
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ class: "cell-main" },
        });
        (m.producto);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-monto" },
            ...{ class: (m.cantidad > 0 ? 'td-pos' : 'td-neg') },
        });
        (m.cantidad > 0 ? '+' : '');
        (__VLS_ctx.formatNum(m.cantidad));
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "badge" },
            ...{ class: (`badge--${m.tipoMovimiento.toLowerCase()}`) },
        });
        (m.tipoMovimiento);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
        (m.operacion);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-motivo" },
        });
        (m.motivo || m.tipoDocumento || '—');
        (m.noDocumento ? ' #' + m.noDocumento : '');
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-usuario" },
        });
        (m.usuario || '—');
    }
}
if (__VLS_ctx.paginado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "pagination" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (...[$event]) => {
                if (!(__VLS_ctx.paginado))
                    return;
                __VLS_ctx.irPagina(__VLS_ctx.pagina - 1);
            } },
        ...{ class: "btn btn-ghost btn-sm" },
        disabled: (__VLS_ctx.pagina === 1),
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "pagination-info" },
    });
    (__VLS_ctx.pagina);
    (__VLS_ctx.paginado.totalPaginas);
    (__VLS_ctx.paginado.total);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
        ...{ onClick: (...[$event]) => {
                if (!(__VLS_ctx.paginado))
                    return;
                __VLS_ctx.irPagina(__VLS_ctx.pagina + 1);
            } },
        ...{ class: "btn btn-ghost btn-sm" },
        disabled: (__VLS_ctx.pagina >= __VLS_ctx.paginado.totalPaginas),
    });
}
/** @type {__VLS_StyleScopedClasses['page']} */ ;
/** @type {__VLS_StyleScopedClasses['page-header']} */ ;
/** @type {__VLS_StyleScopedClasses['page-title']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['filters-bar']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-producto']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-input']} */ ;
/** @type {__VLS_StyleScopedClasses['sugerencias']} */ ;
/** @type {__VLS_StyleScopedClasses['sugerencia-item']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-activo']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-quitar']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-select']} */ ;
/** @type {__VLS_StyleScopedClasses['filtro-fechas']} */ ;
/** @type {__VLS_StyleScopedClasses['fecha-label']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-input']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-date']} */ ;
/** @type {__VLS_StyleScopedClasses['fecha-label']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-input']} */ ;
/** @type {__VLS_StyleScopedClasses['filter-date']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-secondary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['table-card']} */ ;
/** @type {__VLS_StyleScopedClasses['table-empty']} */ ;
/** @type {__VLS_StyleScopedClasses['table-empty']} */ ;
/** @type {__VLS_StyleScopedClasses['table-error']} */ ;
/** @type {__VLS_StyleScopedClasses['table-empty']} */ ;
/** @type {__VLS_StyleScopedClasses['data-table']} */ ;
/** @type {__VLS_StyleScopedClasses['td-id']} */ ;
/** @type {__VLS_StyleScopedClasses['td-fecha']} */ ;
/** @type {__VLS_StyleScopedClasses['cell-main']} */ ;
/** @type {__VLS_StyleScopedClasses['td-monto']} */ ;
/** @type {__VLS_StyleScopedClasses['badge']} */ ;
/** @type {__VLS_StyleScopedClasses['td-motivo']} */ ;
/** @type {__VLS_StyleScopedClasses['td-usuario']} */ ;
/** @type {__VLS_StyleScopedClasses['pagination']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-sm']} */ ;
/** @type {__VLS_StyleScopedClasses['pagination-info']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-sm']} */ ;
var __VLS_dollars;
const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            RouterLink: RouterLink,
            movimientos: movimientos,
            paginado: paginado,
            cargando: cargando,
            error: error,
            pagina: pagina,
            busquedaProducto: busquedaProducto,
            sugerencias: sugerencias,
            mostrarSugerencias: mostrarSugerencias,
            filtroProductoId: filtroProductoId,
            filtroProductoNombre: filtroProductoNombre,
            filtroOperacion: filtroOperacion,
            filtroDesde: filtroDesde,
            filtroHasta: filtroHasta,
            ocultarSugerencias: ocultarSugerencias,
            buscarProductos: buscarProductos,
            seleccionarProducto: seleccionarProducto,
            quitarProducto: quitarProducto,
            buscar: buscar,
            limpiar: limpiar,
            irPagina: irPagina,
            formatFecha: formatFecha,
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
