
## script to refresh covid-19 case data in skagit valley 
## from skagit public health website. 

library(readr)
library(httr)
library(rvest)
library(dplyr)
library(tidyr)
library(lubridate)
pub <- read_html( "https://www.skagitcounty.net/Departments/HealthDiseases/coronavirus.htm")

localTime <- Sys.time()


freshdata <- pub %>%
  html_node("body") %>% 
  html_nodes(".table1") %>% 
  .[[3]] %>% 
 #html_nodes("tbody") %>% 
  rvest::html_table(fill = TRUE)  
  
freshdata$DateStamp = ymd_hms(localTime)
freshdata$News = NA

pastData = read_csv("data/skagit_valley_covid_counts.csv", 
                      col_types  = cols(Date = col_datetime(format = ""),
                                        Cases = col_double(),
                                        Deaths = col_double(),
                                        Hospitalized = col_double(),
                                        News = col_character())) 


newData <- rbind(
  pastData, 
  select(freshdata,
         Date =  DateStamp, 
         Cases = `Positive*`, 
         Deaths = Deaths, 
         Hospitalized = `Hospitalized**`, 
         News))

write_csv(newData, path = "data/skagit_valley_covid_counts.csv")


