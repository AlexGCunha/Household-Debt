#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- From the potential sample from code 'hd_define_potential_sample', run
# additional filterings;
#- Match treated x control individuals. And then treated x treated
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
if (!require("MatchIt")) install.packages("splitstackshape", repos = repository)

library(tidyverse)
library(arrow)
library(MatchIt)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"

#COMENTAR
# data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"

a = Sys.time()

#Parameters
initial_year = 2006
final_year = 2014

treated_multiple_times_aux = read_rds(paste0(data_path, "treated_multiple_times.rds"))
ever_treated_aux = read_rds(paste0(data_path, 'ever_treated.rds'))

#auxiliary function to retrieve matched pairs after matching procedure
retrieve_pairs = function(df, model){
  #create matching matrix, with info about matching pairs
  match_matrix = as.data.frame(model$match.matrix)
  match_matrix = match_matrix %>% 
    rownames_to_column() %>% 
    rename(paired_treated = rowname,
           paired_control = V1) %>% 
    #Add a label to this pair of matches
    mutate(match_id = seq(1:nrow(match_matrix))) %>% 
    #drop non-matched individuals
    filter(!is.na(paired_control))
  
  #Add matching information back to matching dataset
  df = df %>% 
    left_join(match_matrix %>% select(!paired_control),
              join_by(rowname==paired_treated),
              na_matches = 'never') %>% 
    left_join(match_matrix %>% select(!paired_treated),
              join_by(rowname == paired_control),
              na_matches = 'never') %>% 
    mutate(match_id = ifelse(is.na(match_id.x), match_id.y, match_id.x)) %>% 
    select(cpf, match_id)
  
  return(df)
}


#Loop to match for every year
for(y in initial_year:final_year){
  b = Sys.time()
  filename = paste0(data_path, "potential_sample_", y, ".parquet")
  df = read_parquet(filename)
  
  #define high and low debt level as top and low 25% of debt ratio
  q25_debt = quantile(df$debt_ratio, 0.25)
  q75_debt = quantile(df$debt_ratio, 0.75)
  
  df = df %>% 
    mutate(high_debt = case_when(debt_ratio >= q75_debt ~ 1,
                                 debt_ratio <= q25_debt ~ 0,
                                 T ~ NA))
  rm(q25_debt, q75_debt)
  
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
  
  #----------------------------------
  #First Match: Treated x Control
  #----------------------------------
  df_match = df %>% rownames_to_column()
  
  #Exact Matching
  m1 = matchit(treated ~ debt_ratio + real_earnings + n_employees + factor(age) + 
                 factor(uf)  + factor(tenure) + factor(cnae1),
               method = "cem",
               cutpoints = list(real_earnings = seq(0, max(df_match$real_earnings), 250),
                                n_employees = "q4",
                                debt_ratio = "q10"),
               data = df_match,
               k2k = TRUE) # for 1:1 matching
  
  match_pairs = retrieve_pairs(df_match, m1) %>% 
    rename(first_match_id = match_id)
  
  #update main df
  df = df %>% 
    left_join(match_pairs, by = c('cpf'), na_matches = 'never') %>% 
    filter(!is.na(first_match_id))
  
  rm(m1, match_pairs, df_match)
  
  #----------------------------------
  #Second Match: Treated High Debt x Treated Low Debt
  #----------------------------------
  df_match = df %>% 
    filter(treated == 1,
           !is.na(high_debt)) %>% 
    rownames_to_column()
  
  m2 = matchit(high_debt ~ real_earnings + n_employees + factor(age) + 
                 factor(uf) + factor(tenure) + factor(cnae1),
               method = "cem",
               cutpoints = list(real_earnings = seq(0, 
                                                    max(df_match$real_earnings), 
                                                    250),
                                n_employees = "q4"),
               data = df_match,
               k2k = TRUE) #for 1:1 matching
  
  match_pairs = retrieve_pairs(df_match, m2) %>% 
    rename(second_match_id = match_id)
  
  df = df %>% 
    left_join(match_pairs, by = "cpf", na_matches = "never")
  
  rm(match_pairs, m2, df_match)
  
  #Select columns to keep
  df = df %>% 
    select(cpf, year, treated, first_match_id, second_match_id, high_debt, cbo_02,
           cnpj_cei, cnpj, real_earnings, debt_ratio, skill_b, uf, age, 
           n_employees,munic, quit_month_le1)
  
  #Add "_b" suffix to indicate that the variable is at the baseline year
  df = df %>% 
    rename(high_debt_b = high_debt,
           cbo_02_b = cbo_02,
           cnpj_cei_b = cnpj_cei,
           cnpj_b = cnpj,
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
