/*==============================================================================
  diag_2016_influence.do

  Purpose:  Diagnose WHY the 2016 election cycle is so influential in the
            pooled T1 estimate. Tests 4 hypotheses:

            H1: First-year anchoring / level shift
            H2: Treatment intensity / composition differs in 2016
            H3: Institutional reporting stabilization (missingness)
            H4: Election environment (high-salience year)

  Input:    $DATA_FINAL/michigan_panel_B.dta
  Output:   $DIAGNOSTICS/diag_2016_influence.log  (screen + log)

  Run:      do code/master/paths.do
            do code/michigan/diag_2016_influence.do
==============================================================================*/

set update_query off
set more off

* --- Setup ---
capture log close _all

* Bootstrap the paths (CODE_MASTER not yet set)
local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

log using "$DIAGNOSTICS/diag_2016_influence.log", replace text

di _n as result "================================================================"
di as result "  2016 INFLUENCE DIAGNOSTIC"
di as result "  Dataset: michigan_panel_B.dta (primary specification)"
di as result "================================================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Key pipeline outcomes: actually_reported told_to_report pct_told_to_report
*   summoned total_jury_verdicts capital_felony pct_other_felony


/*--------------------------------------------------------------------------
  HYPOTHESIS 1: First-year anchoring / level shift
  Compare 2016 outcome distributions vs later years.
  If 2016 has systematically larger pipeline counts, it will inflate beta.
--------------------------------------------------------------------------*/
di _n as result "================================================================"
di as result "  H1: FIRST-YEAR ANCHORING / LEVEL SHIFT"
di as result "================================================================"

di _n as text "--- Panel A: Mean outcomes by year ---"
table year, stat(mean actually_reported told_to_report summoned) ///
    stat(count actually_reported) nformat(%9.1f)

di _n as text "--- Panel B: Mean verdict/composition outcomes by year ---"
table year, stat(mean total_jury_verdicts capital_felony pct_other_felony) ///
    stat(count total_jury_verdicts) nformat(%9.3f)

di _n as text "--- Panel C: Mean told-to-report share by year ---"
table year, stat(mean pct_told_to_report) ///
    stat(sd pct_told_to_report) ///
    stat(count pct_told_to_report) nformat(%9.3f)

* Formal comparison: 2016 vs all other years
di _n as text "--- T-tests: 2016 vs other years for key outcomes ---"
gen is_2016 = (year == 2016)

foreach v in actually_reported told_to_report pct_told_to_report ///
    summoned total_jury_verdicts pct_other_felony {
    di _n as text "=== `v' ==="
    ttest `v', by(is_2016)
}

* Within-county deviation: how far is each county's 2016 from its own mean?
di _n as text "--- Within-county deviations: 2016 vs county mean ---"
foreach v in actually_reported told_to_report pct_told_to_report {
    bys county_id: egen mean_`v' = mean(`v')
    gen dev_`v' = `v' - mean_`v'
    di _n as text "`v': mean within-county deviation in 2016 vs other years"
    tabstat dev_`v', by(is_2016) stat(mean sd min max n) format(%9.1f)
    drop mean_`v' dev_`v'
}


/*--------------------------------------------------------------------------
  HYPOTHESIS 2: Treatment intensity / composition
  Does 2016 have more/different treatment than other election years?
--------------------------------------------------------------------------*/
di _n as result "================================================================"
di as result "  H2: TREATMENT INTENSITY / COMPOSITION"
di as result "================================================================"

di _n as text "--- Treatment rates by year ---"
table year, stat(mean treat_pros_pressure treat_pros_contested_long ///
    treat_pros_contested treat_pros_uncontested) ///
    stat(count treat_pros_pressure) nformat(%9.3f)

di _n as text "--- Number of treated counties by year ---"
foreach tvar in treat_pros_pressure treat_pros_contested_long ///
    treat_pros_contested treat_pros_uncontested {
    di _n as text "Treated counties per year: `tvar'"
    tab year `tvar', row
}

* Treatment composition in election years only
di _n as text "--- Treatment composition: election years (2016, 2024) only ---"
preserve
    keep if year == 2016 | year == 2024
    di _n as text "Pressure rate:"
    tab year treat_pros_pressure, row
    di _n as text "Contested (general election):"
    tab year treat_pros_contested_long, row
    di _n as text "Contested (any stage):"
    tab year treat_pros_contested, row
    di _n as text "Uncontested:"
    tab year treat_pros_uncontested, row
restore

* Average outcome among TREATED units, by year
di _n as text "--- Mean outcomes among TREATED counties only, by year ---"
preserve
    keep if treat_pros_pressure == 1
    table year, stat(mean actually_reported told_to_report pct_told_to_report) ///
        stat(count actually_reported) nformat(%9.1f)
    di _n as text "Verdict outcomes among treated:"
    table year, stat(mean total_jury_verdicts pct_other_felony) ///
        stat(count total_jury_verdicts) nformat(%9.3f)
restore

* Average outcome among UNTREATED units, by year
di _n as text "--- Mean outcomes among UNTREATED counties only, by year ---"
preserve
    keep if treat_pros_pressure == 0
    table year, stat(mean actually_reported told_to_report pct_told_to_report) ///
        stat(count actually_reported) nformat(%9.1f)
restore

* Treated-untreated gap by year (the raw DiD contrast)
di _n as text "--- Treated minus Untreated gap by year (raw DiD contrast) ---"
foreach v in actually_reported told_to_report pct_told_to_report {
    di _n as text "=== `v' ==="
    bys year treat_pros_pressure: egen yr_trt_mean_`v' = mean(`v')
    preserve
        collapse (mean) yr_trt_mean_`v', by(year treat_pros_pressure)
        reshape wide yr_trt_mean_`v', i(year) j(treat_pros_pressure)
        gen gap_`v' = yr_trt_mean_`v'1 - yr_trt_mean_`v'0
        list year yr_trt_mean_`v'0 yr_trt_mean_`v'1 gap_`v', noobs
    restore
    drop yr_trt_mean_`v'
}


/*--------------------------------------------------------------------------
  HYPOTHESIS 3: Institutional reporting stabilization (missingness)
  Check if 2016 has different missingness or data completeness.
--------------------------------------------------------------------------*/
di _n as result "================================================================"
di as result "  H3: REPORTING STABILIZATION / MISSINGNESS"
di as result "================================================================"

di _n as text "--- Observations per year ---"
tab year

di _n as text "--- Missing values per outcome per year ---"
foreach v in actually_reported told_to_report pct_told_to_report ///
    summoned total_jury_verdicts capital_felony pct_other_felony {
    di _n as text "`v': count of non-missing by year"
    gen nm_`v' = !missing(`v')
    tab year nm_`v', row
    drop nm_`v'
}

