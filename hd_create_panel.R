#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Use matched samples from "define_final_sample_match" to create a balanced
# panel for individuals on that sample on the individual x year aggregation
# Append to a unique final dataframe
#- Run after hd_define_final_sample_match
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




#-------------------------------------
#Loop to create base dataset
#-------------------------------------

final_dataset = data.table()
for(y in initial_year:final_year){
  b = Sys.time()
  filename = paste0(data_path, "matched_sample_", y, ".parquet")
  base = read_parquet(filename) %>% data.table()
  cpf_list = unique(base$cpf)
  
  #create aggregate dataframe to be filled with individual info by year
  agg_df = data.table()
  for(sub_y in (y-3):min(2019, (y+5))){
    filename = paste0(data_path, "rais_clean_", sub_y, ".parquet")
    df = read_parquet(filename) %>% data.table()
    df = df[cpf %in% cpf_list]
    
    #select_variables
    vars_keep = c('cpf', 'year', 'cbo_02', 'cnpj_cei', 
                  'quit_reason', 'real_earnings', 'active', 
                  'age', 'hire_year', 'hire_month','emp_time')
    
    df = df[,..vars_keep]
    df[, year := sub_y]
    
    #add loans data for years we have it -If we change here we also must change in define_potential_sample
    if(sub_y %in% c(2006:2015)){
      filename = paste0(data_path, "hd_scr_ind_clean_", sub_y, ".parquet")
      loans = read_parquet(filename) 
      setDT(loans)
    } else{
      loans = data.table(cpf = NA_real_,
                         loan_outstanding = NA_real_,
                         year = as.integer(NA))
    }
    
    df = merge(df, loans, by = c("year", "cpf"), all.x = TRUE)
    
    #add to agg df
    agg_df = rbind(agg_df, df)
    rm(df, loans)
    gc()
  }
  
  #get info on original displacement date and agg to agg_df
  displacement_date = base[, .(cpf, baseline, quit_month_le1)]
  displacement_date[, nc_disp := nchar(quit_month_le1)]
  displacement_date[, aux_quit_month := fcase(nc_disp == 1, paste0(0, quit_month_le1),
                                              default = paste0(quit_month_le1))]
  displacement_date[, disp_date := fcase(
    aux_quit_month != 0, as.Date(paste0("28", aux_quit_month, (baseline + 1)),
                                 format = "%d%m%Y"),
    default = as.Date(NA)
  )]
  displacement_date = displacement_date[, .(cpf, disp_date)]
  
  agg_df = merge(agg_df, displacement_date, by = "cpf", all.x = TRUE)
  
  #Drop potential duplicates
  agg_df[, duplicate := seq_len(.N), by = .(cpf, year, cnpj_cei, real_earnings,
                                            active)]
  agg_df = agg_df[duplicate == 1]
  agg_df[, duplicate := NULL]
  
  #Additional variables
  agg_df[, `:=`(displaced = fifelse(quit_reason == 11, 1, 0),
                new_job = fifelse(hire_year == y, 1, 0))]
  agg_df[, `:=`(job_highest_tenure = fifelse(emp_time == max(emp_time) 
                                             & active == 1, 1, 0),
                job_highest_wage = fifelse(real_earnings == max(real_earnings)
                                           & active == 1, 1, 0)),
         by = .(cpf, year)]
  
  #if person has multiple jobs with the same highest wage, keep the one with
  #also highest tenure
  agg_df[, n_jobs_highest_wage := sum(job_highest_wage), by = .(cpf, year)]
  agg_df[n_jobs_highest_wage > 1 & job_highest_wage == 1, 
         aux_job := fcase(emp_time == max(emp_time), 1, 
                          default = 0),
         by = .(cpf, year)]
  agg_df[, job_highest_wage := fcase(
    n_jobs_highest_wage  > 1 & job_highest_wage == 1, aux_job,
    default = job_highest_wage)]
  
  #if there are still multiple jobs with highest wage, drop worker
  agg_df[, n_jobs_highest_wage := sum(job_highest_wage), by = .(cpf, year)]
  n_workers_before = length(unique(agg_df$cpf))
  agg_df = agg_df[n_jobs_highest_wage <= 1]
  n_workers_after = length(unique(agg_df$cpf))
  dif = round(n_workers_after - n_workers_before)
  
  
  if(dif != 0){
    message = paste0("Workers dropped in ", y, " due to multiple jobs with highest wage: ",
                     n_workers_after - n_workers_before)
    print(message)
  }
  
  
  #define hire date for each employment spell
  agg_df[, nc_hire := nchar(hire_month)]
  agg_df[, aux_hire_month := fcase(nc_hire == 1, paste0(0, hire_month),
                                   default = paste0(hire_month))]
  agg_df[, hire_date := as.Date(paste0("28", aux_hire_month, hire_year), 
                                format = "%d%m%Y")]
  agg_df[, `:=`(aux_hire_month = NULL, nc_hire = NULL)]
  
  #add 2 and 3-digit occupation
  agg_df[, cbo_2digs := substr(cbo_02, 1,2)]
  agg_df[, cbo_3digs := substr(cbo_02,1,3)]
  
  #define first employment spell after displacement
  agg_df[, first_job_after := fcase(
    hire_date > disp_date & year == year(hire_date), 1, default = 0
  )]
  
  #for workers who entered in multiple jobs in the same month, keep the highest
  #earnings one. This is only for the first job after reemployment
  agg_df[, n_first_jobs := sum(first_job_after), by = .(cpf)]
  agg_df[n_first_jobs > 1 & first_job_after == 1 , aux_first_job := fcase(
    real_earnings == max(real_earnings), 1, default = 0
  ), by = .(cpf)]
  agg_df[, first_job_after := fcase(
    n_first_jobs >1 & first_job_after == 1, aux_first_job, 
    default = first_job_after
  )]
  
  #if there are still multiple first jobs, drop worker
  agg_df[, n_first_jobs := sum(first_job_after), by = .(cpf)]
  n_workers_before = length(unique(agg_df$cpf))
  agg_df = agg_df[n_first_jobs <= 1]
  n_workers_after = length(unique(agg_df$cpf))
  dif = round(n_workers_after - n_workers_before)
  
  
  if(dif != 0){
    message = paste0("Workers dropped in ", y, " due to multiple first jobs: ",
                     n_workers_after - n_workers_before)
    print(message)
  }
  
  
  #define time to first employment and first employment occupation
  agg_df[, `:=`(
    first_job_time = fcase(
      first_job_after == 1, as.integer(difftime(hire_date, disp_date, units = "days")),
      default = as.integer(0)),
    first_job_occup2 = fcase(
      first_job_after == 1, as.integer(cbo_2digs), default = as.integer(0) 
    ),
    first_job_occup3 = fcase(
      first_job_after == 1, as.integer(cbo_3digs), default = as.integer(0)
    ),
    first_job_wage = fcase(
      first_job_after == 1, as.integer(real_earnings), default = as.integer(0)
    )
  )]
  
  #inpute this info for every year
  agg_df[, `:=`(first_job_time = max(first_job_time),
                first_job_occup2 = max(first_job_occup2),
                first_job_occup3 = max(first_job_occup3),
                first_job_wage = max(first_job_wage)), by = .(cpf)]
  
  
  #Collapse to one line per individual-year
  agg_df = agg_df[,
                  .(total_wage = sum(real_earnings[active == 1]),
                    mean_wage = mean(real_earnings[active == 1]),
                    tenure_wage = mean(real_earnings[job_highest_tenure ==1]),
                    highest_wage = mean(real_earnings[job_highest_wage == 1]),
                    cbo2 = cbo_2digs[job_highest_wage == 1],
                    cbo3 = cbo_3digs[job_highest_wage == 1],
                    employed = max(active),
                    n_jobs_year = .N,
                    n_jobs = sum(active),
                    displaced = max(displaced),
                    new_job = max(new_job),
                    first_job_time = max(first_job_time),
                    first_job_cbo2 = max(first_job_occup2),
                    first_job_cbo3 = max(first_job_occup3),
                    first_job_wage = max(first_job_wage)),
                  by = .(cpf, year)]
  
  agg_df[, worked_in_year := fcase(n_jobs_year > 0, 1, default = 0)]
  
  #correct cbo for first employment
  agg_df[, `:=`(
    first_job_cbo2 = fcase(
      first_job_cbo2 == 0, as.character(0),
      nchar(first_job_cbo2) == 2, as.character(first_job_cbo2),
      nchar(first_job_cbo2) == 1, as.character(paste0(0, first_job_cbo2)),
      default = NA_character_),
    first_job_cbo3 = fcase(
      first_job_cbo3 == 0, as.character(0),
      nchar(first_job_cbo3) == 3, as.character(first_job_cbo3),
      nchar(first_job_cbo3) == 2, as.character(paste0(0, first_job_cbo3)),
      default = NA_character_)
  )]
  
  #Create a balanced panel
  bal_panel = expand_grid(cpf = cpf_list,
                          year = c((y-3):(y+5))) %>% 
    arrange(cpf, year) %>% data.table()
  
  nrow_ini = nrow(bal_panel)
  bal_panel = merge(bal_panel, agg_df, by = c("cpf", "year"), all.x = TRUE)
  bal_panel = merge(bal_panel, base, by = "cpf", all.x = TRUE)
  nrow_fin = nrow(bal_panel)
  
  #print a message if there is any difference in rownumber after join
  dif = nrow_fin - nrow_ini
  if(dif != 0) print(paste0("New rows after merging in ", y, " :", dif))
  
  rm(agg_df, base)
  gc()
  
  #Correct data for years the worker did not appear in rais
  cols_to_correct = c("total_wage", "mean_wage", 'tenure_wage', 'highest_wage',
                      'employed', 'n_jobs', 'n_jobs_year', 'worked_in_year')
  
  bal_panel[, (cols_to_correct) := lapply(.SD,
                                          function(x) fcase(is.na(x) | is.nan(x),
                                                            0,
                                                            default = as.double(x))),
            .SDcols = cols_to_correct]
  
  #Add year relative to baseline
  bal_panel[, year_relative_baseline := year - baseline]
  
  #add to main dataset
  final_dataset = rbind(final_dataset, bal_panel)
  rm(bal_panel)
  gc()
  
  #print time message
  c = Sys.time()
  message = paste0(round(difftime(c, b, units = "mins")),
                   " minutes to create ", y, " baseline panel")
  print(message)
  
}

