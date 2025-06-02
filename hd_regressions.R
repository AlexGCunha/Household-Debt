#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Run Regressions and create tables
#- Run after hd_create_panel
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
if (!require("fixest")) install.packages("splitstackshape", repos = repository)
if (!require("cowplot")) install.packages("splitstackshape", repos = repository)
if (!require("modelsummary")) install.packages("splitstackshape", repos = repository)
if (!require("broom")) install.packages("splitstackshape", repos = repository)

library(tidyverse)
library(arrow)
library(data.table)
library(fixest)
library(cowplot)
library(modelsummary)
library(broom)

output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check/"
data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files/"
code_path = "Z:/Bernardus/Cunha_Santos_Doornik/Codes/"

#COMENTAR
output_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Output/"
data_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Data/"
code_path = "C:/Users/xande/OneDrive/Documentos/Doutorado/RA/Household Debt/Household-Debt/"

# source(paste0(code_path, "hd_aux_funcs.R"))
#Parameters
years_prior = 3
years_after = 5
periods = years_after + years_prior + 1
period_of_reference = 0
wage_use = "mean_wage"
dia = Sys.Date()

#initial adjustments
df_fm = read_parquet(paste0(data_path, "agg_panel.parquet")) %>% 
  filter(!is.na(first_match_id))

#filter workers where the first match id indicates 2 workers
df_fm = df_fm %>% 
  group_by(first_match_id) %>% 
  mutate(count_cpf = length(unique(cpf))) %>% 
  ungroup() %>% 
  filter(count_cpf == 2)


df_sm = df_fm %>% 
  filter(!is.na(second_match_id))

##########################################
#Table: Summary Statistics for displaced x non-displaced
##########################################
summary_data = df_sm %>% 
  filter(year == baseline) %>% 
  mutate(lths = ifelse(skill_b == 1, 100, 0),
         hs_some_college = ifelse(skill_b == 2, 100, 0),
         college_or_more = ifelse(skill_b == 3, 100, 0),
         lpop = log(pop_m),
         across(c('unem_rate_m','inf_rate_m', 'lths_rate_m', 
                  'hs_rate_m'), ~.*100),
         treat_status = ifelse(treated == 1, 'Treated', 'Control'),
         debt_stats = ifelse(high_debt_b == 1, 'High', 'Low')) %>% 
  rename('Debt Ratio' = 'debt_ratio_b',
         'Wages' = 'real_earnings_b',
         'Less Than HS' = 'lths',
         'HS or Some College' = 'hs_some_college', 
         'Age' = 'age_b', 
         'Firm Size'= 'n_employees_b', 
         'Unemp Rate (M)' = 'unem_rate_m', 
         'Informality Rate (M)' = 'inf_rate_m',
         'Log Pop (M)' = 'lpop', 
         'Mean Earnings (M)' = 'mean_income_m',
         'Less Than HS (M)' = 'lths_rate_m', 
         'HS or Some College (M)' = 'hs_rate_m')

datasummary_balance(`Debt Ratio`
                    + `Mean Wages` + `Less Than HS` + `HS or Some College`
                    + `College or More` + `Age` + `Firm Size` + `Log Pop (M)`
                    + `Unem Rate (M)` + `Informality Rate (M)` + `Population (M)`
                    + `Less Than HS (M)` +`HS or Some College (M)` 
                    ~ treat_status,
                    data = summary_data, 
                    fmt = fmt_decimal(digits = 1),
                    stars = TRUE,
                    output = paste0(output_path,"summary_treat_control_sm.txt"),
                    title = 'Control x Treated - After Second Match')

rm(summary_data)

##########################################
#Table: Summary Statistics for displaced x non-displaced - First Match
##########################################
summary_data = df_fm %>% 
  filter(year == baseline) %>% 
  mutate(lths = ifelse(skill_b == 1, 100, 0),
         hs_some_college = ifelse(skill_b == 2, 100, 0),
         college_or_more = ifelse(skill_b == 3, 100, 0),
         lpop = log(pop_m),
         across(c('unem_rate_m','inf_rate_m', 'lths_rate_m', 
                  'hs_rate_m'), ~.*100),
         treat_status = ifelse(treated == 1, 'Treated', 'Control'),
         debt_stats = ifelse(high_debt_b == 1, 'High', 'Low')) %>% 
  rename('Debt Ratio' = 'debt_ratio_b',
         'Wages' = 'real_earnings_b',
         'Less Than HS' = 'lths',
         'HS or Some College' = 'hs_some_college', 
         'Age' = 'age_b', 
         'Firm Size'= 'n_employees_b', 
         'Unemp Rate (M)' = 'unem_rate_m', 
         'Informality Rate (M)' = 'inf_rate_m',
         'Log Pop (M)' = 'lpop', 
         'Mean Earnings (M)' = 'mean_income_m',
         'Less Than HS (M)' = 'lths_rate_m', 
         'HS or Some College (M)' = 'hs_rate_m')

