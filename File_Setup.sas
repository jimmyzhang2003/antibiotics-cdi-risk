/* File_Setup.sas
Summary: setting up libraries and data files for the CCAE and MDCR data
Created by: Jimmy Zhang @ 1/10/22
Modified by: Jimmy Zhang @ 5/2/22 
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

/***** PULLING DRUG DATA *****/
*create separate dataset views for each year of drug data (both CCAE and MDCR data);
%create_drug_dataset(input=ccae.ccaed083, output=mine.drug_08_view);
%create_drug_dataset(input=ccae.ccaed093, output=mine.drug_09_view);
%create_drug_dataset(input=ccae.ccaed103, output=mine.drug_10_view);
%create_drug_dataset(input=ccae.ccaed113, output=mine.drug_11_view);
%create_drug_dataset(input=ccae.ccaed123, output=mine.drug_12_view);
%create_drug_dataset(input=ccae.ccaed133, output=mine.drug_13_view);
%create_drug_dataset(input=ccae.ccaed143, output=mine.drug_14_view);
%create_drug_dataset(input=ccae.ccaed153, output=mine.drug_15_view);
%create_drug_dataset(input=ccae.ccaed162, output=mine.drug_16_view);
%create_drug_dataset(input=ccae.ccaed171, output=mine.drug_17_view);
%create_drug_dataset(input=ccae.ccaed181, output=mine.drug_18_view);
%create_drug_dataset(input=ccae.ccaed191, output=mine.drug_19_view);
%create_drug_dataset(input=ccae.ccaed201, output=mine.drug_20_view);

%create_drug_dataset(input=mdcr.mdcrd083, output=mine.drug_08_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd093, output=mine.drug_09_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd103, output=mine.drug_10_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd113, output=mine.drug_11_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd123, output=mine.drug_12_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd133, output=mine.drug_13_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd143, output=mine.drug_14_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd153, output=mine.drug_15_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd162, output=mine.drug_16_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd171, output=mine.drug_17_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd181, output=mine.drug_18_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd191, output=mine.drug_19_mdcr_view);
%create_drug_dataset(input=mdcr.mdcrd201, output=mine.drug_20_mdcr_view);

*----------------------------------------------------------------------------------------------;

/***** IDENTIFYING TOP ANTIBIOTIC CLASSES *****/
/* 423226 unique drugs (NDCNUM) in Redbook
   3082 unique therapeutic drug groups (THERDTL) in Redbook */
proc sql;
	SELECT COUNT(DISTINCT THERDTL)
	FROM redbook.redbook2019;
quit;

/* temporarily pool all drug dataset views into one large dataset to determine most popular drugs*/
data mine.drug_all_view / view=mine.drug_all_view;
	set mine.drug_08_view mine.drug_09_view mine.drug_10_view mine.drug_11_view mine.drug_12_view 
		mine.drug_13_view mine.drug_14_view mine.drug_15_view mine.drug_16_view mine.drug_17_view
		mine.drug_18_view mine.drug_19_view mine.drug_20_view
        mine.drug_08_mdcr_view mine.drug_09_mdcr_view mine.drug_10_mdcr_view mine.drug_11_mdcr_view mine.drug_12_mdcr_view 
		mine.drug_13_mdcr_view mine.drug_14_mdcr_view mine.drug_15_mdcr_view mine.drug_16_mdcr_view mine.drug_17_mdcr_view
		mine.drug_18_mdcr_view mine.drug_19_mdcr_view mine.drug_20_mdcr_view;
run;

*create frequency table of all THERDTL codes;
proc freq data=mine.drug_all_view order=freq noprint;
	tables THERDTL / out=mine.tbl_therdtl_adults;
run;

*to print only the top 100 THERDTL groups;
proc print data=mine.tbl_therdtl_adults(obs=100) noobs;
run;

/* add column to THERDTL table identifying one of the corresponding PRODNME (drug name) codes 
for each THERDTL code; */
*get counts of each THERDTL and PRODNME combination;
proc sql;
	CREATE TABLE mine.drug_names_count_all_adults AS
	SELECT PRODNME, THERDTL, COUNT(*) AS COUNT
	FROM redbook.redbook2019
	GROUP BY THERDTL, PRODNME;
quit;

*take the most popular PRODNME for each THERDTL;
proc sql;
	CREATE TABLE mine.drug_names_count_top_adults AS
	SELECT *
	FROM mine.drug_names_count_all_adults
	GROUP BY THERDTL
	HAVING COUNT = MAX(COUNT);
quit;

*drop duplicate PRODNMEs in case multiple names are the most popular;
proc sort data=mine.drug_names_count_top_adults nodupkey;
	by THERDTL;
