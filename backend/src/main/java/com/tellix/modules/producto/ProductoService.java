package com.tellix.modules.producto;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProductoService {

    private final ProductoRepository repo;

    public ProductoService(ProductoRepository repo) {
        this.repo = repo;
    }

    // ── CRUD producto ─────────────────────────────────────────
    public PagedResponse<ProductoDto.ProductoResumen> listar(
        String busqueda, Integer categoria, Integer marca,
        String estado, int pagina, int tamano
    ) {
        return repo.listar(busqueda, categoria, marca, estado, pagina, tamano);
    }

    public ProductoDto.ProductoDetalle obtener(int id) {
        return repo.obtener(id)
            .orElseThrow(() -> new RecursoNoEncontradoException("Producto", id));
    }

    @Transactional
    public int crear(ProductoDto.CrearProductoRequest req) {
        return repo.crear(req, usuarioActual().getCodigoUsuario());
    }

    @Transactional
    public void actualizar(int id, ProductoDto.ActualizarProductoRequest req) {
        ProductoDto.ProductoDetalle existente = obtener(id);
        repo.actualizar(id, req);
    }

    @Transactional
    public void cambiarEstado(int id, ProductoDto.CambiarEstadoRequest req) {
        ProductoDto.ProductoDetalle existente = obtener(id);
        repo.cambiarEstado(id, req);
    }

    @Transactional
    public int asignarPrecio(int productoId, ProductoDto.AsignarPrecioRequest req) {
        ProductoDto.ProductoDetalle existente = obtener(productoId);
        return repo.asignarPrecio(productoId, req, usuarioActual().getCodigoUsuario());
    }

    // ── Catálogos auxiliares ──────────────────────────────────
    public List<ProductoDto.CategoriaDto> listarCategorias() {
        return repo.listarCategorias();
    }

    public List<ProductoDto.MarcaDto> listarMarcas() {
        return repo.listarMarcas();
    }

    public List<ProductoDto.MedidaDto> listarMedidas() {
        return repo.listarMedidas();
    }

    public List<ProductoDto.ImpuestoDto> listarImpuestos() {
        return repo.listarImpuestos();
    }

    public List<ProductoDto.DescuentoDto> listarDescuentos() {
        return repo.listarDescuentos();
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
