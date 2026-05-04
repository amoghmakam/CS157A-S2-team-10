#!/bin/sh

# CampusQueue database setup script for macOS/Linux.
# This resets the team10 database, applies feature upgrades,
# creates easy demo accounts, and runs verification queries.

set -e

MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_DB="team10"

echo "Resetting CampusQueue database..."
mysql -u "$MYSQL_USER" -p < sql/schema.sql

echo "Applying feature upgrades..."
mysql -u "$MYSQL_USER" -p "$MYSQL_DB" < sql/upgrade_basic_features.sql

echo "Adding demo accounts..."
mysql -u "$MYSQL_USER" -p "$MYSQL_DB" < sql/demo_accounts.sql

echo "Running verification queries..."
mysql -u "$MYSQL_USER" -p "$MYSQL_DB" < sql/test_basic_features.sql

echo "Database setup complete."
echo "Demo accounts:"
echo "  student.demo@sjsu.edu / pass123"
echo "  staff.demo@sjsu.edu / pass123"
echo "  admin.demo@sjsu.edu / pass123"
