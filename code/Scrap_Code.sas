/* Scrap_Code.sas
Summary: some scrap code from my analyses and data processing
Created by: Jimmy Zhang @ 1/15/22
Modified by: Jimmy Zhang @ 4/19/22
*/

*error -> not enough space in WORK folder;
proc sql;
	CREATE VIEW mine.drug_08_view AS
	SELECT ccaed083.ENROLID, ccaed083.NDCNUM, ccaed083.SVCDATE, redbook2019.THERDTL
	FROM ccae.ccaed083, redbook.redbook2019
	WHERE ccaed083.NDCNUM = redbook2019.NDCNUM 
		AND ccaed083.ENROLID IS NOT MISSING 
		AND ccaed083.NDCNUM IS NOT MISSING 
		AND ccaed083.NDCNUM <> '00000000000'
		AND ccaed083.SVCDATE IS NOT MISSING
		AND redbook2019.THERDTL IS NOT MISSING
		AND redbook2019.THERDTL <> 9999999999;
quit;

*doesn't work -> keys must be sorted beforehand;
data mine.drug_09_test;
	merge mine.drug_09 (obs=20 keep = ENROLID SVCDATE NDCNUM in=drug_09) redbook.redbook2019 (keep = NDCNUM THERDTL in=redbook);
		by NDCNUM;
	keep NDCNUM ENROLID SVCDATE THERDTL;
	if missing(ENROLID) OR missing(SVCDATE) OR missing(THERDTL) OR THERDTL = 9999999999 then delete;
	if drug_09;
run;

*changed to include THERDTL as well using Redbook;
data mine.drug_10_view / VIEW=mine.drug_10_view;
	set ccae.ccaed103;
	keep ENROLID NDCNUM SVCDATE;
	if missing(ENROLID) OR missing(SVCDATE) OR NDCNUM = '00000000000' OR missing(SVCDATE) then delete;
run;

proc sort data=mine.drugs_freq_table nodupkey; *drop duplicates to only keep one PRODNME;
	by THERDTL;
run;

proc sort data=mine.drugs_freq_table;
	by descending COUNT;
run;

proc sql inobs=1000;
	SELECT COUNT(*) 
			FROM redbook.redbook2019
			GROUP BY THERDTL, PRODNME;
		quit;

proc sql;
	(SELECT PRODNME
		FROM redbook.redbook2019
		GROUP BY PRODNME
		HAVING COUNT(*) >= ALL 
			(SELECT COUNT(*) 
			FROM redbook.redbook2019
			GROUP BY THERDTL, PRODNME)
		);
		quit;
		
proc sql;
	CREATE TABLE mine.drugs_freq_table AS
	SELECT *
	FROM mine.tbl_therdtl
	INNER JOIN
	(SELECT THERDTL, PRODNME FROM redbook.redbook2019 GROUP BY THERDTL)
	ON tbl_therdtl.THERDTL = redbook2019.THERDTL;
quit;

proc sql;
	CREATE TABLE mine.outpatient_exposures_08 AS
	SELECT exp.*, out.AGE, out.AGEGRP, out.SEX, out.REGION
	FROM mine.exposures_08 AS exp INNER JOIN ccae.ccaeo083 AS out 
	ON exp.SEQNUM = out.SEQNUM;
quit;

/* MERGING OUTPATIENT DATA WITH ANTIBIOTIC PRESCRIPTION DATA */
*for each exposure, merge with a row in the outpatient data based on ENROLID and SVCDATE;
%MACRO merge_outpatient_drug_data(exposure_input=, outpatient_input=, output=);
	data &output;
		merge &exposure_input &outpatient_input;
		by ENROLID SVCDATE;
		if in_exposures & in_outpatients;
		keep SEQNUM ENROLID SVCDATE DRUGNAME AGE AGEGRP SEX REGION;
	run;
%MEND;

%merge_outpatient_drug_data(exposure_input=mine.exposures_09(in=in_exposures), outpatient_input=ccae.ccaeo093(in=in_outpatients), output=mine.outpatient_exposures_08);

data test;
*check within 90 day window;
	set mine.exposures_18(obs=1000 in=in_exp) mine.all_cdi_outcomes_no_dups(obs=1000);

	*create flag for CDI;
	IF OUTCOME_DRUG_SVCDATE = . THEN CDI_FLAG = 0;
	ELSE CDI_FLAG = 1;
	
	IF in_exp;
