/* Antibiotic_Usage_Line_Plots.sas
Summary: line plots summarizing antibiotic usage trends over time
Created by: Jimmy Zhang @ 5/4/22
Modified by: Jimmy Zhang @ 5/23/22
*/

*combine CCAE and MDCR freq tables;
proc sql;
	CREATE TABLE mine.unique_adults_per_year_combined AS
	SELECT x.YEAR, x.NUM_UNIQUE_PATIENTS + y.NUM_UNIQUE_PATIENTS AS NUM_UNIQUE_PATIENTS
	FROM mine.unique_adults_per_year_table as x INNER JOIN mine.unique_adults_per_year_mdcr AS y
	ON x.YEAR = y.YEAR;
quit;

%merge_drug_freq(ccae_freq_table=mine.drugs_freq_08, mdcr_freq_table=mine.drugs_freq_08_mdcr, output=mine.drugs_freq_08_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_09, mdcr_freq_table=mine.drugs_freq_09_mdcr, output=mine.drugs_freq_09_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_10, mdcr_freq_table=mine.drugs_freq_10_mdcr, output=mine.drugs_freq_10_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_11, mdcr_freq_table=mine.drugs_freq_11_mdcr, output=mine.drugs_freq_11_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_12, mdcr_freq_table=mine.drugs_freq_12_mdcr, output=mine.drugs_freq_12_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_13, mdcr_freq_table=mine.drugs_freq_13_mdcr, output=mine.drugs_freq_13_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_14, mdcr_freq_table=mine.drugs_freq_14_mdcr, output=mine.drugs_freq_14_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_15, mdcr_freq_table=mine.drugs_freq_15_mdcr, output=mine.drugs_freq_15_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_16, mdcr_freq_table=mine.drugs_freq_16_mdcr, output=mine.drugs_freq_16_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_17, mdcr_freq_table=mine.drugs_freq_17_mdcr, output=mine.drugs_freq_17_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_18, mdcr_freq_table=mine.drugs_freq_18_mdcr, output=mine.drugs_freq_18_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_19, mdcr_freq_table=mine.drugs_freq_19_mdcr, output=mine.drugs_freq_19_combined);
%merge_drug_freq(ccae_freq_table=mine.drugs_freq_20, mdcr_freq_table=mine.drugs_freq_20_mdcr, output=mine.drugs_freq_20_combined);

*join all drug freq datasets together;
data mine.drugs_freq_all_by_year_combined;
	set mine.drugs_freq_08_combined mine.drugs_freq_09_combined mine.drugs_freq_10_combined mine.drugs_freq_11_combined
		mine.drugs_freq_12_combined mine.drugs_freq_13_combined mine.drugs_freq_14_combined mine.drugs_freq_15_combined
		mine.drugs_freq_16_combined mine.drugs_freq_17_combined mine.drugs_freq_18_combined mine.drugs_freq_19_combined
		mine.drugs_freq_20_combined;
run;	

*add column denoting total number of unique patients for that year;
data mine.drugs_freq_all_by_year_combined;
	set mine.drugs_freq_all_by_year_combined;
	select (year(YEAR));
		when (2008) NUM_UNIQUE_PATIENTS = 21104880;
		when (2009) NUM_UNIQUE_PATIENTS = 23620708;
		when (2010) NUM_UNIQUE_PATIENTS = 23445785;
		when (2011) NUM_UNIQUE_PATIENTS = 25641531;
		when (2012) NUM_UNIQUE_PATIENTS = 25878653;
		when (2013) NUM_UNIQUE_PATIENTS = 21260400;
		when (2014) NUM_UNIQUE_PATIENTS = 21241537;
		when (2015) NUM_UNIQUE_PATIENTS = 16797389;
		when (2016) NUM_UNIQUE_PATIENTS = 16399655;
		when (2017) NUM_UNIQUE_PATIENTS = 14714237;
		when (2018) NUM_UNIQUE_PATIENTS = 14714879;
		when (2019) NUM_UNIQUE_PATIENTS = 13663305;
		when (2020) NUM_UNIQUE_PATIENTS = 10835505;
		otherwise NUM_UNIQUE_PATIENTS = .;
	end;
run;

*add columns denoting number of 1000 person-years (i.e. just divide by 1000) and normalized count;
data mine.drugs_freq_all_by_year_combined;
	set mine.drugs_freq_all_by_year_combined;
	COUNT_PER_1000_PERSON_YEARS = COUNT / (NUM_UNIQUE_PATIENTS/ 1000);
	select (strip(upcase(DRUGNAME)));
		when ('AMOXICILLIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 228.42873307;
		when ('AZITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 224.51418819;
		when ('FLUOROQUINOLONES') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 199.46249398;
		when ('CEPHALEXIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 82.364552653;
		when ('CLINDAMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 67.741489172;
		when ('DOXYCYCLINE') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 67.81962276;
		when ('NITROFURANTOIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 37.560365186;
		when ('PENICILLIN VK') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 31.063289628;
		when ('CLARITHROMYCIN') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 27.470708196;
		when ('CEFDINIR') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 18.200293013;
		when ('CEFUROXIME') COUNT_NORM = COUNT_PER_1000_PERSON_YEARS / 15.841265148;
		otherwise COUNT_NORM = .;
	end;
run;

*change DRUGNAME to Antibiotic;
data mine.drugs_freq_all_by_year_combined;
	set mine.drugs_freq_all_by_year_combined;
	rename DRUGNAME = Antibiotic;
run;

/* (LINE PLOT) prescription rates by year*/
ods graphics / attrpriority=none;

title "Prescription Rates of Top Antibiotic Classes";
proc sgplot data=mine.drugs_freq_all_by_year_combined;
	series x=YEAR  y=COUNT_PER_1000_PERSON_YEARS / group=Antibiotic;
	xaxis label= "Year";
	yaxis label= "Prescriptions per 1,000 Person-Years" type=log logbase=10;
	styleattrs datacontrastcolors=(darkslategray maroon green darkblue gold lime aquamarine CXff00ff dodgerblue goldenrod hotpink)
				   datalinepatterns=(Solid Dash);
run;
title;

/* (LINE PLOT) prescription rates by year, normalized to 2008 */
title "Prescription Rates of Top Antibiotic Classes (Normalized to 2008)";
proc sgplot data=mine.drugs_freq_all_by_year_combined;
	series x=YEAR  y=COUNT_NORM / group=Antibiotic;
	xaxis label= "Year";
	yaxis label="Prescription Rate (Relative to 2008)" type=log logbase=10;
	refline 1 / axis=y lineattrs=(thickness=3 color=darkred pattern=dash) 
				label=("No change");
	styleattrs datacontrastcolors=(darkslategray maroon green darkblue gold lime aquamarine CXff00ff dodgerblue goldenrod hotpink)
				   datalinepatterns=(Solid Dash);
run;
title;