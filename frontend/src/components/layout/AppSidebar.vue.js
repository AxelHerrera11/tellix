if (__VLS_ctx.auth.tieneRol('ADMINISTRADOR', 'VENDEDOR', 'CONTADOR')) {
    const __VLS_36 = {}.RouterLink;

    // @ts-ignore
    const __VLS_37 = __VLS_asFunctionalComponent(__VLS_36, new __VLS_36({
        to: "/precios",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }));

    const __VLS_38 = __VLS_37({
        to: "/precios",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }, ...__VLS_functionalComponentArgsRest(__VLS_37));

    __VLS_39.slots.default;

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-icon" },
    });

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-label" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    var __VLS_39;
}

const __VLS_40 = {}.RouterLink;

// @ts-ignore
const __VLS_41 = __VLS_asFunctionalComponent(__VLS_40, new __VLS_40({
    to: "/catalogos/clientes",
    ...{ class: "nav-item nav-item--sub" },
    activeClass: "nav-item--active",
}));

const __VLS_42 = __VLS_41({
    to: "/catalogos/clientes",
    ...{ class: "nav-item nav-item--sub" },
    activeClass: "nav-item--active",
}, ...__VLS_functionalComponentArgsRest(__VLS_41));

__VLS_43.slots.default;

__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "nav-icon" },
});

__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "nav-label" },
});

__VLS_asFunctionalDirective(
    __VLS_directives.vShow
)(
    null,
    { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
    null,
    null
);

var __VLS_43;

const __VLS_44 = {}.RouterLink;

// @ts-ignore
const __VLS_45 = __VLS_asFunctionalComponent(__VLS_44, new __VLS_44({
    to: "/catalogos/proveedores",
    ...{ class: "nav-item nav-item--sub" },
    activeClass: "nav-item--active",
}));

const __VLS_46 = __VLS_45({
    to: "/catalogos/proveedores",
    ...{ class: "nav-item nav-item--sub" },
    activeClass: "nav-item--active",
}, ...__VLS_functionalComponentArgsRest(__VLS_45));

__VLS_47.slots.default;

__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "nav-icon" },
});

__VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
    ...{ class: "nav-label" },
});

__VLS_asFunctionalDirective(
    __VLS_directives.vShow
)(
    null,
    { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
    null,
    null
);

var __VLS_47;

if (__VLS_ctx.auth.tieneRol('ADMINISTRADOR', 'CONTADOR')) {
    const __VLS_48 = {}.RouterLink;

    // @ts-ignore
    const __VLS_49 = __VLS_asFunctionalComponent(__VLS_48, new __VLS_48({
        to: "/reportes",
        ...{ class: "nav-item" },
        activeClass: "nav-item--active",
    }));

    const __VLS_50 = __VLS_49({
        to: "/reportes",
        ...{ class: "nav-item" },
        activeClass: "nav-item--active",
    }, ...__VLS_functionalComponentArgsRest(__VLS_49));

    __VLS_51.slots.default;

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-icon" },
    });

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-label" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    var __VLS_51;
}

if (__VLS_ctx.auth.esAdmin) {

    __VLS_asFunctionalElement(__VLS_intrinsicElements.div, __VLS_intrinsicElements.div)({
        ...{ class: "nav-section" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    const __VLS_52 = {}.RouterLink;

    // @ts-ignore
    const __VLS_53 = __VLS_asFunctionalComponent(__VLS_52, new __VLS_52({
        to: "/admin/usuarios",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }));

    const __VLS_54 = __VLS_53({
        to: "/admin/usuarios",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }, ...__VLS_functionalComponentArgsRest(__VLS_53));

    __VLS_55.slots.default;

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-icon" },
    });

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-label" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    var __VLS_55;

    const __VLS_56 = {}.RouterLink;

    // @ts-ignore
    const __VLS_57 = __VLS_asFunctionalComponent(__VLS_56, new __VLS_56({
        to: "/admin/roles",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }));

    const __VLS_58 = __VLS_57({
        to: "/admin/roles",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }, ...__VLS_functionalComponentArgsRest(__VLS_57));

    __VLS_59.slots.default;

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-icon" },
    });

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-label" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    var __VLS_59;

    const __VLS_60 = {}.RouterLink;

    // @ts-ignore
    const __VLS_61 = __VLS_asFunctionalComponent(__VLS_60, new __VLS_60({
        to: "/admin/auditoria",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }));

    const __VLS_62 = __VLS_61({
        to: "/admin/auditoria",
        ...{ class: "nav-item nav-item--sub" },
        activeClass: "nav-item--active",
    }, ...__VLS_functionalComponentArgsRest(__VLS_61));

    __VLS_63.slots.default;

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-icon" },
    });

    __VLS_asFunctionalElement(__VLS_intrinsicElements.span, __VLS_intrinsicElements.span)({
        ...{ class: "nav-label" },
    });

    __VLS_asFunctionalDirective(
        __VLS_directives.vShow
    )(
        null,
        { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.ui.sidebarAbierto) },
        null,
        null
    );

    var __VLS_63;
}