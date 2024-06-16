#!/bin/bash -i
# give server time to "start"
docker compose up --detach --remove-orphans

# oracle needs some time to wake
sleep 30
docker exec -it oracledb01 /bin/bash /code/run-inside.sh
docker compose down