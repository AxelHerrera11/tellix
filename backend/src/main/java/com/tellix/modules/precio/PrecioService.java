package com.tellix.modules.precio;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import com.tellix.shared.exception.RecursoNoEncontradoException;
import com.tellix.shared.exception.TellixException;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class PrecioService {

    private final PrecioRepository repo;

    public PrecioService(PrecioRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<PrecioDto.PrecioResumen> listar(Integer producto, String busqueda, String aplicacion, String estado, Boolean vigentes, LocalDate fecha, int pagina, int tamano) {
        return repo.listar(producto, busqueda, aplicacion, estado, vigentes, fecha, pagina, tamano);
    }

    public PrecioDto.PrecioDetalle obtener(int id) {
        return repo.obtener(id).orElseThrow(() -> new RecursoNoEncontradoException("Precio", id));
    }

    public int crear(PrecioDto.CrearPrecioRequest req) {
        return repo.crear(req, usuarioActual().getCodigoUsuario());
    }

    public void actualizar(int id, PrecioDto.ActualizarPrecioRequest req) {
        if (req.finVigencia() != null && req.finVigencia().isBefore(req.inicioVigencia())) {
            throw new TellixException("La fecha fin no puede ser menor a la fecha inicio.", HttpStatus.BAD_REQUEST);
        }
        repo.actualizar(id, req);
    }

    public void cambiarEstado(int id, PrecioDto.CambiarEstadoPrecioRequest req) {
        repo.cambiarEstado(id, req.estado());
    }

    public PrecioDto.PrecioResumen obtenerVigente(int producto, String aplicacion, LocalDate fecha) {
        return repo.obtenerVigente(producto, aplicacion, fecha).orElseThrow(() -> new TellixException("No existe precio vigente para los parametros indicados.", HttpStatus.NOT_FOUND));
    }

    public List<PrecioDto.ProductoPrecioDto> listarProductos() {
        return repo.listarProductos();
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