run;

proc sql;
	CREATE TABLE test AS
	SELECT x.*, y.DRUGNAME, y.OUTCOME_DRUG_SVCDATE, 
		CASE 
			WHEN OUTCOME_DRUG_SVCDATE = . THEN 0
			ELSE 1
		END AS CDI_FLAG
	FROM mine.exposures_18 AS x LEFT JOIN mine.all_cdi_outcomes_no_dups AS y
	ON x.ENROLID = y.ENROLID AND x.SVCDATE >= y.SVCDATE - 90;
quit;

data mine.outpatient_exposures_08;
	merge mine.exposures_08(obs=100000 in=in_exposures) ccae.ccaeo083(obs=1000000 in=in_outpatients);
	by ENROLID SVCDATE;
	if in_exposures & in_outpatients;
	keep SEQNUM ENROLID SVCDATE DRUGNAME AGE AGEGRP SEX REGION;
run;

proc sort data=mine.outpatient_exposures_08 nodupkey;
	by ENROLID SVCDATE;
run;

data cdi_diagnoses_test;
	set ccae.ccaeo083(obs=1000000);
	if ENROLID = . or AGE < 18 then delete;
	array DXCODES (4) DX1-DX4;
	do i=1 to 4;
		*check if patient received one of the ICD9 or 10 codes for CDI;
		if DXCODES(i) in ('00845', 'A047', 'A0471', 'A0472') then CDI_FLAG=1;
	end;
	keep CDI_FLAG ENROLID SVCDATE DX1-DX4 DXVER;
run;

*macro for creating outpatient datasets;
%MACRO create_outpatient_dataset(input=, output=);
	data &output;
		set &input;
		if ENROLID = . or AGE < 18 or missing(SEQNUM) then delete;
		keep SEQNUM ENROLID SVCDATE AGE AGEGRP SEX REGION;
	run;
%MEND;

*logistic regression -> error because of maxpoints=none;
proc logistic data=mine.exposures_15_with_outcome(keep=SEX AGEGRP YEAR REGION DRUGNAME CDI_FLAG PRIOR_HOSPITALIZATION) plots(maxpoints=none)=all descending;
	class PRIOR_HOSPITALIZATION(param=ref ref='0') SEX AGEGRP(param=ref ref='2') YEAR REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = PRIOR_HOSPITALIZATION SEX AGEGRP YEAR REGION DRUGNAME;
run;

proc logistic data=mine.exposures_15_with_outcome(keep=DRUGNAME CDI_FLAG) plots=all descending;
	class DRUGNAME(param=ref ref='DOXYCYCLINE');
	model CDI_FLAG = DRUGNAME;
run;

%MACRO iter_outpatient_diagnoses(num_diagnoses=, input=, cc_grp_codes=,cc_grp=);
	%do i=1 %to &num_diagnoses;
		CASE WHEN &input..DX&i IN &cc_grp_codes THEN 1 END AS CC_GRP_&cc_grp
	%end;
%MEND;

