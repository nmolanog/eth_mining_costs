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
p_load(shiny)

ui <- fluidPage(
  titlePanel("Mining Profitability"),
  sidebarLayout(
    sidebarPanel(
      numericInput(inputId="EC",label="Energy cost COP",value=366420,min=1000,max=10000000,
                   step=1),
      numericInput("Meth","ETH ammount Mined",0.08,0.0000001,10000,1),
      numericInput("my_ETH_USD","ETH price (USD)",NA,1,100000,1),
      numericInput("my_USD_COP","USD price (COP)",NA,1,100000,1),
      actionButton("execute","update prices online")
    ),
    mainPanel(
      h3("Tasa de cambio USD-COP vs ETH-USD"),
      plotlyOutput("p1"),
      h5("Puntos por encima de la curva son rentables"),
      h4("Current Rates:"),
      textOutput("txt") ,
      h4("Sources:"),
      h5("https://coinmarketcap.com/currencies/ethereum/"),
      h5("https://www.cnbc.com/quotes/COP=")
      )
  )
)

server <- function(input, output, session){
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
}
shinyApp(ui = ui, server = server)