#-------------------------------------
#Add municipality and wages based on CBO info
#-------------------------------------
#add municipality data
munic_data = read_parquet(paste0(data_path, "munic_data_10.parquet")) %>% data.table()
munic_data[, munic_b := as.numeric(substr(munic, 1, 6))]
munic_data[, munic := NULL]

final_dataset = merge(final_dataset, munic_data, by = "munic_b", all.x = TRUE)

####add data for wages (baseline, first job and annual jobs) based on 2-digits cbo
cbo_2 = read_parquet(paste0(data_path, "cbo_2digs.parquet"))

#annual wages
colnames(cbo_2) = c("cbo2", "wage_cbo2")
final_dataset = merge(final_dataset, cbo_2, by = ("cbo2"), all.x = TRUE)

#first job after reemployment wages
colnames(cbo_2) = c("first_job_cbo2", "wage_first_job_cbo2")
final_dataset = merge(final_dataset, cbo_2, by = ("first_job_cbo2"), all.x = TRUE)

#baseline
final_dataset[, cbo_2digs_b := substr(cbo_02_b, 1, 2)]
colnames(cbo_2) = c("cbo_2digs_b", "wage_cbo2_b")
final_dataset = merge(final_dataset, cbo_2, by = ("cbo_2digs_b"), all.x = TRUE)


