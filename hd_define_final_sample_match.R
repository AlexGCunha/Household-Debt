#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- From the potential sample from code 'hd_define_potential_sample', run
# additional filterings;
#- Match treated x control individuals. And then treated x treated
#- Run after hd_define_potential_sample
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
library(data.table)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"

#COMENTAR
data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"

a = Sys.time()

#Parameters
initial_year = 2006
final_year = 2014

treated_multiple_times_aux = read_rds(paste0(data_path, "treated_multiple_times.rds"))
ever_treated_aux = read_rds(paste0(data_path, 'ever_treated.rds'))

#Loop to match for every year
for(y in initial_year:final_year){
  b = Sys.time()
  filename = paste0(data_path, "potential_sample_", y, ".parquet")
  df = read_parquet(filename)
  
  #define high and low debt level as above/below median
  q50_debt = quantile(df$debt_ratio, 0.5)
  
  df = df %>% 
    mutate(high_debt = case_when(debt_ratio >= q50_debt ~ 1,
                                 debt_ratio < q50_debt ~ 0,
                                 T ~ NA))
  rm(q50_debt)
  
  #add ever treated and treated multiple times info
  df = df %>% 
    mutate(ever_treated = ifelse(cpf %in% ever_treated_aux, 1, 0),
           treated_multiple_times = ifelse(cpf %in% treated_multiple_times_aux, 
                                           1, 0))
  
  #Drop individuals treated multiple times and dont allow ever treated as control
  df = df %>% 
    mutate(drop1 = ifelse(pot_control == 1 & ever_treated == 1, 1, 0),
           drop2 = ifelse(treated_multiple_times == 1, 1, 0)) %>% 
    filter(drop1 == 0, drop2 == 0) %>% 
    select(-c(drop1, drop2, ever_treated, treated_multiple_times))
  
  #Guarantee there are no NAs on the matching variables and cpf
  df = df %>% 
    filter(!is.na(cpf) & !is.na(age) & !is.na(tenure) & !is.na(cnae1)
           & !is.na(n_employees) & !is.na(high_debt) 
           & !is.na(real_earnings) & !is.na(sex))
  
  #additional variable creation
  quants_employees = quantile(df$n_employees, c(0.25, 0.5, 0.75))
  df = df %>% 
    mutate(real_earnings_bins = cut_width(real_earnings, 250),
           n_employees_quants = fcase(
             n_employees <= quants_employees[1], 1,
             n_employees > quants_employees[1] & n_employees <= quants_employees[2], 2,
             n_employees > quants_employees[2] & n_employees <= quants_employees[3], 2,
             default = 4))
  
  
  #----------------------------------
  #First Match: Treated x Control
  #----------------------------------
  df_match = copy(df) %>% data.table()
  
  treated_workers = df_match[treated == 1, 
                              .(cpf, age, uf,tenure, cnae1, n_employees_quants,
                                high_debt, real_earnings_bins, sex)]
  setnames(treated_workers, old = "cpf", new = "cpf_treated")
  
  control_workers = df_match[treated == 0, 
                              .(cpf, age, uf,tenure, cnae1, n_employees_quants,
                                high_debt, real_earnings_bins, sex)]
  setnames(control_workers, old = "cpf", new = "cpf_control")
  
  
  matched_workers = merge(treated_workers, control_workers, 
                          by = c('high_debt', 
                                 'n_employees_quants', 'real_earnings_bins',
                                 "age", "uf", "tenure", "cnae1", "sex"),
                          all.x = TRUE, allow.cartesian = TRUE)
  
  #drop unmatched workers
  matched_workers = matched_workers[!is.na(cpf_control)]
  
  #Create an indicator for the group and order of appearance within group
  matched_workers[, order_treated := seq_len(.N), by = .(cpf_treated)]
  matched_workers[, order_control := seq_len(.N), by = .(cpf_control)]
  
  #keep when the values are equal. This will give the exact match we want, preserving
  #the maximum number of matches without replacement
  matched_workers = matched_workers[order_treated == order_control]
  
  #keep just the info we want
  matched_workers = matched_workers[, .(cpf_control, cpf_treated)]
  matched_workers = matched_workers %>% rownames_to_column(var = "first_match_id")
  matched_workers = matched_workers %>% 
    pivot_longer(cols = c("cpf_treated", "cpf_control"),
                                                     values_to = "cpf") %>% 
    select(-c(name))
  
  #updates main df
  df = df %>% 
    left_join(matched_workers, by = c('cpf'), na_matches = 'never') %>% 
    filter(!is.na(first_match_id))
  
  rm(matched_workers,control_workers, treated_workers, df_match)
  
  #----------------------------------
  #Second Match: Treated High Debt x Treated Low Debt
  #----------------------------------
  df_match = copy(df) %>% 
    filter(treated == 1,
           !is.na(high_debt)) %>% 
    data.table()
  
  treated_workers = df_match[high_debt == 1, 
                             .(cpf, age, uf,tenure, cnae1, n_employees_quants,
                               real_earnings_bins, sex)]
  setnames(treated_workers, old = "cpf", new = "cpf_treated")
  
  control_workers = df_match[high_debt == 0, 
                             .(cpf, age, uf,tenure, cnae1, n_employees_quants,
                               real_earnings_bins, sex)]
  setnames(control_workers, old = "cpf", new = "cpf_control")
  
  
  matched_workers = merge(treated_workers, control_workers, 
                          by = c('n_employees_quants', 'real_earnings_bins',
                                 "age", "uf", "tenure", "cnae1", "sex"),
                          all.x = TRUE, allow.cartesian = TRUE)
  
  #drop unmatched workers
  matched_workers = matched_workers[!is.na(cpf_control)]
  
  #Create an indicator for the group and order of appearance within group
  matched_workers[, order_treated := seq_len(.N), by = .(cpf_treated)]
  matched_workers[, order_control := seq_len(.N), by = .(cpf_control)]
  
  #keep when the values are equal. This will give the exact match we want, preserving
  #the maximum number of matches without replacement
  matched_workers = matched_workers[order_treated == order_control]
  
  #keep just the info we want
  matched_workers = matched_workers[, .(cpf_control, cpf_treated)]
  matched_workers = matched_workers %>% rownames_to_column(var = "second_match_id")
  matched_workers = matched_workers %>% 
    pivot_longer(cols = c("cpf_treated", "cpf_control"),
                 values_to = "cpf") %>% 
    select(-c(name))
  
  #updates main df
  df = df %>% 
    left_join(matched_workers, by = c('cpf'), na_matches = 'never')
  
  rm(matched_workers,control_workers, treated_workers, df_match)
  
  
  #----------------------------------
  #Additional modifications and save
  #----------------------------------
  #Print number of matched obs per year
  n_first_match = length(unique(df$cpf))/2
  n_second_match = df %>% filter(!is.na(second_match_id)) %>% 
    select(cpf) %>% unique() %>% nrow()/2
  message = paste0("Number of matches in ", y, ": ", 
                   "first_match: ", n_first_match, 
                   "; second_match: ", n_second_match)
  print(message)
  
  #Select columns to keep
  df = df %>% 
    select(cpf, year, treated, first_match_id, second_match_id, high_debt, cbo_02,
           cnpj_cei, cnpj, real_earnings, debt_ratio, skill_b, uf, age, sex,
           n_employees,munic, quit_month_le1)
  
  #Add "_b" suffix to indicate that the variable is at the baseline year
  df = df %>% 
    rename(high_debt_b = high_debt,
           cbo_02_b = cbo_02,
           cnpj_cei_b = cnpj_cei,
           cnpj_b = cnpj,
           sex_b = sex,
           debt_ratio_b = debt_ratio,
           real_earnings_b = real_earnings,
           uf_b = uf, 
           baseline = year, 
           age_b = age, 
           n_employees_b = n_employees,
           munic_b = munic)
  
  #save
  filename = paste0(data_path, "matched_sample_", y, ".parquet")
  write_parquet(df, filename)
  
  if(y == final_year | y == initial_year) print(summary(df))
  
  c = Sys.time()
  message = paste0(round(difftime(c, b, units = 'mins'), 1), 
                    " mins to create ", y, " matched sample")
  print(message)
  
  rm(df, filename, message, b, c)
  
}

c = Sys.time()
message = paste0(round(difftime(c, a, units = 'hours'), 1), 
                 " hours to create all matched samples")
print(message)
rm(list = ls())
gc()
