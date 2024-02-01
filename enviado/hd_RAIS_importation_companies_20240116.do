/*

 

00_SCR_importation_teradata_yyyymmdd

 
This Do file will download  RAIS data from TERADATA from 1992 to 2018, but just
a small subset of columns that we will need to define companies that had mass layoffs

*/


set more off, perm
*****1994

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS1994]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_94.dta", replace



*****1995

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS1995]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_95.dta", replace



*****1996

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS1996]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_96.dta", replace



*****1997

clear
#delimit ;

local sql_statement
SELECT SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]

FROM [Depep].[dbo].[RAIS1997]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_97.dta", replace



*****1998

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS1998]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_98.dta", replace



*****1999

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS1999]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_99.dta", replace



*****2000

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2000]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_00.dta", replace



*****2001

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2001]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_01.dta", replace



*****2002 - mudança importante, checar cbo e grau instrucao e salario minomo em dezembro

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2002]
WHERE [TP VINCL] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_02.dta", replace



*****2003

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2003]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_03.dta", replace



*****2004

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2004]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_04.dta", replace



*****2005 - confirmar sexo e educacao

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_05.dta", replace



*****2006 - conferir educacao tb

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2006]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_06.dta", replace



*****2007 - conferir educacao de novo

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2007]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80') AND
[EMP EM 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_07.dta", replace



*****2008

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2008]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[EMP EM 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_08.dta", replace



*****2009 - conferir educ novamente

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2009]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[EMP EM 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_09.dta", replace



*****2010 - nao tem pis

clear
#delimit ;

local sql_statement
SELECT [RADIC CNPJ] as cnpj
,COUNT([RADIC CNPJ]) as n_employees
GROUP BY [RADIC CNPJ]
FROM [Depep].[dbo].[RAIS2010]
WHERE [TP VINCULO] IN ('10', '15', '20', '25', '40', '55', '80')
 AND
[EMP EM 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_10.dta", replace



*****2011 - NAO TEM DATA DE NASCIMENTO

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2011]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1


;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_11.dta", replace



*****2012

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2012]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_12.dta", replace



*****2013 - voltou idade

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2013]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_13.dta", replace



*****2014 - voltou dia de nascimento

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2014]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_14.dta", replace



*****2015

clear
#delimit ;

local sql_statement
SELECT [CNPJ Raiz] as cnpj
,COUNT([CNPJ Raiz]) as n_employees
GROUP BY [CNPJ Raiz]
FROM [Depep].[dbo].[RAIS2015]
WHERE [Tipo Vínculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[Vínculo Ativo 31 12] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_15.dta", replace



*****2016

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]
FROM [Depep].[dbo].[RAIS2016]
WHERE [tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_16.dta", replace



*****2017

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]
FROM [Depep].[dbo].[RAIS2017]
WHERE [tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_17.dta", replace



*****2018

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]
FROM [Depep].[dbo].[RAIS2018]
WHERE [tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_18.dta", replace



*****2019

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]
FROM [Depep].[dbo].[RAIS2019]
WHERE [tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_19.dta", replace



*****2020

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]
FROM [Depep].[dbo].[RAIS2020]
WHERE 
[tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80')  AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_20.dta", replace



*****2021

clear
#delimit ;

local sql_statement
SELECT [cnpjraiz] as cnpj
,COUNT([cnpjraiz]) as n_employees
GROUP BY [cnpjraiz]

FROM [Depep].[dbo].[RAIS2021]
WHERE [tipovinculo] IN ('10', '15', '20', '25', '40', '55', '80') AND
[vinculoativo3112] = 1

;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Depep")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\RAIS_firm_21.dta", replace
