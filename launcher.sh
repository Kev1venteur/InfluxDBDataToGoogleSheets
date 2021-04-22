#!/bin/bash
#---------------------------------CAUTION-------------------------------------------#
#If the script does not works for any dark reasons, try deleting your
#token.pickle file in credentials folder & restart your internet
#connection.
#-----------------------------------------------------------------------------------#
#----------------------------------PROXY--------------------------------------------#
#If you have a proxy, uncomment this block of lines, and put your proxy cert 
#renamed as "cacert.pem" in the credentials folder
#Getting cert path location
export PYTHONIOENCODING=utf8
if [[ "$OSTYPE" == "msys" ]]
  then
    #Python for windows and git bash
    cert_path=$(python python_tools/locate-cert-path.py)
elif [[ "$OSTYPE" == "linux-gnu" ]]
  then
    #Python for linux
    cert_path=$(python3 python_tools/locate-cert-path.py)
else
    echo "OSTYPE unknown, cannot continue the script" 
    exit
fi
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
rm csv/raw-clusters/*
rm csv/*.csv

#Call bash script to export hostnames of postgresql servers from Temboard database
echo "Getting hostnames from Temboard..."
echo
source hostnames_export/postgreV12-influx_db-hostname_exporter.sh
echo "Getting PostgreV12 hostnames from InfluxDB..."
echo
influxExport "rec"
influxExport "prod"

#Call bash script to export InfluxDB data to CSV via HTTP API
echo
source postgre-data_export/postgre-data_exporter.sh
echo "Getting data from InfluxDB..."
echo
influxExport "rec"
influxExport "prod"
echo

#Call bash script to export hostnames of oracle servers from CloudControl database
echo "Getting hostnames from Oracle..."
echo
./hostnames_export/oracle_db-hostname_exporter.sh
echo

#Call bash script to export Oracle data for all servers to CSV via SQL request
echo
source oracle-data_export/oracle-data_exporter.sh
echo "Getting Servers Infos from Oracle..."
echo
oracleExport "rec"
oracleExport "dev"
oracleExport "prod"
echo

#Call bash script to export Oracle data for clusters only to CSV via SQL request
echo
source oracle-data_export/oracle-clusters_exporter.sh
echo "Getting Cluster Infos from Oracle..."
echo
oracleExport "rec"
oracleExport "dev"
oracleExport "prod"
echo

#Create Header files before sending data
echo "Date,Zone,Cible,Etiquette,Valeur" > csv/header/Capa-Postgre.csv
echo "Date,Zone,Cluster,Cible,Etiquette,Valeur" > csv/header/Capa-Oracle.csv
echo "Date,Zone,Cluster,Etiquette,Valeur" > csv/header/Capa-Clusters-Oracle.csv

#Call python script to write csv data to google spreadsheet
echo
echo "Sending all data to Google Sheets..."
if [[ "$OSTYPE" == "msys" ]]
  then
    #Python for windows and git bash
    ./loading-animation.sh python send-csv_google-sheets.py
elif [[ "$OSTYPE" == "linux-gnu" ]]
  then
    #Python for linux
    ./loading-animation.sh python3 send-csv_google-sheets.py
else
    echo "OSTYPE unknown, cannot continue the script" 
    exit
fi

#Pause to see the terminal log
echo
read -p "Press enter to close"
