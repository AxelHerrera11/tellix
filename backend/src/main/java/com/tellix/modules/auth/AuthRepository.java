package com.tellix.modules.auth;

import com.tellix.security.TellixUserDetails;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.util.Optional;

@Repository
public class AuthRepository {

    private final JdbcTemplate jdbc;

    public AuthRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<TellixUserDetails> login(String userName, String contrasenaHash) {
        return jdbc.execute((java.sql.Connection con) -> {
            // Usamos EXEC directo, no {call ...}
            String sql = "EXEC sp_login @p_username = ?, @p_hash = ?";
            try (CallableStatement cs = con.prepareCall(sql)) {
                cs.setString(1, userName);
                cs.setString(2, contrasenaHash);

                // Iterar todos los ResultSets hasta encontrar uno con datos
                boolean hasResult = cs.execute();
                while (true) {
                    if (hasResult) {
                        try (ResultSet rs = cs.getResultSet()) {
                            if (rs.next()) {
                                return Optional.of(new TellixUserDetails(
                                        rs.getInt("codigo"),
                                        rs.getString("user_name"),
                                        rs.getString("rol_nombre"),
                                        rs.getInt("rol_nivel"),
                                        rs.getString("nombre_empleado")
                                ));
                            }
                        }
                    }
                    // Verificar si hay más resultados
                    int updateCount = cs.getUpdateCount();
                    if (!hasResult && updateCount == -1) break;
                    hasResult = cs.getMoreResults();
                }
                return Optional.<TellixUserDetails>empty();
            }
        });
    }
}