package com.tellix.modules.cxp;

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
@RequestMapping("/api/cxp")
@Tag(name = "Cuentas por pagar", description = "Gestion de CXP")
@SecurityRequirement(name = "bearerAuth")
public class CxpController {

    private final CxpService service;

    public CxpController(CxpService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Listar CXP", description = "Listado paginado de cuentas por pagar con filtros.")
    public ResponseEntity<ApiResponse<PagedResponse<CxpDto.CxpResumen>>> listar(
        @RequestParam(required = false) String proveedor,
        @RequestParam(required = false) String estado,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
        @RequestParam(required = false) Boolean vencidas,
        @RequestParam(defaultValue = "1") int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.listar(proveedor, estado, desde, hasta, vencidas, pagina, tamano)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Obtener CXP", description = "Detalle de una cuenta por pagar incluyendo movimientos.")
    public ResponseEntity<ApiResponse<CxpDto.CxpDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }

    @PostMapping("/{id}/pagos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Registrar pago", description = "Registra un abono en una cuenta por pagar.")
    public ResponseEntity<ApiResponse<Void>> registrarPago(@PathVariable int id, @Valid @RequestBody CxpDto.RegistrarPagoRequest req) {
        service.registrarPago(id, req);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Pago registrado correctamente.", null));
    }

    @PatchMapping("/{id}/anular")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Anular CXP", description = "Anula una cuenta por pagar sin pagos aplicados.")
    public ResponseEntity<ApiResponse<Void>> anular(@PathVariable int id, @RequestBody(required = false) CxpDto.AnularCxpRequest req) {
        service.anular(id, req);
        return ResponseEntity.ok(ApiResponse.ok("CXP anulada correctamente.", null));
    }

    @GetMapping("/vencidas")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Consultar CXP vencidas", description = "Devuelve las cuentas por pagar vencidas con saldo pendiente.")
    public ResponseEntity<ApiResponse<List<CxpDto.CxpResumen>>> vencidas(
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha
    ) {
        return ResponseEntity.ok(ApiResponse.ok(service.vencidas(fecha)));
    }

    @GetMapping("/resumen")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Resumen financiero CXP", description = "Totales y conteos del estado financiero de CXP.")
    public ResponseEntity<ApiResponse<CxpDto.CxpResumenFinanciero>> resumen() {
        return ResponseEntity.ok(ApiResponse.ok(service.resumen()));
    }

    @PostMapping("/generar-desde-compra/{compraId}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Generar CXP desde compra", description = "Genera una cuenta por pagar a partir de una compra existente.")
    public ResponseEntity<ApiResponse<Integer>> generarDesdeCompra(@PathVariable int compraId) {
        int id = service.generarDesdeCompra(compraId);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("CXP generada correctamente.", id));
    }

    @GetMapping("/catalogos/metodos-pago")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Catalogo de metodos de pago", description = "Lista metodos de pago activos para CXP.")
    public ResponseEntity<ApiResponse<List<CxpDto.MetodoPagoDto>>> listarMetodosPago() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarMetodosPago()));
    }

    @GetMapping("/catalogos/cuentas-bancarias")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','CONTADOR')")
    @Operation(summary = "Catalogo de cuentas bancarias", description = "Lista cuentas bancarias activas y sus bancos.")
    public ResponseEntity<ApiResponse<List<CxpDto.CuentaBancariaDto>>> listarCuentasBancarias() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarCuentasBancarias()));
    }
}