datasummary_balance(`Debt Ratio`
                    + `Mean Wages` + `Less Than HS` + `HS or Some College`
                    + `College or More` + `Age` + `Firm Size` + `Log Pop (M)`
                    + `Unem Rate (M)` + `Informality Rate (M)` + `Population (M)`
                    + `Less Than HS (M)` +`HS or Some College (M)` 
                    ~ treat_status,
                    data = summary_data, 
                    fmt = fmt_decimal(digits = 1),
                    stars = TRUE,
                    output = paste0(output_path,"summary_treat_control_fm.txt"),
                    title = 'Control x Treated - After First Match')

rm(summary_data)

##########################################
#Table: Displaced LD x Displaced HD, second match
##########################################
summary_data = df_sm %>% 
  filter(year == baseline & treated == 1) %>% 
  mutate(lths = ifelse(skill_b == 1, 100, 0),
         hs_some_college = ifelse(skill_b == 2, 100, 0),
         college_or_more = ifelse(skill_b == 3, 100, 0),
         lpop = log(pop_m),
         across(c('unem_rate_m','inf_rate_m', 'lths_rate_m', 
                  'hs_rate_m'), ~.*100),
         treat_status = ifelse(treated == 1, 'Treated', 'Control'),
         debt_stats = ifelse(high_debt_b == 1, 'High', 'Low')) %>% 
  rename('Debt Ratio' = 'debt_ratio_b',
         'Wages' = 'real_earnings_b',
         'Less Than HS' = 'lths',
         'HS or Some College' = 'hs_some_college', 
         'Age' = 'age_b', 
         'Firm Size'= 'n_employees_b', 
         'Unemp Rate (M)' = 'unem_rate_m', 
         'Informality Rate (M)' = 'inf_rate_m',
         'Log Pop (M)' = 'lpop', 
         'Mean Earnings (M)' = 'mean_income_m',
         'Less Than HS (M)' = 'lths_rate_m', 
         'HS or Some College (M)' = 'hs_rate_m')

datasummary_balance(`Debt Ratio`
                    + `Mean Wages` + `Less Than HS` + `HS or Some College`
                    + `College or More` + `Age` + `Firm Size` + `Log Pop (M)`
                    + `Unem Rate (M)` + `Informality Rate (M)` + `Population (M)`
                    + `Less Than HS (M)` +`HS or Some College (M)` 
                    ~ debt_stats,
                    data = summary_data, 
                    fmt = fmt_decimal(digits = 1),
                    stars = TRUE,
                    output = paste0(output_path,"summary_treat_hd_ld_sm.txt"),
                    title = 'Control x Treated - After First Match')

rm(summary_data)


##########################################
#Table: Displaced LD x Displaced HD, first match
##########################################
summary_data = df_fm %>% 
  filter(year == baseline & treated == 1) %>% 
  mutate(lths = ifelse(skill_b == 1, 100, 0),
         hs_some_college = ifelse(skill_b == 2, 100, 0),
         college_or_more = ifelse(skill_b == 3, 100, 0),
         lpop = log(pop_m),
         across(c('unem_rate_m','inf_rate_m', 'lths_rate_m', 
                  'hs_rate_m'), ~.*100),
         treat_status = ifelse(treated == 1, 'Treated', 'Control'),
         debt_stats = ifelse(high_debt_b == 1, 'High', 'Low')) %>% 
  rename('Debt Ratio' = 'debt_ratio_b',
         'Wages' = 'real_earnings_b',
         'Less Than HS' = 'lths',
         'HS or Some College' = 'hs_some_college', 
         'Age' = 'age_b', 
         'Firm Size'= 'n_employees_b', 
         'Unemp Rate (M)' = 'unem_rate_m', 
         'Informality Rate (M)' = 'inf_rate_m',
         'Log Pop (M)' = 'lpop', 
         'Mean Earnings (M)' = 'mean_income_m',
         'Less Than HS (M)' = 'lths_rate_m', 
         'HS or Some College (M)' = 'hs_rate_m')

