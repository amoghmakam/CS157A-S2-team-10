#!/bin/sh

# CampusQueue build/deploy script for macOS/Linux with Tomcat 10.
# Default app name is CampusQueueFork so it can run separately from other copies.

set -e

TOMCAT_HOME="${TOMCAT_HOME:-/Users/oops/Downloads/tomcat10}"
APP_NAME="${APP_NAME:-CampusQueueFork}"
MYSQL_JAR="web/WEB-INF/lib/mysql-connector-j-9.6.0.jar"

if [ ! -f "$TOMCAT_HOME/lib/servlet-api.jar" ]; then
  echo "Could not find servlet-api.jar. Set TOMCAT_HOME to your Tomcat 10 folder."
  exit 1
fi

if [ ! -f "$MYSQL_JAR" ]; then
  echo "Could not find $MYSQL_JAR. Check web/WEB-INF/lib for the connector jar name."
  exit 1
fi

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

echo "Starting Tomcat..."
sh "$TOMCAT_HOME/bin/startup.sh"

echo "Open: http://localhost:8080/$APP_NAME/HomeServlet"
