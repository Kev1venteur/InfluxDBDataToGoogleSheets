#!/bin/bash
function oracleExport() {
  function launchExport() {
    cat $csvHostnamesPath | while read hostname
    do
      # Read queries into variables
      sqlram="$(cat oracle-data_export/oracle-query-ram.sql)"
      sqlcpu="$(cat oracle-data_export/oracle-query-cpu.sql)"
      sqldisk="$(cat oracle-data_export/oracle-query-disk.sql)"

      # If sqlplus is not installed, then exit
      if ! command -v oracle-data_export/instantclient_19_6/sqlplus.exe > /dev/null; then
        echo "L'executable SQLPlus 'oracle-data_export/instantclient_19_6/sqlplus.exe' est nécessaire pour exécuter ce script..."
        exit 1
      fi

      # Connect to the database, run the query, then disconnect
      #Sed replaces spaces by commas and add etiquettes
      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlram" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Ram_Used (%)/' >> csv/raw/raw-oracle-data

      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlcpu" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,CPU_Used (%)/' >> csv/raw/raw-oracle-data

      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqldisk" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Disk_Used (%)/' >> csv/raw/raw-oracle-data
      
      #Add dates, zone and hostname to CSV
      cat csv/raw/raw-oracle-data | sed 's/^/,'$1','$hostname'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
    done
    echo "Oracle data of "$1" correctly formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "$1" == "rec" ]]
  then
    csvHostnamesPath="csv/rec-oracle-hostnames.csv"
    echo
    echo "Oracle rec export..."
    echo
    launchExport "Recette"

  elif [[ "$1" == "prod" ]]
  then
    csvHostnamesPath="csv/prod-oracle-hostnames.csv"
    echo
    echo "Oracle prod export..."
    echo
    launchExport "Production"

  elif [[ "$1" == "dev" ]]
  then
    csvHostnamesPath="csv/dev-oracle-hostnames.csv"
    echo
    echo "Oracle dev export..."
    echo
    launchExport "Developpement"

  else
    echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
    exit
  fi
}