/*==============================================================================
  07_regressions.do

  Purpose:  Run all MI TWFE regressions across county-level variants (A/B/C)
            and court-level subsamples. Outputs results to CSV for comparison
            against original benchmark estimates.

  Specification:
    reghdfe outcome treatment, absorb(unit_fe year) vce(cluster cluster_var)

  Treatment tiers:
    Tier 1 (Baseline):   treat_pros_pressure  (incumbent running)
    Tier 2 (Mechanism):  treat_pros_contested_long + treat_pros_uncontested
                         (general-election contested vs fully unopposed;
                          primary-only contested county-years excluded from sample)
    Tier 3 (Robustness): treat_pros_contested + treat_pros_uncontested
                         (any-stage contested vs fully unopposed)

  Aggregation variants (county-level):
    A: felony-focused (STANDALONE_CP + fallback COMBINED)   — 579 obs, 83 counties
    B: all-courts expanded (COMBINED else sum non-COMBINED)  — 579 obs, 83 counties
    C: combined-only (COMBINED courts only)                  — 307 obs, 44 counties

  Court-level subsamples:
    COURT_ALL:         all mapped courts
    COURT_STALONE_CP:  standalone circuit/probate only
    COURT_COMBINED:    combined courts only
    COURT_DISTRICT:    district/3rd circuit only

  County-level FE:  absorb(county_id year), vce(cluster county_id)
  Court-level FE:   absorb(court_id year),  vce(cluster county_id)
    (cross-level: court FE for precision, county clustering for inference)

  Input:    $DATA_FINAL/michigan_panel_A.dta
            $DATA_FINAL/michigan_panel_B.dta
            $DATA_FINAL/michigan_panel_C.dta
            $DATA_FINAL/michigan_court_level.dta

  Output:   $OUTPUT/results/mi_regression_results.csv

  Requires: paths.do, globals.do, 01-06 must have run, reghdfe installed.
            OR: cd to results_rebuild/ and run this file directly (auto-bootstraps).
==============================================================================*/

* --- Bootstrap: allow standalone execution ---
* If called from master_build_all.do, $ROOT is already set — skip.
* If run directly, this block sets all path globals automatically.
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

* NOTE: Do NOT use `clear all` here — it wipes globals set by paths.do.
* Use `clear` (clears data only) instead.
clear
set more off

di as text _newline "========================================"
di as text "  07_regressions.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* SETUP: Output directory + CSV header
* =============================================================================

capture mkdir "$OUTPUT/results"

* Define output CSV path
global REG_CSV "$OUTPUT/results/mi_regression_results.csv"

* Initialize CSV (overwrite any prior run — idempotent)
tempname fh
file open `fh' using "$REG_CSV", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_treated,n_clusters,share_treated,fe_unit,fe_year,cluster" _n
file close `fh'

di "Results CSV initialized: $REG_CSV"

* Define equality-test CSV path (F-test: beta_contested = beta_uncontested)
global EQ_CSV "$OUTPUT/results/mi_equality_tests.csv"

tempname fh2
file open `fh2' using "$EQ_CSV", write replace
file write `fh2' "variant,tier,spec_name,outcome,tvar1,tvar2,beta1,beta2,diff,F_stat,p_equality,n_obs,n_clusters" _n
file close `fh2'

di "Equality-test CSV initialized: $EQ_CSV"


* =============================================================================
* PROGRAM: run_reg — run one regression and append results to CSV
* =============================================================================
* Arguments:
*   variant   — A, B, C, COURT_ALL, COURT_STALONE_CP, COURT_COMBINED, COURT_DISTRICT
*   tier      — T1_baseline, T2_mechanism, T3_robustness, T4_per10k
*   spec      — pressure, contested_long, contested
*   outcome   — variable name
*   treatvars — space-separated treatment variable(s)
*   fe_unit   — absorb unit variable (county_id or court_id)
*   cluster   — cluster variable (county_id)
*
* NOTE: Writes one CSV row per treatment variable. For T2/T3 with two
*       treatment dummies, this produces two rows from one regression.

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
            * Append to equality-test CSV
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
        else {
            di "  EQUALITY TEST FAILED for `outcome' (test command rc=" _rc ")"
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
* PROGRAM: run_variant — run all tiers for one county-level dataset
* =============================================================================

