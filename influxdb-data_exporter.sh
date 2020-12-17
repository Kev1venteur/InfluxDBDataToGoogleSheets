#!/bin/bash
#----------------------------DB Managment for tests------------------------------------#
#Create DB via http
#curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
#Write data into db
#curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=u3recu197.recgroupement.systeme-u.fr,region=us-west value=0.64 1434055562000000000'
#----------------------------Data Processing-------------------------------------------#
#Foreach hostname, getting data from influxdb directly into separated CSV format
cat csv/temboard-hostnames.csv | while read hostname
do
  curl -s -S -G 'http://localhost:8086/query?pretty=true'\
          --data-urlencode "db=mydb"\
          --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"host\"='"$hostname"'"\
          -H "Accept: application/csv" > 'csv/raw/raw-influx('"$hostname"')-data.csv'
  #Removing the first csv's line
  sed 1d 'csv/raw/raw-influx('"$hostname"')-data.csv' > 'csv/formatted/'"$hostname"''
done
echo "InfluxDB data correctly formatted to CSV normalisation."
