#!/bin/bash
# Prompt for temboard database username and password
temuser=$(sed -n -e 1p credentials/temboard_rec.creds)
tempass=$(sed -n -e 2p credentials/temboard_rec.creds)
echo "Export hostnames rec..."
echo

# Export env password variable
export PGPASSWORD=$tempass

# Connect to Rec-PostgreSQL DB and launch query - store result in csv
psql -h u3recu523 -U postgres -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts;' > csv/raw/raw-rec-temboard-hostnames.csv
# Remove first second line
sed -i '1d;2d;' csv/raw/raw-rec-temboard-hostnames.csv
# Remove the 2 last lines
head -n -2 csv/raw/raw-rec-temboard-hostnames.csv > csv/rec-temboard-hostnames.csv


temuser=$(sed -n -e 1p credentials/temboard_prod.creds)
tempass=$(sed -n -e 2p credentials/temboard_prod.creds)
echo "Export hostnames prod..."
echo

# Export env password variable
export PGPASSWORD=$tempass

# Connect to Rec-PostgreSQL DB and launch query - store result in csv
psql -h u3antu579 -U postgres -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts;' > csv/raw/raw-prod-temboard-hostnames.csv
# Remove first second line
sed -i '1d;2d;' csv/raw/raw-prod-temboard-hostnames.csv
# Remove the 2 last lines
head -n -2 csv/raw/raw-prod-temboard-hostnames.csv > csv/prod-temboard-hostnames.csv

#Cannot use grep or egrep to only keep good lines, because it creates an unknown charachter (unusable) at each keeped line.

echo "Temboard hostnames succesfully exported."
