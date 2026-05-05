# CampusQueue Grading Checklist

Use this checklist to verify the project before submission or demo.

## Build and Deployment

- [ ] Project uses Tomcat 10 because the Java code imports `jakarta.servlet`.
- [ ] Project compiles with Tomcat 10 `servlet-api.jar` and `jsp-api.jar`.
- [ ] MySQL connector jar is available either in `web/WEB-INF/lib/` or Tomcat's `lib/` folder.
- [ ] `scripts/build_deploy_mac.sh` compiles the app and deploys it as `CampusQueue`.
- [ ] App deploys to Tomcat without copying raw `src` into `webapps`.
- [ ] App opens at `http://localhost:8080/CampusQueue/HomeServlet` or the configured app name.

## Database

- [ ] `schema.sql` creates all entity and relationship tables.
- [ ] `upgrade_basic_features.sql` adds account moderation support and indexes.
- [ ] `demo_accounts.sql` creates the official student, staff, and admin demo accounts.
- [ ] `test_basic_features.sql` runs and displays users, services, active check-ins, staff assignments, validations, and audit logs.
- [ ] `scripts/setup_db_mac.sh` runs schema, upgrades, demo accounts, and verification queries in the correct order.
- [ ] Foreign keys are used for the main relationships.
- [ ] Relationship tables are populated by sample data and by Java runtime actions.

## Official Demo Accounts

- [ ] Student demo login works: `student.demo@sjsu.edu` / `pass123`.
- [ ] Staff demo login works: `staff.demo@sjsu.edu` / `pass123`.
- [ ] Admin demo login works: `admin.demo@sjsu.edu` / `pass123`.
- [ ] Staff demo account is assigned to SRAC Gym.

## Student Requirements

- [ ] Student can log in.
- [ ] Student can view services.
- [ ] Student can filter services by category.
- [ ] Student can view predicted wait time and crowd level.
- [ ] Student can open service detail page.
- [ ] Student can view service hours and historical trends.
- [ ] Student can check in.
- [ ] Student cannot create a second active check-in.
- [ ] Student can check out.
- [ ] Check-out stores duration.

## Staff Requirements

- [ ] Staff can log in.
- [ ] Staff sees only assigned services.
- [ ] Staff can update status and capacity for assigned services.
- [ ] Staff can update service hours for assigned services.
- [ ] Staff cannot update services they are not assigned to.
- [ ] Staff can validate or flag check-ins for assigned services.
- [ ] Validation inserts into `ValidationLog`, `Validates`, and `Flags`.

## Admin Requirements

- [ ] Admin can log in.
- [ ] Admin can add services.
- [ ] Admin can edit services.
- [ ] Admin can deactivate services.
- [ ] Admin can remove services.
- [ ] Admin can add, edit, and remove service categories.
- [ ] Admin can assign staff to services.
- [ ] Staff assignment inserts into `StaffAssignment`, `AssignedTo`, `Covers`, and `Manages`.
- [ ] Admin can suspend and reactivate users.
- [ ] Suspended users cannot log in.
- [ ] Admin can view audit logs.

## Security and Accountability

- [ ] New passwords are hashed using SHA-256.
- [ ] Existing plain-text demo passwords are upgraded to hashes after successful login.
- [ ] Sessions expire after 30 minutes of inactivity.
- [ ] `AuthFilter` protects student, staff, and admin routes.
- [ ] Staff actions are checked server-side against assigned services.
- [ ] Audit actions insert into `AuditLog` and `Performs`.

## Documentation and Comments

- [ ] `README.md` explains setup, running, accounts, architecture, database coverage, and demo flow.
- [ ] `RUN_AND_TEST.md` gives exact local run/test commands.
- [ ] `IMPLEMENTATION_NOTES.md` explains the implementation in intro-class terms.
- [ ] `GRADING_CHECKLIST.md` provides a final verification checklist.
- [ ] Core DAO classes have comments explaining database operations.
- [ ] Core Servlet classes have comments explaining route behavior.
- [ ] JSP pages include comments for major forms/actions.
- [ ] SQL files include comments explaining schema/setup/test/demo purpose.

## Final Before Submission

- [ ] Run `git pull origin main`.
- [ ] Run `sh scripts/setup_db_mac.sh`.
- [ ] Run `sh scripts/build_deploy_mac.sh`.
- [ ] Log in with all three official demo accounts.
- [ ] Walk through the Student, Staff, and Admin demo flows.
- [ ] Confirm audit log entries appear after demo actions.
