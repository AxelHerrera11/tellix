package com.tellix.modules.cxp;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class CxpService {

    private final CxpRepository repo;

    public CxpService(CxpRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<CxpDto.CxpResumen> listar(
        String proveedor, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return repo.listar(proveedor, estado, desde, hasta, pagina, tamano);
    }

    public CxpDto.CxpDetalle obtener(int id) {
        return repo.obtener(id)
            .orElseThrow(() -> new RecursoNoEncontradoException("Cuenta por pagar", id));
    }

    public void registrarPago(int id, CxpDto.RegistrarPagoRequest req) {
        repo.registrarPago(id, req.monto(), usuarioActual().getCodigoUsuario(), req.descripcion());
    }

    public void anular(int id, CxpDto.AnularCxpRequest req) {
        repo.anular(id, usuarioActual().getCodigoUsuario(),
            req != null ? req.motivo() : null);
    }

    public List<CxpDto.CxpVencida> reporteVencidas(LocalDate fecha) {
        return repo.reporteVencidas(fecha);
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
