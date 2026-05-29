/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />

import { onMounted, ref } from 'vue';
import { RouterLink } from 'vue-router';

import { useToast } from '@/composables/useToast';
import { cxcService } from '@/services/cxc.service';

const props = defineProps();

const toast = useToast();

const registros = ref([]);
const paginado = ref(null);
const resumen = ref(null);

const cargando = ref(false);
const pagina = ref(1);

const filtros = ref({
    cliente: '',
    estado: '',
    desde: '',
    hasta: '',
    vencidas: !!props.soloVencidas
});

async function cargar() {
    try {
        cargando.value = true;

        const [listado, datosResumen] = await Promise.all([
            cxcService.listar({
                ...filtros.value,
                pagina: pagina.value,
                tamano: 20
            }),
            cxcService.resumen()
        ]);

        registros.value = listado.data;
        paginado.value = listado;
        resumen.value = datosResumen;

    } catch {
        toast.error('Error al cargar cuentas por cobrar.');

    } finally {
        cargando.value = false;
    }
}

function buscar() {
    pagina.value = 1;
    cargar();
}

function limpiar() {
    filtros.value = {
        cliente: '',
        estado: '',
        desde: '',
        hasta: '',
        vencidas: !!props.soloVencidas
    };

    buscar();
}

function irPagina(n) {
    pagina.value = n;
    cargar();
}

function formatFecha(f) {
    return f
        ? new Date(f).toLocaleDateString('es-GT')
        : '—';
}

function formatNum(n) {
    return Number(n ?? 0).toFixed(2);
}

onMounted(cargar);

debugger; /* PartiallyEnd: #3632/scriptSetup.vue */

const __VLS_ctx = {};

let __VLS_components;
let __VLS_directives;

var __VLS_dollars;

const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            RouterLink,
            registros,
            paginado,
            resumen,
            cargando,
            pagina,
            filtros,
            buscar,
            limpiar,
            irPagina,
            formatFecha,
            formatNum,
        };
    },

    __typeProps: {},
});

export default (await import('vue')).defineComponent({
    setup() {
        return {};
    },

    __typeProps: {},
});

; /* PartiallyEnd: #4569/main.vue */