-- CampusQueue upgrade_basic_features.sql
-- Run this after sql/schema.sql.
-- Keeps extra database upgrades simple.

USE team10;

-- ==========================================================
-- Account moderation support
-- ==========================================================

-- Add account status for admin moderation.
-- ACTIVE users can log in. SUSPENDED users are blocked by UserDao.login().
ALTER TABLE Users
ADD COLUMN accountStatus VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';

-- Make all existing sample users active after the column is added.
UPDATE Users
SET accountStatus = 'ACTIVE'
WHERE accountStatus IS NULL OR accountStatus = '';

-- ==========================================================
-- Simple performance indexes
-- ==========================================================

-- User login and moderation lookups.
CREATE INDEX idx_users_email_status ON Users(email, accountStatus);

-- Student check-in/check-out lookups.
CREATE INDEX idx_checkin_student_active ON CheckIn(studentID, checkOutTime);
CREATE INDEX idx_checkin_service_time ON CheckIn(serviceName, checkInTime);
CREATE INDEX idx_checkin_service_checkout ON CheckIn(serviceName, checkOutTime);

-- Staff assignment lookups.
CREATE INDEX idx_staffassignment_staff_service ON StaffAssignment(staffID, serviceName);
CREATE INDEX idx_staffassignment_service_staff ON StaffAssignment(serviceName, staffID);

-- Service browsing and filtering lookups.
CREATE INDEX idx_service_category_status ON Service(categoryName, currentStatus);
CREATE INDEX idx_service_status ON Service(currentStatus);

-- Service hours lookups for detail pages and staff updates.
CREATE INDEX idx_servicehours_service_day ON ServiceHours(serviceName, dayOfWeek);

-- Historical trend and wait-time lookups.
CREATE INDEX idx_waittimehistory_service_time ON WaitTimeHistory(serviceName, recordDate, recordHour);
CREATE INDEX idx_waittimehistory_service_hour ON WaitTimeHistory(serviceName, recordHour);

-- Validation and audit dashboard lookups.
CREATE INDEX idx_validationlog_checkin_staff ON ValidationLog(checkInID, staffID);
CREATE INDEX idx_validationlog_staff_time ON ValidationLog(staffID, validationTime);
CREATE INDEX idx_auditlog_user_time ON AuditLog(userID, actionTime);
CREATE INDEX idx_auditlog_action_time ON AuditLog(actionType, actionTime);

-- ==========================================================
-- Notes
-- ==========================================================

-- Sample data originally used plain-text passwords.
-- The Java code accepts old passwords once and automatically upgrades them to SHA-256 at login.
-- New registered users are always stored with a SHA-256 hash.
