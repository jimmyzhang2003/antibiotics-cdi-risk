/* File_Setup.sas
Summary: setting up libraries and data files for the CCAE data
Created by: Jimmy Zhang @ 1/10/22
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

/***** PULLING DRUG DATA *****/
*create separate dataset views for each year of drug data;
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
		mine.drug_18_view mine.drug_19_view mine.drug_20_view;
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
/* create table of number of unique patients per year */
proc sql;
	CREATE TABLE mine.unique_adults_per_year_table AS
	SELECT 2008 as YEAR, COUNT(DISTINCT drug_08_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_08_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2009 as YEAR, COUNT(DISTINCT drug_09_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_09_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2010 as YEAR, COUNT(DISTINCT drug_10_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_10_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2011 as YEAR, COUNT(DISTINCT drug_11_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_11_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2012 as YEAR, COUNT(DISTINCT drug_12_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_12_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2013 as YEAR, COUNT(DISTINCT drug_13_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_13_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2014 as YEAR, COUNT(DISTINCT drug_14_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_14_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2015 as YEAR, COUNT(DISTINCT drug_15_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_15_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2016 as YEAR, COUNT(DISTINCT drug_16_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_16_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2017 as YEAR, COUNT(DISTINCT drug_17_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_17_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2018 as YEAR, COUNT(DISTINCT drug_18_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_18_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2019 as YEAR, COUNT(DISTINCT drug_19_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_19_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2020 as YEAR, COUNT(DISTINCT drug_20_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_20_view;
quit;

*create exposures dataset with above antibiotic classes and renamed variable names separated by year;
%rename_exposure_drugs(input=mine.drug_08_view, output=mine.exposures_08);
%rename_exposure_drugs(input=mine.drug_09_view, output=mine.exposures_09);
%rename_exposure_drugs(input=mine.drug_10_view, output=mine.exposures_10);
%rename_exposure_drugs(input=mine.drug_11_view, output=mine.exposures_11);
%rename_exposure_drugs(input=mine.drug_12_view, output=mine.exposures_12);
%rename_exposure_drugs(input=mine.drug_13_view, output=mine.exposures_13);
%rename_exposure_drugs(input=mine.drug_14_view, output=mine.exposures_14);
%rename_exposure_drugs(input=mine.drug_15_view, output=mine.exposures_15);
%rename_exposure_drugs(input=mine.drug_16_view, output=mine.exposures_16);
%rename_exposure_drugs(input=mine.drug_17_view, output=mine.exposures_17);
%rename_exposure_drugs(input=mine.drug_18_view, output=mine.exposures_18);
%rename_exposure_drugs(input=mine.drug_19_view, output=mine.exposures_19);
%rename_exposure_drugs(input=mine.drug_19_view, output=mine.exposures_19);
%rename_exposure_drugs(input=mine.drug_20_view, output=mine.exposures_20);

*get drug frequencies for each year;
%get_drug_freq(input=mine.exposures_08, output=mine.drugs_freq_08, year=2008);
%get_drug_freq(input=mine.exposures_09, output=mine.drugs_freq_09, year=2009);
%get_drug_freq(input=mine.exposures_10, output=mine.drugs_freq_10, year=2010);
%get_drug_freq(input=mine.exposures_11, output=mine.drugs_freq_11, year=2011);
%get_drug_freq(input=mine.exposures_12, output=mine.drugs_freq_12, year=2012);
%get_drug_freq(input=mine.exposures_13, output=mine.drugs_freq_13, year=2013);
%get_drug_freq(input=mine.exposures_14, output=mine.drugs_freq_14, year=2014);
%get_drug_freq(input=mine.exposures_15, output=mine.drugs_freq_15, year=2015);
%get_drug_freq(input=mine.exposures_16, output=mine.drugs_freq_16, year=2016);
%get_drug_freq(input=mine.exposures_17, output=mine.drugs_freq_17, year=2017);
%get_drug_freq(input=mine.exposures_18, output=mine.drugs_freq_18, year=2018);
%get_drug_freq(input=mine.exposures_19, output=mine.drugs_freq_19, year=2019);
%get_drug_freq(input=mine.exposures_20, output=mine.drugs_freq_20, year=2020);

*join all drug freq datasets together;
data mine.drugs_freq_all_by_year;
	set mine.drugs_freq_08 mine.drugs_freq_09 mine.drugs_freq_10 mine.drugs_freq_11
		 mine.drugs_freq_12 mine.drugs_freq_13 mine.drugs_freq_14 mine.drugs_freq_15
		 mine.drugs_freq_16 mine.drugs_freq_17 mine.drugs_freq_18 mine.drugs_freq_19
		 mine.drugs_freq_20;
run;	

*add column denoting total number of unique patients for that year (based on UNIQUE_ADULTS_PER_YEAR_TABLE);
data mine.drugs_freq_all_by_year;
	set mine.drugs_freq_all_by_year;
	select (year(YEAR));
		when (2008) NUM_UNIQUE_PATIENTS = 18403144;
		when (2009) NUM_UNIQUE_PATIENTS = 21031748;
		when (2010) NUM_UNIQUE_PATIENTS = 20591222;
		when (2011) NUM_UNIQUE_PATIENTS = 22264424;
		when (2012) NUM_UNIQUE_PATIENTS = 22695165;
		when (2013) NUM_UNIQUE_PATIENTS = 18339738;
		when (2014) NUM_UNIQUE_PATIENTS = 18823022;
		when (2015) NUM_UNIQUE_PATIENTS = 14887989;
		when (2016) NUM_UNIQUE_PATIENTS = 14549514;
		when (2017) NUM_UNIQUE_PATIENTS = 13437607;
		when (2018) NUM_UNIQUE_PATIENTS = 13697841;
		when (2019) NUM_UNIQUE_PATIENTS = 12764991;
		when (2020) NUM_UNIQUE_PATIENTS = 9954880;
		otherwise NUM_UNIQUE_PATIENTS = .;
	end;
run;

*add columns denoting number of 1000 person-years (i.e. just divide by 1000) and normalized count;
data mine.drugs_freq_all_by_year;
	set mine.drugs_freq_all_by_year;
	COUNT_PER_1000_PERSON_YEARS = COUNT / (NUM_UNIQUE_PATIENTS/ 1000);
	select (strip(upcase(DRUGNAME)));
		when ('AMOXICILLIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 229.4820385;
		when ('AZITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 229.18361124;
		when ('FLUOROQUINOLONES') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 179.73928803;
		when ('CEPHALEXIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 77.255875409;
		when ('CLINDAMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 70.453505118;
		when ('DOXYCYCLINE') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 68.309088925;
		when ('NITROFURANTOIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 32.899215482;
		when ('PENICILLIN VK') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 32.257585986;
		when ('CLARITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 28.458561211;
		when ('CEFDINIR') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 19.171887151;
		when ('CEFUROXIME') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 15.567611708;
		otherwise COUNT_NORM = .;
	end;
run;

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

data mine.outcomes_all;
	set mine.outcomes_08 mine.outcomes_09 mine.outcomes_10 mine.outcomes_11 mine.outcomes_12
		mine.outcomes_13 mine.outcomes_14 mine.outcomes_15 mine.outcomes_16 mine.outcomes_17
		mine.outcomes_18 mine.outcomes_19 mine.outcomes_20;
run;

/* DX Codes for CDiff: ICD9 (00845), ICD10 (A047, A0471, and A0472)  */
*create table of all CDI diagnoses across all years;
data mine.cdi_diagnoses;
	set ccae.ccaeo083 ccae.ccaeo093 ccae.ccaeo103 ccae.ccaeo113 ccae.ccaeo123 ccae.ccaeo133
		ccae.ccaeo143 ccae.ccaeo153 ccae.ccaeo162 ccae.ccaeo171 ccae.ccaeo181 ccae.ccaeo191
		ccae.ccaeo201;
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
run; *~154,000 outcomes remaining;

%let outcomes = mine.all_cdi_outcomes_no_dups;
	
%create_CDI_flag(exposures=mine.exposures_08, outcomes=&outcomes, output=mine.exposures_08_with_outcome);
%create_CDI_flag(exposures=mine.exposures_09, outcomes=&outcomes, output=mine.exposures_09_with_outcome);
%create_CDI_flag(exposures=mine.exposures_10, outcomes=&outcomes, output=mine.exposures_10_with_outcome);
%create_CDI_flag(exposures=mine.exposures_11, outcomes=&outcomes, output=mine.exposures_11_with_outcome);
%create_CDI_flag(exposures=mine.exposures_12, outcomes=&outcomes, output=mine.exposures_12_with_outcome);
%create_CDI_flag(exposures=mine.exposures_13, outcomes=&outcomes, output=mine.exposures_13_with_outcome);
%create_CDI_flag(exposures=mine.exposures_14, outcomes=&outcomes, output=mine.exposures_14_with_outcome);
%create_CDI_flag(exposures=mine.exposures_15, outcomes=&outcomes, output=mine.exposures_15_with_outcome);
%create_CDI_flag(exposures=mine.exposures_16, outcomes=&outcomes, output=mine.exposures_16_with_outcome);
%create_CDI_flag(exposures=mine.exposures_17, outcomes=&outcomes, output=mine.exposures_17_with_outcome);
%create_CDI_flag(exposures=mine.exposures_18, outcomes=&outcomes, output=mine.exposures_18_with_outcome);
%create_CDI_flag(exposures=mine.exposures_19, outcomes=&outcomes, output=mine.exposures_19_with_outcome);
%create_CDI_flag(exposures=mine.exposures_20, outcomes=&outcomes, output=mine.exposures_20_with_outcome);

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

*----------------------------------------------------------------------------------------------;

/*CREATE VARIABLE FOR PRIOR HOSPITALIZATION */
*create inpatient dataset across all years;
data mine.inpatients_all; *roughly 20 million;
	set ccae.CCAEI083 ccae.CCAEI093 ccae.CCAEI103 ccae.CCAEI113 ccae.CCAEI123 ccae.CCAEI133 
		ccae.CCAEI143 ccae.CCAEI153 ccae.CCAEI162 ccae.CCAEI171 ccae.CCAEI181 ccae.CCAEI191
		ccae.CCAEI201;
	keep ENROLID DISDATE; *include discharge date;
	if missing(ENROLID) or AGE < 18
		then delete;
run;

%let inpatients = mine.inpatients_all;

%add_hospitalization(exposures=mine.exposures_08_with_outcome, inpatients=&inpatients, output=mine.exposures_08_with_outcome);
%add_hospitalization(exposures=mine.exposures_09_with_outcome, inpatients=&inpatients, output=mine.exposures_09_with_outcome);
%add_hospitalization(exposures=mine.exposures_10_with_outcome, inpatients=&inpatients, output=mine.exposures_10_with_outcome);
%add_hospitalization(exposures=mine.exposures_11_with_outcome, inpatients=&inpatients, output=mine.exposures_11_with_outcome);
%add_hospitalization(exposures=mine.exposures_12_with_outcome, inpatients=&inpatients, output=mine.exposures_12_with_outcome);
%add_hospitalization(exposures=mine.exposures_13_with_outcome, inpatients=&inpatients, output=mine.exposures_13_with_outcome);
%add_hospitalization(exposures=mine.exposures_14_with_outcome, inpatients=&inpatients, output=mine.exposures_14_with_outcome);
%add_hospitalization(exposures=mine.exposures_15_with_outcome, inpatients=&inpatients, output=mine.exposures_15_with_outcome);
%add_hospitalization(exposures=mine.exposures_16_with_outcome, inpatients=&inpatients, output=mine.exposures_16_with_outcome);
%add_hospitalization(exposures=mine.exposures_17_with_outcome, inpatients=&inpatients, output=mine.exposures_17_with_outcome);
%add_hospitalization(exposures=mine.exposures_18_with_outcome, inpatients=&inpatients, output=mine.exposures_18_with_outcome);
%add_hospitalization(exposures=mine.exposures_19_with_outcome, inpatients=&inpatients, output=mine.exposures_19_with_outcome);
%add_hospitalization(exposures=mine.exposures_20_with_outcome, inpatients=&inpatients, output=mine.exposures_20_with_outcome);

*----------------------------------------------------------------------------------------------;

/*CREATE VARIABLE FOR CHARLSON COMORBIDITY INDEX (CCI) */
/*diagnosis codes for comorbidities (first line is ICD-9, second line is ICD-10) */
*Myocardial Infarction;		
%let cc_grp_1_codes = ('410','412', 'I21', 'I22','I252');
*Congestive Heart Failure;
%let cc_grp_2_codes = ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493', '4254','4255','4257','4258','4259','428', 
				'I43','I50','I099','I110','I130','I132','I255','I420','I425','I426', 'I427','I428','I429','P290');
*Peripheral Vascular Disease;
%let cc_grp_3_codes = ('0930','4373','440','441','4431','4432','4438','4439','4471','5571','5579','V434',
				'I70','I71','I731','I738','I739','I771','I790','I792','K551','K558','K559','Z958','Z959');
*Cerebrovascular Disease;
%let cc_grp_4_codes = ('36234','430','431','432','433','434','435','436','437','438',
				'G45','G46','I60','I61','I62','I63','I64','I65','I66','I67','I68','I69','H340');
*Dementia;
%let cc_grp_5_codes = ('290','2941','3312', 
				'F00','F01','F02','F03','G30','F051','G311');
*Chronic Pulmonary Disease;
%let cc_grp_6_codes = ('4168','4169','490','491','492','493','494','495','496','500','501','502','503', '504','505','5064','5081','5088',
				'J40','J41','J42','J43','J44','J45','J46','J47','J60','J61','J62','J63', 'J64','J65','J66','J67','I278','I279','J684','J701','J703');
*Connective Tissue Disease-Rheumatic Disease;
%let cc_grp_7_codes = ('4465','7100','7101','7102','7103','7104','7140','7141','7142','7148','725',
				'M05','M32','M33','M34','M06','M315','M351','M353','M360');
*Peptic Ulcer Disease;
%let cc_grp_8_codes = ('531','532','533','534',
				'K25','K26','K27','K28');
*Mild Liver Disease;
%let cc_grp_9_codes = ('07022','07023','07032','07033','07044','07054','0706','0709','570','571','5733','5734','5738','5739','V427',
				'B18','K73','K74','K700','K701','K702','K703','K709','K717','K713','K714','K715','K760','K762','K763','K764','K768','K769','Z944');
*Diabetes without complications;
%let cc_grp_10_codes = ('2500','2501','2502','2503','2508','2509',
				'E100','E101','E106','E108','E109','E110','E111','E116','E118','E119','E120','E121','E126','E128','E129','E130','E131','E136','E138','E139','E140','E141','E146','E148','E149');
*Diabetes with complications;
%let cc_grp_11_codes = ('2504','2505','2506','2507',
				'E102','E103','E104','E105','E107','E112','E113','E114','E115','E117','E122','E123','E124','E125','E127','E132','E133','E134','E135','E137','E142','E143','E144','E145','E147');
*Paraplegia and Hemiplegia;
%let cc_grp_12_codes = ('3341','342','343','3440','3441','3442','3443','3444','3445','3446','3449', 
				'G81','G82','G041','G114','G801','G802','G830','G831','G832','G833','G834','G839');
*Renal Disease;
%let cc_grp_13_codes = ('40301','40311','40391','40402','40403','40412','40413','40492','40493','582','5830','5831','5832','5834','5836','5837','585','586','5880','V420','V451','V56',
				'N18','N19','N052','N053','N054','N055','N056','N057','N250','I120','I131','N032','N033','N034','N035','N036','N037','Z490','Z491','Z492','Z940','Z992');
*Cancer;
%let cc_grp_14_codes = ('140','141','142','143','144','145','146','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','170','171',
						'172','174','175','176','179','180','181','182','183','184','185','186','187','188','189','190','191','192','193','194','195','200','201','202','203','204','205',
						'206','207','208','2386', 'C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11',
                  'C12','C13','C14','C15','C16','C17','C18','C19','C20','C21','C22','C23','C24','C25','C26','C30','C31','C32','C33','C34','C37','C38','C39','C40','C41','C43','C45','C46',
                  		'C47','C48','C49','C50','C51','C52','C53','C54','C55','C56','C57','C58','C60','C61','C62','C63','C64','C65','C66','C67','C68','C69','C70','C71','C72','C73','C74',
                  		'C75','C76','C81','C82','C83','C84','C85','C88','C90','C91','C92','C93','C94','C95','C96','C97');
*Moderate or Severe Liver Disease;
%let cc_grp_15_codes = ('4560','4561','4562','5722','5723','5724','5728',
				'K704','K711','K721','K729','K765','K766','K767','I850','I859','I864','I982');
*Metastatic Carcinoma;
%let cc_grp_16_codes = ('196','197','198','199', 
				'C77','C78','C79','C80');
*AIDS/HIV;
%let cc_grp_17_codes = ('042','043','044',
				'B20','B21','B22','B24');	

*first, sort all exposures datasets by ENROLID and SVCDATE;
%sort_exposures(input=mine.exposures_08_with_outcome, output=mine.exposures_08_with_outcome);
%sort_exposures(input=mine.exposures_09_with_outcome, output=mine.exposures_09_with_outcome);
%sort_exposures(input=mine.exposures_10_with_outcome, output=mine.exposures_10_with_outcome);
%sort_exposures(input=mine.exposures_11_with_outcome, output=mine.exposures_11_with_outcome);
%sort_exposures(input=mine.exposures_12_with_outcome, output=mine.exposures_12_with_outcome);
%sort_exposures(input=mine.exposures_13_with_outcome, output=mine.exposures_13_with_outcome);
%sort_exposures(input=mine.exposures_14_with_outcome, output=mine.exposures_14_with_outcome);
%sort_exposures(input=mine.exposures_15_with_outcome, output=mine.exposures_15_with_outcome);
%sort_exposures(input=mine.exposures_16_with_outcome, output=mine.exposures_16_with_outcome);
%sort_exposures(input=mine.exposures_17_with_outcome, output=mine.exposures_17_with_outcome);
%sort_exposures(input=mine.exposures_18_with_outcome, output=mine.exposures_18_with_outcome);
%sort_exposures(input=mine.exposures_19_with_outcome, output=mine.exposures_19_with_outcome);
%sort_exposures(input=mine.exposures_20_with_outcome, output=mine.exposures_20_with_outcome);

*then, generate comorbidity data for each exposures dataset;
%add_comorbidities_08(exposures=mine.exposures_08_with_outcome, inpatients=ccae.ccaei083, outpatients=ccae.ccaeo083, output=mine.exposures_08_complete);
%add_comorbidities_09(exposures=mine.exposures_09_with_outcome, inpatients1=ccae.ccaei083, inpatients2=ccae.ccaei093, outpatients1=ccae.ccaeo083, outpatients2=ccae.ccaeo093, output=mine.exposures_09_complete);
%add_comorbidities(exposures=mine.exposures_10_with_outcome, inpatients1=ccae.ccaei093, inpatients2=ccae.ccaei103, outpatients1=ccae.ccaeo093, outpatients2=ccae.ccaeo103, output=mine.exposures_10_complete);
%add_comorbidities(exposures=mine.exposures_11_with_outcome, inpatients1=ccae.ccaei103, inpatients2=ccae.ccaei113, outpatients1=ccae.ccaeo103, outpatients2=ccae.ccaeo113, output=mine.exposures_11_complete);
%add_comorbidities(exposures=mine.exposures_12_with_outcome, inpatients1=ccae.ccaei113, inpatients2=ccae.ccaei123, outpatients1=ccae.ccaeo113, outpatients2=ccae.ccaeo123, output=mine.exposures_12_complete);
%add_comorbidities(exposures=mine.exposures_13_with_outcome, inpatients1=ccae.ccaei123, inpatients2=ccae.ccaei133, outpatients1=ccae.ccaeo123, outpatients2=ccae.ccaeo133, output=mine.exposures_13_complete);
%add_comorbidities(exposures=mine.exposures_14_with_outcome, inpatients1=ccae.ccaei133, inpatients2=ccae.ccaei143, outpatients1=ccae.ccaeo133, outpatients2=ccae.ccaeo143, output=mine.exposures_14_complete);
%add_comorbidities(exposures=mine.exposures_15_with_outcome, inpatients1=ccae.ccaei143, inpatients2=ccae.ccaei153, outpatients1=ccae.ccaeo143, outpatients2=ccae.ccaeo153, output=mine.exposures_15_complete);
%add_comorbidities(exposures=mine.exposures_16_with_outcome, inpatients1=ccae.ccaei153, inpatients2=ccae.ccaei162, outpatients1=ccae.ccaeo153, outpatients2=ccae.ccaeo162, output=mine.exposures_16_complete);
%add_comorbidities(exposures=mine.exposures_17_with_outcome, inpatients1=ccae.ccaei162, inpatients2=ccae.ccaei171, outpatients1=ccae.ccaeo162, outpatients2=ccae.ccaeo171, output=mine.exposures_17_complete);
%add_comorbidities(exposures=mine.exposures_18_with_outcome, inpatients1=ccae.ccaei171, inpatients2=ccae.ccaei181, outpatients1=ccae.ccaeo171, outpatients2=ccae.ccaeo181, output=mine.exposures_18_complete);
%add_comorbidities(exposures=mine.exposures_19_with_outcome, inpatients1=ccae.ccaei181, inpatients2=ccae.ccaei191, outpatients1=ccae.ccaeo181, outpatients2=ccae.ccaeo191, output=mine.exposures_19_complete);
%add_comorbidities(exposures=mine.exposures_20_with_outcome, inpatients1=ccae.ccaei191, inpatients2=ccae.ccaei201, outpatients1=ccae.ccaeo191, outpatients2=ccae.ccaeo201, output=mine.exposures_20_complete);

*add CCI variable to each year's dataset;
%add_cci(input=mine.exposures_08_complete, output=mine.exposures_08_complete);
%add_cci(input=mine.exposures_09_complete, output=mine.exposures_09_complete);
%add_cci(input=mine.exposures_10_complete, output=mine.exposures_10_complete);
%add_cci(input=mine.exposures_11_complete, output=mine.exposures_11_complete);
%add_cci(input=mine.exposures_12_complete, output=mine.exposures_12_complete);
%add_cci(input=mine.exposures_13_complete, output=mine.exposures_13_complete);
%add_cci(input=mine.exposures_14_complete, output=mine.exposures_14_complete);
%add_cci(input=mine.exposures_15_complete, output=mine.exposures_15_complete);
%add_cci(input=mine.exposures_16_complete, output=mine.exposures_16_complete);
%add_cci(input=mine.exposures_17_complete, output=mine.exposures_17_complete);
%add_cci(input=mine.exposures_18_complete, output=mine.exposures_18_complete);
%add_cci(input=mine.exposures_19_complete, output=mine.exposures_19_complete);
%add_cci(input=mine.exposures_20_complete, output=mine.exposures_20_complete);

*to get the frequency table of CCI values;
proc freq data=mine.exposures_08_complete;
	tables CCI;
run;

/*LIMIT ANALYSIS TO ONLY THE FIRST PRESCRIPTION CORRESPONDING TO EACH PATIENT*/
%sort_unique_patients(data=mine.exposures_08_complete, output=mine.exposures_08_unique_complete);
%sort_unique_patients(data=mine.exposures_09_complete, output=mine.exposures_09_unique_complete);
%sort_unique_patients(data=mine.exposures_10_complete, output=mine.exposures_10_unique_complete);
%sort_unique_patients(data=mine.exposures_11_complete, output=mine.exposures_11_unique_complete);
%sort_unique_patients(data=mine.exposures_12_complete, output=mine.exposures_12_unique_complete);
%sort_unique_patients(data=mine.exposures_13_complete, output=mine.exposures_13_unique_complete);
%sort_unique_patients(data=mine.exposures_14_complete, output=mine.exposures_14_unique_complete);
%sort_unique_patients(data=mine.exposures_15_complete, output=mine.exposures_15_unique_complete);
%sort_unique_patients(data=mine.exposures_16_complete, output=mine.exposures_16_unique_complete);
%sort_unique_patients(data=mine.exposures_17_complete, output=mine.exposures_17_unique_complete);
%sort_unique_patients(data=mine.exposures_18_complete, output=mine.exposures_18_unique_complete);
%sort_unique_patients(data=mine.exposures_19_complete, output=mine.exposures_19_unique_complete);
%sort_unique_patients(data=mine.exposures_20_complete, output=mine.exposures_20_unique_complete);