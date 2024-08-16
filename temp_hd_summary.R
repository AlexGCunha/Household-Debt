#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Print a summary of data downloaded by year
#------------------------------------------------------------------------------------------------------------------------------
options(file.download.method="wininet")
repository = "http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/"
if (!require("dplyr")) install.packages("splitstackshape", repos=repository)
if (!require("haven")) install.packages("splitstackshape", repos = repository)
if (!require("arrow")) install.packages("splitstackshape", repos = repository)
if (!require("stringr")) install.packages("splitstackshape", repos = repository)
if (!require("tibble")) install.packages("splitstackshape", repos = repository)
if (!require("tidyr")) install.packages("splitstackshape", repos = repository)
if (!require("ggplot2")) install.packages("splitstackshape", repos = repository)
if (!require("readr")) install.packages("splitstackshape", repos = repository)
if (!require("purrr")) install.packages("splitstackshape", repos = repository)

# library(tidyverse)
# library(haven) 
# library(arrow)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check"
scr_path = "Z:/DATA/Dta_files/SCR_TERADATA"
setwd(data_path)

for (i in c(1997:2021)){
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename) 
  
  print(summary(df))
}
