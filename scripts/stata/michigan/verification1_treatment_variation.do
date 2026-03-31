/*==============================================================================
  verification1_treatment_variation.do

  Purpose:  Verify that treatment variables vary WITHIN county over time.
            Catches merge errors or mis-coded treatment where a county is
            always-treated or never-treated, leaving no identifying variation.

  What this checks:
    - For each treatment variable, compute within-county SD
    - Count counties where treatment is constant (sd == 0)
    - Report which counties lack variation

  Expected results:
    - treat_pros_pressure: Most counties should have variation (election cycles)
    - treat_pros_contested: Many counties may legitimately have zero variation
      (consistently contested or never contested — that's fine)
    - treat_pros_uncontested: Same — many counties always or never uncontested

  RED FLAGS:
    - If ALL counties have sd==0 for pressure → merge/coding error
    - If >90% of counties have sd==0 for pressure → data alignment bug

  Usage: do code/michigan/verification1_treatment_variation.do
  Requires: paths.do has been run (or run this after master_build_all.do)
==============================================================================*/

clear all
set more off
set update_query off

* --- Set paths ---
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"

* --- Log ---
log using "$LOGS/verification1_treatment_variation.log", replace

di _n "{hline 72}"
di "VERIFICATION 1: WITHIN-COUNTY TREATMENT VARIATION"
di "{hline 72}"

* =============================================================================
* CHECK A: County-level panel (Panel B — primary specification)
* =============================================================================

di _n "=== PANEL B (all-courts, primary specification) ==="
use "$DATA_FINAL/michigan_panel_B.dta", clear
* Construct primary-only flag (may not survive pipeline collapse)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
di "Observations: " _N
qui distinct county_id
di "Counties: " r(ndistinct)

foreach tvar in treat_pros_pressure treat_pros_contested_long ///
    treat_pros_contested treat_pros_uncontested treat_pros_primary_only {

    capture confirm variable `tvar'
    if _rc {
        di _n "  `tvar': VARIABLE NOT FOUND (skip)"
        continue
    }

    bys county_id: egen _sd_`tvar' = sd(`tvar')

    di _n "=== `tvar' ==="
    di "  Overall distribution:"
    tab `tvar'

    di _n "  Within-county SD:"
    sum _sd_`tvar', detail

    qui count if _sd_`tvar' == 0
    local n_zero = r(N)
    qui distinct county_id if _sd_`tvar' == 0
    local c_zero = r(ndistinct)
    qui distinct county_id
    local c_total = r(ndistinct)

    di _n "  County-years with ZERO within-county variation: `n_zero'"
    di "  Counties with ZERO variation: `c_zero' / `c_total'"

    if `c_zero' == `c_total' {
        di as error "  *** RED FLAG: ALL counties have zero variation! ***"
    }
    else if `c_zero' / `c_total' > 0.9 {
        di as error "  *** WARNING: >90% of counties have zero variation ***"
    }
    else {
        di as result "  OK: `=`c_total' - `c_zero'' counties have identifying variation"
    }

    * List counties with zero variation (if small number)
    if `c_zero' > 0 & `c_zero' <= 20 {
        di _n "  Counties with zero variation in `tvar':"
        qui levelsof county_id if _sd_`tvar' == 0, local(zero_counties)
        foreach c of local zero_counties {
            di "    county_id = `c'"
        }
    }

    drop _sd_`tvar'
}

* =============================================================================
* CHECK B: Decomposition identity check
* =============================================================================

di _n "{hline 72}"
di "DECOMPOSITION IDENTITY CHECKS"
di "{hline 72}"

* contested + uncontested == pressure
gen _check1 = (treat_pros_contested + treat_pros_uncontested == treat_pros_pressure)
qui count if _check1 == 0
di "  contested + uncontested == pressure violations: " r(N)
assert r(N) == 0
drop _check1

* contested_long <= contested
gen _check2 = (treat_pros_contested_long <= treat_pros_contested)
qui count if _check2 == 0
di "  contested_long <= contested violations: " r(N)
assert r(N) == 0
drop _check2

* primary_only = contested - contested_long
capture confirm variable treat_pros_primary_only
if !_rc {
    gen _check3 = (treat_pros_primary_only == (treat_pros_contested - treat_pros_contested_long))
    qui count if _check3 == 0
    di "  primary_only == contested - contested_long violations: " r(N)
    assert r(N) == 0
    drop _check3

    * Count primary-only observations
    qui count if treat_pros_primary_only == 1
    di _n "  Primary-only contested county-years: " r(N) " (these get excluded from T2)"
}

di _n "=== VERIFICATION 1 COMPLETE ==="

log close
