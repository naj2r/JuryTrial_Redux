/*==============================================================================
  14_paper_tables.do — FINAL PRODUCTION TABLES (v3)

  Architecture:
    T0: Election-year benchmark. Full B (83 counties, N=579). All obs.
    T1: Incumbent pressure. Full B, open seats dropped (N=553). Single β.
    T2: Contestation. Full B, open seats dropped (N=553). Two β + Δ.
        THIS IS THE MAIN TABLE.

  All models: county FE + year FE + county-clustered SE.
  No open_pros anywhere. No B_no_offcycle (causes collinearity).
  Full B panel required — off-cycle counties provide identification.

  Output: $OL/files/tab/paper/table1-8.tex
==============================================================================*/
/* FC = Felony Capital (life-eligible). FH = Felony non-capital. SCAO codes. */

if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear all
set more off

global OL "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26"
global TAB_DIR "$OL/files/tab/paper"
capture mkdir "$TAB_DIR"

capture which esttab
if _rc {
    di as error "esttab not found. ssc install estout"
    exit 198
}

di _n "========================================"
di "  14_paper_tables.do — FINAL v3"
di "  $S_DATE $S_TIME"
di "========================================"


* =============================================================================
* SHARED SETUP: Outcome lists, labels, star function
* =============================================================================

* --- Full outcome list (4 groups, 16 outcomes) ---
#delimit ;
local outcomes_summon  "summoned told_to_report actually_reported
                        sent_to_courtroom questioned_in_voir_dire" ;
local outcomes_rates   "pct_told_to_report pct_sent_to_courtroom
                        pct_questioned_in_voir_dire utilization_rate" ;
local outcomes_verdict "total_jury_verdicts capital_felony other_felony other_cases" ;
local outcomes_comp    "pct_capital_felony pct_other_felony pct_other_cases" ;
#delimit cr

local all_outcomes "`outcomes_summon' `outcomes_rates' `outcomes_verdict' `outcomes_comp'"

* --- Outcome labels ---
local lbl_summoned                    "Summoned"
local lbl_told_to_report              "Told to Report"
local lbl_actually_reported           "Actually Reported"
local lbl_sent_to_courtroom           "Sent to Courtroom"
local lbl_questioned_in_voir_dire     "Questioned in Voir Dire"
local lbl_pct_told_to_report          "\% Told to Report"
local lbl_pct_sent_to_courtroom       "\% Sent to Courtroom"
local lbl_pct_questioned_in_voir_dire "\% Questioned in Voir Dire"
local lbl_utilization_rate            "Utilization Rate"
local lbl_total_jury_verdicts         "Total Jury Verdicts"
local lbl_capital_felony              "Capital Felony Verdicts"
local lbl_other_felony                "Other Felony Verdicts"
local lbl_other_cases                 "Other Cases Verdicts"
local lbl_pct_capital_felony          "\% Capital Felony"
local lbl_pct_other_felony            "\% Other Felony"
local lbl_pct_other_cases             "\% Other Cases"

* --- Star function ---
capture program drop add_stars
program define add_stars, rclass
    args pval
    if `pval' < 0.01 {
        return local stars "\sym{***}"
    }
    else if `pval' < 0.05 {
        return local stars "\sym{**}"
    }
    else if `pval' < 0.10 {
        return local stars "\sym{*}"
    }
    else {
        return local stars ""
    }
end

* --- Formatting helper: count outcomes get 1 decimal, rates get 3 ---
capture program drop fmt_coef
program define fmt_coef, rclass
    args val outcome
    local is_rate = (strpos("`outcome'", "pct_") == 1 | "`outcome'" == "utilization_rate")
    if `is_rate' {
        local fmt : di %9.3f `val'
    }
    else {
        local fmt : di %9.1f `val'
    }
    return local formatted "`=strtrim("`fmt'")'"
end


* =============================================================================
* TABLE 1 — T0c: MAIN PAPER (county FE only, open seat as separate regressor)
*   Y = β1*ElectionYear + β2*OpenSeat + county FE + ε
*   Full B panel (83 counties, N=579). County FE only — no year FE.
* =============================================================================

di _n "{hline 72}"
di "TABLE 1: T0c — MAIN PAPER (county FE, open seat regressor)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Full B: " _N

local f "$TAB_DIR/table1_baseline.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect (T0)}" _n
file write t "\label{tab:table1}" _n
file write t "\begin{threeparttable}" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Election Year} & \multicolumn{2}{c}{Open Seat} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(N\) \\"' _n
file write t "\midrule" _n

