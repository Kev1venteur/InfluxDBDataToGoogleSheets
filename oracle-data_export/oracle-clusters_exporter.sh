#!/bin/bash
function oracleExport() {
  function launchExport() {
    #Select distinct value in file and rewrite the file with it
    cat $csvClusterPath  | sort | uniq > "csv/tmp"
    cat "csv/tmp" > $csvClusterPath

    #Remove temp file
    rm csv/tmp
    
    #Count lines in CSV files to make a counter
    totalLines=$(wc -l $csvClusterPath | cut -f1 -d' ')
    doneLines=0

    cat $csvClusterPath | while read _hostname
    do
      # Read sql queries and strore them into variables with env-variable substitution
      export envhostname="$(echo $_hostname)"
      export dollar='$'
      sqlDGData=$(envsubst < oracle-data_export/oracle-query-dgData.sql)
      sqlDGReco=$(envsubst < oracle-data_export/oracle-query-dgReco.sql)

      # If sqlplus is not installed, then exit
      if ! command -v oracle-data_export/instantclient_19_6/sqlplus.exe > /dev/null; then
        echo "L'executable SQLPlus 'oracle-data_export/instantclient_19_6/sqlplus.exe' est nécessaire pour exécuter ce script..."
        exit 1
      fi

      #CPU calc part from exported oracle data
      finalCpuValue=0
      finalRamValue=0

      # Check if file is not empty and having size greater than zero
      if [ -s "csv/raw-clusters/${_hostname}-cpu" ]
      then
        counter=0
        somme=0
        while read -r value; do
          #Add value to somme
          somme=$(($somme + $value))
          #Increment counter
          counter=$(($counter + 1))
        done < "csv/raw-clusters/${_hostname}-cpu"
        finalCpuValue=$(($somme / $counter))
        echo "${finalCpuValue}" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-CPU_Used (%),/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      #RAM calc part from exported oracle data
      # Check if file is not empty and having size greater than zero
      if [ -s "csv/raw-clusters/${_hostname}-ram" ]
      then
        counter=0
        somme=0
        while read -r value; do
          #Add value to somme
          somme=$(($somme + $value))
          #Increment counter
          counter=$(($counter + 1))
        done < "csv/raw-clusters/${_hostname}-ram"
        finalRamValue=$(($somme / $counter))
        echo "${finalRamValue}" | sed -e 's/\s\+/,/g' | sed 's/^/,AVG-RAM_Used (%),/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      #Disk Group Data Request
      returnedDGDataInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlDGData}" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")

      if [ -z "$returnedDGDataInfo" ]
      then 
        echo ",Null" | sed -e 's/\s\+/,/g' | sed 's/^/,DGData_AVG2DaysUsed (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      else
        echo "${returnedDGDataInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,DGData_AVG2DaysUsed (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      #Disk Group Reco Request
      returnedDGRecoInfo=$(echo -e "SET PAGESIZE 0\n SET FEEDBACK OFF\n ${sqlDGReco}" | \
      oracle-data_export/instantclient_19_6/sqlplus.exe -S -L \
      "${ORACLE_USERNAME}/${ORACLE_PASSWORD}@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=${ORACLE_HOST})(PORT=${ORACLE_PORT}))(CONNECT_DATA=(SERVICE_NAME=${ORACLE_DATABASE})))")
      
      if [ -z "$returnedDGRecoInfo" ]
      then 
        echo ",Null" | sed -e 's/\s\+/,/g' | sed 's/^/,DGReco_MaxMonthUsed (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      else
        echo "${returnedDGRecoInfo}" | sed -e 's/\s\+/,/g' | sed 's/^/,DGReco_MaxMonthUsed (%)/' | sed 's/^/,'${1}','$(echo $_hostname)'/' | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> ${formattedCSVPath}
      fi

      # Echo "plan d'action"
      echo "$(date +"%Y-%m-%d") ,${1},$(echo $_hostname),Plan_Action" >> ${formattedCSVPath}

      #Increment counter
      ((doneLines=doneLines+1))
      
      #Show number of host done
      echo "[${doneLines}/${totalLines}]"  

    done
    echo
    echo "Oracle Cluster data of ${1} formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "${1}" == "rec" ]]
  then
    source credentials/rec-oracle.env
    csvClusterPath="csv/rec-oracle-clusters.csv"
    formattedCSVPath="csv/formatted/Capa-Clusters-Oracle"
    echo
    echo "Oracle rec clusters export..."
    echo
    launchExport "Recette"

  elif [[ "${1}" == "prod" ]]
  then
    source credentials/prod-oracle.env
    csvClusterPath="csv/prod-oracle-clusters.csv"
    formattedCSVPath="csv/formatted/Capa-Clusters-Oracle"
    echo
    echo "Oracle prod clusters export..."
    echo
    launchExport "Production"

  elif [[ "${1}" == "dev" ]]
  then
    source credentials/rec-oracle.env
    csvClusterPath="csv/dev-oracle-clusters.csv"
    formattedCSVPath="csv/formatted/Capa-Clusters-Oracle"
    echo
    echo "Oracle dev clusters export..."
    echo
    launchExport "Developpement"

  else
    echo
    echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
    exit
  fi
}