datasummary_balance(`Debt Ratio`
                    + `Mean Wages` + `Less Than HS` + `HS or Some College`
                    + `College or More` + `Age` + `Firm Size` + `Log Pop (M)`
                    + `Unem Rate (M)` + `Informality Rate (M)` + `Population (M)`
                    + `Less Than HS (M)` +`HS or Some College (M)` 
                    ~ debt_stats,
                    data = summary_data, 
                    fmt = fmt_decimal(digits = 1),
                    stars = TRUE,
                    output = paste0(output_path,"summary_treat_hd_ld_fm.txt"),
                    title = 'Control x Treated - After First Match')

rm(summary_data)

##########################################
#Mean effects by debt level - triple difference
##########################################
emp_avg_sm = triple_diff(data = df_fm, 
                         dep_var = "employed",
                         family = "gaussian",
                         td_on = "high_debt_b")

wage_avg_sm = triple_diff(data = df_fm,
                          dep_var = "mean_wage",
                          family = "poisson",
                          td_on = "high_debt_b")


modelsummary(
  models = list ('Formal Employment' = emp_avg_sm,
                 'Wages'= wage_avg_sm),
  stars = T,
  coef_omit = c(-1,-4),
  coef_rename = c(
    'treated:pos' = 'Treated x After',
    'treated:pos:high_debt_b' = 'Treated x After x High Debt'),
  gof_map = c('nobs', 'r.squared'),
  output = paste0(output_path, 'td_debt.txt'),
  title = 'Triple Difference Average Results',
  fmt = fmt_decimal(digits = 3, pdigits = 3))


##########################################
#Event Study Overall
##########################################
wage_all = m_model(data = df_fm, dep_var = 'mean_wage', 
                   controls = 1, reference_period = 0, 
                   family = 'poisson')

emp_all = m_model(data = df_fm, dep_var = 'employed', 
                   controls = 1, reference_period = 0)


plot_wage = multi_line_graph(models = list(wage_all),
                             legends = c(''), 
                             graph_title = '(b) Real Wages',
                             exponentiate = 1,
                             reference_period = 0)

plot_emp = multi_line_graph(models = list(wage_all),
                             legends = c(''), 
                             graph_title = '(a) Employment',
                             exponentiate = 0,
                             reference_period = 0)

plot_grid(plot_emp, plot_wage) %>% print()
ggsave(paste0(output_path, 'es_main.png'), height = 5, width = 6)
source(paste0(code_path, "hd_aux_funcs.R"))

##########################################
#Event Study Por Nível de Dívida
##########################################
wage_hd = m_model(data = df_fm, dep_var = 'mean_wage', 
                  controls = 1, reference_period = 0, 
                  family = 'poisson',
                  high_debt = 1)

emp_hd = m_model(data = df_fm, dep_var = 'employed', 
                 controls = 1, reference_period = 0,
                 high_debt = 1)

wage_ld = m_model(data = df_fm, dep_var = 'mean_wage', 
                  controls = 1, reference_period = 0, 
                  family = 'poisson',
                  high_debt = 0)

emp_ld = m_model(data = df_fm, dep_var = 'employed', 
                 controls = 1, reference_period = 0,
                 high_debt = 0)



plot_wage = multi_line_graph(models = list(wage_hd, wage_ld),
                             legends = c('High Debt', 'Low Debt'), 
                             graph_title = '(b) Real Wages',
                             exponentiate = 1,
                             reference_period = 0)

plot_emp = multi_line_graph(models = list(emp_hd, emp_ld),
                            legends = c('High Debt', 'Low Debt'), 
                            graph_title = '(a) Employment',
                            exponentiate = 0,
                            reference_period = 0)

legends = get_plot_component(plot_wage, "guide-box", return_all = TRUE)[[5]]

p_td = plot_grid(plot_emp + theme(legend.position = "bottom"),
                 plot_wage + theme(legend.position = "bottom"))


ggsave(paste0(output_path, 'es_debt.png'), height = 5, width = 6)

##########################################
#Robustness -Mean effects by debt level - triple difference Second Match
##########################################
emp_avg_sm = triple_diff(data = df_sm, 
                         dep_var = "employed",
                         family = "gaussian",
                         td_on = "high_debt_b")

wage_avg_sm = triple_diff(data = df_sm,
                          dep_var = "mean_wage",
                          family = "poisson",
                          td_on = "high_debt_b")


