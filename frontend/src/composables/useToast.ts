import { useUiStore } from '@/stores/ui.store'

export function useToast() {
  const ui = useUiStore()
  return {
    exito:  (msg: string) => ui.mostrarToast(msg, 'exito'),
    error:  (msg: string) => ui.mostrarToast(msg, 'error'),
    aviso:  (msg: string) => ui.mostrarToast(msg, 'aviso'),
    info:   (msg: string) => ui.mostrarToast(msg, 'info')
  }
}
