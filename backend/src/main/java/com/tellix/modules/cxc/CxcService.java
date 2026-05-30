package com.tellix.modules.cxc;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class CxcService {

    private final CxcRepository repo;

    public CxcService(CxcRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<CxcDto.CxcResumen> listar(String cliente, String estado, LocalDate desde, LocalDate hasta, Boolean vencidas, int pagina, int tamano) {
        return repo.listar(cliente, estado, desde, hasta, vencidas, pagina, tamano);
    }

    public CxcDto.CxcDetalle obtener(int id) {
        return repo.obtener(id).orElseThrow(() -> new RecursoNoEncontradoException("CXC", id));
    }

    public void registrarCobro(int id, CxcDto.RegistrarCobroRequest req) {
        repo.registrarCobro(id, req, usuarioActual().getCodigoUsuario());
    }

    public void anular(int id, CxcDto.AnularCxcRequest req) {
        repo.anular(id, usuarioActual().getCodigoUsuario(), req != null ? req.motivo() : null);
    }

    public List<CxcDto.CxcVencida> vencidas(LocalDate fecha) {
        return repo.vencidas(fecha);
    }

    public CxcDto.CxcResumenFinanciero resumen() {
        return repo.resumen();
    }

    public int generarDesdeVenta(int ventaId) {
        return repo.generarDesdeVenta(ventaId);
    }

    public List<CxcDto.MetodoCobroDto> listarMetodosCobro() {
        return repo.listarMetodosCobro();
    }

    public List<CxcDto.CuentaBancariaDto> listarCuentasBancarias() {
        return repo.listarCuentasBancarias();
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
