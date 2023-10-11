FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /ovalide_data           &&  \
                                         \
    mkdir -p /ovalide_data/upload/   &&  \
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
    chown -R 999:999 /ovalide_data/

RUN R -q -e 'install.packages("renv")'

COPY renv.lock /

RUN  R -q -e 'renv::restore()'

COPY . /srv/shiny-server

RUN mkdir -p /logs && chown 999:999 /logs
