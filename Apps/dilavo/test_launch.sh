#!/bin/bash

docker network inspect test_network >/dev/null 2>&1 || \
  docker network create test_network

docker compose -f test_compose.yml down  && \
docker compose -f test_compose.yml build && \
docker compose -f test_compose.yml up  --detach

docker compose -f test_compose.yml logs --follow db_updater
