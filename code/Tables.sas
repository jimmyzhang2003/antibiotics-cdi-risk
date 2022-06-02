/* Tables.sas
Summary: generating tables for paper
Created by: Jimmy Zhang @ 5/17/22
Modified by: Jimmy Zhang @ 5/28/22 
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*change work directory to ensure enough space;
data _null_; 
	rc=dlgcdir("G:\def2004/temp");
	put rc=;
run;

/*For all tables, use mine.exposures_all_sampled (final dataset sampled down to 20 million) */

/* TABLE 1: Cohort Characteristics/Descriptive Table of Exposures*/
proc surveyfreq data=mine.exposures_all_sampled;
	tables CDI_FLAG * (AGEGRP SEX CCI_CAT REGION PRIOR_HOSPITALIZATION) ;
run;

/* TABLE 2: Prevalence and Incidence of CDiff Across Antibiotic Classes */
proc surveyfreq data=mine.exposures_all_sampled;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

/* TABLE 3: Odds Ratios of CDiff Across Antibiotic Classes*/
*taken from logistic regression output;

/* TABLE 4: Prevalence and Incidence of CDiff Across Antibiotic Classes (Age > 65) */
proc sql;
	CREATE TABLE mine.exposures_mdcr_sampled AS
	SELECT * FROM mine.exposures_all_sampled
	WHERE AGEGRP = '6';
quit;

proc surveyfreq data=mine.exposures_mdcr_sampled;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

/* SUPP TABLE 1: Prevalence and Incidence of CDiff Across Antibiotic Classes (Highest Risk Group)*/
proc sql;
	CREATE TABLE mine.high_risk_cohort AS
	SELECT * FROM mine.exposures_all_sampled
	WHERE AGEGRP = '6' AND PRIOR_HOSPITALIZATION = 1 AND CCI_CAT = '3+';
quit;

proc surveyfreq data=mine.high_risk_cohort;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;

/* SUPP TABLE 2: Prevalence and Incidence of CDiff Across Antibiotic Classes (Lowest Risk Group)*/
*for some reason, CCI_CAT cannot match to just '0';
proc sql;
	CREATE TABLE mine.low_risk_cohort AS
	SELECT * FROM mine.exposures_all_sampled
	WHERE AGEGRP <> '6' AND PRIOR_HOSPITALIZATION = 0 AND CCI_CAT CONTAINS'0';
quit;

proc surveyfreq data=mine.low_risk_cohort;
	tables CDI_FLAG * DRUGNAME / row nowt wchisq;
run;