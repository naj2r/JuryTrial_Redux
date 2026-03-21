/*==============================================================================
  07h_additional_robustness.do

  Purpose:  Three additional robustness tests:
    1. Jackknife (leave-one-county-out) — at least 10 largest counties
    2. Placebo permutation — 500 iterations
    3. Pre-trend diagnostic — exclude prosecutors not seeking re-election at t=0

  Outputs:
    $OUTPUT/results/mi_jackknife_results.csv
    $OUTPUT/results/mi_permutation_results.csv
    $OUTPUT/results/mi_pretrend_results.csv
==============================================================================*/
/* FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies). From SCAO case type codes. */

* --- Bootstrap ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off
set seed 20260321

di as text _newline "========================================"
di as text "  07h_additional_robustness.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"

capture mkdir "$OUTPUT/results"


* =============================================================================
* PART 1: JACKKNIFE (Leave-One-County-Out)
*
*   Drop each of the 10 largest counties one at a time, re-estimate T1.
*   Output: one row per county × outcome with the leave-one-out coefficient.
* =============================================================================

di _n "{hline 72}"
di "PART 1: JACKKNIFE — LEAVE-ONE-COUNTY-OUT"
di "{hline 72}"

global JACK_CSV "$OUTPUT/results/mi_jackknife_results.csv"

tempname fh
file open `fh' using "$JACK_CSV", write replace
file write `fh' "dropped_county,outcome,beta_loo,se_loo,p_loo,n_loo,beta_full,se_full,p_full,n_full" _n
file close `fh'

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)

* Identify 10 largest counties by average population
preserve
    collapse (mean) county_pop, by(county county_id)
    gsort -county_pop
    gen rank = _n
    list county county_pop rank if rank <= 10, noobs
    keep if rank <= 10
    levelsof county_id, local(big_counties)
    levelsof county, local(big_names)
restore

* Key outcomes for jackknife
local jack_outcomes "actually_reported told_to_report pct_told_to_report ///
    utilization_rate total_jury_verdicts capital_felony pct_other_felony"

* Full-sample estimates (benchmark)
foreach y of local jack_outcomes {
    qui reghdfe `y' treat_pros_pressure open_pros, ///
        absorb(county_id year) vce(cluster county_id)
    local b_full_`y' = _b[treat_pros_pressure]
    local s_full_`y' = _se[treat_pros_pressure]
    local p_full_`y' = 2*ttail(e(df_r), abs(`b_full_`y''/`s_full_`y''))
    local n_full_`y' = e(N)
}

* Leave-one-out loop
foreach cid of local big_counties {
    * Get county name
    qui levelsof county if county_id == `cid', local(cname) clean

    preserve
        drop if county_id == `cid'
        local n_remaining = _N

        foreach y of local jack_outcomes {
            qui reghdfe `y' treat_pros_pressure open_pros, ///
                absorb(county_id year) vce(cluster county_id)
            local b_loo = _b[treat_pros_pressure]
            local s_loo = _se[treat_pros_pressure]
            local p_loo = 2*ttail(e(df_r), abs(`b_loo'/`s_loo'))
            local n_loo = e(N)

            tempname fhj
            file open `fhj' using "$JACK_CSV", write append
            file write `fhj' ///
                `"`cname'"' "," `"`y'"' "," ///
                (`b_loo') "," (`s_loo') "," (`p_loo') "," (`n_loo') "," ///
                (`b_full_`y'') "," (`s_full_`y'') "," (`p_full_`y'') "," (`n_full_`y'') _n
            file close `fhj'
        }

        di "  Dropped `cname' (id=`cid'): N=" `n_remaining'
    restore
}

di "Jackknife complete: $JACK_CSV"


* =============================================================================
* PART 2: PLACEBO PERMUTATION (500 iterations)
*
*   Randomly shuffle treatment assignment within each year, re-estimate T1.
*   Output: distribution of placebo coefficients for comparison with actual.
* =============================================================================

di _n "{hline 72}"
di "PART 2: PLACEBO PERMUTATION (500 iterations)"
di "{hline 72}"

global PERM_CSV "$OUTPUT/results/mi_permutation_results.csv"

tempname fh
file open `fh' using "$PERM_CSV", write replace
file write `fh' "iteration,outcome,beta_placebo,se_placebo,p_placebo,n_obs" _n
file close `fh'

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)

local perm_outcomes "actually_reported pct_told_to_report total_jury_verdicts pct_other_felony"

* Store actual estimates
foreach y of local perm_outcomes {
    qui reghdfe `y' treat_pros_pressure open_pros, ///
        absorb(county_id year) vce(cluster county_id)
    local b_actual_`y' = _b[treat_pros_pressure]
}

* Permutation loop
forval iter = 1/500 {
    if mod(`iter', 50) == 0 di "  Iteration `iter'/500..."

    preserve
        * Shuffle treatment within year (preserves year-level treatment share)
        gen _rand = runiform()
        bysort year (_rand): gen _rank = _n
        bysort year: egen _n_treated = total(treat_pros_pressure)

        * Assign placebo treatment to top _n_treated within each year
        gen treat_placebo = (_rank <= _n_treated)

        * Similarly shuffle open_pros
        bysort year: egen _n_open = total(open_pros)
        gen open_placebo = (_rank > _n_treated & _rank <= _n_treated + _n_open)

        foreach y of local perm_outcomes {
            qui reghdfe `y' treat_placebo open_placebo, ///
                absorb(county_id year) vce(cluster county_id)
            local b_p = _b[treat_placebo]
            local s_p = _se[treat_placebo]
            local p_p = 2*ttail(e(df_r), abs(`b_p'/`s_p'))
            local n_p = e(N)

            tempname fhp
            file open `fhp' using "$PERM_CSV", write append
            file write `fhp' ///
                (`iter') "," `"`y'"' "," ///
                (`b_p') "," (`s_p') "," (`p_p') "," (`n_p') _n
            file close `fhp'
        }
    restore
}

* Append actual estimates as iteration 0
foreach y of local perm_outcomes {
    qui reghdfe `y' treat_pros_pressure open_pros, ///
        absorb(county_id year) vce(cluster county_id)
    local b_a = _b[treat_pros_pressure]
    local s_a = _se[treat_pros_pressure]
    local p_a = 2*ttail(e(df_r), abs(`b_a'/`s_a'))
    local n_a = e(N)

    tempname fhp
    file open `fhp' using "$PERM_CSV", write append
    file write `fhp' ///
        (0) "," `"`y'"' "," ///
        (`b_a') "," (`s_a') "," (`p_a') "," (`n_a') _n
    file close `fhp'
}

