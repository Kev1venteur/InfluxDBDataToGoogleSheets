#!/bin/bash
#Export the db returned values to csv format
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=devconnected" --data-urlencode "q=SELECT \"value\" FROM \"cpu_load_short\" WHERE \"region\"='us-west'" -H "Accept: application/csv" > raw-csv-data.csv
#Make alias to correctly call python from bash
alias python='winpty python.exe'
#Call python script to write csv data to google spreadsheet
python send-csv_google-sheets.py
#Pause to see the log
read -p "Press enter to continue"
