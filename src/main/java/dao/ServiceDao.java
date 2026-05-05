package dao;

import model.Service;
import model.ServiceHour;
import model.WaitTrend;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ServiceDao {

    /**
     * Returns services for the student/home pages.
     * The list is sorted by the calculated predicted wait time so the shortest wait appears first.
     */
    public List<Service> getAllServices(String category) throws SQLException {
        List<Service> services = new ArrayList<>();

        String sql;
        if (category == null || category.trim().isEmpty()) {
            sql = "SELECT * FROM Service";
        } else {
            sql = "SELECT * FROM Service WHERE categoryName = ?";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (category != null && !category.trim().isEmpty()) {
                ps.setString(1, category);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(makeService(conn, rs));
                }
            }
        }

        services.sort((a, b) -> Double.compare(a.getPredictedWait(), b.getPredictedWait()));
        return services;
    }

    public Service getServiceByName(String serviceName) throws SQLException {
        String sql = "SELECT * FROM Service WHERE serviceName = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return makeService(conn, rs);
            }
        }
    }

    public List<ServiceHour> getServiceHours(String serviceName) throws SQLException {
        List<ServiceHour> hours = new ArrayList<>();
        String sql = "SELECT * FROM ServiceHours WHERE serviceName = ? ORDER BY dayOfWeek";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceHour hour = new ServiceHour();
                    hour.setDayOfWeek(rs.getString("dayOfWeek"));
                    hour.setOpenTime(rs.getTime("openTime") == null ? "-" : rs.getTime("openTime").toString());
                    hour.setCloseTime(rs.getTime("closeTime") == null ? "-" : rs.getTime("closeTime").toString());
                    hour.setClosed(rs.getBoolean("isClosed"));
                    hours.add(hour);
                }
            }
        }

        return hours;
    }

    public List<WaitTrend> getWaitTrends(String serviceName) throws SQLException {
        List<WaitTrend> trends = new ArrayList<>();
        String sql = "SELECT * FROM WaitTimeHistory WHERE serviceName = ? ORDER BY recordDate, recordHour";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WaitTrend trend = new WaitTrend();
                    trend.setLabel(rs.getString("recordDate") + " @ " + rs.getInt("recordHour") + ":00");
                    trend.setAvgWait(rs.getDouble("avgWaitTime"));
                    trend.setTotalCheckIns(rs.getInt("totalCheckIns"));
                    trend.setCrowdLevel(rs.getString("crowdLevel"));
                    trends.add(trend);
                }
            }
        }

        return trends;
    }

    public List<Service> getAssignedServices(int staffId) throws SQLException {
        List<Service> services = new ArrayList<>();

        String sql = "SELECT s.* FROM Service s " +
                     "JOIN StaffAssignment sa ON s.serviceName = sa.serviceName " +
                     "WHERE sa.staffID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    services.add(makeService(conn, rs));
                }
            }
        }

        services.sort((a, b) -> a.getServiceName().compareToIgnoreCase(b.getServiceName()));
        return services;
    }

    /** Makes sure staff only update services assigned to them. */
    public boolean isStaffAssignedToService(int staffId, String serviceName) throws SQLException {
        String sql = "SELECT * FROM StaffAssignment WHERE staffID = ? AND serviceName = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setString(2, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void updateService(String serviceName, int capacity, String status) throws SQLException {
        String sql = "UPDATE Service SET capacity = ?, currentStatus = ? WHERE serviceName = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, capacity);
            ps.setString(2, status);
            ps.setString(3, serviceName);
            ps.executeUpdate();
        }
    }

    public void updateServiceFull(String oldServiceName, String newServiceName, String location,
                                  String buildingName, String roomNumber, int capacity,
                                  String currentStatus, String categoryName) throws SQLException {
        String sql = "UPDATE Service SET serviceName = ?, location = ?, buildingName = ?, roomNumber = ?, " +
                     "capacity = ?, currentStatus = ?, categoryName = ? WHERE serviceName = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newServiceName);
            ps.setString(2, location);
            ps.setString(3, buildingName);
            ps.setString(4, roomNumber);
            ps.setInt(5, capacity);
            ps.setString(6, currentStatus);
            ps.setString(7, categoryName);
            ps.setString(8, oldServiceName);
            ps.executeUpdate();
        }
    }

    public void addService(String serviceName, String location, String buildingName, String roomNumber,
                           int capacity, String currentStatus, String categoryName) throws SQLException {
        String insertService = "INSERT INTO Service(serviceName, location, buildingName, roomNumber, capacity, currentStatus, categoryName) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?)";
        String insertCategorizes = "INSERT INTO Categorizes(categoryName, serviceName) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertService)) {
                    ps.setString(1, serviceName);
                    ps.setString(2, location);
                    ps.setString(3, buildingName);
                    ps.setString(4, roomNumber);
                    ps.setInt(5, capacity);
                    ps.setString(6, currentStatus);
                    ps.setString(7, categoryName);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(insertCategorizes)) {
                    ps.setString(1, categoryName);
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

    /** Deactivation keeps the service record but marks it closed. */
    public void deactivateService(String serviceName) throws SQLException {
        String sql = "UPDATE Service SET currentStatus = 'Closed' WHERE serviceName = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            ps.executeUpdate();
        }
    }

    /** Removing a service deletes it and dependent rows through foreign key cascade rules. */
    public void removeService(String serviceName) throws SQLException {
        String sql = "DELETE FROM Service WHERE serviceName = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            ps.executeUpdate();
        }
    }

    /** Staff/admin can update hours for one service and one day at a time. */
    public void updateServiceHours(String serviceName, String dayOfWeek, String openTime,
                                   String closeTime, boolean isClosed) throws SQLException {
        String sql = "INSERT INTO ServiceHours(serviceName, dayOfWeek, openTime, closeTime, isClosed) " +
                     "VALUES (?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE openTime = VALUES(openTime), closeTime = VALUES(closeTime), isClosed = VALUES(isClosed)";
        String link = "INSERT IGNORE INTO HasHours(serviceName, dayOfWeek) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, serviceName);
                    ps.setString(2, dayOfWeek);
                    ps.setString(3, isClosed ? null : openTime);
                    ps.setString(4, isClosed ? null : closeTime);
                    ps.setBoolean(5, isClosed);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(link)) {
                    ps.setString(1, serviceName);
                    ps.setString(2, dayOfWeek);
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

    private String getCrowdTrendNext24h(Connection conn, String serviceName)
            throws SQLException {
        String sql = "SELECT recordHour, AVG(avgWaitTime) as avgWait " +
                "FROM WaitTimeHistory WHERE serviceName = ? " +
                "GROUP BY recordHour ORDER BY recordHour";

        int currentHour = java.time.LocalTime.now().getHour();
        double peakWait = -1;
        int peakHour = -1;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int hour = rs.getInt("recordHour");
                    double wait = rs.getDouble("avgWait");
                    int hoursFromNow = (hour - currentHour + 24) % 24;
                    if (hoursFromNow <= 24 && wait > peakWait) {
                        peakWait = wait;
                        peakHour = hour;
                    }
                }
            }
        }

        if (peakHour == -1) return "No trend data available";
        String period = peakHour < 12 ? "am" : "pm";
        int displayHour = peakHour % 12 == 0 ? 12 : peakHour % 12;
        return "Peak expected around " + displayHour + period;
    }

    public List<WaitTrend> getAvgWaitByDay(String serviceName) throws SQLException
    {
        String sql = "SELECT DAYNAME(checkInTime) as day, DAYOFWEEK(checkInTime) as dayNum, " +
                     "AVG(duration) as avgWait FROM CheckIn " +
                     "WHERE serviceName = ? AND duration IS NOT NULL " +
                     "GROUP BY DAYOFWEEK(checkInTime), DAYNAME(checkInTime) " +
                     "ORDER BY DAYOFWEEK(checkInTime)";

        List<WaitTrend> trends = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WaitTrend t = new WaitTrend();
                    t.setLabel(rs.getString("day"));
                    t.setAvgWait(rs.getDouble("avgWait"));
                    t.setCrowdLevel(rs.getDouble("avgWait") < 50 ? "Low" :
                            rs.getDouble("avgWait") < 150 ? "Medium" : "High");
                    trends.add(t);
                }
            }
        }
        return trends;
    }

    public List<WaitTrend> getAvgWaitByHour(String serviceName) throws
            SQLException {
        String sql = "SELECT HOUR(checkInTime) as hour, AVG(duration) as avgWait FROM CheckIn " +
                     "WHERE serviceName = ? AND duration IS NOT NULL " +
                     "GROUP BY HOUR(checkInTime) ORDER BY HOUR(checkInTime)";

        List<WaitTrend> trends = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WaitTrend t = new WaitTrend();
                    int hour = rs.getInt("hour");
                    String period = hour < 12 ? "am" : "pm";
                    int display = hour % 12 == 0 ? 12 : hour % 12;
                    t.setLabel(display + period);
                    t.setAvgWait(rs.getDouble("avgWait"));
                    t.setCrowdLevel(rs.getDouble("avgWait") < 50 ? "Low" :
                            rs.getDouble("avgWait") < 150 ? "Medium" : "High");
                    trends.add(t);
                }
            }
        }
        return trends;
    }


    private Service makeService(Connection conn, ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setServiceName(rs.getString("serviceName"));
        service.setLocation(rs.getString("location"));
        service.setBuildingName(rs.getString("buildingName"));
        service.setRoomNumber(rs.getString("roomNumber"));
        service.setCapacity(rs.getInt("capacity"));
        service.setCurrentStatus(rs.getString("currentStatus"));
        service.setCategoryName(rs.getString("categoryName"));

        int activeCount = getActiveCount(conn, service.getServiceName());
        service.setActiveCount(activeCount);
        service.setCrowdLevel(calculateCrowd(activeCount, service.getCapacity()));
        service.setPredictedWait(calculatePredictedWait(conn, service.getServiceName(), activeCount, service.getCapacity()));
        service.setTrendLabel(getCrowdTrendNext24h(conn, service.getServiceName())); // For 24 hour trend
        return service;
    }

    private int getActiveCount(Connection conn, String serviceName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CheckIn WHERE serviceName = ? AND checkOutTime IS NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Intro-class prediction formula:
     * historical average wait + small penalty for active crowd pressure.
     */
    private double calculatePredictedWait(Connection conn, String serviceName, int activeCount, int capacity) throws SQLException {
        double averageWait = getAverageWait(conn, serviceName);
        double capacityPenalty = capacity <= 0 ? 0 : ((double) activeCount / capacity) * 10.0;
        return averageWait + capacityPenalty;
    }

    private double getAverageWait(Connection conn, String serviceName) throws SQLException {
        String sql = "SELECT AVG(duration) FROM CheckIn WHERE serviceName = ? AND duration IS NOT NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble(1);
                    return rs.wasNull() ? 0 : avg;
                }
            }
        }
        return 0;
    }

    private String calculateCrowd(int activeCount, int capacity) {
        if (capacity <= 0) {
            return "Low";
        }

        double ratio = (double) activeCount / capacity;
        if (ratio < 0.4) {
            return "Low";
        } else if (ratio < 0.8) {
            return "Medium";
        } else {
            return "High";
        }
    }
}
