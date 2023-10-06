#!/bin/sh

R -q -e 'source("/db_updater_script.R")' mco_dgf &
R -q -e 'source("/db_updater_script.R")' mco_oqn &
R -q -e 'source("/db_updater_script.R")' smr_dgf &
R -q -e 'source("/db_updater_script.R")' smr_oqn &
R -q -e 'source("/db_updater_script.R")' had_dgf &
R -q -e 'source("/db_updater_script.R")' had_oqn &
R -q -e 'source("/db_updater_script.R")' psy_dgf &
R -q -e 'source("/db_updater_script.R")' psy_oqn 
