# CampusQueue – CS157A Team 10

## Overview

CampusQueue is a web-based application designed to help students view **real-time and predicted wait times** for campus services such as gyms, dining halls, advising centers, and parking garages.

The system uses **student check-in and check-out data** combined with **historical records** to estimate crowd levels and waiting times.

---

## Features

### Student

* View campus services and current status
* See predicted wait times and crowd levels
* Check-in and check-out of services
* View historical trends

### Staff

* Manage assigned services (status, capacity, hours)
* Validate suspicious check-ins
* View analytics for their services

### Admin

* Add/edit/remove services
* Assign staff to services
* Monitor system activity and audit logs

---

## Tech Stack

* **Frontend:** HTML, CSS, JavaScript, JSP
* **Backend:** Java Servlets (Apache Tomcat)
* **Database:** MySQL
* **Database Access:** JDBC

---

## Project Structure

```
CS157A-S2-team-10/
│
├── sql/
│   └── schema.sql              # Full database schema + sample data
│
├── src/main/java/
│   ├── dao/                    # Database access layer
│   ├── model/                  # Java Objects
│   ├── servlet/                # Controller - flow and logic
│   ├── filter/                 # Authentication filtering by views
│   └── util/
│       └── DBUtil.java         # Database connection
│
├── web/
│   ├── index.jsp               # Landing page
│   ├── student/                # Student views
│   ├── staff/                  # Staff views
│   ├── admin/                  # Admin views
│   └── WEB-INF/
│       ├── web.xml             # Servlet config
│       └── lib/
│           └── mysql-connector.jar
│
└── README.md
```

---

## Database Setup

### 1. Create Database

```sql
CREATE DATABASE team10;
USE team10;
```

### 2. Run Schema

Open MySQL Workbench or CLI and run:

```sql
SOURCE path/to/schema.sql;
```

This will:

* Create all tables
* Insert sample data
* Set AUTO_INCREMENT values

---

## JDBC Configuration

Update database credentials in:

```java
src/main/java/util/DBUtil.java
```

```java
private static final String URL = "jdbc:mysql://localhost:3306/team10";
private static final String USER = "root";
private static final String PASSWORD = "";
```

---

## Running the Project (Apache Tomcat)

### 1. Deploy to Tomcat

* Copy project into Tomcat `webapps/` folder
  OR
* Deploy with IntelliJ or Eclipse

### 2. Start Tomcat

```bash
cd apache-tomcat/bin
startup.bat   (Windows)
./startup.sh  (Mac/Linux)
```

### 3. Open in Browser

```
http://localhost:8080/CS157A-S2-team-10/
```

---

## How to Demo (IMPORTANT)

### Login Accounts

Use sample users from database:

#### Students

* email: `john.doe@sjsu.edu`
* password: `pass123`

#### Staff

* email: `suparn.posina@sjsu.edu`

#### Admin

* email: `stephen.curry@sjsu.edu`

---

### Demo Flow

#### 1. Student Demo

* Login
* View services
* Click a service
* Check-in
* Check-out
* View updated wait time

#### 2. Staff Demo

* Login
* View assigned services
* Update service status
* Validate check-ins

#### 3. Admin Demo

* Login
* Add/edit services
* Assign staff
* View audit logs

---

## Architecture

CampusQueue follows a **3-tier architecture**:

### 1. Presentation Layer

* JSP pages (UI)

### 2. Application Layer

* Servlets handle logic and routing

### 3. Data Layer

* DAO -> interact with MySQL via JDBC

---

## DAO Layer

The DAO layer is responsible for:

* Running SQL queries
* Fetching data from database
* Converting data into Java objects

Example:

```java
ServiceDao.getAllServices()
```

---

## Key Concepts Used

* JDBC (Database Connection)
* Model-View-Controller Pattern
* Role-based Access Control
* Session Handling
* Relational Database Design
* Foreign Keys & Relationships

---

## Future Improvements

* Better UI/UX (maybe React frontend)
* Real-time updating with WebSockets (TBD)
* Machine-learning integration for predictions
* Mobile App Version

---

## Team Members

* Amogh Makam
* Suparn Posina
* Andrea Tapia-Sandoval

---

## Notes

For CS157A (Intro Database Management Systems)

