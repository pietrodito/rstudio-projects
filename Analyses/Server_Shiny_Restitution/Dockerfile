FROM rocker/shiny-verse:latest

RUN apt-get update && apt-get install -y \
      libudunits2-dev \
      libproj-dev \
      libgdal-dev \
   && rm -rf /var/lib/apt/lists/*

ARG coro_calaisis="Coronarographie dans le Calaisis/"
ARG hdfmaps="utils/hdfmaps/"
 
RUN mkdir -p /hdfmaps
 
COPY  ${hdfmaps} /hdfmaps

RUN R -q -e 'devtools::install_github("slowkow/ggrepel");        \
             devtools::install_github("thomasp85/ggforce");      \
             devtools::install_github("ropensci/rnaturalearth"); \
             devtools::install_github("r-spatial/sf");           \
             devtools::install_github("rstudio/DT");             \
             devtools::install_github("rstudio/bslib");          \
             devtools::install_github("daattali/shinyjs");       \
             devtools::install("hdfmaps")'

RUN rm -rf /srv/shiny-server/*

COPY  ${coro_calaisis} /srv/shiny-server/${coro_calaisis}
ARG lamorlaye="Activite autour SSR Lamorlaye/"  
COPY ${lamorlaye} /srv/shiny-server/${lamorlaye}

RUN chmod 777 "/srv/shiny-server/${lamorlaye}" && chmod 777 "/srv/shiny-server/${coro_calaisis}"
