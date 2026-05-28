import api from './api';
export const cxcService = {
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
        if (filtros.vencidas)
            params.append('vencidas', 'true');
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/cxc?${params.toString()}`);
        return data.data;
    },
    async obtener(id) { const { data } = await api.get(`/cxc/${id}`); return data.data; },
    async registrarCobro(id, req) { await api.post(`/cxc/${id}/cobros`, req); },
    async anular(id, motivo) { await api.patch(`/cxc/${id}/anular`, { motivo }); },
    async vencidas(fecha) {
        const params = new URLSearchParams();
        if (fecha)
            params.append('fecha', fecha);
        const { data } = await api.get(`/cxc/vencidas?${params.toString()}`);
        return data.data;
    },
    async resumen() { const { data } = await api.get('/cxc/resumen'); return data.data; },
    async generarDesdeVenta(ventaId) { const { data } = await api.post(`/cxc/generar-desde-venta/${ventaId}`); return data.data; },
    async listarMetodosCobro() { const { data } = await api.get('/cxc/catalogos/metodos-cobro'); return data.data; },
    async listarCuentasBancarias() { const { data } = await api.get('/cxc/catalogos/cuentas-bancarias'); return data.data; }
};
