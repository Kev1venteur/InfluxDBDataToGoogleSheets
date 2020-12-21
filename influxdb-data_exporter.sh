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
  #CPU formatting and calculation
  float=$(sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f4)
  #Operation to get used CPU and not free CPU
  #Convert float to int
  int=${float%.*}
  result=$((100 - $int))
  echo $result > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  #Formatting for sheet and putting into formatted folder
  sed 's/^/'"$current_date"','"$hostname"',CPU_Used (%),/' 'csv/raw/raw-influx('"$hostname"')-data.csv' >> 'csv/formatted/Capa-Postgre'

  #Calling InfluxDB API for memory
  curl -sS -G 'http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true'\
        --data-urlencode "db=metrologie"\
        --data-urlencode "q=SELECT MEAN(*) FROM \"syst-metro-linux-mem\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
        -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  #Ram formating and calculation
  mem_free=$(sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f6)
  mem_total=$(sed -e '1d' 'csv/raw/raw-influx('"$hostname"')-data.csv' | cut -d , -f8)
  mem_free=${mem_free%.*}
  mem_total=${mem_total%.*}
  mem_used=$(($mem_total - $mem_free))
  result=$(($mem_used * 100 / $mem_total))
  echo $result > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  sed 's/^/'"$current_date"','"$hostname"',RAM_Used (%),/' 'csv/raw/raw-influx('"$hostname"')-data.csv' >> 'csv/formatted/Capa-Postgre'
  echo ""$current_date","$hostname",Plan_Action," >> 'csv/formatted/Capa-Postgre'

  curl -sS -G 'http://metrologie-influxdb-rec.recgroupement.systeme-u.fr:8086/query?pretty=true'\
        --data-urlencode "db=metrologie"\
        --data-urlencode "q=SELECT MEAN(*) FROM \"syst-metro-linux-mem\" WHERE \"host\"='"$hostname"' AND \"time\">'"$last_month_date"' AND \"time\"<'"$current_date"'"\
        -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'
done
echo "InfluxDB data correctly formatted to CSV normalisation."
