/* Utility_Macros.sas
Summary: macro functions for file setup and analyses
Created by: Jimmy Zhang @ 4/25/22
Modified by: Jimmy Zhang @ 7/20/22 
*/

*----------------------------------------------------------------------------------------------;

/*FOR CREATING DRUG AND EXPOSURES DATASETS */

*macro function for creating drug datasets (uses hashing to match NDCNUM to corresponding THERDTL and PRODNME);
%MACRO create_drug_dataset(input=, output=);
	data &output / view=&output;
		drop rc;
	
		if 0 then set &input(drop=GENERID) redbook.redbook2019(drop=GENERID);
		if _n_ = 1 then do;
			declare Hash MatchDrugCodes (dataset:'redbook.redbook2019');
			MatchDrugCodes.DefineKey ('NDCNUM');
			MatchDrugCodes.DefineData ('THERDTL', 'PRODNME');
			MatchDrugCodes.DefineDone ();
		end;
		
		set &input;
		rc = MatchDrugCodes.find();
		
		*limit analysis to only adults (age >= 18) and exclude region 5 (unknown);
		if missing(ENROLID) or missing(NDCNUM) or NDCNUM = '00000000000' or missing(SVCDATE) or missing(THERDTL) or THERDTL = 9999999999 or AGE < 18 or REGION = 5 
			then delete;
%MEND;

*macro function for renaming exposure drugs in dataset;
%MACRO rename_exposure_drugs(input1=, input2=, output=);
	data &output;
		set &input1 &input2;
		format DRUGNAME $20.;
		select (THERDTL);
			when (812160005) DRUGNAME = "AMOXICILLIN";
			when (812120002) DRUGNAME = "AZITHROMYCIN";
			when (822010010) DRUGNAME = "FLUOROQUINOLONES";
			when (822010017) DRUGNAME = "FLUOROQUINOLONES";
			when (5204040060) DRUGNAME = "FLUOROQUINOLONES";
			when (5204040088) DRUGNAME = "FLUOROQUINOLONES";
			when (812240010) DRUGNAME = "DOXYCYCLINE";
			when (8404040015) DRUGNAME = "CLINDAMYCIN";
			when (812280010) DRUGNAME = "CLINDAMYCIN";
			when (812060045) DRUGNAME = "CEPHALEXIN";
			when (812060019) DRUGNAME = "CEFDINIR";
			when (836010055) DRUGNAME = "NITROFURANTOIN";
			when (812160070) DRUGNAME = "PENICILLIN VK";
			when (812120003) DRUGNAME = "CLARITHROMYCIN";
			when (812060040) DRUGNAME = "CEFUROXIME";
			otherwise delete;
		end;
		*keep all identifiers and covars;
		keep ENROLID SVCDATE YEAR DRUGNAME SEQNUM AGE AGEGRP SEX REGION;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR GETTING UNIQUE PATIENTS */

*macro for getting unique patients;
%MACRO sort_unique_patients(data=, output=);
	proc sort data=&data out=&output nodupkey;
		by ENROLID;
	run;
%MEND;

*macro for joining and sorting to get unique patients across dataset years;
%MACRO join_sort_unique_patients(data1=, data2=, output=);
	data &output;
		set &data1 &data2;
    run;
	
	proc sort data=&output nodupkey;
		by ENROLID;
	run;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR DETERMINING CONTINUOUS ENROLLMENT*/

*ensure that for each antibiotic prescription, the patient was enrolled for 3 months before the index
date and three months after the index date;
*macros for checking if patients have continuous enrollment;
*to check enrollment within +/- 90 days, include the prior year and the subsequent year;
*check both CCAE data and MDCR data;

%MACRO merge_enrollment(enrollment1=, enrollment2=, output=);
	data &output;
		set &enrollment1 &enrollment2;
		keep ENROLID ENRIND1-ENRIND12;
	run;
	
	proc sort data=&output;
		by ENROLID;
	run;
	
	*collapse rows so each patient has ENRIND variables that account for both CCAE and MDCR;
	data &output;
		update &output(obs=0) &output;
		by ENROLID;
	run;
%MEND;

%MACRO cont_enroll_prior_1(exposures=, enrollment=, output=);
	*sort by ENROLID;
	proc sort data=&exposures;
		by ENROLID;
	run;

	*prior year;
	data &output;
		merge &exposures(in=a) 
			  &enrollment(in=b keep=ENROLID ENRIND1-ENRIND12);
		by ENROLID;
		if a;
		MONTH = month(SVCDATE);
		array ENRINDS (12) ENRIND1-ENRIND12;
		
		*initalize enrolled flag to 1, then update as we check the months of enrollment;
		ENROLLED1 = 1;
		*only need to check last three months of the year;
		do i=MONTH+9 to 12;
			if ENRINDS(i) ^= 1 then ENROLLED1=0;
		end;
		
		if ENROLLED1;
		drop ENRIND1-ENRIND12 i;
	run;