*%MACRO add_comorbidities(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, output=);
%MACRO add_comorbidities(exposures=, inpatients1=, output=);
	*start with inpatients dataset;
	data &output;
		merge &exposures &inpatients1(keep=ENROLID DISDATE DX1-DX15);
		by ENROLID;
		if SVCDATE <= DISDATE + 365; *make sure that diagnoses occur within 1 year of drug prescription date;
		array DXCODES (15) DX1-DX15;
		do i=1 to 15;
			*check if patient has one of the ICD9 or 10 codes for each comorbidity;
			if DXCODES(i) in &cc_grp_1_codes then CC_GRP_1 = 1;
			else if DXCODES(i) in &cc_grp_2_codes then CC_GRP_2 = 1;
			else if DXCODES(i) in &cc_grp_3_codes then CC_GRP_3 = 1;
			else if DXCODES(i) in &cc_grp_4_codes then CC_GRP_4 = 1;
			else if DXCODES(i) in &cc_grp_5_codes then CC_GRP_5 = 1;
			else if DXCODES(i) in &cc_grp_6_codes then CC_GRP_6 = 1;
			else if DXCODES(i) in &cc_grp_7_codes then CC_GRP_7 = 1;
			else if DXCODES(i) in &cc_grp_8_codes then CC_GRP_8 = 1;
			else if DXCODES(i) in &cc_grp_9_codes then CC_GRP_9 = 1;
			else if DXCODES(i) in &cc_grp_10_codes then CC_GRP_10 = 1;
			else if DXCODES(i) in &cc_grp_11_codes then CC_GRP_11 = 1;
			else if DXCODES(i) in &cc_grp_12_codes then CC_GRP_12 = 1;
			else if DXCODES(i) in &cc_grp_13_codes then CC_GRP_13 = 1;
			else if DXCODES(i) in &cc_grp_14_codes then CC_GRP_14 = 1;
			else if DXCODES(i) in &cc_grp_15_codes then CC_GRP_15 = 1;
			else if DXCODES(i) in &cc_grp_16_codes then CC_GRP_16 = 1;
			else if DXCODES(i) in &cc_grp_17_codes then CC_GRP_17 = 1;
		end;
	run;
	
	*since there are duplicates due to one-to-many merging, select the max of each comorbidity column (0 or 1) and collapse rows;
	proc sql;
		CREATE TABLE &output AS 
		SELECT SEQNUM, ENROLID, SVCDATE, YEAR, AGE, REGION, AGEGRP, SEX, DRUGNAME, CDI_FLAG, DISDATE, PRIOR_HOSPITALIZATION,
			   MAX(CC_GRP_1) AS CC_GRP_1, MAX(CC_GRP_2) AS CC_GRP_2, MAX(CC_GRP_3) AS CC_GRP_3, MAX(CC_GRP_4) AS CC_GRP_4, MAX(CC_GRP_5) AS CC_GRP_5,
			   MAX(CC_GRP_6) AS CC_GRP_6, MAX(CC_GRP_7) AS CC_GRP_7, MAX(CC_GRP_8) AS CC_GRP_8, MAX(CC_GRP_9) AS CC_GRP_9, MAX(CC_GRP_10) AS CC_GRP_10,
			   MAX(CC_GRP_11) AS CC_GRP_11, MAX(CC_GRP_12) AS CC_GRP_12, MAX(CC_GRP_13) AS CC_GRP_13, MAX(CC_GRP_14) AS CC_GRP_14, MAX(CC_GRP_15) AS CC_GRP_15,
			   MAX(CC_GRP_16) AS CC_GRP_16, MAX(CC_GRP_17) AS CC_GRP_17
		FROM &output
		GROUP BY SEQNUM;
	quit;
	
	*sort to remove duplicates generated by the merge step;
	proc sort data=&output nodupkey;
		by SEQNUM;
	run;
%MEND;

*convert all missing values to 0;
data &output;
	set &output;
	array CC_GROUPS (17) CC_GRP_1-CC_GRP_17;
	do i=1 to 17;
		CC_GROUPS(i) = coalesce(CC_GROUPS(i), 0);
	end;
	drop i;
run;

%add_comorbidities(exposures=mine.exposures_09_with_outcome, inpatients=mine.inpatient_08_09_view(obs=1), outpatients=mine.outpatient_08_09_view(obs=1), facility_header=mine.facility_header_08_09_view(obs=1), output=mine.test);

%add_cci(input=mine.exposures_09_complete, output=mine.exposures_09_complete);

proc freq data=mine.exposures_09_complete;
	tables CCI;
run;

/* Sort execution failure +
NOTE: The query requires remerging summary statistics back with the original data.
 WARNING: This CREATE TABLE statement recursively references the target table. A consequence of this is a possible data integrity 
          problem.
 ERROR: Insufficient space in file WORK.'SASTMP-000000571'n.UTILITY.
 ERROR: File WORK.'SASTMP-000000571'n.UTILITY is damaged. I/O processing did not complete.
 NOTE: Error was encountered during utility-file processing. You may be able to execute the SQL statement successfully if you 
       allocate more space to the WORK library.
 ERROR: There is not enough WORK disk space to store the results of an internal sorting phase.
 ERROR: An error has occurred.
*/

