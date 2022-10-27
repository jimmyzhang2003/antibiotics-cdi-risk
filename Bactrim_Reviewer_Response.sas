/* Bactrim_Reviewer_Response.sas
Summary: additional analysis on bactrim (response to reviewer)
Created by: Jimmy Zhang @ 10/3/22
Modified by: Jimmy Zhang @ 10/12/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

/***** CREATING NEW DATASETS WITH BACTRIM (SMZ/TMP) *****/
*macro function for renaming bactrim in datasets;
%MACRO rename_bactrim(input1=, input2=, output=);
	data &output;
		set &input1 &input2;
		format DRUGNAME $20.;
		select (THERDTL);
			when (824010030) DRUGNAME = "SMZ/TMP";
			otherwise delete;
		end;
		*keep all identifiers and covars;
		keep ENROLID SVCDATE YEAR DRUGNAME SEQNUM AGE AGEGRP SEX REGION;
%MEND;

%rename_bactrim(input1=mine.drug_08_view, input2=mine.drug_08_mdcr_view, output=mine.exposures_08_bactrim);
%rename_bactrim(input1=mine.drug_09_view, input2=mine.drug_09_mdcr_view, output=mine.exposures_09_bactrim);
%rename_bactrim(input1=mine.drug_10_view, input2=mine.drug_10_mdcr_view, output=mine.exposures_10_bactrim);
%rename_bactrim(input1=mine.drug_11_view, input2=mine.drug_11_mdcr_view, output=mine.exposures_11_bactrim);
%rename_bactrim(input1=mine.drug_12_view, input2=mine.drug_12_mdcr_view, output=mine.exposures_12_bactrim);
%rename_bactrim(input1=mine.drug_13_view, input2=mine.drug_13_mdcr_view, output=mine.exposures_13_bactrim);
%rename_bactrim(input1=mine.drug_14_view, input2=mine.drug_14_mdcr_view, output=mine.exposures_14_bactrim);
%rename_bactrim(input1=mine.drug_15_view, input2=mine.drug_15_mdcr_view, output=mine.exposures_15_bactrim);
%rename_bactrim(input1=mine.drug_16_view, input2=mine.drug_16_mdcr_view, output=mine.exposures_16_bactrim);
%rename_bactrim(input1=mine.drug_17_view, input2=mine.drug_17_mdcr_view, output=mine.exposures_17_bactrim);
%rename_bactrim(input1=mine.drug_18_view, input2=mine.drug_18_mdcr_view, output=mine.exposures_18_bactrim);
%rename_bactrim(input1=mine.drug_19_view, input2=mine.drug_19_mdcr_view, output=mine.exposures_19_bactrim);
%rename_bactrim(input1=mine.drug_20_view, input2=mine.drug_20_mdcr_view, output=mine.exposures_20_bactrim);

*limit analysis to first antibiotic prescription corresponding to each unique patient;
%sort_unique_patients(data=mine.exposures_08_bactrim, output=mine.exposures_08_bactrim_unique);
%sort_unique_patients(data=mine.exposures_09_bactrim, output=mine.exposures_09_bactrim_unique);
%sort_unique_patients(data=mine.exposures_10_bactrim, output=mine.exposures_10_bactrim_unique);
%sort_unique_patients(data=mine.exposures_11_bactrim, output=mine.exposures_11_bactrim_unique);
%sort_unique_patients(data=mine.exposures_12_bactrim, output=mine.exposures_12_bactrim_unique);
%sort_unique_patients(data=mine.exposures_13_bactrim, output=mine.exposures_13_bactrim_unique);
%sort_unique_patients(data=mine.exposures_14_bactrim, output=mine.exposures_14_bactrim_unique);
%sort_unique_patients(data=mine.exposures_15_bactrim, output=mine.exposures_15_bactrim_unique);
%sort_unique_patients(data=mine.exposures_16_bactrim, output=mine.exposures_16_bactrim_unique);
%sort_unique_patients(data=mine.exposures_17_bactrim, output=mine.exposures_17_bactrim_unique);
%sort_unique_patients(data=mine.exposures_18_bactrim, output=mine.exposures_18_bactrim_unique);
%sort_unique_patients(data=mine.exposures_19_bactrim, output=mine.exposures_19_bactrim_unique);
%sort_unique_patients(data=mine.exposures_20_bactrim, output=mine.exposures_20_bactrim_unique);

