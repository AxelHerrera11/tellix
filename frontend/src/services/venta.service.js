import api from './api';
// ── Service ───────────────────────────────────────────────────
export const ventaService = {
    async listar(filtros = {}) {
        const params = new URLSearchParams();
        if (filtros.cliente)
            params.append('cliente', filtros.cliente);
        if (filtros.estado)
            params.append('estado', filtros.estado);
        if (filtros.desde)
            params.append('desde', filtros.desde);
        if (filtros.hasta)
            params.append('hasta', filtros.hasta);
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/ventas?${params.toString()}`);
        return data.data;
    },
    async obtener(id) {
        const { data } = await api.get(`/ventas/${id}`);
        return data.data;
    },
    async registrar(req) {
        const { data } = await api.post('/ventas', req);
        return data.data;
    },
    async anular(id, motivo) {
        await api.patch(`/ventas/${id}/anular`, { motivo });
    },
    async buscarProductos(q, aplicacion) {
        const params = new URLSearchParams();
        if (q)
            params.append('q', q);
        if (aplicacion)
            params.append('aplicacion', aplicacion);
        const { data } = await api.get(`/ventas/productos/buscar?${params.toString()}`);
        return data.data;
    },
    async buscarClientes(q) {
        const params = new URLSearchParams();
        if (q)
            params.append('q', q);
        const { data } = await api.get(`/ventas/clientes/buscar?${params.toString()}`);
        return data.data;
    }
};
