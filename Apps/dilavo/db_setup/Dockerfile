FROM alpine:latest

RUN apk update && apk add postgresql15-client 

WORKDIR /home/postgres

COPY . .

RUN chown -R postgres /home/postgres/ 

USER postgres

ENV PGPASSFILE=/home/postgres/.pgpass

CMD /home/postgres/setup-db.sh
