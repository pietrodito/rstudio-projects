#!/bin/sh
#

DB_READY=2

while [ $DB_READY != 0 ]
do
  pg_isready -h db
  DB_READY=$?
  sleep 1
done

createdb -h db MCO_DGF
createdb -h db MCO_OQN
createdb -h db HAD_DGF
createdb -h db HAD_OQN
createdb -h db SMR_DGF
createdb -h db SMR_OQN
createdb -h db PSY_DGF
createdb -h db PSY_OQN
