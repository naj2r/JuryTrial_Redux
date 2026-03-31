/*==============================================================================
  07e_plea_composition.do

  Purpose:  Plea vs. trial composition regressions — McCannon (2013/2014)-style
            mechanism analysis. Tests whether electoral pressure shifts the
            margin between negotiated (plea) and adjudicated (trial) resolution.

  Specifications:
    A. Felony-only (circuit courts, FC + FH)   — PRIMARY
    B. Misdemeanor (district courts, SD + SM)   — SECONDARY
    C. Combined (felony + misdemeanor summed)   — EXPLORATORY

  Outcomes:
    Primary:   plea_share, jury_only
    Secondary: trial_total, plea_total, jury_share
    Leads:     plea_share_lead1, jury_only_lead1 (optional timing)

  Input:    $DATA_FINAL/michigan_panel_B.dta         (elections + jury panel)
            $DATA_INT/mi_plea_composition_felony.dta
            $DATA_INT/mi_plea_composition_misdemeanor.dta

  Output:   $OUTPUT/results/mi_plea_composition_results.csv

  Design notes:
    - Standalone file (not in master_build_all.do)
    - County-clustered SEs, county + year FE
    - NO lagged DV as regressor (avoids Nickell bias)
    - COVID 2020-2021 excluded via panel merge
    - Framing: "suggestive mechanism" not "causal identification"

  Requires: 01-06 pipeline + 03c must have run.
==============================================================================*/
/* FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies). From SCAO case type codes. */

* --- Bootstrap ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

di as text _newline "========================================"
di as text "  07e_plea_composition.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* SETUP: Output CSV + run_reg program
* =============================================================================

capture mkdir "$OUTPUT/results"

global REG_CSV "$OUTPUT/results/mi_plea_composition_results.csv"

tempname fh
file open `fh' using "$REG_CSV", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_treated,n_clusters,share_treated,fe_unit,fe_year,cluster" _n
file close `fh'

