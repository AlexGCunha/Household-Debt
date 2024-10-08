#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Open rais files and filter individuals with characteristics we want
#- Create and adapt variable to match
#- Match
#- Data that will be used was generated by hd_compat_rais_env.R and..
#- .. hd_aggregate_rais_firms.R
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
if (!require("MatchIt")) install.packages("MatchIt")

library(tidyverse)
library(readxl)
library(haven)
library(arrow)
library(MatchIt)

setwd("Z:/Bernardus/Cunha_Santos_Doornik")
a = Sys.time()
#Parameters
min_age = 24
max_age = 50
initial_year = 1998
final_year = 2016
years_prior = 3
years_advance = 5
min_years = 3
min_employees = 30
percentage_base = 15

######################################
#Auxiliary dataframes
######################################
#Read minimum wages and deflator data, to be used later
df_br = read_excel("Dta_files/series_nacionais.xlsx", sheet = 'anual')

#Read enforcement data and define enforcement levels, to be used later
df_enf = read_parquet("Dta_files/Distances_munic.parquet") %>% 
  rename(munic_t = munic) %>% 
  mutate(munic_t = substr(as.character(munic_t), 1, 6)) %>% 
  select(munic_t, dist_min) %>% 
  mutate_all(as.integer)

mid_enf = quantile(df_enf$dist_min, 0.5, na.rm = T)
print(paste0('Median Distance, that defines enforcement, is ', mid_enf, ' km'))

df_enf = df_enf %>% 
  mutate(high_enf = ifelse(dist_min <= mid_enf, 1,0),
         low_enf = 1 - high_enf,
         dist_min = dist_min/100)

#Create a list of control and treated individuals to be updated recursively
#in the matching part (to avoid repeating individuals)
control = c()
treated = c()
treated_multiple_times = c()

#Pis to cpf information
pis_cpf = read_stata("Dta_files/hd_cpf_to_pis.dta")

######################################
#SCR data
######################################
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
           mes = substr(time_id, nchar(time_id) - 1, nchar(time_id))) %>% 
    mutate(across(c("ano", "mes"), as.integer)) %>% 
    filter(mes == 12) %>% 
    select(!c("mes", "time_id"))
  
  #Select only loan_outstanding
  df = df %>% 
    rename(loan_t = loan_outstanding) %>% 
    select(c(pis, ano, loan_t))
  
  #Deflate
  df = df %>% 
    left_join(df_br %>% select(ano, deflator_2010_t),
              by = 'ano', na_matches = 'never') %>% 
    mutate(loan_t = loan_t*deflator_2010_t) %>% 
    select(c(pis, ano, loan_t))
  
  return(df)
}

#Read and correct data on all loans
scr_all = read_stata("Dta_files/hd_SCR_indivudal.dta")
scr_all = clean_scr(scr_all)
scr_all = scr_all %>% 
  rename(loan_all_t = loan_t)

#Read and correct data on loans and financing
scr_loans = read_stata("Dta_files/hd_SCR_indivudal_loans.dta")
scr_loans = clean_scr(scr_loans)

print(summary(scr_all))
print(summary(scr_loans))