capture program drop run_variant
program define run_variant
    syntax , variant(string) datafile(string) [controls(string) spec_suffix(string)]

    di _n "{hline 72}"
    di "VARIANT `variant': `datafile'"
    if "`controls'" != "" di "  Controls: `controls' (spec suffix: `spec_suffix')"
    di "{hline 72}"

    use "`datafile'", clear
    capture gen log_county_pop = ln(county_pop)
    * Construct primary-only flag (may not survive pipeline collapse)
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    di "Obs: " _N

    * --- Outcome lists ---
    local rate_outcomes   "pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate pct_capital_felony pct_other_felony pct_other_cases"
    local count_outcomes  "total_jury_verdicts capital_felony other_felony other_cases"
    local summon_outcomes "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"

    * Combined list for Tiers 1-3
    local all_outcomes "`rate_outcomes' `count_outcomes' `summon_outcomes'"

    * Per-10k list for Tier 4
    local p10k_outcomes ""
    foreach v of local count_outcomes {
        capture confirm variable `v'_p10k
        if !_rc {
            local p10k_outcomes "`p10k_outcomes' `v'_p10k"
        }
    }
    foreach v of local summon_outcomes {
        capture confirm variable `v'_p10k
        if !_rc {
            local p10k_outcomes "`p10k_outcomes' `v'_p10k"
        }
    }

    * --- Pre-estimation diagnostics (skip for controlled runs) ---
    if "`spec_suffix'" == "" {
        di _n "--- Treatment distribution ---"
        tab year treat_pros_pressure
        di _n "--- Contested_long distribution ---"
        tab year treat_pros_contested_long
        di _n "--- Contested distribution ---"
        tab year treat_pros_contested
    }

    * --- Tier 1: Baseline (pressure + open seat decomposition) ---
    *     Three mutually exclusive states: non-election (omitted), incumbent running, open seat
    *     Y_ct = β1*IncumbentRunning + β2*OpenSeat + α_c + γ_t + ε_ct
    di _n "=== TIER 1: BASELINE (pressure + open_pros) `spec_suffix' ==="
    foreach y of local all_outcomes {
        run_reg, variant("`variant'") tier("T1_baseline") spec("pressure`spec_suffix'") ///
            outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
            fe_unit("county_id") cluster("county_id") controls("`controls'")
    }

    * --- Tier 2: Mechanism (contested_long + uncontested) ---
    *     Primary-only contested AND open-seat county-years excluded from T2 sample
    di _n "=== TIER 2: MECHANISM (contested_long + uncontested) `spec_suffix' ==="
    preserve
        qui drop if treat_pros_primary_only == 1
        qui drop if open_pros == 1
        di "  T2 sample (primary-only + open seats excluded): " _N
        foreach y of local all_outcomes {
            run_reg, variant("`variant'") tier("T2_mechanism") spec("contested_long`spec_suffix'") ///
                outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
                fe_unit("county_id") cluster("county_id") controls("`controls'")
        }
    restore

    * --- Tier 3: Robustness (contested + uncontested) ---
    *     Open-seat county-years excluded from T3 sample
    di _n "=== TIER 3: ROBUSTNESS (contested + uncontested) `spec_suffix' ==="
    preserve
        qui drop if open_pros == 1
        di "  T3 sample (open seats excluded): " _N
        foreach y of local all_outcomes {
            run_reg, variant("`variant'") tier("T3_robustness") spec("contested`spec_suffix'") ///
                outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
                fe_unit("county_id") cluster("county_id") controls("`controls'")
        }
    restore

    * --- Tier 4: Per-10k regressions (pressure + open seat) ---
    if "`p10k_outcomes'" != "" {
        di _n "=== TIER 4: PER-10K (pressure + open_pros) `spec_suffix' ==="
        foreach y of local p10k_outcomes {
            run_reg, variant("`variant'") tier("T4_per10k") spec("pressure`spec_suffix'") ///
                outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
                fe_unit("county_id") cluster("county_id") controls("`controls'")
        }
    }
    else {
        di _n "NOTE: No per-10k variables found in `variant'. Skipping Tier 4."
    }
