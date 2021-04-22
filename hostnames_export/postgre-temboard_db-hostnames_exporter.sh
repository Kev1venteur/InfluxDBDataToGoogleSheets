#!/bin/bash
# Read user and password from file in credentials folder
temuser=$(sed -n -e 1p credentials/temboard_rec.creds)
tempass=$(sed -n -e 2p credentials/temboard_rec.creds)

# Export env password variable
export PGPASSWORD=$tempass

echo "Export Temboard hostnames for rec..."
echo
# Connect to Rec-PostgreSQL DB and launch query - store result in variable
recTemHosts=$(psql -h u3recu523 -U ${temuser} -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts ORDER BY hostname ASC;')
# Remove first second line and the 2 last lines
echo "${recTemHosts}" | sed -e '1d;2d;' | head -n -2 | cut -d . -f1 > "csv/rec-temboard-hostnames.csv"

echo "Export Temboard hostnames for dev..."
echo
# Connect to Dev-PostgreSQL DB and launch query - store result in variable
devTemHosts=$(psql -h u3antu505 -U ${temuser} -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts ORDER BY hostname ASC;')
# Remove first second line and the 2 last lines
echo "${devTemHosts}" | sed -e '1d;2d;' | head -n -2 | cut -d . -f1 > "csv/dev-temboard-hostnames.csv"

temuser=$(sed -n -e 1p credentials/temboard_prod.creds)
tempass=$(sed -n -e 2p credentials/temboard_prod.creds)

# Export env password variable
export PGPASSWORD=$tempass

echo "Export Temboard hostnames for prod..."
echo
# Connect to Prod-PostgreSQL DB and launch query - store result in csv
prodTemHosts=$(psql -h u3antu579 -U ${temuser} -p 5433 -d temboard -c 'SELECT hostname FROM monitoring.hosts ORDER BY hostname ASC;')
# Remove first second line and the 2 last lines
echo "${prodTemHosts}" | sed -e '1d;2d;' | head -n -2 | cut -d . -f1 > "csv/prod-temboard-hostnames.csv"

echo "Temboard hostnames succesfully exported."
