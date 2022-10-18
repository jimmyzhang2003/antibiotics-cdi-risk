/* Antibiotic_Usage_Line_Plots.sas
Summary: line plots summarizing antibiotic usage trends over time
Created by: Jimmy Zhang @ 5/4/22
Modified by: Jimmy Zhang @ 10/18/22
*/

*create libraries;
libname ccae 'F:/CCAE';
libname mdcr 'F:/MDCR';
libname mine 'G:\def2004/cdi_marketscan';
libname redbook 'F:/Redbook';
libname tmp 'G:\def2004/tmp';

*----------------------------------------------------------------------------------------------;

*create table of number of unique patients per year;
proc sql;
	CREATE TABLE mine.unique_adults_per_year_table AS
	SELECT 2008 as YEAR, COUNT(DISTINCT drug_08_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_08_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2008 as YEAR, COUNT(DISTINCT drug_08_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_08_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2009 as YEAR, COUNT(DISTINCT drug_09_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_09_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2009 as YEAR, COUNT(DISTINCT drug_09_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_09_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2010 as YEAR, COUNT(DISTINCT drug_10_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_10_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2010 as YEAR, COUNT(DISTINCT drug_10_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_10_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2011 as YEAR, COUNT(DISTINCT drug_11_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_11_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2011 as YEAR, COUNT(DISTINCT drug_11_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_11_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2012 as YEAR, COUNT(DISTINCT drug_12_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_12_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2012 as YEAR, COUNT(DISTINCT drug_12_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_12_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2013 as YEAR, COUNT(DISTINCT drug_13_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_13_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2013 as YEAR, COUNT(DISTINCT drug_13_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_13_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2014 as YEAR, COUNT(DISTINCT drug_14_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_14_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2014 as YEAR, COUNT(DISTINCT drug_14_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_14_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2015 as YEAR, COUNT(DISTINCT drug_15_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_15_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2015 as YEAR, COUNT(DISTINCT drug_15_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_15_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2016 as YEAR, COUNT(DISTINCT drug_16_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_16_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2016 as YEAR, COUNT(DISTINCT drug_16_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_16_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2017 as YEAR, COUNT(DISTINCT drug_17_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_17_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2017 as YEAR, COUNT(DISTINCT drug_17_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_17_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2018 as YEAR, COUNT(DISTINCT drug_18_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_18_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2018 as YEAR, COUNT(DISTINCT drug_18_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_18_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2019 as YEAR, COUNT(DISTINCT drug_19_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_19_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2019 as YEAR, COUNT(DISTINCT drug_19_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_19_mdcr_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2020 as YEAR, COUNT(DISTINCT drug_20_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_20_view;
quit;

proc sql;
	INSERT INTO mine.unique_adults_per_year_table
	SELECT 2020 as YEAR, COUNT(DISTINCT drug_20_mdcr_view.ENROLID) AS NUM_UNIQUE_PATIENTS FROM mine.drug_20_mdcr_view;
quit;

*sum up the CCAE and MDCR rows for each year;
proc sql;
    SELECT YEAR, SUM(NUM_UNIQUE_PATIENTS) AS NUM_UNIQUE_PATIENTS FROM mine.unique_adults_per_year_table
    GROUP BY YEAR;
quit;

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
data mine.drugs_freq_all_by_year;
	set mine.drugs_freq_all_by_year;
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

*rename DRUGNAME to Antibiotic;
data mine.drugs_freq_all_by_year;
	set mine.drugs_freq_all_by_year;
	rename DRUGNAME = Antibiotic;
run;

/* (LINE PLOT) prescription rates by year*/
ods graphics / imagefmt=SVG imagemap=off attrpriority=none;

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