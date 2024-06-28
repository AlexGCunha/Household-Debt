#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Work on individual SCR data downloaded from TERADATA
#- Merge with RAIS data worked in the previous codes
#- Necessary previous codes: hd_create_base_dataset & hd_import_SCR
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
library(readxl)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check"
scr_path = "Z:/DATA/Dta_files/SCR_TERADATA"

init_time = Sys.time()
setwd(data_path)
#PIS x CPF data
pis_cpf = read_stata("hd_cpf_to_pis.dta")
#Main dataset (from RAIS)
rais = read_parquet("sample_complete_information.parquet")

#We have two scr files, one with all kinds of debts and the other only with
#loans and financing. 
#So we create a function to work in both of these datasets
clean_scr = function(df){
  #retrieve pis information
  df = df %>% 
    left_join(pis_cpf, by = "pis", na_matches = "never") %>% 
    select(!cpf)
  
  #take data only in December
  df = df %>% 
    mutate(ano = substr(time_id, 1, 4),
           mes = substr(time_id), nchar(time_id)-1, nchar(time_id)) %>% 
    mutate(across(c("ano", "mes"), as.integer)) %>% 
    filter(mes == 12) %>% 
    select(!c("mes", "time_id"))
  
  #Select only loan_outstanding
  df = df %>% 
    rename(loan_t = loan_outstanding) %>% 
    select(c(pis, ano, loan_t))
  
  return(df)
}

#Add all loans data to main dataset
scr_all = read_stata("hd_SCR_indivudal.dta")
scr_all = clean_scr(scr_all)
scr_all = scr_all %>% 
  rename(loan_all_t = loan_t)

rais = rais %>% 
  left_join(scr_all, by = c("pis", "ano"), na_matches = "never")
rm(scr_all)

#Add only loans and financing data to main dataset
scr_loans = read_stata("hd_SCR_indivudal_loans.dta")
scr_loans = clean_scr(scr_loans)

rais = rais %>% 
  left_join(scr_loans, by = c("pis", "ano"), na_matches = "never") %>% 
  #Deflate loans
  mutate(across(c("loan_t", "loan_all_t"), ~ . * deflator_2010_t))

rm(scr_loans, pis_cpf)
gc()

#Define debt level at baseline year c
rais = rais %>% 
  group_by(pis, baseline) %>% 
  mutate(loan_c = loan_t[ano == baseline],
         loan_all_c = loan_all_t[ano == baseline]) %>% 
  ungroup() %>% 
  mutate(debt_ratio_c = loan_c/real_wage_c,
         debt_ratio_all_c = loan_all_c/real_wage_c)

#Define deciles of debt level
#Take only one value per individual/baseline year
aux = rais %>% 
  select(pis, baseline, debt_ratio_c, debt_ratio_all_c) %>% 
  group_by(pis, baseline) %>% 
  summarise_all(first) %>% 
  ungroup() %>% 
  #define deciles of debt level
  mutate(decile_debt_c = cut_number(debt_ratio_c, 10, labels = FALSE),
         decile_debt_all_c = cut_number(debt_ratio_all_c, 10, labels = FALSE)) 

#Create a graph of debt levels
aux %>% 
  ggplot(aes(debt_ratio_c))+
  geom_histogram()+
  facet_wrap(~baseline)

setwd(output_path)
ggsave("debt_ratio_per_year.png", width = 8, height = 6)

#Drop columns to not create duplicates with main df
aux = aux %>% 
  select(!c(debt_ratio_c, debt_ratio_all_c))

#put this information back to the main dataset
rais = rais %>% 
  left_join(aux, by = c("pis", "baseline"), na_matches = "never")

#Save
setwd(data_path)
write_parquet(rais, "data_before_matching.parquet")
print(summary(rais))

final_time = Sys.time()
print(paste0("Time to run: ", 
             round(difftime(final_time, init_time, units = 'mins')), 
             ' mins'))
rm(list = ls())
gc()

