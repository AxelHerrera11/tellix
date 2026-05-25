package com.tellix.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public class TellixUserDetails implements UserDetails {

    private final int codigoUsuario;
    private final String userName;
    private final String rol;
    private final int nivel;
    private final String nombreEmpleado;

    public TellixUserDetails(int codigoUsuario, String userName,
                              String rol, int nivel, String nombreEmpleado) {
        this.codigoUsuario   = codigoUsuario;
        this.userName        = userName;
        this.rol             = rol;
        this.nivel           = nivel;
        this.nombreEmpleado  = nombreEmpleado;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + rol.toUpperCase()));
    }

    @Override public String getPassword()  { return null; }
    @Override public String getUsername()  { return userName; }
    @Override public boolean isAccountNonExpired()    { return true; }
    @Override public boolean isAccountNonLocked()     { return true; }
    @Override public boolean isCredentialsNonExpired(){ return true; }
    @Override public boolean isEnabled()              { return true; }

    public int    getCodigoUsuario()   { return codigoUsuario; }
    public String getRol()             { return rol; }
    public int    getNivel()           { return nivel; }
    public String getNombreEmpleado()  { return nombreEmpleado; }
}
