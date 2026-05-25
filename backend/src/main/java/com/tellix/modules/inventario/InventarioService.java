package com.tellix.modules.inventario;

import com.tellix.security.TellixUserDetails;
import com.tellix.shared.dto.PagedResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class InventarioService {

    private final InventarioRepository repo;

    public InventarioService(InventarioRepository repo) {
        this.repo = repo;
    }

    public PagedResponse<InventarioDto.StockProducto> listarStock(
        String busqueda, Integer categoria, String estado,
        boolean critico, int pagina, int tamano
    ) {
        return repo.listarStock(busqueda, categoria, estado, critico, pagina, tamano);
    }

    public List<InventarioDto.StockCritico> stockCritico() {
        return repo.stockCritico();
    }

    public PagedResponse<InventarioDto.MovimientoDto> listarMovimientos(
        Integer producto, String operacion,
        LocalDate desde, LocalDate hasta,
        int pagina, int tamano
    ) {
        return repo.listarMovimientos(producto, operacion, desde, hasta, pagina, tamano);
    }

    @Transactional
    public void ajustar(InventarioDto.AjustarStockRequest req) {
        repo.ajustar(req.fkProducto(), req.cantidad(), req.motivo(), usuarioActual().getCodigoUsuario());
    }

    private TellixUserDetails usuarioActual() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (TellixUserDetails) auth.getPrincipal();
    }
}
