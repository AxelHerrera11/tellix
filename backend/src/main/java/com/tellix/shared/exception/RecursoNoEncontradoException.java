package com.tellix.shared.exception;

import org.springframework.http.HttpStatus;

public class RecursoNoEncontradoException extends TellixException {
    public RecursoNoEncontradoException(String recurso, Object id) {
        super(recurso + " con id '" + id + "' no encontrado.", HttpStatus.NOT_FOUND);
    }
}
