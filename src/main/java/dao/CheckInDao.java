package dao;

import model.CheckInRecord;
import model.ValidationEntry;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CheckInDao {

    public boolean hasActiveCheckIn(int studentId) throws SQLException {
        String sql = "SELECT * FROM CheckIn WHERE studentID = ? AND checkOutTime IS NULL";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void createCheckIn(int studentId, String serviceName, int crowdEstimate) throws SQLException {
        String insertCheckIn = "INSERT INTO CheckIn(studentID, serviceName, checkInTime, checkOutTime, crowdEstimate, duration) " +
                               "VALUES (?, ?, NOW(), NULL, ?, NULL)";
        String getLastId = "SELECT LAST_INSERT_ID()";
        String insertSubmits = "INSERT INTO Submits(studentID, checkInID) VALUES (?, ?)";
        String insertOccursAt = "INSERT INTO OccursAt(serviceName, checkInID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement checkInPs = conn.prepareStatement(insertCheckIn)) {
                checkInPs.setInt(1, studentId);
                checkInPs.setString(2, serviceName);
                checkInPs.setInt(3, crowdEstimate);
                checkInPs.executeUpdate();

                int checkInId;
                try (PreparedStatement idPs = conn.prepareStatement(getLastId);
                     ResultSet rs = idPs.executeQuery()) {
                    rs.next();
                    checkInId = rs.getInt(1);
                }

                try (PreparedStatement submitsPs = conn.prepareStatement(insertSubmits)) {
                    submitsPs.setInt(1, studentId);
                    submitsPs.setInt(2, checkInId);
                    submitsPs.executeUpdate();
                }

                try (PreparedStatement occursPs = conn.prepareStatement(insertOccursAt)) {
                    occursPs.setString(1, serviceName);
                    occursPs.setInt(2, checkInId);
                    occursPs.executeUpdate();
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
        String sql = "UPDATE CheckIn " +
                     "SET checkOutTime = NOW(), duration = TIMESTAMPDIFF(MINUTE, checkInTime, NOW()) " +
                     "WHERE studentID = ? AND checkOutTime IS NULL";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.executeUpdate();
        }
    }

    public List<CheckInRecord> getStudentHistory(int studentId) throws SQLException {
        List<CheckInRecord> history = new ArrayList<>();
        String sql = "SELECT * FROM CheckIn WHERE studentID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    history.add(makeCheckInRecord(rs));
                }
            }
        }

        return history;
    }

    public List<CheckInRecord> getAssignedServiceRecentActivity(int staffId) throws SQLException {
        List<CheckInRecord> records = new ArrayList<>();

        String sql = "SELECT c.* FROM CheckIn c " +
                     "JOIN StaffAssignment sa ON c.serviceName = sa.serviceName " +
                     "WHERE sa.staffID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    records.add(makeCheckInRecord(rs));
                }
            }
        }

        return records;
    }

    public void validateCheckIn(int checkInId, int staffId, String validationType, String validationReason) throws SQLException {
        String sql = "INSERT INTO ValidationLog(checkInID, staffID, validationType, validationReason, validationTime) " +
                     "VALUES (?, ?, ?, ?, NOW())";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, checkInId);
            ps.setInt(2, staffId);
            ps.setString(3, validationType);
            ps.setString(4, validationReason);
            ps.executeUpdate();
        }
    }

    public List<ValidationEntry> getRecentValidationsForStaff(int staffId) throws SQLException {
        List<ValidationEntry> entries = new ArrayList<>();
        String sql = "SELECT * FROM ValidationLog WHERE staffID = ?";

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
                    entry.setValidationTime(rs.getTimestamp("validationTime").toString());
                    entries.add(entry);
                }
            }
        }

        return entries;
    }

    private CheckInRecord makeCheckInRecord(ResultSet rs) throws SQLException {
        CheckInRecord record = new CheckInRecord();
        record.setCheckInId(rs.getInt("checkInID"));
        record.setStudentId(rs.getInt("studentID"));
        record.setServiceName(rs.getString("serviceName"));
        record.setCheckInTime(rs.getTimestamp("checkInTime"));
        record.setCheckOutTime(rs.getTimestamp("checkOutTime"));
        record.setCrowdEstimate((Integer) rs.getObject("crowdEstimate"));
        record.setDuration((Integer) rs.getObject("duration"));
        return record;
    }
}