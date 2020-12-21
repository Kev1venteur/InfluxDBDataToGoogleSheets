#!/bin/bash
#Login and keep session cookie
curl -s -c credentials/temboard.cookie -d 'username=admin&password=Alex3Pont9' -k https://u3recu523:8888/login > /dev/null
#Remove all existing CSV files
rm csv/*
#Getting HTML page containing all the hostnames in a CSV
curl -s -b credentials/temboard.cookie -k https://u3recu523:8888/settings/instances > csv/raw/raw-temboard-data.csv
#Formatting CSV to only get hostnames (only getting lines starting with <td> and ending with </td>)
sed -n 's/<td>\(.*\)<\/td>/\1/Ip' csv/raw/raw-temboard-data.csv > csv/raw/raw-temboard2-data.csv
#Only getting lines ending by ".fr"
cat csv/raw/raw-temboard2-data.csv | grep '\.fr$' > csv/temboard-hostnames.csv
#Removing everything and only keep the name (ex: u3recu218)
sed 's/[.].*$//' csv/temboard-hostnames.csv > csv/raw/raw-temboard2-data.csv
cat csv/raw/raw-temboard2-data.csv > csv/temboard-hostnames.csv
#Deleting temp temboard hostname file
rm csv/raw/raw-temboard2-data.csv
echo "Temboard hostnames succesfully exported."
