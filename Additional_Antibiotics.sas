/* Additional_Antibiotics.sas
Summary: accounting for additional antibiotics received 90 days within the first antibiotic prescription
Created by: Jimmy Zhang @ 7/20/22
Modified by: Jimmy Zhang @ 7/22/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/* combine each year's dataset into a combined dataset by joining and removing duplicates across years */
%join_sort_unique_patients(data1=mine.exposures_08_with_hosp_cci, data2=mine.exposures_09_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_10_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_11_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_12_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_13_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_14_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_15_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_16_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_17_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_18_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_19_with_hosp_cci, output=mine.exposures_all_combined);
%join_sort_unique_patients(data1=mine.exposures_all_combined, data2=mine.exposures_20_with_hosp_cci, output=mine.exposures_all_combined);

*create dataset of all exposures (non-unique patients);
data mine.exposures_all_non_unique;
    set mine.exposures_08 mine.exposures_09 mine.exposures_10 mine.exposures_11
        mine.exposures_12 mine.exposures_13 mine.exposures_14 mine.exposures_15
        mine.exposures_16 mine.exposures_17 mine.exposures_18 mine.exposures_19
        mine.exposures_20;
run;

*create dataset with patients who received additional antibiotics;
data mine.exposures_all_combined_with_add_abx;
	merge mine.exposures_all_combined(in=a) mine.exposures_all_non_unique(in=b rename=(SVCDATE=SVCDATE2 DRUGNAME=DRUGNAME2));
	if a and SVCDATE2 >= SVCDATE and SVCDATE2 <= min(SVCDATE+90, DIAGNOSISDATE) and DRUGNAME ^= DRUGNAME2; *check if additional antibiotics were prescribed within 90 days or before a CDI diagnosis, whichever occurred first;
	by ENROLID;
	drop SVCDATE2;
run;  

*drop duplicate rows;
proc sort data=mine.exposures_all_combined_with_add_abx nodupkey;
	by ENROLID;
run;

*create table of number of the count of additional unique drugs prescribed for each patient;
proc sql;
	CREATE TABLE mine.add_abx_count_table AS
	SELECT ENROLID, COUNT(DISTINCT(DRUGNAME2)) AS ADD_ABX 
	FROM mine.exposures_all_combined_with_add_abx
	GROUP BY ENROLID;
quit;

*merge with combined exposures dataset;
data mine.exposures_all_combined_with_add_abx_final;
	merge mine.exposures_all_combined(in=a) mine.add_abx_count_table(in=b);
	if a;
	by ENROLID;
run;
	
*convert missing values in additional antibiotics variable to zeroes;
data mine.exposures_final;
	set mine.exposures_all_combined_with_add_abx_final;
	ADD_ABX = coalesce(ADD_ABX, 0);
run;

*add a categorical variable for additional antibiotics with categories 0, 1, and 2+;
data mine.exposures_final;
	set mine.exposures_final;
	if ADD_ABX >= 2 then ADD_ABX_CAT = '2+';
	else ADD_ABX_CAT = ADD_ABX;
run;