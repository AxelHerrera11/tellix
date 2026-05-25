package com.tellix.shared.exception;

import org.springframework.http.HttpStatus;

public class TellixException extends RuntimeException {

    private final HttpStatus status;

    public TellixException(String mensaje, HttpStatus status) {
        super(mensaje);
        this.status = status;
    }

    public HttpStatus getStatus() { return status; }
}
