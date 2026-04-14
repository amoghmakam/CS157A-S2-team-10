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
                    service.setPredictedWait(getAverageWait(conn, service.getServiceName()));
                    service.setCrowdLevel(calculateCrowd(activeCount, service.getCapacity()));

                    services.add(service);
                }
            }
        }

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

                Service service = new Service();
                service.setServiceName(rs.getString("serviceName"));
                service.setLocation(rs.getString("location"));
                service.setBuildingName(rs.getString("buildingName"));
                service.setRoomNumber(rs.getString("roomNumber"));
                service.setCapacity(rs.getInt("capacity"));
                service.setCurrentStatus(rs.getString("currentStatus"));
                service.setCategoryName(rs.getString("categoryName"));

                int activeCount = getActiveCount(conn, serviceName);
                service.setActiveCount(activeCount);
                service.setPredictedWait(getAverageWait(conn, serviceName));
                service.setCrowdLevel(calculateCrowd(activeCount, service.getCapacity()));

                return service;
            }
        }
    }

    public List<ServiceHour> getServiceHours(String serviceName) throws SQLException {
        List<ServiceHour> hours = new ArrayList<>();
        String sql = "SELECT * FROM ServiceHours WHERE serviceName = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServiceHour hour = new ServiceHour();
                    hour.setDayOfWeek(rs.getString("dayOfWeek"));

                    if (rs.getTime("openTime") != null) {
                        hour.setOpenTime(rs.getTime("openTime").toString());
                    } else {
                        hour.setOpenTime("-");
                    }

                    if (rs.getTime("closeTime") != null) {
                        hour.setCloseTime(rs.getTime("closeTime").toString());
                    } else {
                        hour.setCloseTime("-");
                    }

                    hour.setClosed(rs.getBoolean("isClosed"));
                    hours.add(hour);
                }
            }
        }

        return hours;
    }

    public List<WaitTrend> getWaitTrends(String serviceName) throws SQLException {
        List<WaitTrend> trends = new ArrayList<>();
        String sql = "SELECT * FROM WaitTimeHistory WHERE serviceName = ?";

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
                    service.setPredictedWait(getAverageWait(conn, service.getServiceName()));
                    service.setCrowdLevel(calculateCrowd(activeCount, service.getCapacity()));

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
        String sql = "INSERT INTO Service(serviceName, location, buildingName, roomNumber, capacity, currentStatus, categoryName) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

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

    private int getActiveCount(Connection conn, String serviceName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CheckIn WHERE serviceName = ? AND checkOutTime IS NULL";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    private double getAverageWait(Connection conn, String serviceName) throws SQLException {
        String sql = "SELECT AVG(duration) FROM CheckIn WHERE serviceName = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble(1);
                    if (rs.wasNull()) {
                        return 0;
                    }
                    return avg;
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