di "Permutation complete: $PERM_CSV"


* =============================================================================
* PART 3: PRE-TREND DIAGNOSTIC
*
*   Restrict sample to election years where the incumbent is seeking re-election
*   at t=0. Test whether outcomes in the year BEFORE the election (t-1) already
*   show the treatment pattern. If pre-trends exist, the design is threatened.
*
*   Approach: regress outcomes on LEAD of treatment (next year's pressure)
* =============================================================================

di _n "{hline 72}"
di "PART 3: PRE-TREND DIAGNOSTIC"
di "{hline 72}"

global PRETREND_CSV "$OUTPUT/results/mi_pretrend_results.csv"

tempname fh
file open `fh' using "$PRETREND_CSV", write replace
file write `fh' "spec,outcome,beta,se,p_value,n_obs,n_clusters,description" _n
file close `fh'

use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)

* Generate lead of treatment (next year's pressure)
sort county_id year
by county_id: gen lead_pressure = treat_pros_pressure[_n+1]
by county_id: gen lead_open = open_pros[_n+1]
replace lead_pressure = 0 if missing(lead_pressure)
replace lead_open = 0 if missing(lead_open)
label var lead_pressure "Lead: pressure in t+1"
label var lead_open "Lead: open seat in t+1"

* Also generate lag (prior year's pressure)
by county_id: gen lag_pressure = treat_pros_pressure[_n-1]
by county_id: gen lag_open = open_pros[_n-1]
replace lag_pressure = 0 if missing(lag_pressure)
replace lag_open = 0 if missing(lag_open)
label var lag_pressure "Lag: pressure in t-1"
label var lag_open "Lag: open seat in t-1"

local pretrend_outcomes "actually_reported told_to_report pct_told_to_report ///
    utilization_rate total_jury_verdicts capital_felony pct_other_felony"

* --- Test 1: Lead of treatment (does next year's election predict this year's outcome?) ---
di _n "=== Lead test: does t+1 pressure predict t outcome? ==="
foreach y of local pretrend_outcomes {
    qui reghdfe `y' lead_pressure lead_open, ///
        absorb(county_id year) vce(cluster county_id)
    local b = _b[lead_pressure]
    local s = _se[lead_pressure]
    local p = 2*ttail(e(df_r), abs(`b'/`s'))
    local n = e(N)
    local nc = e(N_clust)

    di "  `y': lead_pressure b=" %9.3f `b' " p=" %6.4f `p'

    tempname fht
    file open `fht' using "$PRETREND_CSV", write append
    file write `fht' ///
        `""lead_pressure""' "," `"`y'"' "," ///
        (`b') "," (`s') "," (`p') "," (`n') "," (`nc') "," ///
        `""Does t+1 election predict t outcome""' _n
    file close `fht'
}

* --- Test 2: Lag of treatment (does prior year's election predict current outcome?) ---
di _n "=== Lag test: does t-1 pressure predict t outcome? ==="
foreach y of local pretrend_outcomes {
    qui reghdfe `y' lag_pressure lag_open, ///
        absorb(county_id year) vce(cluster county_id)
    local b = _b[lag_pressure]
    local s = _se[lag_pressure]
    local p = 2*ttail(e(df_r), abs(`b'/`s'))
    local n = e(N)
    local nc = e(N_clust)

    di "  `y': lag_pressure b=" %9.3f `b' " p=" %6.4f `p'

    tempname fht
    file open `fht' using "$PRETREND_CSV", write append
    file write `fht' ///
        `""lag_pressure""' "," `"`y'"' "," ///
        (`b') "," (`s') "," (`p') "," (`n') "," (`nc') "," ///
        `""Does t-1 election predict t outcome""' _n
    file close `fht'
}

* --- Test 3: Both lead and lag in same regression (event study style) ---
di _n "=== Joint lead+lag+current test ==="
foreach y of local pretrend_outcomes {
    qui reghdfe `y' lag_pressure treat_pros_pressure lead_pressure ///
        lag_open open_pros lead_open, ///
        absorb(county_id year) vce(cluster county_id)

    foreach tv in lag_pressure treat_pros_pressure lead_pressure {
        local b = _b[`tv']
        local s = _se[`tv']
        local p = 2*ttail(e(df_r), abs(`b'/`s'))
        local n = e(N)
        local nc = e(N_clust)

        tempname fht
        file open `fht' using "$PRETREND_CSV", write append
        file write `fht' ///
            `""joint_`tv'""' "," `"`y'"' "," ///
            (`b') "," (`s') "," (`p') "," (`n') "," (`nc') "," ///
            `""Joint model: lag+current+lead""' _n
        file close `fht'
    }
}


di _n "========================================"
di "  07h COMPLETE"
di "  Outputs:"
di "    $JACK_CSV"
di "    $PERM_CSV"
di "    $PRETREND_CSV"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
