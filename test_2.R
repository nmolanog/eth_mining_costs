#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(pacman)
p_load(here)
# p_load(data.table)
p_load(openxlsx)
p_load(tidyverse)
p_load(lubridate)
p_load(chron)
p_load(stringr)
p_load(reshape2)
p_load(plotly)
p_load(xml2)
p_load(rvest)
library(bueri)

month_eth_mined<-0.085277662708337
energy_cost_cop<-366420

usd_cop<-seq(1000,10000,length.out=100)
usd_eth<-seq(100,5000,length.out=100)

url <-"https://coinmarketcap.com/currencies/ethereum/"
webpage <- read_html(url)

current_ETH_USD<-html_element(webpage,".priceValue") %>%
  html_text() %>% str_remove_all(",|\\$") %>% as.numeric()

url2 <-"https://www.cnbc.com/quotes/COP="
webpage2 <- read_html(url2)

current_USD_COP<-html_element(webpage2,".QuoteStrip-lastPrice")%>%
  html_text()%>% str_remove_all(",|\\$") %>% as.numeric()


# current_USD_COP<-4401
# mkr_rate<-1182
my_colors <- c("Miner ETH-USD rate" = "black", "current rates" = "red", "user defined rates" = "blue")
z2<-data.frame(usd_cop=usd_cop,ETH_USD=energy_cost_cop/(month_eth_mined*usd_cop))

user_USD_COP<-3600
user_ETH_USD<-900

z3<-data.frame(USD_COP=c(user_USD_COP,current_USD_COP,NA),
               ETH_USD=c(user_ETH_USD,current_ETH_USD,NA),
               source=c("User","Market","miner neutral rate"))
 
(z2 %>% ggplot(aes(x=usd_cop,y=ETH_USD))+geom_line()+ 
    geom_point(data=z3,mapping =aes(x=USD_COP,y=ETH_USD,color=source))+
    scale_color_manual(breaks = c("User", "Market","miner neutral rate"),
                       values=c("blue", "red","black"))+
    geom_vline(xintercept = current_USD_COP,  color="red",
               linetype="dashed", size=0.5)+
    geom_hline(yintercept = current_ETH_USD,  color="red",
               linetype="dashed", size=0.5)+
    geom_vline(xintercept = user_USD_COP,  color="blue",
               linetype="dashed", size=0.5)+
    geom_hline(yintercept = user_ETH_USD,  color="blue",
               linetype="dashed", size=0.5)+
    scale_y_continuous(limits = c(500, 5000), breaks = seq(500, 5000, 500))+
    scale_x_continuous(limits = c(1000, 10000), breaks = seq(1000, 10000, 1000))+
    theme_bw()) %>% ggplotly()