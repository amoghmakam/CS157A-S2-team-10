# CampusQueue Demo

On a new machine, first make sure these are installed:

- Java JDK
- Tomcat 10
- MySQL Server
- MySQL Connector/J
- Git

Test MySQL login:

```
mysql -u root -p
```

Then exit MySQL:

\q
or
exit;

Clone the project:

```
cd ~/Downloads
git clone https://github.com/amoghmakam/CS157A-S2-team-10.git campusqueue
cd campusqueue
```

Important:
Adjust TOMCAT_HOME to the Tomcat 10 directory on the machine.
Set DB_PASSWORD to the local MySQL root password.

To start, run:
```
cd ~/Downloads/campusqueue
git pull origin main
git status

export TOMCAT_HOME="/Users/oops/Downloads/tomcat10"
export CATALINA_HOME="$TOMCAT_HOME"
export DB_USER="root"
export DB_PASSWORD="campusqueue123"
export DB_URL="jdbc:mysql://localhost:3306/team10?serverTimezone=UTC"

sh scripts/setup_db_mac.sh
sh scripts/build_deploy_mac.sh
```

Go to:
http://localhost:8080/CampusQueue/HomeServlet 

*note: only run setup_db_mac.sh if you want fresh database, the cmd resets the db. Make sure git status says “working tree clean” before starting.

 DB PASSWORD: campusqueue123

Demo Student auth:

student.demo@sjsu.edu
pass123

Demo staff auth:

staff.demo@sjsu.edu
pass123

Demo admin auth:

admin.demo@sjsu.edu
pass123  Demo flow:

1. Student
- Log in with student.demo@sjsu.edu / pass123
- View services
- Filter by category
- Open service detail
- Check in
- Try second check-in to show it is blocked
- Check out

2. Staff
- Log in with staff.demo@sjsu.edu / pass123
- Show assigned SRAC Gym service
- Update status/capacity
- Update hours
- Validate or flag a check-in

3. Admin
- Log in with admin.demo@sjsu.edu / pass123
- Add a test service
- Edit it
- Deactivate it
- Remove it
- Assign staff
- Suspend/reactivate a user
- Show audit logs
