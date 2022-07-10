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
p_load(RSelenium)
library(bueri)

url <-"https://coinmarketcap.com/currencies/ethereum/"
webpage <- read_html(url)

eth_usd<-html_element(webpage,".priceValue") %>%
  html_text() %>% str_remove_all(",|\\$") %>% as.numeric()

url <-"https://www.cnbc.com/quotes/COP="
webpage <- read_html(url)

html_element(webpage,".QuoteStrip-lastPrice")%>%
  html_text()%>% str_remove_all(",|\\$") %>% as.numeric()

###to web scraping using Rselenium
#not for use in shiny app
check_object <- function(object) {
  cat("\nclass: ",
      class(object),
      "\ntypeof: ",
      typeof(object),
      "\n")
}

client_server <- RSelenium::rsDriver(browser=c("chrome"), 
                                     chromever="103.0.5060.53",
                                     version="3.141.59",
                                     port=4585L, 
                                     verbose=F,
                                     check =F)
check_object(client_server)

driver <- client_server[["client"]]
check_object(driver)


url <-"https://www.bloomberg.com/quote/USDCOP:CUR"
driver$navigate(url)
driver$getCurrentUrl()
driver$findElement

login_xpath <- "//*[@id=\"root\"]/div/div/section/section[1]/div/div[2]/section[1]/section/section/section/div[1]/span[1]"
login_link <- driver$findElement(using = "xpath", value = login_xpath)
check_object(login_link)

# This method returns the element tag name
login_link$getElementTagName()

# This method returns the element inner text
###this
login_link$getElementText()

# This method returns an element attribute (in this case, "href")
login_link$getElementAttribute("href")
