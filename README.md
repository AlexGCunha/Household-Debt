# **Codes for Household debt project**
**Please, do not cite. This project is not yet over. We remain to finish the dataset creation and run regressions.**

The main goal of this project is to analyse the heterogeneous effect of job dipslacement (through a mass layoff) on carrer outcomes for people with distinct levels of debt before layoff.
That is, we expect that individuals with higher debt levels will be in more need to find a new (formal) job quickly, independetly if the job is the best one she could get or not. On the other hand, non-finacially distressed individuals could wait a bit longer and maybe are reemployed in better jobs after layoff.

In order to do that, we will use two main datasets: RAIS and SCR. Rais contains detailed information on every formal employment in Brazil, identified at the individual and firm level. Information in Rais comprisses date of hiring/layoff, wages in December, layoff reason, hours worked, employmnet type (if it is private/ public employmnet, or even if ac ontract with fixed length). The data is annual, and since it is identified, we are able to follow the (formal) carrer trajectory of individuals across the years. SCR, on the other hand, contains detailed information of all loans conceded by Brazilian banks, identified at the individual level. 

Note that all this data is confidential. Since only one of the authors have access to it, we can present only the codes:

* hd_RAIS_importation.do: Download RAIS data with an ODBC connection to SQL Server (1 archive per year).

* hd_import_SCR.do: Download SCR data with an ODBC connection to SQL Server. One archive for year and for loan type (all kinds of loans/normal loans and financing), grouped by individual and year.

* hd_compat_rais_v2.R: Rais data downloaded is not compatible across the years, this code cleans the data, extract just the information we want, create new columns and make everything compatible across files.

* hd_create_fake_sample_local.R: All these codes are not run in my personal machine, they are run on one of the authors machine (the one with access to the data). But since one code needs the output of the others, I need to create a local fake dataset to test whether the codes are working properly or not. This code does that.

* hd_clean_rais_companies.R: create a panel with employment at the firm level, defining if there was a mass-layoff or not in the following year, but just for private firms and full-time private employees.

* hd_define_potential_sample.R: Opens RAIS yearly files and define treated individuals: the ones who were laid-off without a cause in a mass-layoff. Also, define potential controls.

* hd_define_final_sample_match.R: match treated individuals to very similar control ones using exact matching.

* hd_create_main_dataset.R: for matched individuals, create an employment panel with informations we want.

* hd_regressions.R: run regressions