end


* =============================================================================
* PROGRAM: run_court_subsample — run regressions on a court-level subsample
* =============================================================================

capture program drop run_court_subsample
program define run_court_subsample
    syntax , variant(string) [keep_condition(string) controls(string) spec_suffix(string)]

    di _n "{hline 60}"
    di "COURT SUBSAMPLE: `variant'"
    if "`keep_condition'" != "" {
        di "  Filter: `keep_condition'"
    }
    if "`controls'" != "" di "  Controls: `controls' (spec suffix: `spec_suffix')"
    di "{hline 60}"

    * Apply subsample filter if specified
    if "`keep_condition'" != "" {
        qui keep if `keep_condition'
    }
    capture gen log_county_pop = ln(county_pop)
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    di "Obs in subsample: " _N

    if _N < 20 {
        di "  SKIP `variant': too few obs (N=" _N ")"
        exit
    }

    * Court-level outcomes
    local rate_outcomes   "pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate pct_capital_felony pct_other_felony pct_other_cases"
    local count_outcomes  "total_jury_verdicts capital_felony other_felony other_cases"
    local all_outcomes    "`rate_outcomes' `count_outcomes'"

    * --- Tier 1: Baseline ---
    di _n "=== TIER 1: BASELINE (pressure) `spec_suffix' ==="
    foreach y of local all_outcomes {
        run_reg, variant("`variant'") tier("T1_baseline") spec("pressure`spec_suffix'") ///
            outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
            fe_unit("court_id") cluster("county_id") controls("`controls'")
    }

    * --- Tier 2: Mechanism ---
    *     Primary-only contested AND open-seat county-years excluded from T2 sample
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    di "  T2 sample (primary-only + open seats excluded): " _N
    di _n "=== TIER 2: MECHANISM (contested_long + uncontested) `spec_suffix' ==="
    foreach y of local all_outcomes {
        run_reg, variant("`variant'") tier("T2_mechanism") spec("contested_long`spec_suffix'") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("court_id") cluster("county_id") controls("`controls'")
    }
end


* =============================================================================
* RUN: County-level variants A, B, C
* =============================================================================

run_variant, variant("A") datafile("$DATA_FINAL/michigan_panel_A.dta")
run_variant, variant("B") datafile("$DATA_FINAL/michigan_panel_B.dta")
run_variant, variant("C") datafile("$DATA_FINAL/michigan_panel_C.dta")

* --- With log(population) control ---
run_variant, variant("A") datafile("$DATA_FINAL/michigan_panel_A.dta") controls("log_county_pop") spec_suffix("_pop")
run_variant, variant("B") datafile("$DATA_FINAL/michigan_panel_B.dta") controls("log_county_pop") spec_suffix("_pop")
run_variant, variant("C") datafile("$DATA_FINAL/michigan_panel_C.dta") controls("log_county_pop") spec_suffix("_pop")

* --- Category B robustness: all-courts county aggregate ---
run_variant, variant("D") datafile("$DATA_FINAL/michigan_panel_D.dta")
run_variant, variant("D") datafile("$DATA_FINAL/michigan_panel_D.dta") controls("log_county_pop") spec_suffix("_pop")

* --- Category C robustness: circuit-court-only county aggregate ---
run_variant, variant("E") datafile("$DATA_FINAL/michigan_panel_E.dta")
run_variant, variant("E") datafile("$DATA_FINAL/michigan_panel_E.dta") controls("log_county_pop") spec_suffix("_pop")


