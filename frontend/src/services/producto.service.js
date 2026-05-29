import api from './api';
// ── Service ───────────────────────────────────────────────────
export const productoService = {
    async listar(filtros = {}) {
        const params = new URLSearchParams();
        if (filtros.busqueda)
            params.append('busqueda', filtros.busqueda);
        if (filtros.categoria)
            params.append('categoria', String(filtros.categoria));
        if (filtros.marca)
            params.append('marca', String(filtros.marca));
        if (filtros.estado)
            params.append('estado', filtros.estado);
        params.append('pagina', String(filtros.pagina ?? 1));
        params.append('tamano', String(filtros.tamano ?? 20));
        const { data } = await api.get(`/productos?${params.toString()}`);
        return data.data;
    },
    async obtener(id) {
        const { data } = await api.get(`/productos/${id}`);
        return data.data;
    },
    async crear(req) {
        const { data } = await api.post('/productos', req);
        return data.data;
    },
    async actualizar(id, req) {
        await api.put(`/productos/${id}`, req);
    },
    async cambiarEstado(id, req) {
        await api.patch(`/productos/${id}/estado`, req);
    },
    async asignarPrecio(id, req) {
        const { data } = await api.post(`/productos/${id}/precios`, req);
        return data.data;
    },
    async listarCategorias() {
        const { data } = await api.get('/productos/categorias');
        return data.data;
    },
    async listarMarcas() {
        const { data } = await api.get('/productos/marcas');
        return data.data;
    },
    async listarMedidas() {
        const { data } = await api.get('/productos/medidas');
        return data.data;
    },
    async listarImpuestos() {
        const { data } = await api.get('/productos/impuestos');
        return data.data;
    },
    async listarDescuentos() {
        const { data } = await api.get('/productos/descuentos');
        return data.data;
    }
};
