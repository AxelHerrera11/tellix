import { useUiStore } from '@/stores/ui.store';
export function useToast() {
    const ui = useUiStore();
    return {
        exito: (msg) => ui.mostrarToast(msg, 'exito'),
        error: (msg) => ui.mostrarToast(msg, 'error'),
        aviso: (msg) => ui.mostrarToast(msg, 'aviso'),
        info: (msg) => ui.mostrarToast(msg, 'info')
    };
}
