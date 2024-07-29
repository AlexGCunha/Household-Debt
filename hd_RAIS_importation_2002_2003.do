/*

This Do file will download  RAIS data from TERADATA for 2002

*/


set more off, perm

*****2002 - mudança importante, checar cbo e grau instrucao e salario minomo em dezembro

clear
#delimit ;

local sql_statement
SELECT [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCL] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO] as cbo_94
,[GRAU INSTR] as educ_85
,[SEXO] as sex
,[DT ADMISSAO] as hire_month
,[TEMP EMPR] as emp_time
,[PIS] as pis
,[RADIC CNPJ] as cnpj
,[DT NASCIMENT] as born_date
,[CLAS CNAE 95] as cnae_95
,[REM DEZEMBRO] as wage_dec_sm
,[REM DEZ (R$)] as wage_dec_nom
,[HORAS CONTR] as wk_hours
,[CPF] as cpf
FROM [Depep].[dbo].[RAIS2002]
WHERE [TP VINCL] IN ('CLT R/PJ IND', 'CLT R/PF IND', 'CLT U/PJ IND', 'CLT U/PF IND', 'APREND CONTR', 'DIRETOR', 'AVULSO') 

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep02$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_02.dta", replace


*****2003

clear
#delimit ;

local sql_statement
SELECT [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GRAU INSTR] as educ_85
,[SEXO] as sex
,[RACA_COR] as color
,[DT ADMISSAO] as hire_month
,[TEMP EMPR] as emp_time
,[PIS] as pis
,[RADIC CNPJ] as cnpj
,[DT NASCIMENT] as born_date
,[CLAS CNAE 95] as cnae_95
,[REM DEZEMBRO] as wage_dec_sm
,[REM DEZ (R$)] as wage_dec_nom
,[HORAS CONTR] as wk_hours
,[CPF] as cpf
,[OCUP 2002] as cbo_02
FROM [Depep].[dbo].[RAIS2003]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') 

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep02$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_03.dta", replace