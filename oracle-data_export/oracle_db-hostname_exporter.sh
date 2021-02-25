#!/bin/bash
# Load database connection info
source credentials/oracle.env

# Export hostnames from cloud control
sqlhost="$(cat oracle-data_export/oracle-query-hostnames.sql)"
echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlhost" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" > csv/raw/oracle-hostnames.csv

# Format exported hostnames
#Remove FQDN and only keep first part
cat csv/raw/oracle-hostnames.csv | cut -d . -f1 > csv/oracle-hostnames.csv
#Get antu and put in dev hostname file
echo "Export Oracle hostnames from dev"
cat csv/oracle-hostnames.csv | grep "antu" > csv/dev-oracle-hostnames.csv
#Get recu and put in rec hostname file
echo "Export Oracle hostnames from rec"
cat csv/oracle-hostnames.csv | grep "recu" > csv/rec-oracle-hostnames.csv