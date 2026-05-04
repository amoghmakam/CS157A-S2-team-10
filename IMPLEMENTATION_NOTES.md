# CampusQueue Implementation Notes

This file explains the important implementation details in simple terms for an introductory database management systems project.

## Official Demo Accounts

These accounts are created by `sql/demo_accounts.sql` and are automatically loaded by `scripts/setup_db_mac.sh`.

| Role | Email | Password | Notes |
|---|---|---|---|
| Student | `student.demo@sjsu.edu` | `pass123` | Used to demonstrate service browsing, check-in, check-out, and history. |
| Staff | `staff.demo@sjsu.edu` | `pass123` | Assigned to SRAC Gym so assigned-service staff features work immediately. |
| Admin | `admin.demo@sjsu.edu` | `pass123` | Used to demonstrate service management, staff assignment, user moderation, and audit logs. |

The original sample accounts still work as backup demo data.

---

## Scripts

### `scripts/setup_db_mac.sh`

This script resets and prepares the database. It runs:

1. `sql/schema.sql`
2. `sql/upgrade_basic_features.sql`
3. `sql/demo_accounts.sql`
4. `sql/test_basic_features.sql`

This gives the grader a repeatable way to rebuild the database, seed demo accounts, and verify core tables.

### `scripts/build_deploy_mac.sh`

This script compiles and deploys the app to Tomcat 10. It:

1. Finds Tomcat using `TOMCAT_HOME`.
2. Finds the MySQL connector jar either in the project or Tomcat `lib` folder.
3. Compiles Java source files into `build/classes`.
4. Deploys the app as `CampusQueueFork`.
5. Copies compiled classes into `WEB-INF/classes`.
6. Copies the MySQL connector into `WEB-INF/lib`.
7. Restarts Tomcat.

---

## Security

- `PasswordUtil` hashes new passwords using SHA-256.
- `UserDao.login()` checks the stored password against the hash.
- Demo passwords such as `pass123` are initially inserted as plain text only for simple demo seeding.
- When a demo user logs in successfully, `UserDao.login()` upgrades that password to a SHA-256 hash.
- `LoginServlet` sets a 30-minute session timeout.
- `AuthFilter` protects student, staff, and admin routes.
- Admins can suspend or reactivate users using `UserStatusServlet`.

---

## Student Features

- Students can view services and predicted wait times.
- Students can filter services by category.
- Students can open service detail pages.
- Students can view service hours and historical trends.
- Students can check in and check out.
- `CheckInDao` blocks more than one active check-in for the same student.
- Check-out stores the duration in minutes.
- New check-ins update `CheckIn`, `Submits`, and `OccursAt`.

---

## Staff Features

- Staff can only see services assigned to them.
- Staff updates are checked in the servlet/DAO layer so a user cannot manually post a different service.
- Staff can update service status, capacity, and operating hours.
- Staff can validate or flag check-ins only for assigned services.
- Validations update `ValidationLog`, `Validates`, and `Flags`.

---

## Admin Features

- Admins can add services.
- Admins can edit services.
- Admins can deactivate services by marking them closed.
- Admins can remove services.
- Admins can assign staff to services.
- Admins can suspend or reactivate users.
- Admins can view audit logs.
- Staff assignments update `StaffAssignment`, `AssignedTo`, `Covers`, and `Manages`.
- Audit actions update `AuditLog` and `Performs`.

---

## Database Relationship Tables

The project keeps the ERD relationship tables synchronized in beginner-friendly Java code:

- New check-ins update `CheckIn`, `Submits`, and `OccursAt`.
- Staff assignments update `StaffAssignment`, `AssignedTo`, `Covers`, and `Manages`.
- Validations update `ValidationLog`, `Validates`, and `Flags`.
- Audit actions update `AuditLog` and `Performs`.

---

## Wait Time Prediction

The prediction is intentionally simple and explainable:

```text
predicted wait = average past duration + small active-crowd penalty
```

This uses normal SQL averages and a small Java calculation rather than advanced machine learning. That keeps the implementation appropriate for an intro DBMS class while still using both live activity and historical data.

---

## Final Setup Order

Use this order for a clean demo:

```bash
git pull origin main
sh scripts/setup_db_mac.sh
export TOMCAT_HOME="/Users/oops/Downloads/tomcat10"
export CATALINA_HOME="$TOMCAT_HOME"
export DB_USER="root"
export DB_PASSWORD="campusqueue123"
export DB_URL="jdbc:mysql://localhost:3306/team10?serverTimezone=UTC"
sh scripts/build_deploy_mac.sh
```

Then open:

```text
http://localhost:8080/CampusQueueFork/HomeServlet
```
