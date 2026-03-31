* Test twowayfeweights return values
do "code/master/paths.do"
do "code/master/globals.do"

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Run twowayfeweights — it displays output to screen, check what it stores
twowayfeweights actually_reported county_id year treat_pros_pressure, type(feTR)

di _n "=== RETURN LIST ==="
return list

di _n "=== ERETURN LIST ==="
ereturn list

di _n "=== SCALAR LIST ==="
capture di r(N_pos_weights)
capture di "num_pos_weights = " r(num_pos_weights)
capture di "num_neg_weights = " r(num_neg_weights)
