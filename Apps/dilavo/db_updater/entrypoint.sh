#!/bin/bash

echo "**** DB-UPDATER ENTRYPOINT ****"


if [ "$DEBUG" == "YES" ]
then
    while [ "1" == "1" ]
    do
      echo "<----- DEBUG MODE -----> (1) launch R: 'deit db_updater R'"
      echo "<----- DEBUG MODE -----> (2) source('dispatcher.R')"
      echo "<----- DEBUG MODE -----> (3) Dispatcher no longer launches probe_dir script"
      echo "<----- DEBUG MODE -----> --------------------------------------------------"
      echo "<----- DEBUG MODE -----> (4) launch R: 'deit db_updater R'"
      echo "<----- DEBUG MODE -----> (5) source('probe_dir.R') # and then type 'mco_dgf'"
      sleep 1000
    done
fi

 ./dispatcher.R