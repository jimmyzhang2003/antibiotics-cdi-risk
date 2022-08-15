/* Prior_Hospitalization.sas
Summary: creating variable for prior hospitalization
Created by: Jimmy Zhang @ 1/30/22
Modified by: Jimmy Zhang @ 5/5/22 
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/*CREATE VARIABLE FOR PRIOR HOSPITALIZATION WITHIN 90 DAYS OF PRESCRIPTION DATE */
*create inpatient dataset across all years;
data mine.inpatients_all;
	set ccae.CCAEI083 ccae.CCAEI093 ccae.CCAEI103 ccae.CCAEI113 ccae.CCAEI123 ccae.CCAEI133 
		ccae.CCAEI143 ccae.CCAEI153 ccae.CCAEI162 ccae.CCAEI171 ccae.CCAEI181 ccae.CCAEI191
		ccae.CCAEI201
        mdcr.mdcri083 mdcr.mdcri093 mdcr.mdcri103 mdcr.mdcri113 mdcr.mdcri123 mdcr.mdcri133 
		mdcr.mdcri143 mdcr.mdcri153 mdcr.mdcri162 mdcr.mdcri171 mdcr.mdcri181 mdcr.mdcri191 
		mdcr.mdcri201;
	keep ENROLID DISDATE; *include discharge date;
	if missing(ENROLID) or AGE < 18
		then delete;
run;

%let inpatients = mine.inpatients_all;

%add_hospitalization(exposures=mine.exposures_08_cont_enrolled, inpatients=&inpatients, output=mine.exposures_08_with_hosp);
%add_hospitalization(exposures=mine.exposures_09_cont_enrolled, inpatients=&inpatients, output=mine.exposures_09_with_hosp);
%add_hospitalization(exposures=mine.exposures_10_cont_enrolled, inpatients=&inpatients, output=mine.exposures_10_with_hosp);
%add_hospitalization(exposures=mine.exposures_11_cont_enrolled, inpatients=&inpatients, output=mine.exposures_11_with_hosp);
%add_hospitalization(exposures=mine.exposures_12_cont_enrolled, inpatients=&inpatients, output=mine.exposures_12_with_hosp);
%add_hospitalization(exposures=mine.exposures_13_cont_enrolled, inpatients=&inpatients, output=mine.exposures_13_with_hosp);
%add_hospitalization(exposures=mine.exposures_14_cont_enrolled, inpatients=&inpatients, output=mine.exposures_14_with_hosp);
%add_hospitalization(exposures=mine.exposures_15_cont_enrolled, inpatients=&inpatients, output=mine.exposures_15_with_hosp);
%add_hospitalization(exposures=mine.exposures_16_cont_enrolled, inpatients=&inpatients, output=mine.exposures_16_with_hosp);
%add_hospitalization(exposures=mine.exposures_17_cont_enrolled, inpatients=&inpatients, output=mine.exposures_17_with_hosp);
%add_hospitalization(exposures=mine.exposures_18_cont_enrolled, inpatients=&inpatients, output=mine.exposures_18_with_hosp);
%add_hospitalization(exposures=mine.exposures_19_cont_enrolled, inpatients=&inpatients, output=mine.exposures_19_with_hosp);
%add_hospitalization(exposures=mine.exposures_20_cont_enrolled, inpatients=&inpatients, output=mine.exposures_20_with_hosp);