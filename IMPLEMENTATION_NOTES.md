# CampusQueue Implementation Notes

This file explains the important implementation details in simple terms for an intro database management systems project.

## Security

- `PasswordUtil` hashes new passwords using SHA-256.
- `UserDao.login()` checks the stored password against the hash.
- Old sample passwords such as `pass123` still work one time and are upgraded to a hash after login.
- `LoginServlet` sets a 30-minute session timeout.
- `AuthFilter` protects student, staff, and admin routes.

## Student Features

- Students can view services and predicted wait times.
- Students can check in and check out.
- `CheckInDao` blocks more than one active check-in for the same student.
- Check-out stores the duration in minutes.

## Staff Features

- Staff can only see services assigned to them.
- Staff updates are checked again in the servlet/DAO layer so a user cannot post a different service manually.
- Staff can update service status, capacity, and optional hours for a day.
- Staff can validate or flag check-ins only for assigned services.

## Admin Features

- Admins can add, edit, deactivate, and remove services.
- Admins can assign staff to services.
- Admins can set users to `ACTIVE` or `SUSPENDED`.
- Suspended users cannot log in.

## Database Relationship Tables

The project keeps the ERD relationship tables synchronized in beginner-friendly Java code:

- New check-ins update `CheckIn`, `Submits`, and `OccursAt`.
- Staff assignments update `StaffAssignment`, `AssignedTo`, `Covers`, and `Manages`.
- Validations update `ValidationLog`, `Validates`, and `Flags`.
- Audit actions update `AuditLog` and `Performs`.

## Wait Time Prediction

The prediction is intentionally simple:

```text
predicted wait = average past duration + small active-crowd penalty
```

This uses normal SQL averages and a small Java calculation rather than advanced machine learning.

## Database Upgrade

If the database already exists, run:

```sql
SOURCE sql/upgrade_basic_features.sql;
```

If starting fresh, run `schema.sql` first, then run the upgrade script.