####add data for wages (baseline, first job and annual jobs) based on 3-digits cbo
cbo_3 = read_parquet(paste0(data_path, "cbo_3digs.parquet"))

#annual wages
colnames(cbo_3) = c("cbo3", "wage_cbo3")
final_dataset = merge(final_dataset, cbo_3, by = ("cbo3"), all.x = TRUE)

#first job after reemployment wages
colnames(cbo_3) = c("first_job_cbo3", "wage_first_job_cbo3")
final_dataset = merge(final_dataset, cbo_3, by = ("first_job_cbo3"), all.x = TRUE)

#baseline
final_dataset[, cbo_3digs_b := substr(cbo_02_b, 1, 3)]
colnames(cbo_3) = c("cbo_3digs_b", "wage_cbo3_b")
final_dataset = merge(final_dataset, cbo_3, by = ("cbo_3digs_b"), all.x = TRUE)

#-------------------------------------
#Final adjustments
#-------------------------------------
#pairs are matched within baseline year; create a unique first match id for each
#pais across all years
final_dataset[!is.na(first_match_id), first_match_id := .GRP, 
              by = .(first_match_id, baseline)]
final_dataset[, `:=`(first_match_id = as.integer(first_match_id),
                     second_match_id = as.integer(second_match_id))]

#Second match ids only relate treated individuals. We want to use the same
#index to also denote their control counterparts. That is. we want second match id
#to designate 4 individuals: treated high debt, treated low debt and their 
#control counterpars per year. The procedure will be
#1) inpute -1 as second match id for both non-matched treated and for controls
#2) within first match id, designate the second match id as the maximum value of
# second match id. If the treated part was matched, it will hive the second match
#id, ifnot, it will give -1
#3) Save non second matched gorups (second_match_id == -1) in an aux column
#4) create another second match id for each baseline/group
#5) inpute NA for the ones not second matches (info saved in the aux column)
final_dataset[!is.na(first_match_id),
              second_match_id := fifelse(is.na(second_match_id), -1, 
                                         second_match_id)]

