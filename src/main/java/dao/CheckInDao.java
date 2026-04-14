package dao;

import model.CheckInRecord;
import model.ValidationEntry;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CheckInDao {

    public boolean hasActiveCheckIn(int studentId) throws SQLException {
        String sql = "SELECT 1 FROM CheckIn WHERE studentID = ? AND checkOutTime IS NULL LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void createCheckIn(int studentId, String serviceName, int crowdEstimate) throws SQLException {
        String insertCheckIn = """
            INSERT INTO CheckIn(studentID, serviceName, checkInTime, checkOutTime, crowdEstimate, duration)
            VALUES (?, ?, NOW(), NULL, ?, NULL)
        """;
        String insertSubmits = "INSERT INTO Submits(studentID, checkInID) VALUES (?, ?)";
        String insertOccursAt = "INSERT INTO OccursAt(serviceName, checkInID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertCheckIn, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, studentId);
                ps.setString(2, serviceName);
                ps.setInt(3, crowdEstimate);
                ps.executeUpdate();

                int checkInId;
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    checkInId = keys.getInt(1);
                }

                try (PreparedStatement sub = conn.prepareStatement(insertSubmits)) {
                    sub.setInt(1, studentId);
                    sub.setInt(2, checkInId);
                    sub.executeUpdate();
                }

                try (PreparedStatement occ = conn.prepareStatement(insertOccursAt)) {
                    occ.setString(1, serviceName);
                    occ.setInt(2, checkInId);
                    occ.executeUpdate();
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

    public void checkOut(int studentId) throws SQLException {
        String sql = """
            UPDATE CheckIn
            SET checkOutTime = NOW(),
                duration = TIMESTAMPDIFF(MINUTE, checkInTime, NOW())
            WHERE studentID = ? AND checkOutTime IS NULL
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.executeUpdate();
        }
    }

    public List<CheckInRecord> getStudentHistory(int studentId) throws SQLException {
        List<CheckInRecord> history = new ArrayList<>();
        String sql = """
            SELECT checkInID, studentID, serviceName, checkInTime, checkOutTime, crowdEstimate, duration
            FROM CheckIn
            WHERE studentID = ?
            ORDER BY checkInTime DESC
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CheckInRecord record = new CheckInRecord();
                    record.setCheckInId(rs.getInt("checkInID"));
                    record.setStudentId(rs.getInt("studentID"));
                    record.setServiceName(rs.getString("serviceName"));
                    record.setCheckInTime(rs.getTimestamp("checkInTime"));
                    record.setCheckOutTime(rs.getTimestamp("checkOutTime"));
                    record.setCrowdEstimate((Integer) rs.getObject("crowdEstimate"));
                    record.setDuration((Integer) rs.getObject("duration"));
                    history.add(record);
                }
            }
        }
        return history;
    }

    public List<CheckInRecord> getAssignedServiceRecentActivity(int staffId) throws SQLException {
        List<CheckInRecord> records = new ArrayList<>();
        String sql = """
            SELECT c.checkInID, c.studentID, c.serviceName, c.checkInTime, c.checkOutTime, c.crowdEstimate, c.duration
            FROM CheckIn c
            JOIN StaffAssignment sa ON c.serviceName = sa.serviceName
            WHERE sa.staffID = ?
            ORDER BY c.checkInTime DESC
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CheckInRecord record = new CheckInRecord();
                    record.setCheckInId(rs.getInt("checkInID"));
                    record.setStudentId(rs.getInt("studentID"));
                    record.setServiceName(rs.getString("serviceName"));
                    record.setCheckInTime(rs.getTimestamp("checkInTime"));
                    record.setCheckOutTime(rs.getTimestamp("checkOutTime"));
                    record.setCrowdEstimate((Integer) rs.getObject("crowdEstimate"));
                    record.setDuration((Integer) rs.getObject("duration"));
                    records.add(record);
                }
            }
        }
        return records;
    }

    public void validateCheckIn(int checkInId, int staffId, String validationType, String validationReason) throws SQLException {
        String insertValidation = """
            INSERT INTO ValidationLog(checkInID, staffID, validationType, validationReason, validationTime)
            VALUES (?, ?, ?, ?, NOW())
        """;
        String insertFlags = "INSERT INTO Flags(checkInID, validationID) VALUES (?, ?)";
        String insertValidates = "INSERT INTO Validates(staffID, validationID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertValidation, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, checkInId);
                ps.setInt(2, staffId);
                ps.setString(3, validationType);
                ps.setString(4, validationReason);
                ps.executeUpdate();

                int validationId;
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    validationId = keys.getInt(1);
                }

                try (PreparedStatement flags = conn.prepareStatement(insertFlags)) {
                    flags.setInt(1, checkInId);
                    flags.setInt(2, validationId);
                    flags.executeUpdate();
                }

                try (PreparedStatement validates = conn.prepareStatement(insertValidates)) {
                    validates.setInt(1, staffId);
                    validates.setInt(2, validationId);
                    validates.executeUpdate();
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

    public List<ValidationEntry> getRecentValidationsForStaff(int staffId) throws SQLException {
        List<ValidationEntry> entries = new ArrayList<>();
        String sql = """
            SELECT validationID, checkInID, staffID, validationType, validationReason, validationTime
            FROM ValidationLog
            WHERE staffID = ?
            ORDER BY validationTime DESC
        """;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ValidationEntry entry = new ValidationEntry();
                    entry.setValidationId(rs.getInt("validationID"));
                    entry.setCheckInId(rs.getInt("checkInID"));
                    entry.setStaffId(rs.getInt("staffID"));
                    entry.setValidationType(rs.getString("validationType"));
                    entry.setValidationReason(rs.getString("validationReason"));
                    entry.setValidationTime(String.valueOf(rs.getTimestamp("validationTime")));
                    entries.add(entry);
                }
            }
        }
        return entries;
    }
}
