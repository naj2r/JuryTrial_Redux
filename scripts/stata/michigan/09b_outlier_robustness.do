/*==============================================================================
  09b_outlier_robustness.do

  Purpose:  Non-destructive robustness check for pct_told_to_report outliers.
            Creates modified Panel B datasets with three treatments:
              (1) Drop observations with pct_told_to_report > 1
              (2) Top-code pct_told_to_report at 1.0
              (3) Winsorize pct_told_to_report at 99th percentile
            Runs the full regression battery on each, saving results to
            SEPARATE CSV files. The baseline mi_regression_results.csv is
            never touched.

  Input:    $DATA_FINAL/michigan_panel_B.dta  (unmodified)
  Output:   $DATA_FINAL/michigan_panel_B_drop_ptr_gt1.dta
            $DATA_FINAL/michigan_panel_B_topcode_ptr.dta
            $DATA_FINAL/michigan_panel_B_winsor_ptr.dta
            $OUTPUT/results/mi_reg_robustness_drop_ptr_gt1.csv
            $OUTPUT/results/mi_reg_robustness_topcode_ptr.csv
            $OUTPUT/results/mi_reg_robustness_winsor_ptr.csv

  Non-destructive: baseline files are read-only.
==============================================================================*/
/* FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies). From SCAO case type codes. */

set update_query off
set more off

capture log close _all

local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"
do "`rb'/code/master/globals.do"

log using "$DIAGNOSTICS/09b_outlier_robustness.log", replace text

di _n as result "================================================================"
di as result "  OUTLIER ROBUSTNESS: pct_told_to_report > 1"
di as result "================================================================"


* =============================================================================
* STEP 1: Create modified datasets (saved alongside originals)
* =============================================================================

di _n as text "--- Creating modified Panel B datasets ---"

* --- Variant 1: DROP observations with pct_told_to_report > 1 ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
di "  Baseline N = " _N
qui count if pct_told_to_report > 1 & !missing(pct_told_to_report)
di "  Observations with pct_told_to_report > 1: " r(N)
drop if pct_told_to_report > 1 & !missing(pct_told_to_report)
di "  After drop: N = " _N
label data "MI panel variant B -- pct_told_to_report > 1 DROPPED"
save "$DATA_FINAL/michigan_panel_B_drop_ptr_gt1.dta", replace

* --- Variant 2: TOP-CODE pct_told_to_report at 1.0 ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
qui count if pct_told_to_report > 1 & !missing(pct_told_to_report)
di "  Top-coding " r(N) " observations at 1.0"
replace pct_told_to_report = 1.0 if pct_told_to_report > 1 & !missing(pct_told_to_report)
label data "MI panel variant B -- pct_told_to_report TOP-CODED at 1.0"
save "$DATA_FINAL/michigan_panel_B_topcode_ptr.dta", replace

* --- Variant 3: WINSORIZE pct_told_to_report at p99 ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
qui sum pct_told_to_report, detail
local p99 = r(p99)
di "  p99 of pct_told_to_report = " %6.4f `p99'
qui count if pct_told_to_report > `p99' & !missing(pct_told_to_report)
di "  Winsorizing " r(N) " observations at p99 = " %6.4f `p99'
replace pct_told_to_report = `p99' if pct_told_to_report > `p99' & !missing(pct_told_to_report)
label data "MI panel variant B -- pct_told_to_report WINSORIZED at p99"
save "$DATA_FINAL/michigan_panel_B_winsor_ptr.dta", replace


* =============================================================================
* STEP 2: Define the same run_reg program from 07_regressions.do
*         (copied verbatim to avoid dependency on program memory)
* =============================================================================

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
* STEP 3: Run regressions on each modified dataset
*         Only Panel B (primary specification), Tiers 1-3
* =============================================================================

* Outcome lists (same as 07_regressions.do)
local rate_outcomes   "pct_told_to_report pct_questioned_in_voir_dire utilization_rate pct_capital_felony pct_other_felony pct_other_cases"
local count_outcomes  "total_jury_verdicts capital_felony other_felony other_cases"
local summon_outcomes "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"
local all_outcomes "`rate_outcomes' `count_outcomes' `summon_outcomes'"

* --- Loop over the three robustness variants ---
foreach robvar in drop_ptr_gt1 topcode_ptr winsor_ptr {

    di _n as result "================================================================"
    di as result "  ROBUSTNESS VARIANT: `robvar'"
    di as result "================================================================"

    * Set output CSV for this variant
    global REG_CSV "$OUTPUT/results/mi_reg_robustness_`robvar'.csv"

    * Initialize CSV header
    tempname fh
    file open `fh' using "$REG_CSV", write replace
    file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_treated,n_clusters,share_treated,fe_unit,fe_year,cluster" _n
    file close `fh'

    * Load modified dataset
    use "$DATA_FINAL/michigan_panel_B_`robvar'.dta", clear
    capture gen log_county_pop = ln(county_pop)
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    di "Obs: " _N

    * --- Tier 1: Baseline (pressure) ---
    di _n "=== TIER 1: BASELINE (pressure) ==="
    foreach y of local all_outcomes {
        run_reg, variant("B_`robvar'") tier("T1_baseline") spec("pressure") ///
            outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
            fe_unit("county_id") cluster("county_id")
    }

    * --- Tier 2: Mechanism (contested_long + uncontested) ---
    di _n "=== TIER 2: MECHANISM (contested_long + uncontested) ==="
    preserve
        qui drop if treat_pros_primary_only == 1
        qui drop if open_pros == 1
        di "  T2 sample (primary-only excluded): " _N
        foreach y of local all_outcomes {
            run_reg, variant("B_`robvar'") tier("T2_mechanism") spec("contested_long") ///
                outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
                fe_unit("county_id") cluster("county_id")
        }
    restore

    * --- Tier 3: Robustness (contested + uncontested) ---
    di _n "=== TIER 3: ROBUSTNESS (contested + uncontested) ==="
    foreach y of local all_outcomes {
        run_reg, variant("B_`robvar'") tier("T3_robustness") spec("contested") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }

    di _n as text "  Results saved to: $REG_CSV"
}


* =============================================================================
* STEP 4: Quick comparison — headline results only
* =============================================================================

di _n as result "================================================================"
di as result "  HEADLINE COMPARISON: Baseline vs Robustness Variants"
di as result "================================================================"

* Reload baseline for comparison
use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n as text "--- BASELINE: T1 pressure on headline outcomes ---"
foreach y in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `y' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    di "  `y': b=" %9.3f _b[treat_pros_pressure] ///
       " se=" %9.3f _se[treat_pros_pressure] ///
       " p=" %6.4f 2*ttail(e(df_r), abs(_b[treat_pros_pressure]/_se[treat_pros_pressure])) ///
       " N=" e(N)
}

foreach robvar in drop_ptr_gt1 topcode_ptr winsor_ptr {
    use "$DATA_FINAL/michigan_panel_B_`robvar'.dta", clear
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

    di _n as text "--- `robvar': T1 pressure on headline outcomes ---"
    foreach y in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
        qui reghdfe `y' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
        di "  `y': b=" %9.3f _b[treat_pros_pressure] ///
           " se=" %9.3f _se[treat_pros_pressure] ///
           " p=" %6.4f 2*ttail(e(df_r), abs(_b[treat_pros_pressure]/_se[treat_pros_pressure])) ///
           " N=" e(N)
    }
}


di _n as result "================================================================"
di as result "  ROBUSTNESS REGRESSIONS COMPLETE"
di as result "================================================================"

log close
