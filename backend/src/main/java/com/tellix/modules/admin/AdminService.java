package com.tellix.modules.admin;

import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    private final AdminRepository repo;

    public AdminService(AdminRepository repo) {
        this.repo = repo;
    }

    public List<AdminDto.UsuarioResumen> listarUsuarios() {
        return repo.listarUsuarios();
    }

    public List<AdminDto.RolResumen> listarRoles() {
        return repo.listarRoles();
    }
 public int crearUsuario(AdminDto.CrearUsuarioRequest req) {
        return repo.crearUsuario(req);
    }

    public List<AdminDto.AuditoriaResumen> listarAuditoria() {
        return repo.listarAuditoria();
    }

}
