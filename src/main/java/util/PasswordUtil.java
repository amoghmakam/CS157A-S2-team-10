package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Small helper class for password hashing.
 *
 * This project uses SHA-256 because it is simple to explain for an intro class.
 * In a real production system, a stronger password algorithm such as bcrypt or Argon2
 * would be preferred, but SHA-256 still avoids storing readable plain-text passwords.
 */
public class PasswordUtil {

    /**
     * Converts a plain password into a SHA-256 hex string.
     * Example idea: "pass123" becomes a long unreadable hash value.
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(password.getBytes(StandardCharsets.UTF_8));

            StringBuilder hex = new StringBuilder();
            for (byte b : encodedHash) {
                String part = Integer.toHexString(0xff & b);
                if (part.length() == 1) {
                    hex.append('0');
                }
                hex.append(part);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 is not available.", e);
        }
    }

    /**
     * Hashes the password typed by the user and compares it to the stored value.
     */
    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        return hashPassword(plainPassword).equals(storedPassword);
    }
}
