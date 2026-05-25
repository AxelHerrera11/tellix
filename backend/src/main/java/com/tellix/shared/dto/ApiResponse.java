package com.tellix.shared.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Envoltorio genérico para todas las respuestas del API.
 * Uso: ApiResponse.ok(data) / ApiResponse.error("mensaje")
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
    boolean ok,
    String mensaje,
    T data
) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, null, data);
    }

    public static <T> ApiResponse<T> ok(String mensaje, T data) {
        return new ApiResponse<>(true, mensaje, data);
    }

    public static <T> ApiResponse<T> error(String mensaje) {
        return new ApiResponse<>(false, mensaje, null);
    }
}
