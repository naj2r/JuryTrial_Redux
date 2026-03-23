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
use "$DATADIR/mi_panel_B.dta", clear
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

* --- T1: Pressure + Open Seat ---
di _n "--- T1 Baseline ---"
foreach y of local key_outcomes {
    capture confirm variable `y'
    if _rc continue

    qui count if !missing(`y')
    if r(N) < 50 continue

    * Run the regression
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)

    local nobs = e(N)
    local nclu = e(N_clust)

    * Conventional results for pressure
    local b    = _b[treat_pros_pressure]
    local se   = _se[treat_pros_pressure]
    local t    = `b' / `se'
    local p_cl = 2 * ttail(e(df_r), abs(`t'))

    qui count if treat_pros_pressure == 1 & e(sample)
    local n_treat = r(N)

    * Wild cluster bootstrap for pressure
    capture boottest treat_pros_pressure, reps(999) seed(42) nograph
    if !_rc {
        local p_boot = r(p)
    }
    else {
        local p_boot = .
        di "  boottest FAILED for `y' T1 pressure"
    }

    * Write result
    tempname fh
    file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
    file write `fh' "B,T1_baseline,pressure,`y',treat_pros_pressure," ///
        (`b') "," (`se') "," (`p_cl') "," (`p_boot') "," ///
        (`nobs') "," (`nclu') "," (`n_treat') ",999" _n
    file close `fh'

    di "  T1 | `y' | pressure | p_cluster=" %6.4f `p_cl' " p_boot=" %6.4f `p_boot'

    * Wild cluster bootstrap for open_pros
    local b_o    = _b[open_pros]
    local se_o   = _se[open_pros]
    local t_o    = `b_o' / `se_o'
    local p_cl_o = 2 * ttail(e(df_r), abs(`t_o'))

    qui count if open_pros == 1 & e(sample)
    local n_treat_o = r(N)

    capture boottest open_pros, reps(999) seed(42) nograph
    if !_rc {
        local p_boot_o = r(p)
    }
    else {
        local p_boot_o = .
    }

    tempname fh
    file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
    file write `fh' "B,T1_baseline,pressure,`y',open_pros," ///
        (`b_o') "," (`se_o') "," (`p_cl_o') "," (`p_boot_o') "," ///
        (`nobs') "," (`nclu') "," (`n_treat_o') ",999" _n
    file close `fh'
}

* --- T2: Contested + Uncontested (open seats excluded) ---
di _n "--- T2 Mechanism ---"
preserve
    drop if open_pros == 1
    * Drop primary-only contested
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    drop if treat_pros_primary_only == 1

    foreach y of local key_outcomes {
        capture confirm variable `y'
        if _rc continue

        qui count if !missing(`y')
        if r(N) < 50 continue

        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)

        local nobs = e(N)
        local nclu = e(N_clust)

        * Contested
        local b    = _b[treat_pros_contested_long]
        local se   = _se[treat_pros_contested_long]
        local t    = `b' / `se'
        local p_cl = 2 * ttail(e(df_r), abs(`t'))

        qui count if treat_pros_contested_long == 1 & e(sample)
        local n_treat = r(N)

        capture boottest treat_pros_contested_long, reps(999) seed(42) nograph
        if !_rc {
            local p_boot = r(p)
        }
        else {
            local p_boot = .
            di "  boottest FAILED for `y' T2 contested"
        }

        tempname fh
        file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
        file write `fh' "B,T2_mechanism,contested,`y',treat_pros_contested_long," ///
            (`b') "," (`se') "," (`p_cl') "," (`p_boot') "," ///
            (`nobs') "," (`nclu') "," (`n_treat') ",999" _n
        file close `fh'

        di "  T2 | `y' | contested | p_cluster=" %6.4f `p_cl' " p_boot=" %6.4f `p_boot'

        * Uncontested
        local b_u    = _b[treat_pros_uncontested]
        local se_u   = _se[treat_pros_uncontested]
        local t_u    = `b_u' / `se_u'
        local p_cl_u = 2 * ttail(e(df_r), abs(`t_u'))

        qui count if treat_pros_uncontested == 1 & e(sample)
        local n_treat_u = r(N)

        capture boottest treat_pros_uncontested, reps(999) seed(42) nograph
        if !_rc {
            local p_boot_u = r(p)
        }
        else {
            local p_boot_u = .
        }

        tempname fh
        file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
        file write `fh' "B,T2_mechanism,contested,`y',treat_pros_uncontested," ///
            (`b_u') "," (`se_u') "," (`p_cl_u') "," (`p_boot_u') "," ///
            (`nobs') "," (`nclu') "," (`n_treat_u') ",999" _n
        file close `fh'
    }
restore

* --- T0: Election year binary (open-seat cycles excluded) ---
di _n "--- T0 Election Year ---"
preserve
    * Exclude open-seat cycles (lame-duck contamination)
    bysort county_id (year): gen _has_open = (open_pros == 1)
    bysort county_id: egen _ever_open = max(_has_open)

    * For counties with open seats, find the open-seat year and prior election
    gen _open_year = year if open_pros == 1
    bysort county_id: egen _max_open_yr = max(_open_year)

    gen _prev_elec = .
    forvalues y = 2016/2024 {
        replace _prev_elec = `y' if _max_open_yr > `y' & is_election_year_pros == 1 & year == `y' & _ever_open == 1
    }
    bysort county_id: egen _prev_elec_yr = max(_prev_elec)

    * Drop from (prev_election + 1) through open-seat year
    drop if _ever_open == 1 & year > _prev_elec_yr & year <= _max_open_yr & !missing(_prev_elec_yr)
    * If no prior election found, drop all years up to open seat
    drop if _ever_open == 1 & missing(_prev_elec_yr) & year <= _max_open_yr

    drop _has_open _ever_open _open_year _max_open_yr _prev_elec _prev_elec_yr

    di "  T0 sample: " _N

    foreach y of local key_outcomes {
        capture confirm variable `y'
        if _rc continue

        qui count if !missing(`y')
        if r(N) < 50 continue

        qui reghdfe `y' is_election_year_pros, absorb(county_id year) vce(cluster county_id)

        local nobs = e(N)
        local nclu = e(N_clust)

        local b    = _b[is_election_year_pros]
        local se   = _se[is_election_year_pros]
        local t    = `b' / `se'
        local p_cl = 2 * ttail(e(df_r), abs(`t'))

        qui count if is_election_year_pros == 1 & e(sample)
        local n_treat = r(N)

        capture boottest is_election_year_pros, reps(999) seed(42) nograph
        if !_rc {
            local p_boot = r(p)
        }
        else {
            local p_boot = .
        }

        tempname fh
        file open `fh' using "$OUTPUT/results/mi_boottest_results.csv", write append
        file write `fh' "B,T0_electionyear,electionyear,`y',is_election_year_pros," ///
            (`b') "," (`se') "," (`p_cl') "," (`p_boot') "," ///
            (`nobs') "," (`nclu') "," (`n_treat') ",999" _n
        file close `fh'

        di "  T0 | `y' | p_cluster=" %6.4f `p_cl' " p_boot=" %6.4f `p_boot'
    }
restore


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
use "$DATADIR/mi_panel_B.dta", clear

* twowayfeweights requires: outcome, group, time, treatment
* For T1: treatment = treat_pros_pressure
foreach y of local key_outcomes {
    capture confirm variable `y'
    if _rc continue

    qui count if !missing(`y')
    if r(N) < 50 continue

    di _n "--- twowayfeweights: `y' (T1 pressure) ---"

    capture twowayfeweights `y' county_id year treat_pros_pressure, type(feTR)
    if !_rc {
        * Extract results
        local n_pos = r(N_pos_weights)
        local n_neg = r(N_neg_weights)
        local sum_pos = r(sum_pos_weights)
        local sum_neg = r(sum_neg_weights)

        * Get min/max weights if available
        capture local min_w = r(min_weight)
        if _rc local min_w = .
        capture local max_w = r(max_weight)
        if _rc local max_w = .

        * Sensitivity bounds
        capture local lb = r(sensibility_beta_lb)
        if _rc local lb = .
        capture local ub = r(sensibility_beta_ub)
        if _rc local ub = .

        qui count if !missing(`y')
        local nobs = r(N)

        tempname fh2
        file open `fh2' using "$OUTPUT/results/mi_twowayfeweights.csv", write append
        file write `fh2' "B,T1_baseline,`y',treat_pros_pressure," ///
            (`n_pos') "," (`n_neg') "," (`sum_pos') "," (`sum_neg') "," ///
            (`min_w') "," (`max_w') "," (`nobs') "," (`lb') "," (`ub') _n
        file close `fh2'

        di "  Positive weights: `n_pos' (sum=" %7.4f `sum_pos' ")"
        di "  Negative weights: `n_neg' (sum=" %7.4f `sum_neg' ")"
        if `n_neg' > 0 {
            di "  WARNING: Negative weights detected!"
        }
        else {
            di "  OK: No negative weights"
        }
    }
    else {
        di "  twowayfeweights FAILED for `y'"
    }
}

* T0: election year binary (on full panel before exclusions, for comparison)
foreach y of local key_outcomes {
    capture confirm variable `y'
    if _rc continue

    qui count if !missing(`y')
    if r(N) < 50 continue

    di _n "--- twowayfeweights: `y' (T0 election year) ---"

    capture twowayfeweights `y' county_id year is_election_year_pros, type(feTR)
    if !_rc {
        local n_pos = r(N_pos_weights)
        local n_neg = r(N_neg_weights)
        local sum_pos = r(sum_pos_weights)
        local sum_neg = r(sum_neg_weights)

        capture local min_w = r(min_weight)
        if _rc local min_w = .
        capture local max_w = r(max_weight)
        if _rc local max_w = .

        capture local lb = r(sensibility_beta_lb)
        if _rc local lb = .
        capture local ub = r(sensibility_beta_ub)
        if _rc local ub = .

        qui count if !missing(`y')
        local nobs = r(N)

        tempname fh2
        file open `fh2' using "$OUTPUT/results/mi_twowayfeweights.csv", write append
        file write `fh2' "B,T0_electionyear,`y',is_election_year_pros," ///
            (`n_pos') "," (`n_neg') "," (`sum_pos') "," (`sum_neg') "," ///
            (`min_w') "," (`max_w') "," (`nobs') "," (`lb') "," (`ub') _n
        file close `fh2'

        di "  Positive: `n_pos' | Negative: `n_neg'"
    }
    else {
        di "  twowayfeweights FAILED for `y'"
    }
}


di _n "=============================================="
di "   INFERENCE DIAGNOSTICS COMPLETE"
di "=============================================="
di "  Boottest results: $OUTPUT/results/mi_boottest_results.csv"
di "  TWFE weights:     $OUTPUT/results/mi_twowayfeweights.csv"
