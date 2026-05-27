import api from './api';
import { sha256 } from 'js-sha256';
/**
 * Hashea la contraseña en el cliente antes de enviarla.
 * El backend valida contra el hash almacenado en BD.
 */
export function hashPassword(password) {
    return sha256(password);
}
export const authService = {
    async login(userName, password) {
        const req = {
            userName,
            contrasenaHash: hashPassword(password)
        };
        const { data } = await api.post('/auth/login', req);
        return data.data;
    },
    async logout() {
        await api.post('/auth/logout');
    },
    async refresh(refreshToken) {
        const { data } = await api.post('/auth/refresh', null, {
            headers: { 'X-Refresh-Token': refreshToken }
        });
        return data.data;
    }
};
