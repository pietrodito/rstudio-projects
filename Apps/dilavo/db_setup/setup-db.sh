#!/bin/sh
#

DB_READY=2

while [ $DB_READY != 0 ]
do
  pg_isready -h db
  DB_READY=$?
  sleep 1
done


if [ "$( psql -h db -XtAc \
     "SELECT 1 FROM pg_database WHERE datname='PSY_OQN'" )" = '1' ]
then
    echo "Databases already exist"
else
    createdb -h db MCO_DGF
    createdb -h db MCO_OQN
    createdb -h db HAD_DGF
    createdb -h db HAD_OQN
    createdb -h db SMR_DGF
    createdb -h db SMR_OQN
    createdb -h db PSY_DGF
    createdb -h db PSY_OQN
fi



top
