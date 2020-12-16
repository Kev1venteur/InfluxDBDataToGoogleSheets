#!/bin/bash
#Create DB via http
#curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"
#White data into db
#curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'
#Export the db returned values to csv format
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'" -H "Accept: application/csv" > csv/raw/raw-influx-data.csv
echo
#Removing the first csv line
sed 1d csv/raw/raw-influx-data.csv > csv/formatted/formatted-influx-data.csv
echo "InfluxDB data correctly formatted to CSV normalisation."
