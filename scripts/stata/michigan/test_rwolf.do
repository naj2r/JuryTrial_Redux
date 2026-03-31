* Minimal test: rwolf + reghdfe wrapper to fix _rc=111 issue

if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

* ---------------------------------------------------------------
* Wrapper program: reghdfe_rc0
*
* reghdfe v6+ (Stata 19) returns _rc=111 even on success
* (singleton notification). rwolf v3.1.0 treats any non-zero _rc
* as failure. This wrapper catches the spurious _rc and returns 0
* if the regression actually completed (e(N) populated).
* ---------------------------------------------------------------
capture program drop reghdfe_rc0
program define reghdfe_rc0
    capture noisily reghdfe `0'
    local rc_inner = _rc
    if `rc_inner' != 0 & e(N) > 0 & e(N) < . {
        * Regression completed successfully despite non-zero _rc
        * (e.g., reghdfe v6+ singleton notification _rc=111)
        di as text "  [reghdfe_rc0: suppressed _rc=`rc_inner', e(N)=" e(N) "]"
        exit 0
    }
    else if `rc_inner' != 0 {
        * Genuine failure — e(N) not set
        exit `rc_inner'
    }
    * rc_inner == 0: normal success
end

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
qui drop if treat_pros_primary_only == 1

clonevar tp = treat_pros_pressure
clonevar y1 = pct_told_to_report
clonevar y2 = utilization_rate
clonevar y3 = summoned

di _n "=== Test 1: reghdfe_rc0 wrapper (should return rc=0) ==="
reghdfe_rc0 y1 tp, absorb(county_id year) vce(cluster county_id)
di "  rc=" _rc " N=" e(N) " b=" _b[tp]

di _n "=== Test 2: rwolf with reghdfe_rc0, 3 outcomes, verbose ==="
capture noisily rwolf y1 y2 y3, ///
    indepvar(tp) ///
    method(reghdfe_rc0) ///
    absorb(county_id year) vce(cluster county_id) ///
    cluster(county_id) ///
    reps(50) seed(42) verbose holm
di _n "  Test 2 rc = " _rc

if !_rc {
    di _n "=== rwolf SUCCEEDED! ==="
    mat list e(RW)
}
else {
    di _n "=== rwolf FAILED with rc=" _rc " ==="
}

di _n "=== ALL TESTS COMPLETE ==="