* Zero-value prevalence (counties reporting zero for a pipeline variable)
di _n as text "--- Zero-value prevalence by year ---"
foreach v in actually_reported told_to_report summoned ///
    total_jury_verdicts capital_felony {
    di _n as text "`v': count of zeros by year"
    gen zero_`v' = (`v' == 0) if !missing(`v')
    tab year zero_`v', row
    drop zero_`v'
}

* County coverage: how many distinct counties per year?
di _n as text "--- Distinct counties with non-missing data by year ---"
foreach v in actually_reported told_to_report pct_told_to_report {
    di _n as text "`v':"
    preserve
        keep if !missing(`v')
        egen _tag = tag(year county_id)
        bys year: egen n_counties_`v' = total(_tag)
        collapse (first) n_counties_`v', by(year)
        list, noobs
    restore
}


/*--------------------------------------------------------------------------
  HYPOTHESIS 4: County-level leverage
  Which counties contribute most to the 2016 effect?
  Show the largest treated-untreated swings at the county level.
--------------------------------------------------------------------------*/
di _n as result "================================================================"
di as result "  H4: COUNTY-LEVEL LEVERAGE IN 2016"
di as result "================================================================"

* For each county: compute mean outcome in treated vs untreated years
di _n as text "--- Counties with largest treated-year deviations (actually_reported) ---"
preserve
    bys county_id: egen county_mean_ar = mean(actually_reported)
    gen dev_ar = actually_reported - county_mean_ar
    keep if year == 2016
    gsort -dev_ar
    list county_id dev_ar actually_reported county_mean_ar in 1/10, noobs
    di _n as text "Bottom 10:"
    gsort dev_ar
    list county_id dev_ar actually_reported county_mean_ar in 1/10, noobs
restore

* Same for pct_told_to_report
di _n as text "--- Counties with largest treated-year deviations (pct_told_to_report) ---"
preserve
    bys county_id: egen county_mean_ptr = mean(pct_told_to_report)
    gen dev_ptr = pct_told_to_report - county_mean_ptr
    keep if year == 2016
    gsort -dev_ptr
    list county_id dev_ptr pct_told_to_report county_mean_ptr in 1/10, noobs
    di _n as text "Bottom 10:"
    gsort dev_ptr
    list county_id dev_ptr pct_told_to_report county_mean_ptr in 1/10, noobs
restore


/*--------------------------------------------------------------------------
  SUMMARY: Variance decomposition
  How much of the overall within-county variance in outcomes
  comes from 2016?
--------------------------------------------------------------------------*/
di _n as result "================================================================"
di as result "  VARIANCE DECOMPOSITION: 2016 vs OTHER YEARS"
di as result "================================================================"

foreach v in actually_reported told_to_report pct_told_to_report {
    * Demean within county
    bys county_id: egen cmean_`v' = mean(`v')
    gen resid_`v' = (`v' - cmean_`v')^2

    * Total within-county variance
    qui sum resid_`v'
    local total_var = r(sum)
    local total_n   = r(N)

    * 2016 contribution
    qui sum resid_`v' if year == 2016
    local var_2016 = r(sum)
    local n_2016   = r(N)

    local pct_var = 100 * `var_2016' / `total_var'
    local pct_n   = 100 * `n_2016' / `total_n'

    di _n as text "`v':"
    di as text "  Total within-county SS: " %12.1f `total_var' " (N = `total_n')"
    di as text "  2016 contribution:      " %12.1f `var_2016' " (N = `n_2016')"
    di as text "  2016 share of variance: " %5.1f `pct_var' "% (vs " %5.1f `pct_n' "% of obs)"
    di as text "  Leverage ratio:         " %5.2f (`pct_var'/`pct_n')

    drop cmean_`v' resid_`v'
}

drop is_2016

di _n as result "================================================================"
di as result "  DIAGNOSTIC COMPLETE"
di as result "================================================================"

log close
