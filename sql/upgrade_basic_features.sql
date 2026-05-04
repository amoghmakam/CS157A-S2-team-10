-- CampusQueue upgrade_basic_features.sql
-- Run this after sql/schema.sql if your database already exists.
-- This keeps the upgrade simple for an intro database class.

USE team10;

-- Add account status for admin moderation.
-- ACTIVE users can log in. SUSPENDED users are blocked by UserDao.login().
ALTER TABLE Users
ADD COLUMN accountStatus VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';

-- These indexes keep the common lookup queries fast without using advanced database features.
CREATE INDEX idx_checkin_student_active ON CheckIn(studentID, checkOutTime);
CREATE INDEX idx_checkin_service_time ON CheckIn(serviceName, checkInTime);
CREATE INDEX idx_staffassignment_staff_service ON StaffAssignment(staffID, serviceName);
CREATE INDEX idx_waittimehistory_service_time ON WaitTimeHistory(serviceName, recordDate, recordHour);

-- The sample data originally used plain-text passwords.
-- The Java code accepts old passwords once and automatically upgrades them to SHA-256 at login.
-- New registered users are always stored with a SHA-256 hash.
