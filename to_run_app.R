rm(list=ls())
options(max.print=999999)
library(pacman)
p_load(here)
p_load(tidyverse)
p_load(shiny)
getwd()
##test locally
runApp("eth_mining_profitability")
#deploy in shiny
rsconnect::setAccountInfo(name='nicolas-molano',
                          token='xxxx',
                          secret='<SECRET>')

rsconnect::deployApp("eth_mining_profitability")