######################################
#Loop to create a base for each year
######################################
for( y in initial_year:final_year){
  b = Sys.time()
  filename = paste0('Dta_files/RAIS_comp_filt_', y, '.parquet')
  rais = read_parquet(filename)
  
  #Get pis information for 2010:
  if(y == 2010){
    rais = rais %>% 
      left_join(pis_cpf %>% rename(pis_aux = pis),
                by = "cpf", na_matches = 'never') %>% 
      mutate(pis = ifelse(is.na(pis), pis_aux, pis)) %>% 
      select(!pis_aux)
  }
  
  #Get a list of pis with characteristics we want
  pis_keep = rais %>% 
    select(pis, emp_time_t) %>% 
    #Who had at most one job in that year
    group_by(pis) %>% 
    mutate(n_emp_t = n()) %>% 
    ungroup() %>% 
    filter(n_emp_t ==1) %>% 
    #Who were working for our minimum number of years
    filter(emp_time_t >= 12 * min_years) %>% 
    #Our sample of Pis
    mutate(nchar_pis = nchar(as.character(pis)),
           last_char_pis = substr(as.character(pis), nchar_pis - 1, nchar_pis),
           last_char_pis = as.integer(last_char_pis)) %>% 
    filter(last_char_pis <= percentage_base) %>% 
    select(pis) %>% 
    pull() %>% 
    unique()
  
  #Get information of # of employees on the firm, per year
  df_firm = read_parquet('Dta_files/firm_employment_panel.parquet') %>% 
    select(cnpj, ano, demissao_massa)
  
  colnames(df_firm) = c('cnpj_t', 'ano', 'n_employees_t', 'mass_layoff_firm_t')
  
  df_firm_baseline = df_firm %>% 
    select(cnpj_t, ano, mass_layoff_t) %>% 
    rename(cnpj_b = cnpj_t,
           mass_layoff_base_t = mass_layoff_t)
  
  df_firm = df_firm %>% 
    select(cnpj_t, ano, n_employees_t)
  
  #Decrease the sizes of df_firm and df_plant by choosing firms that our
  #sample worked
  cnpj_keep = rais %>% 
    filter(pis %in% pis_keep) %>% 
    select(cnpj_t) %>% 
    unique() %>% 
    pull()
  
  df_firm = df_firm %>% 
    filter(cnpj_t %in% cnpj_keep)
  
  rm(cnpj_keep)
  gc()
  
  ######################################
  #In this part I will recover lagged and lead information for each individual
  #in order to match
  ######################################
  df = expand.grid(pis = pis_keep,
                   ano = c(max((y-years_prior), 1995)
                           :min((y+years_advance), 2017)))
  
  sub_rais = tibble()
  for (sub_y in max((y - years_prior), 1995):min((y+years_advance), 2017)){
    filename = paste0('Dta_files/RAIS_comp_filt_', sub_y, '.parquet')
    aux = read_parquet(filename) %>% 
      filter(pis %in% pis_keep)
    sub_rais = rbind(sub_rais, aux)
    rm(aux)
    
    #Guarantee that each individual had at most one job per year
    sub_rais = sub_rais %>% 
      group_by(pis, ano) %>% 
      mutate(n_jobs = n()) %>% 
      ungroup() %>% 
      group_by(pis) %>% 
      mutate(ever_had_more_than_one_job = ifelse(max(n_jobs) > 1, 1,0)) %>% 
      ungroup() %>% 
      filter(ever_had_more_than_one_job == 0) %>% 
      select(!c(n_jobs, ever_had_more_than_one_job))
    
  }
  
  #Join to get information on all years
  df = df %>% 
    left_join(sub_rais, by = c('pis', 'ano', na_matches = 'never')) %>% 
    arrange(pis, ano) %>% 
    mutate(baseline = y) %>% 
    select(pis, ano, baseline, everything())
  
  rm(rais, sub_rais)
  gc()
  
  #Drop individuals who dont have wage information for the baseline year 
  #and 3 years prior to layoff
  pis_complete = df %>% 
    filter(ano <= y,
           !is.na(wage_dec_sm_t)) %>% 
    group_by(pis) %>% 
    summarise(count = n()) %>% 
    ungroup() %>% 
    filter(count == years_prior + 1) %>% 
    select(pis) %>% 
    unique() %>% 
    pull()
  
  df = df %>% 
    filter(pis %in% pis_complete)
  
  #Define if lost job in a mass layoff between baseline year and the next one
  #first, define if lost job
  df = df %>% 
    arrange(pis, ano) %>% 
    group_by(pis) %>% 
    mutate(lost_job_t = case_when(
      is.na(cnpj_t) | cnpj_t != lag(cnpj_t, n = 1L) ~ 1,
      TRUE ~ 0)) %>% 
    #firm id on the baseline year
    mutate(cnpj_b = cnpj_t[ano == baseline]) %>% 
    ungroup()
  
  #Second, inpute mass layoff and employment information, filter by company size
  df = df %>% 
    left_join(df_firm_baseline, 
              by = c('cnpj_b', 'ano'), na_matches = 'never') %>% 
    left_join(df_firm, by = c('cnpj_t', 'ano'), na_matches = 'never') %>%
    group_by(pis) %>% 
    filter(n_employees_t[ano == baseline] >= min_employees) %>% 
    ungroup()
  
  #Third, define is  a person worked in the same company in the next 3 years
  df = df %>% 
    group_by(pis) %>% 
    mutate(same_company_3y_t = case_when(
      cnpj_b == lead(cnpj_t, n = 1L) |
        cnpj_b == lead(cnpj_t, n = 2L) |
        cnpj_b == lead(cnpj_t, n = 3L) ~ 1,
      T ~ 0)) %>% 
    ungroup()
  
  #Finally, define if lost job in a mass layoff
  df = df %>% 
    group_by(pis) %>% 
    mutate(lost_job_mass_layoff_b1 = case_when(
      lost_job_t[ano == baseline + 1] == 1 &
        mass_layoff_base_t[ano == baseline + 1] == 1 &
        same_company_3y_t[ano == baseline] == 0 ~ 1,
      T ~ 0)) %>%
    mutate(lost_job_t1 = lead(lost_job_t, n = 1L)) %>% 
    ungroup()
  
  #Convert wages to real wages
  df = df %>% 
    left_join(df_br, by = 'ano', na_matches = 'never') %>% 
    mutate(real_wage_t = wage_dec_sm * salario_minimo_t * deflator_2010_t,
           real_wage_t = ifelse(is.na(real_wage_t), 0, real_wage_t),
           ln_real_wage_t = log(1+real_wage_t))
  
  #Add wage bins (for every 250 reais)
  df = df %>% 
    mutate(wage_bin_t = cut_width(real_wage_t, 250))
  
  #Add lagged wages
  df = df %>% 
    group_by(pis) %>% 
    mutate(real_wage_tm1 = lag(real_wage_t, n = 1L),
           real_wage_tm2 = lag(real_wage_t, n = 2L),
           wage_bin_tm1 = lag(wage_bin, n = 1L),
           wage_bin_tm2 = lag(wage_bin, n = 2L)) %>% 
    ungroup()
  
  #Create debt ratio metric
  df = df %>% 
    mutate(
      debt_ratio_t = loan_t/real_wage_t,
      debt_ratio_all_t = loan_all_t/real_wage_t
    )
  
  #Decile debt ratio for that baseline year
  aux_debt = df %>% 
    filter(ano == baseline) %>% 
    mutate(decile_debt_b = cut_number(debt_ratio_t, 10, labels = F),
           decile_debt_all_b = cut_number(debt_ratio_all_b, 10, labels = F)) %>% 
    select(pis, decile_debt_b, decile_debt_all_b)
  
  df = df %>% 
    left_join(aux_debt, by = 'pis', na_matches = 'never')
  
  rm(aux_debt)
  
  #Add enforcement data
  df = df %>% 
    left_join(df_enf, by = 'munic_t', na_matches = 'never')
  
  #Create 1 and 2-digit cnae metric
  df = df %>% 
    mutate(cnae1_t = substr(as.character(cnae_95_t), 1, 1),
           cnae2_t = substr(as.character(cnae_95_t), 1, 2)) %>% 
    mutate(across(c(cnae1_t, cnae2_t), as.integer))
  
  df = df %>% 
    group_by(pis) %>% 
    #1 is less then high scholl
    #2 is completed high school or some college
    #3 is completed college or more
    mutate(skill = case_when(
      is.na(educ_col) & is.na(educ_hs) & is.na(educ_fund) ~ NA_integer_,
      educ_col == 1 ~ 3,
      educ_col == 0 & educ_hs == 1 ~ 2,
      T ~ 1
    )) %>% 
    ungroup()
  
  #Some individuals were working but appear with 0 wage. Drop these individuals
  df = df %>% 
    mutate(error = ifelse(!is.na(cnpj_t) & real_wage_t == 0, 1, 0)) %>% 
    group_by(pis) %>% 
    mutate(error_any_year = max(error)) %>% 
    ungroup() %>% 
    filter(error_any_year == 0) %>% 
    select(!c(error, error_any_year))
  
  ######################################
  #First Match
  ######################################
  df_match = df %>% 
    filter(ano == baseline)
  
  #Update list of individuals who were treated multiple times
  treated_again = df_match %>% 
    filter(lost_job_mass_layoff_b1 == 1) %>% 
    select(pis) %>% 
    filter(pis %in% treated) %>% 
    unique() %>% 
    pull()
  
  treated_multiple_times = unique(c(treated_multiple_times, treated_again))
  
  #Filter individuals who were already used as control or were treated in 
  #previous years
  df_match = df_match %>%
    filter(!(pis %in% control)) %>% 
    filter(!(pis %in% treated))
  
  #Filter individuals with full information on debt level and cnae
  #(for exact matching)
  df_match = df_match %>% 
    filter(!is.na(cnae1_t) & !is.na(debt_ratio_t))
  
  #Filter individuals who either lost job in a mass layoff or did not lose job
  df_match = df_match %>% 
    filter(lost_job_mass_layoff_b1 == 1 | lost_job_b1 == 0)
  
  m1 = matchit(lost_job_mass_layoff_b1 ~ n_employees_t + 
                 real_wage_tm1 + real_wage_tm2 + factor(skill) +
                 emp_time_t + age_t,
               data = df_match,
               exact = c('decile_debt_b', 'cnae1_t'),
               method = 'nearest',
               distance = 'glm')
  
  #Indices for the match are given by rownumber, so lets add that 
  df_match = df_match %>% 
    rownames_to_column()
  
  #Create matching matrix, with info about matching pairs
  match_matrix = as_tibble(m1$match_matrix)
  match_matrix = match_matrix %>% 
    rownames_to_column() %>% 
    rename(paired_treated = rowname,
           paired_control = V1) %>% 
    #Add a label to this pair of matches
    mutate(match_t = seq(1:nrow(match_matrix))) %>% 
    #drop non matched individuals
    filter(!is.na(paired_control))
  
  #add matching information back to main dataset
  df_match = df_match %>% 
    left_join(match_matrix %>% select(!paired_control),
              join_by(rowname == paired_treated),
              na_matches = 'never') %>% 
    left_join(match_matrix %>% select(!paired_treated),
              join_by(rowname == paired_control),
              na_matches = 'never') %>% 
    mutate(match_t = ifelse(is.na(match_t.x), match_t.y, match_t.x)) %>% 
    select(!c(match_t.x, match_t.y, rowname))
  
  #Update list of control and treated individuals
  new_treated = df_match %>% 
    filter(!is.na(match_t), lost_job_t1 == 1) %>% 
    select(pis) %>% 
    unique() %>% 
    pull()
  
  new_control = df_match %>% 
    filter(!is.na(match_t), lost_job_t1 == 0) %>% 
    select(pis) %>% 
    unique() %>% 
    pull()
  
  treated = unique(c(treated, new_treated))
  control = unique(c(control, new_control))
  
  #Add matching information back to main dataset
  df_match = df_match %>% 
    select(pis, match_t)
  
  df = df %>% 
    left_join(df_match, by = 'pis', na_matches = 'never')
  
  #Save
  filename = paste0('Dta_files/first_match_', y, '.parquet')
  write_parquet(df, filename)
  c = Sys.time()
  message = paste0('Time to create ', y, ' dataset and match',
                   round(difftime(c, b, units = 'mins')), ' minutes')
  print(message)
  
  gc()
}

