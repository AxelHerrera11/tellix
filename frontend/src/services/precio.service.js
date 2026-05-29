import api from './api';
export const precioService = {
    async listar(f = {}) {
        const p = new URLSearchParams();
        if (f.producto)
            p.append('producto', String(f.producto));
        if (f.busqueda)
            p.append('busqueda', f.busqueda);
        if (f.aplicacion)
            p.append('aplicacion', f.aplicacion);
        if (f.estado)
            p.append('estado', f.estado);
        if (f.vigentes)
            p.append('vigentes', 'true');
        if (f.fecha)
            p.append('fecha', f.fecha);
        p.append('pagina', String(f.pagina ?? 1));
        p.append('tamano', String(f.tamano ?? 20));
        const { data } = await api.get(`/precios?${p.toString()}`);
        return data.data;
    },
    async obtener(id) { const { data } = await api.get(`/precios/${id}`); return data.data; },
    async crear(req) { const { data } = await api.post('/precios', req); return data.data; },
    async actualizar(id, req) { await api.put(`/precios/${id}`, req); },
    async cambiarEstado(id, estado) { await api.patch(`/precios/${id}/estado`, { estado }); },
    async obtenerVigente(producto, aplicacion, fecha) {
        const p = new URLSearchParams();
        p.append('producto', String(producto));
        if (aplicacion)
            p.append('aplicacion', aplicacion);
        if (fecha)
            p.append('fecha', fecha);
        const { data } = await api.get(`/precios/vigente?${p.toString()}`);
        return data.data;
    },
    async listarProductos() { const { data } = await api.get('/precios/catalogos/productos'); return data.data; }
};