run;

*now merge drug name into frequency table;
proc sql;
	CREATE TABLE mine.drugs_freq_table_adults AS
	SELECT *
	FROM mine.tbl_therdtl_adults
	INNER JOIN
	(SELECT PRODNME FROM mine.drug_names_count_top_adults)
	ON tbl_therdtl_adults.THERDTL = drug_names_count_top_adults.THERDTL
	ORDER BY COUNT DESC;
quit;

/* top antibiotic classes, excluding those that treat CDI, to be included in our analysis: Antibiotic Name (THERDTL code)
1) Amoxicillin (812160005)
2) Azithromycin (812120002)
3) Fluoroquinolones: Ciprofloxacin, Levofloxacin, Moxifloxacin (822010010, 822010017, 5204040060, 5204040088)
4) Doxycycline (812240010)
5) Clindamycin (8404040015, 812280010)
6) SMZ-TMP (824010030) -> exclude
7) Cephalexin (812060045)
8) Cefdinir (812060019)
9) Nitrofurantoin (836010055)
10) Minocycline (812240020) -> exclude
11) Pencillin VK (812160070)
12) Clarithromycin (812120003)
13) Cefuroxime (812060040)
*/

*----------------------------------------------------------------------------------------------;

/***** CREATING EXPOSURES DATASETS *****/
*create exposures dataset with above antibiotic classes and renamed variable names separated by year;
%rename_exposure_drugs(input1=mine.drug_08_view, input2=mine.drug_08_mdcr_view, output=mine.exposures_08);
%rename_exposure_drugs(input1=mine.drug_09_view, input2=mine.drug_09_mdcr_view, output=mine.exposures_09);
%rename_exposure_drugs(input1=mine.drug_10_view, input2=mine.drug_10_mdcr_view, output=mine.exposures_10);
%rename_exposure_drugs(input1=mine.drug_11_view, input2=mine.drug_11_mdcr_view, output=mine.exposures_11);
%rename_exposure_drugs(input1=mine.drug_12_view, input2=mine.drug_12_mdcr_view, output=mine.exposures_12);
%rename_exposure_drugs(input1=mine.drug_13_view, input2=mine.drug_13_mdcr_view, output=mine.exposures_13);
%rename_exposure_drugs(input1=mine.drug_14_view, input2=mine.drug_14_mdcr_view, output=mine.exposures_14);
%rename_exposure_drugs(input1=mine.drug_15_view, input2=mine.drug_15_mdcr_view, output=mine.exposures_15);
%rename_exposure_drugs(input1=mine.drug_16_view, input2=mine.drug_16_mdcr_view, output=mine.exposures_16);
%rename_exposure_drugs(input1=mine.drug_17_view, input2=mine.drug_17_mdcr_view, output=mine.exposures_17);
%rename_exposure_drugs(input1=mine.drug_18_view, input2=mine.drug_18_mdcr_view, output=mine.exposures_18);
%rename_exposure_drugs(input1=mine.drug_19_view, input2=mine.drug_19_mdcr_view, output=mine.exposures_19);
%rename_exposure_drugs(input1=mine.drug_20_view, input2=mine.drug_20_mdcr_view, output=mine.exposures_20);

*limit analysis to first antibiotic prescription corresponding to each unique patient;
%sort_unique_patients(data=mine.exposures_08, output=mine.exposures_08_unique);
%sort_unique_patients(data=mine.exposures_09, output=mine.exposures_09_unique);
%sort_unique_patients(data=mine.exposures_10, output=mine.exposures_10_unique);
%sort_unique_patients(data=mine.exposures_11, output=mine.exposures_11_unique);
%sort_unique_patients(data=mine.exposures_12, output=mine.exposures_12_unique);
%sort_unique_patients(data=mine.exposures_13, output=mine.exposures_13_unique);
%sort_unique_patients(data=mine.exposures_14, output=mine.exposures_14_unique);
%sort_unique_patients(data=mine.exposures_15, output=mine.exposures_15_unique);
%sort_unique_patients(data=mine.exposures_16, output=mine.exposures_16_unique);
%sort_unique_patients(data=mine.exposures_17, output=mine.exposures_17_unique);
%sort_unique_patients(data=mine.exposures_18, output=mine.exposures_18_unique);
%sort_unique_patients(data=mine.exposures_19, output=mine.exposures_19_unique);
%sort_unique_patients(data=mine.exposures_20, output=mine.exposures_20_unique);

*----------------------------------------------------------------------------------------------;

