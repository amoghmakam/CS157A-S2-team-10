-- CampusQueue test_basic_features.sql
-- These are simple checks you can run after schema.sql and upgrade_basic_features.sql.

USE team10;

-- 1. Check account status column exists.
SELECT userID, email, accountStatus
FROM Users
ORDER BY userID
LIMIT 5;

-- 2. Check services are available.
SELECT serviceName, categoryName, currentStatus, capacity
FROM Service
ORDER BY serviceName;

-- 3. Check active check-ins. There should be sample active rows where checkOutTime is NULL.
SELECT checkInID, studentID, serviceName, checkInTime, checkOutTime
FROM CheckIn
WHERE checkOutTime IS NULL;

-- 4. Check staff assignments and relationship tables.
SELECT sa.assignmentID, sa.staffID, sa.serviceName, sa.dateAssigned
FROM StaffAssignment sa
ORDER BY sa.assignmentID;

SELECT * FROM AssignedTo ORDER BY assignmentID;
SELECT * FROM Covers ORDER BY assignmentID;
SELECT * FROM Manages ORDER BY staffID, serviceName;

-- 5. Check validation relationship tables.
SELECT validationID, checkInID, staffID, validationType
FROM ValidationLog
ORDER BY validationID DESC
LIMIT 10;

SELECT * FROM Validates ORDER BY validationID DESC LIMIT 10;
SELECT * FROM Flags ORDER BY validationID DESC LIMIT 10;

-- 6. Check audit log relationship table.
SELECT auditID, userID, actionType, actionTime
FROM AuditLog
ORDER BY auditID DESC
LIMIT 10;

SELECT * FROM Performs ORDER BY auditID DESC LIMIT 10;
