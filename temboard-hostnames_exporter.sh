#!/bin/bash
#Login and keep session cookie
curl -s -c credentials/temboard.cookie -d 'username=admin&password=Alex3Pont9' -k https://u3recu523:8888/login > /dev/null
#Getting HTML page containing all the hostnames in a CSV
curl -s -b credentials/temboard.cookie -k https://u3recu523:8888/settings/instances > csv/raw/raw-temboard-data.csv
#Formatting CSV to only get hostnames (only getting lines starting with <td> and ending with </td>)
sed -n 's/<td>\(.*\)<\/td>/\1/Ip' csv/raw/raw-temboard-data.csv > csv/raw/raw-temboard2-data.csv
#Only getting lines ending by ".fr"
cat csv/raw/raw-temboard2-data.csv | grep '\.fr$' > csv/raw/raw-temboard-data.csv
#Deleting temp temboard file
rm csv/raw/raw-temboard2-data.csv
echo "Temboard hostnames succesfully exported."
