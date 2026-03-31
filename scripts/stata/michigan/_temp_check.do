* Temporary check file - describe Michigan panel data
* Created for variable inspection

clear all
set more off

do "code/master/paths.do"

use "$DATA_FINAL/michigan_panel_B.dta", clear

di "===== SHORT DESCRIBE ====="
describe, short

di "===== FULL DESCRIBE ====="
describe

di "===== TAB YEAR ====="
tab year

di "===== POPULATION VARIABLES ====="
sum population* pop* county_pop*

di "===== TREATMENT VARIABLES ====="
sum treat_pros_*

di "===== DONE ====="