c = Sys.time()
message = paste0('Time to create matching datasets: ',
                 round(difftime(c, a, units = 'hours'), 1), ' hours')
print(message)

#Remove no longer necessary datasets
rm(df, df_match, rais, m1, df_br, df_firm, df_firm_baseline, match_matrix,
   df_enf)

gc()


######################################
#Create an aggregate dataset
######################################

rais_agg = tibble()
#Create aggregate dataset for matched individuals
for (y in initial_year:final_year){
  filename = paste0('Dta_files/first_match_', y, '.parquet')
  rais_y = read_parquet(filename) %>% 
    filter(!is.na(match_t))
  
  rais_agg = rbind(rais_agg, rais_y)
}

rm(rais_y)
gc()

#Create a unique identifier for each grouped pair
rais_agg = rais_agg %>% 
  group_by(match_t, baseline) %>% 
  mutate(first_match_id = cur_group_id()) %>% 
  ungroup() %>% 
  select(!match_t)

#Drop individuals that were treated multiple times and their counterparts
rais_agg = rais_agg %>% 
  mutate(indicator_mult = ifelse(pis %in% treated_multiple_times,1, 0)) %>% 
  group_by(first_match_id) %>% 
  mutate(indicator_mult_both = max(indicator_mult)) %>% 
  ungroup() %>% 
  filter(indicator_mult_both == 0) %>% 
  select(!c(indicator_mult, indicator_mult_both))

