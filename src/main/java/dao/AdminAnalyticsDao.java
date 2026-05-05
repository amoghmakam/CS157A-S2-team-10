package dao;

import model.AdminAnalytics;
import model.HourlyVolumeRow;
import model.ServiceAnalyticsRow;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AdminAnalyticsDao {

    public AdminAnalytics getAdminAnalytics() throws SQLException {
        AdminAnalytics analytics = new AdminAnalytics();

        try (Connection conn = DBUtil.getConnection()) {
            analytics.setTotalServices(getInt(conn, "SELECT COUNT(*) FROM Service"));
            analytics.setOpenServices(getInt(conn, "SELECT COUNT(*) FROM Service WHERE LOWER(currentStatus) = 'open'"));
            analytics.setTotalUsers(getInt(conn, "SELECT COUNT(*) FROM Users"));
            analytics.setActiveCheckIns(getInt(conn, "SELECT COUNT(*) FROM CheckIn WHERE checkOutTime IS NULL"));
            analytics.setTotalCompletedVisits(getInt(conn, "SELECT COUNT(*) FROM CheckIn WHERE checkOutTime IS NOT NULL"));
            analytics.setAverageVisitMinutes(getDouble(conn, "SELECT AVG(duration) FROM CheckIn WHERE duration IS NOT NULL"));
            analytics.setFlaggedRecords(getInt(conn, "SELECT COUNT(*) FROM ValidationLog WHERE UPPER(validationType) = 'FLAGGED'"));

            analytics.setBusiestServices(getBusiestServices(conn));
            analytics.setHourlyVolume(getHourlyVolume(conn));
        }

        return analytics;
    }

    private int getInt(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private double getDouble(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                double value = rs.getDouble(1);
                return rs.wasNull() ? 0 : value;
            }
            return 0;
        }
    }

    private List<ServiceAnalyticsRow> getBusiestServices(Connection conn) throws SQLException {
        List<ServiceAnalyticsRow> rows = new ArrayList<>();

        String sql =
            "SELECT serviceName, " +
            "COUNT(*) AS totalVisits, " +
            "SUM(CASE WHEN checkOutTime IS NULL THEN 1 ELSE 0 END) AS activeVisits, " +
            "AVG(duration) AS averageDuration " +
            "FROM CheckIn " +
            "GROUP BY serviceName " +
            "ORDER BY totalVisits DESC " +
            "LIMIT 5";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ServiceAnalyticsRow row = new ServiceAnalyticsRow();
                row.setServiceName(rs.getString("serviceName"));
                row.setTotalVisits(rs.getInt("totalVisits"));
                row.setActiveVisits(rs.getInt("activeVisits"));

                double avg = rs.getDouble("averageDuration");
                row.setAverageDuration(rs.wasNull() ? 0 : avg);

                rows.add(row);
            }
        }

        return rows;
    }

    private List<HourlyVolumeRow> getHourlyVolume(Connection conn) throws SQLException {
        List<HourlyVolumeRow> rows = new ArrayList<>();

        String sql =
            "SELECT h.hourValue, " +
            "COALESCE(ci.checkIns, 0) AS checkIns, " +
            "COALESCE(co.checkOuts, 0) AS checkOuts " +
            "FROM ( " +
            "  SELECT 0 hourValue UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 " +
            "  UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 " +
            "  UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 " +
            "  UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 " +
            ") h " +
            "LEFT JOIN ( " +
            "  SELECT HOUR(checkInTime) AS hourValue, COUNT(*) AS checkIns " +
            "  FROM CheckIn GROUP BY HOUR(checkInTime) " +
            ") ci ON h.hourValue = ci.hourValue " +
            "LEFT JOIN ( " +
            "  SELECT HOUR(checkOutTime) AS hourValue, COUNT(*) AS checkOuts " +
            "  FROM CheckIn WHERE checkOutTime IS NOT NULL GROUP BY HOUR(checkOutTime) " +
            ") co ON h.hourValue = co.hourValue " +
            "ORDER BY h.hourValue";

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                HourlyVolumeRow row = new HourlyVolumeRow();
                row.setHour(rs.getInt("hourValue"));
                row.setCheckIns(rs.getInt("checkIns"));
                row.setCheckOuts(rs.getInt("checkOuts"));
                rows.add(row);
            }
        }

        return rows;
    }
}