*create variable corresponding to CDI diagnosis;
%let outcomes = mine.all_cdi_outcomes_no_dups;

%create_CDI_flag(exposures=mine.exposures_08_bactrim_unique, outcomes=&outcomes, output=mine.exposures_08_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_09_bactrim_unique, outcomes=&outcomes, output=mine.exposures_09_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_10_bactrim_unique, outcomes=&outcomes, output=mine.exposures_10_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_11_bactrim_unique, outcomes=&outcomes, output=mine.exposures_11_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_12_bactrim_unique, outcomes=&outcomes, output=mine.exposures_12_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_13_bactrim_unique, outcomes=&outcomes, output=mine.exposures_13_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_14_bactrim_unique, outcomes=&outcomes, output=mine.exposures_14_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_15_bactrim_unique, outcomes=&outcomes, output=mine.exposures_15_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_16_bactrim_unique, outcomes=&outcomes, output=mine.exposures_16_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_17_bactrim_unique, outcomes=&outcomes, output=mine.exposures_17_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_18_bactrim_unique, outcomes=&outcomes, output=mine.exposures_18_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_19_bactrim_unique, outcomes=&outcomes, output=mine.exposures_19_bactrim_outcome);
%create_CDI_flag(exposures=mine.exposures_20_bactrim_unique, outcomes=&outcomes, output=mine.exposures_20_bactrim_outcome);

*----------------------------------------------------------------------------------------------;

/***** CONTINUOUS ENROLLMENT *****/
*limit analysis to patients with continuous enrollment;
*2008;
%cont_enroll_prior_0(exposures=mine.exposures_08_bactrim_outcome, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_08, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_09, output=mine.exposures_08_bactrim_enrolled);

*2009;
%cont_enroll_prior_1(exposures=mine.exposures_09_bactrim_outcome, enrollment=mine.full_enrollment_08, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_09, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_10, output=mine.exposures_09_bactrim_enrolled);

*2010;
%cont_enroll_prior_1(exposures=mine.exposures_10_bactrim_outcome, enrollment=mine.full_enrollment_09, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_10, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_11, output=mine.exposures_10_bactrim_enrolled);

*2011;
%cont_enroll_prior_1(exposures=mine.exposures_11_bactrim_outcome, enrollment=mine.full_enrollment_10, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_11, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_12, output=mine.exposures_11_bactrim_enrolled);

*2012;
%cont_enroll_prior_1(exposures=mine.exposures_12_bactrim_outcome, enrollment=mine.full_enrollment_11, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_12, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_13, output=mine.exposures_12_bactrim_enrolled);

*2013;
%cont_enroll_prior_1(exposures=mine.exposures_13_bactrim_outcome, enrollment=mine.full_enrollment_12, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_13, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_14, output=mine.exposures_13_bactrim_enrolled);

*2014;
%cont_enroll_prior_1(exposures=mine.exposures_14_bactrim_outcome, enrollment=mine.full_enrollment_13, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_14, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_15, output=mine.exposures_14_bactrim_enrolled);

*2015;
%cont_enroll_prior_1(exposures=mine.exposures_15_bactrim_outcome, enrollment=mine.full_enrollment_14, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_15, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_16, output=mine.exposures_15_bactrim_enrolled);

*2016;
%cont_enroll_prior_1(exposures=mine.exposures_16_bactrim_outcome, enrollment=mine.full_enrollment_15, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_16, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_17, output=mine.exposures_16_bactrim_enrolled);

*2017;
%cont_enroll_prior_1(exposures=mine.exposures_17_bactrim_outcome, enrollment=mine.full_enrollment_16, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_17, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_18, output=mine.exposures_17_bactrim_enrolled);

