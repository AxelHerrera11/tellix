<template>
  <aside class="sidebar" :class="{ collapsed: !ui.sidebarAbierto }">
    <div class="sidebar-logo">
      <span class="logo-mark">T</span>
      <span class="logo-name" v-show="ui.sidebarAbierto">Tellix</span>
    </div>

    <nav class="sidebar-nav">
      <router-link to="/dashboard" class="nav-item" active-class="nav-item--active">
        <span class="nav-icon">⊞</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Dashboard</span>
      </router-link>

      <!-- Ventas: Vendedor, Administrador -->
      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','VENDEDOR')"
        to="/ventas" class="nav-item" active-class="nav-item--active"
      >
        <span class="nav-icon">🧾</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Ventas</span>
      </router-link>

      <!-- Compras + Inventario: Bodeguero, Administrador -->
      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','BODEGUERO')"
        to="/compras" class="nav-item" active-class="nav-item--active"
      >
        <span class="nav-icon">📦</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Compras</span>
      </router-link>

      <template v-if="auth.tieneRol('ADMINISTRADOR','BODEGUERO')">
        <router-link to="/inventario" class="nav-item" active-class="nav-item--active">
          <span class="nav-icon">📊</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Inventario</span>
        </router-link>
        <router-link to="/inventario/ajuste" class="nav-item nav-item--sub" active-class="nav-item--active">
          <span class="nav-icon">⚖</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Ajustes</span>
        </router-link>
        <router-link to="/inventario/movimientos" class="nav-item nav-item--sub" active-class="nav-item--active">
          <span class="nav-icon">📋</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Movimientos</span>
        </router-link>
      </template>

      <!-- CXC / CXP: Contador, Administrador -->
      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','CONTADOR')"
        to="/cxc" class="nav-item" active-class="nav-item--active"
      >
        <span class="nav-icon">💵</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">CXC</span>
      </router-link>

      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','CONTADOR')"
        to="/cxp" class="nav-item" active-class="nav-item--active"
      >
        <span class="nav-icon">💳</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">CXP</span>
      </router-link>
      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','CONTADOR')"
        to="/cxp/vencidas" class="nav-item nav-item--sub" active-class="nav-item--active"
      >
        <span class="nav-icon">⏳</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">CXP vencidas</span>
      </router-link>

      <!-- Catálogos: todos -->
      <div class="nav-section" v-show="ui.sidebarAbierto">Catálogos</div>
      <router-link v-if="auth.tieneRol('ADMINISTRADOR','VENDEDOR','CONTADOR')" to="/catalogos/productos" class="nav-item nav-item--sub" active-class="nav-item--active">
        <span class="nav-icon">🏷</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Productos</span>
      </router-link>
      <router-link v-if="auth.tieneRol('ADMINISTRADOR','VENDEDOR','CONTADOR')" to="/precios" class="nav-item nav-item--sub" active-class="nav-item--active">
        <span class="nav-icon">💲</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Precios</span>
      </router-link>
      <router-link to="/catalogos/clientes"    class="nav-item nav-item--sub" active-class="nav-item--active">
        <span class="nav-icon">👥</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Clientes</span>
      </router-link>
      <router-link to="/catalogos/proveedores" class="nav-item nav-item--sub" active-class="nav-item--active">
        <span class="nav-icon">🏭</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Proveedores</span>
      </router-link>

      <!-- Reportes: Contador, Administrador -->
      <router-link
        v-if="auth.tieneRol('ADMINISTRADOR','CONTADOR')"
        to="/reportes" class="nav-item" active-class="nav-item--active"
      >
        <span class="nav-icon">📈</span>
        <span class="nav-label" v-show="ui.sidebarAbierto">Reportes</span>
      </router-link>

      <!-- Admin: solo nivel 1 -->
      <template v-if="auth.esAdmin">
        <div class="nav-section" v-show="ui.sidebarAbierto">Administración</div>
        <router-link to="/admin/usuarios"  class="nav-item nav-item--sub" active-class="nav-item--active">
          <span class="nav-icon">👤</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Usuarios</span>
        </router-link>
        <router-link to="/admin/roles"     class="nav-item nav-item--sub" active-class="nav-item--active">
          <span class="nav-icon">🔑</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Roles</span>
        </router-link>
        <router-link to="/admin/auditoria" class="nav-item nav-item--sub" active-class="nav-item--active">
          <span class="nav-icon">📋</span>
          <span class="nav-label" v-show="ui.sidebarAbierto">Auditoría</span>
        </router-link>
      </template>
    </nav>
  </aside>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores/auth.store'
import { useUiStore }   from '@/stores/ui.store'
const auth = useAuthStore()
const ui   = useUiStore()
</script>

<style scoped>
.sidebar {
  width: 220px;
  background: var(--color-bg-sidebar);
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  transition: width 0.2s;
  overflow: hidden;
}
.sidebar.collapsed { width: 56px; }
.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 1.25rem 1rem;
  border-bottom: 1px solid rgba(255,255,255,0.07);
}
.logo-mark {
  width: 32px; height: 32px;
  background: var(--color-primary);
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-weight: 700; font-size: 1rem;
  flex-shrink: 0;
}
.logo-name {
  color: #fff; font-weight: 700; font-size: 1.1rem;
  white-space: nowrap;
}
.sidebar-nav {
  flex: 1;
  padding: 0.75rem 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow-y: auto;
}
.nav-section {
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  color: rgba(255,255,255,0.3);
  text-transform: uppercase;
  padding: 0.75rem 0.5rem 0.25rem;
}
.nav-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0.55rem 0.75rem;
  border-radius: 8px;
  color: rgba(255,255,255,0.65);
  text-decoration: none;
  font-size: 0.9rem;
  transition: background 0.1s, color 0.1s;
  white-space: nowrap;
}
.nav-item:hover { background: rgba(255,255,255,0.08); color: #fff; }
.nav-item--active { background: var(--color-primary); color: #fff !important; }
.nav-item--sub { padding-left: 1rem; }
.nav-icon { font-size: 1rem; flex-shrink: 0; width: 20px; text-align: center; }
.nav-label { overflow: hidden; white-space: nowrap; }
</style>
