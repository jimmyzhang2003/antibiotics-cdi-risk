# antibiotics-cdi-risk

## Summary

Clostridioides difficile infection (CDI) is a contagious bacterial infection that typically causes diarrhea and colitis in symptomatic patients. Antibiotic use has been regarded as one of the most important (and modifiable) risk factors of CDI infection. Transmission of CDI occurs along the fecal-oral route, and though CDI has been considered to be a predominantly hospital-acquired infection, recent evidence has shown that community-acquired CDI constitutes a large proportion of CDI cases. However, community-acquired CDI is still not fully understood, and further research is required to confirm the specific antibiotic classes that are associated with CDI risk.

This project leverages the MarketScan database, a large commercial insurance billing database containing over 40 million unique patient records, to identify associations between specific antibiotic classes and risk for CDI.

## File Structure

> Ideally, files should be accessed and run in this order because data tables were created sequentially from one file to the next.

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
    └── README.md
```

## Contact

Correspondence to: Jimmy Zhang, Columbia University
Email: jimmyzhang2003@gmail.com
