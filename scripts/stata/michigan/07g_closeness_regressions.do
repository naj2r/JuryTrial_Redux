/*==============================================================================
  07g_closeness_regressions.do

  Purpose:  Test whether the INTENSITY of electoral competition modulates
            treatment effects beyond the binary contested/uncontested distinction.
            Interacts treatment indicators with closeness measures.

  Outputs:  $OUTPUT/results/mi_closeness_results.csv

  Closeness definition:
    closeness = 1 - |incumbent_pct - 50| / 50
    Range: 0 (blowout) to 1 (tied at 50%)
    Non-contested/non-election/open seat: closeness = 0

  Source: Audit 3-19-26/check_margin_regressions_v2.do (verified logic)
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
di as text "  07g_closeness_regressions.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* SETUP: Output CSV
* =============================================================================

capture mkdir "$OUTPUT/results"

global CLOSE_CSV "$OUTPUT/results/mi_closeness_results.csv"

tempname fh
file open `fh' using "$CLOSE_CSV", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_clusters,closeness_type,interaction_type" _n
file close `fh'

di "Closeness CSV initialized: $CLOSE_CSV"


* =============================================================================
* PROGRAM: run_closeness_reg — one regression, append to CSV
* =============================================================================

capture program drop run_closeness_reg
program define run_closeness_reg
    syntax , variant(string) tier(string) spec(string) ///
        outcome(string) treatvars(string) ///
        fe_unit(string) cluster(string) ///
        closeness_type(string) interaction_type(string)

    capture confirm variable `outcome'
    if _rc {
        di "  SKIP `outcome': not found"
        exit
    }
    qui count if !missing(`outcome')
    if r(N) < 20 {
        di "  SKIP `outcome': <20 nonmissing"
        exit
    }

    capture noisily reghdfe `outcome' `treatvars', ///
        absorb(`fe_unit' year) vce(cluster `cluster')

    if _rc {
        di "  FAILED `outcome'"
        exit
    }

    local nobs = e(N)
    local nclu = e(N_clust)

    foreach tv of local treatvars {
        local b = _b[`tv']
        local s = _se[`tv']
        local p = 2*ttail(e(df_r), abs(`b'/`s'))
        local lo = `b' - invttail(e(df_r), 0.025) * `s'
        local hi = `b' + invttail(e(df_r), 0.025) * `s'

        tempname fhc
        file open `fhc' using "$CLOSE_CSV", write append
        file write `fhc' ///
            `"`variant'"' "," `"`tier'"' "," `"`spec'"' "," ///
            `"`outcome'"' "," `"`tv'"' "," ///
            (`b') "," (`s') "," (`p') "," (`lo') "," (`hi') "," ///
            (`nobs') "," (`nclu') "," ///
            `"`closeness_type'"' "," `"`interaction_type'"' _n
        file close `fhc'
    }
end


* =============================================================================
* MAIN: Panel B closeness regressions
* =============================================================================

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = ///
    (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n "--- Closeness variable coverage ---"
tabstat general_closeness primary_closeness max_closeness ///
    if treat_pros_pressure == 1, ///
    stat(n mean sd min p50 max) columns(statistics) format(%9.3f)

* --- Generate interaction terms ---

* T1: pressure × closeness
gen t1_x_gen_close = treat_pros_pressure * general_closeness
gen t1_x_max_close = treat_pros_pressure * max_closeness

* T2: contested_long × closeness
gen t2_x_gen_close = treat_pros_contested_long * general_closeness
gen t2_x_max_close = treat_pros_contested_long * max_closeness

* T3: contested × closeness
gen t3_x_gen_close = treat_pros_contested * general_closeness
gen t3_x_max_close = treat_pros_contested * max_closeness

* --- Demeaned versions (centered interaction) ---
qui sum general_closeness if treat_pros_contested_long == 1 & general_closeness > 0
local gen_close_mean = r(mean)
gen gen_close_dm = general_closeness - `gen_close_mean'
gen t2_x_gen_close_dm = treat_pros_contested_long * gen_close_dm

qui sum max_closeness if treat_pros_pressure == 1 & max_closeness > 0
local max_close_mean = r(mean)
gen max_close_dm = max_closeness - `max_close_mean'
gen t1_x_max_close_dm = treat_pros_pressure * max_close_dm

di _n "Mean general closeness (contested): " %6.3f `gen_close_mean'
di "Mean max closeness (pressure): " %6.3f `max_close_mean'

* --- Key outcomes ---
local key_outcomes "actually_reported told_to_report pct_told_to_report utilization_rate total_jury_verdicts capital_felony pct_other_felony pct_capital_felony pct_other_cases"

* =============================================================================
* T1 regressions: pressure × closeness
* =============================================================================

di _n "{hline 72}"
di "T1: PRESSURE × CLOSENESS INTERACTIONS"
di "{hline 72}"

foreach y of local key_outcomes {
    * T1 + max closeness interaction (raw)
    run_closeness_reg, variant("B") tier("T1_baseline") ///
        spec("pressure_x_maxclose") ///
        outcome("`y'") treatvars("treat_pros_pressure t1_x_max_close") ///
        fe_unit("county_id") cluster("county_id") ///
        closeness_type("max") interaction_type("raw")

    * T1 + max closeness interaction (demeaned)
    run_closeness_reg, variant("B") tier("T1_baseline") ///
        spec("pressure_x_maxclose_dm") ///
        outcome("`y'") treatvars("treat_pros_pressure t1_x_max_close_dm") ///
        fe_unit("county_id") cluster("county_id") ///
        closeness_type("max_demeaned") interaction_type("centered")

    * T1 + general closeness interaction
    run_closeness_reg, variant("B") tier("T1_baseline") ///
        spec("pressure_x_genclose") ///
        outcome("`y'") treatvars("treat_pros_pressure t1_x_gen_close") ///
        fe_unit("county_id") cluster("county_id") ///
        closeness_type("general") interaction_type("raw")
}


* =============================================================================
* T2 regressions: contested_long × closeness
* =============================================================================

di _n "{hline 72}"
di "T2: CONTESTED_LONG × CLOSENESS INTERACTIONS"
di "{hline 72}"

preserve
    drop if treat_pros_primary_only == 1
    drop if open_pros == 1
    di "  T2 sample: " _N

    foreach y of local key_outcomes {
        * T2 + general closeness interaction (raw)
        run_closeness_reg, variant("B") tier("T2_mechanism") ///
            spec("contested_x_genclose") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested t2_x_gen_close") ///
            fe_unit("county_id") cluster("county_id") ///
            closeness_type("general") interaction_type("raw")

        * T2 + general closeness interaction (demeaned)
        run_closeness_reg, variant("B") tier("T2_mechanism") ///
            spec("contested_x_genclose_dm") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested t2_x_gen_close_dm") ///
            fe_unit("county_id") cluster("county_id") ///
            closeness_type("general_demeaned") interaction_type("centered")
    }
restore


* =============================================================================
* T3 regressions: contested × max closeness
* =============================================================================

di _n "{hline 72}"
di "T3: CONTESTED × MAX CLOSENESS INTERACTIONS"
di "{hline 72}"

preserve
    drop if open_pros == 1
    di "  T3 sample: " _N

    foreach y of local key_outcomes {
        run_closeness_reg, variant("B") tier("T3_robustness") ///
            spec("contested_x_maxclose") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested t3_x_max_close") ///
            fe_unit("county_id") cluster("county_id") ///
            closeness_type("max") interaction_type("raw")
    }
restore


di _n "========================================"
di "  07g COMPLETE"
di "  Output: $CLOSE_CSV"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
