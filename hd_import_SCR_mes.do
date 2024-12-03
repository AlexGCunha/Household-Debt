/*

hd_import_SCR.do

This file will download SCR debt data at the individual level per month

*/


* First, lets look at all kinds of debt and sum then up
set more off, perm

forvalues year = 2006/2015{
local file_dates 12 
foreach x of local file_dates {

clear

#delimit ;

local sql_statement

SELECT 
  tableLoans.MEE_CD_MES as time_id,
  tableLoans.CLI_CD as cpf,
  SUM(tableLoans.FOC_VL_CARTEIRA_ATIVA) as loan_outstanding
FROM 
  SCRDWPRO_ACC.SCRTB_FOC_FATO_OPERACAO_CREDITO tableLoans
WHERE 
  tableLoans.TPC_CD = 1 AND
  tableLoans.MEE_CD_MES =`year'`x'
GROUP BY 
  tableLoans.MEE_CD_MES, 
  tableLoans.CLI_CD
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep02$\Bernardus\Cunha_Santos_Doornik\Dta_files\hd_SCR_indivudal_`year'`x'.dta", replace

}
}



* Now, only at some loans and financing
set more off, perm

forvalues year = 2006/2015{
local file_dates 12 
foreach x of local file_dates {

clear

#delimit ;

local sql_statement

SELECT 
  tableLoans.MEE_CD_MES as time_id,
  tableLoans.CLI_CD as cpf,
  SUM(tableLoans.FOC_VL_CARTEIRA_ATIVA) as loan_outstanding
FROM 
  SCRDWPRO_ACC.SCRTB_FOC_FATO_OPERACAO_CREDITO tableLoans
WHERE 
  tableLoans.TPC_CD = 1 AND
  ((tableLoans.DMO_CD BETWEEN 200 AND 299) OR
  (tableLoans.DMO_CD BETWEEN 400 AND 499)) AND
  tableLoans.MEE_CD_MES = `year'`x'
GROUP BY 
  tableLoans.MEE_CD_MES, 
  tableLoans.CLI_CD
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep02$\Bernardus\Cunha_Santos_Doornik\Dta_files\hd_SCR_indivudal_loans_`year'`x'.dta", replace

}
}


