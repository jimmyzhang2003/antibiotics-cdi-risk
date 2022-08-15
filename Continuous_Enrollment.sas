/* Continuous_Enrollment.sas
Summary: merging the CCAE and MDCR data + checking for continuous enrollment
Created by: Jimmy Zhang @ 1/25/22
Modified by: Jimmy Zhang @ 5/20/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

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
%cont_enroll_prior_0(exposures=mine.exposures_08_with_outcome, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_08, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_09, output=mine.exposures_08_cont_enrolled);

*2009;
%cont_enroll_prior_1(exposures=mine.exposures_09_with_outcome, enrollment=mine.full_enrollment_08, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_09, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_10, output=mine.exposures_09_cont_enrolled);

*2010;
%cont_enroll_prior_1(exposures=mine.exposures_10_with_outcome, enrollment=mine.full_enrollment_09, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_10, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_11, output=mine.exposures_10_cont_enrolled);

*2011;
%cont_enroll_prior_1(exposures=mine.exposures_11_with_outcome, enrollment=mine.full_enrollment_10, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_11, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_12, output=mine.exposures_11_cont_enrolled);

*2012;
%cont_enroll_prior_1(exposures=mine.exposures_12_with_outcome, enrollment=mine.full_enrollment_11, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_12, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_13, output=mine.exposures_12_cont_enrolled);

*2013;
%cont_enroll_prior_1(exposures=mine.exposures_13_with_outcome, enrollment=mine.full_enrollment_12, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_13, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_14, output=mine.exposures_13_cont_enrolled);

*2014;
%cont_enroll_prior_1(exposures=mine.exposures_14_with_outcome, enrollment=mine.full_enrollment_13, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_14, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_15, output=mine.exposures_14_cont_enrolled);

*2015;
%cont_enroll_prior_1(exposures=mine.exposures_15_with_outcome, enrollment=mine.full_enrollment_14, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_15, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_16, output=mine.exposures_15_cont_enrolled);

*2016;
%cont_enroll_prior_1(exposures=mine.exposures_16_with_outcome, enrollment=mine.full_enrollment_15, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_16, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_17, output=mine.exposures_16_cont_enrolled);

*2017;
%cont_enroll_prior_1(exposures=mine.exposures_17_with_outcome, enrollment=mine.full_enrollment_16, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_17, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_18, output=mine.exposures_17_cont_enrolled);

*2018;
%cont_enroll_prior_1(exposures=mine.exposures_18_with_outcome, enrollment=mine.full_enrollment_17, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_18, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_19, output=mine.exposures_18_cont_enrolled);

*2019;
%cont_enroll_prior_1(exposures=mine.exposures_19_with_outcome, enrollment=mine.full_enrollment_18, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_19, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_20, output=mine.exposures_19_cont_enrolled);

*2020;
%cont_enroll_prior_1(exposures=mine.exposures_20_with_outcome, enrollment=mine.full_enrollment_19, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_20, output=tmp.out2);
%cont_enroll_after_0(exposures=tmp.out2, output=mine.exposures_20_cont_enrolled);