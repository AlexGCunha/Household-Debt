#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Make RAIS files compatible through years 
# These rais files were downloaded via sql from the code hd_RAIS_importation_teradata
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

# library(tidyverse)
# library(haven) 
# library(arrow)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check"
scr_path = "Z:/DATA/Dta_files/SCR_TERADATA"

a = Sys.time()
setwd(data_path)
###################################
#1994-2001
###################################
for (i in c(1994:2001)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "educ_85","sex","hire_month","age","cnae_95",
               "wk_hours")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ_85 >=5,1,0),
           educ_hs = ifelse(educ_85 >= 7,1,0),
           educ_col = ifelse(educ_85 >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  #Add columns
  df<- df %>% 
    mutate(cpf = rep(NA, nrow(df)),
           color = rep(NA, nrow(df)),
           cbo_02 = rep(NA, nrow(df)),
           ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}

###################################
#2002
###################################
for (i in c(2002:2002)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "educ_85","sex","hire_month","cnae_95",
               "wk_hours")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj", "cpf")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #Correct born_date and create age
  df <- df %>% 
    mutate(born_date = as.character(born_date),
           nc = nchar(born_date)) %>% 
    mutate(born_date = case_when(nc == 8 ~ born_date,
                                 nc == 7 ~paste0(0,born_date),
                                 T ~ NA_character_)) %>% 
    mutate(born_date = as.Date(born_date, format = "%d%m%Y"))
  
  date_comparison = as.Date(paste0("3112",i), format = "%d%m%Y")
  
  df <- df %>% 
    mutate(age = as.integer(floor(date_comparison - born_date)/365))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ_85 >=5,1,0),
           educ_hs = ifelse(educ_85 >= 7,1,0),
           educ_col = ifelse(educ_85 >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  #Add columns
  df<- df %>% 
    mutate(color = rep(NA, nrow(df)),
           cbo_02 = rep(NA, nrow(df)),
           ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}


###################################
#2003-2005
###################################
for (i in c(2003:2005)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "educ_85","sex","hire_month","cnae_95",
               "wk_hours", "color")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj", "cpf", "cbo_02")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #Correct born_date and create age
  df <- df %>% 
    mutate(born_date = as.character(born_date),
           nc = nchar(born_date)) %>% 
    mutate(born_date = case_when(nc == 8 ~ born_date,
                                 nc == 7 ~paste0(0,born_date),
                                 T ~ NA_character_)) %>% 
    mutate(born_date = as.Date(born_date, format = "%d%m%Y"))
  
  date_comparison = as.Date(paste0("3112",i), format = "%d%m%Y")
  
  df <- df %>% 
    mutate(age = as.integer(floor(date_comparison - born_date)/365))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ_85 >=5,1,0),
           educ_hs = ifelse(educ_85 >= 7,1,0),
           educ_col = ifelse(educ_85 >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  df <- df %>% 
    mutate(ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}

###################################
#2006-2009
###################################
for (i in c(2006:2009)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "sex","hire_month","cnae_95",
               "wk_hours", "color", "educ")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj", "cpf", "cbo_02")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #Correct born_date and create age
  df <- df %>% 
    mutate(born_date = as.character(born_date),
           nc = nchar(born_date)) %>% 
    mutate(born_date = case_when(nc == 8 ~ born_date,
                                 nc == 7 ~paste0(0,born_date),
                                 T ~ NA_character_)) %>% 
    mutate(born_date = as.Date(born_date, format = "%d%m%Y"))
  
  date_comparison = as.Date(paste0("3112",i), format = "%d%m%Y")
  
  df <- df %>% 
    mutate(age = as.integer(floor(date_comparison - born_date)/365))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ >=5,1,0),
           educ_hs = ifelse(educ >= 7,1,0),
           educ_col = ifelse(educ >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  #Add columns
  df <- df %>% 
    mutate(ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}


###################################
#2010
###################################
for (i in c(2010:2010)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "sex","hire_month","cnae_95",
               "wk_hours", "color", "educ")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","cnpj", "cpf", "cbo_02")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #Correct born_date and create age
  df <- df %>% 
    mutate(born_date = as.character(born_date),
           nc = nchar(born_date)) %>% 
    mutate(born_date = case_when(nc == 8 ~ born_date,
                                 nc == 7 ~paste0(0,born_date),
                                 T ~ NA_character_)) %>% 
    mutate(born_date = as.Date(born_date, format = "%d%m%Y"))
  
  date_comparison = as.Date(paste0("3112",i), format = "%d%m%Y")
  
  df <- df %>% 
    mutate(age = as.integer(floor(date_comparison - born_date)/365))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ >=5,1,0),
           educ_hs = ifelse(educ >= 7,1,0),
           educ_col = ifelse(educ >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  #Add columns
  df<- df %>% 
    mutate(pis = rep(NA, nrow(df)),
           ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}


###################################
#2011-2012
###################################
for (i in c(2011:2012)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "sex","hire_month","cnae_95",
               "wk_hours", "color", "educ")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj", "cpf", "cbo_02")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ >=5,1,0),
           educ_hs = ifelse(educ >= 7,1,0),
           educ_col = ifelse(educ >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  
  #Add columns
  df<- df %>% 
    mutate(age = rep(NA, nrow(df)),
           ano = i)
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}


###################################
#2013-2021
###################################
for (i in c(2013:2021)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df <- read_dta(filename) %>% 
    mutate(active = as.integer(active)) %>% 
    filter(active == 1)
  
  #correct some numeric variables that have a "," as decimal separator
  variables <- c("emp_time", "wage_dec_sm")
  df <- df %>% 
    mutate(across(all_of(variables),as.character)) %>% 
    mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
    mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))
  
  #convert columns
  int_cols = c("munic","emp_type","quit_reason","quit_month",
               "sex","hire_month","age","cnae_95",
               "wk_hours", "color", "educ")
  continuous_cols <- c("emp_time", "wage_dec_sm")
  char_cols = c("cbo_94","pis","cnpj", "cpf", "cbo_02")
  
  df <- df %>% 
    mutate(across(all_of(int_cols), as.integer)) %>% 
    mutate(across(all_of(continuous_cols), as.numeric)) %>% 
    mutate(across(all_of(char_cols), as.character))
  
  
  #create some education dummies
  df <- df %>% 
    mutate(educ_fund = ifelse(educ >=5,1,0),
           educ_hs = ifelse(educ >= 7,1,0),
           educ_col = ifelse(educ >= 9,1,0))
  
  #drop unnecessary columns
  df <- df %>% 
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date", "nc")))
  
  #Add columns
  df = df %>% 
    mutate (ano = i)
  
  
  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)
  
  print(i)
  
}


b = Sys.time()
print(b-a)



###################################
#Merge files
###################################
aux_count = 0
for (i in c(1994:2021)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux <- read_parquet(filename)
  
  if(aux_count== 0){
    columns = colnames(df_aux)
    aux_count = 1
    df <- df_aux
  } else {
    df_aux <- df_aux %>% select(columns)
    df = rbind(df, df_aux)
  }
  
  
  #Save
  filename = paste0("RAIS_agg.parquet")
  write_parquet(df, filename)
  
  
}

print(summary(df))

c = Sys.time()
print(c-a)

rm(list = ls())
gc()