*2018;
%cont_enroll_prior_1(exposures=mine.exposures_18_bactrim_outcome, enrollment=mine.full_enrollment_17, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_18, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_19, output=mine.exposures_18_bactrim_enrolled);

*2019;
%cont_enroll_prior_1(exposures=mine.exposures_19_bactrim_outcome, enrollment=mine.full_enrollment_18, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_19, output=tmp.out2);
%cont_enroll_after_1(exposures=tmp.out2, enrollment=mine.full_enrollment_20, output=mine.exposures_19_bactrim_enrolled);

*2020;
%cont_enroll_prior_1(exposures=mine.exposures_20_bactrim_outcome, enrollment=mine.full_enrollment_19, output=tmp.out1);
%cont_enroll_curr(exposures=tmp.out1, enrollment=mine.full_enrollment_20, output=tmp.out2);
%cont_enroll_after_0(exposures=tmp.out2, output=mine.exposures_20_bactrim_enrolled);

*----------------------------------------------------------------------------------------------;

/***** ADD PRIOR HOSPITALIZATION VARIABLE *****/
%let inpatients = mine.inpatients_all;

%add_hospitalization(exposures=mine.exposures_08_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_08_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_09_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_09_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_10_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_10_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_11_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_11_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_12_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_12_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_13_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_13_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_14_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_14_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_15_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_15_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_16_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_16_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_17_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_17_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_18_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_18_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_19_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_19_bactrim_hosp);
%add_hospitalization(exposures=mine.exposures_20_bactrim_enrolled, inpatients=&inpatients, output=mine.exposures_20_bactrim_hosp);

*----------------------------------------------------------------------------------------------;

/***** CREATE VARIABLE FOR CHARLSON COMORBIDITY INDEX (CCI) *****/
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
				
*add additional category for codes that indicate patient is prescribed bactrim as a prophylactic (i.e., HIV, organ transplant, and cancer);
%let prophylaxis_symptom_codes = ('042','043','044','V42','V420','V421','V422','V423','V424','V425','V426','V427',
										'V428', 'V4281','V4282','V4283','V4284','V4289','V429',
				'B20','B21','B22','B24','Z94','Z941','Z942','Z943','Z944','Z945','Z946','Z947','Z948','Z9481',
								  'Z9482','Z9483','Z9484','Z9489','Z949',
				'140','141','142','143','144','145','146','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','170','171',
						'172','174','175','176','179','180','181','182','183','184','185','186','187','188','189','190','191','192','193','194','195','200','201','202','203','204','205',
						'206','207','208','2386', 'C00','C01','C02','C03','C04','C05','C06','C07','C08','C09','C10','C11',
                 'C12','C13','C14','C15','C16','C17','C18','C19','C20','C21','C22','C23','C24','C25','C26','C30','C31','C32','C33','C34','C37','C38','C39','C40','C41','C43','C45','C46',
                  		'C47','C48','C49','C50','C51','C52','C53','C54','C55','C56','C57','C58','C60','C61','C62','C63','C64','C65','C66','C67','C68','C69','C70','C71','C72','C73','C74',
                  		'C75','C76','C81','C82','C83','C84','C85','C88','C90','C91','C92','C93','C94','C95','C96','C97');

