package com.tellix.modules.reporte;

import org.springframework.stereotype.Service;

@Service
public class ReporteService {

    private final ReporteRepository repo;

    public ReporteService(ReporteRepository repo) {
        this.repo = repo;
    }

    public ReporteDto.ResumenGeneral obtenerResumenGeneral() {
        return repo.obtenerResumenGeneral();
    }
}
