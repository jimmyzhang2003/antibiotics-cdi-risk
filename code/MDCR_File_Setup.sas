/* File_Setup.sas
Summary: setting up libraries and data files for the Medicare data
Created by: Jimmy Zhang @ 4/25/22
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
	CREATE TABLE mine.unique_adults_per_year_mdcr AS
	SELECT 2008 as YEAR, COUNT(DISTINCT drug_08_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_08_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2009 as YEAR, COUNT(DISTINCT drug_09_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_09_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2010 as YEAR, COUNT(DISTINCT drug_10_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_10_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2011 as YEAR, COUNT(DISTINCT drug_11_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_11_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2012 as YEAR, COUNT(DISTINCT drug_12_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_12_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2013 as YEAR, COUNT(DISTINCT drug_13_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_13_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2014 as YEAR, COUNT(DISTINCT drug_14_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_14_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2015 as YEAR, COUNT(DISTINCT drug_15_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_15_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2016 as YEAR, COUNT(DISTINCT drug_16_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_16_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2017 as YEAR, COUNT(DISTINCT drug_17_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_17_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2018 as YEAR, COUNT(DISTINCT drug_18_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_18_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2019 as YEAR, COUNT(DISTINCT drug_19_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_19_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_mdcr
	SELECT 2020 as YEAR, COUNT(DISTINCT drug_20_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_20_mdcr_view;
quit;

*create exposures dataset with above antibiotic classes and renamed variable names separated by year;
%rename_exposure_drugs(input=mine.drug_08_mdcr_view, output=mine.exposures_08_mdcr);
%rename_exposure_drugs(input=mine.drug_09_mdcr_view, output=mine.exposures_09_mdcr);
%rename_exposure_drugs(input=mine.drug_10_mdcr_view, output=mine.exposures_10_mdcr);
%rename_exposure_drugs(input=mine.drug_11_mdcr_view, output=mine.exposures_11_mdcr);
%rename_exposure_drugs(input=mine.drug_12_mdcr_view, output=mine.exposures_12_mdcr);
%rename_exposure_drugs(input=mine.drug_13_mdcr_view, output=mine.exposures_13_mdcr);
%rename_exposure_drugs(input=mine.drug_14_mdcr_view, output=mine.exposures_14_mdcr);
%rename_exposure_drugs(input=mine.drug_15_mdcr_view, output=mine.exposures_15_mdcr);
%rename_exposure_drugs(input=mine.drug_16_mdcr_view, output=mine.exposures_16_mdcr);
%rename_exposure_drugs(input=mine.drug_17_mdcr_view, output=mine.exposures_17_mdcr);
%rename_exposure_drugs(input=mine.drug_18_mdcr_view, output=mine.exposures_18_mdcr);
%rename_exposure_drugs(input=mine.drug_19_mdcr_view, output=mine.exposures_19_mdcr);
%rename_exposure_drugs(input=mine.drug_20_mdcr_view, output=mine.exposures_20_mdcr);

*get drug frequencies for each year;
%get_drug_freq(input=mine.exposures_08_mdcr, output=mine.drugs_freq_08_mdcr, year=2008);
%get_drug_freq(input=mine.exposures_09_mdcr, output=mine.drugs_freq_09_mdcr, year=2009);
%get_drug_freq(input=mine.exposures_10_mdcr, output=mine.drugs_freq_10_mdcr, year=2010);
%get_drug_freq(input=mine.exposures_11_mdcr, output=mine.drugs_freq_11_mdcr, year=2011);
%get_drug_freq(input=mine.exposures_12_mdcr, output=mine.drugs_freq_12_mdcr, year=2012);
%get_drug_freq(input=mine.exposures_13_mdcr, output=mine.drugs_freq_13_mdcr, year=2013);
%get_drug_freq(input=mine.exposures_14_mdcr, output=mine.drugs_freq_14_mdcr, year=2014);
%get_drug_freq(input=mine.exposures_15_mdcr, output=mine.drugs_freq_15_mdcr, year=2015);
%get_drug_freq(input=mine.exposures_16_mdcr, output=mine.drugs_freq_16_mdcr, year=2016);
%get_drug_freq(input=mine.exposures_17_mdcr, output=mine.drugs_freq_17_mdcr, year=2017);
%get_drug_freq(input=mine.exposures_18_mdcr, output=mine.drugs_freq_18_mdcr, year=2018);
%get_drug_freq(input=mine.exposures_19_mdcr, output=mine.drugs_freq_19_mdcr, year=2019);
%get_drug_freq(input=mine.exposures_20_mdcr, output=mine.drugs_freq_20_mdcr, year=2020);

*join all drug freq datasets together;
data mine.drugs_freq_all_by_year_mdcr;
	set mine.drugs_freq_08_mdcr mine.drugs_freq_09_mdcr mine.drugs_freq_10_mdcr mine.drugs_freq_11_mdcr
		 mine.drugs_freq_12_mdcr mine.drugs_freq_13_mdcr mine.drugs_freq_14_mdcr mine.drugs_freq_15_mdcr
		 mine.drugs_freq_16_mdcr mine.drugs_freq_17_mdcr mine.drugs_freq_18_mdcr mine.drugs_freq_19_mdcr
		 mine.drugs_freq_20_mdcr;
run;	

*add column denoting total number of unique patients for that year (based on unique_adults_per_year_mdcr);
data mine.drugs_freq_all_by_year_mdcr;
	set mine.drugs_freq_all_by_year_mdcr;
	select (year(YEAR));
		when (2008) NUM_UNIQUE_PATIENTS = 2701736;
		when (2009) NUM_UNIQUE_PATIENTS = 2588960;
		when (2010) NUM_UNIQUE_PATIENTS = 2854563;
		when (2011) NUM_UNIQUE_PATIENTS = 3377107;
		when (2012) NUM_UNIQUE_PATIENTS = 3183488;
		when (2013) NUM_UNIQUE_PATIENTS = 2920662;
		when (2014) NUM_UNIQUE_PATIENTS = 2418515;
		when (2015) NUM_UNIQUE_PATIENTS = 1909400;
		when (2016) NUM_UNIQUE_PATIENTS = 1850141;
		when (2017) NUM_UNIQUE_PATIENTS = 1276630;
		when (2018) NUM_UNIQUE_PATIENTS = 1017038;
		when (2019) NUM_UNIQUE_PATIENTS = 898314;
		when (2020) NUM_UNIQUE_PATIENTS = 880625;
		otherwise NUM_UNIQUE_PATIENTS = .;
	end;
run;

*add columns denoting number of 1000 person-years (i.e. just divide by 1000) and normalized count;
data mine.drugs_freq_all_by_year_mdcr;
	set mine.drugs_freq_all_by_year_mdcr;
	COUNT_PER_1000_PERSON_YEARS = COUNT / (NUM_UNIQUE_PATIENTS/ 1000);
	select (strip(upcase(DRUGNAME)));
		when ('AMOXICILLIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 221.25403814;
		when ('AZITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 192.70794778;
		when ('FLUOROQUINOLONES') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 333.80907683;
		when ('CEPHALEXIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 117.1628168;
		when ('CLINDAMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 49.268322294;
		when ('DOXYCYCLINE') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 64.485575201;
		when ('NITROFURANTOIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 69.310250891;
		when ('PENICILLIN VK') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 22.928220966;
		when ('CLARITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 20.741848945;
		when ('CEFDINIR') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 11.582182715;
		when ('CEFUROXIME') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 17.705282826;
		otherwise COUNT_NORM = .;
	end;
run;

*----------------------------------------------------------------------------------------------;

/***** CREATING OUTCOMES DATASETS *****/
/* we define a CDI outcome as having the appropriate diagnostic codes for CDI AND receipt any of the three drugs,
(vanco, metro, or dificid), within a +/- two-week window of the diagnosis*/
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

