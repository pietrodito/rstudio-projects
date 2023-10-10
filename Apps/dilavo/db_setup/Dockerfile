FROM alpine:latest

RUN apk update && apk add postgresql14-client

COPY . /

CMD ["/setup-db.sh"]