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

#Set parameters
sex_use = c(1)
min_age = 24
max_age = 50

###################################
#Print structure of each downloaded database
###################################
for (i in c(1997:2021)){
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename) %>% 
    mutate(ano = i)
  
  print(summary(df))
}
rm(df)
gc()

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

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

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
  print(summary(df))

}

###################################
#2002
###################################
for (i in c(2002:2002)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename)

  #in this year, we didnt filter active individuals in SQL, so lets see
  #the unique values
  aux_values = sort(unique(df$active))
  unique_2002 = ""
  for (value in aux_values) unique_2002 = paste(unique_2002, value, sep = ", ")
  message = paste0("Distinct values for 'active' column in 2002: ", unique_2002)
  print(message)

  #Filter active individuals
  df = df %>%
    mutate(active = as.integer(active)) %>%
    filter(active == 1)

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

  #Add columns
  df<- df %>%
    mutate(color = rep(NA, nrow(df)),
           cbo_02 = rep(NA, nrow(df)),
           ano = i)

  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

}


###################################
#2003-2005
###################################
for (i in c(2003:2005)){
  #Open file and filter individuals who were working in December
  year = substr(i, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename)

  if(i == 2003){
    #in this year, we didnt filter active individuals in SQL, so lets see
    #the unique values
    aux_values = sort(unique(df$active))
    unique_2003 = ""
    for (value in aux_values) unique_2003 = paste(unique_2003, value,
                                                  sep = ", ")
    message = paste0("Distinct values for 'active' column in 2003: ",
                     unique_2003)
    print(message)
  }

  #Filter active individuals
  df = df %>%
    mutate(active = as.integer(active)) %>%
    filter(active == 1)

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

  df <- df %>%
    mutate(ano = i)

  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

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

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

  #Add columns
  df <- df %>%
    mutate(ano = i)

  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

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

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

  #Add columns
  df<- df %>%
    mutate(pis = rep(NA, nrow(df)),
           ano = i)

  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

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

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))


  #Add columns
  df<- df %>%
    mutate(age = rep(NA, nrow(df)),
           ano = i)

  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

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

  #print total formal workers in that year
  n_workers = nrow(df)
  message = paste0('Formal CLT workers in ', i, ': ', n_workers)
  print(message)

  #correct some numeric variables that have a "," as decimal separator
  # variables <- c("emp_time", "wage_dec_sm")
  # df <- df %>%
  #   mutate(across(all_of(variables),as.character)) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[.]",""))) %>%
  #   mutate(across(all_of(variables),~str_replace_all(.,"[,]",".")))

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
    select(!any_of(c("active","wage_dec_nom", "educ_85","educ", "born_date",
                     "nc")))

  #Add columns
  df = df %>%
    mutate (ano = i)


  #Save
  filename = paste0("RAIS_comp_",year,".parquet")
  write_parquet(df, filename)

  print(i)
  print(summary(df))

}


b = Sys.time()
print(b-a)

###################################
#Pis correction for 2010
###################################
#Create a unique file with pis x cpf correspondance
df_pis = tibble()
for (i in c(2002:2009, 2011:2021)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux <- read_parquet(filename) %>%
    filter(!is.na(pis) & !is.na(cpf)) %>%
    group_by(cpf) %>%
    summarise(pis_aux = first(pis)) %>%
    ungroup() %>%
    mutate(ano_aux = i)

  #aggregate and remove duplicates picking the most recent one
  df_pis = rbind(df_pis, df_aux) %>%
    group_by(pis_aux) %>%
    filter(ano_aux == max(ano_aux)) %>%
    ungroup()
}

df_pis = df_pis %>%
  select(!ano_aux)

#update pis information for 2010
for (i in c(2010)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux <- read_parquet(filename) %>%
    left_join(df_pis, by = 'cpf', na_matches = 'never') %>%
    mutate(pis = pis_aux) %>%
    select(!c(pis_aux))

  #Update file
  write_parquet(df_aux, filename)

}

rm(df_pis, df_aux)

###################################
#Age correction for 2011 and 2012
###################################
#Create a unique file with everyones age
df_age = tibble()
for (i in c(2002:2010, 2013:2015)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux <- read_parquet(filename) %>%
    filter(!is.na(age)) %>%
    group_by(pis) %>%
    summarise(age_aux = first(age)) %>%
    ungroup() %>%
    mutate(ano_aux = i)

  #aggregate and remove duplicates
  df_age = rbind(df_age, df_aux) %>%
    group_by(pis) %>%
    filter(ano_aux == max(ano_aux)) %>%
    ungroup()
}

#update age information for 2011 and 2012
for (i in c(2011:2012)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux <- read_parquet(filename) %>%
    left_join(df_age, by = 'pis', na_matches = 'never') %>%
    mutate(age = ano - ano_aux + age_aux) %>%
    select(!c(ano_aux, age_aux))

  #Update file
  write_parquet(df_aux, filename)

}
rm(df_age, df_aux)

###################################
#Additional modifications
###################################
#take a list of columns we want (the same across every year)
columns_to_keep = read_parquet('RAIS_comp_94.parquet') %>% 
  select(!any_of(c("active", "emp_type"))) %>% 
  colnames()

for (i in c(1994:2021)){
  #Open file
  year = substr(i, 3,4)
  filename = paste0("RAIS_comp_",year,".parquet")
  df_aux = read_parquet(filename) %>% 
    select(all_of(columns_to_keep)) %>% 
    #drop observations without cnpj
    filter(!is.na(cnpj)) %>% 
    #filter characteristics we want
    filter(age >= min_age,
           age <= max_age)
  
  #Inpute subscript _t for every column that is not pis and ano
  df_aux = df_aux %>% select(pis, ano, everything())
  cols = colnames(df_aux)[3:ncol(df_aux)]
  cols = paste0(cols, '_t')
  cols = c('pis', 'ano', cols)
  colnames(df_aux) = cols
  
  #Update file
  filename = paste0("RAIS_comp_filt_",year,".parquet")
  write_parquet(df_aux, filename)
  
  #Print number of workers per year
  n_workers = nrow(df_aux)
  message = paste0('Workers in ', i, ' after cleaning: ', n_workers)
  print(message)
  print(summary(df_aux))  
}


b = Sys.time()
message = paste0('Time to clean yearly datasets: ', 
                 round(difftime(b, a, units = 'hours'),1), ' hours')
print(message)

rm(list = ls())
gc()

