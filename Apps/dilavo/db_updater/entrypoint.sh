#!/bin/bash

echo "**** DB-UPDATER ENTRYPOINT ****"


if [ "$DEBUG" == "YES" ]
then
    while [ "1" == "1" ]
    do
      echo "<----- DEBUG MODE -----> (1) copy .csv files in ovalide_data/mco_dgf"
      echo "<----- DEBUG MODE -----> (2) launch R: 'deit db_updater R'"
      echo "<----- DEBUG MODE -----> (3) source('probe_dir.R') # and then type 'mco_dgf'"
      sleep 1000
    done
else
    ./dispatcher.R
fi


