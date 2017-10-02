FROM rocker/shiny
MAINTAINER Don Rauscher (donald.rauscher@gmail.com)
RUN R -e "install.packages(c('dplyr'), repos='http://cran.rstudio.com/')"
COPY ./shiny/ /srv/shiny-server/farkle/
