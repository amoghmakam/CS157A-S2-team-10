package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL =
            System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/team10?serverTimezone=UTC");
    private static final String USER =
            System.getenv().getOrDefault("DB_USER", "root");
    private static final String PASSWORD =
            System.getenv().getOrDefault("DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}