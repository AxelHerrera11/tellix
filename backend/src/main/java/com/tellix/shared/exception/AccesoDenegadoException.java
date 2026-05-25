package com.tellix.shared.exception;

import org.springframework.http.HttpStatus;

public class AccesoDenegadoException extends TellixException {
    public AccesoDenegadoException() {
        super("No tiene permisos para realizar esta operación.", HttpStatus.FORBIDDEN);
    }
    public AccesoDenegadoException(String mensaje) {
        super(mensaje, HttpStatus.FORBIDDEN);
    }
}
