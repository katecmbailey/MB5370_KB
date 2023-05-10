### ----------------- ###

## Assignment - End-to-end data analysis in R ##

----------------- 

## Import the data ##

library(readr)
QLD_sharkdata <- read_csv("E:/QLD_Sharkdata.csv", skip = 1, 17) # remove the first row of data 
View(QLD_sharkdata)
data = QLD_Sharkdata
----------------- 

## Tidying the data ##

library(tidyverse)

mutate(data, 
       "Other" = NULL, 
       "2001 total" = NULL, 
       "2002 total" = NULL,
       "2003 total" = NULL,
       "2004 total" = NULL, 
       "2005 total" = NULL, 
       "2006 total" = NULL,
       "2007 total" = NULL, 
       "2008 total" = NULL, 
       "2009 total" = NULL) # To remove columns with no value 

