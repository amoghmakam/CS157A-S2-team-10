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
-- Additional staff demo accounts
-- Password for all additional staff accounts: pass123
-- These accounts make staff assignment and user moderation easier to test.
-- ==========================================================

-- Staff ID 29: Parking staff assigned to North Garage
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (29, 'Parking', 'Staff', 'staff.parking@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (29, 'Parking Staff', 'Parking Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (29, NULL, 29, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

INSERT INTO StaffAssignment(assignmentID, staffID, serviceName, dateAssigned)
VALUES (13, 29, 'North Garage', CURDATE())
ON DUPLICATE KEY UPDATE
    staffID = VALUES(staffID),
    serviceName = VALUES(serviceName),
    dateAssigned = VALUES(dateAssigned);

INSERT IGNORE INTO AssignedTo(staffID, assignmentID)
VALUES (29, 13);

INSERT IGNORE INTO Covers(serviceName, assignmentID)
VALUES ('North Garage', 13);

INSERT IGNORE INTO Manages(staffID, serviceName)
VALUES (29, 'North Garage');


-- Staff ID 30: Advising staff assigned to Academic Advising
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (30, 'Advising', 'Staff', 'staff.advising@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (30, 'Advising Staff', 'Advising Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (30, NULL, 30, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

INSERT INTO StaffAssignment(assignmentID, staffID, serviceName, dateAssigned)
VALUES (14, 30, 'Academic Advising', CURDATE())
ON DUPLICATE KEY UPDATE
    staffID = VALUES(staffID),
    serviceName = VALUES(serviceName),
    dateAssigned = VALUES(dateAssigned);

INSERT IGNORE INTO AssignedTo(staffID, assignmentID)
VALUES (30, 14);

INSERT IGNORE INTO Covers(serviceName, assignmentID)
VALUES ('Academic Advising', 14);

INSERT IGNORE INTO Manages(staffID, serviceName)
VALUES (30, 'Academic Advising');


-- Staff ID 31: Extra dining staff assigned to Dining Commons
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (31, 'Dining', 'Staff', 'staff.dining2@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (31, 'Dining Staff Two', 'Dining Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (31, NULL, 31, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

INSERT INTO StaffAssignment(assignmentID, staffID, serviceName, dateAssigned)
VALUES (15, 31, 'Dining Commons', CURDATE())
ON DUPLICATE KEY UPDATE
    staffID = VALUES(staffID),
    serviceName = VALUES(serviceName),
    dateAssigned = VALUES(dateAssigned);

INSERT IGNORE INTO AssignedTo(staffID, assignmentID)
VALUES (31, 15);

INSERT IGNORE INTO Covers(serviceName, assignmentID)
VALUES ('Dining Commons', 15);

INSERT IGNORE INTO Manages(staffID, serviceName)
VALUES (31, 'Dining Commons');


-- Staff ID 32: Extra fitness staff assigned to SRAC Gym
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (32, 'Fitness', 'Staff', 'staff.fitness2@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (32, 'Fitness Staff Two', 'Fitness Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (32, NULL, 32, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

INSERT INTO StaffAssignment(assignmentID, staffID, serviceName, dateAssigned)
VALUES (16, 32, 'SRAC Gym', CURDATE())
ON DUPLICATE KEY UPDATE
    staffID = VALUES(staffID),
    serviceName = VALUES(serviceName),
    dateAssigned = VALUES(dateAssigned);

INSERT IGNORE INTO AssignedTo(staffID, assignmentID)
VALUES (32, 16);

INSERT IGNORE INTO Covers(serviceName, assignmentID)
VALUES ('SRAC Gym', 16);

INSERT IGNORE INTO Manages(staffID, serviceName)
VALUES (32, 'SRAC Gym');


-- Staff ID 33: Unassigned staff for testing Assign Staff to Service
INSERT INTO Users(userID, firstName, lastName, email, password, accountStatus)
VALUES (33, 'Unassigned', 'Staff', 'staff.unassigned@sjsu.edu', 'pass123', 'ACTIVE')
ON DUPLICATE KEY UPDATE
    firstName = VALUES(firstName),
    lastName = VALUES(lastName),
    password = VALUES(password),
    accountStatus = VALUES(accountStatus);

INSERT INTO Staff(staffID, staffName, staffRole)
VALUES (33, 'Unassigned Staff', 'Floating Staff')
ON DUPLICATE KEY UPDATE
    staffName = VALUES(staffName),
    staffRole = VALUES(staffRole);

INSERT INTO IsA(userID, studentID, staffID, adminID)
VALUES (33, NULL, 33, NULL)
ON DUPLICATE KEY UPDATE
    studentID = VALUES(studentID),
    staffID = VALUES(staffID),
    adminID = VALUES(adminID);

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
ALTER TABLE Users AUTO_INCREMENT = 34;
ALTER TABLE StaffAssignment AUTO_INCREMENT = 17;
