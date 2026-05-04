# CampusQueue Run and Test Guide

## Local setup used

- Tomcat 10 folder: `/Users/oops/Downloads/tomcat10`
- Database name: `team10`
- MySQL connector: `web/WEB-INF/lib/mysql-connector-j-9.6.0.jar`

## 1. Clone the fork separately

```bash
cd ~
mkdir -p campusqueue-testing
cd campusqueue-testing
git clone https://github.com/oops408/CS157A-S2-team-10.git campusqueue-fork
cd campusqueue-fork
```

## 2. Set environment variables

```bash
export TOMCAT_HOME="/Users/oops/Downloads/tomcat10"
export CATALINA_HOME="$TOMCAT_HOME"
export DB_USER="root"
export DB_PASSWORD="YOUR_MYSQL_PASSWORD"
export DB_URL="jdbc:mysql://localhost:3306/team10?serverTimezone=UTC"
```

## 3. Reset and verify the database

```bash
sh scripts/setup_db_mac.sh
```

This runs:

```bash
mysql -u root -p < sql/schema.sql
mysql -u root -p team10 < sql/upgrade_basic_features.sql
mysql -u root -p team10 < sql/demo_accounts.sql
mysql -u root -p team10 < sql/test_basic_features.sql
```

## 4. Compile and deploy

```bash
sh scripts/build_deploy_mac.sh
```

The script compiles Java files, deploys the app as `CampusQueueFork`, clears old Tomcat work files, and restarts Tomcat.

## 5. Open the app

```text
http://localhost:8080/CampusQueueFork/HomeServlet
```

## 6. Recommended demo accounts

Student: `student.demo@sjsu.edu` / `pass123`

Staff: `staff.demo@sjsu.edu` / `pass123`

Admin: `admin.demo@sjsu.edu` / `pass123`

## 7. Backup sample accounts

Student: `john.doe@sjsu.edu` / `pass123`

Staff: `suparn.posina@sjsu.edu` / `pass123`

Admin: `stephen.curry@sjsu.edu` / `pass123`

## 8. Demo checklist

### Student

- Log in.
- View services and predicted wait times.
- Filter services by category.
- Open a service detail page.
- Check in.
- Try a second active check-in and confirm it is blocked.
- Check out and confirm duration appears in history.

### Staff

- Log in.
- Confirm only assigned services appear.
- Update service status/capacity.
- Update service hours.
- Validate or flag a check-in.
- Confirm validation appears in validation history.

### Admin

- Log in.
- Add a service.
- Edit a service.
- Deactivate a service.
- Remove a test service.
- Assign staff to a service.
- Suspend and reactivate a user.
- View audit logs.

## Troubleshooting

If Java says `package jakarta.servlet does not exist`, set `TOMCAT_HOME` correctly and compile with the Tomcat 10 jars.

If MySQL says access denied, rerun the command and enter the correct local MySQL password.

In zsh, use forward slashes such as `sql/schema.sql`, not Windows backslashes.