*first, sort all bactrim exposures datasets by ENROLID and SVCDATE;
%sort_exposures(input=mine.exposures_08_bactrim_hosp, output=mine.exposures_08_bactrim_hosp);
%sort_exposures(input=mine.exposures_09_bactrim_hosp, output=mine.exposures_09_bactrim_hosp);
%sort_exposures(input=mine.exposures_10_bactrim_hosp, output=mine.exposures_10_bactrim_hosp);
%sort_exposures(input=mine.exposures_11_bactrim_hosp, output=mine.exposures_11_bactrim_hosp);
%sort_exposures(input=mine.exposures_12_bactrim_hosp, output=mine.exposures_12_bactrim_hosp);
%sort_exposures(input=mine.exposures_13_bactrim_hosp, output=mine.exposures_13_bactrim_hosp);
%sort_exposures(input=mine.exposures_14_bactrim_hosp, output=mine.exposures_14_bactrim_hosp);
%sort_exposures(input=mine.exposures_15_bactrim_hosp, output=mine.exposures_15_bactrim_hosp);
%sort_exposures(input=mine.exposures_16_bactrim_hosp, output=mine.exposures_16_bactrim_hosp);
%sort_exposures(input=mine.exposures_17_bactrim_hosp, output=mine.exposures_17_bactrim_hosp);
%sort_exposures(input=mine.exposures_18_bactrim_hosp, output=mine.exposures_18_bactrim_hosp);
%sort_exposures(input=mine.exposures_19_bactrim_hosp, output=mine.exposures_19_bactrim_hosp);
%sort_exposures(input=mine.exposures_20_bactrim_hosp, output=mine.exposures_20_bactrim_hosp);

