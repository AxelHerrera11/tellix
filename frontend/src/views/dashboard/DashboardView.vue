<template>
  <div class="dashboard">
      <h2 class="section-title">Bienvenido, {{ auth.nombreEmpleado }}</h2>
      <p class="section-sub">Rol: <strong>{{ auth.rol }}</strong></p>

      <div class="cards">
        <div class="stat-card">
          <span class="stat-label">Ventas hoy</span>
          <span class="stat-value">—</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">Stock crítico</span>
          <span class="stat-value">—</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">CXC vencidas</span>
          <span class="stat-value">—</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">CXP pendientes</span>
          <span class="stat-value">—</span>
        </div>
      </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth.store'
const auth = useAuthStore()
</script>

<style scoped>
.dashboard { display: flex; flex-direction: column; gap: 1.5rem; }
.section-title { font-size: 1.4rem; font-weight: 600; }
.section-sub { color: var(--color-text-secondary); font-size: 0.9rem; }
.cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; }
.stat-card {
  background: var(--color-bg-card);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1.25rem;
  display: flex; flex-direction: column; gap: 6px;
}
.stat-label { font-size: 0.8rem; color: var(--color-text-muted); font-weight: 500; }
.stat-value { font-size: 1.8rem; font-weight: 700; color: var(--color-text); }
</style>
