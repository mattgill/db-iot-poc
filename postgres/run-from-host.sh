#!/bin/bash -i
# give server time to "start"
docker compose up --detach --remove-orphans

# oracle needs some time to wake
sleep 5
docker exec -it postgres01 /bin/bash /code/run-inside.sh
docker compose down