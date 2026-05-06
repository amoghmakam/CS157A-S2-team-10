# CampusQueue – CS157A Team 10

CampusQueue is a web-based campus service wait-time platform for CS157A. It lets students view current and predicted wait times for campus services, submit check-ins/check-outs, and use historical trends to decide when to visit. Staff can manage assigned services and validate activity, while administrators can manage services, staff assignments, users, and audit logs.

This project uses beginner-friendly Java/JSP/Servlet/JDBC code and a MySQL database. The implementation is intentionally simple enough for an introductory database management systems course while still covering the required database, role, and application functionality.

---

## Main Features

### Student

- Log in with a student account.
- View campus services, categories, current status, crowd level, and predicted wait time.
- Filter services by category.
- Open a service detail page with location, capacity, hours, crowd level, wait estimate, and historical trends.
- Submit a check-in when entering a service.
- Prevent more than one active check-in for the same student.
- Submit a check-out and store the visit duration.
- View personal check-in/check-out history.

### Staff

- Log in with a staff account.
- View only services assigned to that staff member.
- Update status and capacity for assigned services.
- Update operating hours for assigned services.
- Review recent check-ins for assigned services.
- Validate or flag check-in records.
- Keep validation relationship tables synchronized.

### Admin

- Log in with an admin account.
- Add new services.
- Edit existing services.
- Deactivate services by marking them closed.
- Remove services.
- Add, edit, and remove service categories.
- Assign staff to services.
- Suspend or reactivate user accounts.
- View system-wide audit logs.
- Keep staff assignment and audit relationship tables synchronized.

---

## Tech Stack

- **Frontend:** HTML, CSS, JavaScript, JSP
- **Backend:** Java Servlets on Apache Tomcat 10
- **Database:** MySQL Community Server
- **Database Access:** JDBC
- **Architecture:** Three-tier architecture: JSP presentation layer, Servlet/DAO application layer, MySQL data layer

---

## Project Structure

```text
CS157A-S2-team-10/
├── README.md                       # Main project overview and setup guide
├── DEMO.md                         # Information to demo project
├── RUN_AND_TEST.md                 # Detailed local run/test guide
├── IMPLEMENTATION_NOTES.md         # Explanation of important implementation choices
├── CHECKLIST.md                    # Final requirement checklist for demo/submission
├── scripts/
│   ├── setup_db_mac.sh             # Rebuilds DB, applies upgrades, seeds demo accounts, runs tests
│   └── build_deploy_mac.sh         # Compiles Java and deploys to Tomcat 10
├── sql/
│   ├── schema.sql                  # Main schema, relationship tables, and sample data
│   ├── upgrade_basic_features.sql  # Account-status column and helpful indexes
│   ├── demo_accounts.sql           # Easy demo accounts for student/staff/admin
│   └── test_basic_features.sql     # SQL verification queries
├── src/main/java/
│   ├── dao/                        # JDBC data access classes
│   ├── filter/                     # Login and role access filter
│   ├── model/                      # Java model objects
│   ├── servlet/                    # Request handling / controller logic
│   └── util/                       # DBUtil and PasswordUtil helpers
└── web/
    ├── index.jsp                   # Landing/login page
    ├── css/                        # Stylesheet for web application
    ├── student/                    # Student JSP pages
    ├── staff/                      # Staff JSP pages
    ├── admin/                      # Admin JSP pages
    └── WEB-INF/                    # Web config and optional library folder
```

---

## Recommended Demo Accounts

These are created by `sql/demo_accounts.sql`, which is run automatically by `scripts/setup_db_mac.sh`.

| Role | Email | Password |
|---|---|---|
| Student | `student.demo@sjsu.edu` | `pass123` |
| Staff | `staff.demo@sjsu.edu` | `pass123` |
| Admin | `admin.demo@sjsu.edu` | `pass123` |

The staff demo account is assigned to **SRAC Gym** so staff functionality can be demonstrated immediately.

Backup sample accounts also exist:

| Role | Email | Password |
|---|---|---|
| Student | `john.doe@sjsu.edu` | `pass123` |
| Staff | `suparn.posina@sjsu.edu` | `pass123` |
| Admin | `stephen.curry@sjsu.edu` | `pass123` |

---

## Local Setup and Run Instructions

The tested local setup uses:

- Tomcat 10 at `/Users/oops/Downloads/tomcat10`
- MySQL database named `team10`
- MySQL connector jar either in the project or in Tomcat's `lib` folder

### 1. Clone the fork

```bash
cd ~/Downloads
git clone https://github.com/amoghmakam/CS157A-S2-team-10.git campusqueue
cd campusqueue
```

### 2. Set environment variables

```bash
export TOMCAT_HOME="/Users/oops/Downloads/tomcat10"
export CATALINA_HOME="$TOMCAT_HOME"
export DB_USER="root"
export DB_PASSWORD="campusqueue123"
export DB_URL="jdbc:mysql://localhost:3306/team10?serverTimezone=UTC"
```

If your local MySQL root password is different, replace `campusqueue123` with your actual MySQL password.