*combining datasets maybe ruined sorting order in ENROLID?
*macros for combining two datasets (used for comorbidity generation, which requires current and prior year);
%MACRO combine_inpatient_datasets(input1=, input2=, output=);
	data &output / view=&output;
		set &input1 &input2;
		if missing(ENROLID) or missing(DISDATE) or AGE < 18 then delete;
		keep ENROLID DISDATE DX1-DX15;
	run;
%MEND;

%MACRO combine_outpatient_datasets(input1=, input2=, output=);
	data &output / view =&output;
		set &input1 &input2;
		if missing(ENROLID) or missing(SVCDATE) or AGE < 18 then delete;
		keep ENROLID SVCDATE DX1-DX4;
	run;
%MEND;

%MACRO combine_facility_header_datasets(input1=, input2=, output=);
	data &output / view=&output;
		set &input1 &input2;
		if missing(ENROLID) or missing(SVCDATE) or AGE < 18 then delete;
		keep ENROLID SVCDATE DX1-DX9;
	run;
%MEND;

*combining inpatient datasets;
%combine_inpatient_datasets(input1=ccae.ccaei083, input2=ccae.ccaei093, output=mine.inpatient_08_09_view);
%combine_inpatient_datasets(input1=ccae.ccaei093, input2=ccae.ccaei103, output=mine.inpatient_09_10_view);
%combine_inpatient_datasets(input1=ccae.ccaei103, input2=ccae.ccaei113, output=mine.inpatient_10_11_view);
%combine_inpatient_datasets(input1=ccae.ccaei113, input2=ccae.ccaei123, output=mine.inpatient_11_12_view);
%combine_inpatient_datasets(input1=ccae.ccaei123, input2=ccae.ccaei133, output=mine.inpatient_12_13_view);
%combine_inpatient_datasets(input1=ccae.ccaei133, input2=ccae.ccaei143, output=mine.inpatient_13_14_view);
%combine_inpatient_datasets(input1=ccae.ccaei143, input2=ccae.ccaei153, output=mine.inpatient_14_15_view);
%combine_inpatient_datasets(input1=ccae.ccaei153, input2=ccae.ccaei162, output=mine.inpatient_15_16_view);
%combine_inpatient_datasets(input1=ccae.ccaei162, input2=ccae.ccaei171, output=mine.inpatient_16_17_view);
%combine_inpatient_datasets(input1=ccae.ccaei171, input2=ccae.ccaei181, output=mine.inpatient_17_18_view);
%combine_inpatient_datasets(input1=ccae.ccaei181, input2=ccae.ccaei191, output=mine.inpatient_18_19_view);

*combining outpatient datasets;
%combine_outpatient_datasets(input1=ccae.ccaeo083, input2=ccae.ccaeo093, output=mine.outpatient_08_09_view);
%combine_outpatient_datasets(input1=ccae.ccaeo093, input2=ccae.ccaeo103, output=mine.outpatient_09_10_view);
%combine_outpatient_datasets(input1=ccae.ccaeo103, input2=ccae.ccaeo113, output=mine.outpatient_10_11_view);
%combine_outpatient_datasets(input1=ccae.ccaeo113, input2=ccae.ccaeo123, output=mine.outpatient_11_12_view);
%combine_outpatient_datasets(input1=ccae.ccaeo123, input2=ccae.ccaeo133, output=mine.outpatient_12_13_view);
%combine_outpatient_datasets(input1=ccae.ccaeo133, input2=ccae.ccaeo143, output=mine.outpatient_13_14_view);
%combine_outpatient_datasets(input1=ccae.ccaeo143, input2=ccae.ccaeo153, output=mine.outpatient_14_15_view);
%combine_outpatient_datasets(input1=ccae.ccaeo153, input2=ccae.ccaeo162, output=mine.outpatient_15_16_view);
%combine_outpatient_datasets(input1=ccae.ccaeo162, input2=ccae.ccaeo171, output=mine.outpatient_16_17_view);
%combine_outpatient_datasets(input1=ccae.ccaeo171, input2=ccae.ccaeo181, output=mine.outpatient_17_18_view);
%combine_outpatient_datasets(input1=ccae.ccaeo181, input2=ccae.ccaeo191, output=mine.outpatient_18_19_view);

