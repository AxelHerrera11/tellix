package com.tellix.modules.cxp;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class CxpService {

    private final CxpRepository repo;

    public CxpService(CxpRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<CxpDto.CxpResumen> listar(String proveedor, String estado, LocalDate desde, LocalDate hasta, Boolean vencidas, int pagina, int tamano) {
        return repo.listar(proveedor, estado, desde, hasta, vencidas, pagina, tamano);
    }

    public CxpDto.CxpDetalle obtener(int id) {
        return repo.obtener(id).orElseThrow(() -> new RecursoNoEncontradoException("CXP", id));
    }

    public void registrarPago(int id, CxpDto.RegistrarPagoRequest req) {
        repo.registrarPago(id, req, usuarioActual().getCodigoUsuario());
    }

    public void anular(int id, CxpDto.AnularCxpRequest req) {
        repo.anular(id, usuarioActual().getCodigoUsuario(), req != null ? req.motivo() : null);
    }

    public List<CxpDto.CxpResumen> vencidas(LocalDate fecha) {
        return repo.vencidas(fecha);
    }

    public CxpDto.CxpResumenFinanciero resumen() {
        return repo.resumen();
    }

    public int generarDesdeCompra(int compraId) {
        return repo.generarDesdeCompra(compraId);
    }

    public List<CxpDto.MetodoPagoDto> listarMetodosPago() {
        return repo.listarMetodosPago();
    }

    public List<CxpDto.CuentaBancariaDto> listarCuentasBancarias() {
        return repo.listarCuentasBancarias();
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
