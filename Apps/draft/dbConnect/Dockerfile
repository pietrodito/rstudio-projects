FROM rocker/shiny:latest

RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages("renv")'

COPY renv.lock /

RUN  R -q -e 'renv::restore()'