* Loop through all 4 panels
local panel_lbl_1 "Panel A: Summon/Report Counts"
local panel_list_1 "`outcomes_summon'"
local panel_lbl_2 "Panel B: Pipeline Rates"
local panel_list_2 "`outcomes_rates'"
local panel_lbl_3 "Panel C: Verdict Counts"
local panel_list_3 "`outcomes_verdict'"
local panel_lbl_4 "Panel D: Verdict Composition"
local panel_list_4 "`outcomes_comp'"

forvalues p = 1/4 {
    if `p' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{6}{l}{\textit{`panel_lbl_`p''}} \\[0.3em]" _n

    foreach y of local panel_list_`p' {
        qui reghdfe `y' is_election_year_pros open_pros, absorb(county_id) vce(cluster county_id)
        local b1 = _b[is_election_year_pros]
        local se1 = _se[is_election_year_pros]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[open_pros]
        local se2 = _se[open_pros]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        local n = e(N)

        add_stars `p1'
        local stars1 "`r(stars)'"
        add_stars `p2'
        local stars2 "`r(stars)'"

        fmt_coef `b1' `y'
        local b1f "`r(formatted)'"
        fmt_coef `se1' `y'
        local se1f "`r(formatted)'"
        fmt_coef `b2' `y'
        local b2f "`r(formatted)'"
        fmt_coef `se2' `y'
        local se2f "`r(formatted)'"

        file write t "`lbl_`y'' & `b1f'`stars1' & (`se1f') & `b2f'`stars2' & (`se2f') & `n' \\" _n
    }
}

file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item \textit{Notes.} \(Y_{ct} = \beta_1 \cdot \text{ElectionYear}_{ct} + \beta_2 \cdot \text{OpenSeat}_{ct} + \alpha_c + \varepsilon_{ct}\)."' _n
file write t `"\item County fixed effects only (no year FE). Standard errors clustered at county level."' _n
file write t `"\item ElectionYear \(= 1\) when incumbent prosecutor runs for re-election."' _n
file write t `"\item OpenSeat \(= 1\) when no incumbent runs. Omitted: non-election years."' _n
file write t `"\item Full panel: 83 counties \(\times\) 7 years \(= 579\) obs (less outcome-specific missingness)."' _n
file write t `"\item See Table~\ref{tab:tableA1} for sample restriction sensitivity (T0a--T0e), including TWFE."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Table 1 (T0c main) DONE: `f'"


* =============================================================================
* TABLE A1 — APPENDIX: T0 SAMPLE SENSITIVITY (4 versions, key outcomes only)
*   Columns: T0a | T0b | T0c (elec) | T0d (elec)
*   Rows: key outcomes × (coef, SE)
*   Footer rows: Open seats excluded? | Off-cycle excluded? | N | Counties
*
*   T0a: Y = β*ElecYear + county FE + ε,   open seats dropped
*   T0b: Y = β*ElecYear + county FE + ε,   open seats dropped + off-cycle dropped
*   T0c: Y = β1*ElecYear + β2*Open + county FE + ε,   full panel
*   T0d: Y = β1*ElecYear + β2*Open + county FE + ε,   off-cycle dropped
* =============================================================================

di _n "{hline 72}"
di "TABLE A1: T0 APPENDIX SENSITIVITY"
di "{hline 72}"

* We need to run all 4 versions and store results
* Use a tempfile CSV approach

