#!/bin/bash
# Prompt for temboard database username and password
temuser=$(sed -n -e 1p credentials/temboard.creds)
tempass=$(sed -n -e 2p credentials/temboard.creds)
echo

# Export env password variable
export PGPASSWORD=$tempass
# Connect to PostgreSQL DB and launch query - store result in csv
psql -h u3recu523 -U postgres -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts;' > csv/raw/raw-temboard-hostnames.csv
# Remove first second line
sed -i '1d;2d;' csv/raw/raw-temboard-hostnames.csv
# Remove the 2 last lines
head -n -2 csv/raw/raw-temboard-hostnames.csv > csv/temboard-hostnames.csv
#Cannot use grep or egrep to only keep good lines, because it creates an unknown charachter (unusable) at each keeped line.

echo "Temboard hostnames succesfully exported."
