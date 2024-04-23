/*

hd_import_SCR.do

This file will download SCR debt data at the individual level

*/


* First, lets look at all kinds of debt and sum then up
set more off, perm

clear
#delimit ;

local sql_statement

SELECT 
  tableLoans.MEE_CD_MES as time_id,
  tableLoans.CLI_CD as cpf,
  SUM(tableLoans.FOC_VL_CARTEIRA_ATIVA) as loan_outstanding,
  SUM(tableLoans.FOC_VL_CONTRATADO) as contract_value
FROM 
  SCRDWPRO_ACC.SCRTB_FOC_FATO_OPERACAO_CREDITO tableLoans
WHERE 
  tableLoans.TPC_CD = 1 AND
  tableLoans.MEE_CD_MES > 199501 AND
  RIGHT(LTRIM(RTRIM(tableLoans.CLI_CD)),2)= '12'
GROUP BY 
  tableLoans.MEE_CD_MES, 
  tableLoans.CLI_CD
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\hd_SCR_indivudal.dta", replace


* Now, only at some loans and financing
set more off, perm

clear
#delimit ;

local sql_statement

SELECT 
  tableLoans.MEE_CD_MES as time_id,
  tableLoans.CLI_CD as cpf,
  SUM(tableLoans.FOC_VL_CARTEIRA_ATIVA) as loan_outstanding,
  SUM(tableLoans.FOC_VL_CONTRATADO) as contract_value
FROM 
  SCRDWPRO_ACC.SCRTB_FOC_FATO_OPERACAO_CREDITO tableLoans
WHERE 
  tableLoans.TPC_CD = 1 AND
  ((tableLoans.DMO_CD BETWEEN 200 AND 299) OR
  (tableLoans.DMO_CD BETWEEN 400 AND 499)) AND
  tableLoans.MEE_CD_MES > 199501 AND
  RIGHT(LTRIM(RTRIM(tableLoans.CLI_CD)),2)= '12'
GROUP BY 
  tableLoans.MEE_CD_MES, 
  tableLoans.CLI_CD
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\hd_SCR_indivudal_loans.dta", replace


* Download CPF to PIS data
set more off, perm

clear
#delimit ;

local sql_statement
SELECT 
  CPF_CD,
  MAX(FCP_PIS) AS FCP_PIS
FROM 
  MTDWPRO_ACC.EMTTB_FCP_FATO_CPF_PIS
WHERE
  RIGHT(LTRIM(RTRIM(CPF_CD)),2) = '12'
GROUP BY 
  CPF_CD
;
#delimit cr
display in smcl as text "`sql_statement'"
odbc load, exec("`sql_statement';") dsn("Teradata Sede")
save "\\sbcdf060\depep01$\Bernardus\Cunha_Santos_Doornik\Dta_files\hd_cpf_to_pis.dta", replace
