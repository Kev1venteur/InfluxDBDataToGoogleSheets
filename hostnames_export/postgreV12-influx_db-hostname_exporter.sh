#!/bin/bash
function influxExport () {
  function launchExport () {
    #Get V12 postgre hostnames from influxdb
    curl -sS -G $influxURL\
        --data-urlencode "u=$influxuser"\
        --data-urlencode "p=$influxpass"\
        --data-urlencode "db=metrologie"\
        --data-urlencode "q=SELECT distinct(host) from (select _var_lib_pgsql_12_main_data_mnt_MB,host from \"disk-gen-full-_var_lib_pgsql_12_main_data_mnt\")"\
        -H "Accept: application/csv" | sed -e '1d' | cut -d , -f4 | sort > "csv/$1-postgre12-hostnames.csv"
    
    echo "PostgreV12 hostnames of "$1" grabbed."
  }
  #Block to set variables before code and avoid code repetition
  if [[ "$1" == "rec" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-rec.creds)
    influxpass=$(sed -n -e 2p credentials/influx-rec.creds)
    influxURL="http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Postgre V12 rec export from influx..."
    echo
    launchExport "rec"

  elif [[ "$1" == "prod" ]]
  then
    influxuser=$(sed -n -e 1p credentials/influx-prod.creds)
    influxpass=$(sed -n -e 2p credentials/influx-prod.creds)
    influxURL="http://metrologie-influxdb-prod.groupement.systeme-u.fr:8086/query?pretty=true"
    echo
    echo "Postgre V12 prod export from influx..."
    echo
    launchExport "prod"

  else
    echo "Error, no environement type (rec, prod) specified, exiting..." 
    exit
  fi
}