*add comorbidities for 2008 data, adapted for bactrim data to also keep track of prophylaxis diagnosis codes;
%MACRO add_comorbidities_08_bactrim(exposures=, inpatients=, outpatients=, output=);
	*inpatients data;	
	data tmp.inpatients_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		*also check if any of the diagnosis codes correspond to HIV or organ transplant (indicating prophylactic use);
		do i=1 to 15;	
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX15;
	run;
	
	%collapse_rows(data=tmp.inpatients_merged);

	*outpatients data;
	data tmp.outpatients_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &outpatients(in=b keep=ENROLID SVCDATE DX1-DX2 rename=(SVCDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (2) DX1-DX2;
		*check if any of the diagnoses codes match one of the comorbidity codes or prophylaxis codes;
		do i=1 to 2;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX2;
	run;
	
	%collapse_rows(data=tmp.outpatients_merged);
	
	*concatenate all datasets and collapse rows one final time;
	data tmp.all_merged;
		set tmp.inpatients_merged tmp.outpatients_merged;
		by ENROLID SVCDATE;
	run;
	
	%collapse_rows(data=tmp.all_merged);
	
	*merge back with original exposures dataset;
	data &output;
		merge &exposures(in=a) tmp.all_merged(in=b);
		if a;
		by ENROLID SVCDATE;
	run;
	
	*convert all missing values to 0;
	data &output;
		set &output;
		array CC_GROUPS (17) CC_GRP_1-CC_GRP_17;
		do i=1 to 17;
			CC_GROUPS(i) = coalesce(CC_GROUPS(i), 0);
		end;
		PROPHYLAXIS = coalesce(PROPHYLAXIS, 0);
		drop i;
	run;
%MEND;

*add_comorbidities macro for 2009 data, adapted for bactrim data to also keep track of prophylaxis diagnosis codes;
%MACRO add_comorbidities_09_bactrim(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, output=);
	*inpatients1 data;	
	data tmp.inpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients1(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes or prophylaxis codes;
		do i=1 to 15;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX15;
	run;
	
	%collapse_rows(data=tmp.inpatients1_merged);
	
	*inpatients2 data;	
	data tmp.inpatients2_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients2(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes or prophylaxis codes;
		do i=1 to 15;	
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX15;
	run;
	
	%collapse_rows(data=tmp.inpatients2_merged);

	*outpatients1 data;
	data tmp.outpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &outpatients1(in=b keep=ENROLID SVCDATE DX1-DX2 rename=(SVCDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (2) DX1-DX2;
		*check if any of the diagnoses codes match one of the comorbidity codes or prophylaxis codes;
		do i=1 to 2;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX2;
	run;
	
	%collapse_rows(data=tmp.outpatients1_merged);
	
	*outpatients2 data;
	data tmp.outpatients2_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &outpatients2(in=b keep=ENROLID SVCDATE DX1-DX4 rename=(SVCDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (4) DX1-DX4;
		*check if any of the diagnoses codes match one of the comorbidity codes or prophylaxis codes;
		do i=1 to 4;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX4;
	run;
	
	%collapse_rows(data=tmp.outpatients2_merged);
	
	*concatenate all datasets and collapse rows one final time;
	data tmp.all_merged;
		set tmp.inpatients1_merged tmp.inpatients2_merged tmp.outpatients1_merged tmp.outpatients2_merged;
		by ENROLID SVCDATE;
	run;
	
	%collapse_rows(data=tmp.all_merged);
	
	*merge back with original exposures dataset;
	data &output;
		merge &exposures(in=a) tmp.all_merged(in=b);
		if a;
		by ENROLID SVCDATE;
	run;
	
	*convert all missing values to 0;
	data &output;
		set &output;
		array CC_GROUPS (17) CC_GRP_1-CC_GRP_17;
		do i=1 to 17;
			CC_GROUPS(i) = coalesce(CC_GROUPS(i), 0);
		end;
		PROPHYLAXIS = coalesce(PROPHYLAXIS, 0);
		drop i;
	run;
%MEND;

*add comorbidities for all other years, adapted for bactrim data to also keep track of prophylaxis diagnosis codes;
%MACRO add_comorbidities_bactrim(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, output=);
	*inpatients1 data;	
	data tmp.inpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients1(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 15;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX15;
	run;
	
	%collapse_rows(data=tmp.inpatients1_merged);
	
	*inpatients2 data;	
	data tmp.inpatients2_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients2(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 15;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX15;
	run;
	
	%collapse_rows(data=tmp.inpatients2_merged);

	*outpatients1 data;
	data tmp.outpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &outpatients1(in=b keep=ENROLID SVCDATE DX1-DX4 rename=(SVCDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (4) DX1-DX4;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 4;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX4;
	run;
	
	%collapse_rows(data=tmp.outpatients1_merged);
	
	*outpatients2 data;
	data tmp.outpatients2_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &outpatients2(in=b keep=ENROLID SVCDATE DX1-DX4 rename=(SVCDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (4) DX1-DX4;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 4;
			if DXCODES(i) in: &prophylaxis_symptom_codes then PROPHYLAXIS=1;
			if DXCODES(i) in: &cc_grp_1_codes then CC_GRP_1=1;
			else if DXCODES(i) in: &cc_grp_2_codes then CC_GRP_2=1;
			else if DXCODES(i) in: &cc_grp_3_codes then CC_GRP_3=1;
			else if DXCODES(i) in: &cc_grp_4_codes then CC_GRP_4=1;
			else if DXCODES(i) in: &cc_grp_5_codes then CC_GRP_5=1;
			else if DXCODES(i) in: &cc_grp_6_codes then CC_GRP_6=1;
			else if DXCODES(i) in: &cc_grp_7_codes then CC_GRP_7=1;
			else if DXCODES(i) in: &cc_grp_8_codes then CC_GRP_8=1;
			else if DXCODES(i) in: &cc_grp_9_codes then CC_GRP_9=1;
			else if DXCODES(i) in: &cc_grp_10_codes then CC_GRP_10=1;
			else if DXCODES(i) in: &cc_grp_11_codes then CC_GRP_11=1;
			else if DXCODES(i) in: &cc_grp_12_codes then CC_GRP_12=1;
			else if DXCODES(i) in: &cc_grp_13_codes then CC_GRP_13=1;
			else if DXCODES(i) in: &cc_grp_14_codes then CC_GRP_14=1;
			else if DXCODES(i) in: &cc_grp_15_codes then CC_GRP_15=1;
			else if DXCODES(i) in: &cc_grp_16_codes then CC_GRP_16=1;
			else if DXCODES(i) in: &cc_grp_17_codes then CC_GRP_17=1;
		end;
		drop i SVCDATE2 DX1-DX4;
	run;
	
	%collapse_rows(data=tmp.outpatients2_merged);
	
	*concatenate all datasets and collapse rows one final time;
	data tmp.all_merged;
		set tmp.inpatients1_merged tmp.inpatients2_merged tmp.outpatients1_merged tmp.outpatients2_merged;
		by ENROLID SVCDATE;
	run;
	
	%collapse_rows(data=tmp.all_merged);
	
	*merge back with original exposures dataset;
	data &output;
		merge &exposures(in=a) tmp.all_merged(in=b);
		if a;
		by ENROLID SVCDATE;
	run;
	
	*convert all missing values to 0;
	data &output;
		set &output;
		array CC_GROUPS (17) CC_GRP_1-CC_GRP_17;
		do i=1 to 17;
			CC_GROUPS(i) = coalesce(CC_GROUPS(i), 0);
		end;
		PROPHYLAXIS = coalesce(PROPHYLAXIS, 0);
		drop i;
	run;
%MEND;

*generate comorbidity data for each bactrim exposures dataset;
%add_comorbidities_08_bactrim(exposures=mine.exposures_08_bactrim_hosp, inpatients=mine.full_inpatient_08, outpatients=mine.full_outpatient_08, output=mine.exposures_08_bactrim_cci);
%add_comorbidities_09_bactrim(exposures=mine.exposures_09_bactrim_hosp, inpatients1=mine.full_inpatient_08, inpatients2=mine.full_inpatient_09, outpatients1=mine.full_outpatient_08, outpatients2=mine.full_outpatient_09, output=mine.exposures_09_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_10_bactrim_hosp, inpatients1=mine.full_inpatient_09, inpatients2=mine.full_inpatient_10, outpatients1=mine.full_outpatient_09, outpatients2=mine.full_outpatient_10, output=mine.exposures_10_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_11_bactrim_hosp, inpatients1=mine.full_inpatient_10, inpatients2=mine.full_inpatient_11, outpatients1=mine.full_outpatient_10, outpatients2=mine.full_outpatient_11, output=mine.exposures_11_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_12_bactrim_hosp, inpatients1=mine.full_inpatient_11, inpatients2=mine.full_inpatient_12, outpatients1=mine.full_outpatient_11, outpatients2=mine.full_outpatient_12, output=mine.exposures_12_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_13_bactrim_hosp, inpatients1=mine.full_inpatient_12, inpatients2=mine.full_inpatient_13, outpatients1=mine.full_outpatient_12, outpatients2=mine.full_outpatient_13, output=mine.exposures_13_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_14_bactrim_hosp, inpatients1=mine.full_inpatient_13, inpatients2=mine.full_inpatient_14, outpatients1=mine.full_outpatient_13, outpatients2=mine.full_outpatient_14, output=mine.exposures_14_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_15_bactrim_hosp, inpatients1=mine.full_inpatient_14, inpatients2=mine.full_inpatient_15, outpatients1=mine.full_outpatient_14, outpatients2=mine.full_outpatient_15, output=mine.exposures_15_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_16_bactrim_hosp, inpatients1=mine.full_inpatient_15, inpatients2=mine.full_inpatient_16, outpatients1=mine.full_outpatient_15, outpatients2=mine.full_outpatient_16, output=mine.exposures_16_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_17_bactrim_hosp, inpatients1=mine.full_inpatient_16, inpatients2=mine.full_inpatient_17, outpatients1=mine.full_outpatient_16, outpatients2=mine.full_outpatient_17, output=mine.exposures_17_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_18_bactrim_hosp, inpatients1=mine.full_inpatient_17, inpatients2=mine.full_inpatient_18, outpatients1=mine.full_outpatient_17, outpatients2=mine.full_outpatient_18, output=mine.exposures_18_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_19_bactrim_hosp, inpatients1=mine.full_inpatient_18, inpatients2=mine.full_inpatient_19, outpatients1=mine.full_outpatient_18, outpatients2=mine.full_outpatient_19, output=mine.exposures_19_bactrim_cci);
%add_comorbidities_bactrim(exposures=mine.exposures_20_bactrim_hosp, inpatients1=mine.full_inpatient_19, inpatients2=mine.full_inpatient_20, outpatients1=mine.full_outpatient_19, outpatients2=mine.full_outpatient_20, output=mine.exposures_20_bactrim_cci);

*add CCI variable to each year's dataset;
%add_cci(input=mine.exposures_08_bactrim_cci, output=mine.exposures_08_bactrim_cci);
%add_cci(input=mine.exposures_09_bactrim_cci, output=mine.exposures_09_bactrim_cci);
%add_cci(input=mine.exposures_10_bactrim_cci, output=mine.exposures_10_bactrim_cci);
%add_cci(input=mine.exposures_11_bactrim_cci, output=mine.exposures_11_bactrim_cci);
%add_cci(input=mine.exposures_12_bactrim_cci, output=mine.exposures_12_bactrim_cci);
%add_cci(input=mine.exposures_13_bactrim_cci, output=mine.exposures_13_bactrim_cci);
%add_cci(input=mine.exposures_14_bactrim_cci, output=mine.exposures_14_bactrim_cci);
%add_cci(input=mine.exposures_15_bactrim_cci, output=mine.exposures_15_bactrim_cci);
%add_cci(input=mine.exposures_16_bactrim_cci, output=mine.exposures_16_bactrim_cci);
%add_cci(input=mine.exposures_17_bactrim_cci, output=mine.exposures_17_bactrim_cci);
%add_cci(input=mine.exposures_18_bactrim_cci, output=mine.exposures_18_bactrim_cci);
%add_cci(input=mine.exposures_19_bactrim_cci, output=mine.exposures_19_bactrim_cci);
%add_cci(input=mine.exposures_20_bactrim_cci, output=mine.exposures_20_bactrim_cci);

*----------------------------------------------------------------------------------------------;

/***** MERGE ALL YEAR DATASETS TOGETHER *****/

%MACRO join_sort_unique_bactrim(data1=, data2=, output=);
	data &output;
		set &data1 &data2;
		keep ENROLID SEQNUM SVCDATE SEX YEAR AGEGRP REGION SEX DRUGNAME CDI_FLAG PRIOR_HOSPITALIZATION CCI_CAT PROPHYLAXIS;
	run;
	
	proc sort data=&output nodupkey;
		by ENROLID;
	run;
%MEND;

%join_sort_unique_bactrim(data1=mine.exposures_08_bactrim_cci, data2=mine.exposures_09_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_10_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_11_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_12_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_13_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_14_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_15_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_16_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_17_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_18_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_19_bactrim_cci, output=mine.exposures_bactrim_complete);
%join_sort_unique_bactrim(data1=mine.exposures_bactrim_complete, data2=mine.exposures_20_bactrim_cci, output=mine.exposures_bactrim_complete);

*----------------------------------------------------------------------------------------------;

/***** CREATE FINAL MERGED DATASET WITH BACTRIM + LOGISTIC REGRESSION *****/

*merge back into main data;
data mine.exposures_final_with_bactrim;
	set mine.exposures_final mine.exposures_bactrim_complete;
run;

proc sort data=mine.exposures_final_with_bactrim;
	by ENROLID SVCDATE;
run;

proc sort data=mine.exposures_final_with_bactrim nodupkey;
	by ENROLID;
run;

*adjusted logistic regression model with bactrim;
proc logistic data=mine.exposures_final_with_bactrim plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT;
run;

*stratify bactrim into prophylaxis and non-prophylaxis patients;
data mine.exposures_final_with_bactrim_2;
	set mine.exposures_final_with_bactrim;
	if PROPHYLAXIS = 1 then DRUGNAME='BACTRIM_PROPHYLAXIS';
	if PROPHYLAXIS = 0 then DRUGNAME ='BACTRIM_NON_PROPHYLAXIS';
run;

*adjusted logistic regression model with bactrim (split by prophylaxis);
proc logistic data=mine.exposures_final_with_bactrim_2 plots=oddsratio(logbase=10) descending;
	class SEX(param=ref ref='1') AGEGRP(param=ref ref='2') REGION(param=ref ref='1') DRUGNAME(param=ref ref='DOXYCYCLINE') PRIOR_HOSPITALIZATION(param=ref ref='0') CCI_CAT(param=ref ref='0');
	model CDI_FLAG = SEX AGEGRP REGION DRUGNAME PRIOR_HOSPITALIZATION CCI_CAT;
run;