library(tidyverse)
library(arrow)
library(haven)
library(tictoc)


#################################
#Create fake rais
#################################
tic()
initial_year = 2003
final_year = 2019

samp_size = 500000
# Função para gerar uma string de n dígitos aleatórios
set.seed(12)
generate_random_string <- function(n) {
  paste0(sample(0:9, n, replace = TRUE), collapse = "")
}

# Criando o vetor com 500 elementos
cnpjs_cei = replicate(500, generate_random_string(14))
munics = replicate(500, generate_random_string(6))

for (y in initial_year:final_year){
  rais = tibble(
    cpf = sample(c(1:(samp_size/2)), samp_size, TRUE),
    year = rep(y, samp_size),
    cnpj_cei = as.numeric(sample(cnpjs_cei, samp_size, TRUE)),
    active = sample(c(0,1,1,1,1,1,1,1,1), samp_size, TRUE),
    sex = sample(c(0,1), samp_size, TRUE),
    real_earnings = sample(c(800:10000), samp_size, TRUE),
    emp_type = sample(c(10, 10,10, 10, 10, 20), samp_size, TRUE),
    quit_reason = sample(c(0,10, 11, 20, 90), samp_size, TRUE),
    wk_hours = sample(c(10, 30, 30,30,30, 35, 44), samp_size, TRUE),
    emp_time = sample(c(1:300), samp_size, TRUE),
    cnae_95 = as.character(sample(c(0:100), samp_size, TRUE)),
    munic = as.numeric(sample(munics, samp_size, TRUE)),
    educ = sample(c(0:11), samp_size, TRUE),
    age = sample(c(0:80), samp_size, TRUE),
    cbo_02 = as.character(sample(c(0:99), samp_size, TRUE)),
    legal_nature = sample(c(1000:10000), samp_size, TRUE),
    hire_month = sample(c(1:12), samp_size, TRUE),
    hire_year = sample(c(2000:y), samp_size, TRUE),
    quit_month = sample(c(0: 12), samp_size, TRUE)
  ) %>% 
    mutate(cnpj = substr(cnpj_cei, 1, 8),
           across(c("cnpj", "cnpj_cei"), as.numeric),
           cnae_95 = as.character(cnae_95),
           munic = as.numeric(munic),
           cbo_02 = as.character(cbo_02))
  
  #save
  write_parquet(rais, paste0("../Data/rais_clean_", y, ".parquet"))
}
toc()

#################################
#Increase number of mass-layoffs
#################################
firms = read_parquet("../Data/emp_panel.parquet")
firms = firms %>% 
  mutate(var_emp_le1 = ifelse(var_emp_le1 <= -0.05, -0.4, var_emp_le1))

write_parquet(firms, "../Data/emp_panel.parquet")


#################################
#Create fake scr loans
#################################
initial_year = 2006
final_year = 2015

nsamp = 500000
loans = tibble(
  ano = sample(c(2006:2015), nsamp, TRUE),
  cpf = sample(c(1:(nsamp/2)), nsamp, TRUE),
  loan_outstanding = sample(c(1000:1000000), nsamp, TRUE)) %>% 
  mutate(time_id = paste0(ano, "12")) %>% 
  select(-ano) %>% 
  group_by(time_id, cpf) %>% 
  summarise(loan_outstanding = sum(loan_outstanding)) %>% 
  ungroup()

#save
write_dta(loans, "../Data/hd_SCR_indivudal.dta")
write_dta(loans, "../Data/hd_SCR_indivudal_loans.dta")

rm(list = ls())

#################################
#Create fake employment panel
#################################
initial_year = 2003
final_year = 2019

emp = expand_grid(cnpj_cei = as.numeric(cnpjs_cei),
                  year = initial_year:final_year)
nsamp = nrow(emp)
emp = emp %>% 
  mutate(n_employees = sample(c(1:300), nsamp, TRUE),
         n_employees_le1 = sample(c(1:300), nsamp, TRUE),
         var_emp_le1 = n_employees_le1/n_employees -1)

write_parquet(emp, "../Data/emp_panel.parquet")


#################################
#Create fake potential samples
#################################
initial_year = 2004
final_year = 2014
samp_size = 250000
years_recession = c(1995, 1998, 2001, 2003, 2014, 2015, 2016, 2020)
for(y in (initial_year:final_year)){
  aux = tibble(
    cpf = sample(c(1:samp_size), samp_size, FALSE),
    year = rep(y, samp_size),
    cnpj_cei = as.numeric(sample(cnpjs_cei, samp_size, TRUE)),
    active = rep(1, samp_size),
    sex = rep(1, samp_size),
    real_earnings = sample(c(800:10000), samp_size, TRUE),
    emp_type = rep(10, samp_size),
    quit_reason = rep(0, samp_size),
    wk_hours = sample(c(30, 35, 44), samp_size, TRUE),
    emp_time = sample(c(36:300), samp_size, TRUE),
    cnae_95 = as.character(sample(c(0:99), samp_size, TRUE)),
    munic = as.numeric(sample(munics, samp_size, TRUE)),
    educ = sample(c(0:11), samp_size, TRUE),
    age = sample(c(24:35), samp_size, TRUE),
    cbo_02 = as.character(sample(c(0:99), samp_size, TRUE)),
    legal_nature = sample(c(1000:10000), samp_size, TRUE),
    hire_month = sample(c(1:12), samp_size, TRUE),
    hire_year = sample(c(2000:y-3), samp_size, TRUE),
    quit_month = rep(0, samp_size),
    n_employees = sample(c(15:400), samp_size, TRUE),
    n_employees_le1 = sample(c(15:400), samp_size, TRUE),
    quit_reason_le1 = sample(c(0, 11), samp_size, TRUE),
    loan_outstanding = sample(c(1000:1000000), samp_size, TRUE),
    tenure = sample(c(3:6), samp_size, TRUE),
    uf = as.character(sample(c(1:4), samp_size, TRUE)),
    skill_b = sample(c(1,2,3), samp_size, TRUE)
    
  ) %>% 
    mutate(cnpj = substr(cnpj_cei, 1, 8),
           across(c("cnpj", "cnpj_cei"), as.numeric),
           cnae_95 = as.character(cnae_95),
           munic = as.numeric(munic),
           cbo_02 = as.character(cbo_02),
           var_emp_le1 = n_employees_le1/n_employees - 1,
           treated = ifelse(quit_reason_le1 == 11, 1, 0),
           pot_control = ifelse(quit_reason_le1 == 0, 1, 0),
           quartile_size = cut_number(n_employees, 4),
           debt_ratio = loan_outstanding/real_earnings*12,
           decile_debt = cut_number(debt_ratio, 10),
           recession = ifelse(year %in% years_recession, 1, 0),
           recession_le1 = ifelse(year + 1 %in% years_recession, 1, 0),
           cnae1 = substr(cnae_95,1, 1),
           quit_month_le1 = ifelse(quit_reason_le1 == 0, 0, sample(c(1:12),1))
  )
  
  write_parquet(aux, paste0("../Data/potential_sample_", y, ".parquet"))
  
  rm(aux)
}



