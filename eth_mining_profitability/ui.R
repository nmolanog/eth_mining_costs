#######################
###load data
#######################
library(tidyverse)
library(plotly)
library(xml2)
library(rvest)
library(shiny)

fluidPage(
  titlePanel("Mining Profitability"),
  sidebarLayout(
    sidebarPanel(
      numericInput(inputId="EC",label="Energy cost COP",value=366420,min=1000,max=10000000,
                   step=1),
      numericInput("Meth","ETH ammount Mined",0.085277662708337,0.0000001,10000,1),
      numericInput("my_ETH_USD","ETH price (USD)",NA,1,100000,1),
      numericInput("my_USD_COP","USD price (COP)",NA,1,100000,1),
      actionButton("execute","update prices online")
    ),
    mainPanel(
      h3("exchange rates USD-COP vs ETH-USD"),
      plotlyOutput("p1"),
      h5("points above black curve are profitable"),
      h4("Current Rates:"),
      textOutput("txt") ,
      h4("Profitability based on market:"),
      textOutput("profitability_market") ,
      h4("Profitability based on user settings:"),
      textOutput("profitability_user") ,
      h4("Sources:"),
      tags$a(href="https://coinmarketcap.com/currencies/ethereum/", "https://coinmarketcap.com/currencies/ethereum/"),
      h4(" "),
      tags$a(href="https://www.cnbc.com/quotes/COP=", "httpshttps://www.cnbc.com/quotes/COP=")
    )
  )
)
