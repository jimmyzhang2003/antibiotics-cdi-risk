# antibiotics-cdi-risk

## Title

Antibiotic-Specific Risk for Community-Acquired _Clostridioides difficile_ Infection in the United States from 2008 to 2020

## Abstract

Antibiotic exposure is a crucial risk factor for community-acquired _Clostridioides difficile_ infection (CA-CDI). However, the relative risks associated with specific antibiotics may vary over time, and the absolute risks have not been clearly established. This was a retrospective cohort study. Adults were included if they received an outpatient antibiotic prescription within the IBM® MarketScan® Databases between 2008 and 2020. The primary exposure was an outpatient antibiotic prescription, and receipt of doxycycline was used as the reference comparison. The primary outcome was CA-CDI, defined as the presence of an ICD diagnosis code for CDI within 90 days of receiving an outpatient antibiotic prescription, and subsequent treatment for CDI. There were 36,626,794 unique patients who received outpatient antibiotics including 11,607 (0.03%) who developed CA-CDI. Relative to doxycycline, the antibiotics conferring the highest risks for CA-CDI were clindamycin (adjusted odds ratio [aOR] 8.81, 95% confidence interval [CI]: 7.76-10.00), cefdinir (aOR 5.86, 95% CI: 5.03-6.83), cefuroxime (aOR 4.57, 95% CI: 3.87-5.39), and fluoroquinolones (aOR 4.05, 95% CI: 3.58-4.59). Among older patients with CA-CDI risk factors, nitrofurantoin was also associated with CA-CDI (aOR 3.05, 95% CI: 1.92-4.84), with fewer number needed to harm compared to fluoroquinolones. While clindamycin, cefuroxime, and fluoroquinolone use declined from 2008 to 2020, nitrofurantoin use increased by 40%. Clindamycin was associated with the greatest CA-CDI risk overall. Among older patients with elevated baseline risk for CA-CDI, multiple antibiotics, including nitrofurantoin, had strong associations with CA-CDI. These results may guide antibiotic selection and future stewardship efforts.

## File Structure

> Ideally, files should be accessed and run in this order because data tables were created sequentially across files.

```
    ├── Utility_Macros.sas
    ├── File_Setup.sas
    ├── Continuous_Enrollment.sas
    ├── Prior_Hospitalization.sas
    ├── Charlson_Comorbidity_Index.sas
    ├── Additional_Antibiotics.sas
    ├── Antibiotic_Usage_Line_Plots.sas
    ├── Tables.sas
    ├── Logistic_Regression.sas
    ├── odds_ratios_plot.R
    ├── Bactrim_Reviewer_Response.sas
    ├── CDI_Cases_Reviewer_Response.sas
    └── README.md
```

## Citation

## Contact

Correspondence to: Jimmy Zhang, Columbia University, jimmyzhang2003@gmail.com