tempname fh
tempfile t0_results
file open `fh' using "`t0_results'", write replace
file write `fh' "version,outcome,beta,se,pval,nobs,ncounties" _n

* --- T0a: drop open seats, all counties, county FE only ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
local na = _N
qui distinct county_id
local nca = r(ndistinct)

foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        local b = _b[is_election_year_pros]
        local s = _se[is_election_year_pros]
        local p = 2 * ttail(e(df_r), abs(`b'/`s'))
        file write `fh' "T0a,`y'," (`b') "," (`s') "," (`p') "," (e(N)) "," (e(N_clust)) _n
    }
}

* --- T0b: drop open seats + off-cycle counties, county FE only ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
local nb = _N
qui distinct county_id
local ncb = r(ndistinct)

foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        local b = _b[is_election_year_pros]
        local s = _se[is_election_year_pros]
        local p = 2 * ttail(e(df_r), abs(`b'/`s'))
        file write `fh' "T0b,`y'," (`b') "," (`s') "," (`p') "," (e(N)) "," (e(N_clust)) _n
    }
}

* --- T0c: full panel, open seat as regressor, county FE only ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
local nc = _N
qui distinct county_id
local ncc = r(ndistinct)

foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        local b = _b[is_election_year_pros]
        local s = _se[is_election_year_pros]
        local p = 2 * ttail(e(df_r), abs(`b'/`s'))
        file write `fh' "T0c,`y'," (`b') "," (`s') "," (`p') "," (e(N)) "," (e(N_clust)) _n
    }
}

* --- T0d: off-cycle dropped, open seat as regressor, county FE only ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
local nd = _N
qui distinct county_id
local ncd = r(ndistinct)

foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        local b = _b[is_election_year_pros]
        local s = _se[is_election_year_pros]
        local p = 2 * ttail(e(df_r), abs(`b'/`s'))
        file write `fh' "T0d,`y'," (`b') "," (`s') "," (`p') "," (e(N)) "," (e(N_clust)) _n
    }
}

* --- T0e: TWFE (county + year FE), open seats dropped ---
* This is the specification that WOULD be standard but is fragile here
* because within-year election timing variation comes from ~5 off-cycle counties only.
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1

foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        local b = _b[is_election_year_pros]
        local s = _se[is_election_year_pros]
        local p = 2 * ttail(e(df_r), abs(`b'/`s'))
        file write `fh' "T0e,`y'," (`b') "," (`s') "," (`p') "," (e(N)) "," (e(N_clust)) _n
    }
}

file close `fh'

* --- Now read the CSV and build the appendix table ---
preserve
import delimited using "`t0_results'", clear

local fa "$TAB_DIR/tableA1_t0_sensitivity.tex"
file open t using "`fa'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect: Sample Restriction Sensitivity}" _n
file write t "\label{tab:tableA1}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & (1) T0a & (2) T0b & (3) T0c & (4) T0d & (5) T0e \\"' _n
file write t "\midrule" _n

* Write outcome rows from the stored CSV data
local key_outcomes "actually_reported pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate total_jury_verdicts capital_felony other_felony other_cases pct_capital_felony pct_other_felony pct_other_cases"

