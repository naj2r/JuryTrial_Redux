/*==============================================================================
  07i_inference_diagnostics.do

  Wild cluster bootstrap (boottest) and TWFE weight diagnostics (twowayfeweights)

  Purpose: Address domain reviewer's major concerns:
    1. With ~15-20 treated clusters in T2/T3 and only 2 presidential election
       cycles, conventional cluster-robust SEs may be distorted
    2. TWFE with recurring treatment may produce negative weights under
       heterogeneous treatment effects across cycles

  Outputs:
    $OUTPUT/results/mi_boottest_results.csv     — wild bootstrap p-values
    $OUTPUT/results/mi_twowayfeweights.csv      — TWFE weight diagnostics

  FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital
  (other felonies). From SCAO case type codes.
==============================================================================*/

clear all
set more off

* Load paths
do "code/master/paths.do"
do "code/master/globals.do"

* Key outcomes for inference diagnostics (headline results only)
local key_outcomes "actually_reported told_to_report pct_told_to_report utilization_rate total_jury_verdicts capital_felony pct_other_felony pct_other_cases"

* Initialize output CSVs
tempname fh
file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write replace
file write `fh' "variant,tier,spec_name,outcome,treatment_var,beta,se_cluster,p_cluster,p_boot_wild,n_obs,n_clusters,n_treated,boot_reps" _n
file close `fh'

