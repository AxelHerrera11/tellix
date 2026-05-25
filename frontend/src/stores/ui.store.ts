import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface Toast {
  id: number
  tipo: 'exito' | 'error' | 'aviso' | 'info'
  mensaje: string
}

export const useUiStore = defineStore('ui', () => {
  const sidebarAbierto = ref(true)
  const cargando       = ref(false)
  const toasts         = ref<Toast[]>([])
  let toastId          = 0

  function mostrarToast(mensaje: string, tipo: Toast['tipo'] = 'info', duracion = 4000) {
    const id = ++toastId
    toasts.value.push({ id, tipo, mensaje })
    setTimeout(() => {
      toasts.value = toasts.value.filter(t => t.id !== id)
    }, duracion)
  }

  function toggleSidebar() {
    sidebarAbierto.value = !sidebarAbierto.value
  }

  function setCargando(val: boolean) {
    cargando.value = val
  }

  return { sidebarAbierto, cargando, toasts, mostrarToast, toggleSidebar, setCargando }
})
