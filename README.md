# Sex-biased Infection Rates and Responses Contribute to Sex Differences in Neurodegenerative Disease Risk

This repository holds the AoU code to identify sex differences in neurodegenerative disease risk.

| Script  | Description |
| ------------- | ------------- |
| 01_pull_NDD_rule_of_two_MAY_15_2026.ipynb  | Pulls the NDD cases (AD, PD, VD, and DEM) from AoU|
| 02_controls_60.ipynb  | Pulls Controls from AoU  |
| 03_pull_ICD10_code_data.ipynb  |  Pulls ICD10 codes of interest from AoU  |
| 04_prep_CONTROL_JUNE_01_2026.ipynb  | Preps the Controls using exclusion/filtering criteria |
| 04_prep_NDD_june_01_26_rule_of_two.ipynb  | Preps the Cases using exclusion/filtering criteria  |
| 05_prep_COMBO.ipynb  | Preps the Cases, Controls, and ICD10 codes. Will also concat them into a final_df for the analysis models   |
| 06_run_COX_Z_and_GLM.iypnb  |  Runs the Cox Models (both_sexes, female-only, male-only), Cox with Interaction Term, Z-test, and GLM models  |
| 07_PREP_FOR_Q3_MEDIATION_ANALYSIS.ipynb  | Prepares the final_df to run for Mediation Analysis  |
| 08_Q3_MEDIATION_ANALYSIS.r  | Runs the Mediation Analysis  |
| 09_Create_Final_DF_mediation.ipynb  | Concats all the output of Mediation Analyses (per-ICD10 code) together |
