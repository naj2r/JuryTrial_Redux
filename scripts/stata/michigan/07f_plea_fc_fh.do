/*==============================================================================
  07f_plea_fc_fh.do

  Purpose:  Capital vs. Non-capital felony plea composition — the disaggregated
            finding that FC plea share declines under electoral pressure while
            FH is invariant.

  Specifications:
    1. FC (Capital Felony) only — PRIMARY FINDING
    2. FH (Non-capital Felony) only — COMPARISON NULL
    3. Each × T1/T2/T3 treatment tiers
    4. Each × above/below median population split

  Outcomes:  plea_share, jury_only, plea_total, trial_total, jury_share

  Input:    $DATA_RAW/scao_caseload/outgoing_felony_by_year.csv
            $DATA_FINAL/michigan_panel_B.dta

  Output:   $OUTPUT/results/mi_plea_fc_fh_results.csv

  Design:   Standalone — builds FC/FH data internally, merges with elections,
            runs all regressions. No dependency on 03c.
==============================================================================*/

* --- Bootstrap ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

di as text _newline "========================================"
di as text "  07f_plea_fc_fh.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* SETUP: CSV + run_reg
* =============================================================================

capture mkdir "$OUTPUT/results"

global REG_CSV "$OUTPUT/results/mi_plea_fc_fh_results.csv"

tempname fh
file open `fh' using "$REG_CSV", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se,p_value,ci_lo,ci_hi,n_obs,n_treated,n_clusters,share_treated,fe_unit,fe_year,cluster" _n
file close `fh'

global EQ_CSV "$OUTPUT/results/mi_plea_fc_fh_equality.csv"
tempname fh2
file open `fh2' using "$EQ_CSV", write replace
file write `fh2' "variant,tier,spec_name,outcome,tvar1,tvar2,beta1,beta2,diff,F_stat,p_equality,n_obs,n_clusters" _n
file close `fh2'


* --- Copy run_reg ---
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
* BUILD FC AND FH SEPARATELY FROM RAW DATA
* =============================================================================

di _n "{hline 72}"
di "BUILDING FC AND FH PLEA DATA FROM RAW"
di "{hline 72}"

import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", ///
    clear varnames(1) encoding("UTF-8")

* Keep plea/trial dispositions only
gen byte is_disp = inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
keep if is_disp == 1
drop is_disp

* Reshape to wide
gen action_var = ""
replace action_var = "jury" if action_name == "Jury Verdict"
replace action_var = "bench" if action_name == "Bench Verdict"
replace action_var = "plea" if action_name == "Guilty Plea"

duplicates tag county court_code case_type year action_var, gen(_dup)
qui count if _dup > 0
if r(N) > 0 {
    collapse (sum) quantity, by(county court_code case_type year action_var)
}
else {
    drop _dup
}
drop action_name

reshape wide quantity, i(county court_code case_type year) j(action_var) string

rename quantityjury jury_only
rename quantitybench bench_verdict
rename quantityplea plea_total

foreach v in jury_only bench_verdict plea_total {
    replace `v' = 0 if missing(`v')
}

gen trial_total = jury_only + bench_verdict
gen resolved = plea_total + trial_total
gen plea_share = plea_total / resolved if resolved > 0
gen jury_share = jury_only / resolved if resolved > 0

* Flag case types
gen byte is_fc = regexm(case_type, "^FC ")

* Collapse to county × casetype × year (drop court_code)
collapse (sum) jury_only bench_verdict plea_total trial_total resolved, by(county is_fc year)
gen plea_share = plea_total / resolved if resolved > 0
gen jury_share = jury_only / resolved if resolved > 0

* Save FC
preserve
    keep if is_fc == 1
    drop is_fc
    tempfile fc_data
    save `fc_data'
    di "FC data: " _N " obs"
restore

* Save FH
preserve
    keep if is_fc == 0
    drop is_fc
    tempfile fh_data
    save `fh_data'
    di "FH data: " _N " obs"
restore


* =============================================================================
* PROGRAM: run_all_tiers — run T1-T3 for a given variant
* =============================================================================

