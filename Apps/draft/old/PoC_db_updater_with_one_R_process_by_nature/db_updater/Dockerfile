FROM r-base:4.3.1

COPY ./db_updater/* ./

RUN mkdir -p /ovalide_data && chown 999:999 /ovalide_data

ENTRYPOINT [ "./entrypoint.sh" ]