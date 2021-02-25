#!/bin/bash
function oracleExport() {
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

      #Start data export in empty files
      rm csv/raw/raw-oracle-data.csv
      rm csv/raw/temp-oracle-data

      # Connect to the database, run the query, then disconnect
      #Sed replaces spaces by commas and add etiquettes
      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlram" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Ram_Used (%)/'>> csv/raw/raw-oracle-data.csv

      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqlcpu" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,CPU_Used (%)/' >> csv/raw/raw-oracle-data.csv

      echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n $sqldisk" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L "$ORACLE_USERNAME/$ORACLE_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$ORACLE_HOST)(PORT=$ORACLE_PORT))(CONNECT_DATA=(SERVICE_NAME=$ORACLE_DATABASE)))" | sed -e 's/\s\+/,/g' | sed 's/^/,Disk_Used (%)/' >> csv/raw/raw-oracle-data.csv
    done

    #Add "Cible" to each lines
    sed 's/^/,'$1','$hostname'/' csv/raw/raw-oracle-data.csv > csv/raw/temp-oracle-data
    #Add dates to CSV
    cat csv/raw/temp-oracle-data | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
    #Removing the temp file
    rm csv/raw/temp-oracle-data

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