<template>
  <div class="error-page">
    <span class="code">404</span>
    <h1>Pagina no encontrada</h1>
    <p>La ruta que busca no existe.</p>
    <router-link to="/dashboard">Volver al inicio</router-link>
  </div>
</template>
<script setup lang="ts">
import { RouterLink } from "vue-router"
</script>
<style scoped>
.error-page { min-height:100vh; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:.75rem; text-align:center; }
.code { font-size:5rem; font-weight:800; color:var(--color-text-muted); line-height:1; }
h1 { font-size:1.5rem; }
p  { color:var(--color-text-muted); }
</style>