if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

local outcomes "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate total_jury_verdicts capital_felony other_felony other_cases pct_capital_felony pct_other_felony pct_other_cases"

* ============================================================================
* SPECIFICATION 1: Timing-Group × Year FE
*   Separate year effects for synchronized vs off-cycle counties
*   absorb(county_id group_year)
* ============================================================================

di _n "============================================"
di "SPEC 1: TIMING-GROUP x YEAR FE"
di "============================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
di "Sample: " _N

* Create timing group: 0 = off-cycle, 1 = synchronized
gen byte sync_group = !inlist(county_id, 3, 37, 62, 66, 74, 21)
tab sync_group
egen group_year = group(sync_group year)
tab group_year

foreach y of local outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id group_year) vce(cluster county_id)
    if !_rc {
        local b1 = _b[treat_pros_contested_long]
        local se1 = _se[treat_pros_contested_long]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[treat_pros_uncontested]
        local se2 = _se[treat_pros_uncontested]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d = r(estimate)
        local dse = r(se)
        local dp = 2 * ttail(e(df_r), abs(`d'/`dse'))
        di "GxY `y': con=" %9.3f `b1' "(p=" %6.4f `p1' ") unc=" %9.3f `b2' "(p=" %6.4f `p2' ") D=" %9.3f `d' "(p=" %6.4f `dp' ") N=" e(N)
    }
    else {
        di "GxY `y': FAILED — " _rc
    }
}

* ============================================================================
* SPECIFICATION 2: County-Specific Linear Trends for Off-Cycle Only
*   Off-cycle counties get county_id × year trends
*   Synchronized counties: standard county + year FE
* ============================================================================

di _n "============================================"
di "SPEC 2: OFF-CYCLE COUNTY-SPECIFIC LINEAR TRENDS"
di "============================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
di "Sample: " _N

* Create off-cycle county × year interaction for trends
gen byte offcycle = inlist(county_id, 3, 37, 62, 66, 74, 21)
gen offcycle_trend = county_id * year if offcycle == 1
replace offcycle_trend = 0 if offcycle == 0

* For reghdfe, we need a proper FE variable for each off-cycle county's trend
* Create separate trend variables for each off-cycle county
foreach c in 3 37 62 66 74 21 {
    gen trend_`c' = year if county_id == `c'
    replace trend_`c' = 0 if county_id != `c'
}

foreach y of local outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested ///
        trend_3 trend_37 trend_62 trend_66 trend_74 trend_21, ///
        absorb(county_id year) vce(cluster county_id)
    if !_rc {
        local b1 = _b[treat_pros_contested_long]
        local se1 = _se[treat_pros_contested_long]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[treat_pros_uncontested]
        local se2 = _se[treat_pros_uncontested]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d = r(estimate)
        local dse = r(se)
        local dp = 2 * ttail(e(df_r), abs(`d'/`dse'))
        di "LT  `y': con=" %9.3f `b1' "(p=" %6.4f `p1' ") unc=" %9.3f `b2' "(p=" %6.4f `p2' ") D=" %9.3f `d' "(p=" %6.4f `dp' ") N=" e(N)
    }
    else {
        di "LT  `y': FAILED — " _rc
    }
}

* ============================================================================
* SPECIFICATION 3: Wooldridge Extended TWFE (Cohort × Time Interactions)
*   3 cohorts: synchronized (elections 2016+2024), off-cycle-A (2016+2018),
*   off-cycle-B (2016+2022 — Delta county only)
*   Interact cohort × year for heterogeneous time effects
* ============================================================================

di _n "============================================"
di "SPEC 3: WOOLDRIDGE COHORT x TIME"
di "============================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
di "Sample: " _N

* Define election-timing cohorts
gen byte cohort = 1  // synchronized (default)
* Off-cycle A: elections in 2018 (Allegan=3, Isabella=37, Newaygo=62, Osceola=66, Roscommon=74)
replace cohort = 2 if inlist(county_id, 3, 37, 62, 66, 74)
* Off-cycle B: election in 2022 (Delta=21)
replace cohort = 3 if county_id == 21

tab cohort
tab cohort year

* Create cohort × year interaction FE
egen cohort_year = group(cohort year)
tab cohort_year

foreach y of local outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id cohort_year) vce(cluster county_id)
    if !_rc {
        local b1 = _b[treat_pros_contested_long]
        local se1 = _se[treat_pros_contested_long]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[treat_pros_uncontested]
        local se2 = _se[treat_pros_uncontested]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d = r(estimate)
        local dse = r(se)
        local dp = 2 * ttail(e(df_r), abs(`d'/`dse'))
        di "WLD `y': con=" %9.3f `b1' "(p=" %6.4f `p1' ") unc=" %9.3f `b2' "(p=" %6.4f `p2' ") D=" %9.3f `d' "(p=" %6.4f `dp' ") N=" e(N)
    }
    else {
        di "WLD `y': FAILED — " _rc
    }
}

di _n "ALL TIMING ROBUSTNESS DONE"
