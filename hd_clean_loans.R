#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Clean SCR data 
#- Run after  hd_import_SCR
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
if (!require("data.table")) install.packages("splitstackshape", repos = repository)

library(tidyverse)
library(arrow)
library(haven)
library(readxl)
library(data.table)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"

#COMENTAR
data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"

a = Sys.time()


#-------------------------------------
#Initial part to clean loans data
#Only has to be runned once, then we can comment 'forever'
#-------------------------------------

##### Just for Empréstimos e financiamentos
# for (y in 2006:2015){
#   b = Sys.time()
#   loans = read_dta(paste0(data_path, "hd_SCR_individual_loans_", y ,"12.dta"))
#   setDT(loans)
#   loans[, `:=`(mes = substr(as.character(time_id), 5, 6),
#                year = substr(as.character(time_id), 1, 4),
#                cpf = as.numeric(cpf))]
#   
#   loans[, year := as.integer(year)]
#   loans = loans[mes == "12"]
#   loans[, `:=`(time_id = NULL, mes = NULL)]
#   
#   #Guarantee one line of loans per individual/year
#   loans = loans[, n_appear := seq_len(.N), by = .(cpf, year)]
#   loans = loans[n_appear == 1]
#   loans = loans[, n_appear := NULL]
#   
#   #save
#   new_filename = paste0(data_path, "hd_scr_ind_loans_clean_", y, ".parquet")
#   write_parquet(loans, new_filename)
#   rm(new_filename, loans)
#   gc()
#   
#   c = Sys.time()
#   print(paste0("Time to clean ", y, " SCR file: ",
#                round(difftime(c,b, units = 'hours'), 2), ' hours'))
# }


#### For every type of loans in SCR
for (y in 2006:2015){
  b = Sys.time()
  loans = read_dta(paste0(data_path, "hd_SCR_individual_", y ,"12.dta"))
  setDT(loans)
  loans[, `:=`(mes = substr(as.character(time_id), 5, 6),
               year = substr(as.character(time_id), 1, 4),
               cpf = as.numeric(cpf))]

  loans[, year := as.integer(year)]
  loans = loans[mes == "12"]
  loans[, `:=`(time_id = NULL, mes = NULL)]

  #Guarantee one line of loans per individual/year
  loans = loans[, n_appear := seq_len(.N), by = .(cpf, year)]
  loans = loans[n_appear == 1]
  loans = loans[, n_appear := NULL]

  #save
  new_filename = paste0(data_path, "hd_scr_ind_clean_", y, ".parquet")
  write_parquet(loans, new_filename)
  rm(new_filename, loans)
  gc()

  c = Sys.time()
  print(paste0("Time to clean ", y, " SCR file: ",
               round(difftime(c,b, units = 'hours'), 2), ' hours'))
}


c = Sys.time()
print(paste0("Time to clean all SCR files: ",
             round(difftime(c,a, units = 'hours'), 2), ' hours'))