*combining facility header datasets;
%combine_facility_header_datasets(input1=ccae.ccaef083, input2=ccae.ccaef093, output=mine.facility_header_08_09_view);
%combine_facility_header_datasets(input1=ccae.ccaef093, input2=ccae.ccaef103, output=mine.facility_header_09_10_view);
%combine_facility_header_datasets(input1=ccae.ccaef103, input2=ccae.ccaef113, output=mine.facility_header_10_11_view);
%combine_facility_header_datasets(input1=ccae.ccaef113, input2=ccae.ccaef123, output=mine.facility_header_11_12_view);
%combine_facility_header_datasets(input1=ccae.ccaef123, input2=ccae.ccaef133, output=mine.facility_header_12_13_view);
%combine_facility_header_datasets(input1=ccae.ccaef133, input2=ccae.ccaef143, output=mine.facility_header_13_14_view);
%combine_facility_header_datasets(input1=ccae.ccaef143, input2=ccae.ccaef153, output=mine.facility_header_14_15_view);
%combine_facility_header_datasets(input1=ccae.ccaef153, input2=ccae.ccaef162, output=mine.facility_header_15_16_view);
%combine_facility_header_datasets(input1=ccae.ccaef162, input2=ccae.ccaef171, output=mine.facility_header_16_17_view);
%combine_facility_header_datasets(input1=ccae.ccaef171, input2=ccae.ccaef181, output=mine.facility_header_17_18_view);
%combine_facility_header_datasets(input1=ccae.ccaef181, input2=ccae.ccaef191, output=mine.facility_header_18_19_view);

*since there are duplicates due to one-to-many merging, select the max of each comorbidity column (0 or 1) and collapse rows;
/* 	proc sql; */
/* 		CREATE TABLE &output AS  */
/* 		SELECT SEQNUM, ENROLID, SVCDATE, YEAR, AGE, REGION, AGEGRP, SEX, DRUGNAME, CDI_FLAG, DISDATE, PRIOR_HOSPITALIZATION, */
/* 			   MAX(CC_GRP_1) AS CC_GRP_1, MAX(CC_GRP_2) AS CC_GRP_2, MAX(CC_GRP_3) AS CC_GRP_3, MAX(CC_GRP_4) AS CC_GRP_4, MAX(CC_GRP_5) AS CC_GRP_5, */
/* 			   MAX(CC_GRP_6) AS CC_GRP_6, MAX(CC_GRP_7) AS CC_GRP_7, MAX(CC_GRP_8) AS CC_GRP_8, MAX(CC_GRP_9) AS CC_GRP_9, MAX(CC_GRP_10) AS CC_GRP_10, */
/* 			   MAX(CC_GRP_11) AS CC_GRP_11, MAX(CC_GRP_12) AS CC_GRP_12, MAX(CC_GRP_13) AS CC_GRP_13, MAX(CC_GRP_14) AS CC_GRP_14, MAX(CC_GRP_15) AS CC_GRP_15, */
/* 			   MAX(CC_GRP_16) AS CC_GRP_16, MAX(CC_GRP_17) AS CC_GRP_17 */
/* 		FROM &output */
/* 		GROUP BY SEQNUM; */
/* 	quit; */

/* 	*sort again to remove duplicates generated by the merge step; */
/* 	proc sort data=&output nodupkey; */
/* 		by SEQNUM; */
/* 	run; */

/*ERROR: No disk space is available for the write operation.  Filename = C:\Users\def2004\AppData\Local\Temp\SAS Temporary 
        Files\SAS_util00010000288C_sas-ibmdb\ut288C00003D.utl.
 ERROR: Failure while attempting to write page 1809 of sorted run 12.
 ERROR: Failure while attempting to write page 40925 to utility file 1.
 ERROR: Failure encountered while creating initial set of sorted runs.
 ERROR: Failure encountered during external sort.
 ERROR: Sort execution failure. */

