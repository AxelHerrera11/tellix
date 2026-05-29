package com.tellix.modules.cxp;

import com.tellix.shared.dto.ApiResponse;
import com.tellix.shared.dto.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/cxp")
@Tag(name = "CXP", description = "Gestión de cuentas por pagar")
@SecurityRequirement(name = "bearerAuth")
public class CxpController {

    private final CxpService service;

    public CxpController(CxpService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Listar cuentas por pagar", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<CxpDto.CxpResumen>>> listar(
        @RequestParam(required = false) String proveedor,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(proveedor, estado, desde, hasta, pagina, tamano)
        ));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Obtener cuenta por pagar", description = "Devuelve detalle de una cuenta por pagar.")
    public ResponseEntity<ApiResponse<CxpDto.CxpDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }

    @PostMapping("/{id}/pagos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Registrar pago", description = "Registra un abono a la cuenta por pagar.")
    public ResponseEntity<ApiResponse<Void>> registrarPago(
        @PathVariable int id,
        @Valid @RequestBody CxpDto.RegistrarPagoRequest req
    ) {
        service.registrarPago(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Pago registrado correctamente.", null));
    }

    @PatchMapping("/{id}/anular")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Anular cuenta por pagar", description = "Anula la cuenta por pagar.")
    public ResponseEntity<ApiResponse<Void>> anular(
        @PathVariable int id,
        @RequestBody(required = false) CxpDto.AnularCxpRequest req
    ) {
        service.anular(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Cuenta por pagar anulada correctamente.", null));
    }

    @GetMapping("/reporte/vencidas")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Reporte de CXP vencidas", description = "Lista cuentas por pagar vencidas.")
    public ResponseEntity<ApiResponse<List<CxpDto.CxpVencida>>> reporteVencidas(
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.reporteVencidas(fecha)));
    }
}
