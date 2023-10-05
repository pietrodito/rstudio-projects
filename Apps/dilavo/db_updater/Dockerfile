FROM r-base:4.3.1

RUN apt-get update && apt-get install -y libpq-dev && \
        rm -rf /var/lib/apt/lists/*
RUN R -q -e 'install.packages(c("box", "RPostgres"))'

COPY ./db_updater/ /
COPY ./app/logic/db_utils.R /

RUN mkdir -p /ovalide_data && chown 999:999 /ovalide_data

CMD R -q -e 'source("/db_updater_script.R")'
