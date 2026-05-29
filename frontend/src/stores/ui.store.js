import { defineStore } from 'pinia';
import { ref } from 'vue';
export const useUiStore = defineStore('ui', () => {
    const sidebarAbierto = ref(true);
    const cargando = ref(false);
    const toasts = ref([]);
    let toastId = 0;
    function mostrarToast(mensaje, tipo = 'info', duracion = 4000) {
        const id = ++toastId;
        toasts.value.push({ id, tipo, mensaje });
        setTimeout(() => {
            toasts.value = toasts.value.filter(t => t.id !== id);
        }, duracion);
    }
    function toggleSidebar() {
        sidebarAbierto.value = !sidebarAbierto.value;
    }
    function setCargando(val) {
        cargando.value = val;
    }
    return { sidebarAbierto, cargando, toasts, mostrarToast, toggleSidebar, setCargando };
});
