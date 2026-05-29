import api from './api';
// ── Service ───────────────────────────────────────────────────
export const inventarioService = {
    async listarStock(filtros = {}) {
        const params = new URLSearchParams();
        if (filtros.busqueda)
            params.append('busqueda', filtros.busqueda);
        if (filtros.categoria)
            params.append('categoria', String(filtros.categoria));
        if (filtros.estado)
            params.append('estado', filtros.estado);
        if (filtros.critico)
            params.append('critico', 'true');
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/inventario/stock?${params.toString()}`);
        return data.data;
    },
    async stockCritico() {
        const { data } = await api.get('/inventario/stock/critico');
        return data.data;
    },
    async listarMovimientos(filtros = {}) {
        const params = new URLSearchParams();
        if (filtros.producto)
            params.append('producto', String(filtros.producto));
        if (filtros.operacion)
            params.append('operacion', filtros.operacion);
        if (filtros.desde)
            params.append('desde', filtros.desde);
        if (filtros.hasta)
            params.append('hasta', filtros.hasta);
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/inventario/movimientos?${params.toString()}`);
        return data.data;
    },
    async ajustar(req) {
        await api.post('/inventario/ajustes', req);
    }
};
