# CampusQueue Grading Checklist

Use this checklist to verify the project before submission or demo.

## Build and Deployment

- [ ] Project compiles with Tomcat 10 `servlet-api.jar` and `jsp-api.jar`.
- [ ] MySQL connector jar exists in `web/WEB-INF/lib/mysql-connector-j-9.6.0.jar`.
- [ ] App deploys to Tomcat without copying `src` into `webapps`.
- [ ] App opens at `http://localhost:8080/CampusQueueFork/HomeServlet` or the configured app name.

## Database

- [ ] `schema.sql` creates all entity and relationship tables.
- [ ] `upgrade_basic_features.sql` adds account moderation support and indexes.
- [ ] `test_basic_features.sql` runs and displays users, services, active check-ins, staff assignments, validations, and audit logs.
- [ ] Foreign keys are used for the main relationships.
- [ ] Relationship tables are populated by sample data and by Java runtime actions.

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
- [ ] Audit actions insert into `AuditLog` and `Performs`.

## Documentation and Comments

- [ ] `README.md` explains setup, running, accounts, and demo flow.
- [ ] `IMPLEMENTATION_NOTES.md` explains the implementation in intro-class terms.
- [ ] Core DAO classes have comments explaining database operations.
- [ ] Core Servlet classes have comments explaining route behavior.
- [ ] JSP pages include comments for major forms/actions.
- [ ] SQL files include comments explaining schema/setup/test purpose.
