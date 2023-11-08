FROM alpine:latest

RUN apk add --no-cache postgresql15-client bash

WORKDIR /home/postgres

COPY . .

RUN chown -R postgres /home/postgres/

USER postgres

ENV PGPASSFILE=/home/postgres/.pgpass

CMD /home/postgres/setup-db.sh
