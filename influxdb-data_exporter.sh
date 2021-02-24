#!/bin/bash
function influxExport () {
  #removing all old raw files
  rm csv/raw/*

  #Setting dates to set request timestamp
  current_date=$(date +'%Y-%m-%d')
  last_month_date=$(date -d "$date -1 months" +"%Y-%m-%d")

  function launchExport () {
    #Foreach rec hostname, getting data from influxdb directly into separated CSV format
    cat $csvHostnamesPath | while read hostname
    do
      #Calling InfluxDB API for CPU (can be executed in one request CPU + RAM, but in two the post-process is faster)
      curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT MEAN(\"cpu_idle\") FROM \"syst-metro-linux-cpu\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
            -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'

      if [ -s "csv/raw/raw-influx("$hostname")-data.csv" ] #File exist and is not empty
      then
        #CPU formatting and calculation
        float=$(sed -e '1d' 'csv/raw/raw-influx('$hostname')-data.csv' | cut -d , -f4)
        #Operation to get used CPU and not free CPU
        #Convert float to int
        int=${float%.*}
        result=$((100 - $int))
        echo $result > 'csv/raw/raw-influx('$hostname')-data.csv'
        #Formatting for sheet and putting into formatted folder
        sed 's/^/'"$current_date"','$1','"$hostname"',CPU_Used (%),/' 'csv/raw/raw-influx('"$hostname"')-data.csv' >> 'csv/formatted/Capa-Postgre'
      else
        echo "No CPU infos of '"$hostname"' has been returned from InfluxDB"
      fi

      #Calling InfluxDB API for Memory
      curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT MEAN(\"MemAvailable\"),MEAN(\"MemTotal\") FROM \"syst-metro-linux-mem\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
            -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'

      if [ -s "csv/raw/raw-influx("$hostname")-data.csv" ]
      then
        #Ram formating and calculation
        mem_free=$(sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f4)
        mem_total=$(sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f5)
        mem_free=${mem_free%.*}
        mem_total=${mem_total%.*}
        mem_used=$(($mem_total - $mem_free))
        result=$(($mem_used * 100 / $mem_total))
        echo $result > 'csv/raw/raw-influx('"$hostname"')-data.csv'
        sed 's/^/'"$current_date"','$1','"$hostname"',RAM_Used (%),/' 'csv/raw/raw-influx('"$hostname"')-data.csv' >> 'csv/formatted/Capa-Postgre'
        echo ""$current_date","$1","$hostname",Plan_Action," >> 'csv/formatted/Capa-Postgre'
      else
        echo "No RAM infos of '"$hostname"' has been returned from InfluxDB"
      fi

      #Convert hostname to instance name (u3recuXXX to pgsrXXX)
      if [[ "$1" == "Recette" ]]
      then
        #Define hostname separation with "." get the first part, and remove the frist 8 char
        pgname="pgsr"$(cat 'csv/rec-temboard-hostnames.csv' | grep "$hostname" | cut -d . -f1 | cut -c8-)".recgroupement.systeme-u.fr"

      elif [[ "$1" == "Production" ]]
      then
        pgname="pgsr"$(cat 'csv/prod-temboard-hostnames.csv' | grep "$hostname" | cut -d . -f1 | cut -c8-)".groupement.systeme-u.fr"

      elif [[ "$1" == "Developpement" ]]
      then
        pgname="pgsr"$(cat 'csv/dev-temboard-hostnames.csv' | grep "$hostname" | cut -d . -f1 | cut -c8-)".groupement.systeme-u.fr"

      else
        echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
        exit
      fi

      #Calling InfluxDB API for Availaibility
      curl -sS -G $influxURL\
            --data-urlencode "u=$influxuser"\
            --data-urlencode "p=$influxpass"\
            --data-urlencode "db=metrologie"\
            --data-urlencode "q=SELECT \"postgres\" FROM \"pgsql-stat\" WHERE  \"host\"='"$pgname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"' tz('Europe/Paris')"\
            -H "Accept: application/csv" > 'csv/raw/raw-dispo'$1'-influx('"$hostname"')-data.csv'
      
      if [ -s "csv/raw/raw-dispo'$1'-influx('"$hostname"')-data.csv" ]
      then
        #Code to execute with all availability bools returned from
        echo "Availability data correctly received from influx"
        echo
      else
        echo "No availability infos of '"$pgname"' has been returned from InfluxDB"
        echo
      fi
            
    done
    echo "InfluxDB data correctly formatted to CSV normalisation."
  }

  #Block to set variables before code and avoid code repetition
  if [[ "$1" == "rec" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-rec.creds)
    influxpass=$(sed -n -e 2p credentials/influx-rec.creds)
    csvHostnamesPath="csv/rec-temboard-hostnames.csv"
    influxURL="http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx rec export..."
    launchExport "Recette"

  elif [[ "$1" == "prod" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-prod.creds)
    influxpass=$(sed -n -e 2p credentials/influx-prod.creds)
    csvHostnamesPath="csv/prod-temboard-hostnames.csv"
    influxURL="http://metrologie-influxdb-prod.groupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx prod export..."
    launchExport "Production"

  elif [[ "$1" == "dev" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-prod.creds)
    influxpass=$(sed -n -e 2p credentials/influx-prod.creds)
    csvHostnamesPath="csv/dev-temboard-hostnames.csv"
    influxURL="http://metrologie-influxdb-prod.groupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Influx dev export..."
    launchExport "Developpement"

  else
    echo "Error, no environement type (rec, dev, prod) specified, exiting..." 
    exit
  fi
}