FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

RUN apk add --no-cache postgresql16-client bash

WORKDIR /home/postgres

COPY . .

RUN chown -R postgres /home/postgres/

USER postgres

ENV PGPASSFILE=/home/postgres/.pgpass

CMD /home/postgres/setup-db.sh