### 3. Rebuild and verify the database

```bash
sh scripts/setup_db_mac.sh
```

This script runs:

```bash
mysql -u root -p < sql/schema.sql
mysql -u root -p team10 < sql/upgrade_basic_features.sql
mysql -u root -p team10 < sql/demo_accounts.sql
mysql -u root -p team10 < sql/test_basic_features.sql
```

### 4. Compile and deploy to Tomcat

```bash
sh scripts/build_deploy_mac.sh
```

The deploy script:

- Finds Tomcat 10 using `TOMCAT_HOME`.
- Uses the MySQL connector jar from either the project or Tomcat `lib` folder.
- Compiles all Java source files into `build/classes`.
- Deploys the app as `CampusQueue`.
- Copies compiled classes into `WEB-INF/classes`.
- Copies the MySQL connector into `WEB-INF/lib`.
- Restarts Tomcat.

### 5. Open the app

```text
http://localhost:8080/CampusQueue/HomeServlet
```

---

## Demo Flow

### Student Demo

1. Log in as `student.demo@sjsu.edu`.
2. View services and predicted wait times.
3. Filter services by category.
4. Open a service detail page.
5. Submit a check-in.
6. Attempt a second active check-in and confirm it is blocked.
7. Submit check-out and confirm duration/history updates.

### Staff Demo

1. Log in as `staff.demo@sjsu.edu`.
2. Confirm only assigned service(s) appear.
3. Update service status/capacity.
4. Update service hours.
5. Validate or flag a check-in.
6. Confirm validation history updates.

### Admin Demo

1. Log in as `admin.demo@sjsu.edu`.
2. Add a test service.
3. Edit that service.
4. Deactivate that service.
5. Remove that test service.
6. Assign staff to a service.
7. Suspend and reactivate a user.
8. View audit logs.

---

## Database Design Coverage

The database includes the required entity tables:

- `Users`, `Student`, `Staff`, `Admin`
- `ServiceCategory`, `Service`, `ServiceHours`
- `CheckIn`, `StaffAssignment`, `ValidationLog`, `WaitTimeHistory`, `AuditLog`

It also includes relationship tables from the ERD/report:

- `IsA`, `Categorizes`, `HasHours`, `Submits`, `OccursAt`, `Manages`, `AssignedTo`, `Covers`, `Records`, `Validates`, `Flags`, `Performs`

The application keeps relationship tables synchronized during runtime actions:

- New check-ins update `CheckIn`, `Submits`, and `OccursAt`.
- Staff assignments update `StaffAssignment`, `AssignedTo`, `Covers`, and `Manages`.
- Validations update `ValidationLog`, `Validates`, and `Flags`.
- Audit actions update `AuditLog` and `Performs`.

---

## Security and Access Control

- Passwords are not stored as plain text for new registrations.
- `PasswordUtil` hashes new passwords with SHA-256.
- Old demo passwords like `pass123` are accepted once and upgraded to hashes after login.
- Sessions expire after 30 minutes of inactivity.
- `AuthFilter` protects student, staff, and admin routes.
- Staff actions are checked server-side so staff can only update/validate assigned services.
- Admins can suspend/reactivate accounts using account status.

---

## Important Notes

- Use **Tomcat 10**, because the Java code uses `jakarta.servlet` imports.
- In zsh/macOS terminal, use forward slashes such as `sql/schema.sql`, not Windows backslashes.
- If MySQL says access denied, the local MySQL password does not match `DB_PASSWORD`.
- The project is intentionally implemented with plain Servlets, JSP, JDBC, and SQL for an intro DBMS class.

---

## Team Contributions

### Amogh Makam
- 

### Suparn Posina
- Contributed to the CampusQueue project idea, planning, and database design.
- Created ERD diagram for overall application functionality.
- Implemented and finalized major full-stack functionality for the CampusQueue web application.
- Worked on Java Servlet, JSP, DAO, model, utility, SQL, and Tomcat/MySQL integration.
- Added role-based workflows for students, staff, and administrators.
- Added demo accounts, setup scripts, database verification scripts, documentation updates, and final deployment cleanup.

### Andrea Tapia-Sandoval
- Built and styled the homepage and initial project structure, including login
   and signup card views.                                                       
  - Added 5-minute session timeout to the web application.                      
  - Fixed the student dashboard checkout button placement and active service    
  display in the Account Status card.                                           
  - Implemented category filter UI on the home page and student dashboard.      
  - Added audit log display panel to the admin dashboard.                       
  - Built the 24-hour crowd trend prediction label on service cards showing
  expected peak times.                                                          
  - Created historical wait-time bar visualizations by day of week and hour of
  day on the service detail page, with color-coded crowd levels and a           
  best-time-to-visit recommendation.
  - Implemented per-service operational analytics panels on the staff dashboard,
   showing day bars, hour bars, and event volume charts for each assigned       
  service.
  - Implemented per-service operational analytics panels on the admin dashboard 
  for all services.                                                             
  - Managed code integration by reviewing and merging pull requests throughout
  the project.              
