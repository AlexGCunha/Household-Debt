#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Make some summary statistics to try to understand from where the error 
# of few observation in more recent years comes from
#------------------------------------------------------------------------------------------------------------------------------


options(file.download.method="wininet")
repository = "http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/"
if (!require("dplyr")) install.packages("splitstackshape", repos = repository)
if (!require("haven")) install.packages("splitstackshape", repos = repository)
if (!require("arrow")) install.packages("splitstackshape", repos = repository)
if (!require("stringr")) install.packages("splitstackshape", repos = repository)
if (!require("tibble")) install.packages("splitstackshape", repos = repository)
if (!require("tidyr")) install.packages("splitstackshape", repos = repository)
if (!require("ggplot2")) install.packages("splitstackshape", repos = repository)
if (!require("readr")) install.packages("splitstackshape", repos = repository)
if (!require("purrr")) install.packages("splitstackshape", repos = repository)
if (!require("readxl")) install.packages("splitstackshape", repos = repository)

library(tidyverse)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
setwd(data_path)
df = read_parquet("sample_complete_information.parquet")

#Try to see if we are fully dropping some years
df1 = df %>% 
  #filter only one observation per baseline and pis
  filter(ano == baseline) %>% 
  group_by(baseline) %>% 
  summarise(individuals_per_year = n()) %>% 
  ungroup()

print(df1)

#See this same information on the base created on the code just before
df2 = read_parquet("RAIS_agg.parquet")
df2 = df2 %>% 
  group_by(ano) %>% 
  summarise(individuals_agg_base = n()) %>% 
  ungroup()
print(df2)

#And, in the code before that
for (y in c(1994:2021)){
  #in the first part of the code (donwloaded from teradata)
  year = substr(y, 3,4)
  filename = paste0("RAIS_hd_",year,".parquet")
  df3 = read_parquet(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  n1 = nrow(df3)
  
  #in the second part of the code (already cleaned)
  filename = paste0("RAIS_comp_",year,".parquet")
  df4 = read_parquet(filename)
  n2 = nrow(df4)
  
  message = paste0('Individuals in yearly file ', year, ': ', n1, ', ', n2)
  print(message)
  rm(df3, df4)
    
}