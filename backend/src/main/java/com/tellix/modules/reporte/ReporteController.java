package com.tellix.modules.reporte;

import com.tellix.shared.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
@Tag(name = "Reportes", description = "Reportes generales del sistema")
@SecurityRequirement(name = "bearerAuth")
public class ReporteController {

    private final ReporteService service;

    public ReporteController(ReporteService service) {
        this.service = service;
    }

    @GetMapping("/resumen")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Resumen general", description = "Devuelve totales principales del sistema.")
    public ResponseEntity<ApiResponse<ReporteDto.ResumenGeneral>> obtenerResumenGeneral() {
        return ResponseEntity.ok(ApiResponse.ok(service.obtenerResumenGeneral()));
    }
}
