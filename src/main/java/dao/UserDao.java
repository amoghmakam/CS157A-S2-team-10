package dao;

import model.User;
import util.DBUtil;

import java.sql.*;

public class UserDao {

    public User login(String email, String password) throws SQLException {
        String sql = "SELECT userID, firstName, lastName, email, password FROM Users WHERE email = ? AND password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                User user = new User();
                user.setUserId(rs.getInt("userID"));
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(resolveRole(conn, user.getUserId()));
                return user;
            }
        }
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE email = ?";
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
            try (PreparedStatement psUser = conn.prepareStatement(insertUser, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, firstName);
                psUser.setString(2, lastName);
                psUser.setString(3, email);
                psUser.setString(4, password);
                psUser.executeUpdate();

                int userId;
                try (ResultSet keys = psUser.getGeneratedKeys()) {
                    keys.next();
                    userId = keys.getInt(1);
                }

                try (PreparedStatement psStudent = conn.prepareStatement(insertStudent)) {
                    psStudent.setInt(1, userId);
                    psStudent.setString(2, major);
                    psStudent.setString(3, grade);
                    psStudent.executeUpdate();
                }

                try (PreparedStatement psIsA = conn.prepareStatement(insertIsA)) {
                    psIsA.setInt(1, userId);
                    psIsA.setInt(2, userId);
                    psIsA.executeUpdate();
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

    private String resolveRole(Connection conn, int userId) throws SQLException {
        if (existsIn(conn, "Admin", "adminID", userId)) return "ADMIN";
        if (existsIn(conn, "Staff", "staffID", userId)) return "STAFF";
        if (existsIn(conn, "Student", "studentID", userId)) return "STUDENT";
        return "GUEST";
    }

    private boolean existsIn(Connection conn, String table, String column, int userId) throws SQLException {
        String sql = "SELECT 1 FROM " + table + " WHERE " + column + " = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
