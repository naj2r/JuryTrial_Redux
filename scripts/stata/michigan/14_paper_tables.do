/*==============================================================================
  14_paper_tables.do

  Purpose:  Generate the 8 publication-ready LaTeX tables for the paper.
            ALL tables use B_no_offcycle sample (drop 2018, 2022).
            Uses esttab/estout for formatting with booktabs.

  Tables:
    1. Baseline Election Effect (T0)
    2. Incumbent vs Open Seat — Main Result (T1)
    3. Contestation Mechanism (T2)
    4. Pipeline vs Outcomes — Core Contribution (T1)
    5. Composition / Mechanism Detail (T1 + FC/FH plea)
    6. Heterogeneity by Population (T1)
    7. Robustness Summary (B, B_no_offcycle, B_no2016, B_no2024)
    8. Falsification / Placebo

  Output:   $OL/files/tab/paper/table1_baseline.tex ... table8_falsification.tex

  Requires: paths.do, globals.do, esttab (estout package)
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
di as text "  14_paper_tables.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"

* --- Output directory ---
global OL "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26"
global TAB_DIR "$OL/files/tab/paper"
capture mkdir "$TAB_DIR"

* --- Confirm esttab is available ---
capture which esttab
if _rc {
    di as error "esttab not found. Install: ssc install estout"
    exit 198
}


* =============================================================================
* LOAD PANEL B AND CREATE B_NO_OFFCYCLE
* =============================================================================

use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Panel B loaded: " _N " obs"

* Drop off-cycle COUNTIES to create B_no_offcycle
* These 6 counties have off-cycle prosecutor elections (2018 or 2022):
*   Allegan, Isabella, Newaygo, Osceola, Roscommon (2018); Delta (2022)
* They are the entire source of TWFE negative weights in T0
* We drop them from ALL years (not just 2018/2022) to maintain balanced panel
drop if inlist(county, "Allegan", "Isabella", "Newaygo", "Osceola", "Roscommon", "Delta")
di "B_no_offcycle sample (6 off-cycle counties dropped): " _N " obs"

* Verify panel structure
qui distinct county_id
di "Counties: " r(ndistinct)
qui distinct year
di "Years: " r(ndistinct)
tab year treat_pros_pressure, missing

* Store sample size
local N_main = _N


* =============================================================================
* TABLE 1 — BASELINE ELECTION EFFECT (T0)
*
* Y_ct = β * ElectionYear_ct + county FE + year FE + ε_ct
* Sample: B_no_offcycle, excluding open-seat cycles (lame-duck + open year)
* =============================================================================

di _n "{hline 72}"
di "TABLE 1: BASELINE ELECTION EFFECT (T0)"
di "{hline 72}"

preserve

    * --- Exclude open-seat cycles (lame-duck years + open-seat year) ---
    * Identify counties with open-seat elections
    bysort county_id: egen _has_open = max(open_pros)

    * For counties WITH open seats: find the open-seat year and prior election
    * Then drop from (prior_election + 1) through open-seat year
    gen _drop_t0 = 0

    levelsof county_id if _has_open == 1, local(open_counties)
    foreach c of local open_counties {
        * Find open-seat year for this county
        qui su year if county_id == `c' & open_pros == 1, meanonly
        if r(N) > 0 {
            local open_yr = r(mean)
            * Find most recent election year before the open-seat year
            qui su year if county_id == `c' & is_election_year_pros == 1 & year < `open_yr', meanonly
            if r(N) > 0 {
                local prev_elec = r(max)
                * Drop from prev_elec+1 through open_yr
                replace _drop_t0 = 1 if county_id == `c' & year > `prev_elec' & year <= `open_yr'
            }
            else {
                * No prior election in panel — drop all years up to and including open year
                replace _drop_t0 = 1 if county_id == `c' & year <= `open_yr'
            }
        }
    }

    qui drop if _drop_t0 == 1
    drop _has_open _drop_t0
    di "T0 sample (open-seat cycles excluded): " _N

    * --- Regressions ---
    local t1_outcomes "actually_reported pct_told_to_report utilization_rate total_jury_verdicts"

    local i = 1
    foreach y of local t1_outcomes {
        qui reghdfe `y' is_election_year_pros, absorb(county_id year) vce(cluster county_id)
        eststo t1_`i'
        local ++i
    }

    * --- Generate table ---
    esttab t1_1 t1_2 t1_3 t1_4 using "$TAB_DIR/table1_baseline.tex", ///
        replace booktabs alignment(D{.}{.}{-1}) ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        mtitles("Jurors Reported" "\% Told to Report" "Utilization Rate" "Jury Verdicts") ///
        mgroups("Pipeline" "Outcomes", pattern(1 0 0 1) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
        scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
        label nonotes noobs ///
        addnotes("Standard errors clustered at county level in parentheses." ///
                 "County and year fixed effects included in all specifications." ///
                 "Sample: B\_no\_offcycle, open-seat election cycles excluded." ///
                 "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

    eststo clear
    di "Table 1 written to $TAB_DIR/table1_baseline.tex"

restore


* =============================================================================
* TABLE 2 — INCUMBENT PRESSURE (MAIN RESULT, T1)
*
* Y_ct = β1 * IncumbentRunning_ct + β2 * OpenSeat_ct + FE + ε_ct
* Sample: B_no_offcycle (6 off-cycle counties dropped, open seats kept)
* Omitted: non-election years. Open seats provide within-year variation.
* Only pressure coefficient reported; open_pros is a control.
* =============================================================================

di _n "{hline 72}"
di "TABLE 2: INCUMBENT PRESSURE (T1)"
di "{hline 72}"

local t2_outcomes "actually_reported pct_told_to_report utilization_rate total_jury_verdicts pct_other_felony"

local i = 1
foreach y of local t2_outcomes {
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo t2_`i'
    local ++i
}

esttab t2_1 t2_2 t2_3 t2_4 t2_5 using "$TAB_DIR/table2_main.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Reported" "\% Told to Report" "Utilization Rate" "Jury Verdicts" "\% Other Felony") ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Standard errors clustered at county level in parentheses." ///
             "County and year fixed effects. Open-seat indicator included as control." ///
             "Sample: B\_no\_offcycle (6 off-cycle counties excluded)." ///
             "Omitted category: non-election years." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 2 written to $TAB_DIR/table2_main.tex"


* =============================================================================
* TABLE 3 — CONTESTATION (T2)
*
* Y_ct = β1 * Contested_ct + β2 * Uncontested_ct + FE + ε_ct
* Sample: B_no_offcycle, incumbent-running elections only (exclude open seats)
* =============================================================================

di _n "{hline 72}"
di "TABLE 3: CONTESTATION (T2)"
di "{hline 72}"

preserve

    * Drop open seats and primary-only contested
    capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)
    qui drop if treat_pros_primary_only == 1
    qui drop if open_pros == 1
    di "T2 sample: " _N

    local t3_outcomes "actually_reported pct_told_to_report utilization_rate total_jury_verdicts pct_other_felony"

    local i = 1
    foreach y of local t3_outcomes {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
        eststo t3_`i'

        * Store lincom difference
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar diff_b = r(estimate) : t3_`i'
        estadd scalar diff_se = r(se) : t3_`i'
        estadd scalar diff_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t3_`i'

        local ++i
    }

    esttab t3_1 t3_2 t3_3 t3_4 t3_5 using "$TAB_DIR/table3_contestation.tex", ///
        replace booktabs alignment(D{.}{.}{-1}) ///
        cells(b(star fmt(3)) se(par fmt(3))) ///
        star(* 0.10 ** 0.05 *** 0.01) ///
        mtitles("Jurors Reported" "\% Told to Report" "Utilization Rate" "Jury Verdicts" "\% Other Felony") ///
        keep(treat_pros_contested_long treat_pros_uncontested) ///
        coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
        scalars("diff_b $\Delta$ (Contested $-$ Uncontested)" "diff_se SE($\Delta$)" "diff_p $p(\Delta)$" ///
                "N Observations" "N_clust Clusters") ///
        sfmt(3 3 3 0 0) ///
        label nonotes noobs ///
        addnotes("Standard errors clustered at county level in parentheses." ///
                 "$\Delta$ = Contested $-$ Uncontested, tested via \texttt{lincom}." ///
                 "Sample: B\_no\_offcycle, open seats and primary-only excluded." ///
                 "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

    eststo clear
    di "Table 3 written to $TAB_DIR/table3_contestation.tex"

restore


* =============================================================================
* TABLE 4 — PIPELINE VS OUTCOMES (CORE CONTRIBUTION, T1)
*
* Single coefficient: treat_pros_pressure, open seats excluded from sample
* Panel A: Mobilization   (jurors reported, % told to report, utilization)
* Panel B: Outcomes       (jury verdicts, capital felony)
* Panel C: Composition    (% capital felony, % other felony, % other cases)
* =============================================================================

di _n "{hline 72}"
di "TABLE 4: PIPELINE VS OUTCOMES"
di "{hline 72}"

* Panel A: Mobilization
local panA "actually_reported pct_told_to_report utilization_rate"
local i = 1
foreach y of local panA {
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo t4a_`i'
    local ++i
}

* Panel B: Outcomes
local panB "total_jury_verdicts capital_felony"
local i = 1
foreach y of local panB {
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo t4b_`i'
    local ++i
}

* Panel C: Composition
local panC "pct_capital_felony pct_other_felony pct_other_cases"
local i = 1
foreach y of local panC {
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo t4c_`i'
    local ++i
}

esttab t4a_1 t4a_2 t4a_3 t4b_1 t4b_2 t4c_1 t4c_2 t4c_3 using "$TAB_DIR/table4_pipeline_outcomes.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Reported" "\% Told to Report" "Utilization" "Jury Verdicts" "Capital Felony" "\% Capital" "\% Other Felony" "\% Other Cases") ///
    mgroups("Panel A: Mobilization" "Panel B: Outcomes" "Panel C: Composition", ///
        pattern(1 0 0 1 0 1 0 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Standard errors clustered at county level in parentheses." ///
             "County and year FE. Open-seat indicator included as control." ///
             "Sample: B\_no\_offcycle." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 4 written to $TAB_DIR/table4_pipeline_outcomes.tex"


* =============================================================================
* TABLE 5 — COMPOSITION / MECHANISM DETAIL
*
* Panel A: County-year verdict composition (from main panel)
* Panel B: Circuit court FC plea composition (from outgoing caseload)
* Panel C: Circuit court FH plea composition (from outgoing caseload)
* =============================================================================

di _n "{hline 72}"
di "TABLE 5: COMPOSITION DETAIL"
di "{hline 72}"

* --- Panel A: Verdict composition from main panel ---
local panA5 "pct_capital_felony pct_other_felony pct_other_cases"
local i = 1
foreach y of local panA5 {
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo t5a_`i'
    local ++i
}

* --- Panel B: FC plea composition (circuit court capital felonies) ---
preserve

    * Build FC data from raw
    import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", clear varnames(1) encoding("UTF-8")
    gen byte is_disp = inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
    keep if is_disp == 1
    gen action_var = ""
    replace action_var = "jury" if action_name == "Jury Verdict"
    replace action_var = "bench" if action_name == "Bench Verdict"
    replace action_var = "plea" if action_name == "Guilty Plea"

    collapse (sum) quantity, by(county court_code case_type year action_var)
    drop if missing(action_var) | action_var == ""
    reshape wide quantity, i(county court_code case_type year) j(action_var) string

    rename quantityjury jury_only
    capture rename quantitybench bench_verdict
    rename quantityplea plea_total

    foreach v in jury_only bench_verdict plea_total {
        capture replace `v' = 0 if missing(`v')
    }

    gen trial_total = jury_only + cond(missing(bench_verdict), 0, bench_verdict)
    gen resolved = plea_total + trial_total
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0

    * FC only
    keep if regexm(case_type, "^FC ")
    collapse (sum) jury_only plea_total trial_total resolved, by(county year)
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0

    * Merge with election data
    merge m:1 county year using "$DATA_FINAL/michigan_panel_B.dta", ///
        keepusing(county_id treat_pros_pressure open_pros is_election_year_pros ///
                  treat_pros_contested_long treat_pros_uncontested treat_pros_contested) ///
        keep(match) nogen

    * Apply B_no_offcycle restriction (drop off-cycle counties, not years)
    drop if inlist(county, "Allegan", "Isabella", "Newaygo", "Osceola", "Roscommon", "Delta")

    di "FC plea sample (B_no_offcycle): " _N

    local fc_outcomes "plea_share jury_share"
    local i = 1
    foreach y of local fc_outcomes {
        qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
        eststo t5b_`i'
        local ++i
    }

restore

* --- Panel C: FH plea composition (circuit court non-capital felonies) ---
preserve

    import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", clear varnames(1) encoding("UTF-8")
    gen byte is_disp = inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
    keep if is_disp == 1
    gen action_var = ""
    replace action_var = "jury" if action_name == "Jury Verdict"
    replace action_var = "bench" if action_name == "Bench Verdict"
    replace action_var = "plea" if action_name == "Guilty Plea"

    collapse (sum) quantity, by(county court_code case_type year action_var)
    drop if missing(action_var) | action_var == ""
    reshape wide quantity, i(county court_code case_type year) j(action_var) string

    rename quantityjury jury_only
    capture rename quantitybench bench_verdict
    rename quantityplea plea_total

    foreach v in jury_only bench_verdict plea_total {
        capture replace `v' = 0 if missing(`v')
    }

    gen trial_total = jury_only + cond(missing(bench_verdict), 0, bench_verdict)
    gen resolved = plea_total + trial_total
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0

    * FH only (NOT FC)
    keep if !regexm(case_type, "^FC ")
    collapse (sum) jury_only plea_total trial_total resolved, by(county year)
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0

    merge m:1 county year using "$DATA_FINAL/michigan_panel_B.dta", ///
        keepusing(county_id treat_pros_pressure open_pros is_election_year_pros ///
                  treat_pros_contested_long treat_pros_uncontested treat_pros_contested) ///
        keep(match) nogen

    drop if inlist(county, "Allegan", "Isabella", "Newaygo", "Osceola", "Roscommon", "Delta")
    di "FH plea sample (B_no_offcycle): " _N

    local fh_outcomes "plea_share jury_share"
    local i = 1
    foreach y of local fh_outcomes {
        qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
        eststo t5c_`i'
        local ++i
    }

restore

esttab t5a_1 t5a_2 t5a_3 t5b_1 t5b_2 t5c_1 t5c_2 using "$TAB_DIR/table5_composition.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("\% Capital" "\% Other Felony" "\% Other Cases" "FC Plea Share" "FC Jury Share" "FH Plea Share" "FH Jury Share") ///
    mgroups("Panel A: Verdict Composition" "Panel B: FC Plea (Circuit)" "Panel C: FH Plea (Circuit)", ///
        pattern(1 0 0 1 0 1 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Standard errors clustered at county level in parentheses." ///
             "Panel A: jury verdict composition from SCAO jury management data." ///
             "Panels B--C: plea/trial composition from SCAO outgoing caseload data (circuit courts)." ///
             "FC = Capital Felony (life-eligible). FH = Non-capital Felony." ///
             "Sample: B\_no\_offcycle, open-seat county-years excluded." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 5 written to $TAB_DIR/table5_composition.tex"


* =============================================================================
* TABLE 6 — HETEROGENEITY BY POPULATION (T1)
*
* Panel A: Above-median population
* Panel B: Below-median population
* =============================================================================

di _n "{hline 72}"
di "TABLE 6: HETEROGENEITY BY POPULATION"
di "{hline 72}"

* Compute median population
qui su county_pop, detail
local pop_median = r(p50)
di "Median county population: " `pop_median'

gen byte highpop = (county_pop >= `pop_median')

local t6_outcomes "actually_reported pct_told_to_report utilization_rate total_jury_verdicts pct_other_felony"

* Panel A: High population
preserve
    keep if highpop == 1
    di "High-pop sample: " _N

    local i = 1
    foreach y of local t6_outcomes {
        qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
        eststo t6a_`i'
        local ++i
    }
restore

* Panel B: Low population
preserve
    keep if highpop == 0
    di "Low-pop sample: " _N

    local i = 1
    foreach y of local t6_outcomes {
        qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
        eststo t6b_`i'
        local ++i
    }
restore

* Write Panel A
esttab t6a_1 t6a_2 t6a_3 t6a_4 t6a_5 using "$TAB_DIR/table6a_het_highpop.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Reported" "\% Told to Report" "Utilization" "Jury Verdicts" "\% Other Felony") ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Panel A: Above-median population counties." ///
             "Standard errors clustered at county level." ///
             "County and year FE. Open-seat indicator included as control." ///
             "Sample: B\_no\_offcycle." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

* Write Panel B
esttab t6b_1 t6b_2 t6b_3 t6b_4 t6b_5 using "$TAB_DIR/table6b_het_lowpop.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Reported" "\% Told to Report" "Utilization" "Jury Verdicts" "\% Other Felony") ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Panel B: Below-median population counties." ///
             "Standard errors clustered at county level." ///
             "County and year FE. Open-seat indicator included as control." ///
             "Sample: B\_no\_offcycle." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 6 written to $TAB_DIR/table6a_het_highpop.tex and table6b_het_lowpop.tex"


* =============================================================================
* TABLE 7 — ROBUSTNESS SUMMARY
*
* Rows: B, B_no_offcycle (main), B_no2016, B_no2024
* Columns: Jurors Reported, Jury Verdicts (IncumbentRunning only)
* =============================================================================

di _n "{hline 72}"
di "TABLE 7: ROBUSTNESS SUMMARY"
di "{hline 72}"

* Reload full B panel
use "$DATA_FINAL/michigan_panel_B.dta", clear

* --- B (full panel, open_pros as control) ---
qui reghdfe actually_reported treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
eststo r_B_ar
qui reghdfe total_jury_verdicts treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
eststo r_B_jv

* --- B_no_offcycle (drop off-cycle counties, open_pros as control) ---
preserve
    drop if inlist(county, "Allegan", "Isabella", "Newaygo", "Osceola", "Roscommon", "Delta")
    qui reghdfe actually_reported treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_Bno_ar
    qui reghdfe total_jury_verdicts treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_Bno_jv
restore

* --- B_no2016 ---
preserve
    drop if year == 2016
    qui reghdfe actually_reported treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_no16_ar
    qui reghdfe total_jury_verdicts treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_no16_jv
restore

* --- B_no2024 ---
preserve
    drop if year == 2024
    qui reghdfe actually_reported treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_no24_ar
    qui reghdfe total_jury_verdicts treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    eststo r_no24_jv
restore

* Write as grouped columns
esttab r_B_ar r_Bno_ar r_no16_ar r_no24_ar r_B_jv r_Bno_jv r_no16_jv r_no24_jv ///
    using "$TAB_DIR/table7_robustness.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("B" "B\_noOC" "No 2016" "No 2024" "B" "B\_noOC" "No 2016" "No 2024") ///
    mgroups("Jurors Actually Reported" "Total Jury Verdicts", ///
        pattern(1 0 0 0 1 0 0 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Incumbent Running coefficient shown; open-seat indicator included as control." ///
             "B\_noOC = B\_no\_offcycle (drop 6 off-cycle counties). County and year FE." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 7 written to $TAB_DIR/table7_robustness.tex"


* =============================================================================
* TABLE 8 — FALSIFICATION / PLACEBO
*
* Caseload DV: incoming_felony does not respond to treatment
* Permutation: summary of 07h placebo distribution
* =============================================================================

di _n "{hline 72}"
di "TABLE 8: FALSIFICATION"
di "{hline 72}"

* Reload B_no_offcycle (drop off-cycle counties)
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if inlist(county, "Allegan", "Isabella", "Newaygo", "Osceola", "Roscommon", "Delta")

* Merge caseload data (key is county + year, not county_id)
merge m:1 county year using "$DATA_INT/mi_caseload_panel.dta", ///
    keepusing(incoming_felony pending_felony log_pending) ///
    keep(match master) nogen

* --- Caseload falsification ---
qui reghdfe incoming_felony treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
eststo t8_1

* --- Congestion control: main result with log(pending) ---
* log_pending already in caseload data from 03b
qui reghdfe actually_reported treat_pros_pressure open_pros log_pending, absorb(county_id year) vce(cluster county_id)
eststo t8_2

esttab t8_1 t8_2 using "$TAB_DIR/table8_falsification.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Incoming Felonies" "Jurors Reported (w/ caseload control)") ///
    keep(treat_pros_pressure) ///
    coeflabels(treat_pros_pressure "Incumbent Running") ///
    scalars("N Observations" "N_clust Clusters") sfmt(0 0) ///
    label nonotes noobs ///
    addnotes("Col 1: Incoming felony caseload as dependent variable (falsification)." ///
             "Col 2: Main result with log(pending felonies) as additional control." ///
             "Open-seat indicator included as control. County and year FE." ///
             "Sample: B\_no\_offcycle." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 8 written to $TAB_DIR/table8_falsification.tex"


* =============================================================================
* DONE
* =============================================================================

di _n "{hline 72}"
di "ALL 8 TABLES GENERATED"
di "Output directory: $TAB_DIR"
di "{hline 72}"

dir "$TAB_DIR/*.tex"

di _n "Done. $S_DATE $S_TIME"
