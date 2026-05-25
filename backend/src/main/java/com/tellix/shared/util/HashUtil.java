package com.tellix.shared.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public final class HashUtil {

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    private HashUtil() {}

    public static String hash(String raw) {
        return encoder.encode(raw);
    }

    public static boolean matches(String raw, String hashed) {
        return encoder.matches(raw, hashed);
    }

    /**
     * Hash SHA-256 simple en hex — usado para el hash que envía el frontend
     * antes de que llegue al BCrypt del backend.
     */
    public static String sha256Hex(String input) {
        try {
            var digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            var sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 no disponible", e);
        }
    }
}