/***** CREATING OUTCOMES DATASETS *****/
/* we define a CDI outcome as having the appropriate diagnostic codes for CDI AND receipt any of the three drugs,
(vanco, metro, or dificid), within a +/- two-week window of the diagnosis*/
*frequency table of outcome drugs (vanco, metro, dificid);
proc sql;
	CREATE TABLE mine.outcome_drugs_freq_table AS
	SELECT * FROM mine.drugs_freq_table_adults
	WHERE LOWER(PRODNME) CONTAINS "vanco"
		OR LOWER(PRODNME) CONTAINS "metronidazole"
		OR LOWER(PRODNME) CONTAINS "fidaxomicin" OR LOWER(PRODNME) CONTAINS "dificid";
quit;

%rename_outcome_drugs(input=mine.drug_08_view, output=mine.outcomes_08);
%rename_outcome_drugs(input=mine.drug_09_view, output=mine.outcomes_09);
%rename_outcome_drugs(input=mine.drug_10_view, output=mine.outcomes_10);
%rename_outcome_drugs(input=mine.drug_11_view, output=mine.outcomes_11);
%rename_outcome_drugs(input=mine.drug_12_view, output=mine.outcomes_12);
%rename_outcome_drugs(input=mine.drug_13_view, output=mine.outcomes_13);
%rename_outcome_drugs(input=mine.drug_14_view, output=mine.outcomes_14);
%rename_outcome_drugs(input=mine.drug_15_view, output=mine.outcomes_15);
%rename_outcome_drugs(input=mine.drug_16_view, output=mine.outcomes_16);
%rename_outcome_drugs(input=mine.drug_17_view, output=mine.outcomes_17);
%rename_outcome_drugs(input=mine.drug_18_view, output=mine.outcomes_18);
%rename_outcome_drugs(input=mine.drug_19_view, output=mine.outcomes_19);
%rename_outcome_drugs(input=mine.drug_20_view, output=mine.outcomes_20);
%rename_outcome_drugs(input=mine.drug_08_mdcr_view, output=mine.outcomes_08_mdcr);
%rename_outcome_drugs(input=mine.drug_09_mdcr_view, output=mine.outcomes_09_mdcr);
%rename_outcome_drugs(input=mine.drug_10_mdcr_view, output=mine.outcomes_10_mdcr);
%rename_outcome_drugs(input=mine.drug_11_mdcr_view, output=mine.outcomes_11_mdcr);
%rename_outcome_drugs(input=mine.drug_12_mdcr_view, output=mine.outcomes_12_mdcr);
%rename_outcome_drugs(input=mine.drug_13_mdcr_view, output=mine.outcomes_13_mdcr);
%rename_outcome_drugs(input=mine.drug_14_mdcr_view, output=mine.outcomes_14_mdcr);
%rename_outcome_drugs(input=mine.drug_15_mdcr_view, output=mine.outcomes_15_mdcr);
%rename_outcome_drugs(input=mine.drug_16_mdcr_view, output=mine.outcomes_16_mdcr);
%rename_outcome_drugs(input=mine.drug_17_mdcr_view, output=mine.outcomes_17_mdcr);
%rename_outcome_drugs(input=mine.drug_18_mdcr_view, output=mine.outcomes_18_mdcr);
%rename_outcome_drugs(input=mine.drug_19_mdcr_view, output=mine.outcomes_19_mdcr);
%rename_outcome_drugs(input=mine.drug_20_mdcr_view, output=mine.outcomes_20_mdcr);

data mine.outcomes_all;
	set mine.outcomes_08 mine.outcomes_09 mine.outcomes_10 mine.outcomes_11 mine.outcomes_12
		mine.outcomes_13 mine.outcomes_14 mine.outcomes_15 mine.outcomes_16 mine.outcomes_17
		mine.outcomes_18 mine.outcomes_19 mine.outcomes_20;
        mine.outcomes_08_mdcr mine.outcomes_09_mdcr mine.outcomes_10_mdcr mine.outcomes_11_mdcr mine.outcomes_12_mdcr
		mine.outcomes_13_mdcr mine.outcomes_14_mdcr mine.outcomes_15_mdcr mine.outcomes_16_mdcr mine.outcomes_17_mdcr
		mine.outcomes_18_mdcr mine.outcomes_19_mdcr mine.outcomes_20_mdcr;
run;

