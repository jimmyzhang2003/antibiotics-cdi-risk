/* Logistic_Regression.sas
Summary: logistic regression analysis
Created by: Jimmy Zhang @ 1/10/22
Modified by: Jimmy Zhang @ 5/4/22
*/

/* LOGISTIC REGRESSION*/
*first, do a simple random sample down to 20 million patients;
proc surveyselect data=mine.exposures_all_final_combined method=srs 
				  n=20000000 seed=42 out=mine.exposures_all_sampled;
run;

*unadjusted logistic regression model;
proc logistic data=mine.exposures_all_sampled plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;


*adjusted logistic regression model;
proc logistic data=mine.exposures_all_sampled plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT;
run;

*year-by-year logistic regression model;
%run_log_reg(data=mine.exposures_all_sampled, year=2008);
%run_log_reg(data=mine.exposures_all_sampled, year=2009);
%run_log_reg(data=mine.exposures_all_sampled, year=2010);
%run_log_reg(data=mine.exposures_all_sampled, year=2011);
%run_log_reg(data=mine.exposures_all_sampled, year=2012);
%run_log_reg(data=mine.exposures_all_sampled, year=2013);
%run_log_reg(data=mine.exposures_all_sampled, year=2014);
%run_log_reg(data=mine.exposures_all_sampled, year=2015);
%run_log_reg(data=mine.exposures_all_sampled, year=2016);
%run_log_reg(data=mine.exposures_all_sampled, year=2017);
%run_log_reg(data=mine.exposures_all_sampled, year=2018);
%run_log_reg(data=mine.exposures_all_sampled, year=2019);
%run_log_reg(data=mine.exposures_all_sampled, year=2020);