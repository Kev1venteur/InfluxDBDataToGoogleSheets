#!/bin/bash
#---------------------------------CAUTION--------------------------------------#
#If the script does not works for any dark reasons, try deleting your
#token.picle file in credentials folder & restart your internet
#connection.
#------------------------------------------------------------------------------#
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
./oracle-data_export/oracle-data_exporter.sh
#Make alias to correctly call python from bash
#---------------------------------WINDOWS--------------------------------------#
#Uncomment the next line ONLY FOR WINDOWS !
alias python='winpty python.exe'
#----------------------------------PROXY---------------------------------------#
#If you have a proxy uncomment the next line and put your proxy cert path
export REQUESTS_CA_BUNDLE=credentials/cacert.pem
#Then duplicate your cert to the path returned by "locate-cert-path.py"
#with the name "cacert.pem"
#You can execute it by typing : "python *scriptfolderpath*/locate-cert-path.py"
#------------------------------------------------------------------------------#
#Call python script to write csv data to google spreadsheet
echo "Sending all data to Google Sheets..."
python send-csv_google-sheets.py
#Pause to see the terminal log
echo
read -p "End, press enter to continue"
