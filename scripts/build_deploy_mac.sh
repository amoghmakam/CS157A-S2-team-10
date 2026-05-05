#!/bin/sh

# CampusQueue build/deploy script for macOS/Linux with Tomcat 10.
# Default app name is CampusQueue so it can run separately from other copies.

set -e

TOMCAT_HOME="${TOMCAT_HOME:-/Users/oops/Downloads/tomcat10}"
APP_NAME="${APP_NAME:-CampusQueue}"

# The MySQL connector can be either inside the project or inside Tomcat's lib folder.
# This makes the script work with both common setups.
PROJECT_MYSQL_JAR="web/WEB-INF/lib/mysql-connector-j-9.6.0.jar"
TOMCAT_MYSQL_JAR="$TOMCAT_HOME/lib/mysql-connector-j-9.6.0.jar"

if [ ! -f "$TOMCAT_HOME/lib/servlet-api.jar" ]; then
  echo "Could not find servlet-api.jar. Set TOMCAT_HOME to your Tomcat 10 folder."
  exit 1
fi

if [ -f "$PROJECT_MYSQL_JAR" ]; then
  MYSQL_JAR="$PROJECT_MYSQL_JAR"
elif [ -f "$TOMCAT_MYSQL_JAR" ]; then
  MYSQL_JAR="$TOMCAT_MYSQL_JAR"
else
  echo "Could not find MySQL connector jar."
  echo "Expected one of these:"
  echo "  $PROJECT_MYSQL_JAR"
  echo "  $TOMCAT_MYSQL_JAR"
  exit 1
fi

echo "Using MySQL connector: $MYSQL_JAR"
echo "Compiling Java source files..."
rm -rf build
mkdir -p build/classes

javac -encoding UTF-8 \
  -cp "$TOMCAT_HOME/lib/servlet-api.jar:$TOMCAT_HOME/lib/jsp-api.jar:$MYSQL_JAR" \
  -d build/classes \
  $(find src/main/java -name "*.java")

echo "Stopping Tomcat if it is running..."
sh "$TOMCAT_HOME/bin/shutdown.sh" || true

echo "Deploying $APP_NAME..."
rm -rf "$TOMCAT_HOME/webapps/$APP_NAME"
rm -rf "$TOMCAT_HOME/work/Catalina/localhost/$APP_NAME"

mkdir -p "$TOMCAT_HOME/webapps/$APP_NAME"
cp -R web/* "$TOMCAT_HOME/webapps/$APP_NAME/"

mkdir -p "$TOMCAT_HOME/webapps/$APP_NAME/WEB-INF/classes"
cp -R build/classes/* "$TOMCAT_HOME/webapps/$APP_NAME/WEB-INF/classes/"

# If the project did not include the connector under WEB-INF/lib, copy it into the deployed app.
# This ensures the web app can load com.mysql.cj.jdbc.Driver at runtime.
mkdir -p "$TOMCAT_HOME/webapps/$APP_NAME/WEB-INF/lib"
cp "$MYSQL_JAR" "$TOMCAT_HOME/webapps/$APP_NAME/WEB-INF/lib/"

echo "Starting Tomcat..."
sh "$TOMCAT_HOME/bin/startup.sh"

echo "Open: http://localhost:8080/$APP_NAME/HomeServlet"
