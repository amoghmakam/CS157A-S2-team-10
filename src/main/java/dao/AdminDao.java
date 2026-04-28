package dao;

import model.AuditLog;
import util.DBUtil;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;



public class AdminDao {

    public void assignStaff(int staffId, String serviceName) throws SQLException {
        String sql = "INSERT INTO StaffAssignment(staffID, serviceName, dateAssigned) VALUES (?, ?, CURDATE())";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setString(2, serviceName);
            ps.executeUpdate();
        }
    }
    public List<AuditLog> getAuditLogs() throws SQLException{
        String sql = "SELECT auditID, userID, actionType, actionDescription, actionTime FROM AuditLog ORDER BY actionTime DESC";
        List<AuditLog> logs = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery(sql)){
            while (rs.next()){
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