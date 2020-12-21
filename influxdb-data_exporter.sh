#!/bin/bash
#Setting dates to set request timestamp
current_date=$(date +'%Y-%m-%d')
last_month_date=$(date -d "$date -1 months" +"%Y-%m-%d")
#Foreach hostname, getting data from influxdb directly into separated CSV format
cat csv/temboard-hostnames.csv | while read hostname
do
  #Calling InfluxDB API for CPU (can be executed in one request but in two, the post-process is faster)
  curl -sS -G 'http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true'\
        --data-urlencode "db=metrologie"\
        --data-urlencode "q=SELECT MEAN(*) FROM \"syst-metro-linux-cpu\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
        -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  #Removing the first, third and fourth csv line getting only the Mean cpu idle
  sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f4 | sed 's/^/'"$current_date"','"$hostname"',CPU_Inutilisé (%), /' >> 'csv/formatted/Capa-Postgre'

  #Calling InfluxDB API for memory
  curl -sS -G 'http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true'\
        --data-urlencode "db=metrologie"\
        --data-urlencode "q=SELECT MEAN(*) FROM \"syst-metro-linux-mem\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
        -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  #Removing the first, third and fourth csv line and throw the result in formatted file
  sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f5 | sed 's/^/'"$current_date"','"$hostname"',Moy_RAM_Libre (Octets), /' >> 'csv/formatted/Capa-Postgre'
done
echo "InfluxDB data correctly formatted to CSV normalisation."