modelsummary(
  models = list ('Formal Employment' = emp_avg_sm,
                 'Wages'= wage_avg_sm),
  stars = T,
  coef_omit = c(-1,-4),
  coef_rename = c(
    'treated:pos' = 'Treated x After',
    'treated:pos:high_debt_b' = 'Treated x After x High Debt'),
  gof_map = c('nobs', 'r.squared'),
  output = paste0(output_path, 'td_debt_sm.txt'),
  title = 'Triple Difference Average Results - SM',
  fmt = fmt_decimal(digits = 3, pdigits = 3))

rm(emp_avg_sm, wage_avg_sm)

##########################################
#Only reemployed - Simple OLS
##########################################
df_reemp = copy(df_fm) %>% 
  data.table()

df_reemp = df_reemp[treated == 1 & first_job_time > 0 & year == baseline]
df_reemp[, `:=`(better_first_job_occup = fifelse(wage_first_job_cbo3 > wage_cbo3_b, 1, 0),
                better_first_job_wage = fifelse(first_job_wage > real_earnings_b, 1, 0))]

m1 = feols(log(first_job_wage) ~ high_debt_b + first_job_time + better_first_job_occup
           + age_b + I(age_b^2) + log(n_employees_b) + log(pop_m) 
           + log(tot_income_m) + unem_rate_m + lths_rate_m + hs_rate_m 
           + log(pea_m) | skill_b + uf_b,
           data = df_reemp)

m2 = feols(better_first_job_wage ~ high_debt_b + first_job_time + better_first_job_occup 
           + age_b + I(age_b^2) + log(n_employees_b) + log(pop_m) 
           + log(tot_income_m) + unem_rate_m + lths_rate_m + hs_rate_m 
           + log(pea_m) | skill_b + uf_b,
           data = df_reemp)

m3 = feols(better_first_job_occup ~ high_debt_b + first_job_time  
           + age_b + I(age_b^2) + log(n_employees_b) + log(pop_m) 
           + log(tot_income_m) + unem_rate_m + lths_rate_m + hs_rate_m 
           + log(pea_m) | skill_b + uf_b,
           data = df_reemp)

m4 = feols(first_job_time ~ high_debt_b  
           + age_b + I(age_b^2) + log(n_employees_b) + log(pop_m) 
           + log(tot_income_m) + unem_rate_m + lths_rate_m + hs_rate_m 
           + log(pea_m) | skill_b + uf_b,
           data = df_reemp)


modelsummary(
  models = list ('First Job Wage' = m1,
                 'Better First Job Wage' = m2,
                 'Better First Job Occup' = m3,
                 'Time to First Job' = m4),
  stars = T,
  gof_map = c('nobs', 'r.squared'),
  output = paste0(output_path, 'reemployed_ols.txt'),
  title = 'OLS for reemployed workers',
  fmt = fmt_decimal(digits = 3, pdigits = 3))

##########################################
#Individual DiD
##########################################
#Starting by calculating individual DiD
df_did = copy(df_fm) %>% 
  data.table()

df_did[, `:=`(
  dif_wage_1 = mean_wage[year_relative_baseline == 1] - real_earnings_b[year_relative_baseline == 0],
  dif_wage_2 = mean_wage[year_relative_baseline == 2] - real_earnings_b[year_relative_baseline == 0],
  dif_wage_3 = mean_wage[year_relative_baseline == 3] - real_earnings_b[year_relative_baseline == 0],
  dif_lwage_1 = log(1+mean_wage[year_relative_baseline == 1]) - log(1+real_earnings_b[year_relative_baseline == 0]),
  dif_lwage_2 = log(1+mean_wage[year_relative_baseline == 2]) - log(1+real_earnings_b[year_relative_baseline == 0]),
  dif_lwage_3 = log(1+mean_wage[year_relative_baseline == 3]) - log(1+real_earnings_b[year_relative_baseline == 0]),
  dif_emp_1 = employed[year_relative_baseline == 1] - employed[year_relative_baseline == 0],
  dif_emp_2 = employed[year_relative_baseline == 2] - employed[year_relative_baseline == 0],
  dif_emp_3 = employed[year_relative_baseline == 1] - employed[year_relative_baseline == 0],
  dif_cbo3_1 = wage_cbo3[year_relative_baseline == 1] - wage_cbo3_b[year_relative_baseline == 0],
  dif_cbo3_2 = wage_cbo3[year_relative_baseline == 2] - wage_cbo3_b[year_relative_baseline == 0],
  dif_cbo3_3 = wage_cbo3[year_relative_baseline == 3] - wage_cbo3_b[year_relative_baseline == 0]),
  by = .(cpf, first_match_id)]