#Define debt ratio for each baseline year
rais_baseline = rais_agg %>%
  filter(ano == baseline & !is.na(debt_ratio_t)) %>% 
  group_by(ano) %>% 
  mutate(fourth_quartile_debt = quantile(debt_ratio_t, 0.75),
         second_quartile_debt = quantile(debt_ratio_t, 0.25),
         median_debt = quantile(debt_ratio_t, 0.5)) %>% 
  ungroup() %>% 
  mutate(high_debt_b = ifelse(debt_ratio_t >= median_debt, 1, 0)) %>% 
  select(pis, high_debt_b)

rais_agg = rais_agg %>% 
  left_join(rais_baseline, by = 'pis', na_matches = 'never')

print(summary(rais_agg))

#Save dataset until here as a checkpoint
write_parquet(rais_agg, "Dta_files/after_first_match_v2.parquet")

######################################
#Second Match
#- Match individuals who were fired and were with high debt ratio to another
# who was fired and had a low debt ratio
######################################
df_match = rais_agg %>% 
  filter(ano == baseline, 
         perdeu_emprego_demissao_massa_b1 == 1) %>% 
  rownames_to_column()

m2 = matchit(high_debt_b ~ n_employees_t + real_wage_tm1 +
               real_wage_tm2 + factor(skill)+ emp_time_t+ age_t,
             data = df_match, 
             exact = c('baseline'),
             distance = 'glm')

