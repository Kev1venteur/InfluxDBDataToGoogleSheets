# InfluxDBDataToGoogleSheets
:key: This project goal is to automate enterprise reporting, by formatting InfluxDB data into google spreadsheet, to be used with datastudio
## How to Start
```
git clone https://github.com/Kev1venteur/InfluxDBDataToGoogleSheets.git
```

## How to Launch
:pushpin: Don't forget to change the fields that needs to be modified in the scripts. </br></br>
:pushpin: Install the Google Client Library :
``` sh
pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org --upgrade pip requests-toolbelt google-api-python-client google-auth-httplib2 google-auth-oauthlib gspread
```
:pushpin: Turn on the Google Sheets API from this page : https://developers.google.com/sheets/api/quickstart/python </br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; :point_right: In resulting dialog click DOWNLOAD CLIENT CONFIGURATION and save the file credentials.json to your working directory.</br></br>
:pushpin: Turn on the Google Drive API from this page : https://developers.google.com/drive/api/v3/quickstart/python </br></br>
:pushpin: Just install python 3.8 (also available on the MSstore) and execute [The bash script](influxdb-data_exporter.sh). </br>

## Examples
Environment: Using InfluxDB Docker container

``` sh
#-------------------Container Managment----------------------#
#Pull the container
docker pull influxdb

#Start the container
docker run --name=influxdb -d -p 8086:8086 influxdb

#Get a shell in the container
docker exec -it influxdb bash

#--------------------Database Managment----------------------#
#Create DB via http
curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE mydb"

#White data into db
curl -i -XPOST 'http://localhost:8086/write?db=mydb' --data-binary 'cpu_load_short,host=server01,region=us-west value=0.64 1434055562000000000'

#Export data to CSV
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=mydb" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'" -H "Accept: application/csv" > raw-csv-data.csv
```

## How to contribute
Just send a pull-request :trophy:

## Author
:cocktail: <b>Kévin Gillet</b> - <i>Developper</i> - <a href="https://www.linkedin.com/in/k%C3%A9vin-gillet-50b25b175/">Linkedin</a>.

## Sources
:gem: InfluxDB API : https://docs.influxdata.com/influxdb/v1.8/guides/write_data/ </br>
:gem: Google Sheets API : https://developers.google.com/sheets/api/quickstart/python </br>
