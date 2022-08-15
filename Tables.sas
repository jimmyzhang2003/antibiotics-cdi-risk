/* Tables.sas
Summary: generating tables for paper
Created by: Jimmy Zhang @ 5/17/22
Modified by: Jimmy Zhang @ 7/26/22 
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/*For tables, use mine.exposures_final */

/* TABLE 1: Cohort Characteristics/Descriptive Table of Exposures*/
proc surveyfreq data=mine.exposures_final;
	tables CDI_FLAG * (AGEGRP SEX CCI_CAT REGION PRIOR_HOSPITALIZATION ADD_ABX_CAT) ;
run;

/* TABLE 2: Prevalence and Incidence of CDiff Across Antibiotic Classes */
proc surveyfreq data=mine.exposures_final;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

/* TABLE 3: Odds Ratios of CDiff Across Antibiotic Classes*/
*taken from logistic regression output;

/* TABLE 4: Prevalence and Incidence of CDiff Across Antibiotic Classes (Highest Risk Group)*/
proc sql;
	CREATE TABLE mine.high_risk_cohort AS
	SELECT * FROM mine.exposures_final
	WHERE AGEGRP = '6' AND (CCI_CAT = '3+' OR PRIOR_HOSPITALIZATION = 1);
quit;

proc surveyfreq data=mine.high_risk_cohort;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

*----------------------------------------------------------------------------------------------;

/* SUPP TABLE 1: Final Multivariable Model */
*taken from logistic regression output;

/* SUPP TABLE 2: Odds Ratios of CDiff (No Additional Antibiotics)*/
proc sql;
	CREATE TABLE mine.exposures_final_only_one_abx AS
	SELECT * FROM mine.exposures_final
	WHERE ADD_ABX_CAT CONTAINS '0';
quit;

proc surveyfreq data=mine.exposures_final_only_one_abx;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

/* SUPP TABLE 3: Odds Ratios of CDiff (Highest Risk Group) */
*taken from logistic regression output;