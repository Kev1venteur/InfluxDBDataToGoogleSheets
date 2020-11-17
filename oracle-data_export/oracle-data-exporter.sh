#!/bin/bash

# Load database connection info
source .env

# Read query into a variable
sql="$(cat oracle-data_export/oracle-query.sql)"

# If sqlplus is not installed, then exit
if ! command -v sqlplus > /dev/null; then
  echo "SQL*Plus est nécessaire pour exécuter ce script..."
  exit 1
fi

# Connect to the database, run the query, then disconnect
echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sql" | \
sqlplus -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))"
