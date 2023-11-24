FROM rocker/shiny-verse:latest

ARG coro_calaisis="./Maxime GARNIER/2023/Coronarographie dans le Calaisis/"

COPY  ${coro_calaisis} /srv/shiny-server/
COPY ./hdfmaps /

RUN R -q -e 'devtools::install("/hdfmaps")'
