#!/bin/bash

echo "**** DB-UPDATER ENTRYPOINT ****"


if [ "$DEBUG" == "ALL" ]
then
    while [ "1" == "1" ]
    do
      echo "< DEBUG MODE > (1) launch R: 'deit db_updater R'"
      echo "< DEBUG MODE > (2) source('dispatcher.R')"
      echo "< DEBUG MODE > ---------------------------------------------------"
      echo "< DEBUG MODE > (3) Dispatcher no longer launches probe_dir script"
      echo "< DEBUG MODE > (4) deit db_updater R -e 'source(\"probe_dir.R\")'"
      sleep 1000
    done
fi

if [ "$DEBUG" == "PROBE" ]
then
  echo "< DEBUG MODE > (1) Dispatcher no longer launches probe_dir script"
  echo "< DEBUG MODE > (2) deit db_updater R -e 'source(\"probe_dir.R\")'"
fi

 ./dispatcher.R