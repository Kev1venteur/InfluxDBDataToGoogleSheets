#!/bin/bash

# RECETTE - DEV EXPORT

# Load database connection info
source credentials/rec-oracle.env
# Load Query into variable
sqlQuery="$(cat hostnames_export/oracle-query-hostnames.sql)"

# Store query result in a variable
RAWOracleHosts=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlQuery" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP) \
(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))")

# Format exported hostnames
#Remove FQDN and only keep first part
OracleHosts=$(echo "${RAWOracleHosts}" | cut -d . -f1)

#Get antu hostnames and put in dev hostname file
echo "Export Oracle hostnames from dev..."
echo "${OracleHosts}" | grep "antu" > csv/dev-oracle-hostnames.csv

#Get recu hostnames and put in rec hostname file
echo
echo "Export Oracle hostnames from rec..."
echo "${OracleHosts}" | grep "recu" > csv/rec-oracle-hostnames.csv

# PRODUCTION EXPORT

# Load database connection info
source credentials/prod-oracle.env

# Store query result in a variable
RAWProdOracleHosts=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlQuery" | \
oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP) \
(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))")

# Format exported hostnames
#Remove FQDN and only keep first part
echo
echo "Export Oracle hostnames from prod..."
echo "${RAWProdOracleHosts}" | cut -d . -f1 > csv/prod-oracle-hostnames.csv