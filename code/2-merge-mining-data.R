## ************************************************************************
## Project:
## Depicting Mangrove's Potential as Blue Carbon Champion in Indonesia
## 
## Syarifah Aini Dalimunthe/ Research Center for Population, BRIN
## Intan Adhi Perdana Putri/ Research Center for Population, BRIN
## Ari Purwanto Sarwo Prasojo/ Research Center for Population, BRIN
## 
## Code for:
## 2-Merge Data after news mining
## 
## Code Writer:
## Ari Purwanto Sarwo Prasojo
## 2021
## ************************************************************************



# Library----
library(dplyr)
library(xlsx)

# Read & Process----
fl <- c("data/mining_06012019_02282021.xlsx",
        "data/mining_06012019_02282021_1.xlsx")

dta <- bind_rows(lapply(fl, read.xlsx, sheetIndex=1))
glimpse(dta)

#-remove duplicate, by link
dta <- dta %>% distinct_at(., vars(link), .keep_all = TRUE)

#-save
dta %>% as.data.frame() %>% 
  write.xlsx(.,"data/14042021_mining_06012019_02282021.xlsx")