global EQ_CSV "$OUTPUT/results/mi_plea_equality_tests.csv"
tempname fh2
file open `fh2' using "$EQ_CSV", write replace
file write `fh2' "variant,tier,spec_name,outcome,tvar1,tvar2,beta1,beta2,diff,F_stat,p_equality,n_obs,n_clusters" _n
file close `fh2'


* --- Copy run_reg from 07_regressions.do ---
capture program drop run_reg
program define run_reg
    syntax , variant(string) tier(string) spec(string) ///
        outcome(string) treatvars(string) ///
        fe_unit(string) cluster(string) [controls(string)]

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

    capture noisily reghdfe `outcome' `treatvars' `controls', ///
        absorb(`fe_unit' year) vce(cluster `cluster')

    if _rc {
        di "  FAILED `variant'|`tier'|`outcome'"
        exit
    }

    local nobs = e(N)
    local nclu = e(N_clust)

    * Equality test for 2-treatment specs
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
        }
    }

    foreach tvar of local treatvars {
        local b    = _b[`tvar']
        local se   = _se[`tvar']
        local t    = `b' / `se'
        local p    = 2 * ttail(e(df_r), abs(`t'))
        local ci_lo = `b' - invttail(e(df_r), 0.025) * `se'
        local ci_hi = `b' + invttail(e(df_r), 0.025) * `se'

        qui count if `tvar' == 1 & e(sample)
        local n_treat = r(N)
        local share = `n_treat' / `nobs'

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
* SPEC A: FELONY-ONLY (Circuit Courts)
* =============================================================================

di _n "{hline 72}"
di "SPEC A: FELONY PLEA COMPOSITION (Circuit Courts)"
di "{hline 72}"

* Load elections panel and merge felony composition
use "$DATA_FINAL/michigan_panel_B.dta", clear

merge m:1 county year using "$DATA_INT/mi_plea_composition_felony.dta", ///
    keepusing(plea_share jury_only trial_total plea_total resolved_total ///
              jury_share ///
              plea_share_lead1 jury_only_lead1 bench_verdict) ///
    keep(master match)

tab _merge
qui count if _merge == 3
di "Felony merge: " r(N) " matched of " _N
drop _merge

* Generate controls
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* Summary
di _n "--- Felony plea composition summary (merged panel) ---"
tabstat plea_share jury_only trial_total plea_total resolved_total, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

* --- Outcome lists ---
local primary_outcomes   "plea_share jury_only"
local secondary_outcomes "trial_total plea_total jury_share"
local lead_outcomes      "plea_share_lead1 jury_only_lead1"
local all_outcomes       "`primary_outcomes' `secondary_outcomes'"

* --- T1: Baseline (pressure) ---
di _n "=== FELONY T1: BASELINE ==="
foreach y of local all_outcomes {
    run_reg, variant("FELONY") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}

* Leads
foreach y of local lead_outcomes {
    run_reg, variant("FELONY") tier("T1_baseline") spec("pressure_lead") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}

* --- T2: Mechanism (contested_long + uncontested) ---
di _n "=== FELONY T2: MECHANISM ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y of local all_outcomes {
        run_reg, variant("FELONY") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore

* --- T3: Robustness (contested + uncontested) ---
di _n "=== FELONY T3: ROBUSTNESS ==="
foreach y of local all_outcomes {
    run_reg, variant("FELONY") tier("T3_robustness") spec("contested") ///
        outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}


* =============================================================================
* SPEC B: MISDEMEANOR (District Courts)
* =============================================================================

di _n "{hline 72}"
di "SPEC B: MISDEMEANOR PLEA COMPOSITION (District Courts)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear

merge m:1 county year using "$DATA_INT/mi_plea_composition_misdemeanor.dta", ///
    keepusing(plea_share jury_only trial_total plea_total resolved_total ///
              jury_share ///
              plea_share_lead1 jury_only_lead1 bench_verdict) ///
    keep(master match)

tab _merge
qui count if _merge == 3
di "Misdemeanor merge: " r(N) " matched of " _N
drop _merge

capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n "--- Misdemeanor plea composition summary ---"
tabstat plea_share jury_only trial_total plea_total, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

* --- T1 ---
di _n "=== MISDEMEANOR T1: BASELINE ==="
foreach y of local all_outcomes {
    run_reg, variant("MISDEM") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}

* --- T2 ---
di _n "=== MISDEMEANOR T2: MECHANISM ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y of local all_outcomes {
        run_reg, variant("MISDEM") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore

* --- T3 ---
di _n "=== MISDEMEANOR T3: ROBUSTNESS ==="
foreach y of local all_outcomes {
    run_reg, variant("MISDEM") tier("T3_robustness") spec("contested") ///
        outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}


* =============================================================================
* SPEC C: COMBINED (Felony + Misdemeanor summed)
* =============================================================================

di _n "{hline 72}"
di "SPEC C: COMBINED PLEA COMPOSITION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Merge both and combine
merge m:1 county year using "$DATA_INT/mi_plea_composition_felony.dta", ///
    keepusing(plea_total trial_total jury_only bench_verdict) ///
    keep(master match) nogen

* Rename felony vars before merging misdemeanor
rename plea_total   f_plea_total
rename trial_total  f_trial_total
rename jury_only    f_jury_only
rename bench_verdict f_bench_verdict

merge m:1 county year using "$DATA_INT/mi_plea_composition_misdemeanor.dta", ///
    keepusing(plea_total trial_total jury_only bench_verdict) ///
    keep(master match) nogen

rename plea_total   m_plea_total
rename trial_total  m_trial_total
rename jury_only    m_jury_only
rename bench_verdict m_bench_verdict

* Combine
gen plea_total = f_plea_total + m_plea_total
gen trial_total = f_trial_total + m_trial_total
gen jury_only = f_jury_only + m_jury_only
gen resolved_total = plea_total + trial_total
gen plea_share = plea_total / resolved_total if resolved_total > 0
gen jury_share = jury_only / resolved_total if resolved_total > 0
* log_jury_only and log_plea_total REMOVED — too many zeros for log transform

capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n "--- Combined plea composition summary ---"
tabstat plea_share jury_only trial_total plea_total, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

* --- T1 ---
di _n "=== COMBINED T1: BASELINE ==="
foreach y of local all_outcomes {
    run_reg, variant("COMBINED") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}

* --- T2 ---
di _n "=== COMBINED T2: MECHANISM ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y of local all_outcomes {
        run_reg, variant("COMBINED") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore

* --- T3 ---
di _n "=== COMBINED T3: ROBUSTNESS ==="
foreach y of local all_outcomes {
    run_reg, variant("COMBINED") tier("T3_robustness") spec("contested") ///
        outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}


* =============================================================================
* SPEC D: DISTRICT FELONY (FY + FD — Preliminary Exam Level)
* =============================================================================

di _n "{hline 72}"
di "SPEC D: DISTRICT FELONY PLEA COMPOSITION (FY + FD)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using "$DATA_INT/mi_plea_composition_distfelony.dta", ///
    keepusing(plea_share jury_only trial_total plea_total resolved_total ///
              jury_share ///
              plea_share_lead1 jury_only_lead1) ///
    keep(master match)

tab _merge
qui count if _merge == 3
di "District felony merge: " r(N) " matched of " _N
drop _merge

capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n "--- District felony summary ---"
tabstat plea_share jury_only trial_total plea_total, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

* T1-T3 (same pattern)
di _n "=== DISTFEL T1: BASELINE ==="
foreach y of local all_outcomes {
    run_reg, variant("DISTFEL") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("county_id") cluster("county_id")
}

di _n "=== DISTFEL T2: MECHANISM ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y of local all_outcomes {
        run_reg, variant("DISTFEL") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
restore

di _n "=== DISTFEL T3: ROBUSTNESS ==="
foreach y of local all_outcomes {
    run_reg, variant("DISTFEL") tier("T3_robustness") spec("contested") ///
        outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
        fe_unit("county_id") cluster("county_id")
}


* =============================================================================
* COURT-LEVEL SPECIFICATIONS (court_id FE + county_id clustering)
* =============================================================================
* These use the disaggregated court-level data. More observations but
* cross-level inference (court FE for precision, county clustering for inference).

* --- COURT: Misdemeanor (most variation — multiple district courts per county) ---
di _n "{hline 72}"
di "COURT-LEVEL: MISDEMEANOR (district courts)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)
keep county county_id year treat_* log_county_pop
duplicates drop county year, force

* Merge court-level plea data (many courts per county)
merge 1:m county year using "$DATA_INT/mi_plea_composition_misdemeanor_court.dta", ///
    keepusing(court_code court_id plea_share jury_only trial_total plea_total ///
              resolved_total jury_share) ///
    keep(match) nogen

capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di "Court-level misdemeanor: " _N " court-year obs"

* T1 only (keep it manageable)
di _n "=== COURT MISDEM T1 ==="
foreach y in plea_share jury_only trial_total plea_total jury_share {
    run_reg, variant("COURT_MISDEM") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("court_id") cluster("county_id")
}

di _n "=== COURT MISDEM T2 ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y in plea_share jury_only trial_total plea_total jury_share {
        run_reg, variant("COURT_MISDEM") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("court_id") cluster("county_id")
    }
restore


* --- COURT: District Felony (FY + FD) ---
di _n "{hline 72}"
di "COURT-LEVEL: DISTRICT FELONY (FY + FD)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)
keep county county_id year treat_* log_county_pop
duplicates drop county year, force

merge 1:m county year using "$DATA_INT/mi_plea_composition_distfelony_court.dta", ///
    keepusing(court_code court_id plea_share jury_only trial_total plea_total ///
              resolved_total jury_share) ///
    keep(match) nogen

capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di "Court-level district felony: " _N " court-year obs"

di _n "=== COURT DISTFEL T1 ==="
foreach y in plea_share jury_only trial_total plea_total jury_share {
    run_reg, variant("COURT_DISTFEL") tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
        fe_unit("court_id") cluster("county_id")
}

di _n "=== COURT DISTFEL T2 ==="
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    foreach y in plea_share jury_only trial_total plea_total jury_share {
        run_reg, variant("COURT_DISTFEL") tier("T2_mechanism") spec("contested_long") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
            fe_unit("court_id") cluster("county_id")
    }
restore


* =============================================================================
* SUMMARY
* =============================================================================

di _n "{hline 72}"
di "SUMMARY: Key findings"
di "{hline 72}"

* Reload felony for headline comparison
use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using "$DATA_INT/mi_plea_composition_felony.dta", ///
    keepusing(plea_share jury_only) keep(master match) nogen

di _n "--- Felony headline: plea_share ~ pressure ---"
reghdfe plea_share treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

di _n "--- Felony headline: jury_only ~ pressure ---"
reghdfe jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

di _n "--- Felony headline: jury_only ~ contested ---"
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
preserve
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    reghdfe jury_only treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
restore


di _n "========================================"
di "  07e_plea_composition.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