/*%MACRO collapse_rows(data=);
	*sort by SEQNUM;
	proc sort data=&data;
		by SEQNUM;
	run;
	
	*use data step and update to collapse duplicate rows (combines the columns for each comorbidity for each unique SEQNUM to only . or 1);
	data &data;
		update &data(obs=0) &data;
		by SEQNUM;
	run;
	
	*re-sort by ENROLID and SVCDATE;
	proc sort data=&data;
		by ENROLID SVCDATE;
	run;
%MEND;

*/

	*break outpatients dataset up;
	%split_and_sort(SRC_DATASET=&outpatients1, OUT_PREFIX=TMP.TEMP_OUT, SPLIT_NUM=100, SPLIT_DEF=SETS);
	
	%do i=1 %to 100;
		proc sql;
			CREATE TABLE &output AS
			SELECT exp.*, 
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_1_codes, cc_grp=1),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_2_codes, cc_grp=2),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_3_codes, cc_grp=3),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_4_codes, cc_grp=4),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_5_codes, cc_grp=5),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_6_codes, cc_grp=6),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_7_codes, cc_grp=7),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_8_codes, cc_grp=8),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_9_codes, cc_grp=9),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_10_codes, cc_grp=10),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_11_codes, cc_grp=11),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_12_codes, cc_grp=12),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_13_codes, cc_grp=13),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_14_codes, cc_grp=14),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_15_codes, cc_grp=15),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_16_codes, cc_grp=16),
				%iter_outpatient_diagnoses(input=outp, cc_grp_codes=&cc_grp_17_codes, cc_grp=17)
			FROM &output as exp LEFT JOIN TMP.TEMP_OUT_&i. as outp
			ON exp.ENROLID = outp.ENROLID AND exp.SVCDATE <= outp.SVCDATE + 365;
		quit;
	%end;

*macro for iterating over inpatient diagnoses codes, checking if they are in the CC groups;
%MACRO iter_inpatient_diagnoses(input=, cc_grp_codes=,cc_grp=);
	CASE WHEN &input..DX1 IN &cc_grp_codes
		OR &input..DX2 IN &cc_grp_codes
		OR &input..DX3 IN &cc_grp_codes
		OR &input..DX4 IN &cc_grp_codes
		OR &input..DX5 IN &cc_grp_codes
		OR &input..DX6 IN &cc_grp_codes
		OR &input..DX7 IN &cc_grp_codes
		OR &input..DX8 IN &cc_grp_codes
		OR &input..DX9 IN &cc_grp_codes
		OR &input..DX10 IN &cc_grp_codes
		OR &input..DX11 IN &cc_grp_codes
		OR &input..DX12 IN &cc_grp_codes
		OR &input..DX13 IN &cc_grp_codes
		OR &input..DX14 IN &cc_grp_codes
		OR &input..DX15 IN &cc_grp_codes
		THEN 1 ELSE .
	END AS CC_GRP_&cc_grp
%MEND;

*macro for iterating over outpatient diagnoses codes, checking if they are in the CC groups;
%MACRO iter_outpatient_diagnoses(input=, cc_grp_codes=, cc_grp=);
	CASE WHEN &input..DX1 IN &cc_grp_codes
		OR &input..DX2 IN &cc_grp_codes
		OR &input..DX3 IN &cc_grp_codes
		OR &input..DX4 IN &cc_grp_codes
		THEN 1 ELSE .
	END AS CC_GRP_&cc_grp
%MEND;

*macro for iterating over facility header diagnosis codes, checking if they are in the CC groups;
%MACRO iter_facility_header_diagnoses(input=, cc_grp_codes=,cc_grp=);
	CASE WHEN &input..DX1 IN &cc_grp_codes
		OR &input..DX2 IN &cc_grp_codes
		OR &input..DX3 IN &cc_grp_codes
		OR &input..DX4 IN &cc_grp_codes
		OR &input..DX5 IN &cc_grp_codes
		OR &input..DX6 IN &cc_grp_codes
		OR &input..DX7 IN &cc_grp_codes
		OR &input..DX8 IN &cc_grp_codes
		OR &input..DX9 IN &cc_grp_codes
		THEN 1 ELSE .
	END AS CC_GRP_&cc_grp
%MEND;

