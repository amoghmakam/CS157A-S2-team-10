-- CampusQueue schema.sql
-- Simple, organized SQL Schema based on our original design.
-- Keep all entities, relationship tables, names, and sample data.

CREATE DATABASE IF NOT EXISTS team10;
USE team10;

-- Drop relationship tables first
DROP TABLE IF EXISTS Validates;
DROP TABLE IF EXISTS Flags;
DROP TABLE IF EXISTS Performs;
DROP TABLE IF EXISTS OccursAt;
DROP TABLE IF EXISTS Submits;
DROP TABLE IF EXISTS Records;
DROP TABLE IF EXISTS HasHours;
DROP TABLE IF EXISTS Manages;
DROP TABLE IF EXISTS AssignedTo;
DROP TABLE IF EXISTS Categorizes;
DROP TABLE IF EXISTS IsA;

-- Drop main tables next
DROP TABLE IF EXISTS ValidationLog;
DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS Covers;
DROP TABLE IF EXISTS StaffAssignment;
DROP TABLE IF EXISTS CheckIn;
DROP TABLE IF EXISTS WaitTimeHistory;
DROP TABLE IF EXISTS ServiceHours;
DROP TABLE IF EXISTS Service;
DROP TABLE IF EXISTS ServiceCategory;
DROP TABLE IF EXISTS Admin;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Users;

-- =========================
-- Main entity tables
-- =========================

CREATE TABLE Users (
    userID INT NOT NULL AUTO_INCREMENT,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    PRIMARY KEY (userID),
    UNIQUE (email)
);

