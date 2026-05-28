import api from './api';
// ── Service ───────────────────────────────────────────────────
export const compraService = {
    async listar(filtros = {}) {
        const params = new URLSearchParams();
        if (filtros.proveedor)
            params.append('proveedor', filtros.proveedor);
        if (filtros.estado)
            params.append('estado', filtros.estado);
        if (filtros.desde)
            params.append('desde', filtros.desde);
        if (filtros.hasta)
            params.append('hasta', filtros.hasta);
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/compras?${params.toString()}`);
        return data.data;
    },
    async obtener(id) {
        const { data } = await api.get(`/compras/${id}`);
        return data.data;
    },
    async registrar(req) {
        const { data } = await api.post('/compras', req);
        return data.data;
    },
    async aprobar(id) {
        await api.patch(`/compras/${id}/aprobar`);
    },
    async completar(id) {
        await api.patch(`/compras/${id}/completar`);
    },
    async anular(id, motivo) {
        await api.patch(`/compras/${id}/anular`, { motivo });
    },
    async buscarProductos(q) {
        const params = new URLSearchParams();
        if (q)
            params.append('q', q);
        const { data } = await api.get(`/compras/productos/buscar?${params.toString()}`);
        return data.data;
    },
    async buscarProveedores(q) {
        const params = new URLSearchParams();
        if (q)
            params.append('q', q);
        const { data } = await api.get(`/compras/proveedores/buscar?${params.toString()}`);
        return data.data;
    },
    async listarMetodosPago() {
        const { data } = await api.get('/compras/metodos-pago');
        return data.data;
    },
    async buscarRepresentantes(q) {
        const params = new URLSearchParams();
        if (q)
            params.append('q', q);
        const { data } = await api.get(`/compras/representantes/buscar?${params.toString()}`);
        return data.data;
    }
};
