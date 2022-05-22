/* Continuous_Enrollment.sas
Summary: merging the CCAE and MDCR data + checking for continuous enrollment
Created by: Jimmy Zhang @ 5/2/22
Modified by: Jimmy Zhang @ 5/2/22
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

*----------------------------------------------------------------------------------------------;

/* JOIN THE CCAE AND MDCR DATA + SORT BY ENROLID + GET UNIQUE PATIENTS */

*for joining AND sorting patients;
%join_sort_unique_patients(data1=mine.exposures_08_unique_complete, data2=mine.exposures_08_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_09_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_09_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_10_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_10_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_11_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_11_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_12_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_12_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_13_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_13_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_14_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_14_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_15_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_15_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_16_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_16_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_17_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_17_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_18_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_18_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_19_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_19_unique_mdcr, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_20_unique_complete, output=mine.exposures_all_combined_complete);
%join_sort_unique_patients(data1=mine.exposures_all_combined_complete, data2=mine.exposures_20_unique_mdcr, output=mine.exposures_all_combined_complete);

*----------------------------------------------------------------------------------------------;

/* CREATE CONTINUOUS ENROLLMENT DATASETS BY MERGING CCAE AND MDCR A TABLE DATA */

%merge_enrollment(enrollment1=ccae.ccaea083, enrollment2=mdcr.mdcra083, output=mine.full_enrollment_08);
%merge_enrollment(enrollment1=ccae.ccaea093, enrollment2=mdcr.mdcra093, output=mine.full_enrollment_09);
%merge_enrollment(enrollment1=ccae.ccaea103, enrollment2=mdcr.mdcra103, output=mine.full_enrollment_10);
%merge_enrollment(enrollment1=ccae.ccaea113, enrollment2=mdcr.mdcra113, output=mine.full_enrollment_11);
%merge_enrollment(enrollment1=ccae.ccaea123, enrollment2=mdcr.mdcra123, output=mine.full_enrollment_12);
%merge_enrollment(enrollment1=ccae.ccaea133, enrollment2=mdcr.mdcra133, output=mine.full_enrollment_13);
%merge_enrollment(enrollment1=ccae.ccaea143, enrollment2=mdcr.mdcra143, output=mine.full_enrollment_14);
%merge_enrollment(enrollment1=ccae.ccaea153, enrollment2=mdcr.mdcra153, output=mine.full_enrollment_15);
%merge_enrollment(enrollment1=ccae.ccaea162, enrollment2=mdcr.mdcra162, output=mine.full_enrollment_16);
%merge_enrollment(enrollment1=ccae.ccaea171, enrollment2=mdcr.mdcra171, output=mine.full_enrollment_17);
%merge_enrollment(enrollment1=ccae.ccaea181, enrollment2=mdcr.mdcra181, output=mine.full_enrollment_18);
%merge_enrollment(enrollment1=ccae.ccaea191, enrollment2=mdcr.mdcra191, output=mine.full_enrollment_19);
%merge_enrollment(enrollment1=ccae.ccaea201, enrollment2=mdcr.mdcra201, output=mine.full_enrollment_20);

/*LIMIT ANALYSIS TO ONLY PATIENTS WITH CONTINUOUS ENROLLMENT */
*2008;
data mine.exposures_08_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2008;
run;
%cont_enroll_prior_0(exposures=mine.exposures_08_unique_combined, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_08, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_09, output=mine.exposures_08_final_combined);

*2009;
data mine.exposures_09_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2009;
run;
%cont_enroll_prior_1(exposures=mine.exposures_09_unique_combined, enrollment=mine.full_enrollment_08, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_09, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_10, output=mine.exposures_09_final_combined);

*2010;
data mine.exposures_10_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2010;
run;
%cont_enroll_prior_1(exposures=mine.exposures_10_unique_combined, enrollment=mine.full_enrollment_09, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_10, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_11, output=mine.exposures_10_final_combined);

*2011;
data mine.exposures_11_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2011;
run;
%cont_enroll_prior_1(exposures=mine.exposures_11_unique_combined, enrollment=mine.full_enrollment_10, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_11, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_12, output=mine.exposures_11_final_combined);

*2012;
data mine.exposures_12_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2012;
run;
%cont_enroll_prior_1(exposures=mine.exposures_12_unique_combined, enrollment=mine.full_enrollment_11, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_12, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_13, output=mine.exposures_12_final_combined);

*2013;
data mine.exposures_13_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2013;
run;
%cont_enroll_prior_1(exposures=mine.exposures_13_unique_combined, enrollment=mine.full_enrollment_12, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_13, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_14, output=mine.exposures_13_final_combined);

*2014;
data mine.exposures_14_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2014;
run;
%cont_enroll_prior_1(exposures=mine.exposures_14_unique_combined, enrollment=mine.full_enrollment_13, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_14, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_15, output=mine.exposures_14_final_combined);

*2015;
data mine.exposures_15_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2015;
run;
%cont_enroll_prior_1(exposures=mine.exposures_15_unique_combined, enrollment=mine.full_enrollment_14, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_15, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_16, output=mine.exposures_15_final_combined);

*2016;
data mine.exposures_16_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2016;
run;
%cont_enroll_prior_1(exposures=mine.exposures_16_unique_combined, enrollment=mine.full_enrollment_15, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_16, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_17, output=mine.exposures_16_final_combined);

*2017;
data mine.exposures_17_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2017;
run;
%cont_enroll_prior_1(exposures=mine.exposures_17_unique_combined, enrollment=mine.full_enrollment_16, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_17, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_18, output=mine.exposures_17_final_combined);

*2018;
data mine.exposures_18_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2018;
run;
%cont_enroll_prior_1(exposures=mine.exposures_18_unique_combined, enrollment=mine.full_enrollment_17, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_18, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_19, output=mine.exposures_18_final_combined);

*2019;
data mine.exposures_19_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2019;
run;
%cont_enroll_prior_1(exposures=mine.exposures_19_unique_combined, enrollment=mine.full_enrollment_18, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_19, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_20, output=mine.exposures_19_final_combined);

*2020;
data mine.exposures_20_unique_combined;
	set mine.exposures_all_combined_complete;
	where YEAR = 2020;
run;
%cont_enroll_prior_1(exposures=mine.exposures_20_unique_combined, enrollment=mine.full_enrollment_19, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_20, output=tmp.out2);
%cont_enroll_after_0(exposures=tmp.out2, output=mine.exposures_20_final_combined);

*combine all final datasets;
data mine.exposures_all_final_combined;
	set mine.exposures_08_final_combined mine.exposures_09_final_combined mine.exposures_10_final_combined mine.exposures_11_final_combined
		mine.exposures_12_final_combined mine.exposures_13_final_combined mine.exposures_14_final_combined mine.exposures_15_final_combined
		mine.exposures_16_final_combined mine.exposures_17_final_combined mine.exposures_18_final_combined mine.exposures_19_final_combined
		mine.exposures_20_final_combined;
run;