tempname fh2
file open `fh2' using "$OUTPUT/results/mi_twowayfeweights.csv", write replace
file write `fh2' "variant,tier,outcome,treatment_var,n_pos_weights,n_neg_weights,sum_pos_weights,sum_neg_weights,min_weight,max_weight,n_obs,sensibility_beta_lb,sensibility_beta_ub" _n
file close `fh2'

di _n "=============================================="
di "   INFERENCE DIAGNOSTICS"
di "=============================================="

* Load main panel
use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Panel B loaded: " _N " obs"


/*------------------------------------------------------------------------------
  PART 1: Wild Cluster Bootstrap (boottest)

  boottest uses the Webb 6-point distribution for wild weights.
  With 83 clusters total, conventional SEs are likely adequate for T0/T1,
  but T2/T3 have only ~15-20 treated clusters — bootstrap SEs matter there.

  We test the null H0: beta = 0 for each treatment variable.
  The bootstrap p-value is compared to the cluster-robust p-value.
  If they diverge substantially, conventional inference is unreliable.
------------------------------------------------------------------------------*/

di _n "=============================================="
di "   PART 1: Wild Cluster Bootstrap"
di "=============================================="

* NOTE: boottest does NOT work with reghdfe when >1 set of absorbed FEs.
* Workaround: use areg (absorb county_id) + manual year dummies.
* This is numerically equivalent to reghdfe with county + year FE.

* Create year dummies (xi would work but tab is cleaner)
qui tab year, gen(_yr_)
* Drop one for identification (first year = reference)
drop _yr_1


* === Helper program for boottest with areg ===
capture program drop run_boottest
program define run_boottest
    syntax , tier(string) spec(string) outcome(string) ///
        treatvars(string) [controls(string)]

    capture confirm variable `outcome'
    if _rc exit

    qui count if !missing(`outcome')
    if r(N) < 50 exit

    * Build year dummy list
    local yrdums ""
    foreach v of varlist _yr_* {
        local yrdums "`yrdums' `v'"
    }

    * Run areg (absorb county_id, manual year dummies, cluster county_id)
    qui areg `outcome' `treatvars' `yrdums' `controls', absorb(county_id) vce(cluster county_id)

    local nobs = e(N)
    local nclu = e(N_clust)

    foreach tvar of local treatvars {
        local b    = _b[`tvar']
        local se   = _se[`tvar']
        local t    = `b' / `se'
        local p_cl = 2 * ttail(e(df_r), abs(`t'))

        qui count if `tvar' == 1 & e(sample)
        local n_treat = r(N)

        * Wild cluster bootstrap
        capture noisily boottest `tvar', reps(999) seed(42) nograph
        if !_rc {
            local p_boot = r(p)
        }
        else {
            local p_boot = .
            di "  boottest FAILED for `outcome' `tier' `tvar'"
        }

        * Write result
        tempname fh
        file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
        file write `fh' "B,`tier',`spec',`outcome',`tvar'," ///
            (`b') "," (`se') "," (`p_cl') "," (`p_boot') "," ///
            (`nobs') "," (`nclu') "," (`n_treat') ",999" _n
        file close `fh'

        di "  `tier' | `outcome' | `tvar' | p_cl=" %6.4f `p_cl' " p_boot=" %6.4f `p_boot'
    }
end


* --- T1: Pressure + Open Seat ---
di _n "--- T1 Baseline ---"
foreach y of local key_outcomes {
    run_boottest, tier("T1_baseline") spec("pressure") ///
        outcome("`y'") treatvars("treat_pros_pressure open_pros")
}

* --- T2: Contested + Uncontested (open seats excluded) ---
di _n "--- T2 Mechanism ---"
preserve
    drop if open_pros == 1
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    drop if treat_pros_primary_only == 1

    foreach y of local key_outcomes {
        run_boottest, tier("T2_mechanism") spec("contested") ///
            outcome("`y'") treatvars("treat_pros_contested_long treat_pros_uncontested")
    }
restore

* --- T0: Election year binary (open-seat cycles excluded) ---
di _n "--- T0 Election Year ---"
preserve
    * Exclude open-seat cycles (lame-duck contamination)
    bysort county_id (year): gen _has_open = (open_pros == 1)
    bysort county_id: egen _ever_open = max(_has_open)

    gen _open_year = year if open_pros == 1
    bysort county_id: egen _max_open_yr = max(_open_year)

    gen _prev_elec = .
    forvalues y = 2016/2024 {
        replace _prev_elec = `y' if _max_open_yr > `y' & is_election_year_pros == 1 & year == `y' & _ever_open == 1
    }
    bysort county_id: egen _prev_elec_yr = max(_prev_elec)

    drop if _ever_open == 1 & year > _prev_elec_yr & year <= _max_open_yr & !missing(_prev_elec_yr)
    drop if _ever_open == 1 & missing(_prev_elec_yr) & year <= _max_open_yr

    drop _has_open _ever_open _open_year _max_open_yr _prev_elec _prev_elec_yr

    di "  T0 sample: " _N

    foreach y of local key_outcomes {
        run_boottest, tier("T0_electionyear") spec("electionyear") ///
            outcome("`y'") treatvars("is_election_year_pros")
    }
restore

* Clean up year dummies
capture drop _yr_*


/*------------------------------------------------------------------------------
  PART 2: TWFE Weight Diagnostics (twowayfeweights)

  de Chaisemartin & D'Haultfoeuille (2020) show TWFE can produce negative
  weights when treatment effects are heterogeneous. With recurring treatment
  across 2 cycles (2016, 2024), effects may differ by cycle.

  twowayfeweights decomposes the TWFE estimator into:
    - Positive weights (observations that contribute positively)
    - Negative weights (observations that contribute NEGATIVELY — bad)

  If negative weights exist, the TWFE estimate is not a convex combination
  of unit-level treatment effects, and could have the wrong sign even if
  every unit's true effect is positive.
------------------------------------------------------------------------------*/

di _n "=============================================="
di "   PART 2: TWFE Weight Diagnostics"
di "=============================================="

* Reload clean panel
use "$DATA_FINAL/michigan_panel_B.dta", clear

* twowayfeweights stores results in e(M) matrix (3x2):
*   Row 1: Positive weights — [# ATTs, Σ weights]
*   Row 2: Negative weights — [# ATTs, Σ weights]
*   Row 3: Total — [# ATTs, Σ weights]
* Also stores e(beta) and e(lb_se_te) for sensitivity.

capture program drop run_twfe_weights
program define run_twfe_weights
    syntax , tier(string) outcome(string) tvar(string)

    capture confirm variable `outcome'
    if _rc exit

    qui count if !missing(`outcome')
    if r(N) < 50 exit

    di _n "--- twowayfeweights: `outcome' (`tier' `tvar') ---"

    capture noisily twowayfeweights `outcome' county_id year `tvar', type(feTR)
    if _rc {
        di "  twowayfeweights FAILED for `outcome'"
        exit
    }

    * Extract from e(M) matrix
    tempname M
    matrix `M' = e(M)
    local n_pos   = `M'[1,1]
    local sum_pos = `M'[1,2]
    local n_neg   = `M'[2,1]
    local sum_neg = `M'[2,2]
    local n_total = `M'[3,1]
    local beta_tw = e(beta)

    * Sensitivity bounds from e()
    capture local lb_se = e(lb_se_te)
    if _rc local lb_se = .
    capture local lb_se2 = e(lb_se_te2)
    if _rc local lb_se2 = .

    qui count if !missing(`outcome')
    local nobs = r(N)

    tempname fh2
    file open `fh2' using "$OUTPUT/results/mi_twowayfeweights.csv", write append
    file write `fh2' "B,`tier',`outcome',`tvar'," ///
        (`n_pos') "," (`n_neg') "," (`sum_pos') "," (`sum_neg') "," ///
        (`n_total') "," (`beta_tw') "," (`nobs') "," (`lb_se') "," (`lb_se2') _n
    file close `fh2'

    di "  Positive: " `n_pos' " (sum=" %7.4f `sum_pos' ")"
    di "  Negative: " `n_neg' " (sum=" %7.4f `sum_neg' ")"
    if `n_neg' > 0 {
        di "  WARNING: " `n_neg' " negative weight(s) detected (sum=" %7.4f `sum_neg' ")"
    }
    else {
        di "  OK: No negative weights"
    }
end

* Update CSV header to match new column structure
tempname fh2
file open `fh2' using "$OUTPUT/results/mi_twowayfeweights.csv", write replace
file write `fh2' "variant,tier,outcome,treatment_var,n_pos_weights,n_neg_weights,sum_pos_weights,sum_neg_weights,n_total_atts,beta_twfe,n_obs,lb_se_te,lb_se_te2" _n
file close `fh2'

* T1: pressure
foreach y of local key_outcomes {
    run_twfe_weights, tier("T1_baseline") outcome("`y'") tvar("treat_pros_pressure")
}

* T0: election year binary (full panel — before open-seat exclusion)
foreach y of local key_outcomes {
    run_twfe_weights, tier("T0_electionyear") outcome("`y'") tvar("is_election_year_pros")
}


di _n "=============================================="
di "   INFERENCE DIAGNOSTICS COMPLETE"
di "=============================================="
di "  Boottest results: $OUTPUT/results/mi_boottest_results.csv"
di "  TWFE weights:     $OUTPUT/results/mi_twowayfeweights.csv"
