# InfluxDBDataToGoogleSheets
This project goal is to automate enterprise reporting, by formatting InfluxDB data into google spreadsheet, to be used with datastudio
## How to Start
```
git clone https://github.com/Kev1venteur/InfluxDBDataToGoogleSheets.git
```

## How to Launch
Just install python and execute [The bash script](grafana-data_exporter.sh). </br>
Don't forget to change the fields that needs to be modified in the scripts. </br>
Install the Google Client Library :
``` sh
pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
```
</br>
Turn on the Google Sheets API from this page : https://developers.google.com/sheets/api/quickstart/python </br>
In resulting dialog click DOWNLOAD CLIENT CONFIGURATION and save the file credentials.json to your working directory.

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

## How to contribute
Just send a pull-request 😉

## Author
- <b>Kévin Gillet</b> - <i>Developper</i> - <a href="https://www.linkedin.com/in/k%C3%A9vin-gillet-50b25b175/">Linkedin</a>.

## Sources
InfluxDB API : https://docs.influxdata.com/influxdb/v1.8/guides/write_data/ </br>
Google Sheets API : https://developers.google.com/sheets/api/quickstart/python </br>
