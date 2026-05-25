<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-logo">
        <span class="logo-text">Tellix</span>
        <span class="logo-sub">Sistema de gestión comercial</span>
      </div>

      <form class="login-form" @submit.prevent="handleLogin">
        <div class="field">
          <label for="userName">Usuario</label>
          <input
            id="userName"
            v-model="form.userName"
            type="text"
            placeholder="Ingrese su usuario"
            autocomplete="username"
            :disabled="cargando"
            required
          />
        </div>

        <div class="field">
          <label for="password">Contraseña</label>
          <div class="input-eye">
            <input
              id="password"
              v-model="form.password"
              :type="mostrarPassword ? 'text' : 'password'"
              placeholder="Ingrese su contraseña"
              autocomplete="current-password"
              :disabled="cargando"
              required
            />
            <button
              type="button"
              class="eye-btn"
              :aria-label="mostrarPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'"
              @click="mostrarPassword = !mostrarPassword"
            >
              {{ mostrarPassword ? '🙈' : '👁' }}
            </button>
          </div>
        </div>

        <p v-if="errorMsg" class="error-msg" role="alert">{{ errorMsg }}</p>

        <button type="submit" class="btn-login" :disabled="cargando">
          <span v-if="cargando" class="spinner" aria-hidden="true"></span>
          {{ cargando ? 'Ingresando...' : 'Ingresar' }}
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth.store'
import { useUiStore }   from '@/stores/ui.store'
import { authService }  from '@/services/auth.service'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route  = useRoute()
const auth   = useAuthStore()
const ui     = useUiStore()

const form = ref({ userName: '', password: '' })
const mostrarPassword = ref(false)
const cargando  = ref(false)
const errorMsg  = ref('')

async function handleLogin() {
  errorMsg.value = ''
  if (!form.value.userName || !form.value.password) {
    errorMsg.value = 'Complete usuario y contraseña.'
    return
  }

  try {
    cargando.value = true
    const resp = await authService.login(form.value.userName, form.value.password)
    auth.guardarSesion(resp)
    ui.mostrarToast(`Bienvenido, ${resp.nombreEmpleado}`, 'exito')
    const redirigir = route.query.redirigir as string | undefined
    router.push(redirigir ?? '/dashboard')
  } catch (err: any) {
    const msg = err.response?.data?.mensaje
    errorMsg.value = msg ?? 'Error al iniciar sesión. Intente de nuevo.'
  } finally {
    cargando.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-page);
  padding: 1rem;
}

.login-card {
  width: 100%;
  max-width: 380px;
  background: var(--color-bg-card);
  border: 1px solid var(--color-border);
  border-radius: 16px;
  padding: 2.5rem 2rem;
}

.login-logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 2rem;
  gap: 4px;
}

.logo-text {
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-primary);
  letter-spacing: -1px;
}

.logo-sub {
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field label {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-secondary);
}

.field input {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  font-size: 0.95rem;
  background: var(--color-bg-input);
  color: var(--color-text);
  transition: border-color 0.15s;
  box-sizing: border-box;
}

.field input:focus {
  outline: none;
  border-color: var(--color-primary);
}

.field input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.input-eye {
  position: relative;
}

.input-eye input {
  padding-right: 2.5rem;
}

.eye-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  font-size: 1rem;
  line-height: 1;
}

.error-msg {
  background: var(--color-danger-bg);
  color: var(--color-danger);
  border: 1px solid var(--color-danger-border);
  border-radius: 8px;
  padding: 0.6rem 0.8rem;
  font-size: 0.85rem;
  margin: 0;
}

.btn-login {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 0.7rem;
  background: var(--color-primary);
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s, opacity 0.15s;
  margin-top: 0.25rem;
}

.btn-login:hover:not(:disabled) {
  background: var(--color-primary-hover);
}

.btn-login:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255,255,255,0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  flex-shrink: 0;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