%MEND cont_enroll_prior_1;

%MACRO cont_enroll_prior_0(exposures=, output=);
	*sort by ENROLID;
	proc sort data=&exposures;
		by ENROLID;
	run;
	
	*prior year;
	data &output;
		set &exposures(in=a);
		MONTH = month(SVCDATE);
		ENROLLED1 = 1;
		*if in the first 3 months of 2008, delete because we will not have continuous enrollment for 3 months prior;
		if MONTH > 3;
	run;
%MEND cont_enroll_prior_0;
 
%MACRO cont_enroll_curr(exposures=, enrollment=, output=);
	*current year;
	data &output;
		merge &exposures(in=a) 
			  &enrollment(in=b keep=ENROLID ENRIND1-ENRIND12);
		by ENROLID;
		if a;
		array ENRINDS (12) ENRIND1-ENRIND12;
		
		*initalize enrolled flag to 1, then update as we check the months of enrollment;
		ENROLLED2 = 1;
		*need to check 3 months prior and 3 months after;
		do i=max(1,MONTH-3) to min(MONTH+3, 12);
			if ENRINDS(i) ^= 1 then ENROLLED2=0;
		end;
		
		if ENROLLED2;
		drop ENRIND1-ENRIND12 i;
	run;
%MEND cont_enroll_curr;

%MACRO cont_enroll_after_1(exposures=, enrollment=, output=);
	*subsequent year;
	data &output;
		merge &exposures(in=a)
			  &enrollment(in=b keep=ENROLID ENRIND1-ENRIND12);
		by ENROLID;
		if a;
		MONTH = month(SVCDATE);
		array ENRINDS (12) ENRIND1-ENRIND12;
		
		*initalize enrolled flag to 1, then update as we check the months of enrollment;
		ENROLLED3 = 1;
		*only need to check first three months of the year;
		do i=1 to MONTH-9;
			if ENRINDS(i) ^= 1 then ENROLLED3=0;
		end;
		
		if ENROLLED1 & ENROLLED2 & ENROLLED3;
		drop ENRIND1-ENRIND12 MONTH i ENROLLED1-ENROLLED3;
	run;
%MEND cont_enroll_after_1;

%MACRO cont_enroll_after_0(exposures=, output=);
	*subsequent year;
	data &output;
		set &exposures;
		*if in the last 3 months of 2020, delete because we will not have continuous enrollment for 3 months after;
		if MONTH < 10 & ENROLLED1 & ENROLLED2;
		drop ENRIND1-ENRIND12 MONTH ENROLLED1-ENROLLED2;
	run;
%MEND cont_enroll_after_0;

*----------------------------------------------------------------------------------------------;

/*FOR DETERMINING CDI OUTCOMES*/
*macro function for renaming outcome drugs in dataset;
%MACRO rename_outcome_drugs(input=, output=);
	data &output;
		set &input;
		select (THERDTL);
			when (840010030) DRUGNAME = "METRONIDAZOLE";
			when (8404160085) DRUGNAME = "METRONIDAZOLE";
			when (812280045) DRUGNAME = "VANCOMYCIN";
			when (812120026) DRUGNAME = "FIDAXOMICIN";
			otherwise delete;
		end;
		keep ENROLID SVCDATE DRUGNAME;
%MEND;

*macro for marking CDI cases in the exposures dataset;
%MACRO create_CDI_flag(exposures=, outcomes=, output=);
    data &output;
        merge &exposures(in=a) &outcomes(in=b keep=ENROLID SVCDATE rename=(SVCDATE=DIAGNOSISDATE));
        if a;
        by ENROLID;
        if DIAGNOSISDATE and SVCDATE >= DIAGNOSISDATE-90 and DIAGNOSISDATE >= SVCDATE then CDI_FLAG = 1;
        else CDI_FLAG = 0;
    run;
        
    *only take the first diagnosis after antibiotic prescription;
    proc sort data=&output;
        by ENROLID descending CDI_FLAG DIAGNOSISDATE;
        
    data &output;
        set &output;
        by ENROLID;
        if FIRST.ENROLID;
    run;

    *drop diagnosis date for patients without CDI_FLAG = 1;
    data &output;
        set &output;
        if CDI_FLAG = 0 then DIAGNOSISDATE = .;
    run;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR DETERMINING PRIOR HOSPITALIZATION */

*macro for adding variable for prior hospitalization (DISDATE/discharge date within 90 days of drug SVCDATE/index date);
%MACRO add_hospitalization(exposures=, inpatients=, output=);
	proc sql;
		CREATE TABLE &output AS 
		SELECT exp.*, inp.DISDATE,
			CASE
				WHEN DISDATE = . THEN 0
				ELSE 1
			END AS PRIOR_HOSPITALIZATION
		FROM &exposures as exp LEFT JOIN &inpatients as inp
		ON exp.ENROLID = inp.ENROLID AND inp.DISDATE <= exp.SVCDATE AND exp.SVCDATE <= inp.DISDATE + 90;
	quit;
	
	*sort to remove duplicates generated by the merge step;
	proc sort data=&output nodupkey;
		by ENROLID;
	run;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR MERGING INPATIENT AND OUTPATIENT DATASETS FROM CCAE AND MDCR */
