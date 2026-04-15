
-- ==========================================================
-- Dedicated Staff Account
-- ==========================================================

INSERT INTO Users (userID, firstName, lastName, email, password)
VALUES (26, 'Staff', 'Demo', 'staff.demo@sjsu.edu', 'pass123');

INSERT INTO Staff (staffID, staffName, staffRole)
VALUES (26, 'Staff Demo', 'Service Staff');

INSERT INTO IsA (userID, studentID, staffID, adminID)
VALUES (26, NULL, 26, NULL);

INSERT INTO StaffAssignment (assignmentID, staffID, serviceName, dateAssigned)
VALUES (12, 26, 'SRAC Gym', '2026-03-01');

INSERT INTO AssignedTo (staffID, assignmentID)
VALUES (26, 12);

INSERT INTO Manages (staffID, serviceName)
VALUES (26, 'SRAC Gym');

INSERT INTO Covers (serviceName, assignmentID)
VALUES ('SRAC Gym', 12);


-- ==========================================================
-- Dedicated Admin Account
-- ==========================================================

INSERT INTO Users (userID, firstName, lastName, email, password)
VALUES (27, 'Admin', 'Demo', 'admin.demo@sjsu.edu', 'pass123');

INSERT INTO Admin (adminID, adminName)
VALUES (27, 'Admin Demo');

INSERT INTO IsA (userID, studentID, staffID, adminID)
VALUES (27, NULL, NULL, 27);
