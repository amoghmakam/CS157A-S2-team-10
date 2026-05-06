package dao;

import model.User;
import util.DBUtil;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    /**
     * Logs a user in by email and password.
     *
     * The original class project stored sample passwords as plain text.
     * To keep the demo accounts working while improving security, this method:
     * 1. finds the user by email,
     * 2. blocks suspended users,
     * 3. accepts a SHA-256 hashed password,
     * 4. also accepts old plain-text sample passwords and upgrades them to a hash.
     */
    public User login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM Users WHERE email = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                String storedPassword = rs.getString("password");
                boolean hashedMatch = PasswordUtil.verifyPassword(password, storedPassword);
                boolean legacyPlainTextMatch = password.equals(storedPassword);

                if (!hashedMatch && !legacyPlainTextMatch) {
                    return null;
                }

                String accountStatus = getOptionalString(rs, "accountStatus", "ACTIVE");
                if ("SUSPENDED".equalsIgnoreCase(accountStatus)) {
                    return null;
                }

                int userId = rs.getInt("userID");

                // Simple migration path: if an old plain-text password worked, store it as a hash now.
                if (legacyPlainTextMatch) {
                    updatePasswordHash(conn, userId, PasswordUtil.hashPassword(password));
                }

                User user = new User();
                user.setUserId(userId);
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
                user.setEmail(rs.getString("email"));
                user.setPassword("[protected]");
                user.setRole(getUserRole(conn, userId));
                user.setAccountStatus(accountStatus);

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

    /**
     * Creates a new student account.
     * New passwords are always stored as SHA-256 hashes instead of plain text.
     */
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
                userPs.setString(4, PasswordUtil.hashPassword(password));
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


    /**
     * Returns every user in the application with role, account status, and staff assignment summary.
     * Admin dashboard uses this for user moderation and verification.
     */
    public List<User> getAllUsersWithRolesAndAssignments() throws SQLException {
        List<User> users = new ArrayList<>();

        String sql =
            "SELECT " +
            "u.userID, u.firstName, u.lastName, u.email, " +
            "COALESCE(u.accountStatus, 'ACTIVE') AS accountStatus, " +
            "CASE " +
            "  WHEN a.adminID IS NOT NULL THEN 'ADMIN' " +
            "  WHEN sf.staffID IS NOT NULL THEN 'STAFF' " +
            "  WHEN st.studentID IS NOT NULL THEN 'STUDENT' " +
            "  ELSE 'GUEST' " +
            "END AS roleName, " +
            "CASE " +
            "  WHEN sf.staffID IS NULL THEN 'N/A' " +
            "  WHEN COUNT(sa.assignmentID) = 0 THEN 'Unassigned' " +
            "  ELSE GROUP_CONCAT(sa.serviceName ORDER BY sa.serviceName SEPARATOR ', ') " +
            "END AS staffAssignments " +
            "FROM Users u " +
            "LEFT JOIN Student st ON u.userID = st.studentID " +
            "LEFT JOIN Staff sf ON u.userID = sf.staffID " +
            "LEFT JOIN Admin a ON u.userID = a.adminID " +
            "LEFT JOIN StaffAssignment sa ON sf.staffID = sa.staffID " +
            "GROUP BY u.userID, u.firstName, u.lastName, u.email, u.accountStatus, " +
            "         st.studentID, sf.staffID, a.adminID " +
            "ORDER BY u.userID";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("userID"));
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
                user.setEmail(rs.getString("email"));
                user.setPassword("[protected]");
                user.setAccountStatus(rs.getString("accountStatus"));
                user.setRole(rs.getString("roleName"));
                user.setStaffAssignments(rs.getString("staffAssignments"));
                users.add(user);
            }
        }

        return users;
    }

    public void updateAccountStatus(int userId, String accountStatus) throws SQLException {
        String sql = "UPDATE Users SET accountStatus = ? WHERE userID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, accountStatus);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private void updatePasswordHash(Connection conn, int userId, String hashedPassword) throws SQLException {
        String sql = "UPDATE Users SET password = ? WHERE userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();
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

    private String getOptionalString(ResultSet rs, String columnName, String defaultValue) {
        try {
            String value = rs.getString(columnName);
            return value == null ? defaultValue : value;
        } catch (SQLException e) {
            return defaultValue;
        }
    }
}
