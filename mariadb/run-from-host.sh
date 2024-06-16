#!/bin/bash -i
# give server time to "start"
docker compose up --detach --remove-orphans

sleep 3
docker exec -it mariadb01 /bin/bash /code/run-inside.sh
docker compose down