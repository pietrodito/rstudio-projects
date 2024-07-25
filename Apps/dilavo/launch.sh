#!/bin/bash

## Read setup variables
. .env

## Git forgets permissions
chmod 0600 ./db_setup/.pgpass
chmod 0600 ./pgadmin/pgpass
chmod -R 777 ./ovalide_data


## Down everybody
docker compose down
docker compose -f test_compose.yml down


if [ "$RUN_IN_RSTUDIO" == "NO" ]
then
  echo "*** App will RUN IN DOCKER ***"

  docker compose build         && \
  docker compose  up  --detach

  # docker compose logs --follow app db_updater db_setup
  docker compose logs --follow db_setup

else

  echo "*** App will RUN IN RSTUDIO ***"

 # docker network inspect test_network >/dev/null 2>&1 || \
 #   docker network create test_network

  docker compose -f test_compose.yml build && \
  docker compose -f test_compose.yml up  --detach

  docker compose -f test_compose.yml logs --follow db_updater db_setup
fi

