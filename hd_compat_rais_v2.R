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

library(tidyverse)
library(haven)
library(arrow)
library(readxl)

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check"
scr_path = "Z:/DATA/Dta_files/SCR_TERADATA"
a = Sys.time()
setwd(data_path)

initial_year = 2003
final_year = 2019

#aux df with deflators
df_br = read_excel("series_nacionais.xlsx", sheet = 'anual') %>% 
  select(ano, deflator_2010_t) %>% 
  rename(deflator = deflator_2010_t)

###################################
#Print structure of each downloaded database
###################################
for (y in c(2003:2007)){
  year = substr(y, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename) %>% 
    mutate(ano = y) %>% 
    select(-any_of(c("cpf", "pis", "cnpj", "cnpj_cei")))
  
  print(str(df))
}
rm(df)
gc()

###################################
#Clean datasets
###################################

for (y in c(initial_year:final_year)){
  b = Sys.time()
  #Open file and filter individuals who were working in December
  year = substr(y, 3,4)
  filename = paste0("RAIS_hd_",year,".dta")
  df = read_dta(filename)
  rm(filename)
  
  #create year column
  df = df %>% mutate(ano = y)
  
  #convert active to integer
  df = df %>% mutate(active = as.integer(active))
  
  #convert cpf and cnpj to numeric
  df = df %>% 
    mutate(across(c("cpf", "cnpj_cei", "cnpj"), as.numeric))
  
  #print total formal workers in that year
  n_workers = df %>% filter(active == 1) %>% count() %>% pull()
  print(paste0("Formal Workers in ", y, ": ", n_workers))
  
  #Fix sex
  df = df %>% 
    mutate(sex = as.character(sex),
           sex = case_when(sex == "MASCULINO" ~ 1,
                           sex == "1" ~ 1,
                           sex == "01" ~ 1,
                           sex == "FEMININO" ~ 0,
                           sex == "2" ~ 0,
                           sex == "02" ~ 0,
                           T ~ NA),
           sex = as.integer(sex))
  
  #fix earnings
  df = df %>% 
    mutate(wage_mean_nom = as.character(wage_mean_nom),
           wage_mean_nom = str_replace(wage_mean_nom,
                                       "[,]", "."),
           wage_mean_nom = as.numeric(wage_mean_nom))
  
  #create real earnings
  df = df %>% 
    left_join(df_br, by = "ano", na_matches = "never") %>% 
    mutate(real_earnings = wage_mean_nom * deflator) %>% 
    select(-c("wage_mean_nom", "deflator"))
  
  #convert some variables to integer
  df= df %>% 
    mutate(across(c("emp_type", "quit_reason", "wk_hours"), 
                  as.integer))
  
  #Fix emp Time
  df = df %>% 
    mutate(emp_time = as.character(emp_time),
           emp_time = str_replace(emp_time,
                                  "[,]", "."),
           emp_time = as.numeric(emp_time))
  
  #Confirm if cnae has the correct number of digits
  df = df %>% 
    mutate(cnae_95 = as.character(cnae_95),
           nc_cnae = nchar(cnae_95),
           cnae_95 = case_when(nc_cnae == 5 ~ cnae_95,
                               nc_cnae == 4 ~ paste0("0", cnae_95),
                               T ~ cnae_95),
    )
  
  #convert munic to numeric
  df = df %>% 
    mutate(munic = as.numeric(munic))
  
  #fix educ column name
  if(("educ_85" %in% colnames(df)) & !("educ" %in% colnames(df))){
    df = df %>% 
      rename(educ = educ_85)
  }
  
  df = df %>% mutate(educ = as.integer(educ))
  
  #For years we dont have age, but do have born_date, calculate age
  if(!("age" %in% colnames(df)) & ("born_date" %in% colnames(df))){
    df = df %>%
      mutate(born_date = as.character(born_date),
             nc = nchar(born_date),
             born_date = case_when(nc == 8 ~ born_date,
                                   nc == 7 ~paste0(0,born_date),
                                   T ~ NA_character_),
             born_date = as.Date(born_date, format = "%d%m%Y")) 
    
    date_comparison = as.Date(paste0("3112",y), format = "%d%m%Y")
    
    df = df %>%
      mutate(age = as.integer(floor(date_comparison - born_date)/365))
  }
  
  #In 2011 and 2012, we dont have info on neither age nor born date,
  #lets inpute age based on previous years (since we look at individuals with
  #at least 3 years of tenure, this shouldn't be a problem)
  
  if(!("age" %in% colnames(df)) & !("born_date" %in% colnames(df))){
    #placeholder
    df = df %>% mutate(age = NA_integer_)
    
    #get info from previous years
    for (rel_data in (1:3)){
      rel_year = y - rel_data
      filename = paste0("rais_clean_", rel_year, ".parquet")
      sub_df = read_parquet(filename)
      sub_df = sub_df %>% 
        select(cpf, age) %>% 
        mutate(age = age + rel_data)
      
      suffix_aux = paste0("_", rel_data)
      
      #merge
      df = df %>% 
        left_join(sub_df, by = c("cpf"), suffix = c("", suffix_aux))
      
      rm(rel_year, filename, sub_df, suffix_aux)
    }
    
    #Take the mean of ages we've found
    df = df %>% 
      mutate(age_t = rowMeans(select(df, c(age_1, age_2, age_3)), na.rm = T),
             age = ifelse(is.nan(age_t), NA_real_, age_t),
             age = round(age)) %>% 
      select(-c("age_1", "age_2", "age_3"))
  }
  
  #convert age to integer
  df = df %>% mutate(age = as.integer(age))
  
  #FIX CBO
  df = df %>% 
    mutate(cbo_02 = as.character(cbo_02),
           cbo_02 = str_replace_all(cbo_02, "CBO", ""),
           cbo_02 = str_replace_all(cbo_02, " ", ""),
           nc_cbo = nchar(cbo_02),
           cbo_02 = case_when(nc_cbo == 6 ~ cbo_02,
                              nc_cbo == 5 ~ paste0(0, cbo_02),
                              T ~cbo_02),
    ) %>% 
    select(-c(nc_cbo))
  
  #convert legal nature to integer
  df = df %>% mutate(legal_nature = as.integer(legal_nature))
  
  #get hire year (in 2011, dates are in reverse order)
  if (y != 2011){
    df = df %>% 
      mutate(hire_month = as.character(hire_month),
             nc = nchar(hire_month),
             hire_month = case_when(nc == 8 ~ hire_month,
                                    nc == 7 ~paste0(0,hire_month),
                                    T ~ NA_character_),
             hire_month = as.Date(hire_month, format = "%d%m%Y"),
             hire_year = format(hire_month, "%Y"),
             hire_year = as.integer(hire_year)) %>% 
      select(-c("hire_month", "nc"))
    
  } else{
    df = df %>% 
      mutate(hire_month = as.character(hire_month),
             hire_year = substr(hire_month, 1, 4),
             hire_year = as.integer(hire_year)) %>% 
      select(-c("hire_month"))
  }
  
  #select only columns we need
  columns_to_keep = c("cpf", "ano", "cnpj_cei", "cnpj", "active", "sex",
                      "real_earnings", "emp_type", "quit_reason", "wk_hours", 
                      "emp_time","cnae_95", "munic", "educ", "age", 
                      "cbo_02","legal_nature", "hire_month")
  
  df = df %>% 
    select(all_of(columns_to_keep)) %>% 
    rename(year = ano)
  
  #Save
  filename = paste0("rais_clean_", y, ".parquet")
  write_parquet(df, filename)
  
  c = Sys.time()
  message = paste0("Time to clean ", y, " dataset: ",
                   round(difftime(c, b, unit = "mins")), " minutes")
  print(message)
  print(summary(df))
  
  rm(df)
  gc()
  
}

c = Sys.time()
message = paste0("Time to clean all dataset: ",
                 round(difftime(c, a, unit = "hours"),1), " hours")
print(message)


