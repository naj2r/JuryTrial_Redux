* Test boottest return values
do "code/master/paths.do"
do "code/master/globals.do"

use "$DATA_FINAL/michigan_panel_B.dta", clear

reghdfe actually_reported treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)

boottest treat_pros_pressure, reps(999) seed(42) nograph

* Check all return values
return list
ereturn list
