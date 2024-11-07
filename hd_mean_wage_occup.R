#------------------------------------------------------------------------------------------------
#This code will work on 2000 census database to create
#mean wages by occupation
#------------------------------------------------------------------------------------------------


library(tidyverse)
library(haven)
library(readxl)
library(arrow)
library(beepr)

data_path = paste0("C:/Users/xande/OneDrive/Documentos/Doutorado/Research/", 
                   "Graduating in a recession/Empirico/Tentativa Censo/Data/")

filename = (paste0(data_path, "census_00_pes_ibge.parquet"))
df<- read_parquet(filename)
gc()


############################################################
#Define PEA
############################################################
df<- df %>% 
  #Employed will be individuals who worked even if they did not receive in the ref week
  mutate(employed = ifelse(worked_ref_week==1|npaid1==1|npaid2==1|npaid3==1|
                             npaid4==1,1,0)) %>% 
  #filter employed
  filter(employed == 1)

#dfine 2-digits occupation
df = df %>% 
  mutate(nc_occup = nchar(as.character(occupation)),
         occup = case_when(nc_occup == 3 ~ paste0("0", occupation),
                           nc_occup == 4 ~ as.character(occupation),
                           T ~NA),
         occup = substr(occup, 1,2))

#define mean wages
df = df %>% 
  filter(!is.na(inc_main_job), !is.na(occup)) %>% 
  group_by(occup) %>% 
  summarise(mean_occup_wage = weighted.mean(inc_main_job, weight= weight)) %>% 
  ungroup()

#save
write_parquet(df, "../Data/wage_cbo_2_digits.parquet")


