#!/bin/bash -i
# give server time to "start"
docker compose up --detach --remove-orphans

# needs some time to wake
sleep 5
docker exec -it timescale01 /bin/bash /code/run-inside.sh
docker compose down