/* DX Codes for CDiff: ICD9 (00845), ICD10 (A047, A0471, and A0472)  */
*create table of all CDI diagnoses across all years;
data mine.cdi_diagnoses;
	set ccae.ccaeo083 ccae.ccaeo093 ccae.ccaeo103 ccae.ccaeo113 ccae.ccaeo123 ccae.ccaeo133
		ccae.ccaeo143 ccae.ccaeo153 ccae.ccaeo162 ccae.ccaeo171 ccae.ccaeo181 ccae.ccaeo191
		ccae.ccaeo201 
        mdcr.mdcro083 mdcr.mdcro093 mdcr.mdcro103 mdcr.mdcro113 mdcr.mdcro123 mdcr.mdcro133
		mdcr.mdcro143 mdcr.mdcro153 mdcr.mdcro162 mdcr.mdcro171 mdcr.mdcro181 mdcr.mdcro191
		mdcr.mdcro201;
	if ENROLID = . or AGE < 18 then delete;
	array DXCODES (4) DX1-DX4;
	do i=1 to 4;
		*check if patient received one of the ICD9 or 10 codes for CDI;
		if DXCODES(i) in ('00845', 'A047', 'A0471', 'A0472') then CDI_FLAG=1;
	end;
	if CDI_FLAG = 1;
	keep ENROLID SVCDATE DX1-DX4;
run;

*check if there is an outcome drug prescription within 2 weeks of CDI diagnosis;
proc sql;
	CREATE TABLE mine.all_cdi_outcomes AS
	SELECT cdi_diagnoses.*, outcomes_all.DRUGNAME, outcomes_all.SVCDATE AS OUTCOME_DRUG_SVCDATE
	FROM mine.cdi_diagnoses INNER JOIN mine.outcomes_all
	ON cdi_diagnoses.ENROLID = outcomes_all.ENROLID
		AND outcomes_all.SVCDATE >= cdi_diagnoses.SVCDATE - 14 
		AND outcomes_all.SVCDATE <= cdi_diagnoses.SVCDATE + 14;
quit;

*remove duplicates from CDI outcomes (all rows with same ENROLID and SVCDATE);
proc sort data=mine.all_cdi_outcomes out=mine.all_cdi_outcomes_no_dups nodupkey;
	by ENROLID SVCDATE;
run;

%let outcomes = mine.all_cdi_outcomes_no_dups;
	
%create_CDI_flag(exposures=mine.exposures_08_unique, outcomes=&outcomes, output=mine.exposures_08_with_outcome);
%create_CDI_flag(exposures=mine.exposures_09_unique, outcomes=&outcomes, output=mine.exposures_09_with_outcome);
%create_CDI_flag(exposures=mine.exposures_10_unique, outcomes=&outcomes, output=mine.exposures_10_with_outcome);
%create_CDI_flag(exposures=mine.exposures_11_unique, outcomes=&outcomes, output=mine.exposures_11_with_outcome);
%create_CDI_flag(exposures=mine.exposures_12_unique, outcomes=&outcomes, output=mine.exposures_12_with_outcome);
%create_CDI_flag(exposures=mine.exposures_13_unique, outcomes=&outcomes, output=mine.exposures_13_with_outcome);
%create_CDI_flag(exposures=mine.exposures_14_unique, outcomes=&outcomes, output=mine.exposures_14_with_outcome);
%create_CDI_flag(exposures=mine.exposures_15_unique, outcomes=&outcomes, output=mine.exposures_15_with_outcome);
%create_CDI_flag(exposures=mine.exposures_16_unique, outcomes=&outcomes, output=mine.exposures_16_with_outcome);
%create_CDI_flag(exposures=mine.exposures_17_unique, outcomes=&outcomes, output=mine.exposures_17_with_outcome);
%create_CDI_flag(exposures=mine.exposures_18_unique, outcomes=&outcomes, output=mine.exposures_18_with_outcome);
%create_CDI_flag(exposures=mine.exposures_19_unique, outcomes=&outcomes, output=mine.exposures_19_with_outcome);
%create_CDI_flag(exposures=mine.exposures_20_unique, outcomes=&outcomes, output=mine.exposures_20_with_outcome);

*to get frequencies of CDI incidence by year;
data mine.exposures_all_with_outcome_view / view=mine.exposures_all_with_outcome_view;
	set mine.exposures_08_with_outcome mine.exposures_09_with_outcome mine.exposures_10_with_outcome mine.exposures_11_with_outcome
		mine.exposures_12_with_outcome mine.exposures_13_with_outcome mine.exposures_14_with_outcome mine.exposures_15_with_outcome
		mine.exposures_16_with_outcome mine.exposures_17_with_outcome mine.exposures_18_with_outcome mine.exposures_19_with_outcome
		mine.exposures_20_with_outcome;
run;

proc freq data=mine.exposures_all_with_outcome_view;
	tables CDI_FLAG*YEAR / out=mine.cdi_exposures_outcome_by_year;
run;