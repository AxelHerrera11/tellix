/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />
import { ref, computed, watch } from 'vue';
import { RouterLink, useRouter } from 'vue-router';
import { ventaService } from '@/services/venta.service';
import { useToast } from '@/composables/useToast';
const router = useRouter();
const toast = useToast();
const clienteBusqueda = ref('');
const clientesResultados = ref([]);
const clienteSeleccionado = ref(null);
const productoBusqueda = ref('');
const productosResultados = ref([]);
const carrito = ref([]);
const guardando = ref(false);
const errorMsg = ref('');
const form = ref({
    fkMetodoPago: 1,
    plazoCredito: 0,
    tipoPlazo: 'DIAS'
});
// ── Totales reactivos ─────────────────────────────────────────
const totales = computed(() => {
    const subtotal = carrito.value.reduce((s, i) => s + i.cantidad * i.precioUnitario, 0);
    const descuentos = carrito.value.reduce((s, i) => s + i.descuentos, 0);
    const impuestos = carrito.value.reduce((s, i) => s + i.impuestos, 0);
    return { subtotal, descuentos, impuestos, total: subtotal - descuentos + impuestos };
});
const puedeRegistrar = computed(() => !!clienteSeleccionado.value && carrito.value.length > 0);
// ── Plazo a 0 si no es crédito ────────────────────────────────
watch(() => form.value.fkMetodoPago, v => {
    if (v !== 2)
        form.value.plazoCredito = 0;
});
// ── Búsquedas ─────────────────────────────────────────────────
let clienteTimer;
async function buscarClientes() {
    clearTimeout(clienteTimer);
    if (!clienteBusqueda.value || clienteBusqueda.value.length < 2) {
        clientesResultados.value = [];
        return;
    }
    clienteTimer = setTimeout(async () => {
        clientesResultados.value = await ventaService.buscarClientes(clienteBusqueda.value);
    }, 300);
}
let productoTimer;
async function buscarProductos() {
    clearTimeout(productoTimer);
    if (!productoBusqueda.value || productoBusqueda.value.length < 2) {
        productosResultados.value = [];
        return;
    }
    productoTimer = setTimeout(async () => {
        productosResultados.value = await ventaService.buscarProductos(productoBusqueda.value);
    }, 300);
}
// ── Carrito ───────────────────────────────────────────────────
function seleccionarCliente(c) {
    clienteSeleccionado.value = c;
    clientesResultados.value = [];
    clienteBusqueda.value = c.nombre;
}
function agregarProducto(p) {
    const existente = carrito.value.find(i => i.fkProducto === p.codigo);
    if (existente) {
        existente.cantidad++;
        recalcularItem(existente);
    }
    else {
        carrito.value.push({
            fkProducto: p.codigo,
            nombre: p.nombre,
            cantidad: 1,
            precioUnitario: p.precioVenta ?? 0,
            descuentos: 0,
            impuestos: 0,
            subtotal: p.precioVenta ?? 0,
            stockActual: p.stockActual
        });
    }
    productoBusqueda.value = '';
    productosResultados.value = [];
}
function quitarProducto(i) {
    carrito.value.splice(i, 1);
}
function recalcularItem(item) {
    item.subtotal = (item.cantidad * item.precioUnitario) - item.descuentos + item.impuestos;
}
function recalcular() {
    carrito.value.forEach(recalcularItem);
}
// ── Registrar ─────────────────────────────────────────────────
async function registrar() {
    errorMsg.value = '';
    if (!clienteSeleccionado.value) {
        errorMsg.value = 'Seleccione un cliente.';
        return;
    }
    if (!carrito.value.length) {
        errorMsg.value = 'Agregue al menos un producto.';
        return;
    }
    const stockInvalido = carrito.value.find(i => i.cantidad > i.stockActual);
    if (stockInvalido) {
        errorMsg.value = `Stock insuficiente para "${stockInvalido.nombre}".`;
        return;
    }
    try {
        guardando.value = true;
        const id = await ventaService.registrar({
            fkCliente: clienteSeleccionado.value.nit,
            fkMetodoPago: form.value.fkMetodoPago,
            plazoCredito: form.value.plazoCredito,
            tipoPlazo: form.value.tipoPlazo,
            items: carrito.value.map(i => ({
                fkProducto: i.fkProducto,
                cantidad: i.cantidad,
                precioUnitario: i.precioUnitario,
                descuentos: i.descuentos,
                impuestos: i.impuestos
            }))
        });
        toast.exito(`Venta #${id} registrada correctamente.`);
        router.push(`/ventas/${id}`);
    }
    catch (err) {
        errorMsg.value = err.response?.data?.mensaje ?? 'Error al registrar la venta.';
    }
    finally {
        guardando.value = false;
    }
}
function formatNum(n) {
    return Number(n ?? 0).toFixed(2);
}
debugger; /* PartiallyEnd: #3632/scriptSetup.vue */
const __VLS_ctx = {};
let __VLS_components;
let __VLS_directives;
/** @type {__VLS_StyleScopedClasses['back-link']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['search-row']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown-item']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown-item']} */ ;
/** @type {__VLS_StyleScopedClasses['cart-table']} */ ;
/** @type {__VLS_StyleScopedClasses['cart-table']} */ ;
/** @type {__VLS_StyleScopedClasses['cart-table']} */ ;
/** @type {__VLS_StyleScopedClasses['remove-btn']} */ ;
/** @type {__VLS_StyleScopedClasses['totales-card']} */ ;
/** @type {__VLS_StyleScopedClasses['total-row']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['pos-grid']} */ ;
/** @type {__VLS_StyleScopedClasses['pos-right']} */ ;
// CSS variable injection 
// CSS variable injection end 
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "page" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "page-header" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "header-left" },
});
const __VLS_0 = {}.RouterLink;
/** @type {[typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, typeof __VLS_components.RouterLink, typeof __VLS_components.routerLink, ]} */ ;
// @ts-ignore
const __VLS_1 = __VLS_asFunctionalComponent(__VLS_0, new __VLS_0({
    to: "/ventas",
    ...{ class: "back-link" },
}));
const __VLS_2 = __VLS_1({
    to: "/ventas",
    ...{ class: "back-link" },
}, ...__VLS_functionalComponentArgsRest(__VLS_1));
__VLS_3.slots.default;
var __VLS_3;
__VLS_asFunctionalElement(__VLS_intrinsicElements.h2, __VLS_intrinsicElements.h2)({
    ...{ class: "page-title" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "pos-grid" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "pos-left" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "search-row" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    ...{ onInput: (__VLS_ctx.buscarClientes) },
    value: (__VLS_ctx.clienteBusqueda),
    type: "text",
    placeholder: "Buscar por nombre o NIT...",
    ...{ class: "field-input" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    ...{ onClick: (...[$event]) => {
            __VLS_ctx.clienteSeleccionado = null;
        } },
    ...{ class: "btn btn-ghost btn-sm" },
});
if (__VLS_ctx.clientesResultados.length && !__VLS_ctx.clienteSeleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "dropdown" },
    });
    for (const [c] of __VLS_getVForSourceType((__VLS_ctx.clientesResultados))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ onClick: (...[$event]) => {
                    if (!(__VLS_ctx.clientesResultados.length && !__VLS_ctx.clienteSeleccionado))
                        return;
                    __VLS_ctx.seleccionarCliente(c);
                } },
            key: (c.nit),
            ...{ class: "dropdown-item" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "d-main" },
        });
        (c.nombre);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "d-sub" },
        });
        (c.nit);
    }
}
if (__VLS_ctx.clienteSeleccionado) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "cliente-chip" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "chip-nombre" },
    });
    (__VLS_ctx.clienteSeleccionado.nombre);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "chip-nit" },
    });
    (__VLS_ctx.clienteSeleccionado.nit);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "search-row" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    ...{ onInput: (__VLS_ctx.buscarProductos) },
    value: (__VLS_ctx.productoBusqueda),
    type: "text",
    placeholder: "Buscar producto por nombre o código...",
    ...{ class: "field-input" },
});
if (__VLS_ctx.productosResultados.length) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "dropdown" },
    });
    for (const [p] of __VLS_getVForSourceType((__VLS_ctx.productosResultados))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
            ...{ onClick: (...[$event]) => {
                    if (!(__VLS_ctx.productosResultados.length))
                        return;
                    __VLS_ctx.agregarProducto(p);
                } },
            key: (p.codigo),
            ...{ class: "dropdown-item" },
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "d-main" },
        });
        (p.nombre);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
            ...{ class: "d-sub" },
        });
        (p.stockActual);
        (p.medida);
        (__VLS_ctx.formatNum(p.precioVenta));
    }
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "card card--grow" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
if (!__VLS_ctx.carrito.length) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "empty-cart" },
    });
}
else {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.table, __VLS_intrinsicElements.table)({
        ...{ class: "cart-table" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.thead, __VLS_intrinsicElements.thead)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.tr, __VLS_intrinsicElements.tr)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.th, __VLS_intrinsicElements.th)({});
    __VLS_asFunctionalElement(__VLS_intrinsicElements.tbody, __VLS_intrinsicElements.tbody)({});
    for (const [item, i] of __VLS_getVForSourceType((__VLS_ctx.carrito))) {
        __VLS_asFunctionalElement(__VLS_intrinsicElements.tr, __VLS_intrinsicElements.tr)({
            key: (i),
        });
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-nombre" },
        });
        (item.nombre);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
            ...{ onChange: (__VLS_ctx.recalcular) },
            type: "number",
            min: "0.0001",
            step: "1",
            ...{ class: "qty-input" },
        });
        (item.cantidad);
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-precio" },
        });
        (__VLS_ctx.formatNum(item.precioUnitario));
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({
            ...{ class: "td-sub" },
        });
        (__VLS_ctx.formatNum(item.subtotal));
        __VLS_asFunctionalElement(__VLS_intrinsicElements.td, __VLS_intrinsicElements.td)({});
        __VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
            ...{ onClick: (...[$event]) => {
                    if (!!(!__VLS_ctx.carrito.length))
                        return;
                    __VLS_ctx.quitarProducto(i);
                } },
            ...{ class: "remove-btn" },
            title: "Quitar",
        });
    }
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "pos-right" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    ...{ class: "label" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
    value: (__VLS_ctx.form.fkMetodoPago),
    ...{ class: "field-input" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (1),
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (2),
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
    value: (3),
});
if (__VLS_ctx.form.fkMetodoPago === 2) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "plazo-row" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "plazo-field" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
        ...{ class: "label-sm" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
        type: "number",
        min: "1",
        ...{ class: "field-input" },
    });
    (__VLS_ctx.form.plazoCredito);
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "plazo-field" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
        ...{ class: "label-sm" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.select, __VLS_intrinsicElements.select)({
        value: (__VLS_ctx.form.tipoPlazo),
        ...{ class: "field-input" },
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "DIAS",
    });
    __VLS_asFunctionalElement(__VLS_intrinsicElements.option, __VLS_intrinsicElements.option)({
        value: "MESES",
    });
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "card totales-card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "total-row" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
(__VLS_ctx.formatNum(__VLS_ctx.totales.subtotal));
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "total-row" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
(__VLS_ctx.formatNum(__VLS_ctx.totales.descuentos));
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "total-row" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
(__VLS_ctx.formatNum(__VLS_ctx.totales.impuestos));
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "total-row total-final" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({});
(__VLS_ctx.formatNum(__VLS_ctx.totales.total));
if (__VLS_ctx.errorMsg) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "error-msg" },
    });
    (__VLS_ctx.errorMsg);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    ...{ onClick: (__VLS_ctx.registrar) },
    ...{ class: "btn btn-primary btn-full" },
    disabled: (!__VLS_ctx.puedeRegistrar || __VLS_ctx.guardando),
});
if (__VLS_ctx.guardando) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "spinner" },
        'aria-hidden': "true",
    });
}
(__VLS_ctx.guardando ? 'Registrando...' : 'Registrar venta');
/** @type {__VLS_StyleScopedClasses['page']} */ ;
/** @type {__VLS_StyleScopedClasses['page-header']} */ ;
/** @type {__VLS_StyleScopedClasses['header-left']} */ ;
/** @type {__VLS_StyleScopedClasses['back-link']} */ ;
/** @type {__VLS_StyleScopedClasses['page-title']} */ ;
/** @type {__VLS_StyleScopedClasses['pos-grid']} */ ;
/** @type {__VLS_StyleScopedClasses['pos-left']} */ ;
/** @type {__VLS_StyleScopedClasses['card']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['search-row']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-ghost']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-sm']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown-item']} */ ;
/** @type {__VLS_StyleScopedClasses['d-main']} */ ;
/** @type {__VLS_StyleScopedClasses['d-sub']} */ ;
/** @type {__VLS_StyleScopedClasses['cliente-chip']} */ ;
/** @type {__VLS_StyleScopedClasses['chip-nombre']} */ ;
/** @type {__VLS_StyleScopedClasses['chip-nit']} */ ;
/** @type {__VLS_StyleScopedClasses['card']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['search-row']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown']} */ ;
/** @type {__VLS_StyleScopedClasses['dropdown-item']} */ ;
/** @type {__VLS_StyleScopedClasses['d-main']} */ ;
/** @type {__VLS_StyleScopedClasses['d-sub']} */ ;
/** @type {__VLS_StyleScopedClasses['card']} */ ;
/** @type {__VLS_StyleScopedClasses['card--grow']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['empty-cart']} */ ;
/** @type {__VLS_StyleScopedClasses['cart-table']} */ ;
/** @type {__VLS_StyleScopedClasses['td-nombre']} */ ;
/** @type {__VLS_StyleScopedClasses['qty-input']} */ ;
/** @type {__VLS_StyleScopedClasses['td-precio']} */ ;
/** @type {__VLS_StyleScopedClasses['td-sub']} */ ;
/** @type {__VLS_StyleScopedClasses['remove-btn']} */ ;
/** @type {__VLS_StyleScopedClasses['pos-right']} */ ;
/** @type {__VLS_StyleScopedClasses['card']} */ ;
/** @type {__VLS_StyleScopedClasses['label']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['plazo-row']} */ ;
/** @type {__VLS_StyleScopedClasses['plazo-field']} */ ;
/** @type {__VLS_StyleScopedClasses['label-sm']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['plazo-field']} */ ;
/** @type {__VLS_StyleScopedClasses['label-sm']} */ ;
/** @type {__VLS_StyleScopedClasses['field-input']} */ ;
/** @type {__VLS_StyleScopedClasses['card']} */ ;
/** @type {__VLS_StyleScopedClasses['totales-card']} */ ;
/** @type {__VLS_StyleScopedClasses['total-row']} */ ;
/** @type {__VLS_StyleScopedClasses['total-row']} */ ;
/** @type {__VLS_StyleScopedClasses['total-row']} */ ;
/** @type {__VLS_StyleScopedClasses['total-row']} */ ;
/** @type {__VLS_StyleScopedClasses['total-final']} */ ;
/** @type {__VLS_StyleScopedClasses['error-msg']} */ ;
/** @type {__VLS_StyleScopedClasses['btn']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-primary']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-full']} */ ;
/** @type {__VLS_StyleScopedClasses['spinner']} */ ;
var __VLS_dollars;
const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            RouterLink: RouterLink,
            clienteBusqueda: clienteBusqueda,
            clientesResultados: clientesResultados,
            clienteSeleccionado: clienteSeleccionado,
            productoBusqueda: productoBusqueda,
            productosResultados: productosResultados,
            carrito: carrito,
            guardando: guardando,
            errorMsg: errorMsg,
            form: form,
            totales: totales,
            puedeRegistrar: puedeRegistrar,
            buscarClientes: buscarClientes,
            buscarProductos: buscarProductos,
            seleccionarCliente: seleccionarCliente,
            agregarProducto: agregarProducto,
            quitarProducto: quitarProducto,
            recalcular: recalcular,
            registrar: registrar,
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
