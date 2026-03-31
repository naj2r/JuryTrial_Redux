* Temporary check file - part 2 (population + treatment summaries)
clear all
set more off

do "code/master/paths.do"

use "$DATA_FINAL/michigan_panel_B.dta", clear

di "===== POPULATION VARIABLE ====="
sum county_pop

di "===== TREATMENT VARIABLES ====="
sum treat_pros_*

di "===== DONE ====="
