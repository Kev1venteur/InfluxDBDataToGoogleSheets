# InfluxDBDataToGoogleSheets
This project goal is to automate enterprise reporting, by formatting InfluxDB data into google spreadsheet, to be used with datastudio

## Examples
Environment: Using InfluxDB Docker container

``` sh
#Initialize container
docker pull influxdb
docker start influxdb

#Create DB via http
curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

#White data into db
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'

#Export data to CSV
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'" -H "Accept: application/csv" > raw-csv-data.csv
```

## Sources
InfluxDB API : https://docs.influxdata.com/influxdb/v1.8/guides/write_data/
Google SpreadSheets API : https://developers.google.com/sheets/api/quickstart/python