print(summary(m2))

#Work on match information to puth back in the dataset
match_matrix = as.tibble(m2$match_matrix)
match_matrix = match_matrix %>% 
  rownames_to_column() %>% 
  rename(paired_high = rowname,
         paired_low = V1) %>% 
  #add a label to this pair of matches
  mutate(match_debt = seq(1:nrow(match_matrix)))

#add pairs information into the dataset
#first, add pair information for highly indebted individuals
df_match = df_match %>% 
  left_join(match_matrix %>% select(!paired_low),
            join_by(rowname == paired_high),
            na_matches = 'never') %>% 
  #now for low debt ratio
  left_join(match_matrix %>% select(!paired_high),
            join_by(rowname == paired_low),
            na_matches = 'never') %>% 
  #we ended up creating two columns of match_debt, lets correct that
  mutate(match_debt = ifelse(is.na(match_debt.x), 
                             match_debt.y, match_debt.x)) %>% 
  select(!c(match_debt.x, match_debt.y, rowname))

rm(m2, match_matrix)

#Inpute this information back to the main dataset
df_match = df_match %>% 
  select(pis, baseline, match_debt)

rais_agg = rais_agg %>% 
  left_join(df_match, by = c('pis', 'baseline'), na_matches = 'never')

#Now, note that we've only created pair indexes for displaced individuals
#we must then use the same indexes for their non-displaced counterparts
rais_agg = rais_agg %>% 
  mutate(match_enf = ifelse(is.na(match_enf), -1, match_enf)) %>% 
  group_by(first_match_id) %>% 
  mutate(match_enf = max(match_enf)) %>% 
  ungroup() %>% 
  mutate(match_enf = ifelse(match_enf == -1, NA, match_enf)) %>% 
  mutate(match_enf = as.integer(match_enf)) %>% 
  rename(second_match_id = match_enf)

