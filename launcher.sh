#!/bin/bash
#---------------------------------CAUTION-------------------------------------------#
#If the script does not works for any dark reasons, try deleting your
#token.picle file in credentials folder & restart your internet
#connection.
#-----------------------------------------------------------------------------------#
#Call bash script to export InfluxDB data to CSV
echo "Getting data from InfluxDB..."
echo
./influxdb-data_exporter.sh
#Removing the first csv line
sed 1d csv/raw/raw-influx-data.csv > csv/formatted/formatted-influx-data.csv
echo "InfluxDB data correctly formatted to CSV normalisation."
echo
#Call bash script to export Oracle data to CSV
echo "Getting data from Oracle..."
echo
#Put commas instead of spaces
sed -e 's/\s\+/,/g' csv/raw/raw-oracle-data.csv > csv/formatted/formatted-oracle-data.csv
#Add dates to CSV
cat csv/formatted/formatted-oracle-data.csv | xargs -d"\n" -I {} date +"%Y-%m-%d {}" >> csv/raw/raw-oracle-data.csv
#Removing first csv line
sed 1d csv/raw/raw-oracle-data.csv > csv/formatted/formatted-oracle-data.csv
echo "Oracle data correctly formatted to CSV normalisation."
echo
./oracle-data_export/oracle-data_exporter.sh
#
#----------------------------------PROXY--------------------------------------------#
#If you have a proxy uncomment the 2 next lines and put your proxy cert path
#Getting cert path location
cert_path=$(python.exe locate-cert-path.py)
#Replacing Certifi cert with credentials/cacert.pem
yes | cp credentials/cacert.pem $cert_path
#Setting python env variable to use cert
export REQUESTS_CA_BUNDLE=credentials/cacert.pem && echo "Set proxy cert." && echo
export http_proxy="http://127.0.0.1:9000"
export https_proxy="http://127.0.0.1:9000"
#-----------------------------------------------------------------------------------#
#Call python script to write csv data to google spreadsheet
echo "Sending all data to Google Sheets..."
./loading-animation.sh python.exe send-csv_google-sheets.py
#Pause to see the terminal log
echo
read -p "Press enter to close"
