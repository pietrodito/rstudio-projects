FROM rocker/r-base:latest


ENV DB_HOST db
ENV DB_PORT 5432
ENV DB_USER postgres
ENV DB_PASSWORD postgres
ENV DB_NAME postgres

RUN apt-get update && apt-get install -y libpq-dev && \
        rm -rf /var/lib/apt/lists/*
RUN R -q -e 'install.packages(c("RPostgres", "tidyverse"))'


ENTRYPOINT [ "sleep", "3600" ]