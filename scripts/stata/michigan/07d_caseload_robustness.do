/*==============================================================================
  07d_caseload_robustness.do

  Purpose:  Caseload robustness regressions for the identification triangle:
            Prong 1 — Falsification: incoming felony caseload does not respond
                      to electoral pressure (kills the demand confound)
            Prong 2 — Congestion control: main jury results survive controlling
                      for contemporaneous log(pending felony + 1)

  Input:    $DATA_FINAL/michigan_panel_B.dta  (main regression panel, 579 obs)
            $DATA_INT/mi_caseload_panel.dta   (caseload panel from 03b)

  Output:   $OUTPUT/results/mi_caseload_results.csv

  Design notes:
    - Standalone file (not part of master_build_all.do)
    - Copies run_reg program from 07_regressions.do for standalone execution
    - Pending is CONTEMPORANEOUS (stock variable, evolves gradually — proxies
      court congestion environment, not a flow that responds to treatment)
    - Incoming is the primary falsification DV (one clean message)

  Requires: 01-07 pipeline must have run. 03b must have run.
            OR: cd to results_rebuild/ and run directly (auto-bootstraps).
==============================================================================*/

* --- Bootstrap: allow standalone execution ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

di as text _newline "========================================"
di as text "  07d_caseload_robustness.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* SETUP: Output CSV
* =============================================================================

capture mkdir "$OUTPUT/results"

global REG_CSV "$OUTPUT/results/mi_caseload_results.csv"

* Initialize CSV (same header as mi_regression_results.csv for compatibility)
tempname fh
file open `fh' using "$REG_CSV", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_treated,n_clusters,share_treated,fe_unit,fe_year,cluster" _n
file close `fh'

di "Results CSV initialized: $REG_CSV"

* Equality test CSV (for T2/T3 contested = uncontested tests)
global EQ_CSV "$OUTPUT/results/mi_caseload_equality_tests.csv"

