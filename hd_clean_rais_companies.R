#-------------------------------------------------------------------------------
#This code will:
#- Create a panel of employment per firm per year
#- Define if a company had a mass layoff or not
#- we must first run hd_compat_rais_v2
#-------------------------------------------------------------------------------

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

library(tidyverse)
library(arrow)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"

#Parameters
initial_year = 2003
final_year = 2019

#COMENTAR
# data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"

a = Sys.time()
rais_agg = tibble()
for(y in initial_year:final_year){
  rais = read_parquet(paste0(data_path, "rais_clean_",y,".parquet"))
  
  #Full time private employees
  rais = rais %>% 
    filter(active == 1, # worked in december
           emp_type == 10, #private employee
           wk_hours >= 30, #minimum hours
           legal_nature > 2038) #non-public company
  
  #aggregate by company
  rais = rais %>% 
    count(cnpj_cei, name = "n_employees") %>% 
    mutate(year = y)
  
  rais_agg = rbind(rais_agg, rais)
  rm(rais)
}


#Create a balanced panel of employment per firm
unique_cnpj = unique(rais_agg$cnpj_cei)

firms_panel = expand_grid(cnpj_cei = unique_cnpj,
                          year = c(initial_year:final_year))

firms_panel = firms_panel %>% 
  left_join(rais_agg, by = c("cnpj_cei", "year"), na_matches = "never")

rm(rais_agg)

#sort by firm and year
firms_panel = firms_panel %>% 
  arrange(cnpj_cei, year)

#0 employees for years without info (either closed ot not yet open)
firms_panel = firms_panel %>% 
  mutate(n_employees = ifelse(is.na(n_employees), 0, n_employees))

#add lead information of #employees
firms_panel_lead = firms_panel %>% 
  mutate(year = year - 1) %>% 
  rename(n_employees_le1 = n_employees)

firms_panel = firms_panel %>% 
  left_join(firms_panel_lead, by = c("year", "cnpj_cei"), na_matches = "never")

rm(firms_panel_lead)

#Drop last year(since we dont have info for the subsequent year)
firms_panel = firms_panel %>% 
  filter(year < final_year)

#define lead layoff share
firms_panel = firms_panel %>% 
  mutate(var_emp_le1 = n_employees_le1/n_employees -1)

firms_panel = firms_panel %>% 
  mutate(var_emp_le1 = ifelse(var_emp_le1 == Inf, NA, var_emp_le1))

#Save
write_parquet(firms_panel, paste0(data_path, "emp_panel.parquet"))

b = Sys.time()
message = paste0("Time to create firms panel: ",
                 round(difftime(b, a, units = 'hours'), 1), ' hours')

print(message)
print(summary(firms_panel))
rm(list = ls())
gc()