capture program drop run_all_tiers
program define run_all_tiers
    syntax , variant(string)

    local outcomes "plea_share jury_only plea_total trial_total jury_share"

    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

    * T1
    di _n "=== `variant' T1: BASELINE ==="
    foreach y of local outcomes {
        run_reg, variant("`variant'") tier("T1_baseline") spec("pressure") ///
            outcome("`y'") treatvars("treat_pros_pressure open_pros") ///
            fe_unit("county_id") cluster("county_id")
    }

    * T2
    di _n "=== `variant' T2: MECHANISM ==="
    preserve
        qui drop if treat_pros_primary_only == 1
        qui drop if open_pros == 1
        foreach y of local outcomes {
            run_reg, variant("`variant'") tier("T2_mechanism") spec("contested_long") ///
                outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested") ///
                fe_unit("county_id") cluster("county_id")
        }
    restore

    * T3
    di _n "=== `variant' T3: ROBUSTNESS ==="
    foreach y of local outcomes {
        run_reg, variant("`variant'") tier("T3_robustness") spec("contested") ///
            outcome("`y'") treatvars("treat_pros_contested treat_pros_uncontested") ///
            fe_unit("county_id") cluster("county_id")
    }
end


* =============================================================================
* FC (CAPITAL FELONY) — Full sample
* =============================================================================

di _n "{hline 72}"
di "FC (CAPITAL FELONY) — FULL SAMPLE"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fc_data', keep(match) nogen

di _n "--- FC summary ---"
tabstat plea_share jury_only plea_total trial_total, ///
    stat(n mean sd min p50 max) format(%12.3f)

run_all_tiers, variant("FC")


* =============================================================================
* FH (NON-CAPITAL FELONY) — Full sample
* =============================================================================

di _n "{hline 72}"
di "FH (NON-CAPITAL FELONY) — FULL SAMPLE"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fh_data', keep(match) nogen

di _n "--- FH summary ---"
tabstat plea_share jury_only plea_total trial_total, ///
    stat(n mean sd min p50 max) format(%12.3f)

run_all_tiers, variant("FH")


* =============================================================================
* FC — ABOVE MEDIAN POPULATION
* =============================================================================

di _n "{hline 72}"
di "FC — ABOVE MEDIAN POPULATION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fc_data', keep(match) nogen

* Generate median split
qui sum county_pop, detail
local med_pop = r(p50)
di "Median population: `med_pop'"
keep if county_pop >= `med_pop'
di "Above-median N: " _N

run_all_tiers, variant("FC_LARGE")


* =============================================================================
* FC — BELOW MEDIAN POPULATION
* =============================================================================

di _n "{hline 72}"
di "FC — BELOW MEDIAN POPULATION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fc_data', keep(match) nogen

qui sum county_pop, detail
local med_pop = r(p50)
keep if county_pop < `med_pop'
di "Below-median N: " _N

run_all_tiers, variant("FC_SMALL")


* =============================================================================
* FH — ABOVE MEDIAN POPULATION
* =============================================================================

di _n "{hline 72}"
di "FH — ABOVE MEDIAN POPULATION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fh_data', keep(match) nogen

qui sum county_pop, detail
local med_pop = r(p50)
keep if county_pop >= `med_pop'
di "Above-median N: " _N

run_all_tiers, variant("FH_LARGE")


* =============================================================================
* FH — BELOW MEDIAN POPULATION
* =============================================================================

di _n "{hline 72}"
di "FH — BELOW MEDIAN POPULATION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fh_data', keep(match) nogen

qui sum county_pop, detail
local med_pop = r(p50)
keep if county_pop < `med_pop'
di "Below-median N: " _N

run_all_tiers, variant("FH_SMALL")


* =============================================================================
* SUMMARY
* =============================================================================

di _n "{hline 72}"
di "SUMMARY: FC vs FH COMPARISON"
di "{hline 72}"

* Reload for headline
use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fc_data', keep(match) nogen

di _n "=== FC: plea_share ~ pressure (headline) ==="
reghdfe plea_share treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
local fc_b = _b[treat_pros_pressure]
local fc_p = 2*ttail(e(df_r), abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

di _n "=== FC: jury_only ~ pressure ==="
reghdfe jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using `fh_data', keep(match) nogen

di _n "=== FH: plea_share ~ pressure (comparison) ==="
reghdfe plea_share treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
local fh_b = _b[treat_pros_pressure]
local fh_p = 2*ttail(e(df_r), abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

di _n "==========================================="
di "FC plea_share: b = " %9.4f `fc_b' " p = " %6.4f `fc_p'
di "FH plea_share: b = " %9.4f `fh_b' " p = " %6.4f `fh_p'
di "==========================================="


di _n "========================================"
di "  07f_plea_fc_fh.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
