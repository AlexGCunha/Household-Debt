#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Combine datasets to construct sample of potential candidates to match,
# for each year
#- we must firs run hd_clean_rais_companies and hd_import_SCR
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

library(tidyverse)
library(arrow)
library(haven)
library(readxl)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"

#COMENTAR
# data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"

a = Sys.time()

#Parameters
initial_year = 2006
final_year = 2014
min_age = 23
max_age = 45
sex_choose = 1
min_years = 3
min_employees = 15
cutoff_mass_layoff = -0.33
cutoff_low_layoff = -0.1

###############################
#Base sample selection and variable construction
###############################
#Auxiliary loans df
loans = read_dta(paste0(data_path, "hd_SCR_indivudal_loans.dta"))
loans = loans %>% 
  mutate(year = substr(as.character(time_id), 1, 4),
         year = as.integer(year),
         cpf = as.numeric(cpf)) %>% 
  select(-c(time_id))

print(summary(loans))

#vectors to fill
ever_treated = c()
treated_multiple_times = c()

#Read data
for (y in initial_year:final_year){
  b = Sys.time()
  rais = read_parquet(paste0(data_path, "rais_clean_", y, ".parquet"))
  
  #Some columns were saved as factor, convert to integer
  factor_cols = colnames(rais)[sapply(rais, is.factor)]
  
  rais = rais %>% 
    mutate(across(all_of(factor_cols), as.character),
           across(all_of(factor_cols), as.integer))
  
  #Working in december
  rais = rais %>% 
    filter(active == 1)
  
  #With only one job in the baseline year
  rais = rais %>% 
    add_count(cpf, name = "n_private_jobs") %>% 
    filter(n_private_jobs == 1) %>% 
    select(-c(n_private_jobs))
  
  #Full time private employees
  rais = rais %>% 
    filter(emp_type == 10, #private employee
           wk_hours >= 30, #minimum hours
           legal_nature > 2038) #non-public company
  
  #With minimum tenure
  rais = rais %>% 
    filter(emp_time >= min_years * 12)
  
  #add information on the firm level and filter by firm size
  firm_info = read_parquet(paste0(data_path, "emp_panel.parquet")) %>% 
    filter(year == y) %>% select(-c(year))
  
  rais = rais %>% 
    left_join(firm_info, by = c("cnpj_cei"), na_matches = "never") %>% 
    filter(n_employees >= min_employees)
  
  rm(firm_info)
  gc()
  
  #add lead information on the individual-firm level
  cpf_so_far = unique(rais$cpf)
  cnpj_so_far = unique(rais$cnpj_cei)
  filename = paste0(data_path, "rais_clean_", (y + 1), ".parquet")
  rais_lead = read_parquet(filename)
  
  rais_lead = rais_lead %>% 
    select(cpf, cnpj_cei, quit_reason, quit_month) %>% 
    rename(quit_reason_le1 = quit_reason,
           quit_month_le1 = quit_month) %>% 
    filter(cpf %in% cpf_so_far,
           cnpj_cei %in% cnpj_so_far)
  
  rais = rais %>% 
    left_join(rais_lead, by = c("cpf", "cnpj_cei"), na_matches = "never")
  
  rm(rais_lead, cpf_so_far, cnpj_so_far)
  gc()
  
  #add lag information on the individual-firm level
  cpf_so_far = unique(rais$cpf)
  cnpj_so_far = unique(rais$cnpj_cei)
  for(sub_y in (y-1):(y-3)){
    ano_relativo = y - sub_y
    filename = paste0(data_path, "rais_clean_", sub_y, ".parquet")
    aux = read_parquet(filename) %>% 
      filter(cpf %in% cpf_so_far,
             cnpj_cei %in% cnpj_so_far,
             active == 1)
    
    #define individuals found
    found = unique(aux[, c('cpf', 'cnpj_cei')]) %>% 
      mutate(encontrado = 1)
    
    #suffix to indicate years of lag
    suffix_aux = paste0('_la', ano_relativo)
    rais = rais %>% 
      left_join(found, by = c("cpf", "cnpj_cei"), na_matches = 'never', 
                suffix = c('', suffix_aux))
    
    rm(filename, ano_relativo, aux, found)
    
  }
  
  
  ##COMENTAR!!!!!!
  # rais = rais %>%
  #   mutate(across(c("encontrado", "encontrado_la2", "encontrado_la3"),
  #                 ~ 1))
  
  #drop individuals that, even though were supposedly working for 3 eyars,
  #had not appeared in rais in the previous 3 years
  rais = rais %>% 
    filter(!is.na(encontrado), !is.na(encontrado_la2), !is.na(encontrado_la3)) %>% 
    select(-c("encontrado", "encontrado_la2", "encontrado_la3"))
  
  #add debt level
  rais = rais %>% 
    left_join(loans, by = c('cpf', 'year'), na_matches = 'never')
  
  #define treated and potential control
  rais = rais %>% 
    mutate(
      treated = case_when(
        #were displaced withou a cause in a mass layoff-firm
        quit_reason_le1 == 11 & var_emp_le1 <= cutoff_mass_layoff ~ 1,
        T ~ 0),
      pot_control = case_when(
        quit_reason_le1 == 0 & var_emp_le1 >= cutoff_low_layoff ~ 1,
        T ~ 0))
  
  rais = rais %>% 
    filter(treated == 1 | pot_control == 1)
  
  #If individuals are appearing more than once (due to multiple entries)
  #in the same firm in the year, drop then
  rais = rais %>% 
    add_count(cpf, name = "n_appear") %>% 
    filter(n_appear == 1) %>% 
    select(-c(n_appear))
  
  #update ever treated and treated multiple times vectors
  new_treated = rais %>% 
    filter(treated ==1) %>% select(cpf) %>% pull() %>% unique()
  treated_again = new_treated[new_treated %in% ever_treated]
  treated_multiple_times = unique(c(treated_again, treated_multiple_times))
  ever_treated = unique(c(new_treated, ever_treated))
  rm(treated_again, new_treated)
  
  ##Additional variable creation
  rais = rais %>% 
    mutate(
      #quartile of firm size (n employees)
      quartile_size = cut_number(n_employees, 4),
      #debt ratio and decile debt ratio
      debt_ratio = loan_outstanding/(12*real_earnings),
      decile_debt = cut_number(debt_ratio, 10))
  
  #Skill level
  rais = rais %>% 
    #1 is less than high school
    #2 is complete high school or some college
    #3 is complete college or more
    mutate(skill_b = case_when(
      educ < 7 ~ 1,
      educ %in% c(7,8) ~ 2,
      educ %in% c(9, 10, 11) ~ 3,
      T ~ NA))
  
  #Geographical State
  rais = rais %>% 
    mutate(uf = substr(as.numeric(munic), 1, 2))
  
  #recession years
  years_recession = c(1995, 1998, 2001, 2003, 2014, 2015, 2016, 2020)
  rais = rais %>% 
    mutate(recession = ifelse(year %in% years_recession, 1, 0),
           recession_le1 = ifelse((year + 1) %in% years_recession, 1, 0))
  
  #Years of employment
  rais = rais %>% 
    mutate(tenure = round(emp_time/12))
  
  #drop individuals withou cnae and debt ratio
  rais = rais %>% 
    mutate(cnae1 = substr(as.character(cnae_95), 1,1)) %>% 
    filter(!is.na(cnae1), !is.na(debt_ratio), !is.na(skill_b))
  
  #Save
  filename = paste0(data_path, "potential_sample_", y, '.parquet')
  write_parquet(rais, filename)
  
  if(y == final_year) print(summary(rais))
  
  rm(rais)
  gc()
  c = Sys.time()
  message = paste0("Time to create potential sample for ", y, ": ",
                   round(difftime(c, b, units = 'mins')), ' minutes')
  print(message)
  
}

#save treated and treated multiple times vectors
write_rds(treated_multiple_times, paste0(data_path, "treated_multiple_times.rds"))
write_rds(ever_treated, paste0(data_path, 'ever_treated.rds'))

c = Sys.time()
message = paste0("Time to create all potential  ",
                 round(difftime(c, a, units = 'hours'), 1), ' hours')
print(message)


