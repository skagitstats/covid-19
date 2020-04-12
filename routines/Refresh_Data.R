
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
  .[[4]] %>% 
 #html_nodes("tbody") %>% 
  rvest::html_table()  
  
freshdata$DateStamp = as_date(Sys.time()  - hours(8))
freshdata$News = NA

pastData = read_csv("../data/skagit_valley_covid_counts.csv", 
                      col_types  = cols(Date = col_datetime(format = ""),
                                        Cases = col_double(),
                                        Deaths = col_double(),
                                        Hospitalized = col_double(),
                                        Recovered  = col_double(), 
                                        News = col_character())) 

freshdata$county = "Skagit"

newData <- rbind(
  select(pastData,
         Date , 
         Cases , 
         Deaths , 
         Hospitalized ,
         Recovered, 
         News,
         county), 
  select(freshdata,
         Date =  DateStamp, 
         Cases = `Positive*`, 
         Deaths = Deaths, 
         Hospitalized = `Hospitalized**`,
         Recovered = `Recovered`, 
         News,
         county))


tail(newData)
newData$Hospitalized[is.na(newData$Hospitalized)] <- 0 
newData$Recovered[is.na(newData$Recovered)] <- 0


newData %>%
  transmute(Date = as_date(Date), Cases, Deaths, Hospitalized, Recovered, News, county  ="Skagit") %>%
  mutate(newCases = Cases - lag(Cases, 1),
         newDeaths = Deaths - lag(Deaths, 1), 
         NewHosp=  Hospitalized - lag(Hospitalized, 1), 
         newRecov = Recovered - lag(Recovered, 1), 
         nonRecov = Cases - Recovered ) %>% 
  distinct()  %>% 
write_csv(path = "../data/skagit_valley_covid_counts.csv")


