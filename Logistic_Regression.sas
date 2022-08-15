/* Logistic_Regression.sas
Summary: logistic regression analysis
Created by: Jimmy Zhang @ 1/10/22
Modified by: Jimmy Zhang @ 7/26/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/* FULL COHORT */

*unadjusted logistic regression model;
proc logistic data=mine.exposures_final plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

*adjusted logistic regression model;
proc logistic data=mine.exposures_final plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0') ADD_ABX_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT ADD_ABX_CAT;
run;

*----------------------------------------------------------------------------------------------;

/* FULL COHORT RECEIVING ONLY 1 ANTIBIOTIC*/
*unadjusted logistic regression model;
proc logistic data=mine.exposures_final_only_one_abx plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

*adjusted logistic regression model;
proc logistic data=mine.exposures_final_only_one_abx plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT;
run;

*----------------------------------------------------------------------------------------------;

/* HIGH RISK COHORT */
*unadjusted logistic regression model;
proc logistic data=mine.high_risk_cohort plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

*adjusted logistic regression model;
proc logistic data=mine.high_risk_cohort plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0') ADD_ABX_CAT(param=ref ref='0');
	model CDI_FLAG = SEX REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT ADD_ABX_CAT;
run;