data mine.outcomes_all_mdcr;
	set mine.outcomes_08_mdcr mine.outcomes_09_mdcr mine.outcomes_10_mdcr mine.outcomes_11_mdcr mine.outcomes_12_mdcr
		mine.outcomes_13_mdcr mine.outcomes_14_mdcr mine.outcomes_15_mdcr mine.outcomes_16_mdcr mine.outcomes_17_mdcr
		mine.outcomes_18_mdcr mine.outcomes_19_mdcr mine.outcomes_20_mdcr;
run;

/* DX Codes for CDiff: ICD9 (00845), ICD10 (A047, A0471, and A0472)  */
*create table of all CDI diagnoses across all years;
data mine.cdi_diagnoses_mdcr;
	set mdcr.mdcro083 mdcr.mdcro093 mdcr.mdcro103 mdcr.mdcro113 mdcr.mdcro123 mdcr.mdcro133
		mdcr.mdcro143 mdcr.mdcro153 mdcr.mdcro162 mdcr.mdcro171 mdcr.mdcro181 mdcr.mdcro191
		mdcr.mdcro201;
	if ENROLID = . then delete;
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
	CREATE TABLE mine.all_cdi_outcomes_mdcr AS
	SELECT cdi_diagnoses_mdcr.*, outcomes_all_mdcr.DRUGNAME, outcomes_all_mdcr.SVCDATE AS OUTCOME_DRUG_SVCDATE
	FROM mine.cdi_diagnoses_mdcr INNER JOIN mine.outcomes_all_mdcr
	ON cdi_diagnoses_mdcr.ENROLID = outcomes_all_mdcr.ENROLID
		AND outcomes_all_mdcr.SVCDATE >= cdi_diagnoses_mdcr.SVCDATE - 14 
		AND outcomes_all_mdcr.SVCDATE <= cdi_diagnoses_mdcr.SVCDATE + 14;