*macro adapted from MCHP SAS macro code: http://mchp-appserv.cpe.umanitoba.ca/viewConcept.php?conceptID=1098;
*check diagnosis codes from inpatient, outpatient, and facility header tables within 1 year of drug prescription index date;
%MACRO add_comorbidities(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, facility_header1=, facility_header2=, output=);
	*inpatients1 data;
	proc sql;
		CREATE TABLE &output AS
		SELECT exp.*, 
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_1_codes, cc_grp=1),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_2_codes, cc_grp=2),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_3_codes, cc_grp=3),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_4_codes, cc_grp=4),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_5_codes, cc_grp=5),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_6_codes, cc_grp=6),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_7_codes, cc_grp=7),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_8_codes, cc_grp=8),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_9_codes, cc_grp=9),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_10_codes, cc_grp=10),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_11_codes, cc_grp=11),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_12_codes, cc_grp=12),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_13_codes, cc_grp=13),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_14_codes, cc_grp=14),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_15_codes, cc_grp=15),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_16_codes, cc_grp=16),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_17_codes, cc_grp=17)
		FROM &exposures as exp LEFT JOIN &inpatients1 as inp
		ON exp.ENROLID = inp.ENROLID AND exp.SVCDATE <= inp.DISDATE + 365;
	quit;
	
	%collapse_rows(data=&output);
	
	*inpatients2 data;
	proc sql;
		CREATE TABLE &output AS
		SELECT exp.*, 
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_1_codes, cc_grp=1),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_2_codes, cc_grp=2),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_3_codes, cc_grp=3),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_4_codes, cc_grp=4),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_5_codes, cc_grp=5),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_6_codes, cc_grp=6),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_7_codes, cc_grp=7),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_8_codes, cc_grp=8),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_9_codes, cc_grp=9),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_10_codes, cc_grp=10),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_11_codes, cc_grp=11),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_12_codes, cc_grp=12),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_13_codes, cc_grp=13),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_14_codes, cc_grp=14),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_15_codes, cc_grp=15),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_16_codes, cc_grp=16),
			%iter_inpatient_diagnoses(input=inp, cc_grp_codes=&cc_grp_17_codes, cc_grp=17)
		FROM &exposures as exp LEFT JOIN &inpatients2 as inp
		ON exp.ENROLID = inp.ENROLID AND exp.SVCDATE <= inp.DISDATE + 365;
	quit;
	
	%collapse_rows(data=&output);

	
	
	
	*convert all missing values to 0;
	data &output;
		set &output;
		array CC_GROUPS (17) CC_GRP_1-CC_GRP_17;
		do i=1 to 17;
			CC_GROUPS(i) = coalesce(CC_GROUPS(i), 0);
		end;
		drop i;
	run;
%MEND;

*macro adapted from https://blogs.sas.com/content/sgf/2020/07/23/splitting-a-data-set-into-smaller-data-sets/;
*used to split the large outpatient and facility header datasets and sort them individually;
%macro split_and_sort(SRC_DATASET=, OUT_PREFIX=, SPLIT_NUM=, SPLIT_DEF=);
/* Parameters:
/*   SRC_DATASET - name of the source data set     */
/*   OUT_PREFIX - prefix of the output data sets   */
/*   SPLIT_NUM - split number                      */
/*   SPLIT_DEF - split definition (=SETS or =NOBS) */
 
   %local I K S TLIST;
 
   /* number of observations &K, number of smaller datasets &S */
   data _null_;
      if 0 then set &SRC_DATASET nobs=N;
      if upcase("&SPLIT_DEF")='NOBS' then
         do;
            call symputx('K',&SPLIT_NUM); 
            call symputx('S',ceil(N/&SPLIT_NUM));
            put "***MACRO SPLIT: Splitting into datasets of no more than &SPLIT_NUM observations";
         end;
         else if upcase("&SPLIT_DEF")='SETS' then
         do;
            call symputx('S',&SPLIT_NUM); 
            call symputx('K',ceil(N/&SPLIT_NUM));
            put "***MACRO SPLIT: Splitting into &SPLIT_NUM datasets";
        end;
         else put "***MACRO SPLIT: Incorrect SPLIT_DEF=&SPLIT_DEF value. Must be either SETS or NOBS.";
      stop; 
   run;
 
   /* terminate macro if nothing to split */
   %if (&K le 0) or (&S le 0) %then %return;
 
    /* generate list of smaller dataset names */
   %do I=1 %to &S;
      %let TLIST = &TLIST &OUT_PREFIX._&I;
   %end;
 
   /* split source dataset into smaller datasets */
   data &TLIST;
      set &SRC_DATASET;
      if missing(ENROLID) or missing(SVCDATE) or AGE < 18
			then delete;
	  keep SEQNUM ENROLID SVCDATE DX1-DX4;
      select;
         %do I=1 %to &S;
            when(_n_ <= &K * &I) output &OUT_PREFIX._&I; 
         %end;
      end;
   run;
   
   *sort each of the individual datasets by ENROLID and SVCDATE;
   %do i=1 %to &S;
	  proc sort data=&OUT_PREFIX._&i;
	  	by ENROLID SVCDATE;
	  run;
	%end;