#Additional modifications
#Years relative to baseline
rais_agg = rais_agg %>% 
  mutate(year_relative_baseline = ano - baseline) %>% 
  #define post period (years after baseline)
  mutate(pos = ifelse(ano > baseline, 1, 0)) %>% 
  #Define if worked in a given year
  mutate(worked_t = ifelse(real_wage_t > 0, 1, 0))



#Recession years
recession_years = c(1995, 1998, 2001, 2003, 2014, 2015, 2016, 2020)
rais_agg = rais_agg %>% 
  mutate(recession_t = ifelse(baseline %in% recession_years, 1, 0),
         recession_b1 = ifelse((baseline + 1) %in% recession_years, 1, 0))

#Information on the baseline year
rais_agg = rais_agg %>% 
  group_by(pis) %>% 
  mutate(munic_b = munic_t[ano == baseline],
         skill = skill[ano == baseline],
         dist_min = dist_min[ano == baseline]) %>% 
  ungroup() %>% 
  select(!c(munic_t))

#Some individuals were working but appear with 0 wage. Drop these 
rais_agg = rais_agg %>% 
  mutate(error = ifelse(!is.na(cnpj_t) & real_wage_t == 0, 1, 0)) %>% 
  group_by(pis) %>% 
  mutate(error_any_year == max(error)) %>% 
  ungroup() %>% 
  filter(error_any_year == 0) %>% 
  select(!c(error, error_any_year))
  


#Save
write_parquet(rais_aff, 'Dta_files/main_dataset.parquet')

c = Sys.time()
message = paste0('Time to create main dataset: ',
                 round(difftime(c, a, units = 'hours'), 1), ' hours')
print(message)

######################################
#Print and save information on the baseline year
######################################
###After first match
rais_baseline = rais_agg %>% 
  filter(ano == baseline)
#debt ratio by year
rais_baseline %>% 
  ggplot(aes(debt_ratio_t))+
  geom_density()+
  facet_wrap(~ano)

filename = paste0('Output_check/debt_ratio_year.png')
ggsave(filename, height = 9, width = 11)

#real wages by year
rais_baseline %>% 
  ggplot(aes(real_wage_t))+
  geom_density()+
  facet_wrap(~ano)

filename = paste0('Output_check/wage_year.png')
ggsave(filename, height = 9, width = 11)

#Number of matched individuals by year
rais_baseline %>%
  group_by(ano) %>% 
  summarise(n_matched = n()) %>% 
  ungroup() %>% 
  ggplot(aes(x = ano, y = n_matched))+
  geom_point()+geom_line()

filename = paste0('Output_check/matched_year.png')
ggsave(filename, height = 7, width = 5)

print(summary(rais_baseline))


####After second match
rais_baseline = rais_agg %>% 
  filter(ano == baseline & !is.na(second_match_id))
#debt ratio by year
rais_baseline %>% 
  ggplot(aes(debt_ratio_t))+
  geom_density()+
  facet_wrap(~ano)

filename = paste0('Output_check/debt_ratio_year_sm.png')
ggsave(filename, height = 9, width = 11)

#real wage by year
rais_baseline %>% 
  ggplot(aes(real_wage_t))+
  geom_density()+
  facet_wrap(~ano)

filename = paste0('Output_check/wage_year_sm.png')
ggsave(filename, height = 9, width = 11)

#Number of matched individuals by year
rais_baseline %>%
  group_by(ano) %>% 
  summarise(n_matched = n()) %>% 
  ungroup() %>% 
  ggplot(aes(x = ano, y = n_matched))+
  geom_point()+geom_line()

filename = paste0('Output_check/matched_year_sm.png')
ggsave(filename, height = 7, width = 5)

print(summary(rais_baseline))


rm(list = ls())
gc()
  


  














