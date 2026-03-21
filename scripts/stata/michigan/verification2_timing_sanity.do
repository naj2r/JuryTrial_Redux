/*==============================================================================
  verification2_timing_sanity.do

  Purpose:  Spot-check that treatment aligns with election years.
            For 10 randomly chosen counties, list year-by-year treatment status.
            Visual inspection catches:
              - pressure==1 in non-election years
              - pressure==0 in election years where incumbent ran
              - contested in non-pressure years (impossible by construction)

  Usage: do code/michigan/verification2_timing_sanity.do
  Requires: paths.do has been run (or run this after master_build_all.do)
==============================================================================*/

clear all
set more off
set update_query off

* --- Set paths ---
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"

* --- Log ---
log using "$LOGS/verification2_timing_sanity.log", replace

di _n "{hline 72}"
di "VERIFICATION 2: TREATMENT TIMING SANITY CHECK"
di "{hline 72}"

* =============================================================================
* CHECK A: 10 random counties from Panel B
* =============================================================================

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Construct primary-only flag (may not survive pipeline collapse)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* Select 10 random counties (reproducible seed)
set seed 12345
tempvar u
gen `u' = runiform()
bys county_id: replace `u' = `u'[1]
egen _rank = group(`u')

* Get the county IDs for the first 10 ranks
qui levelsof county_id if _rank <= 10, local(sample_counties)
keep if _rank <= 10
drop _rank

di _n "=== SAMPLE OF 10 COUNTIES ==="
di "Counties in sample:"
qui levelsof county_id, local(cl)
foreach c of local cl {
    di "  county_id = `c'"
}

sort county_id year

di _n "=== YEAR-BY-YEAR TREATMENT STATUS ==="
di _n "Columns: year | pressure | contested_long | contested | uncontested | primary_only"
di "{hline 72}"

list county_id year treat_pros_pressure treat_pros_contested_long ///
    treat_pros_contested treat_pros_uncontested treat_pros_primary_only, ///
    sepby(county_id) noobs abbreviate(20)

* =============================================================================
* CHECK B: Logical consistency within the sample
* =============================================================================

di _n "{hline 72}"
di "LOGICAL CONSISTENCY CHECKS"
di "{hline 72}"

* No contested without pressure
qui count if treat_pros_contested == 1 & treat_pros_pressure == 0
di "  Contested without pressure: " r(N) " (should be 0)"

* No contested_long without contested
qui count if treat_pros_contested_long == 1 & treat_pros_contested == 0
di "  Contested_long without contested: " r(N) " (should be 0)"

* No uncontested without pressure
qui count if treat_pros_uncontested == 1 & treat_pros_pressure == 0
di "  Uncontested without pressure: " r(N) " (should be 0)"

* Pressure should be 0 in non-election years
* Michigan prosecutor elections: every 4 years
* Election years in panel: 2004, 2008, 2012, 2016, 2024
* (2020 excluded for COVID)
qui count if treat_pros_pressure == 1 & !inlist(year, 2004, 2008, 2012, 2016, 2024)
di "  Pressure in non-election year: " r(N) " (should be 0)"

* =============================================================================
* CHECK C: Full panel election-year distribution
* =============================================================================

di _n "{hline 72}"
di "FULL PANEL: ELECTION YEAR DISTRIBUTION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear

di _n "=== Treatment by year (full panel) ==="
tab year treat_pros_pressure

di _n "=== Contested_long by year ==="
tab year treat_pros_contested_long

di _n "=== Contested by year ==="
tab year treat_pros_contested

di _n "=== Uncontested by year ==="
tab year treat_pros_uncontested

di _n "=== VERIFICATION 2 COMPLETE ==="

log close