foreach y of local key_outcomes {
    * Get values for each version
    foreach v in a b c d e {
        qui count if version == "T0`v'" & outcome == "`y'"
        if r(N) > 0 {
            qui summ beta if version == "T0`v'" & outcome == "`y'"
            local b_`v' = r(mean)
            qui summ se if version == "T0`v'" & outcome == "`y'"
            local se_`v' = r(mean)
            qui summ pval if version == "T0`v'" & outcome == "`y'"
            local p_`v' = r(mean)
        }
        else {
            local b_`v' = .
            local se_`v' = .
            local p_`v' = 1
        }

        * Stars
        local st_`v' ""
        if `p_`v'' < 0.01 local st_`v' "\sym{***}"
        else if `p_`v'' < 0.05 local st_`v' "\sym{**}"
        else if `p_`v'' < 0.10 local st_`v' "\sym{*}"

        * Format
        local is_rate = (strpos("`y'", "pct_") == 1 | "`y'" == "utilization_rate")
        if `is_rate' {
            local bf_`v' : di %7.3f `b_`v''
            local sf_`v' : di %7.3f `se_`v''
        }
        else {
            local bf_`v' : di %7.1f `b_`v''
            local sf_`v' : di %7.1f `se_`v''
        }
    }

    file write t "`lbl_`y'' & `=strtrim("`bf_a'")'`st_a' & `=strtrim("`bf_b'")'`st_b' & `=strtrim("`bf_c'")'`st_c' & `=strtrim("`bf_d'")'`st_d' & `=strtrim("`bf_e'")'`st_e' \\" _n
    file write t "  & (`=strtrim("`sf_a'")') & (`=strtrim("`sf_b'")') & (`=strtrim("`sf_c'")') & (`=strtrim("`sf_d'")') & (`=strtrim("`sf_e'")') \\" _n
}

file write t "\midrule" _n
file write t `"Open seats & Dropped & Dropped & Regressor & Regressor & Dropped \\"' _n
file write t `"Off-cycle counties & Included & Excluded & Included & Excluded & Included \\"' _n
file write t `"Fixed effects & County & County & County & County & County + Year \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item \textit{Notes.} Columns (1)--(4) use county FE only. Column (5) adds year FE (TWFE)."' _n
file write t `"\item Standard errors clustered at county level in parentheses."' _n
file write t `"\item (1) T0a: \(Y_{ct} = \beta \cdot \text{ElecYear}_{ct} + \alpha_c + \varepsilon_{ct}\), open-seat obs dropped."' _n
file write t `"\item (2) T0b: Same as T0a, additionally excluding 6 off-cycle election counties"' _n
file write t `"  (Allegan, Delta, Isabella, Newaygo, Osceola, Roscommon)."' _n
file write t `"\item (3) T0c: \(Y_{ct} = \beta_1 \cdot \text{ElecYear}_{ct} + \beta_2 \cdot \text{OpenSeat}_{ct} + \alpha_c + \varepsilon_{ct}\),"' _n
file write t `"  full panel. Reports \(\beta_1\) only."' _n
file write t `"\item (4) T0d: Same as T0c, excluding 6 off-cycle counties."' _n
file write t `"\item (5) T0e: \(Y_{ct} = \beta \cdot \text{ElecYear}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}\),"' _n
file write t `"  TWFE with year FE. Identified primarily from \(\sim\)5 off-cycle counties in 2018."' _n
file write t `"  Sign instability relative to (1)--(4) reflects limited within-year variation at the"' _n
file write t `"  election-year level, motivating the contestation decomposition (Table~\ref{tab:table2})."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore

di "Table A1 (T0 appendix with T0e) DONE: `fa'"


* =============================================================================
* TABLE 2 — T2: CONTESTATION (MAIN RESULT)
*   Y = β1*Contested + β2*Uncontested + county FE + year FE + ε
*   Full B, open seats dropped. N=553.
*   Reports β1, β2, AND Δ = β1 - β2 via lincom.
* =============================================================================

di _n "{hline 72}"
di "TABLE 2: T2 CONTESTATION — MAIN RESULT"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
di "T2 sample (open seats dropped): " _N

eststo clear
local i = 1
foreach y of local dvs_main {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo t2_`i'

    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : t2_`i'
    estadd scalar delta_se = r(se) : t2_`i'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t2_`i'

    local ++i
}

esttab t2_* using "$TAB_DIR/table2_contestation.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Reported" "\% Told to Report" "Utilization" "Jury Verdicts" "\% Other Felony") ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$ (Contested $-$ Uncontested)" ///
            "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("SEs clustered at county level in parentheses." ///
             "County and year FE. Open-seat county-years excluded." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "Omitted: non-election years." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 2 DONE"


* =============================================================================
* TABLE 3 — T2: OUTCOME BREAKDOWN (ALL FAMILIES)
*   Same T2 spec, all outcomes paneled.
*   Panel A: Pipeline  Panel B: Verdicts  Panel C: Composition
* =============================================================================

di _n "{hline 72}"
di "TABLE 3: T2 OUTCOME BREAKDOWN"
di "{hline 72}"

* Same sample already loaded (open seats dropped)

local panA "actually_reported pct_told_to_report utilization_rate"
local panB "total_jury_verdicts capital_felony other_felony other_cases"
local panC "pct_capital_felony pct_other_felony pct_other_cases"