quit;

*remove duplicates from CDI outcomes (all rows with same ENROLID and SVCDATE);
proc sort data=mine.all_cdi_outcomes_mdcr out=mine.all_cdi_outcomes_no_dups_mdcr nodupkey;
	by ENROLID SVCDATE;
run;

%let outcomes = mine.all_cdi_outcomes_no_dups_mdcr;
	
%create_CDI_flag(exposures=mine.exposures_08_mdcr, outcomes=&outcomes, output=mine.exposures_08_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_09_mdcr, outcomes=&outcomes, output=mine.exposures_09_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_10_mdcr, outcomes=&outcomes, output=mine.exposures_10_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_11_mdcr, outcomes=&outcomes, output=mine.exposures_11_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_12_mdcr, outcomes=&outcomes, output=mine.exposures_12_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_13_mdcr, outcomes=&outcomes, output=mine.exposures_13_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_14_mdcr, outcomes=&outcomes, output=mine.exposures_14_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_15_mdcr, outcomes=&outcomes, output=mine.exposures_15_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_16_mdcr, outcomes=&outcomes, output=mine.exposures_16_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_17_mdcr, outcomes=&outcomes, output=mine.exposures_17_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_18_mdcr, outcomes=&outcomes, output=mine.exposures_18_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_19_mdcr, outcomes=&outcomes, output=mine.exposures_19_with_outcome_mdcr);
%create_CDI_flag(exposures=mine.exposures_20_mdcr, outcomes=&outcomes, output=mine.exposures_20_with_outcome_mdcr);

*to get frequencies of CDI incidence by year;
data mine.exposures_all_outcome_mdcr_view / view=mine.exposures_all_outcome_mdcr_view;
	set mine.exposures_08_with_outcome_mdcr mine.exposures_09_with_outcome_mdcr mine.exposures_10_with_outcome_mdcr mine.exposures_11_with_outcome_mdcr
		mine.exposures_12_with_outcome_mdcr mine.exposures_13_with_outcome_mdcr mine.exposures_14_with_outcome_mdcr mine.exposures_15_with_outcome_mdcr
		mine.exposures_16_with_outcome_mdcr mine.exposures_17_with_outcome_mdcr mine.exposures_18_with_outcome_mdcr mine.exposures_19_with_outcome_mdcr
		mine.exposures_20_with_outcome_mdcr;
run;

proc freq data=mine.exposures_all_outcome_mdcr_view;
	tables CDI_FLAG*YEAR / out=mine.cdi_outcomes_by_year_mdcr;
run; *~221,000 outcomes

*----------------------------------------------------------------------------------------------;

/*CREATE VARIABLE FOR PRIOR HOSPITALIZATION */
*create inpatient dataset across all years;
data mine.inpatients_all_mdcr; 
	set mdcr.mdcri083 mdcr.mdcri093 mdcr.mdcri103 mdcr.mdcri113 mdcr.mdcri123 mdcr.mdcri133 
		mdcr.mdcri143 mdcr.mdcri153 mdcr.mdcri162 mdcr.mdcri171 mdcr.mdcri181 mdcr.mdcri191 
		mdcr.mdcri201;
	keep ENROLID DISDATE; *include discharge date;
	if missing(ENROLID)
		then delete;
