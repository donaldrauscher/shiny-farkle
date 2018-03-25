# start with image with R and Shiny server installed
FROM rocker/shiny

# copy files
COPY ./shiny/ /srv/shiny-server/farkle/

# initialize some inputs for the app
WORKDIR /srv/shiny-server/farkle/
RUN mkdir -p data && \
  R -e "install.packages(c('dplyr'), repos='http://cran.rstudio.com/')" && \
  Rscript init.R

# shiny configuration
RUN mv shiny-server.conf /etc/shiny-server/shiny-server.conf
