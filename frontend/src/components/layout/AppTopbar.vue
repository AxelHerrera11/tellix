<template>
  <header class="topbar">
    <button class="sidebar-toggle" @click="ui.toggleSidebar()" aria-label="Toggle sidebar">
      ☰
    </button>

    <h1 class="page-title">{{ route.meta.titulo ?? 'Tellix' }}</h1>

    <div class="topbar-right">
      <div class="user-info">
        <div class="avatar">{{ iniciales }}</div>
        <div class="user-details">
          <span class="user-name">{{ auth.nombreEmpleado }}</span>
          <span class="user-rol">{{ auth.rol }}</span>
        </div>
      </div>
      <button class="logout-btn" @click="handleLogout" title="Cerrar sesión">⏻</button>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth.store'
import { useUiStore }   from '@/stores/ui.store'
import { useAuth }      from '@/composables/useAuth'

const route  = useRoute()
const auth   = useAuthStore()
const ui     = useUiStore()
const { logout: handleLogout } = useAuth()

const iniciales = computed(() => {
  return auth.nombreEmpleado
    .split(' ')
    .slice(0, 2)
    .map(p => p[0] ?? '')
    .join('')
    .toUpperCase()
})
</script>

<style scoped>
.topbar {
  height: 56px;
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0 1.5rem;
  background: var(--color-bg-card);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}
.sidebar-toggle {
  background: none;
  border: none;
  font-size: 1.1rem;
  cursor: pointer;
  color: var(--color-text-secondary);
  padding: 4px;
  border-radius: 6px;
  line-height: 1;
}
.sidebar-toggle:hover { background: var(--color-bg-page); }
.page-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text);
  flex: 1;
}
.topbar-right {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}
.avatar {
  width: 34px; height: 34px;
  border-radius: 50%;
  background: var(--color-primary-light);
  color: var(--color-primary);
  display: flex; align-items: center; justify-content: center;
  font-size: 0.75rem;
  font-weight: 700;
}
.user-details {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}
.user-name {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text);
}
.user-rol {
  font-size: 0.72rem;
  color: var(--color-text-muted);
  text-transform: capitalize;
}
.logout-btn {
  background: none;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 6px 10px;
  font-size: 1rem;
  cursor: pointer;
  color: var(--color-text-secondary);
  transition: background 0.1s;
}
.logout-btn:hover { background: var(--color-danger-bg); color: var(--color-danger); border-color: var(--color-danger-border); }
</style>
