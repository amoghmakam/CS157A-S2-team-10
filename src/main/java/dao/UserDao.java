package dao;

import model.User;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class UserDao {

    public User login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM Users WHERE email = ? AND password = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                User user = new User();
                int userId = rs.getInt("userID");

                user.setUserId(userId);
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(getUserRole(conn, userId));

                return user;
            }
        }
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT * FROM Users WHERE email = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public int registerStudent(String firstName, String lastName, String email, String password,
                               String major, String grade) throws SQLException {
        String insertUser = "INSERT INTO Users(firstName, lastName, email, password) VALUES (?, ?, ?, ?)";
        String insertStudent = "INSERT INTO Student(studentID, major, grade) VALUES (?, ?, ?)";
        String insertIsA = "INSERT INTO IsA(userID, studentID, staffID, adminID) VALUES (?, ?, NULL, NULL)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement userPs = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                userPs.setString(1, firstName);
                userPs.setString(2, lastName);
                userPs.setString(3, email);
                userPs.setString(4, password);
                userPs.executeUpdate();

                int userId;
                try (ResultSet keys = userPs.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("Could not get new user ID.");
                    }
                    userId = keys.getInt(1);
                }

                try (PreparedStatement studentPs = conn.prepareStatement(insertStudent)) {
                    studentPs.setInt(1, userId);
                    studentPs.setString(2, major);
                    studentPs.setString(3, grade);
                    studentPs.executeUpdate();
                }

                try (PreparedStatement isaPs = conn.prepareStatement(insertIsA)) {
                    isaPs.setInt(1, userId);
                    isaPs.setInt(2, userId);
                    isaPs.executeUpdate();
                }

                conn.commit();
                return userId;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private String getUserRole(Connection conn, int userId) throws SQLException {
        if (existsInTable(conn, "Admin", "adminID", userId)) {
            return "ADMIN";
        }
        if (existsInTable(conn, "Staff", "staffID", userId)) {
            return "STAFF";
        }
        if (existsInTable(conn, "Student", "studentID", userId)) {
            return "STUDENT";
        }
        return "GUEST";
    }

    private boolean existsInTable(Connection conn, String tableName, String columnName, int userId) throws SQLException {
        String sql = "SELECT * FROM " + tableName + " WHERE " + columnName + " = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}