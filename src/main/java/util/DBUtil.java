package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Central database connection helper.
 *
 * All DAO classes call DBUtil.getConnection() instead of repeating connection code.
 * Environment variables make it easy to run the same project on different machines
 * without editing Java source code.
 */
public class DBUtil {
    // Uses DB_URL if set; otherwise connects to the local team10 database.
    private static final String URL =
            System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/team10?serverTimezone=UTC");

    // Uses DB_USER if set; otherwise defaults to root for local class demos.
    private static final String USER =
            System.getenv().getOrDefault("DB_USER", "root");

    // Uses DB_PASSWORD if set; otherwise uses the demo password from the README.
    private static final String PASSWORD =
            System.getenv().getOrDefault("DB_PASSWORD", "campusqueue123");

    static {
        try {
            // Loads the MySQL JDBC driver before any DAO tries to connect.
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        }
    }

    /** Opens and returns a new database connection. */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
