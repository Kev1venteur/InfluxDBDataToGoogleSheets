#!/bin/bash
function oracleExport() {
  function launchExport() {
    #Count lines in CSV files to make a counter
    totalLines=$(wc -l $csvHostnamesPath | cut -f1 -d' ')
    doneLines=0

    cat $csvHostnamesPath | while read _hostname
    do
      # Read sql queries and strore them into variables with env-variable substitution
      export envhostname="$(echo $_hostname)"
      export dollar='$'
      sqlclusterName=$(envsubst < oracle-data_export/oracle-query-clusterName.sql)
      sqlram=$(envsubst < oracle-data_export/oracle-query-ram.sql)
      sqlcpu=$(envsubst < oracle-data_export/oracle-query-cpu.sql)
      sqlAvail=$(envsubst < oracle-data_export/oracle-query-hostAvailability.sql)

      # Connect to the database, run the query, then disconnect
      #Cluster Name Request
      returnedClusterName=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlclusterName}" | \
      ${instantClientPath} -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")

      #If no info of CPU size returned, print message and set value as "Null", else format result and put in formatted
      if [ -z "$returnedClusterName" ]
      then  
        returnedClusterName="Null"
      fi

      # Connect to the database, run the query, then disconnect
      #CPU Request
      returnedCPUInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlcpu}" | \
      ${instantClientPath} -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")

      #If no info of CPU size returned, print message and set value as "Null", else format result and put in formatted
      if [ -z "$returnedCPUInfo" ]
      then  
        echo ",Null" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-CPU_Used-LastMonth (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      else
        echo "${returnedCPUInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-CPU_Used-LastMonth (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      #RAM Request
      returnedRAMInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlram}" | \
      ${instantClientPath} -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")
      
      if [ -z "$returnedRAMInfo" ]
      then  
        echo ",Null" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-RAM_Used-LastMonth (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      else
        echo "${returnedRAMInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-RAM_Used-LastMonth (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      #Availability Request
      returnedAvailInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlAvail}" | \
      ${instantClientPath} -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))" | sed 's/,/\./')

      if [ -z "$returnedAvailInfo" ]
      then  
        echo ",Null" | sed -e 's/\s\+/,/g' | sed 's/^/,LastMonthAvailability (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      else
        echo "${returnedAvailInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,LastMonthAvailability (%)/' | sed 's/^/,'${1}','${returnedClusterName}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi
      
      # Echo "plan d'action"
      echo "$(date +"%Y-%m-%d") ,${1},${returnedClusterName},$(echo $_hostname),Plan_Action" >> ${formattedCSVPath}

      #Export corresonding cluster raw data in files to be used for cluster export script
      if [[ "${returnedClusterName}" != "Null" ]]
      then
        if [[ "${1}" == "Recette" ]]
        then
            echo "$returnedClusterName" >> "csv/rec-oracle-clusters.csv"

        elif [[ "${1}" == "Production" ]]
        then
            echo "$returnedClusterName" >> "csv/prod-oracle-clusters.csv"

        elif [[ "${1}" == "Developpement" ]]
        then
            echo "$returnedClusterName" >> "csv/dev-oracle-clusters.csv"
        fi

        if [[ -n "${returnedCPUInfo}" ]]
        then
          echo "$returnedCPUInfo" >> "csv/raw-clusters/${returnedClusterName}-cpu"
        fi

        if [[ -n "${returnedRAMInfo}" ]]
        then
          echo "$returnedRAMInfo" >> "csv/raw-clusters/${returnedClusterName}-ram"
        fi
      fi

      #Increment counter
      ((doneLines=doneLines+1))
      
      #Show number of host done
      echo "[${doneLines}/${totalLines}]"  

    done
    echo
    echo "Oracle data of ${1} formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "$OSTYPE" == "msys" ]]
    then
      #Oracle path for instant client
      instantClientPath="oracle-data_export/winInstantClient_19_6/sqlplus.exe"
  elif [[ "$OSTYPE" == "linux-gnu" ]]
    then
      #Oracle path for instant client
      instantClientPath="sqlplus"
  else
      echo "OSTYPE unknown, cannot continue the script" 
      exit
  fi

  if [[ "${1}" == "rec" ]]
  then
    source credentials/rec-oracle.env
    csvHostnamesPath="csv/rec-oracle-hostnames.csv"
    formattedCSVPath="csv/formatted/Capa-Oracle"
    echo
    echo "Oracle rec servers export..."
    echo
    launchExport "Recette"

  elif [[ "${1}" == "prod" ]]
  then
    source credentials/prod-oracle.env
    csvHostnamesPath="csv/prod-oracle-hostnames.csv"
    formattedCSVPath="csv/formatted/Capa-Oracle"
    echo
    echo "Oracle prod servers export..."
    echo
    launchExport "Production"

  elif [[ "${1}" == "dev" ]]
  then
    source credentials/rec-oracle.env
    csvHostnamesPath="csv/dev-oracle-hostnames.csv"
    formattedCSVPath="csv/formatted/Capa-Oracle"
    echo
    echo "Oracle dev servers export..."
    echo
    launchExport "Developpement"

  else
    echo
    echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
    exit
  fi
}
