#!/bin/bash
function influxExport () {
  #Setting dates and their format to set request timestamps
  current_date=$(date +'%Y-%m-01')
  last_month_date=$(date -d "$date -1 months" +"%Y-%m-01")

  function launchExport () {
    #Count lines in CSV files to make a counter
    totalLines=$(wc -l $csvHostnamesPath | cut -f1 -d' ')
    doneLines=0

    #Foreach rec hostname, getting data from influxdb directly into separated CSV format
    cat $csvHostnamesPath | while read _hostname
    do
      #Calling InfluxDB API for CPU (can be executed in one request CPU + RAM, but in two the post-process is faster)
      RAWInfluxCPU=$(curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT MEAN(\"cpu_idle\") FROM \"syst-metro-linux-cpu\" WHERE \"host\"=~/"$_hostname"/ AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
            -H "Accept: application/csv")

      #If no info of CPU size returned, print message and null value, else format result and put in formatted
      if [ -z "$RAWInfluxCPU" ]
      then
        echo "Null" | sed 's/^/'"$current_date"','$1','"$_hostname"',CPU_Used (%),/' >> ${formattedCSVPath}
      else
        #CPU formatting and calculation
        float=$(echo "${RAWInfluxCPU}" | sed -e '1d' | cut -d , -f4)
        #Operation to get used CPU and not free CPU
        #Convert float to int
        rInt=${float%.*}
        influxCPU=$((100 - $rInt))
        #Formatting for sheet and putting into formatted file
        echo "${influxCPU}" | sed 's/^/'"$current_date"','$1','"$_hostname"',CPU_Used (%),/' >> ${formattedCSVPath}
      fi

      #Calling InfluxDB API for Memory
      RAWInfluxRAM=$(curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT MEAN(\"MemAvailable\"),MEAN(\"MemTotal\") FROM \"syst-metro-linux-mem\" WHERE \"host\"=~/"$_hostname"/ AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
            -H "Accept: application/csv")

      #Check if variable is empty
      if [ -z "$RAWInfluxRAM" ]
      then
        echo "Null" | sed 's/^/'"$current_date"','$1','"$_hostname"',RAM_Used (%),/' >> ${formattedCSVPath}
      else
        #Ram formating and calculation
        mem_free=$(echo "${RAWInfluxRAM}" | sed -e '1d' | cut -d , -f4)
        mem_total=$(echo "${RAWInfluxRAM}" | sed -e '1d' | cut -d , -f5)
        mem_free=${mem_free%.*}
        mem_total=${mem_total%.*}
        mem_used=$(($mem_total - $mem_free))
        influxRAM=$(($mem_used * 100 / $mem_total))
        echo "${influxRAM}" | sed 's/^/'"$current_date"','$1','"$_hostname"',RAM_Used (%),/' >> ${formattedCSVPath}
      fi

      #Convert hostname to instance name (u3recuXXX to pgsrXXX)
      if [[ "$1" == "Recette" ]]
      then
        #Define hostname separation with "." get the first part, and remove the first 8 char
        pgname=$(cat 'csv/rec-postgre12-hostnames.csv' | grep "$_hostname" | cut -d . -f1 | cut -c8-)".recgroupement.systeme-u.fr"

      elif [[ "$1" == "Production" ]]
      then
        pgname=$(cat 'csv/prod-postgre12-hostnames.csv' | grep "$_hostname" | cut -d . -f1 | cut -c8-)".groupement.systeme-u.fr"

      elif [[ "$1" == "Developpement" ]]
      then
        pgname=$(cat 'csv/dev-postgre12-hostnames.csv' | grep "$_hostname" | cut -d . -f1 | cut -c8-)".groupement.systeme-u.fr"

      else
        echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
        exit
      fi

      #Calling InfluxDB API for Availaibility
      RAWInfluxDispo=$(curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT \"postgres\" FROM \"pgsql-conn-test\" WHERE  \"host\"=~/"$pgname"/ AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"' tz('Europe/Paris')"\
            -H "Accept: application/csv")
      
      # if [ -z "$RAWInfluxDispo" ]
      # then
      #   echo 
      # else
      #   #Code to execute with all availability bools returned from influx
      #   echo
      # fi

      # Echo "plan d'action"
      echo ""$current_date","$1","$_hostname",Plan_Action," >> ${formattedCSVPath}

      #Increment counter
      ((doneLines=doneLines+1))
      
      #Show number of host done
      echo "[${doneLines}/${totalLines}]"  
         
    done
    echo
    echo "InfluxDB data of "$1" formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "$1" == "rec" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-rec.creds)
    influxpass=$(sed -n -e 2p credentials/influx-rec.creds)
    csvHostnamesPath="csv/rec-postgre12-hostnames.csv"
    formattedCSVPath='csv/formatted/Capa-Postgre'
    influxURL="http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx rec export..."
    echo
    launchExport "Recette"

  elif [[ "$1" == "prod" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-prod.creds)
    influxpass=$(sed -n -e 2p credentials/influx-prod.creds)
    csvHostnamesPath="csv/prod-postgre12-hostnames.csv"
    formattedCSVPath='csv/formatted/Capa-Postgre'
    influxURL="http://metrologie-influxdb-prod.groupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx prod export..."
    echo
    launchExport "Production"

  elif [[ "$1" == "dev" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-prod.creds)
    influxpass=$(sed -n -e 2p credentials/influx-prod.creds)
    csvHostnamesPath="csv/dev-postgre12-hostnames.csv"
    formattedCSVPath='csv/formatted/Capa-Postgre'
    influxURL="http://metrologie-influxdb-prod.groupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx dev export..."
    echo
    launchExport "Developpement"

  else
    echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
    exit
  fi
}
