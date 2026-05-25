package com.tellix.shared.dto;

import java.util.List;

public record PagedResponse<T>(
    List<T> data,
    int pagina,
    int tamano,
    long total,
    int totalPaginas
) {
    public static <T> PagedResponse<T> of(List<T> data, int pagina, int tamano, long total) {
        int totalPaginas = (int) Math.ceil((double) total / tamano);
        return new PagedResponse<>(data, pagina, tamano, total, totalPaginas);
    }
}
