package dao;

import model.CheckInRecord;
import model.ValidationEntry;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CheckInDao {

    /** Checks whether a student currently has an open check-in. */
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

    /**
     * Creates a new check-in and fills the Submits/OccursAt relationship tables.
     * The transaction prevents partial inserts if one table fails.
     */
    public void createCheckIn(int studentId, String serviceName, int crowdEstimate) throws SQLException {
        String insertCheckIn = "INSERT INTO CheckIn(studentID, serviceName, checkInTime, checkOutTime, crowdEstimate, duration) " +
                               "VALUES (?, ?, NOW(), NULL, ?, NULL)";
        String insertSubmits = "INSERT INTO Submits(studentID, checkInID) VALUES (?, ?)";
        String insertOccursAt = "INSERT INTO OccursAt(serviceName, checkInID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                if (hasActiveCheckIn(conn, studentId)) {
                    throw new SQLException("Student already has an active check-in.");
                }

                int checkInId;
                try (PreparedStatement checkInPs = conn.prepareStatement(insertCheckIn, Statement.RETURN_GENERATED_KEYS)) {
                    checkInPs.setInt(1, studentId);
                    checkInPs.setString(2, serviceName);
                    checkInPs.setInt(3, crowdEstimate);
                    checkInPs.executeUpdate();

                    try (ResultSet keys = checkInPs.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Could not get new check-in ID.");
                        }
                        checkInId = keys.getInt(1);
                    }
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

    /** Closes the active check-in and stores the duration in minutes. */
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
        String sql = "SELECT * FROM CheckIn WHERE studentID = ? ORDER BY checkInTime DESC";

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
                     "WHERE sa.staffID = ? " +
                     "ORDER BY c.checkInTime DESC";

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

    /**
     * Makes sure staff can only validate check-ins for services assigned to them.
     * Also fills Validates and Flags relationship tables from the ERD.
     */
    public void validateCheckIn(int checkInId, int staffId, String validationType, String validationReason) throws SQLException {
        String insertValidation = "INSERT INTO ValidationLog(checkInID, staffID, validationType, validationReason, validationTime) " +
                                  "VALUES (?, ?, ?, ?, NOW())";
        String insertValidates = "INSERT INTO Validates(staffID, validationID) VALUES (?, ?)";
        String insertFlags = "INSERT INTO Flags(checkInID, validationID) VALUES (?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            try {
                if (!canStaffAccessCheckIn(conn, staffId, checkInId)) {
                    throw new SQLException("Staff member is not assigned to this check-in's service.");
                }

                int validationId;
                try (PreparedStatement validationPs = conn.prepareStatement(insertValidation, Statement.RETURN_GENERATED_KEYS)) {
                    validationPs.setInt(1, checkInId);
                    validationPs.setInt(2, staffId);
                    validationPs.setString(3, validationType);
                    validationPs.setString(4, validationReason);
                    validationPs.executeUpdate();

                    try (ResultSet keys = validationPs.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Could not get validation ID.");
                        }
                        validationId = keys.getInt(1);
                    }
                }

                try (PreparedStatement validatesPs = conn.prepareStatement(insertValidates)) {
                    validatesPs.setInt(1, staffId);
                    validatesPs.setInt(2, validationId);
                    validatesPs.executeUpdate();
                }

                try (PreparedStatement flagsPs = conn.prepareStatement(insertFlags)) {
                    flagsPs.setInt(1, checkInId);
                    flagsPs.setInt(2, validationId);
                    flagsPs.executeUpdate();
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
        String sql = "SELECT * FROM ValidationLog WHERE staffID = ? ORDER BY validationTime DESC";

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

    private boolean hasActiveCheckIn(Connection conn, int studentId) throws SQLException {
        String sql = "SELECT * FROM CheckIn WHERE studentID = ? AND checkOutTime IS NULL";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean canStaffAccessCheckIn(Connection conn, int staffId, int checkInId) throws SQLException {
        String sql = "SELECT * FROM CheckIn c " +
                     "JOIN StaffAssignment sa ON c.serviceName = sa.serviceName " +
                     "WHERE c.checkInID = ? AND sa.staffID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, checkInId);
            ps.setInt(2, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
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
