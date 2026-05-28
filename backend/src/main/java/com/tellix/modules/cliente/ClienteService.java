package com.tellix.modules.cliente;

import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import org.springframework.stereotype.Service;

@Service
public class ClienteService {

    private final ClienteRepository repo;

    public ClienteService(ClienteRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<ClienteDto.ClienteResumen> listar(String busqueda, String estado, Integer tipo, int pagina, int tamano) {
        return repo.listar(busqueda, estado, tipo, pagina, tamano);
    }

    public ClienteDto.ClienteDetalle obtener(int codigo) {
        return repo.obtener(codigo)
            .orElseThrow(() -> new RecursoNoEncontradoException("Cliente", codigo));
    }

    public int crear(ClienteDto.CrearClienteRequest req) {
        return repo.crear(req);
    }

    public void actualizar(int codigo, ClienteDto.ActualizarClienteRequest req) {
        repo.actualizar(codigo, req);
    }

    public void cambiarEstado(int codigo, String estado) {
        repo.cambiarEstado(codigo, estado);
    }
}
