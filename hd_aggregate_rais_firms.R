#------------------------------------------------------------------------------------------------------------------------------
#This code will:
#- Aggregate employment per firm data downloaded from RAIS TERADATA
#- Define, for each company, if it had a mass layoff in the oberseverd years
#- These data were downloaded with the hd_RAIS_importation_companies file
#------------------------------------------------------------------------------------------------------------------------------


options(file.download.method="wininet")

if (!require("dplyr")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("haven")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("arrow")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("stringr")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("tibble")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("tidyr")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("ggplot2")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("readr")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")
if (!require("purrr")) install.packages("splitstackshape", repos="http://artifactory.bcnet.bcb.gov.br/artifactory/cran-remote/")

data_path = "Z:/Bernardus/Cunha_Santos_Doornik/Dta_files"
output_path = "Z:/Bernardus/Cunha_Santos_Doornik/Output_check"
scr_path = "Z:/DATA/Dta_files/SCR_TERADATA"

a = Sys.time()
#Parameters
initial_year = 1994
final_year = 2021
cutoff = -0.3

#Loop through RAIS files and aggregate
aux_count = 0
for (i in 1994:2021){
  setwd(data_path)
  year = substr(i,3,4)
  filename = paste0("RAIS_firm_",i,".dta")
  
  df_aux = read_stata(filename) %>% 
    mutate(ano = i)
  
  #Aggregate
  if (aux_count == 0){
    df = df_aux
    aux_count = 1
  } else{ 
    df = rbind(df, df_aux)
  }
  
}


##################################
#Add variation in employment per firm and year
##################################
colnames(df) = c("cnpj", "n_empregados_ano", "ano")
#list of unique cnpjs
cnpjs = unique(df$cnpj)

df_aux = expand_grid(cnpj = cnpjs, ano = initial_year: final_year)

df_aux = df_aux %>% 
  left_join(df, by = c("cnpj", "ano")) %>% 
  mutate(n_empregados_ano = ifelse(is.na(n_empregados_ano),0, n_empregados_ano))

#Define percentual change in # of employees for each firm per year
df_aux = df_aux %>% 
  group_by(cnpj) %>% 
  arrange(cnpj, ano) %>% 
  mutate(dif_percentual_empregados = case_when(lag(n_empregados_ano)==0 ~NA_real_,
                                               T ~ (n_empregados_ano/lag(n_empregados_ano))-1)) %>% 
  ungroup()

df_aux = df_aux %>% 
  mutate(demissao_massa = ifelse(dif_percentual_empregados <= cutoff,1,0)) %>% 
  select(!dif_percentual_empregados)


#save
write_parquet(df_aux, "firm_employment_panel.parquet")

b = Sys.time()
print(b-a)

rm(list = ls())

Sys.sleep(60)
gc()





