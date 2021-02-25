#!/bin/bash
#---------------------------------CAUTION-------------------------------------------#
#If the script does not works for any dark reasons, try deleting your
#token.picle file in credentials folder & restart your internet
#connection.
#-----------------------------------------------------------------------------------#
#----------------------------------PROXY--------------------------------------------#
#If you have a proxy uncomment this block of lines, and put your proxy cert renamed as
#"cacert.pem" in the credentials folder
#Getting cert path location
cert_path=$(python.exe locate-cert-path.py)
#Replacing Certifi cert with credentials/cacert.pem
yes | cp credentials/cacert.pem $cert_path
#Setting python env variable to use cert for proxy
export REQUESTS_CA_BUNDLE=credentials/cacert.pem && echo "Set proxy cert." && echo
#Setting proxy URL for U GIE IRIS zscaler
export http_proxy="http://127.0.0.1:9000"
export https_proxy="http://127.0.0.1:9000"
#-----------------------------------------------------------------------------------#
#Cleaning before starting
rm csv/formatted/*
rm csv/raw/*

#Call bash script to export hostnames of postgresql servers from Temboard database
echo "Getting hostnames from Temboard..."
echo
./temboard_db-hostnames_exporter.sh
echo

#Call bash script to export InfluxDB data to CSV via HTTP API
echo
source influxdb-data_exporter.sh
echo "Getting data from InfluxDB..."
echo
influxExport "rec"
influxExport "prod"
influxExport "dev"
echo

#Call bash script to export hostnames of oracle servers from CloudControl database
echo "Getting hostnames from Oracle..."
echo
./oracle-data_export/oracle_db-hostname_exporter.sh
echo

#Call bash script to export Oracle data to CSV via SQL request
echo
source oracle-data_export/oracle-data_exporter.sh
echo "Getting data from Oracle..."
echo
oracleExport "rec"
oracleExport "prod"
oracleExport "dev"
echo

#Create Header file before sending data if not exixting
if [ ! -s "csv/header" ] #File exist and is not empty
then
    echo "Date,Zone,Cible,Etiquette,Valeur" > csv/header.csv
fi

#Call python script to write csv data to google spreadsheet
echo
echo "Sending all data to Google Sheets..."
./loading-animation.sh python send-csv_google-sheets.py

#Pause to see the terminal log
echo
read -p "Press enter to close"
