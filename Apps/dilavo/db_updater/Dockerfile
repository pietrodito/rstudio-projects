FROM r-base:4.3.1


ENV DB_HOST db
ENV DB_PORT 5432
ENV DB_USER postgres
ENV DB_PASSWORD postgres
ENV DB_NAME postgres

RUN apt-get update && apt-get install -y libpq-dev && \
        rm -rf /var/lib/apt/lists/*
RUN R -q -e 'install.packages(c( \
        "box",                   \
        "dplyr",                 \
        "glue",                  \
        "readr",                 \
        "RPostgres",             \
        "stringr"                \
        ))'

RUN mkdir -p /app/logic/ && chown 999:999 /app/logic/

COPY ./db_updater/*          /
COPY ./app/logic/db_utils.R  /app/logic/
COPY ./app/logic/df_utils.R  /app/logic/
COPY ./app/logic/log_utils.R /app/logic/

RUN mkdir -p /ovalide_data && chown 999:999 /ovalide_data
RUN mkdir -p /logs && chown 999:999 /logs

RUN useradd updater -u 999
USER updater

ENTRYPOINT [ "./entrypoint.sh" ]