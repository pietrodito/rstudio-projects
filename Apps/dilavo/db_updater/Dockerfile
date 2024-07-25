FROM r-base:4.4.1@sha256:619ae385ea3d449433add6247b682f6f5a36a787a5deb57d1b323d4c4856805d

RUN apt-get update               \
  &&                             \
    apt-get install -y           \
      libpq-dev                  \
      libcurl4-openssl-dev       \
      libxml2-dev                \
      libv8-dev                  \
  &&                             \
    rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages(c( \
        "box",                   \
        "dbplyr",                \
        "dplyr",                 \
        "furrr",                 \
        "future",                \
        "glue",                  \
        "gt",                    \
        "pool",                  \
        "progressr",             \
        "readr",                 \
        "RPostgres",             \
        "stringr"                \
        ))'

RUN mkdir -p /binary/packages/
COPY ./packages/*.tar.gz /binary/packages/

RUN R -q -e 'install.packages("/binary/packages/ovaliDB_0.0.0.9000.tar.gz")'

COPY ./db_updater/*          /

RUN chmod 777 log

# RUN mkdir -p /app/logic/ && chown 999:999 /app/logic/

# COPY ./app/logic/db_utils.R  /app/logic/
# COPY ./app/logic/df_utils.R  /app/logic/
# COPY ./app/logic/log_utils.R /app/logic/
# COPY ./app/logic/nature_utils.R /app/logic/

RUN mkdir -p /ovalide_data && chown 999:999 /ovalide_data
RUN mkdir -p /logs && chown 999:999 /logs

RUN useradd updater -u 999
USER updater

ENV TESTTHAT=true
ENV DB_HOST=db
ENV DB_PORT=5432
ENV DB_USER=postgres
ENV DB_PASSWORD=postgres
ENV DB_NAME=postgres

ENTRYPOINT [ "./entrypoint.sh" ]