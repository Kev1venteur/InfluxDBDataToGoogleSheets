#!/bin/bash
function oracleExport() {
  function launchExport() {
    cat $csvHostnamesPath | while read _hostname
    do
      # Read sql queries and strore them into variables with env-variable substitution
      export envhostname="$(echo $_hostname)"
      export dollar='$'
      sqlram=$(envsubst < oracle-data_export/oracle-query-ram.sql)
      sqlcpu=$(envsubst < oracle-data_export/oracle-query-cpu.sql)
      sqldisk=$(envsubst < oracle-data_export/oracle-query-disk.sql)

      # If sqlplus is not installed, then exit
      if ! command -v oracle-data_export/instantclient_19_6/sqlplus.exe > /dev/null; then
        echo "L'executable SQLPlus 'oracle-data_export/instantclient_19_6/sqlplus.exe' est nécessaire pour exécuter ce script..."
        exit 1
      fi

      # Connect to the database, run the query, then disconnect
      #RAM Request
      returnedRAMInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlram}" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")
      
      #If no info of RAM size returned, print message, else format result and put in formatted
      if [ -z "$returnedRAMInfo" ]
      then  
        echo
        echo "No RAM infos of ${_hostname} has been returned from Oracle Cloud Control"
      else
        echo "${returnedRAMInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,Ram_Used (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
      fi

      #CPU Request
      returnedCPUInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlcpu}" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")

      #If no info of CPU size returned, print message, else format result and put in formatted
      if [ -z "$returnedCPUInfo" ]
      then  
        echo "No CPU infos of ${_hostname} has been returned from Oracle Cloud Control"
      else
        echo "${returnedCPUInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,CPU_Used (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
      fi

      #Disk Request
      returnedDiskInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqldisk}" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")
      
      #If no info of Disk size returned, print message, else format result and put in formatted
      if [ -z "$returnedDiskInfo" ]
      then  
        echo "No Disk infos of ${_hostname} has been returned from Oracle Cloud Control"
      else
        echo "${returnedDiskInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,Disk_Used (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/formatted/Capa-Oracle
        echo "$(date +"%Y-%m-%d") ,${1},$(echo $_hostname),Plan_Action" >> csv/formatted/Capa-Oracle
      fi
    done
    echo "Oracle data of ${1} correctly formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "${1}" == "rec" ]]
  then
    source credentials/rec-oracle.env
    csvHostnamesPath="csv/rec-oracle-hostnames.csv"
    echo
    echo "Oracle rec export..."
    echo
    launchExport "Recette"

  elif [[ "${1}" == "prod" ]]
  then
    source credentials/prod-oracle.env
    csvHostnamesPath="csv/prod-oracle-hostnames.csv"
    echo
    echo "Oracle prod export..."
    echo
    launchExport "Production"

  elif [[ "${1}" == "dev" ]]
  then
    source credentials/rec-oracle.env
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