* =============================================================================
* RUN: Court-level regressions
* =============================================================================

di _n "{hline 72}"
di "COURT-LEVEL REGRESSIONS"
di "{hline 72}"

use "$DATA_FINAL/michigan_court_level.dta", clear
di "Court-level obs: " _N

* Verify court_id and county_id exist
capture confirm variable court_id
if _rc {
    di as error "ERROR: court_id not found. Check 05_merge_panels.do."
    error 111
}
capture confirm variable county_id
if _rc {
    di as error "ERROR: county_id not found. Check 05_merge_panels.do."
    error 111
}

* Court type indicators (idempotent)
capture drop is_standalone_cp
capture drop is_combined
capture drop is_district
gen is_standalone_cp = (court_category == "STANDALONE_CP")
gen is_combined      = (court_category == "COMBINED")
gen is_district      = (court_category == "DISTRICT_OR_3RD")

* Court-level may need total_jury_verdicts and composition shares constructed
capture confirm variable total_jury_verdicts
if _rc {
    capture confirm variable capital_felony
    capture confirm variable other_felony
    capture confirm variable other_cases
    if !_rc {
        gen total_jury_verdicts = capital_felony + other_felony + other_cases
        label var total_jury_verdicts "Total jury verdicts (sum of 3 case types)"
        di "Created total_jury_verdicts from components."
    }
}
* Construct verdict composition shares if missing (court-level)
capture confirm variable pct_capital_felony
if _rc {
    capture confirm variable total_jury_verdicts
    if !_rc {
        gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
        gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
        gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0
        di "Created verdict composition shares for court-level data."
    }
}

* Pre-estimation diagnostics
di _n "--- Court categories ---"
tab court_category
di _n "--- Treatment (pressure) ---"
tab year treat_pros_pressure

* --- ALL mapped courts ---
preserve
    run_court_subsample, variant("COURT_ALL")
restore
preserve
    run_court_subsample, variant("COURT_ALL") controls("log_county_pop") spec_suffix("_pop")
restore

* --- STANDALONE CP only ---
preserve
    run_court_subsample, variant("COURT_STALONE_CP") keep_condition("is_standalone_cp == 1")
restore
preserve
    run_court_subsample, variant("COURT_STALONE_CP") keep_condition("is_standalone_cp == 1") controls("log_county_pop") spec_suffix("_pop")
restore

* --- COMBINED only ---
preserve
    run_court_subsample, variant("COURT_COMBINED") keep_condition("is_combined == 1")
restore
preserve
    run_court_subsample, variant("COURT_COMBINED") keep_condition("is_combined == 1") controls("log_county_pop") spec_suffix("_pop")
restore

* --- DISTRICT/3RD only ---
preserve
    run_court_subsample, variant("COURT_DISTRICT") keep_condition("is_district == 1")
restore
preserve
    run_court_subsample, variant("COURT_DISTRICT") keep_condition("is_district == 1") controls("log_county_pop") spec_suffix("_pop")
restore


* =============================================================================
* ROBUSTNESS A: Leave-One-Cycle-Out
*   Drop each presidential election year individually.
*   Key outcomes only — signs should persist if effects are robust.
* =============================================================================

di _n "{hline 72}"
di "ROBUSTNESS A: LEAVE-ONE-CYCLE-OUT"
di "{hline 72}"

local key_B "actually_reported told_to_report pct_told_to_report utilization_rate total_jury_verdicts capital_felony pct_capital_felony pct_other_felony pct_other_cases"
local key_A "actually_reported told_to_report pct_told_to_report capital_felony pct_capital_felony"
local key_B_t2 "actually_reported pct_told_to_report total_jury_verdicts pct_capital_felony"