eststo clear
local i = 1
foreach y in `panA' `panB' `panC' {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo t3_`i'

    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : t3_`i'
    estadd scalar delta_se = r(se) : t3_`i'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t3_`i'

    local ++i
}

* Write contested coefficients
esttab t3_* using "$TAB_DIR/table3_outcomes.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Rep." "\% Told" "Util." "Verdicts" "Capital" "Other Fel." "Other Cases" "\% Cap." "\% Oth.Fel." "\% Oth.Cases") ///
    mgroups("Panel A: Pipeline" "Panel B: Verdicts" "Panel C: Composition", ///
        pattern(1 0 0 1 0 0 0 1 0 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("SEs clustered at county level. County and year FE. Open seats excluded." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 3 DONE"


* =============================================================================
* TABLE 4 — T2: HETEROGENEITY BY POPULATION
*   Panel A: Above-median    Panel B: Below-median
*   Each panel: Contested, Uncontested, Δ
* =============================================================================

di _n "{hline 72}"
di "TABLE 4: T2 HETEROGENEITY"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1

qui su county_pop, detail
local med = r(p50)
gen byte highpop = (county_pop >= `med')

* Panel A: High pop
eststo clear
preserve
    keep if highpop == 1
    di "High-pop: " _N

    local i = 1
    foreach y of local dvs_main {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo t4a_`i'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : t4a_`i'
        estadd scalar delta_se = r(se) : t4a_`i'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t4a_`i'
        local ++i
    }
restore

esttab t4a_* using "$TAB_DIR/table4a_het_highpop.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Rep." "\% Told" "Utilization" "Verdicts" "\% Other Fel.") ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("Panel A: Above-median population counties." ///
             "SEs clustered at county level. County and year FE. Open seats excluded." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear

* Panel B: Low pop
preserve
    keep if highpop == 0
    di "Low-pop: " _N

    local i = 1
    foreach y of local dvs_main {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo t4b_`i'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : t4b_`i'
        estadd scalar delta_se = r(se) : t4b_`i'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t4b_`i'
        local ++i
    }
restore

esttab t4b_* using "$TAB_DIR/table4b_het_lowpop.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Jurors Rep." "\% Told" "Utilization" "Verdicts" "\% Other Fel.") ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("Panel B: Below-median population counties." ///
             "SEs clustered at county level. County and year FE. Open seats excluded." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 4 DONE"


* =============================================================================
* TABLE 5 — T2: CONTAMINATION SENSITIVITY
*   Col 1-2: Open-seat YEAR only dropped (baseline)
*   Col 3-4: Open-seat year + t-1 dropped (stricter)
*   DVs: actually_reported, total_jury_verdicts
*   Each shows Contested, Uncontested, Δ
* =============================================================================

di _n "{hline 72}"
di "TABLE 5: CONTAMINATION SENSITIVITY"
di "{hline 72}"

* Variant A: drop open-seat year only (already our baseline)
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1
di "Variant A (open year dropped): " _N

eststo clear
foreach y in actually_reported total_jury_verdicts {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo t5a_`y'
    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : t5a_`y'
    estadd scalar delta_se = r(se) : t5a_`y'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t5a_`y'
}

* Variant B: drop open-seat year + t-1 for those counties
use "$DATA_FINAL/michigan_panel_B.dta", clear

* For each county with open_pros==1, also drop year-1
gen _drop = 0
replace _drop = 1 if open_pros == 1

* Get list of open-seat county-years and mark t-1
* county is string — use county not county_id for levelsof
qui levelsof county if open_pros == 1, local(opcounties) clean
foreach c of local opcounties {
    qui levelsof year if county == "`c'" & open_pros == 1, local(oyears)
    foreach yr of local oyears {
        local prior = `yr' - 1
        replace _drop = 1 if county == "`c'" & year == `prior'
    }
}

drop if _drop == 1
drop _drop
di "Variant B (open year + t-1 dropped): " _N

foreach y in actually_reported total_jury_verdicts {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo t5b_`y'
    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : t5b_`y'
    estadd scalar delta_se = r(se) : t5b_`y'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t5b_`y'
}

esttab t5a_actually_reported t5b_actually_reported t5a_total_jury_verdicts t5b_total_jury_verdicts ///
    using "$TAB_DIR/table5_contamination.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Open Yr Only" "Open Yr + t$-$1" "Open Yr Only" "Open Yr + t$-$1") ///
    mgroups("Jurors Actually Reported" "Total Jury Verdicts", ///
        pattern(1 0 1 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("Contamination sensitivity: open-seat year only vs.\ open-seat year + prior year." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "County and year FE. SEs clustered at county level." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 5 DONE"


* =============================================================================
* TABLE 6 — ROBUSTNESS: T2 ACROSS SAMPLE VARIANTS
*   Rows: Contested, Uncontested, Δ
*   Cols: Full B / No 2016 / No 2024
*   DVs: actually_reported, total_jury_verdicts
* =============================================================================

di _n "{hline 72}"
di "TABLE 6: ROBUSTNESS"
di "{hline 72}"

* Full B (open seats dropped) — already baseline
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1

eststo clear
foreach y in actually_reported total_jury_verdicts {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo r_full_`y'
    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : r_full_`y'
    estadd scalar delta_se = r(se) : r_full_`y'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : r_full_`y'
}

* No 2016
preserve
    drop if year == 2016
    foreach y in actually_reported total_jury_verdicts {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo r_no16_`y'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : r_no16_`y'
        estadd scalar delta_se = r(se) : r_no16_`y'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : r_no16_`y'
    }
restore

* No 2024
preserve
    drop if year == 2024
    foreach y in actually_reported total_jury_verdicts {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo r_no24_`y'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : r_no24_`y'
        estadd scalar delta_se = r(se) : r_no24_`y'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : r_no24_`y'
    }
restore

esttab r_full_actually_reported r_no16_actually_reported r_no24_actually_reported ///
    r_full_total_jury_verdicts r_no16_total_jury_verdicts r_no24_total_jury_verdicts ///
    using "$TAB_DIR/table6_robustness.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Full" "No 2016" "No 2024" "Full" "No 2016" "No 2024") ///
    mgroups("Jurors Actually Reported" "Total Jury Verdicts", ///
        pattern(1 0 0 1 0 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("Open-seat county-years excluded. County and year FE." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 6 DONE"


* =============================================================================
* TABLE 7 — COMPOSITION / PLEA DETAIL (T2)
*   Panel A: Verdict composition    Panel B: FC plea    Panel C: FH plea
* =============================================================================

di _n "{hline 72}"
di "TABLE 7: COMPOSITION DETAIL"
di "{hline 72}"

* Panel A: Verdict composition
use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1

eststo clear
local i = 1
foreach y in pct_capital_felony pct_other_felony pct_other_cases {
    qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    eststo t7a_`i'
    qui lincom treat_pros_contested_long - treat_pros_uncontested
    estadd scalar delta_b = r(estimate) : t7a_`i'
    estadd scalar delta_se = r(se) : t7a_`i'
    estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t7a_`i'
    local ++i
}

* Panel B: FC plea
preserve
    import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", clear varnames(1) encoding("UTF-8")
    keep if inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
    gen action_var = cond(action_name == "Jury Verdict", "jury", cond(action_name == "Bench Verdict", "bench", "plea"))
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
    keep if regexm(case_type, "^FC ")
    collapse (sum) jury_only plea_total trial_total resolved, by(county year)
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0
    merge m:1 county year using "$DATA_FINAL/michigan_panel_B.dta", ///
        keepusing(county_id treat_pros_contested_long treat_pros_uncontested open_pros) keep(match) nogen
    drop if open_pros == 1

    local i = 1
    foreach y in plea_share jury_share {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo t7b_`i'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : t7b_`i'
        estadd scalar delta_se = r(se) : t7b_`i'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t7b_`i'
        local ++i
    }
restore

* Panel C: FH plea
preserve
    import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", clear varnames(1) encoding("UTF-8")
    keep if inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
    gen action_var = cond(action_name == "Jury Verdict", "jury", cond(action_name == "Bench Verdict", "bench", "plea"))
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
    keep if !regexm(case_type, "^FC ")
    collapse (sum) jury_only plea_total trial_total resolved, by(county year)
    gen plea_share = plea_total / resolved if resolved > 0
    gen jury_share = jury_only / resolved if resolved > 0
    merge m:1 county year using "$DATA_FINAL/michigan_panel_B.dta", ///
        keepusing(county_id treat_pros_contested_long treat_pros_uncontested open_pros) keep(match) nogen
    drop if open_pros == 1

    local i = 1
    foreach y in plea_share jury_share {
        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        eststo t7c_`i'
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        estadd scalar delta_b = r(estimate) : t7c_`i'
        estadd scalar delta_se = r(se) : t7c_`i'
        estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t7c_`i'
        local ++i
    }
restore

esttab t7a_1 t7a_2 t7a_3 t7b_1 t7b_2 t7c_1 t7c_2 ///
    using "$TAB_DIR/table7_composition.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("\% Cap." "\% Oth.Fel." "\% Oth.Cases" "FC Plea" "FC Jury" "FH Plea" "FH Jury") ///
    mgroups("Verdict Composition" "FC Plea (Circuit)" "FH Plea (Circuit)", ///
        pattern(1 0 0 1 0 1 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("SEs clustered at county level. County and year FE. Open seats excluded." ///
             "Verdict composition: SCAO jury data. Plea: SCAO outgoing caseload (circuit)." ///
             "FC = Capital Felony. FH = Non-capital Felony." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 7 DONE"


* =============================================================================
* TABLE 8 — FALSIFICATION
*   Col 1: Incoming felonies as DV (T2)
*   Col 2: Main result with log(pending) control (T2)
* =============================================================================

di _n "{hline 72}"
di "TABLE 8: FALSIFICATION"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B.dta", clear
drop if open_pros == 1

merge m:1 county year using "$DATA_INT/mi_caseload_panel.dta", ///
    keepusing(incoming_felony log_pending) keep(match master) nogen

eststo clear

qui reghdfe incoming_felony treat_pros_contested_long treat_pros_uncontested, ///
    absorb(county_id year) vce(cluster county_id)
eststo t8_1
qui lincom treat_pros_contested_long - treat_pros_uncontested
estadd scalar delta_b = r(estimate) : t8_1
estadd scalar delta_se = r(se) : t8_1
estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t8_1

qui reghdfe total_jury_verdicts treat_pros_contested_long treat_pros_uncontested log_pending, ///
    absorb(county_id year) vce(cluster county_id)
eststo t8_2
qui lincom treat_pros_contested_long - treat_pros_uncontested
estadd scalar delta_b = r(estimate) : t8_2
estadd scalar delta_se = r(se) : t8_2
estadd scalar delta_p = 2 * ttail(e(df_r), abs(r(estimate)/r(se))) : t8_2

esttab t8_1 t8_2 using "$TAB_DIR/table8_falsification.tex", ///
    replace booktabs alignment(D{.}{.}{-1}) ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("Incoming Felonies" "Jury Verdicts (+ caseload ctrl)") ///
    keep(treat_pros_contested_long treat_pros_uncontested) ///
    coeflabels(treat_pros_contested_long "Contested" treat_pros_uncontested "Uncontested") ///
    scalars("delta_b $\Delta$" "delta_se SE($\Delta$)" "delta_p $p(\Delta)$" ///
            "N Observations" "N_clust Counties") ///
    sfmt(3 3 3 0 0) ///
    label nonotes noobs ///
    addnotes("Col 1: incoming felony caseload as DV (falsification)." ///
             "Col 2: jury verdicts with log(pending felonies) control." ///
             "County and year FE. Open seats excluded." ///
             "$\Delta$ = Contested $-$ Uncontested via \texttt{lincom}." ///
             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")

eststo clear
di "Table 8 DONE"


* =============================================================================
di _n "{hline 72}"
di "ALL 8 TABLES GENERATED"
di "Output: $TAB_DIR"
di "{hline 72}"
dir "$TAB_DIR/*.tex"
di _n "Finished: $S_DATE $S_TIME"
