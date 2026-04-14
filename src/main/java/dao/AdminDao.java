package dao;

import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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
}
