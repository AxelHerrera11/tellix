package com.tellix.modules.reporte;

import java.math.BigDecimal;

public class ReporteDto {

    public record ResumenGeneral(
        Integer totalProductos,
        Integer totalClientes,
        Integer totalProveedores,
        Integer totalVentas,
        Integer totalCompras,
        Integer cxcPendientes,
        Integer cxpPendientes,
        BigDecimal montoCxcPendiente,
        BigDecimal montoCxpPendiente
    ) {}
}
