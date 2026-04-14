package dao;

import model.Service;
import model.ServiceHour;
import model.WaitTrend;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceDao {

    public List<Service> getAllServices(String category) throws SQLException {
        List<Service> services = new ArrayList<>();
        String sql = """
            SELECT s.serviceName, s.location, s.buildingName, s.roomNumber, s.capacity, s.currentStatus, s.categoryName,
                   COUNT(CASE WHEN c.checkOutTime IS NULL THEN 1 END) AS activeCount
            FROM Service s
            LEFT JOIN CheckIn c ON s.serviceName = c.serviceName
            WHERE (? IS NULL OR ? = '' OR s.categoryName = ?)
            GROUP BY s.serviceName, s.location, s.buildingName, s.roomNumber, s.capacity, s.currentStatus, s.categoryName
            ORDER BY s.serviceName
        """;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            ps.setString(2, category);
            ps.setString(3, category);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Service service = mapService(rs);
                    service.setPredictedWait(getPredictedWait(conn, service.getServiceName()));
                    service.setCrowdLevel(calculateCrowd(service.getActiveCount(), service.getCapacity()));
                    services.add(service);
                }
            }
        }
        return services;
    }

    public Service getServiceByName(String serviceName) throws SQLException {
        String sql = """
            SELECT s.serviceName, s.location, s.buildingName, s.roomNumber, s.capacity, s.currentStatus, s.categoryName,
                   COUNT(CASE WHEN c.checkOutTime IS NULL THEN 1 END) AS activeCount
            FROM Service s
            LEFT JOIN CheckIn c ON s.serviceName = c.serviceName
            WHERE s.serviceName = ?
            GROUP BY s.serviceName, s.location, s.buildingName, s.roomNumber, s.capacity, s.currentStatus, s.categoryName
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Service service = mapService(rs);
                service.setPredictedWait(getPredictedWait(conn, serviceName));
                service.setCrowdLevel(calculateCrowd(service.getActiveCount(), service.getCapacity()));
                return service;
            }
        }
    }

    private Service mapService(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setServiceName(rs.getString("serviceName"));
        service.setLocation(rs.getString("location"));
        service.setBuildingName(rs.getString("buildingName"));
        service.setRoomNumber(rs.getString("roomNumber"));
        service.setCapacity(rs.getInt("capacity"));
        service.setCurrentStatus(rs.getString("currentStatus"));
        service.setCategoryName(rs.getString("categoryName"));
        service.setActiveCount(rs.getInt("activeCount"));
        return service;
    }

    public List<ServiceHour> getServiceHours(String serviceName) throws SQLException {
        List<ServiceHour> hours = new ArrayList<>();
        String sql = "SELECT dayOfWeek, openTime, closeTime, isClosed FROM ServiceHours WHERE serviceName = ? ORDER BY dayOfWeek";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceHour hour = new ServiceHour();
                    hour.setDayOfWeek(rs.getString("dayOfWeek"));
                    Time open = rs.getTime("openTime");
                    Time close = rs.getTime("closeTime");
                    hour.setOpenTime(open == null ? "-" : open.toString());
                    hour.setCloseTime(close == null ? "-" : close.toString());
                    hour.setClosed(rs.getBoolean("isClosed"));
                    hours.add(hour);
                }
            }
        }
        return hours;
    }

    public List<WaitTrend> getWaitTrends(String serviceName) throws SQLException {
        List<WaitTrend> trends = new ArrayList<>();
        String sql = """
            SELECT CONCAT(recordDate, ' @ ', recordHour, ':00') AS label, avgWaitTime, totalCheckIns, crowdLevel
            FROM WaitTimeHistory
            WHERE serviceName = ?
            ORDER BY recordDate, recordHour
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WaitTrend trend = new WaitTrend();
                    trend.setLabel(rs.getString("label"));
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
        String sql = """
            SELECT s.serviceName, s.location, s.buildingName, s.roomNumber, s.capacity, s.currentStatus, s.categoryName
            FROM Service s
            JOIN StaffAssignment sa ON s.serviceName = sa.serviceName
            WHERE sa.staffID = ?
            ORDER BY s.serviceName
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Service service = new Service();
                    service.setServiceName(rs.getString("serviceName"));
                    service.setLocation(rs.getString("location"));
                    service.setBuildingName(rs.getString("buildingName"));
                    service.setRoomNumber(rs.getString("roomNumber"));
                    service.setCapacity(rs.getInt("capacity"));
                    service.setCurrentStatus(rs.getString("currentStatus"));
                    service.setCategoryName(rs.getString("categoryName"));
                    services.add(service);
                }
            }
        }
        return services;
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

    public void addService(String serviceName, String location, String buildingName, String roomNumber,
                           int capacity, String currentStatus, String categoryName) throws SQLException {
        String sql = """
            INSERT INTO Service(serviceName, location, buildingName, roomNumber, capacity, currentStatus, categoryName)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            ps.setString(2, location);
            ps.setString(3, buildingName);
            ps.setString(4, roomNumber);
            ps.setInt(5, capacity);
            ps.setString(6, currentStatus);
            ps.setString(7, categoryName);
            ps.executeUpdate();
        }
    }

    private double getPredictedWait(Connection conn, String serviceName) throws SQLException {
        String sql = """
            SELECT COALESCE(AVG(duration), 10.0) AS avgDuration
            FROM CheckIn
            WHERE serviceName = ? AND duration IS NOT NULL
        """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("avgDuration");
            }
        }
        return 10.0;
    }

    private String calculateCrowd(int activeCount, int capacity) {
        if (capacity <= 0) return "Low";
        double ratio = (double) activeCount / capacity;
        if (ratio < 0.4) return "Low";
        if (ratio < 0.8) return "Medium";
        return "High";
    }
}
