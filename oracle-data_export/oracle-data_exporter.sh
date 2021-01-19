#!/bin/bash

# Load database connection info
source oracle-data_export/.env

# Export hostnames from cloud control
sqlhost="$(cat oracle-data_export/oracle-query-hostnames.sql)"
echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlhost" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" > csv/oracle-hostnames.csv

# Read queries into variables
sqlram="$(cat oracle-data_export/oracle-query-ram.sql)"
sqlcpu="$(cat oracle-data_export/oracle-query-cpu.sql)"
sqldisk="$(cat oracle-data_export/oracle-query-disk.sql)"

# If sqlplus is not installed, then exit
if ! command -v oracle-data_export/instantclient_19_6/sqlplus.exe > /dev/null; then
  echo "SQL*Plus est nécessaire pour exécuter ce script..."
  exit 1
fi

# Connect to the database, run the query, then disconnect
#Sed replaces spaces by commas and add etiquettes

echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlram" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Ram_Used (%)/'> csv/raw/raw-oracle-data.csv

echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlcpu" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,CPU_Used (%)/' >> csv/raw/raw-oracle-data.csv

echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqldisk" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Disk_Used (%)/' >> csv/raw/raw-oracle-data.csv

#Add "Cible" to each lines
sed 's/^/,u3recu111/' csv/raw/raw-oracle-data.csv > csv/raw/temp-oracle-data
#Add dates to CSV
cat csv/raw/temp-oracle-data | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
#Removing the temp file
rm csv/raw/temp-oracle-data
echo "Oracle data correctly formatted to CSV normalisation."
