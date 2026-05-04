package dao;

import model.AuditLog;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AdminDao {

    /**
     * Assigns a staff member to a service.
     * StaffAssignment is the main table, and AssignedTo/Covers/Manages keep the ERD relationship tables updated.
     */
    public void assignStaff(int staffId, String serviceName) throws SQLException {
        String insertAssignment = "INSERT INTO StaffAssignment(staffID, serviceName, dateAssigned) VALUES (?, ?, CURDATE())";
        String insertAssignedTo = "INSERT INTO AssignedTo(staffID, assignmentID) VALUES (?, ?)";
        String insertCovers = "INSERT INTO Covers(serviceName, assignmentID) VALUES (?, ?)";
        String insertManages = "INSERT IGNORE INTO Manages(staffID, serviceName) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int assignmentId;
                try (PreparedStatement ps = conn.prepareStatement(insertAssignment, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, staffId);
                    ps.setString(2, serviceName);
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Could not get assignment ID.");
                        }
                        assignmentId = keys.getInt(1);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(insertAssignedTo)) {
                    ps.setInt(1, staffId);
                    ps.setInt(2, assignmentId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(insertCovers)) {
                    ps.setString(1, serviceName);
                    ps.setInt(2, assignmentId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(insertManages)) {
                    ps.setInt(1, staffId);
                    ps.setString(2, serviceName);
                    ps.executeUpdate();
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public List<AuditLog> getAuditLogs() throws SQLException {
        String sql = "SELECT auditID, userID, actionType, actionDescription, actionTime FROM AuditLog ORDER BY actionTime DESC";
        List<AuditLog> logs = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                logs.add(new AuditLog(
                        rs.getInt("auditID"),
                        rs.getInt("userID"),
                        rs.getString("actionType"),
                        rs.getString("actionDescription"),
                        rs.getTimestamp("actionTime")
                ));
            }
        }
        return logs;
    }
}
