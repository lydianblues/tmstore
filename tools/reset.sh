#!/bin/bash

# Delete the entire test schema and recreate:
# (a) the database user with appropriate privileges
# (b) the database schema
# (c) the PL/SQL stored procedures
# (d) the root category

if ! test $RAILS_ENV
then
	echo "Environment variable RAILS_ENV not set."
	exit 1
fi

case $RAILS_ENV in
	test)
		USER=store_test
		;;
	development)
		USER=store
		;;
	production)
		USER=store_production
		;;
	cucumber)
		USER=store_test
		;;
	*)
		echo "Unknown test environment: $RAILS_ENV"
		exit 2
		;;
esac	

echo "Using $RAILS_ENV environment."

PASSWORD=har526
SYS_PASSWORD=har526
# DB_NAME=ORA11GR2
DB_NAME=ORCL2

# Create account (with -S[ILENT] option)
sqlplus -S "sys/$SYS_PASSWORD@$DB_NAME as sysdba" <<__EOF__
	DROP USER $USER CASCADE;
	CREATE USER $USER IDENTIFIED BY $PASSWORD;
	GRANT CREATE SESSION TO $USER;
	GRANT CREATE TABLE TO $USER;
	GRANT CREATE VIEW TO $USER;
	GRANT CREATE SEQUENCE TO $USER;
	GRANT UNLIMITED TABLESPACE TO $USER; 
	GRANT CREATE PROCEDURE TO $USER;
	GRANT CREATE TYPE TO $USER;
__EOF__

# Must do the migration before installing the PL/SQL package.
rake db:migrate

# Load the PL/SQL store package.  It depends on tables built by
# the above migration.
sqlplus -S "$USER/$PASSWORD@$DB_NAME" @store
sqlplus -S "$USER/$PASSWORD@$DB_NAME" @store2

# Create the root category.  The test environment with Selenium 
# uses database_cleaner between steps so it truncates all the tables
# for each example.  Cucumber env.rb has a before block that will
# recreate the root category and the admin user before each example.
rake store:init

# Assumes that Apache/Passenger is configured and uses the
# test environment.  This creates the admin user.
# curl http://store/bootstrap 
# or for mongrel or webrick running on port 3000:
# curl http://localhost:3000/bootstrap

# Make sure that Passenger will reload Rails.
touch ../tmp/restart.txt


