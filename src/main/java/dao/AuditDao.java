package dao;

import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class AuditDao {

    /**
     * Writes an audit entry whenever a user changes important data.
     *
     * This also inserts into Performs so the relationship table stays consistent
     * with the AuditLog table from the ERD/report.
     */
    public void log(int userId, String actionType, String actionDescription) throws SQLException {
        String insertAudit = "INSERT INTO AuditLog(userID, actionType, actionDescription, actionTime) " +
                             "VALUES (?, ?, ?, NOW())";
        String insertPerforms = "INSERT INTO Performs(userID, auditID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement auditPs = conn.prepareStatement(insertAudit, Statement.RETURN_GENERATED_KEYS)) {
                auditPs.setInt(1, userId);
                auditPs.setString(2, actionType);
                auditPs.setString(3, actionDescription);
                auditPs.executeUpdate();

                int auditId;
                try (ResultSet keys = auditPs.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("Could not get audit ID.");
                    }
                    auditId = keys.getInt(1);
                }

                try (PreparedStatement performsPs = conn.prepareStatement(insertPerforms)) {
                    performsPs.setInt(1, userId);
                    performsPs.setInt(2, auditId);
                    performsPs.executeUpdate();
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
}
