#!/bin/bash

echo THIS IS UPDATER ENTRYPOINT
touch /logs/entry

./probe_dir.R mco_dgf &
./probe_dir.R mco_oqn &
./probe_dir.R smr_dgf &
./probe_dir.R smr_oqn &
./probe_dir.R had_dgf &
./probe_dir.R had_oqn &
./probe_dir.R psy_dgf &
./probe_dir.R psy_oqn &
./dispatcher.R