#indicator if treated worker was employed in each year
df_did[treated == 1, `:=`(
  emp_b1 = fifelse(employed[year_relative_baseline == 1] == 1, 1, 0),
  emp_b2 = fifelse(employed[year_relative_baseline == 2] == 1, 1, 0),
  emp_b3 = fifelse(employed[year_relative_baseline == 3] == 1, 1, 0)),
  by = .(cpf, first_match_id)]

df_did = df_did[year == baseline]

df_did[, `:=`(
  did_wage_1 = dif_wage_1[treated == 1] - dif_wage_1[treated == 0],
  did_wage_2 = dif_wage_2[treated == 1] - dif_wage_2[treated == 0],
  did_wage_3 = dif_wage_3[treated == 1] - dif_wage_3[treated == 0],
  did_lwage_1 = dif_lwage_1[treated == 1] - dif_lwage_1[treated == 0],
  did_lwage_2 = dif_lwage_2[treated == 1] - dif_lwage_2[treated == 0],
  did_lwage_3 = dif_lwage_3[treated == 1] - dif_lwage_3[treated == 0],
  did_emp_1 = dif_emp_1[treated == 1] - dif_emp_1[treated == 0],
  did_emp_2 = dif_emp_2[treated == 1] - dif_emp_2[treated == 0],
  did_emp_3 = dif_emp_3[treated == 1] - dif_emp_3[treated == 0],
  did_cbo3_1 = dif_cbo3_1[treated == 1] - dif_cbo3_1[treated == 0],
  did_cbo3_2 = dif_cbo3_2[treated == 1] - dif_cbo3_2[treated == 0],
  did_cbo3_3 = dif_cbo3_3[treated == 1] - dif_cbo3_3[treated == 0]),
  by = .(first_match_id)]

df_did = df_did[treated == 1]

##########################################
#Queda de Salários e empregos - TODOS
##########################################
m1 = feols(did_wage_1 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

m2 = feols(did_wage_2 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

m3 = feols(did_wage_3 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

m4 = feols(did_emp_1 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

m5 = feols(did_emp_2 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

m6 = feols(did_emp_3 ~ debt_ratio_b + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did)

modelsummary(
  models = list ('Formal Employment' = list("1y" = m1, 
                                            "2y" = m2, 
                                            "3y" = m3),
                 'Wages' = list("1y" = m4, 
                                "2y" = m5, 
                                "3y" = m6)),
  stars = T,
  gof_map = c('nobs', 'r.squared'),
  output = paste0(output_path, 'ind_did.txt'),
  title = 'Individual DiD - Everyone',
  shape = 'cbind',
  fmt = fmt_decimal(digits = 3, pdigits = 3))
rm(m1, m2, m3, m4, m5, m6)
##########################################
#Queda de Salários e empregos - Condicional a ter se reempregado, por ano
##########################################
m1 = feols(did_lwage_1 ~ debt_ratio_b + dif_cbo3_1 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b1 == 1])

m2 = feols(did_lwage_2 ~ debt_ratio_b + dif_cbo3_2 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b2 == 1])

m3 = feols(did_lwage_3 ~ debt_ratio_b + dif_cbo3_3 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b3 == 1])

m4 = feols(did_emp_1 ~ debt_ratio_b + dif_cbo3_1 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b1 == 1])

m5 = feols(did_emp_2 ~ debt_ratio_b + dif_cbo3_2 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b2 == 1])

m6 = feols(did_emp_3 ~ debt_ratio_b + dif_cbo3_3 + real_earnings_b + age_b + I(age_b^2) + 
             log(n_employees_b)+ log(pop_m) + log(tot_income_m) + unem_rate_m +
             lths_rate_m + hs_rate_m + log(pea_m)  | skill_b + uf_b ,
           data = df_did[emp_b3 == 1])

modelsummary(
  models = list ('Formal Employment' = list("1y" = m1, 
                                            "2y" = m2, 
                                            "3y" = m3),
                 'Wages' = list("1y" = m4, 
                                "2y" = m5, 
                                "3y" = m6)),
  stars = T,
  gof_map = c('nobs', 'r.squared'),
  output = paste0(output_path, 'ind_did_reemployed.txt'),
  title = 'Individual DiD - Reemployed at each year timeframe',
  shape = 'cbind',
  fmt = fmt_decimal(digits = 3, pdigits = 3))

rm(m1, m2, m3, m4, m5, m6)


##########################################
rm(list = ls())
gc()