-- CASCADE: automatically propagate changes from parent to related child tables.
CREATE TABLE Student (
    studentID INT NOT NULL,
    major VARCHAR(100) NOT NULL,
    grade VARCHAR(20) NOT NULL,
    PRIMARY KEY (studentID),
    FOREIGN KEY (studentID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Staff (
    staffID INT NOT NULL,
    staffName VARCHAR(100) NOT NULL,
    staffRole VARCHAR(50) NOT NULL,
    PRIMARY KEY (staffID),
    FOREIGN KEY (staffID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Admin (
    adminID INT NOT NULL,
    adminName VARCHAR(100) NOT NULL,
    PRIMARY KEY (adminID),
    FOREIGN KEY (adminID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ServiceCategory (
    categoryName VARCHAR(100) NOT NULL,
    categoryDescription VARCHAR(255),
    PRIMARY KEY (categoryName)
);

CREATE TABLE Service (
    serviceName VARCHAR(100) NOT NULL,
    location VARCHAR(150) NOT NULL,
    buildingName VARCHAR(100),
    roomNumber VARCHAR(20),
    capacity INT NOT NULL,
    currentStatus VARCHAR(50) NOT NULL,
    categoryName VARCHAR(100) NOT NULL,
    PRIMARY KEY (serviceName),
    FOREIGN KEY (categoryName) REFERENCES ServiceCategory(categoryName)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE ServiceHours (
    serviceName VARCHAR(100) NOT NULL,
    dayOfWeek VARCHAR(15) NOT NULL,
    openTime TIME,
    closeTime TIME,
    isClosed TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (serviceName, dayOfWeek),
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE CheckIn (
    checkInID INT NOT NULL AUTO_INCREMENT,
    studentID INT NOT NULL,
    serviceName VARCHAR(100) NOT NULL,
    checkInTime DATETIME NOT NULL,
    checkOutTime DATETIME DEFAULT NULL,
    crowdEstimate INT DEFAULT NULL,
    duration INT DEFAULT NULL,
    PRIMARY KEY (checkInID),
    FOREIGN KEY (studentID) REFERENCES Student(studentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE StaffAssignment (
    assignmentID INT NOT NULL AUTO_INCREMENT,
    staffID INT NOT NULL,
    serviceName VARCHAR(100) NOT NULL,
    dateAssigned DATE NOT NULL,
    PRIMARY KEY (assignmentID),
    UNIQUE (staffID, serviceName),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ValidationLog (
    validationID INT NOT NULL AUTO_INCREMENT,
    checkInID INT NOT NULL,
    staffID INT NOT NULL,
    validationType VARCHAR(50) NOT NULL,
    validationReason VARCHAR(255),
    validationTime DATETIME NOT NULL,
    PRIMARY KEY (validationID),
    FOREIGN KEY (checkInID) REFERENCES CheckIn(checkInID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE WaitTimeHistory (
    historyID INT NOT NULL AUTO_INCREMENT,
    serviceName VARCHAR(100) NOT NULL,
    recordDate DATE NOT NULL,
    recordHour INT NOT NULL,
    avgWaitTime DECIMAL(6,2) NOT NULL,
    totalCheckIns INT NOT NULL,
    crowdLevel VARCHAR(50) NOT NULL,
    PRIMARY KEY (historyID),
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE AuditLog (
    auditID INT NOT NULL AUTO_INCREMENT,
    userID INT NOT NULL,
    actionType VARCHAR(100) NOT NULL,
    actionDescription VARCHAR(255) NOT NULL,
    actionTime DATETIME NOT NULL,
    PRIMARY KEY (auditID),
    FOREIGN KEY (userID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================
-- Relationship tables
-- =========================

CREATE TABLE IsA (
    userID INT NOT NULL,
    studentID INT DEFAULT NULL,
    staffID INT DEFAULT NULL,
    adminID INT DEFAULT NULL,
    PRIMARY KEY (userID),
    FOREIGN KEY (userID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (studentID) REFERENCES Student(studentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (adminID) REFERENCES Admin(adminID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Categorizes (
    categoryName VARCHAR(100) NOT NULL,
    serviceName VARCHAR(100) NOT NULL,
    PRIMARY KEY (categoryName, serviceName),
    FOREIGN KEY (categoryName) REFERENCES ServiceCategory(categoryName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE HasHours (
    serviceName VARCHAR(100) NOT NULL,
    dayOfWeek VARCHAR(15) NOT NULL,
    PRIMARY KEY (serviceName, dayOfWeek),
    FOREIGN KEY (serviceName, dayOfWeek) REFERENCES ServiceHours(serviceName, dayOfWeek)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Submits (
    studentID INT NOT NULL,
    checkInID INT NOT NULL,
    PRIMARY KEY (studentID, checkInID),
    FOREIGN KEY (studentID) REFERENCES Student(studentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (checkInID) REFERENCES CheckIn(checkInID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE OccursAt (
    serviceName VARCHAR(100) NOT NULL,
    checkInID INT NOT NULL,
    PRIMARY KEY (serviceName, checkInID),
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (checkInID) REFERENCES CheckIn(checkInID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Manages (
    staffID INT NOT NULL,
    serviceName VARCHAR(100) NOT NULL,
    PRIMARY KEY (staffID, serviceName),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE AssignedTo (
    staffID INT NOT NULL,
    assignmentID INT NOT NULL,
    PRIMARY KEY (staffID, assignmentID),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (assignmentID) REFERENCES StaffAssignment(assignmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Covers (
    serviceName VARCHAR(100) NOT NULL,
    assignmentID INT NOT NULL,
    PRIMARY KEY (serviceName, assignmentID),
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (assignmentID) REFERENCES StaffAssignment(assignmentID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Records (
    serviceName VARCHAR(100) NOT NULL,
    historyID INT NOT NULL,
    PRIMARY KEY (serviceName, historyID),
    FOREIGN KEY (serviceName) REFERENCES Service(serviceName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (historyID) REFERENCES WaitTimeHistory(historyID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Validates (
    staffID INT NOT NULL,
    validationID INT NOT NULL,
    PRIMARY KEY (staffID, validationID),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (validationID) REFERENCES ValidationLog(validationID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Flags (
    checkInID INT NOT NULL,
    validationID INT NOT NULL,
    PRIMARY KEY (checkInID, validationID),
    FOREIGN KEY (checkInID) REFERENCES CheckIn(checkInID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (validationID) REFERENCES ValidationLog(validationID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Performs (
    userID INT NOT NULL,
    auditID INT NOT NULL,
    PRIMARY KEY (userID, auditID),
    FOREIGN KEY (userID) REFERENCES Users(userID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (auditID) REFERENCES AuditLog(auditID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================
-- Sample data
-- =========================

INSERT INTO Users VALUES
(1,'Amogh','Makam','amogh.makam@sjsu.edu','pass123'),
(2,'Suparn','Posina','suparn.posina@sjsu.edu','pass123'),
(3,'Andrea','Tapia-Sandoval','andrea.tapia@sjsu.edu','pass123'),
(4,'John','Doe','john.doe@sjsu.edu','pass123'),
(5,'Jane','Smith','jane.smith@sjsu.edu','pass123'),
(6,'Stephen','Curry','stephen.curry@sjsu.edu','pass123'),
(7,'Lebron','James','lebron.james@sjsu.edu','pass123'),
(8,'Kevin','Durant','kevin.durant@sjsu.edu','test123'),
(9,'Giannis','Antetokounmpo','giannis.antetokounmpo@sjsu.edu','test123'),
(10,'Luka','Doncic','luka.doncic@sjsu.edu','test123'),
(11,'Nikola','Jokic','nikola.jokic@sjsu.edu','test123'),
(12,'Joel','Embiid','joel.embiid@sjsu.edu','test123'),
(13,'Jayson','Tatum','jayson.tatum@sjsu.edu','test123'),
(14,'Devin','Booker','devin.booker@sjsu.edu','test123'),
(15,'Ja','Morant','ja.morant@sjsu.edu','test123'),
(16,'Kawhi','Leonard','kawhi.leonard@sjsu.edu','test123'),
(17,'Paul','George','paul.george@sjsu.edu','test123'),
(18,'Jimmy','Butler','jimmy.butler@sjsu.edu','test123'),
(19,'Damian','Lillard','damian.lillard@sjsu.edu','test123'),
(20,'Anthony','Davis','anthony.davis@sjsu.edu','test123'),
(21,'Shai','Gilgeous-Alexander','shai.gilgeous@sjsu.edu','test123'),
(22,'Trae','Young','trae.young@sjsu.edu','test123'),
(23,'Donovan','Mitchell','donovan.mitchell@sjsu.edu','test123'),
(24,'Zion','Williamson','zion.williamson@sjsu.edu','test123'),
(25,'Jaylen','Brown','jaylen.brown@sjsu.edu','test123');

INSERT INTO Student VALUES
(2,'Computer Science','Junior'),
(4,'Data Science','Senior'),
(5,'Software Engineering','Sophomore'),
(8,'Kinesiology','Senior'),
(9,'Sports Science','Senior'),
(10,'Business','Junior'),
(11,'Nutrition','Senior'),
(12,'Health Science','Senior'),
(13,'Communications','Junior'),
(14,'Marketing','Senior'),
(15,'Exercise Science','Sophomore'),
(16,'Psychology','Senior'),
(17,'Management','Senior'),
(18,'Finance','Senior'),
(19,'Music','Senior'),
(20,'Biology','Senior'),
(21,'Data Analytics','Junior'),
(22,'Economics','Junior'),
(23,'Public Health','Sophomore'),
(24,'Sociology','Sophomore'),
(25,'Engineering','Junior');

INSERT INTO Staff VALUES
(2,'Amogh Makam','Gym Staff'),
(3,'Suparn Posina','Dining Staff');

INSERT INTO Admin VALUES
(6,'Stephen Curry'),
(7,'Lebron James');

INSERT INTO ServiceCategory VALUES
('Advising','Academic advising centers'),
('Dining','Campus dining services'),
('Fitness','Campus fitness and recreation'),
('Parking','Campus parking garages');

INSERT INTO Service VALUES
('Academic Advising','Student Services Center','SSC','210',100,'Open','Advising'),
('Dining Commons','Central Campus','DC','1',500,'Busy','Dining'),
('North Garage','North Campus','North Garage','N/A',800,'Available','Parking'),
('SRAC Gym','South Campus','SRAC','101',300,'Open','Fitness');

INSERT INTO ServiceHours VALUES
('Academic Advising','Monday','08:00:00','17:00:00',0),
('Dining Commons','Monday','07:00:00','20:00:00',0),
('North Garage','Monday','00:00:00','23:59:59',0),
('SRAC Gym','Monday','06:00:00','22:00:00',0),
('SRAC Gym','Tuesday','06:00:00','22:00:00',0);

INSERT INTO WaitTimeHistory VALUES
(1,'SRAC Gym','2026-03-16',9,12.50,40,'Moderate'),
(2,'Dining Commons','2026-03-16',12,18.75,85,'High'),
(3,'Academic Advising','2026-03-16',14,9.25,20,'Low');

INSERT INTO CheckIn VALUES
(1,2,'Dining Commons','2026-01-14 12:08:00','2026-01-14 12:46:00',236,38),
(2,4,'SRAC Gym','2026-01-22 07:42:00','2026-01-22 09:01:00',118,79),
(3,5,'Academic Advising','2026-02-03 14:17:00','2026-02-03 14:49:00',41,32),
(4,8,'SRAC Gym','2026-02-11 08:26:00','2026-02-11 09:54:00',153,88),
(5,9,'SRAC Gym','2026-02-27 17:11:00','2026-02-27 18:36:00',177,85),
(6,10,'Dining Commons','2026-03-05 11:39:00','2026-03-05 12:21:00',251,42),
(7,11,'Dining Commons','2026-03-18 18:04:00','2026-03-18 18:43:00',289,39),
(8,12,'Academic Advising','2026-03-29 09:48:00','2026-03-29 10:19:00',52,31),
(9,13,'SRAC Gym','2026-04-07 15:06:00','2026-04-07 16:24:00',198,78),
(10,14,'Dining Commons','2026-04-21 13:14:00','2026-04-21 13:57:00',274,43),
(11,15,'SRAC Gym','2026-05-02 19:02:00','2026-05-02 20:31:00',221,89),
(12,16,'Academic Advising','2026-05-15 10:23:00','2026-05-15 10:51:00',47,28),
(13,17,'North Garage','2026-05-28 08:02:00','2026-05-28 16:41:00',612,519),
(14,18,'North Garage','2026-06-10 09:17:00','2026-06-10 17:28:00',658,491),
(15,19,'SRAC Gym','2026-06-24 18:33:00','2026-06-24 19:46:00',187,73),
(16,20,'Dining Commons','2026-07-09 12:27:00','2026-07-09 13:05:00',305,38),
(17,21,'Academic Advising','2026-07-22 11:41:00','2026-07-22 12:14:00',57,33),
(18,22,'Dining Commons','2026-08-06 17:56:00','2026-08-06 18:37:00',268,41),
(19,23,'SRAC Gym','2026-08-19 06:58:00','2026-08-19 08:11:00',142,73),
(20,24,'Academic Advising','2026-09-03 14:09:00','2026-09-03 14:36:00',49,27),
(21,25,'North Garage','2026-09-21 10:12:00','2026-09-21 18:03:00',694,471),
(22,8,'Dining Commons','2026-10-04 11:52:00','2026-10-04 12:29:00',244,37),
(23,9,'SRAC Gym','2026-10-16 16:44:00','2026-10-16 18:02:00',205,78),
(24,10,'North Garage','2026-10-29 08:21:00','2026-10-29 15:58:00',573,457),
(25,11,'Academic Advising','2026-11-12 09:36:00','2026-11-12 10:08:00',44,32),
(26,12,'Dining Commons','2026-11-25 18:18:00','2026-11-25 18:59:00',281,41),
(27,13,'SRAC Gym','2026-12-03 07:47:00','2026-12-03 09:05:00',161,78),
(28,14,'Dining Commons','2026-12-11 12:05:00','2026-12-11 12:47:00',259,42),
(29,15,'Academic Advising','2026-12-18 13:27:00',NULL,61,NULL),
(30,21,'SRAC Gym','2026-12-22 18:11:00',NULL,214,NULL);

INSERT INTO StaffAssignment VALUES
(10,2,'SRAC Gym','2026-03-01'),
(11,3,'Dining Commons','2026-03-01');

INSERT INTO AuditLog VALUES
(1,2,'Update Service Status','Marked SRAC Gym as Open','2026-03-17 08:50:00'),
(2,3,'Validate Check-In','Reviewed dining commons activity','2026-03-17 12:45:00'),
(3,4,'Assign Staff','Assigned staff to Dining Commons','2026-03-01 09:00:00');

INSERT INTO ValidationLog VALUES
(1,1,3,'Validated','Dining visit appears normal','2026-01-14 12:52:00'),
(2,2,2,'Validated','Normal gym session duration','2026-01-22 09:08:00'),
(3,3,2,'Flagged','Check-in entered near closing window','2026-02-03 15:02:00'),
(4,4,2,'Validated','Expected student gym activity','2026-02-11 10:01:00'),
(5,5,2,'Flagged','Crowd estimate was unusually high','2026-02-27 18:40:00'),
(6,6,3,'Validated','Lunch traffic consistent with service pattern','2026-03-05 12:29:00'),
(7,7,3,'Validated','Evening dining usage looks valid','2026-03-18 18:51:00'),
(8,8,2,'Validated','Short advising session recorded correctly','2026-03-29 10:24:00'),
(9,9,2,'Validated','Workout duration reasonable','2026-04-07 16:31:00'),
(10,10,3,'Flagged','Dining crowd estimate slightly above average','2026-04-21 14:06:00'),
(11,11,2,'Validated','Long evening gym session but still reasonable','2026-05-02 20:36:00'),
(12,12,2,'Validated','Brief advising record seems legitimate','2026-05-15 11:00:00'),
(13,13,2,'Flagged','Garage stay was unusually long','2026-05-28 16:49:00'),
(14,14,2,'Validated','North Garage occupancy aligns with weekday traffic','2026-06-10 17:34:00'),
(15,15,2,'Validated','Standard recreation visit','2026-06-24 19:50:00'),
(16,16,3,'Flagged','High dining crowd estimate requires review','2026-07-09 13:11:00'),
(17,17,2,'Validated','Academic advising attendance acceptable','2026-07-22 12:20:00'),
(18,18,3,'Validated','Dinner rush record appears normal','2026-08-06 18:43:00'),
(19,19,2,'Validated','Morning gym entry looks normal','2026-08-19 08:18:00'),
(20,20,2,'Validated','Short advising session confirmed','2026-09-03 14:42:00'),
(21,21,2,'Flagged','Parking duration longer than expected','2026-09-21 18:09:00'),
(22,22,3,'Validated','Midday dining activity confirmed','2026-10-04 12:34:00'),
(23,23,2,'Validated','Afternoon gym traffic valid','2026-10-16 18:07:00'),
(24,24,2,'Validated','Garage usage consistent with weekday schedule','2026-10-29 16:06:00'),
(25,25,2,'Flagged','Possible duplicate advising submission under review','2026-11-12 10:14:00'),
(26,26,3,'Validated','Dining check-out time reasonable','2026-11-25 19:04:00'),
(27,27,2,'Validated','Morning gym use recorded normally','2026-12-03 09:10:00'),
(28,28,3,'Validated','Dining visit fits expected noon activity','2026-12-11 12:53:00'),
(29,29,2,'Flagged','Active advising session has no check-out yet','2026-12-18 15:02:00'),
(30,30,2,'Flagged','Gym session still active; follow-up needed','2026-12-22 20:03:00');

INSERT INTO IsA VALUES
(2,NULL,2,NULL),
(3,NULL,3,NULL),
(5,5,NULL,NULL),
(6,NULL,NULL,6),
(8,8,NULL,NULL),
(9,9,NULL,NULL),
(10,10,NULL,NULL),
(11,11,NULL,NULL),
(12,12,NULL,NULL),
(13,13,NULL,NULL),
(14,14,NULL,NULL),
(15,15,NULL,NULL),
(16,16,NULL,NULL),
(17,17,NULL,NULL),
(18,18,NULL,NULL),
(19,19,NULL,NULL),
(20,20,NULL,NULL),
(21,21,NULL,NULL),
(22,22,NULL,NULL),
(23,23,NULL,NULL),
(24,24,NULL,NULL),
(25,25,NULL,NULL);

INSERT INTO Categorizes VALUES
('Advising','Academic Advising'),
('Dining','Dining Commons'),
('Parking','North Garage'),
('Fitness','SRAC Gym');

INSERT INTO AssignedTo VALUES
(2,10),
(3,11);

INSERT INTO Manages VALUES
(3,'Dining Commons'),
(2,'SRAC Gym');

INSERT INTO HasHours VALUES
('Academic Advising','Monday'),
('Dining Commons','Monday'),
('North Garage','Monday'),
('SRAC Gym','Monday'),
('SRAC Gym','Tuesday');

INSERT INTO Records VALUES
('SRAC Gym',1),
('Dining Commons',2),
('Academic Advising',3);

INSERT INTO Submits VALUES
(2,1),
(4,2),
(5,3),
(8,4),
(9,5),
(10,6),
(11,7),
(12,8),
(13,9),
(14,10),
(15,11),
(16,12),
(17,13),
(18,14),
(19,15),
(20,16),
(21,17),
(22,18),
(23,19),
(24,20),
(25,21),
(8,22),
(9,23),
(10,24),
(11,25),
(12,26),
(13,27),
(14,28),
(15,29),
(21,30);

INSERT INTO OccursAt VALUES
('Dining Commons',1),
('SRAC Gym',2),
('Academic Advising',3),
('SRAC Gym',4),
('SRAC Gym',5),
('Dining Commons',6),
('Dining Commons',7),
('Academic Advising',8),
('SRAC Gym',9),
('Dining Commons',10),
('SRAC Gym',11),
('Academic Advising',12),
('North Garage',13),
('North Garage',14),
('SRAC Gym',15),
('Dining Commons',16),
('Academic Advising',17),
('Dining Commons',18),
('SRAC Gym',19),
('Academic Advising',20),
('North Garage',21),
('Dining Commons',22),
('SRAC Gym',23),
('North Garage',24),
('Academic Advising',25),
('Dining Commons',26),
('SRAC Gym',27),
('Dining Commons',28),
('Academic Advising',29),
('SRAC Gym',30);

INSERT INTO Covers VALUES
('SRAC Gym',10),
('Dining Commons',11);

INSERT INTO Performs VALUES
(2,1),
(3,2),
(4,3);

INSERT INTO Flags VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(6,6),
(7,7),
(8,8),
(9,9),
(10,10),
(11,11),
(12,12),
(13,13),
(14,14),
(15,15),
(16,16),
(17,17),
(18,18),
(19,19),
(20,20),
(21,21),
(22,22),
(23,23),
(24,24),
(25,25),
(26,26),
(27,27),
(28,28),
(29,29),
(30,30);

INSERT INTO Validates VALUES
(3,1),
(2,2),
(2,3),
(2,4),
(2,5),
(3,6),
(3,7),
(2,8),
(2,9),
(3,10),
(2,11),
(2,12),
(2,13),
(2,14),
(2,15),
(3,16),
(2,17),
(3,18),
(2,19),
(2,20),
(2,21),
(3,22),
(2,23),
(2,24),
(2,25),
(3,26),
(2,27),
(3,28),
(2,29),
(2,30);

-- ==========================================================
-- Automatically assign next number when inserting new row
-- ==========================================================

ALTER TABLE Users AUTO_INCREMENT = 26;
ALTER TABLE StaffAssignment AUTO_INCREMENT = 12;
ALTER TABLE AuditLog AUTO_INCREMENT = 4;
ALTER TABLE ValidationLog AUTO_INCREMENT = 31;
ALTER TABLE WaitTimeHistory AUTO_INCREMENT = 4;
ALTER TABLE CheckIn AUTO_INCREMENT = 31;
