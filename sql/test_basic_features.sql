-- CampusQueue test_basic_features.sql
-- These are simple checks you can run after schema.sql, upgrade_basic_features.sql, and demo_accounts.sql.
-- The goal is to verify that the main project features have data available for the demo.

USE team10;

-- ==========================================================
-- 1. User accounts and demo accounts
-- ==========================================================

-- Check account status column exists and users are active.
SELECT userID, firstName, lastName, email, accountStatus
FROM Users
ORDER BY userID
LIMIT 10;

-- Check official demo accounts exist.
SELECT userID, firstName, lastName, email, accountStatus
FROM Users
WHERE email IN (
    'student.demo@sjsu.edu',
    'staff.demo@sjsu.edu',
    'admin.demo@sjsu.edu'
)
ORDER BY email;

-- Check student/staff/admin subtype rows exist.
SELECT 'Students' AS tableName, COUNT(*) AS rowCount FROM Student
UNION ALL
SELECT 'Staff' AS tableName, COUNT(*) AS rowCount FROM Staff
UNION ALL
SELECT 'Admin' AS tableName, COUNT(*) AS rowCount FROM Admin;

-- ==========================================================
-- 2. Services, categories, and hours
-- ==========================================================

-- Check services are available for browsing.
SELECT serviceName, categoryName, currentStatus, capacity
FROM Service
ORDER BY serviceName;

-- Check service categories and service counts.
SELECT sc.categoryName, sc.categoryDescription, COUNT(s.serviceName) AS serviceCount
FROM ServiceCategory sc
LEFT JOIN Service s ON sc.categoryName = s.categoryName
GROUP BY sc.categoryName, sc.categoryDescription
ORDER BY sc.categoryName;

-- Check service hours exist.
SELECT serviceName, dayOfWeek, openTime, closeTime, isClosed
FROM ServiceHours
ORDER BY serviceName, dayOfWeek;

-- ==========================================================
-- 3. Student check-in/check-out functionality
-- ==========================================================

-- Check active check-ins. These should have checkOutTime as NULL.
SELECT checkInID, studentID, serviceName, checkInTime, checkOutTime
FROM CheckIn
WHERE checkOutTime IS NULL
ORDER BY checkInID;

-- Check completed check-ins and stored durations.
SELECT checkInID, studentID, serviceName, checkInTime, checkOutTime, duration
FROM CheckIn
WHERE checkOutTime IS NOT NULL
ORDER BY checkInID
LIMIT 10;

-- Check active check-in count by service for live crowd/wait estimation.
SELECT serviceName, COUNT(*) AS activeCheckIns
FROM CheckIn
WHERE checkOutTime IS NULL
GROUP BY serviceName
ORDER BY serviceName;

-- Check average duration by service for historical wait estimation.
SELECT serviceName, ROUND(AVG(duration), 2) AS avgDurationMinutes
FROM CheckIn
WHERE duration IS NOT NULL
GROUP BY serviceName
ORDER BY serviceName;

-- ==========================================================
-- 4. Staff assignment functionality
-- ==========================================================

-- Check staff assignments.
SELECT sa.assignmentID, sa.staffID, u.email AS staffEmail, sa.serviceName, sa.dateAssigned
FROM StaffAssignment sa
JOIN Users u ON sa.staffID = u.userID
ORDER BY sa.assignmentID;

-- Check staff demo account is assigned to SRAC Gym.
SELECT sa.staffID, u.email, sa.serviceName
FROM StaffAssignment sa
JOIN Users u ON sa.staffID = u.userID
WHERE u.email = 'staff.demo@sjsu.edu';

-- Check staff relationship tables.
SELECT * FROM AssignedTo ORDER BY assignmentID;
SELECT * FROM Covers ORDER BY assignmentID;
SELECT * FROM Manages ORDER BY staffID, serviceName;

-- ==========================================================
-- 5. Validation functionality
-- ==========================================================

-- Check validation records.
SELECT validationID, checkInID, staffID, validationType, validationReason, validationTime
FROM ValidationLog
ORDER BY validationID DESC
LIMIT 10;

-- Check validation relationship tables.
SELECT * FROM Validates ORDER BY validationID DESC LIMIT 10;
SELECT * FROM Flags ORDER BY validationID DESC LIMIT 10;

-- ==========================================================
-- 6. Historical trends and wait-time data
-- ==========================================================

-- Check historical wait-time records.
SELECT historyID, serviceName, recordDate, recordHour, avgWaitTime, totalCheckIns, crowdLevel
FROM WaitTimeHistory
ORDER BY serviceName, recordDate, recordHour;

-- Check records relationship table.
SELECT * FROM Records ORDER BY serviceName, historyID;

-- ==========================================================
-- 7. Audit log functionality
-- ==========================================================

-- Check audit logs.
SELECT auditID, userID, actionType, actionDescription, actionTime
FROM AuditLog
ORDER BY auditID DESC
LIMIT 10;

-- Check audit relationship table.
SELECT * FROM Performs ORDER BY auditID DESC LIMIT 10;

-- ==========================================================
-- 8. ERD relationship table coverage
-- ==========================================================

-- Count all main relationship tables to verify they are populated.
SELECT 'IsA' AS relationshipTable, COUNT(*) AS rowCount FROM IsA
UNION ALL
SELECT 'Categorizes', COUNT(*) FROM Categorizes
UNION ALL
SELECT 'HasHours', COUNT(*) FROM HasHours
UNION ALL
SELECT 'Submits', COUNT(*) FROM Submits
UNION ALL
SELECT 'OccursAt', COUNT(*) FROM OccursAt
UNION ALL
SELECT 'Manages', COUNT(*) FROM Manages
UNION ALL
SELECT 'AssignedTo', COUNT(*) FROM AssignedTo
UNION ALL
SELECT 'Covers', COUNT(*) FROM Covers
UNION ALL
SELECT 'Records', COUNT(*) FROM Records
UNION ALL
SELECT 'Validates', COUNT(*) FROM Validates
UNION ALL
SELECT 'Flags', COUNT(*) FROM Flags
UNION ALL
SELECT 'Performs', COUNT(*) FROM Performs;

-- ==========================================================
-- 9. Index verification
-- ==========================================================

-- Show indexes added by upgrade_basic_features.sql.
SHOW INDEX FROM Users;
SHOW INDEX FROM CheckIn;
SHOW INDEX FROM StaffAssignment;
SHOW INDEX FROM Service;
SHOW INDEX FROM ServiceHours;
SHOW INDEX FROM WaitTimeHistory;
SHOW INDEX FROM ValidationLog;
SHOW INDEX FROM AuditLog;
