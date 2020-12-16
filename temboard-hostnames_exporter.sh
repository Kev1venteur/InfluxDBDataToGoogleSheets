#!/bin/bash
#Login to get the session key
#Send json object to login URL
curl -k -X POST -H "Content-Type: application/json"\
                -d '{"username": "admin", "password": "Alex3Pont9"}'\
                https://u3recu523:8888/login | sed -E "s/^.+\"([a-f0-9]+)\".+$/\1/" > csv/raw/raw-temboard-data.csv
echo
