package com.tellix.modules.producto;

import com.tellix.shared.dto.ApiResponse;
import com.tellix.shared.dto.PagedResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
@Tag(name = "Productos", description = "Gestión de productos y catálogos")
@SecurityRequirement(name = "bearerAuth")
public class ProductoController {

    private final ProductoService service;

    public ProductoController(ProductoService service) {
        this.service = service;
    }

    // ── CRUD producto ─────────────────────────────────────────

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar productos", description = "Listado paginado con filtros opcionales.")
    public ResponseEntity<ApiResponse<PagedResponse<ProductoDto.ProductoResumen>>> listar(
        @RequestParam(required = false) String busqueda,
        @RequestParam(required = false) Integer categoria,
        @RequestParam(required = false) Integer marca,
        @RequestParam(required = false) String estado,
        @RequestParam(defaultValue = "1")  int pagina,
        @RequestParam(defaultValue = "20") int tamano
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            service.listar(busqueda, categoria, marca, estado, pagina, tamano)
        ));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Obtener producto", description = "Devuelve el detalle completo de un producto.")
    public ResponseEntity<ApiResponse<ProductoDto.ProductoDetalle>> obtener(@PathVariable int id) {
        return ResponseEntity.ok(ApiResponse.ok(service.obtener(id)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Crear producto", description = "Crea un nuevo producto con precio inicial opcional.")
    public ResponseEntity<ApiResponse<Integer>> crear(
        @Valid @RequestBody ProductoDto.CrearProductoRequest req
    ) {
        int id = service.crear(req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Producto creado correctamente.", id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Actualizar producto", description = "Actualiza los datos generales del producto.")
    public ResponseEntity<ApiResponse<Void>> actualizar(
        @PathVariable int id,
        @Valid @RequestBody ProductoDto.ActualizarProductoRequest req
    ) {
        service.actualizar(id, req);
        return ResponseEntity.ok(ApiResponse.ok("Producto actualizado correctamente.", null));
    }

    @PatchMapping("/{id}/estado")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Cambiar estado", description = "Activa o inactiva un producto.")
    public ResponseEntity<ApiResponse<Void>> cambiarEstado(
        @PathVariable int id,
        @Valid @RequestBody ProductoDto.CambiarEstadoRequest req
    ) {
        service.cambiarEstado(id, req);
        return ResponseEntity.ok(ApiResponse.ok(
            "A".equals(req.estado()) ? "Producto activado." : "Producto desactivado.",
            null
        ));
    }

    @PostMapping("/{id}/precios")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR')")
    @Operation(summary = "Asignar precio", description = "Registra un nuevo precio para el producto.")
    public ResponseEntity<ApiResponse<Integer>> asignarPrecio(
        @PathVariable int id,
        @Valid @RequestBody ProductoDto.AsignarPrecioRequest req
    ) {
        int precioId = service.asignarPrecio(id, req);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok("Precio asignado correctamente.", precioId));
    }

    // ── Catálogos auxiliares ──────────────────────────────────

    @GetMapping("/categorias")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar categorías", description = "Devuelve el listado de categorías activas.")
    public ResponseEntity<ApiResponse<List<ProductoDto.CategoriaDto>>> listarCategorias() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarCategorias()));
    }

    @GetMapping("/marcas")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar marcas", description = "Devuelve el listado de marcas activas.")
    public ResponseEntity<ApiResponse<List<ProductoDto.MarcaDto>>> listarMarcas() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarMarcas()));
    }

    @GetMapping("/medidas")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar medidas", description = "Devuelve el listado de unidades de medida.")
    public ResponseEntity<ApiResponse<List<ProductoDto.MedidaDto>>> listarMedidas() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarMedidas()));
    }

    @GetMapping("/impuestos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar impuestos", description = "Devuelve el listado de impuestos activos.")
    public ResponseEntity<ApiResponse<List<ProductoDto.ImpuestoDto>>> listarImpuestos() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarImpuestos()));
    }

    @GetMapping("/descuentos")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','VENDEDOR','CONTADOR')")
    @Operation(summary = "Listar descuentos", description = "Devuelve el listado de descuentos activos.")
    public ResponseEntity<ApiResponse<List<ProductoDto.DescuentoDto>>> listarDescuentos() {
        return ResponseEntity.ok(ApiResponse.ok(service.listarDescuentos()));
    }
}
