#!/bin/bash
docker compose down          && \
docker compose build         && \
docker compose  up  --detach

docker compose logs --follow app db_updater