* --- Excluding 2016 ---
di _n "=== Excluding 2016 (presidential cycle) ==="

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if year == 2016
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
di "B_no2016: N=" _N
foreach y of local key_B {
    run_reg, variant("B_no2016") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    di "  B_no2016 T2 sample (primary-only + open seats excluded): " _N
    foreach y of local key_B_t2 {
        run_reg, variant("B_no2016") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore
* With log(pop) control
foreach y of local key_B {
    run_reg, variant("B_no2016") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

use "$DATA_FINAL/michigan_panel_A.dta", clear
drop if year == 2016
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
di "A_no2016: N=" _N
foreach y of local key_A {
    run_reg, variant("A_no2016") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local key_A {
    run_reg, variant("A_no2016") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}
qui drop if treat_pros_primary_only == 1
qui drop if open_pros == 1
di "  A_no2016 T2 sample (primary-only + open seats excluded): " _N
foreach y of local key_A {
    run_reg, variant("A_no2016") tier("T2_mechanism") spec("contested_long") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local key_A {
    run_reg, variant("A_no2016") tier("T2_mechanism") spec("contested_long_pop") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

* --- Excluding 2024 ---
di _n "=== Excluding 2024 (presidential cycle) ==="

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if year == 2024
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
di "B_no2024: N=" _N
foreach y of local key_B {
    run_reg, variant("B_no2024") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    di "  B_no2024 T2 sample (primary-only + open seats excluded): " _N
    foreach y of local key_B_t2 {
        run_reg, variant("B_no2024") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore
* With log(pop) control
foreach y of local key_B {
    run_reg, variant("B_no2024") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

use "$DATA_FINAL/michigan_panel_A.dta", clear
drop if year == 2024
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
di "A_no2024: N=" _N
foreach y of local key_A {
    run_reg, variant("A_no2024") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local key_A {
    run_reg, variant("A_no2024") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}
qui drop if treat_pros_primary_only == 1
qui drop if open_pros == 1
di "  A_no2024 T2 sample (primary-only + open seats excluded): " _N
foreach y of local key_A {
    run_reg, variant("A_no2024") tier("T2_mechanism") spec("contested_long") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local key_A {
    run_reg, variant("A_no2024") tier("T2_mechanism") spec("contested_long_pop") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}


* =============================================================================
* ROBUSTNESS B: Excluding Midterm Election Years
*   Drop midterm election years (2018, 2022).
*   Keep: 2016, 2017, 2019, 2023, 2024.
*   Treatment variation comes only from presidential election cycles.
*   Full spec: all tiers and outcomes via run_variant / run_court_subsample.
* =============================================================================

di _n "{hline 72}"
di "ROBUSTNESS B: EXCLUDING MIDTERM YEARS (drop 2018/2022)"
di "{hline 72}"

* --- County-level panels ---
foreach p in A B C {
    use "$DATA_FINAL/michigan_panel_`p'.dta", clear
    drop if year == 2018 | year == 2022
    di "`p'_midterm: N=" _N
    tempfile midterm_`p'
    save `midterm_`p''
    run_variant, variant("`p'_midterm") datafile("`midterm_`p''")
    run_variant, variant("`p'_midterm") datafile("`midterm_`p''") controls("log_county_pop") spec_suffix("_pop")
}

* --- Court-level ---
use "$DATA_FINAL/michigan_court_level.dta", clear
drop if year == 2018 | year == 2022
di "Court-level midterm: N=" _N

capture drop is_standalone_cp is_combined is_district
gen is_standalone_cp = (court_category == "STANDALONE_CP")
gen is_combined      = (court_category == "COMBINED")
gen is_district      = (court_category == "DISTRICT_OR_3RD")

capture confirm variable total_jury_verdicts
if _rc {
    capture confirm variable capital_felony
    capture confirm variable other_felony
    capture confirm variable other_cases
    if !_rc {
        gen total_jury_verdicts = capital_felony + other_felony + other_cases
    }
}

preserve
    run_court_subsample, variant("COURT_ALL_midterm")
restore
preserve
    run_court_subsample, variant("COURT_ALL_midterm") controls("log_county_pop") spec_suffix("_pop")
restore
preserve
    run_court_subsample, variant("COURT_STALONE_CP_midterm") keep_condition("is_standalone_cp == 1")
restore
preserve
    run_court_subsample, variant("COURT_STALONE_CP_midterm") keep_condition("is_standalone_cp == 1") controls("log_county_pop") spec_suffix("_pop")
restore
preserve
    run_court_subsample, variant("COURT_COMBINED_midterm") keep_condition("is_combined == 1")
restore
preserve
    run_court_subsample, variant("COURT_COMBINED_midterm") keep_condition("is_combined == 1") controls("log_county_pop") spec_suffix("_pop")
restore
preserve
    run_court_subsample, variant("COURT_DISTRICT_midterm") keep_condition("is_district == 1")
restore
preserve
    run_court_subsample, variant("COURT_DISTRICT_midterm") keep_condition("is_district == 1") controls("log_county_pop") spec_suffix("_pop")
restore


* =============================================================================
* ROBUSTNESS C: Population Split (above/below median county population)
*   Uses average county_pop across panel years per county.
*   All outcomes with T1 (pressure), T2 (contested_long), T3 (contested).
* =============================================================================

di _n "{hline 72}"
di "ROBUSTNESS C: POPULATION SPLIT"
di "{hline 72}"

* Full outcome lists (matching run_variant)
local rate_outcomes   "pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate pct_capital_felony pct_other_felony pct_other_cases"
local count_outcomes  "total_jury_verdicts capital_felony other_felony other_cases"
local summon_outcomes "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"
local all_outcomes    "`rate_outcomes' `count_outcomes' `summon_outcomes'"

use "$DATA_FINAL/michigan_panel_B.dta", clear
bys county_id: egen avg_pop = mean(county_pop)
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
qui sum avg_pop, detail
local median_pop = r(p50)
di "Median county avg population: `median_pop'"

* --- High population (above median) ---
* Save high-pop subsample to tempfile (avoids nested preserve)
tempfile highpop_data lowpop_data
preserve
    keep if avg_pop > `median_pop'
    di "B_highpop: N=" _N
    save `highpop_data'
restore
keep if avg_pop <= `median_pop'
di "B_lowpop: N=" _N
save `lowpop_data'

* === HIGH POP: T1, T3, then T2 (which drops obs) ===
use `highpop_data', clear

* T1: pressure
foreach y of local all_outcomes {
    run_reg, variant("B_highpop") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local all_outcomes {
    run_reg, variant("B_highpop") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

* T3: contested + uncontested (open seats excluded)
preserve
    qui drop if open_pros == 1
    di "  B_highpop T3 sample (open seats excluded): " _N
    foreach y of local all_outcomes {
        run_reg, variant("B_highpop") tier("T3_robustness") spec("contested") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
    foreach y of local all_outcomes {
        run_reg, variant("B_highpop") tier("T3_robustness") spec("contested_pop") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id") controls("log_county_pop")
    }
restore

* T2: contested_long + uncontested (exclude primary-only + open seats — destructive, run last)
qui drop if treat_pros_primary_only == 1
qui drop if open_pros == 1
di "  B_highpop T2 sample (primary-only + open seats excluded): " _N
foreach y of local all_outcomes {
    run_reg, variant("B_highpop") tier("T2_mechanism") spec("contested_long") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local all_outcomes {
    run_reg, variant("B_highpop") tier("T2_mechanism") spec("contested_long_pop") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

* === LOW POP: T1, T3, then T2 ===
use `lowpop_data', clear

* T1: pressure
foreach y of local all_outcomes {
    run_reg, variant("B_lowpop") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local all_outcomes {
    run_reg, variant("B_lowpop") tier("T1_baseline") spec("pressure_pop") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}

* T3: contested + uncontested (open seats excluded)
preserve
    qui drop if open_pros == 1
    di "  B_lowpop T3 sample (open seats excluded): " _N
    foreach y of local all_outcomes {
        run_reg, variant("B_lowpop") tier("T3_robustness") spec("contested") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
    foreach y of local all_outcomes {
        run_reg, variant("B_lowpop") tier("T3_robustness") spec("contested_pop") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id") controls("log_county_pop")
    }
restore

* T2: contested_long + uncontested (exclude primary-only + open seats — destructive, run last)
qui drop if treat_pros_primary_only == 1
qui drop if open_pros == 1
di "  B_lowpop T2 sample (primary-only + open seats excluded): " _N
foreach y of local all_outcomes {
    run_reg, variant("B_lowpop") tier("T2_mechanism") spec("contested_long") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}
foreach y of local all_outcomes {
    run_reg, variant("B_lowpop") tier("T2_mechanism") spec("contested_long_pop") ///
        outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id") controls("log_county_pop")
}


* =============================================================================
* BENCHMARK COMPARISON: Print summary table
* =============================================================================

di _n "{hline 72}"
di "RESULTS SUMMARY"
di "{hline 72}"

preserve
    import delimited "$REG_CSV", clear varnames(1)
    di _n "Total regressions run: " _N

    * Print all results sorted
    sort variant tier outcome
    list variant tier outcome treatment_var beta se p_value n_obs n_clusters, ///
        noobs clean separator(0)

    * Flag significant results
    capture drop sig_10
    capture drop sig_05
    capture drop sig_01
    destring p_value, replace force
    gen sig_10 = (p_value < 0.10) if !missing(p_value)
    gen sig_05 = (p_value < 0.05) if !missing(p_value)
    gen sig_01 = (p_value < 0.01) if !missing(p_value)

    di _n "=== RESULTS SIGNIFICANT AT p < 0.10 ==="
    list variant tier outcome treatment_var beta p_value n_obs ///
        if sig_10 == 1, noobs clean

    di _n "=== RESULTS SIGNIFICANT AT p < 0.05 ==="
    list variant tier outcome treatment_var beta p_value n_obs ///
        if sig_05 == 1, noobs clean

    di _n "=== RESULTS SIGNIFICANT AT p < 0.01 ==="
    list variant tier outcome treatment_var beta p_value n_obs ///
        if sig_01 == 1, noobs clean

    di _n "=== BENCHMARK COMPARISON TARGETS (from original pipeline) ==="
    di "MI T1 baseline pct_told_to_report:         b=0.060  p=0.253  N=570"
    di "MI T1 baseline pct_questioned_in_voir_dire: b=0.038  p=0.491  N=539"
    di "MI T1 baseline utilization_rate:            b=0.017  p=0.550  N=539"
    di "MI T1 baseline total_jury_verdicts:         b=-1.728 p=0.343  N=579"
    di "MI T1 baseline capital_felony:              b=-1.524 p=0.167  N=579"
    di "MI T1 baseline other_felony:                b=-0.440 p=0.525  N=579"
    di "MI T1 baseline other_cases:                 b=-0.579 p=0.465  N=579"
    di ""
    di "MI Robustness contested_long pct_told_to_report:  b=0.065  p=0.283  N=570"
    di "MI Robustness contested_long total_jury_verdicts:  b=-5.740 p=0.080  N=579"
    di "MI Robustness contested_long capital_felony:       b=-4.965 p=0.065  N=579"
    di ""
    di "NOTE: Original used harmonized panel (location_id FE)."
    di "      This pipeline uses clean-room panel (county_id FE)."
    di "      Tier 1 (pressure) should replicate exactly."
    di "      Tier 2 (contested_long) should replicate exactly."
    di "      Tier 3 (contested — broad) will differ slightly because"
    di "        treatment definition now includes primary-only challenges."
restore


di _n "========================================"
di "  07_regressions.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "  Results: $REG_CSV"
di "========================================"
