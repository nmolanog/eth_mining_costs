#######################
###load data
#######################

library(tidyverse)
library(plotly)
library(xml2)
library(rvest)
library(shiny)

function(input, output, session){
  plt_params<-reactive({
    c(month_eth_mined=input$Meth,energy_cost_cop=input$EC,
      my_USD_COP=input$my_USD_COP,my_ETH_USD=input$my_ETH_USD)
  })
  
  res_react<-reactive({
    input$excute
    isolate({
      url <-"https://coinmarketcap.com/currencies/ethereum/"
      webpage <- read_html(url)
      
      current_ETH_USD<-html_element(webpage,".priceValue") %>%
        html_text() %>% str_remove_all(",|\\$") %>% as.numeric()
      
      url2 <-"https://www.cnbc.com/quotes/COP="
      webpage2 <- read_html(url2)
      
      current_USD_COP<-html_element(webpage2,".QuoteStrip-lastPrice")%>%
        html_text()%>% str_remove_all(",|\\$") %>% as.numeric()
      list(current_ETH_USD=current_ETH_USD,current_USD_COP=current_USD_COP)
    })
  })
  
  output$p1 <- renderPlotly({
    usd_cop<-seq(1000,10000,length.out=10000)
    
    current_USD_COP<-res_react()[["current_USD_COP"]]
    current_ETH_USD<-res_react()[["current_ETH_USD"]]
    user_USD_COP<-plt_params()[["my_USD_COP"]]
    user_ETH_USD<-plt_params()[["my_ETH_USD"]]
    
    my_colors <- c("Miner ETH-USD rate" = "black", "current rates" = "red", "user defined rates" = "blue")
    
    z2<-data.frame(usd_cop=usd_cop,
                   ETH_USD=plt_params()[["energy_cost_cop"]]/(plt_params()[["month_eth_mined"]]*usd_cop))
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
        # scale_y_continuous(limits = c(500, 5000), breaks = seq(500, 5000, 500))+
        # scale_x_continuous(limits = c(1000, 10000), breaks = seq(1000, 10000, 1000))+
        theme_bw()) %>% ggplotly()
  })
  output$txt<-renderText({
    paste0("USD to COP: ",res_react()[["current_USD_COP"]]," --- ",
           "ETH to USD: ",res_react()[["current_ETH_USD"]]) 
  }) 
  
  output$profitability_market<-renderText({
    (plt_params()[["energy_cost_cop"]]/(plt_params()[["month_eth_mined"]]*res_react()[["current_USD_COP"]])) < 
      res_react()[["current_ETH_USD"]]
  }) 
  output$profitability_user<-renderText({
    (plt_params()[["energy_cost_cop"]]/(plt_params()[["month_eth_mined"]]*plt_params()[["my_USD_COP"]])) < 
      plt_params()[["my_ETH_USD"]]
  }) 
}