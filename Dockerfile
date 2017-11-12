# start with image with R and Shiny server installed
FROM rocker/shiny

# copy files into correct directories
COPY ./shiny/ /srv/shiny-server/farkle/
RUN mv /srv/shiny-server/farkle/shiny-server.conf /etc/shiny-server/shiny-server.conf

# initialize some inputs for the app
WORKDIR /srv/shiny-server/farkle/
RUN mkdir -p data && \
  R -e "install.packages(c('dplyr'), repos='http://cran.rstudio.com/')" && \
  Rscript init.R
