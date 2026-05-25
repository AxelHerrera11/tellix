package com.tellix.modules.venta;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class VentaService {

    private final VentaRepository repo;

    public VentaService(VentaRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<VentaDto.VentaResumen> listar(
        String cliente, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return repo.listar(cliente, estado, desde, hasta, pagina, tamano);
    }

    public VentaDto.VentaDetalle obtener(int id) {
        return repo.obtener(id)
            .orElseThrow(() -> new RecursoNoEncontradoException("Venta", id));
    }

    public int registrar(VentaDto.CrearVentaRequest req) {
        return repo.registrar(req, usuarioActual().getCodigoUsuario());
    }

    public void anular(int id, VentaDto.AnularVentaRequest req) {
        repo.anular(id, usuarioActual().getCodigoUsuario(),
            req != null ? req.motivo() : null);
    }

    public List<VentaDto.ProductoVenta> buscarProductos(String busqueda, String aplicacion) {
        return repo.buscarProductos(busqueda, aplicacion);
    }

    public List<VentaDto.ClienteVenta> buscarClientes(String busqueda) {
        return repo.buscarClientes(busqueda);
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
