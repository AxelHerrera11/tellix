<template>
  <div class="app-shell">
    <AppSidebar />
    <div class="main-area">
      <AppTopbar />
      <main class="page-content">
        <RouterView />
      </main>
    </div>

    <!-- Toast notifications -->
    <div class="toast-container" aria-live="polite">
      <div
        v-for="toast in ui.toasts"
        :key="toast.id"
        class="toast"
        :class="`toast--${toast.tipo}`"
      >
        {{ toast.mensaje }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppSidebar from './AppSidebar.vue'
import AppTopbar  from './AppTopbar.vue'
import { useUiStore } from '@/stores/ui.store'
const ui = useUiStore()
</script>

<style scoped>
.app-shell {
  display: flex;
  height: 100vh;
  overflow: hidden;
}
.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.page-content {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 2rem;
}
.toast-container {
  position: fixed;
  bottom: 1.5rem;
  right: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 9999;
}
.toast {
  padding: 0.75rem 1.25rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 500;
  min-width: 240px;
  max-width: 360px;
  animation: slide-in 0.2s ease;
}
.toast--exito  { background: var(--color-success); color: #fff; }
.toast--error  { background: var(--color-danger);  color: #fff; }
.toast--aviso  { background: var(--color-warning); color: #fff; }
.toast--info   { background: var(--color-info);    color: #fff; }
@keyframes slide-in {
  from { transform: translateX(100%); opacity: 0; }
  to   { transform: translateX(0);    opacity: 1; }
}
</style>