tempname fh2
file open `fh2' using "$EQ_CSV", write replace
file write `fh2' "variant,tier,spec_name,outcome,tvar1,tvar2,beta1,beta2,diff,F_stat,p_equality,n_obs,n_clusters" _n
file close `fh2'


* =============================================================================
* PROGRAM: run_reg (copied from 07_regressions.do for standalone execution)
* =============================================================================

capture program drop run_reg
program define run_reg
    syntax , variant(string) tier(string) spec(string) ///
        outcome(string) treatvars(string) ///
        fe_unit(string) cluster(string) [controls(string)]

    * Check outcome exists and has enough observations
    capture confirm variable `outcome'
    if _rc {
        di "  SKIP `variant'|`outcome': variable not found"
        exit
    }
    qui count if !missing(`outcome')
    if r(N) < 20 {
        di "  SKIP `variant'|`outcome': <20 nonmissing (N=" r(N) ")"
        exit
    }

    * Run regression (controls included if specified)
    capture noisily reghdfe `outcome' `treatvars' `controls', ///
        absorb(`fe_unit' year) vce(cluster `cluster')

    if _rc {
        di "  FAILED `variant'|`tier'|`outcome'"
        exit
    }

    * Extract and save results for ALL treatment variables
    local nobs = e(N)
    local nclu = e(N_clust)

    * --- Equality test: when 2 treatment vars, test beta1 = beta2 ---
    local ntv : word count `treatvars'
    if `ntv' == 2 {
        local tv1 : word 1 of `treatvars'
        local tv2 : word 2 of `treatvars'
        local b1 = _b[`tv1']
        local b2 = _b[`tv2']
        local diff = `b1' - `b2'
        capture test `tv1' = `tv2'
        if !_rc {
            local F_eq = r(F)
            local p_eq = r(p)
            tempname fhq
            file open `fhq' using "$EQ_CSV", write append
            file write `fhq' ///
                `"`variant'"' "," `"`tier'"' "," `"`spec'"' "," ///
                `"`outcome'"' "," `"`tv1'"' "," `"`tv2'"' "," ///
                (`b1') "," (`b2') "," (`diff') "," ///
                (`F_eq') "," (`p_eq') "," (`nobs') "," (`nclu') _n
            file close `fhq'
            di "  EQUALITY TEST `outcome': F=" %7.3f `F_eq' " p=" %6.4f `p_eq' ///
                " (diff=" %9.4f `diff' ")"
        }
    }

    foreach tvar of local treatvars {
        local b    = _b[`tvar']
        local se   = _se[`tvar']
        local t    = `b' / `se'
        local p    = 2 * ttail(e(df_r), abs(`t'))
        local ci_lo = `b' - invttail(e(df_r), 0.025) * `se'
        local ci_hi = `b' + invttail(e(df_r), 0.025) * `se'

        * Count treated in estimation sample
        qui count if `tvar' == 1 & e(sample)
        local n_treat = r(N)
        local share = `n_treat' / `nobs'

        * Append to CSV
        tempname fh
        file open `fh' using "$REG_CSV", write append
        file write `fh' ///
            `"`variant'"' "," `"`tier'"' "," `"`spec'"' "," ///
            `"`outcome'"' "," `"`tvar'"' "," ///
            (`b') "," (`se') "," (`p') "," (`ci_lo') "," (`ci_hi') "," ///
            (`nobs') "," (`n_treat') "," (`nclu') "," (`share') "," ///
            `"`fe_unit'"' "," "year" "," `"`cluster'"' _n
        file close `fh'

        di "  `variant' | `tier' | `outcome' | `tvar' | b=" %9.4f `b' ///
            " se=" %9.4f `se' " p=" %6.4f `p' " N=`nobs' cl=`nclu'"
    }
end


* =============================================================================
* LOAD DATA: Panel B + merge caseload
* =============================================================================

di _n "{hline 72}"
di "LOADING PANEL B + MERGING CASELOAD DATA"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Panel B loaded: " _N " obs"

* Merge caseload panel
merge m:1 county year using "$DATA_INT/mi_caseload_panel.dta", ///
    keepusing(incoming_felony pending_felony ///
              incoming_felony_lag1 outgoing_felony clearance_rate ///
              clearance_rate_lead1 log_outgoing ///
              d_clearance_rate d_clearance_rate_lead1) ///
    keep(master match)

* Merge diagnostics
tab _merge
qui count if _merge == 1
local n_unmatched = r(N)
qui count if _merge == 3
local n_matched = r(N)
di _n "MERGE RESULTS: `n_matched' matched, `n_unmatched' unmatched"
if `n_unmatched' > 0 {
    di as error "WARNING: `n_unmatched' jury panel obs could not be matched to caseload data"
    list county year if _merge == 1
}
drop _merge

* Generate controls
capture gen log_county_pop = ln(county_pop)

* Generate primary-only flag for T2 exclusion
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* Verify pending_felony is non-missing for all obs
qui count if missing(pending_felony)
di "Missing pending_felony: " r(N) " of " _N
assert r(N) == 0

* Quick summary of caseload variables
di _n "--- Caseload variable summary ---"
tabstat incoming_felony pending_felony outgoing_felony clearance_rate, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

di _n "Obs: " _N


* =============================================================================
* PRONG 1: FALSIFICATION — Incoming caseload as DV
* =============================================================================
* Goal: One clean message — "We do not observe systematic increases in
*       incoming felony caseloads under electoral pressure."

di _n "{hline 72}"
di "PRONG 1: FALSIFICATION (incoming caseload as DV)"
di "{hline 72}"

* --- Tier 1: Baseline (pressure) ---
di _n "=== T1: BASELINE ==="
run_reg, variant("B_falsi") tier("T1_baseline") spec("pressure") ///
    outcome("incoming_felony") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

* --- Tier 2: Mechanism (contested_long + uncontested) ---
di _n "=== T2: MECHANISM ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    di "  T2 sample (primary-only excluded): " _N

    run_reg, variant("B_falsi") tier("T2_mechanism") spec("contested_long") ///
        outcome("incoming_felony") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
restore

* --- Tier 3: Robustness (contested + uncontested) ---
di _n "=== T3: ROBUSTNESS ==="
run_reg, variant("B_falsi") tier("T3_robustness") spec("contested") ///
    outcome("incoming_felony") treatvars("treat_pros_contested treat_pros_uncontested") ///
    fe_unit("county_id") cluster("county_id")

* --- Lag test: incoming_{t-1} as DV (placebo/pre-trends) ---
di _n "=== PLACEBO: incoming_felony_lag1 ==="
run_reg, variant("B_falsi") tier("T1_baseline") spec("pressure_lag") ///
    outcome("incoming_felony_lag1") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

* --- log_incoming REMOVED: log outcomes inappropriate with many zeros ---
* (was: run_reg on log_incoming, removed 2026-03-21)


* =============================================================================
* PRONG 1b: CLEARANCE RATE — Mechanism via case resolution
* =============================================================================
* Goal: Test whether prosecutors clear more cases under electoral pressure.
*       Clearance rate = outgoing / incoming, derived from stock-flow identity:
*       outgoing = pending_{t-1} + incoming - pending_t

di _n "{hline 72}"
di "PRONG 1b: CLEARANCE RATE (current + lead)"
di "{hline 72}"

* Report clearance rate summary
di _n "--- Clearance rate summary ---"
tabstat clearance_rate clearance_rate_lead1, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

* --- Current clearance rate ---
di _n "=== CLEARANCE RATE (current year) ==="
run_reg, variant("B_mech") tier("T1_baseline") spec("pressure") ///
    outcome("clearance_rate") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    run_reg, variant("B_mech") tier("T2_mechanism") spec("contested_long") ///
        outcome("clearance_rate") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
restore

run_reg, variant("B_mech") tier("T3_robustness") spec("contested") ///
    outcome("clearance_rate") treatvars("treat_pros_contested treat_pros_uncontested") ///
    fe_unit("county_id") cluster("county_id")

* --- Lead clearance rate (t+1) ---
di _n "=== CLEARANCE RATE LEAD (t+1) ==="
run_reg, variant("B_mech") tier("T1_baseline") spec("pressure_lead") ///
    outcome("clearance_rate_lead1") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    run_reg, variant("B_mech") tier("T2_mechanism") spec("contested_long_lead") ///
        outcome("clearance_rate_lead1") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
restore

run_reg, variant("B_mech") tier("T3_robustness") spec("contested_lead") ///
    outcome("clearance_rate_lead1") treatvars("treat_pros_contested treat_pros_uncontested") ///
    fe_unit("county_id") cluster("county_id")


* =============================================================================
* PRONG 1c: FIRST-DIFFERENCED CLEARANCE RATE — Nickell attenuation
* =============================================================================
* FD removes level persistence, focusing on year-to-year changes.
* If results survive FD, serial correlation in the stock is not driving them.
* Uses county+year FE on the differenced variable.

di _n "{hline 72}"
di "PRONG 1c: FIRST-DIFFERENCED CLEARANCE (Nickell attenuation)"
di "{hline 72}"

* Report FD summary
di _n "--- First-differenced clearance rate summary ---"
tabstat d_clearance_rate d_clearance_rate_lead1, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.4f)

* --- FD clearance rate (current) ---
di _n "=== FD CLEARANCE RATE (current year) ==="
run_reg, variant("B_mech_fd") tier("T1_baseline") spec("pressure") ///
    outcome("d_clearance_rate") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    run_reg, variant("B_mech_fd") tier("T2_mechanism") spec("contested_long") ///
        outcome("d_clearance_rate") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
restore

run_reg, variant("B_mech_fd") tier("T3_robustness") spec("contested") ///
    outcome("d_clearance_rate") treatvars("treat_pros_contested treat_pros_uncontested") ///
    fe_unit("county_id") cluster("county_id")

* --- FD clearance rate lead (t+1) ---
di _n "=== FD CLEARANCE RATE LEAD (t+1) ==="
run_reg, variant("B_mech_fd") tier("T1_baseline") spec("pressure_lead") ///
    outcome("d_clearance_rate_lead1") treatvars("treat_pros_pressure open_pros") ///
    fe_unit("county_id") cluster("county_id")

preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    run_reg, variant("B_mech_fd") tier("T2_mechanism") spec("contested_long_lead") ///
        outcome("d_clearance_rate_lead1") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
restore

run_reg, variant("B_mech_fd") tier("T3_robustness") spec("contested_lead") ///
    outcome("d_clearance_rate_lead1") treatvars("treat_pros_contested treat_pros_uncontested") ///
    fe_unit("county_id") cluster("county_id")


* =============================================================================
* PRONG 2: CONGESTION CONTROL — Main outcomes + log(pending)
* =============================================================================
* Goal: Show headline jury results survive controlling for contemporaneous
*       pending caseload (stock variable, proxies congestion environment).

di _n "{hline 72}"
di "PRONG 2: CONGESTION CONTROL (main outcomes + pending_felony)"
di "{hline 72}"

* Core outcomes: actually_reported, told_to_report, pct_told_to_report
local core_outcomes "actually_reported told_to_report pct_told_to_report"

* --- Tier 1: Baseline with congestion control ---
di _n "=== T1: BASELINE + pending_felony ==="
foreach y of local core_outcomes {
    run_reg, variant("B_caseload") tier("T1_baseline") spec("pressure_pending") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("pending_felony")
}

* --- Tier 2: Mechanism with congestion control ---
di _n "=== T2: MECHANISM + pending_felony ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y of local core_outcomes {
        run_reg, variant("B_caseload") tier("T2_mechanism") spec("contested_long_pending") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id") controls("pending_felony")
    }
restore

* --- Tier 3: Robustness with congestion control ---
di _n "=== T3: ROBUSTNESS + pending_felony ==="
foreach y of local core_outcomes {
    run_reg, variant("B_caseload") tier("T3_robustness") spec("contested_pending") ///
        outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id") controls("pending_felony")
}


* =============================================================================
* SUMMARY: Compare baseline vs. caseload-controlled
* =============================================================================

di _n "{hline 72}"
di "SUMMARY: COEFFICIENT COMPARISON"
di "{hline 72}"

* Re-run baseline (no control) for actually_reported to compare
di _n "--- Baseline (no caseload control): actually_reported ---"
reghdfe actually_reported treat_pros_pressure, ///
    absorb(county_id year) vce(cluster county_id)
local b_base = _b[treat_pros_pressure]
local se_base = _se[treat_pros_pressure]
local p_base = 2 * ttail(e(df_r), abs(`b_base'/`se_base'))

di _n "--- With pending_felony control: actually_reported ---"
reghdfe actually_reported treat_pros_pressure pending_felony, ///
    absorb(county_id year) vce(cluster county_id)
local b_ctrl = _b[treat_pros_pressure]
local se_ctrl = _se[treat_pros_pressure]
local p_ctrl = 2 * ttail(e(df_r), abs(`b_ctrl'/`se_ctrl'))
local b_pending = _b[pending_felony]

di _n "==========================================="
di "HEADLINE COMPARISON: Actually Reported"
di "==========================================="
di "Baseline:   b = " %9.2f `b_base' "  se = " %9.2f `se_base' "  p = " %6.4f `p_base'
di "Controlled: b = " %9.2f `b_ctrl'  "  se = " %9.2f `se_ctrl'  "  p = " %6.4f `p_ctrl'
di "Change:     " %6.1f ((`b_ctrl' - `b_base') / `b_base' * 100) "%"
di "pending_felony coeff: " %9.2f `b_pending'
di "==========================================="


di _n "========================================"
di "  07d_caseload_robustness.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
