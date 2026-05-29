/// <reference types="../../../node_modules/.vue-global-types/vue_3.5_0_0_0.d.ts" />
import { ref } from 'vue';
import { useAuthStore } from '@/stores/auth.store';
import { useUiStore } from '@/stores/ui.store';
import { authService } from '@/services/auth.service';
import { useRouter, useRoute } from 'vue-router';
const router = useRouter();
const route = useRoute();
const auth = useAuthStore();
const ui = useUiStore();
const form = ref({ userName: '', password: '' });
const mostrarPassword = ref(false);
const cargando = ref(false);
const errorMsg = ref('');
async function handleLogin() {
    errorMsg.value = '';
    if (!form.value.userName || !form.value.password) {
        errorMsg.value = 'Complete usuario y contraseña.';
        return;
    }
    try {
        cargando.value = true;
        const resp = await authService.login(form.value.userName, form.value.password);
        auth.guardarSesion(resp);
        ui.mostrarToast(`Bienvenido, ${resp.nombreEmpleado}`, 'exito');
        const redirigir = route.query.redirigir;
        router.push(redirigir ?? '/dashboard');
    }
    catch (err) {
        const msg = err.response?.data?.mensaje;
        errorMsg.value = msg ?? 'Error al iniciar sesión. Intente de nuevo.';
    }
    finally {
        cargando.value = false;
    }
}
debugger; /* PartiallyEnd: #3632/scriptSetup.vue */
const __VLS_ctx = {};
let __VLS_components;
let __VLS_directives;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['input-eye']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-login']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-login']} */ ;
// CSS variable injection 
// CSS variable injection end 
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "login-page" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "login-card" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "login-logo" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "logo-text" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "logo-sub" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.form, __VLS_intrinsicElements.form)({
    ...{ onSubmit: (__VLS_ctx.handleLogin) },
    ...{ class: "login-form" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    for: "userName",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    id: "userName",
    value: (__VLS_ctx.form.userName),
    type: "text",
    placeholder: "Ingrese su usuario",
    autocomplete: "username",
    disabled: (__VLS_ctx.cargando),
    required: true,
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "field" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.label, __VLS_intrinsicElements.label)({
    for: "password",
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
    ...{ class: "input-eye" },
});
__VLS_asFunctionalElement(__VLS_intrinsicElements.input)({
    id: "password",
    type: (__VLS_ctx.mostrarPassword ? 'text' : 'password'),
    placeholder: "Ingrese su contraseña",
    autocomplete: "current-password",
    disabled: (__VLS_ctx.cargando),
    required: true,
});
(__VLS_ctx.form.password);
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    ...{ onClick: (...[$event]) => {
            __VLS_ctx.mostrarPassword = !__VLS_ctx.mostrarPassword;
        } },
    type: "button",
    ...{ class: "eye-btn" },
    'aria-label': (__VLS_ctx.mostrarPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'),
});
(__VLS_ctx.mostrarPassword ? '🙈' : '👁');
if (__VLS_ctx.errorMsg) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.p, __VLS_intrinsicElements.p)({
        ...{ class: "error-msg" },
        role: "alert",
    });
    (__VLS_ctx.errorMsg);
}
__VLS_asFunctionalElement(__VLS_intrinsicElements.button, __VLS_intrinsicElements.button)({
    type: "submit",
    ...{ class: "btn-login" },
    disabled: (__VLS_ctx.cargando),
});
if (__VLS_ctx.cargando) {
    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "spinner" },
        'aria-hidden': "true",
    });
}
(__VLS_ctx.cargando ? 'Ingresando...' : 'Ingresar');
/** @type {__VLS_StyleScopedClasses['login-page']} */ ;
/** @type {__VLS_StyleScopedClasses['login-card']} */ ;
/** @type {__VLS_StyleScopedClasses['login-logo']} */ ;
/** @type {__VLS_StyleScopedClasses['logo-text']} */ ;
/** @type {__VLS_StyleScopedClasses['logo-sub']} */ ;
/** @type {__VLS_StyleScopedClasses['login-form']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['field']} */ ;
/** @type {__VLS_StyleScopedClasses['input-eye']} */ ;
/** @type {__VLS_StyleScopedClasses['eye-btn']} */ ;
/** @type {__VLS_StyleScopedClasses['error-msg']} */ ;
/** @type {__VLS_StyleScopedClasses['btn-login']} */ ;
/** @type {__VLS_StyleScopedClasses['spinner']} */ ;
var __VLS_dollars;
const __VLS_self = (await import('vue')).defineComponent({
    setup() {
        return {
            form: form,
            mostrarPassword: mostrarPassword,
            cargando: cargando,
            errorMsg: errorMsg,
            handleLogin: handleLogin,
        };
    },
});
export default (await import('vue')).defineComponent({
    setup() {
        return {};
    },
});
; /* PartiallyEnd: #4569/main.vue */
