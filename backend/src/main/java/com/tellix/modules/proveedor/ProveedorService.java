package com.tellix.modules.proveedor;

import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.stereotype.Service;

@Service
public class ProveedorService {

    private final ProveedorRepository repo;

    public ProveedorService(ProveedorRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<ProveedorDto.ProveedorResumen> listar(String busqueda, String estado, int pagina, int tamano) {
        return repo.listar(busqueda, estado, pagina, tamano);
    }

    public ProveedorDto.ProveedorDetalle obtener(String nit) {
        return repo.obtener(nit)
            .orElseThrow(() -> new RecursoNoEncontradoException("Proveedor", nit));
    }

    public void crear(ProveedorDto.CrearProveedorRequest req) {
        repo.crear(req);
    }

    public void actualizar(String nit, ProveedorDto.ActualizarProveedorRequest req) {
        repo.actualizar(nit, req);
    }

    public void cambiarEstado(String nit, String estado) {
        repo.cambiarEstado(nit, estado);
    }
}
