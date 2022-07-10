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
library(bueri)

month_eth_mined<-0.085277662708337
energy_cost_cop<-366420

usd_cop<-seq(3000,6000,length.out=100)
usd_eth<-seq(100,5000,length.out=100)

z0<-expand.grid(usd_cop=usd_cop,usd_eth=usd_eth)
z0$EC_USD<-366420 / z0$usd_cop
z0$MC_USD<-0.085277662708337*z0$usd_eth
z0$diff<-z0$EC_USD-z0$MC_USD
z0$cond<-(z0$EC_USD-z0$MC_USD<0) %>% as.numeric()
z0$z<-energy_cost_cop/(month_eth_mined*z0$usd_eth)

plot_ly(z0,x=~usd_cop, y=~usd_eth, z=~diff, type="scatter3d", mode="markers",color=~diff,size =1)
plot_ly(z0,x=~usd_cop, y=~usd_eth, z=~diff, type="scatter3d", mode="markers",color=~cond,size =1)

z0 %>% ggplot(aes(x=usd_eth,y=z))+geom_point()+ 
  geom_abline(intercept = 3900, slope = 0, color="red",
              linetype="dashed", size=1)

z1<-data.frame(usd_eth=usd_eth,MCE=energy_cost_cop/(month_eth_mined*usd_eth))

current_USD_COP<-3700

(z1 %>% ggplot(aes(x=usd_eth,y=MCE))+geom_point()+ 
  geom_abline(intercept = current_USD_COP, slope = 0, color="red",
              linetype="dashed", size=1)+
    geom_vline(xintercept = energy_cost_cop/(month_eth_mined*current_USD_COP),  color="red",
                linetype="dashed", size=1)+
    theme_bw())%>%
  ggplotly()


current_USD_COP<-3700
mkr_rate<-950
z2<-data.frame(usd_cop=usd_cop,miner_rate=energy_cost_cop/(month_eth_mined*usd_cop))

(z2 %>% ggplot(aes(x=usd_cop,y=miner_rate))+geom_point()+ 
    geom_vline(xintercept = current_USD_COP,  color="red",
               linetype="dashed", size=1)+
    geom_hline(yintercept = mkr_rate,  color="red",
               linetype="dashed", size=1)+
    theme_bw())%>%
  ggplotly()