final_dataset[!is.na(first_match_id),
              second_match_id := max(second_match_id), by = .(first_match_id)]

final_dataset[!is.na(first_match_id),
              second_match_id_aux := second_match_id]

final_dataset[!is.na(first_match_id),
              second_match_id := .GRP, by = .(second_match_id, baseline)]

final_dataset[!is.na(first_match_id),
              second_match_id := fifelse(second_match_id_aux == -1,
                                         NA, second_match_id)]

final_dataset[, second_match_id_aux := NULL]


#Indicator if any employee in a matched pair ever had more than 1 job in dec
final_dataset[!is.na(second_match_id), ever_more_1_job := fcase(max(n_jobs) > 1, 1, 
                                                                default = 0),
              by = .(second_match_id)]

#add recession info
years_recession = c(1995, 1998, 2001, 2003, 2014, 2015, 2016, 2020)
final_dataset[, recession_b1 := fifelse((baseline + 1) %in% years_recession, 1, 0)]

#add treatement year
final_dataset[, year_treatment := fifelse(treated == 1, baseline + 1, 0)]
final_dataset[, cpf := as.numeric(cpf)]

#check if, for every second match id we have exactly 4 pis and 36 observations
check1 = final_dataset %>% 
  filter(!is.na(second_match_id)) %>% 
  count(second_match_id) %>% 
  count(n)

print(paste0("Number of observations per match (should be only 4 * years): "))
print(check1)

check2 = final_dataset %>% 
  filter(!is.na(second_match_id)) %>% 
  group_by(second_match_id) %>% 
  mutate(n_cpf = length(unique(cpf))) %>% 
  ungroup() %>% 
  count(n_cpf)

print(paste0("Number of individuals per second match (should be only 4): "))
print(check2)


print(summary(final_dataset))
print(str(final_dataset))
#save
filename = paste0(data_path, "agg_panel.parquet")
write_parquet(final_dataset, filename)

#print time message
c = Sys.time()
message = paste0(round(difftime(c, a, units = "hours"), 1),
                 " hours to create main dataset")
print(message)

rm(list = ls())
gc()

