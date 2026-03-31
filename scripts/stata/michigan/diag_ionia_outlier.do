/*==============================================================================
  diag_ionia_outlier.do

  Purpose:  Examine Ionia County's pct_told_to_report = 2.17 in 2016.
            A value > 1.0 means more jurors were told to report than were
            summoned, which is definitionally impossible unless:
            (a) data entry error, (b) carry-over from prior year's summons,
            or (c) numerator/denominator mismatch.

  Input:    $DATA_FINAL/michigan_panel_B.dta
  Output:   $DIAGNOSTICS/diag_ionia_outlier.log

  Run:      do code/master/paths.do
            do code/michigan/diag_ionia_outlier.do
==============================================================================*/

set update_query off
set more off

capture log close _all

local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

log using "$DIAGNOSTICS/diag_ionia_outlier.log", replace text

di _n as result "================================================================"
di as result "  IONIA COUNTY OUTLIER DIAGNOSTIC"
di as result "================================================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Identify county_id type and find Ionia's code
di _n as text "--- county_id variable type ---"
describe county_id
* Decode to string for filtering
decode county_id, gen(county_name)

* --- Full panel for Ionia ---
di _n as text "--- Ionia County: full panel ---"
list county_name year summoned told_to_report actually_reported ///
    pct_told_to_report treat_pros_pressure ///
    if county_name == "Ionia", noobs sepby(county_name)

* --- Compute the ratio manually ---
di _n as text "--- Manual ratio: told_to_report / summoned ---"
gen manual_pct = told_to_report / summoned if county_name == "Ionia"
list county_name year summoned told_to_report manual_pct pct_told_to_report ///
    if county_name == "Ionia", noobs
drop manual_pct

* --- How many counties have pct_told_to_report > 1? ---
di _n as text "--- Counties with pct_told_to_report > 1 (any year) ---"
list county_name year summoned told_to_report pct_told_to_report ///
    if pct_told_to_report > 1 & !missing(pct_told_to_report), noobs

* --- Distribution of pct_told_to_report ---
di _n as text "--- Distribution of pct_told_to_report ---"
sum pct_told_to_report, detail

* --- Counties with pct_told_to_report > 0.95 ---
di _n as text "--- Counties with pct_told_to_report > 0.95 (any year) ---"
list county_name year summoned told_to_report pct_told_to_report ///
    if pct_told_to_report > 0.95 & !missing(pct_told_to_report), noobs

* --- Verdict and composition for Ionia ---
di _n as text "--- Ionia County: verdict and composition outcomes ---"
list county_name year total_jury_verdicts capital_felony pct_other_felony ///
    if county_name == "Ionia", noobs

* --- Check raw data for Ionia ---
di _n as text "--- Ionia County: all available variables ---"
describe summoned told_to_report actually_reported pct_told_to_report

* --- Treatment status for Ionia ---
di _n as text "--- Ionia County: treatment status ---"
list county_name year treat_pros_pressure treat_pros_contested_long ///
    treat_pros_contested treat_pros_uncontested ///
    if county_name == "Ionia", noobs

di _n as result "================================================================"
di as result "  OUTLIER DIAGNOSTIC COMPLETE"
di as result "================================================================"

log close