run;

%let inpatients = mine.inpatients_all_mdcr;

%add_hospitalization(exposures=mine.exposures_08_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_08_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_09_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_09_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_10_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_10_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_11_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_11_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_12_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_12_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_13_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_13_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_14_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_14_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_15_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_15_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_16_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_16_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_17_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_17_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_18_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_18_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_19_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_19_with_outcome_mdcr);
%add_hospitalization(exposures=mine.exposures_20_with_outcome_mdcr, inpatients=&inpatients, output=mine.exposures_20_with_outcome_mdcr);
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
%sort_exposures(input=mine.exposures_08_with_outcome_mdcr, output=mine.exposures_08_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_09_with_outcome_mdcr, output=mine.exposures_09_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_10_with_outcome_mdcr, output=mine.exposures_10_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_11_with_outcome_mdcr, output=mine.exposures_11_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_12_with_outcome_mdcr, output=mine.exposures_12_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_13_with_outcome_mdcr, output=mine.exposures_13_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_14_with_outcome_mdcr, output=mine.exposures_14_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_15_with_outcome_mdcr, output=mine.exposures_15_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_16_with_outcome_mdcr, output=mine.exposures_16_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_17_with_outcome_mdcr, output=mine.exposures_17_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_18_with_outcome_mdcr, output=mine.exposures_18_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_19_with_outcome_mdcr, output=mine.exposures_19_with_outcome_mdcr);
%sort_exposures(input=mine.exposures_20_with_outcome_mdcr, output=mine.exposures_20_with_outcome_mdcr);

*then, generate comorbidity data for each exposures dataset;
%add_comorbidities_08(exposures=mine.exposures_08_with_outcome_mdcr, inpatients=mdcr.mdcri083, outpatients=mdcr.mdcro083, output=mine.exposures_08_complete_mdcr_mdcr);
%add_comorbidities_09(exposures=mine.exposures_09_with_outcome_mdcr, inpatients1=mdcr.mdcri083, inpatients2=mdcr.mdcri093, outpatients1=mdcr.mdcro083, outpatients2=mdcr.mdcro093, output=mine.exposures_09_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_10_with_outcome_mdcr, inpatients1=mdcr.mdcri093, inpatients2=mdcr.mdcri103, outpatients1=mdcr.mdcro093, outpatients2=mdcr.mdcro103, output=mine.exposures_10_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_11_with_outcome_mdcr, inpatients1=mdcr.mdcri103, inpatients2=mdcr.mdcri113, outpatients1=mdcr.mdcro103, outpatients2=mdcr.mdcro113, output=mine.exposures_11_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_12_with_outcome_mdcr, inpatients1=mdcr.mdcri113, inpatients2=mdcr.mdcri123, outpatients1=mdcr.mdcro113, outpatients2=mdcr.mdcro123, output=mine.exposures_12_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_13_with_outcome_mdcr, inpatients1=mdcr.mdcri123, inpatients2=mdcr.mdcri133, outpatients1=mdcr.mdcro123, outpatients2=mdcr.mdcro133, output=mine.exposures_13_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_14_with_outcome_mdcr, inpatients1=mdcr.mdcri133, inpatients2=mdcr.mdcri143, outpatients1=mdcr.mdcro133, outpatients2=mdcr.mdcro143, output=mine.exposures_14_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_15_with_outcome_mdcr, inpatients1=mdcr.mdcri143, inpatients2=mdcr.mdcri153, outpatients1=mdcr.mdcro143, outpatients2=mdcr.mdcro153, output=mine.exposures_15_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_16_with_outcome_mdcr, inpatients1=mdcr.mdcri153, inpatients2=mdcr.mdcri162, outpatients1=mdcr.mdcro153, outpatients2=mdcr.mdcro162, output=mine.exposures_16_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_17_with_outcome_mdcr, inpatients1=mdcr.mdcri162, inpatients2=mdcr.mdcri171, outpatients1=mdcr.mdcro162, outpatients2=mdcr.mdcro171, output=mine.exposures_17_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_18_with_outcome_mdcr, inpatients1=mdcr.mdcri171, inpatients2=mdcr.mdcri181, outpatients1=mdcr.mdcro171, outpatients2=mdcr.mdcro181, output=mine.exposures_18_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_19_with_outcome_mdcr, inpatients1=mdcr.mdcri181, inpatients2=mdcr.mdcri191, outpatients1=mdcr.mdcro181, outpatients2=mdcr.mdcro191, output=mine.exposures_19_complete_mdcr_mdcr);
%add_comorbidities(exposures=mine.exposures_20_with_outcome_mdcr, inpatients1=mdcr.mdcri191, inpatients2=mdcr.mdcri201, outpatients1=mdcr.mdcro191, outpatients2=mdcr.mdcro201, output=mine.exposures_20_complete_mdcr_mdcr);

