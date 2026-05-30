package com.tellix.modules.cxc;

import com.tellix.shared.dto.ApiResponse;
import com.tellix.shared.dto.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/cxc")
@Tag(name = "Cuentas por cobrar", description = "Gestion de CXC")
@SecurityRequirement(name = "bearerAuth")
public class CxcController {

    private final CxcService service;

    public CxcController(CxcService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Listar CXC")
    public ResponseEntity<ApiResponse<PagedResponse<CxcDto.CxcResumen>>> listar(
        @RequestParam(required = false) String cliente,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(required = false) Boolean vencidas,
        @RequestParam(defaultValue = "1") int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.listar(cliente, estado, desde, hasta, vencidas, pagina, tamano)));
    }

    @PostMapping("/{id}/cobros")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Registrar cobro")
    public ResponseEntity<ApiResponse<Void>> registrarCobro(@PathVariable int id, @Valid @RequestBody CxcDto.RegistrarCobroRequest req) {
        service.registrarCobro(id, req);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Cobro registrado correctamente.", null));
    }

    @PatchMapping("/{id}/anular")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Anular CXC")
    public ResponseEntity<ApiResponse<Void>> anular(@PathVariable int id, @RequestBody(required = false) CxcDto.AnularCxcRequest req) {
        service.anular(id, req);
        return ResponseEntity.ok(ApiResponse.ok("CXC anulada correctamente.", null));
    }

    @GetMapping("/vencidas")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Consultar CXC vencidas")
    public ResponseEntity<ApiResponse<List<CxcDto.CxcVencida>>> vencidas(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        return ResponseEntity.ok(ApiResponse.ok(service.vencidas(fecha)));
    }

    @GetMapping("/resumen")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Resumen CXC")
    public ResponseEntity<ApiResponse<CxcDto.CxcResumenFinanciero>> resumen() {
        return ResponseEntity.ok(ApiResponse.ok(service.resumen()));
    }

    @PostMapping("/generar-desde-venta/{ventaId}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Generar CXC desde venta")
    public ResponseEntity<ApiResponse<Integer>> generarDesdeVenta(@PathVariable int ventaId) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("CXC generada correctamente.", service.generarDesdeVenta(ventaId)));
    }

    @GetMapping("/catalogos/metodos-cobro")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Catalogo metodos cobro")
    public ResponseEntity<ApiResponse<List<CxcDto.MetodoCobroDto>>> listarMetodosCobro() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarMetodosCobro()));
    }

    @GetMapping("/catalogos/cuentas-bancarias")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Catalogo cuentas bancarias")
    public ResponseEntity<ApiResponse<List<CxcDto.CuentaBancariaDto>>> listarCuentasBancarias() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarCuentasBancarias()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Obtener CXC")
    public ResponseEntity<ApiResponse<CxcDto.CxcDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }
}
