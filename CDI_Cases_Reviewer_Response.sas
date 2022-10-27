/* CDI_Cases_Reviewer_Response.sas
Summary: additional analysis on CDI case inclusion/exclusion (response to reviewer)
Created by: Jimmy Zhang @ 10/11/22
Modified by: Jimmy Zhang @ 10/14/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/* MARK PATIENTS WITH PRIMARY INPATIENT DIAGNOSIS OF CDI AS CA-CDI */

data mine.cdi_inpatient_diagnoses;
	set ccae.ccaei083 ccae.ccaei093 ccae.ccaei103 ccae.ccaei113 ccae.ccaei123 ccae.ccaei133
		ccae.ccaei143 ccae.ccaei153 ccae.ccaei162 ccae.ccaei171 ccae.ccaei181 ccae.ccaei191
		ccae.ccaei201 mdcr.mdcri083 mdcr.mdcri093 mdcr.mdcri103 mdcr.mdcri113 mdcr.mdcri123 
		mdcr.mdcri133 mdcr.mdcri143 mdcr.mdcri153 mdcr.mdcri162 mdcr.mdcri171 mdcr.mdcri181 
		mdcr.mdcri191 mdcr.mdcri201;
	if ENROLID = . or AGE < 18 then delete;
	*check if patient received one of the ICD9 or 10 codes for CDI as primary diagnosis;
	if DX1 in ('00845', 'A047', 'A0471', 'A0472') then CDI_FLAG=1;
	if CDI_FLAG = 1;
	keep ENROLID ADMDATE DX1;
run;

*check if there is an outcome drug prescription within 2 weeks of inpatient CDI diagnosis;
proc sql;
	CREATE TABLE mine.all_cdi_inpatient_outcomes AS
	SELECT cdi_inpatient_diagnoses.*, outcomes_all.DRUGNAME, outcomes_all_.SVCDATE AS OUTCOME_DRUG_SVCDATE
	FROM mine.cdi_inpatient_diagnoses INNER JOIN mine.outcomes_all
	ON cdi_inpatient_diagnoses.ENROLID = outcomes_all.ENROLID
		AND outcomes_all.SVCDATE >= cdi_inpatient_diagnoses.ADMDATE - 14 
		AND outcomes_all.SVCDATE <= cdi_inpatient_diagnoses.ADMDATE + 14;
quit;

proc sort data=mine.all_cdi_inpatient_outcomes nodupkey;
	by ENROLID ADMDATE;
run;

*create CDI FLAG variable;
data mine.exposures_with_inpatients;
	merge mine.exposures_final(in=a) mine.all_cdi_inpatient_outcomes(in=b keep=ENROLID ADMDATE rename=(ADMDATE=DIAGNOSISDATE));
	if a;
	by ENROLID;
	if DIAGNOSISDATE and SVCDATE >= DIAGNOSISDATE-90 and DIAGNOSISDATE >= SVCDATE then CDI_FLAG = 1;
run;

*only take the first diagnosis after antibiotic prescription;
proc sort data=mine.exposures_with_inpatients out=mine.exposures_with_inpatients;
	by ENROLID descending CDI_FLAG DIAGNOSISDATE;
run;

data mine.exposures_with_inpatients;
	set mine.exposures_with_inpatients;
	by ENROLID;
	if FIRST.ENROLID;
run;

*drop diagnosis date for patients without CDI_FLAG = 1;
data mine.exposures_with_inpatients;
	set mine.exposures_with_inpatients;
	if CDI_FLAG = 0 then DIAGNOSISDATE = .;
run;

*get number of CDI cases after including inpatient cases;
proc freq data=mine.exposures_with_inpatients;
	tables CDI_FLAG; *13,409 total cases;
run;

*unadjusted log reg;
proc logistic data=mine.exposures_with_inpatients plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

*adjusted logistic regression model after including inpatient cases;
proc logistic data=mine.exposures_with_inpatients plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0') ADD_ABX_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT ADD_ABX_CAT;
run;

*----------------------------------------------------------------------------------------------;

/* EXCLUDE PATIENTS WHO WERE HOSPITALIZED AFTER ANTIBIOTIC PRESCRIPTION AND BEFORE CDI DIAGNOSIS */
data mine.exposures_without_hosp_patients;
	merge mine.exposures_final(in=a) mine.inpatients_all(in=b);
	if a;
	by ENROLID;
	if CDI_FLAG=1 AND DISDATE < DIAGNOSISDATE AND DISDATE > SVCDATE then INPATIENT_CASE=1;
	else INPATIENT_CASE=0;
run;

proc sort data=mine.exposures_without_hosp_patients nodupkey;
	by ENROLID;
run;

proc sort data=mine.exposures_without_hosp_patients out=mine.exposures_with_inpatients;
	by ENROLID descending CDI_FLAG DIAGNOSISDATE;
run;

*mark patients who may have contracted CDI during hospital stay as CDI negative;
data mine.exposures_without_hosp_patients;
	set mine.exposures_without_hosp_patients;
	if INPATIENT_CASE = 1 then CDI_FLAG = 0;
run;

proc freq data=mine.exposures_without_hosp_patients;
	tables CDI_FLAG;
run;

*unadjusted log reg;
proc logistic data=mine.exposures_without_hosp_patients plots=oddsratio(logbase=10) descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

*adjusted log reg;
proc logistic data=mine.exposures_without_hosp_patients plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0') ADD_ABX_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT ADD_ABX_CAT;
run;

*high risk cohort;
proc sql;
	CREATE TABLE mine.exposures_without_hosp_high_risk AS
	SELECT * FROM mine.exposures_without_hosp_patients
	WHERE AGEGRP = '6' AND (CCI_CAT = '3+' OR PRIOR_HOSPITALIZATION = 1);
run;

proc logistic data=mine.exposures_without_hosp_high_risk plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0') ADD_ABX_CAT(param=ref ref='0');
	model CDI_FLAG = SEX REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT ADD_ABX_CAT;
run;