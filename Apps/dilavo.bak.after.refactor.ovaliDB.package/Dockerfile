FROM rocker/shiny:4.3

RUN apt-get update && apt-get install -y \
    libpq5 libpq-dev libssl-dev          \
    libxml2-dev                          \
    && rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages("renv")'

COPY renv.lock /

RUN  R -q -e 'renv::restore()'

COPY . /srv/shiny-server

RUN mkdir -p /ovalide_data           &&  \
                                         \
    mkdir -p /ovalide_data/messages/ &&  \
                                         \
    mkdir -p /ovalide_data/upload/   &&  \
                                         \
    mkdir -p /ovalide_data/tmp/      &&  \
                                         \
    mkdir -p /ovalide_data/mco_dgf/  &&  \
    mkdir -p /ovalide_data/mco_oqn/  &&  \
                                         \
    mkdir -p /ovalide_data/smr_dgf/  &&  \
    mkdir -p /ovalide_data/smr_oqn/  &&  \
                                         \
    mkdir -p /ovalide_data/had_dgf/  &&  \
    mkdir -p /ovalide_data/had_oqn/  &&  \
                                         \
    mkdir -p /ovalide_data/psy_dgf/  &&  \
    mkdir -p /ovalide_data/psy_oqn/  &&  \
                                         \
    chown -R 999:999 /ovalide_data/  &&  \
                                         \
    mkdir -p /logs && chown 999:999 /logs
