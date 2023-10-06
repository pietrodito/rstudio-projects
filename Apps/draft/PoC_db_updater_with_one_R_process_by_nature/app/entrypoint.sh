#!/bin/sh

mkdir -p /ovalide_data/mco_dgf/
mkdir -p /ovalide_data/mco_oqn/

mkdir -p /ovalide_data/smr_dgf/
mkdir -p /ovalide_data/smr_oqn/

mkdir -p /ovalide_data/had_dgf/
mkdir -p /ovalide_data/had_oqn/

mkdir -p /ovalide_data/psy_dgf/
mkdir -p /ovalide_data/psy_oqn/

exec "$@"