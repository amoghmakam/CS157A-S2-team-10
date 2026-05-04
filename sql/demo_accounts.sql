-- CampusQueue demo_accounts.sql
-- Adds simple, easy-to-remember demo accounts for presentation/testing.
-- Run after schema.sql and upgrade_basic_features.sql.

USE team10;

-- ==========================================================
-- Student demo account
-- Login: student.demo@sjsu.edu
-- Password: pass123
-- ==========================================================
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (26, 'Student', 'Demo', 'student.demo@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Student(studentID, major, grade)
VALUES (26, 'Computer Science', 'Junior')
ON DUPLICATE KEY UPDATE
    major = VALUES(major),
    grade = VALUES(grade);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (26, 26, NULL, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

-- ==========================================================
-- Staff demo account
-- Login: staff.demo@sjsu.edu
-- Password: pass123
-- Assigned service: SRAC Gym
-- ==========================================================
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (27, 'Staff', 'Demo', 'staff.demo@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (27, 'Staff Demo', 'Demo Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (27, NULL, 27, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

INSERT INTO StaffAssignment(assignmentID, staffID, serviceName, dateAssigned)
VALUES (12, 27, 'SRAC Gym', CURDATE())
ON DUPLICATE KEY UPDATE
    staffID = VALUES(staffID),
    serviceName = VALUES(serviceName),
    dateAssigned = VALUES(dateAssigned);

INSERT IGNORE INTO AssignedTo(staffID, assignmentID)
VALUES (27, 12);

INSERT IGNORE INTO Covers(serviceName, assignmentID)
VALUES ('SRAC Gym', 12);

INSERT IGNORE INTO Manages(staffID, serviceName)
VALUES (27, 'SRAC Gym');

-- ==========================================================
-- Admin demo account
-- Login: admin.demo@sjsu.edu
-- Password: pass123
-- ==========================================================
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (28, 'Admin', 'Demo', 'admin.demo@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Admin(adminID, adminName)
VALUES (28, 'Admin Demo')
ON DUPLICATE KEY UPDATE
    adminName = VALUES(adminName);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (28, NULL, NULL, 28)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

-- Keep auto-increment values ahead of the demo seed IDs.
ALTER TABLE Users AUTO_INCREMENT = 29;
ALTER TABLE StaffAssignment AUTO_INCREMENT = 13;
