#!/bin/bash
#Prompt for temboard database username and password
temuser=$(sed -n -e 1p credentials/temboard.creds)
tempass=$(sed -n -e 2p credentials/temboard.creds)
echo
echo "Exportation des hostnames de la base temboard..."

# Export env password variable
export PGPASSWORD=$tempass
# Connect to PostgreSQL DB and launch query - store result in csv
psql -h u3recu523 -U postgres -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts;' | grep 'u3' > csv/temboard-hostnames.csv

echo "Temboard hostnames succesfully exported."
