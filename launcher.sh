#!/bin/bash
#Call bash script to export InfluxDB data to CSV
echo "Getting data from InfluxDB..."
./influxdb-data_exporter.sh
#Removing the first csv line
sed 1d raw-influx-csv-data.csv > formatted-influx-csv-data.csv
#Call bash script to export Oracle data to CSV
echo "Getting data from Oracle..."
./oracle-data_export/oracle-data_exporter.sh
#Make alias to correctly call python from bash
#Uncomment the next line ONLY FOR WINDOWS !
alias python='winpty python.exe'
#Call python script to write csv data to google spreadsheet
echo "Sending data to Google Sheets..."
python send-csv_google-sheets.py
#Pause to see the log
read -p "Press enter to continue"
