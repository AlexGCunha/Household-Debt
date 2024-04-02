/*

This Do file will download  RAIS data from TERADATA for 2002

*/


set more off, perm

*****2002 - download data for companies

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
FROM [Depep].[dbo].[RAIS2002]
WHERE [TP VINCL] IN ('CLT R/PJ IND', 'CLT R/PF IND', 'CLT U/PJ IND', 'CLT U/PF IND', 'APREND CONTR', 'DIRETOR', 'AVULSO') 
AND RTRIM(LTRIM([EMP EM 31 12])) = '1'
GROUP BY [RADIC CNPJ]
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_02.dta", replace


*****2002 - download overall data

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
WHERE [TP VINCL] IN ('CLT R/PJ IND', 'CLT R/PF IND', 'CLT U/PJ IND', 'CLT U/PF IND', 'APREND CONTR', 'DIRETOR', 'AVULSO') AND
RIGHT([PIS],2)= '12'

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_02.dta", replace


