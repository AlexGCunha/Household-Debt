/*

 

00_SCR_importation_teradata_yyyymmdd

 
This Do file will download  RAIS data from TERADATA from 1992 to 2018, selecting just a subsection of columns
 

*/


*****1992
set more off, perm

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO Ocupação] as cbo
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[IBGE Atividade] as activity
,[Vl Remun Dezembro (SM)] as wage_dec_sm
FROM [Depep].[dbo].[RAIS1992]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_92.dta", replace


*****1993

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO Ocupação] as cbo
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[IBGE Atividade] as activity
,[Vl Remun Dezembro (SM)] as wage_dec_sm
FROM [Depep].[dbo].[RAIS1993]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_93.dta", replace


*****1994

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1994]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_94.dta", replace



*****1995

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1995]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_95.dta", replace



*****1996

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1996]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_96.dta", replace



*****1997

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1997]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_97.dta", replace



*****1998

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1998]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_98.dta", replace



*****1999

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS1999]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_99.dta", replace



*****2000

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS2000]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_00.dta", replace



*****2001

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Grau Instrução 2005-1985] as educ_85
,[Sexo Trabalhador] as sex
,[Mês Admissão] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[Idade] as age
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
FROM [Depep].[dbo].[RAIS2001]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_01.dta", replace



*****2002 - mudança importante, checar cbo e grau instrucao e salario minomo em dezembro

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
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

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_02.dta", replace



*****2003

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
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

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_03.dta", replace



*****2004

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
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
FROM [Depep].[dbo].[RAIS2004]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_04.dta", replace



*****2005 - confirmar sexo e educacao

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GRAU INSTR] as educ_85
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2005]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_05.dta", replace



*****2006 - conferir educacao tb

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GRAU INSTR] as educ
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2006]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_06.dta", replace



*****2007 - conferir educacao de novo

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GR INSTRUCAO] as educ
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2007]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_07.dta", replace



*****2008

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GRAU INSTR] as educ
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2008]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_08.dta", replace



*****2009 - conferir educ novamente

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GR INSTRUCAO] as educ
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2009]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_09.dta", replace



*****2010

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [MUNICIPIO] as munic
,[EMP EM 31 12] as active
,[TP VINCULO] as emp_type
,[CAUSA DESLI] as quit_reason
,[MES DESLIG] as quit_month
,[OCUPACAO 94] as cbo_94
,[GR INSTRUCAO] as educ
,[GENERO] as sex
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
FROM [Depep].[dbo].[RAIS2010]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_10.dta", replace



*****2011 - NAO TEM DATA DE NASCIMENTO

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Escolaridade após 2005] as educ
,[Sexo Trabalhador] as sex
,[Raça Cor] as color
,[Data Admissão Declarada] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
,[CPF] as cpf
,[CBO Ocupação 2002] as cbo_02
FROM [Depep].[dbo].[RAIS2011]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_11.dta", replace



*****2012

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Escolaridade após 2005] as educ
,[Sexo Trabalhador] as sex
,[Raça Cor] as color
,[Data Admissão Declarada] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
,[CPF] as cpf
,[CBO Ocupação 2002] as cbo_02
FROM [Depep].[dbo].[RAIS2012]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_12.dta", replace



*****2013 - voltou idade

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Escolaridade após 2005] as educ
,[Sexo Trabalhador] as sex
,[Raça Cor] as color
,[Data Admissão Declarada] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
,[CPF] as cpf
,[CBO Ocupação 2002] as cbo_02
,[idade] as age
FROM [Depep].[dbo].[RAIS2013]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_13.dta", replace



*****2014 - voltou dia de nascimento

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Escolaridade após 2005] as educ
,[Sexo Trabalhador] as sex
,[Raça Cor] as color
,[Data Admissão Declarada] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
,[CPF] as cpf
,[CBO Ocupação 2002] as cbo_02
,[idade] as age
,[Data de Nascimento] as born_date
FROM [Depep].[dbo].[RAIS2014]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_14.dta", replace



*****2015

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [Município] as munic
,[Vínculo Ativo 31 12] as active
,[Tipo Vínculo] as emp_type
,[Motivo Desligamento] as quit_reason
,[Mês Desligamento] as quit_month
,[CBO 94 Ocupação] as cbo_94
,[Escolaridade após 2005] as educ
,[Sexo Trabalhador] as sex
,[Raça Cor] as color
,[Data Admissão Declarada] as hire_month
,[Tempo Emprego] as emp_time
,[PIS] as pis
,[CNPJ Raiz] as cnpj
,[CNAE 95 Classe] as cnae_95
,[Vl Remun Dezembro (SM)] as wage_dec_sm
,[Vl Remun Dezembro Nom] as wage_dec_nom
,[Qtd Hora Contr] as wk_hours
,[CPF] as cpf
,[CBO Ocupação 2002] as cbo_02
,[Idade] as age
,[Data de Nascimento] as born_date
FROM [Depep].[dbo].[RAIS2015]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_15.dta", replace



*****2016

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2016]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_16.dta", replace



*****2017

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2017]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_17.dta", replace



*****2018

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2018]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_18.dta", replace



*****2019

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2019]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_19.dta", replace



*****2020

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2020]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_20.dta", replace



*****2021

clear
#delimit ;

local sql_statement
SELECT TOP (1000) [municipio] as munic
,[vinculoativo3112] as active
,[tipovinculo] as emp_type
,[motivodesligamento] as quit_reason
,[mesdesligamento] as quit_month
,[cbo94ocupacao] as cbo_94
,[escolaridadeapos2005] as educ
,[sexotrabalhador] as sex
,[racacor] as color
,[dataadmissaodeclarada] as hire_month
,[tempoemprego] as emp_time
,[pis] as pis
,[cnpjraiz] as cnpj
,[cnae95classe] as cnae_95
,[vlremundezembrosm] as wage_dec_sm
,[vlremundezembronom] as wage_dec_nom
,[qtdhoracontr] as wk_hours
,[cpf] as cpf
,[cboocupacao2002] as cbo_02
,[idade] as age
,[datadenascimento] as born_date
FROM [Depep].[dbo].[RAIS2021]

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_hd_21.dta", replace
