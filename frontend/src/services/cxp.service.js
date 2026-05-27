import api from './api';
export const cxpService = {
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
        if (filtros.vencidas)
            params.append('vencidas', 'true');
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/cxp?${params.toString()}`);
        return data.data;
    },
    async obtener(id) {
        const { data } = await api.get(`/cxp/${id}`);
        return data.data;
    },
    async registrarPago(id, req) {
        await api.post(`/cxp/${id}/pagos`, req);
    },
    async anular(id, motivo) {
        const req = { motivo };
        await api.patch(`/cxp/${id}/anular`, req);
    },
    async vencidas(fecha) {
        const params = new URLSearchParams();
        if (fecha)
            params.append('fecha', fecha);
        const { data } = await api.get(`/cxp/vencidas?${params.toString()}`);
        return data.data;
    },
    async resumen() {
        const { data } = await api.get('/cxp/resumen');
        return data.data;
    },
    async generarDesdeCompra(compraId) {
        const { data } = await api.post(`/cxp/generar-desde-compra/${compraId}`);
        return data.data;
    },
    async listarMetodosPago() {
        const { data } = await api.get('/cxp/catalogos/metodos-pago');
        return data.data;
    },
    async listarCuentasBancarias() {
        const { data } = await api.get('/cxp/catalogos/cuentas-bancarias');
        return data.data;
    }
};
