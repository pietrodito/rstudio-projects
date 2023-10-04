FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /ovalide_data && chown 999:999 /ovalide_data

RUN R -q -e 'install.packages("renv")'

COPY renv.lock /

RUN  R -q -e 'renv::restore()'

COPY . /srv/shiny-server