%MACRO merge_ccae_mdcr(ccae=, mdcr=, out=);
	data &out;
		set &ccae &mdcr;
        by ENROLID;
	run;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR CALCULATING CHARLSON COMORBIDITY INDEX */

*macro to collapse rows (i.e., combine comorbidities across multiple rows since there are duplicates from match-merging);
%MACRO collapse_rows(data=);
	*use data step and update to collapse duplicate rows (combines the columns for each comorbidity for each unique SEQNUM to only . or 1);
	data &data;
		update &data(obs=0) &data;
		by ENROLID SVCDATE;
	run;
%MEND;

*macro adapted from MCHP SAS macro code: http://mchp-appserv.cpe.umanitoba.ca/viewConcept.php?conceptID=1098;
*check diagnosis codes from inpatient and outpatient tables within 1 year of drug prescription index date;
%MACRO add_comorbidities(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, output=);
	*inpatients1 data;	
	data tmp.inpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients1(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 15;	
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
		drop i;
	run;
%MEND;

/*add_comorbidities macro for 2008 data, which only contains 2 diagnosis codes in the outpatient 
dataset and only needs the 2008 data since there is no prior year*/
%MACRO add_comorbidities_08(exposures=, inpatients=, outpatients=, output=);
	*inpatients data;	
	data tmp.inpatients_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 15;	
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
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 2;	
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
		drop i;
	run;
%MEND;

*add_comorbidities macro for 2009 data, which only uses 2 diagnosis codes from the 2008 outpatient dataset;
%MACRO add_comorbidities_09(exposures=, inpatients1=, inpatients2=, outpatients1=, outpatients2=, output=);
	*inpatients1 data;	
	data tmp.inpatients1_merged;
		merge &exposures(in=a keep=ENROLID SVCDATE) &inpatients1(in=b keep=ENROLID DISDATE DX1-DX15 rename=(DISDATE=SVCDATE2));
		if a and SVCDATE <= SVCDATE2 + 365;
		by ENROLID;
		array DXCODES (15) DX1-DX15;
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 15;	
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
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 2;	
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
		*check if any of the diagnoses codes match one of the comorbidity codes;
		do i=1 to 4;	
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
		drop i;
	run;
%MEND;

*macro to sort exposures datasets by ENROLID and SVCDATE;
%MACRO sort_exposures(input=, output=);
	proc sort data=&input out=&output;
		by ENROLID SVCDATE;
	run;
%MEND;

*macro for calculating Charlson Comorbidity Index (CCI) based on listed CCI groups;
%MACRO add_cci(input= , output=);
	data &output;
		set &input;
		*use Charlson weights to calculate a weighted score;
		CCI = sum(of CC_GRP_1-CC_GRP_10) + CC_GRP_11*2 + CC_GRP_12*2 + CC_GRP_13*2 + CC_GRP_14*2 +
			  CC_GRP_15*3 + CC_GRP_16*6 + CC_GRP_17*6;
		*moderate/severe liver disease takes precedence over mild liver disease;
		if CC_GRP_9 = 1 & CC_GRP_15 = 1 then CCI = CCI - 1;
		*diabetes with complications takes precedence over diabetes without complications;
		if CC_GRP_10 = 1 & CC_GRP_11 = 1 then CCI = CCI - 1;
		*metastatic carcinoma takes precedence over cancer;
		if CC_GRP_14 = 1 & CC_GRP_16 = 1 then CCI = CCI - 2;
		
		*create a categorical variable for cci with categories 0, 1, 2, 3+;
		if CCI >= 3 then CCI_CAT = '3+';
		else CCI_CAT = CCI;
%MEND;

*----------------------------------------------------------------------------------------------;

/*FOR HANDLING DRUG FREQUENCIES*/
*macro function to get frequencies of each drug for each year;
%MACRO get_drug_freq(input=, output=, year=);
	proc freq data=&input order=freq;
		tables DRUGNAME / out=tmp;
	run;
	
	data &output;
		set tmp;
		YEAR = mdy(1, 1, &year);
		format YEAR year4.;
		keep DRUGNAME COUNT YEAR;
	run;
%MEND;

%MACRO merge_drug_freq(ccae_freq_table=, mdcr_freq_table=, output=);
	proc sql;
		CREATE TABLE &output AS	
		SELECT x.DRUGNAME, x.COUNT + y.COUNT AS COUNT, x.YEAR
		FROM &ccae_freq_table AS x INNER JOIN &mdcr_freq_table AS y
		ON x.DRUGNAME = y.DRUGNAME;
	quit;
%MEND;