%mend;

data test3;
	input a $ b;
	datalines;
	1 2
	2 1 
	4 4 
	3 3
	2 2
;

data test4;
	input a b c;
	datalines;
	3 3 1
	3 4 2
	7 9 4
	8 2 4
;

data test5;
	input a d e;
	datalines;
	3 3 2
	3 4 59
	7 6 2
;

proc sql;
	SELECT test4.*, test5.d, test5.e
	FROM test4 LEFT JOIN test5
	ON test4.b = test5.d;
quit;

data test5;
	update test4(obs=0) test4;
	by a b;
run;

data &data;
		update &data(obs=0) &data;
		by SEQNUM;
	run;
data test5;
	set test3 test4;
run;

data mine.outpatient_08_view / view=mine.outpatient_08_view;
	set ccae.ccaeo083;
	if missing(ENROLID) or missing(SVCDATE) or AGE < 18 then delete;
	length DX3 DX4 $ 5;
	DX3 = .;
	DX4 = .;
	keep ENROLID SVCDATE DX1-DX4;
run;

proc sort data=mine.exposures_09_with_outcome out=mine.exposures_09_with_outcome_test;
	by ENROLID SVCDATE;
run;


*sort all of the exposures datasets by ENROLID and SVCDATE?;
data test;
	set ccae.ccaeo083(obs=1000000);
	if missing(ENROLID) or missing(SVCDATE) or AGE < 18 then delete;
	keep ENROLID SVCDATE DX1-DX4;
run;

proc sort data=test out=test2;
	by ENROLID SVCDATE;
run;

%MACRO check_continuous_enrollment(exposures=, enrollment1=, enrollment2=, enrollment3=, output=);
	*prior year;
	data tmp.out1;
		%if &enrollment1 ^= 0 %then
			%do;
				merge &exposures(in=a) &enrollment1(in=b keep=ENROLID ENRIND1-ENRIND12);
				by ENROLID;
				if a;
				MONTH = month(SVCDATE);
				array ENRINDS (12) ENRIND1-ENRIND12;
			
				*initalize enrolled flag to 1, then update as we check the months of enrollment;
				ENROLLED1 = 1;
				*only need to check last three months of the year;
				do i=MONTH+9 to 12;
				if ENRINDS(i) ^= 1 then ENROLLED1=0;
			
				if ENROLLED1;
				drop ENRIND1-ENRIND12 i;
			%end;
		%else %do;
			%put test;
		%end;
	run;
%MEND;

data bruh;
	merge mine.exposures_all_complete(in=a obs=1000) ccae.ccaea083(in=b obs=10000 keep=ENROLID ENRIND1-ENRIND12);
	by ENROLID;
	MONTH = month(SVCDATE);
	array ENRINDS (12) ENRIND1-ENRIND12;
	ENROLLED = 1;
	do i=1 to 12;
		if i > month+3 then leave;
		if ENRINDS(i) ^= 1 then ENROLLED=0;
	end;
	
	if a & ENROLLED;
	drop ENRIND1-ENRIND12 MONTH i ENROLLED;
run;


%MACRO bruh(N=);
	%if &N ^= 0 %then %do;
		data _null_;
    		put "Hello World!";
		run;
	%end;
	
	%else %do;
		data _null_;
    		put "Goodbye World!";
		run;
	%end;
	
	%if &N ^= 0 %then %do;
		data _null_;
    		put "Hello World!";
		run;
	%end;
	
	%else %do;
		data _null_;
    		put "Goodbye World!";
		run;
	%end;
%MEND;

%bruh(N=0);

%MACRO bruh(N=);
	data bruh;
		set mine.exposures_11(obs=10);
		bruh = max(year, 2012);
	run;
%MEND;

data bruh5;
	set mine.exposures_11(obs=10);
	MONTH = month(SVCDATE);
	do i=MONTH+3 to 0;
		put "Goodbye World!";
	end;
run;