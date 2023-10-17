#!/bin/bash

echo "**** DB-UPDATER ENTRYPOINT *****"


if [ "$DEBUG" == "YES" ]
then
    while [ "1" == "1" ]
    do
      echo "<----- DEBUG MODE -----> (1) deit db_updater R (2) source('probe_dir.R')"
      sleep 1000
    done
else
    ./dispatcher.R
fi


