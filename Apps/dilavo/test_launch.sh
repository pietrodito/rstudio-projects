#!/bin/bash
docker compose -f test_compose.yml down  && \
docker compose -f test_compose.yml build && \
docker compose -f test_compose.yml up  # --detach  

docker compose logs --follow app db_updater
