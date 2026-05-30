package com.tellix.modules.compra;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class CompraService {

    private final CompraRepository repo;

    public CompraService(CompraRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<CompraDto.CompraResumen> listar(
        String proveedor, String estado,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return repo.listar(proveedor, estado, desde, hasta, pagina, tamano);
    }

    public CompraDto.CompraDetalle obtener(int id) {
        return repo.obtener(id)
            .orElseThrow(() -> new RecursoNoEncontradoException("Compra", id));
    }

    public int registrar(CompraDto.CrearCompraRequest req) {
        return repo.registrar(req, usuarioActual().getCodigoUsuario());
    }

    public void anular(int id, CompraDto.AnularCompraRequest req) {
        repo.anular(id, usuarioActual().getCodigoUsuario(),
            req != null ? req.motivo() : null);
    }

    public List<CompraDto.ProductoCompra> buscarProductos(String busqueda) {
        return repo.buscarProductos(busqueda);
    }

    public List<CompraDto.ProveedorCompra> buscarProveedores(String busqueda) {
        return repo.buscarProveedores(busqueda);
    }

    public List<CompraDto.RepresentanteCompra> listarRepresentantes(String proveedor) {
        return repo.listarRepresentantes(proveedor);
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
