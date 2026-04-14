package dao;

import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class AuditDao {
    public void log(int userId, String actionType, String actionDescription) throws SQLException {
        String insertAudit = """
            INSERT INTO AuditLog(userID, actionType, actionDescription, actionTime)
            VALUES (?, ?, ?, NOW())
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertAudit)) {
            ps.setInt(1, userId);
            ps.setString(2, actionType);
            ps.setString(3, actionDescription);
            ps.executeUpdate();
        }
    }
}