*add CCI variable to each year's dataset;
%add_cci(input=mine.exposures_08_complete_mdcr, output=mine.exposures_08_complete_mdcr);
%add_cci(input=mine.exposures_09_complete_mdcr, output=mine.exposures_09_complete_mdcr);
%add_cci(input=mine.exposures_10_complete_mdcr, output=mine.exposures_10_complete_mdcr);
%add_cci(input=mine.exposures_11_complete_mdcr, output=mine.exposures_11_complete_mdcr);
%add_cci(input=mine.exposures_12_complete_mdcr, output=mine.exposures_12_complete_mdcr);
%add_cci(input=mine.exposures_13_complete_mdcr, output=mine.exposures_13_complete_mdcr);
%add_cci(input=mine.exposures_14_complete_mdcr, output=mine.exposures_14_complete_mdcr);
%add_cci(input=mine.exposures_15_complete_mdcr, output=mine.exposures_15_complete_mdcr);
%add_cci(input=mine.exposures_16_complete_mdcr, output=mine.exposures_16_complete_mdcr);
%add_cci(input=mine.exposures_17_complete_mdcr, output=mine.exposures_17_complete_mdcr);
%add_cci(input=mine.exposures_18_complete_mdcr, output=mine.exposures_18_complete_mdcr);
%add_cci(input=mine.exposures_19_complete_mdcr, output=mine.exposures_19_complete_mdcr);
%add_cci(input=mine.exposures_19_complete_mdcr, output=mine.exposures_19_complete_mdcr);
%add_cci(input=mine.exposures_20_complete_mdcr, output=mine.exposures_20_complete_mdcr);

*to get the frequency table of CCI values;
proc freq data=mine.exposures_08_complete_mdcr;
	tables CCI;
run;

/*LIMIT ANALYSIS TO ONLY THE FIRST PRESCRIPTION CORRESPONDING TO EACH PATIENT*/
%sort_unique_patients(data=mine.exposures_08_complete_mdcr, output=mine.exposures_08_unique_mdcr);
%sort_unique_patients(data=mine.exposures_09_complete_mdcr, output=mine.exposures_09_unique_mdcr);
%sort_unique_patients(data=mine.exposures_10_complete_mdcr, output=mine.exposures_10_unique_mdcr);
%sort_unique_patients(data=mine.exposures_11_complete_mdcr, output=mine.exposures_11_unique_mdcr);
%sort_unique_patients(data=mine.exposures_12_complete_mdcr, output=mine.exposures_12_unique_mdcr);
%sort_unique_patients(data=mine.exposures_13_complete_mdcr, output=mine.exposures_13_unique_mdcr);
%sort_unique_patients(data=mine.exposures_14_complete_mdcr, output=mine.exposures_14_unique_mdcr);
%sort_unique_patients(data=mine.exposures_15_complete_mdcr, output=mine.exposures_15_unique_mdcr);
%sort_unique_patients(data=mine.exposures_16_complete_mdcr, output=mine.exposures_16_unique_mdcr);
%sort_unique_patients(data=mine.exposures_17_complete_mdcr, output=mine.exposures_17_unique_mdcr);
%sort_unique_patients(data=mine.exposures_18_complete_mdcr, output=mine.exposures_18_unique_mdcr);
%sort_unique_patients(data=mine.exposures_19_complete_mdcr, output=mine.exposures_19_unique_mdcr);
%sort_unique_patients(data=mine.exposures_20_complete_mdcr, output=mine.exposures_20_unique_mdcr);