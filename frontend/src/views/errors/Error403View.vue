<template>
  <div class="error-page">
    <span class="code">403</span>
    <h1>Acceso denegado</h1>
    <p>No tiene permiso para ver esta pagina.</p>
    <router-link to="/dashboard">Volver al inicio</router-link>
  </div>
</template>
<script setup lang="ts">
import { RouterLink } from "vue-router"
</script>
<style scoped>
.error-page { min-height:100vh; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:.75rem; text-align:center; }
.code { font-size:5rem; font-weight:800; color:var(--color-danger); line-height:1; }
h1 { font-size:1.5rem; }
p  { color:var(--color-text-muted); }
</style>