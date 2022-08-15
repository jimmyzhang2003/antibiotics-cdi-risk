/* Prior_Hospitalization.sas
Summary: creating variable for prior hospitalization
Created by: Jimmy Zhang @ 2/10/22
Modified by: Jimmy Zhang @ 5/5/22 
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

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
%sort_exposures(input=mine.exposures_08_with_hosp, output=mine.exposures_08_with_hosp);
%sort_exposures(input=mine.exposures_09_with_hosp, output=mine.exposures_09_with_hosp);
%sort_exposures(input=mine.exposures_10_with_hosp, output=mine.exposures_10_with_hosp);
%sort_exposures(input=mine.exposures_11_with_hosp, output=mine.exposures_11_with_hosp);
%sort_exposures(input=mine.exposures_12_with_hosp, output=mine.exposures_12_with_hosp);
%sort_exposures(input=mine.exposures_13_with_hosp, output=mine.exposures_13_with_hosp);
%sort_exposures(input=mine.exposures_14_with_hosp, output=mine.exposures_14_with_hosp);
%sort_exposures(input=mine.exposures_15_with_hosp, output=mine.exposures_15_with_hosp);
%sort_exposures(input=mine.exposures_16_with_hosp, output=mine.exposures_16_with_hosp);
%sort_exposures(input=mine.exposures_17_with_hosp, output=mine.exposures_17_with_hosp);
%sort_exposures(input=mine.exposures_18_with_hosp, output=mine.exposures_18_with_hosp);
%sort_exposures(input=mine.exposures_19_with_hosp, output=mine.exposures_19_with_hosp);
%sort_exposures(input=mine.exposures_20_with_hosp, output=mine.exposures_20_with_hosp);

*next, combine inpatient and outpatient datasets from CCAE and MDCR for each year;
%merge_ccae_mdcr(ccae=ccae.ccaei083, mdcr=mdcr.mdcri083, out=mine.full_inpatient_08)
%merge_ccae_mdcr(ccae=ccae.ccaei093, mdcr=mdcr.mdcri093, out=mine.full_inpatient_09)
%merge_ccae_mdcr(ccae=ccae.ccaei103, mdcr=mdcr.mdcri103, out=mine.full_inpatient_10)
%merge_ccae_mdcr(ccae=ccae.ccaei113, mdcr=mdcr.mdcri113, out=mine.full_inpatient_11)
%merge_ccae_mdcr(ccae=ccae.ccaei123, mdcr=mdcr.mdcri123, out=mine.full_inpatient_12)
%merge_ccae_mdcr(ccae=ccae.ccaei133, mdcr=mdcr.mdcri133, out=mine.full_inpatient_13)
%merge_ccae_mdcr(ccae=ccae.ccaei143, mdcr=mdcr.mdcri143, out=mine.full_inpatient_14)
%merge_ccae_mdcr(ccae=ccae.ccaei153, mdcr=mdcr.mdcri153, out=mine.full_inpatient_15)
%merge_ccae_mdcr(ccae=ccae.ccaei162, mdcr=mdcr.mdcri162, out=mine.full_inpatient_16)
%merge_ccae_mdcr(ccae=ccae.ccaei171, mdcr=mdcr.mdcri171, out=mine.full_inpatient_17)
%merge_ccae_mdcr(ccae=ccae.ccaei181, mdcr=mdcr.mdcri181, out=mine.full_inpatient_18)
%merge_ccae_mdcr(ccae=ccae.ccaei191, mdcr=mdcr.mdcri191, out=mine.full_inpatient_19)
%merge_ccae_mdcr(ccae=ccae.ccaei201, mdcr=mdcr.mdcri201, out=mine.full_inpatient_20)

%merge_ccae_mdcr(ccae=ccae.ccaeo083, mdcr=mdcr.mdcro083, out=mine.full_outpatient_08)
%merge_ccae_mdcr(ccae=ccae.ccaeo093, mdcr=mdcr.mdcro093, out=mine.full_outpatient_09)
%merge_ccae_mdcr(ccae=ccae.ccaeo103, mdcr=mdcr.mdcro103, out=mine.full_outpatient_10)
%merge_ccae_mdcr(ccae=ccae.ccaeo113, mdcr=mdcr.mdcro113, out=mine.full_outpatient_11)
%merge_ccae_mdcr(ccae=ccae.ccaeo123, mdcr=mdcr.mdcro123, out=mine.full_outpatient_12)
%merge_ccae_mdcr(ccae=ccae.ccaeo133, mdcr=mdcr.mdcro133, out=mine.full_outpatient_13)
%merge_ccae_mdcr(ccae=ccae.ccaeo143, mdcr=mdcr.mdcro143, out=mine.full_outpatient_14)
%merge_ccae_mdcr(ccae=ccae.ccaeo153, mdcr=mdcr.mdcro153, out=mine.full_outpatient_15)
%merge_ccae_mdcr(ccae=ccae.ccaeo162, mdcr=mdcr.mdcro162, out=mine.full_outpatient_16)
%merge_ccae_mdcr(ccae=ccae.ccaeo171, mdcr=mdcr.mdcro171, out=mine.full_outpatient_17)
%merge_ccae_mdcr(ccae=ccae.ccaeo181, mdcr=mdcr.mdcro181, out=mine.full_outpatient_18)
%merge_ccae_mdcr(ccae=ccae.ccaeo191, mdcr=mdcr.mdcro191, out=mine.full_outpatient_19)
%merge_ccae_mdcr(ccae=ccae.ccaeo201, mdcr=mdcr.mdcro201, out=mine.full_outpatient_20)

*then, generate comorbidity data for each exposures dataset;
%add_comorbidities_08(exposures=mine.exposures_08_with_hosp, inpatients=mine.full_inpatient_08, outpatients=mine.full_outpatient_08, output=mine.exposures_08_with_hosp_cci);
%add_comorbidities_09(exposures=mine.exposures_09_with_hosp, inpatients1=mine.full_inpatient_08, inpatients2=mine.full_inpatient_09, outpatients1=mine.full_outpatient_08, outpatients2=mine.full_outpatient_09, output=mine.exposures_09_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_10_with_hosp, inpatients1=mine.full_inpatient_09, inpatients2=mine.full_inpatient_10, outpatients1=mine.full_outpatient_09, outpatients2=mine.full_outpatient_10, output=mine.exposures_10_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_11_with_hosp, inpatients1=mine.full_inpatient_10, inpatients2=mine.full_inpatient_11, outpatients1=mine.full_outpatient_10, outpatients2=mine.full_outpatient_11, output=mine.exposures_11_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_12_with_hosp, inpatients1=mine.full_inpatient_11, inpatients2=mine.full_inpatient_12, outpatients1=mine.full_outpatient_11, outpatients2=mine.full_outpatient_12, output=mine.exposures_12_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_13_with_hosp, inpatients1=mine.full_inpatient_12, inpatients2=mine.full_inpatient_13, outpatients1=mine.full_outpatient_12, outpatients2=mine.full_outpatient_13, output=mine.exposures_13_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_14_with_hosp, inpatients1=mine.full_inpatient_13, inpatients2=mine.full_inpatient_14, outpatients1=mine.full_outpatient_13, outpatients2=mine.full_outpatient_14, output=mine.exposures_14_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_15_with_hosp, inpatients1=mine.full_inpatient_14, inpatients2=mine.full_inpatient_15, outpatients1=mine.full_outpatient_14, outpatients2=mine.full_outpatient_15, output=mine.exposures_15_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_16_with_hosp, inpatients1=mine.full_inpatient_15, inpatients2=mine.full_inpatient_16, outpatients1=mine.full_outpatient_15, outpatients2=mine.full_outpatient_16, output=mine.exposures_16_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_17_with_hosp, inpatients1=mine.full_inpatient_16, inpatients2=mine.full_inpatient_17, outpatients1=mine.full_outpatient_16, outpatients2=mine.full_outpatient_17, output=mine.exposures_17_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_18_with_hosp, inpatients1=mine.full_inpatient_17, inpatients2=mine.full_inpatient_18, outpatients1=mine.full_outpatient_17, outpatients2=mine.full_outpatient_18, output=mine.exposures_18_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_19_with_hosp, inpatients1=mine.full_inpatient_18, inpatients2=mine.full_inpatient_19, outpatients1=mine.full_outpatient_18, outpatients2=mine.full_outpatient_19, output=mine.exposures_19_with_hosp_cci);
%add_comorbidities(exposures=mine.exposures_20_with_hosp, inpatients1=mine.full_inpatient_19, inpatients2=mine.full_inpatient_20, outpatients1=mine.full_outpatient_19, outpatients2=mine.full_outpatient_20, output=mine.exposures_20_with_hosp_cci);

*add CCI variable to each year's dataset;
%add_cci(input=mine.exposures_08_with_hosp_cci, output=mine.exposures_08_with_hosp_cci);
%add_cci(input=mine.exposures_09_with_hosp_cci, output=mine.exposures_09_with_hosp_cci);
%add_cci(input=mine.exposures_10_with_hosp_cci, output=mine.exposures_10_with_hosp_cci);
%add_cci(input=mine.exposures_11_with_hosp_cci, output=mine.exposures_11_with_hosp_cci);
%add_cci(input=mine.exposures_12_with_hosp_cci, output=mine.exposures_12_with_hosp_cci);
%add_cci(input=mine.exposures_13_with_hosp_cci, output=mine.exposures_13_with_hosp_cci);
%add_cci(input=mine.exposures_14_with_hosp_cci, output=mine.exposures_14_with_hosp_cci);
%add_cci(input=mine.exposures_15_with_hosp_cci, output=mine.exposures_15_with_hosp_cci);
%add_cci(input=mine.exposures_16_with_hosp_cci, output=mine.exposures_16_with_hosp_cci);
%add_cci(input=mine.exposures_17_with_hosp_cci, output=mine.exposures_17_with_hosp_cci);
%add_cci(input=mine.exposures_18_with_hosp_cci, output=mine.exposures_18_with_hosp_cci);
%add_cci(input=mine.exposures_19_with_hosp_cci, output=mine.exposures_19_with_hosp_cci);
%add_cci(input=mine.exposures_20_with_hosp_cci, output=mine.exposures_20_with_hosp_cci);

*to get the frequency table of CCI values;
proc freq data=mine.exposures_08_with_hosp_cci;
	tables CCI;
run;