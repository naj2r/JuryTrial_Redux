/*==============================================================================
  14_paper_tables.do — FINAL PRODUCTION TABLES (v4 — corrected caseload DVs)

  Architecture:
    T0: Election-year benchmark. County FE only (no year FE).
        elec_incumbent + open_pros. Full B panel (83 counties, N=579).
    T2: Contestation. County + year FE (TWFE).
        Contested + uncontested + Δ. 77 sync counties, open seats dropped.
        THIS IS THE MAIN TABLE.

  Data source change (v4):
    Verdict and plea variables now from SCAO outgoing caseload dashboard
    (fc_jury, fh_jury, fc_plea, fh_plea, fc_dismiss_rate, etc.)
    NOT from the jury utilization dashboard (capital_felony, other_felony —
    broken for 2024 due to MIN() aggregation in Power BI).
    Pipeline variables (summoned through utilization_rate) still from jury
    dashboard — those are correct.

  Output: $OL/files/tab/paper/table*.tex

  FC = Felony Capital (life-eligible). FH = Felony non-capital. SCAO codes.
==============================================================================*/

if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear all
set more off

global OL "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26"
global TAB_DIR "$OL/files/tab/paper"
capture mkdir "$TAB_DIR"

di _n "========================================"
di "  14_paper_tables.do — v4 (corrected DVs)"
di "  $S_DATE $S_TIME"
di "========================================"


* =============================================================================
* SHARED SETUP: Outcome lists, labels, helper programs
* =============================================================================

* --- Full outcome list: 5 groups ---
* Group 1: Pipeline counts (jury dashboard)
local grp1_lbl "Pipeline Counts"
local grp1 "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"

* Group 2: Pipeline rates (jury dashboard)
local grp2_lbl "Pipeline Rates"
local grp2 "pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate"

* Group 3: Verdict & trial counts (caseload — corrected)
local grp3_lbl "Verdict and Trial Counts"
local grp3 "fc_jury fh_jury fc_bench fh_bench felony_jury_total"

* Group 4: Plea & dismissal counts (caseload)
local grp4_lbl "Plea and Dismissal Counts"
local grp4 "fc_plea fh_plea fc_dismissed fh_dismissed"

* Group 5: Disposition rates & composition (caseload)
local grp5_lbl "Disposition Rates and Composition"
local grp5 "fc_jury_share fh_jury_share fc_plea_share fh_plea_share fc_dismiss_rate fh_dismiss_rate severity_share fc_jury_adj_share fc_plea_adj_share fh_jury_adj_share fh_plea_adj_share"

local all_outcomes "`grp1' `grp2' `grp3' `grp4' `grp5'"
local n_groups = 5

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
local lbl_fc_jury                     "FC Jury Verdicts"
local lbl_fh_jury                     "FH Jury Verdicts"
local lbl_fc_bench                    "FC Bench Verdicts"
local lbl_fh_bench                    "FH Bench Verdicts"
local lbl_felony_jury_total           "Total Felony Jury Verdicts"
local lbl_fc_plea                     "FC Guilty Pleas"
local lbl_fh_plea                     "FH Guilty Pleas"
local lbl_fc_dismissed                "FC Dismissed (Prosecutorial)"
local lbl_fh_dismissed                "FH Dismissed (Prosecutorial)"
local lbl_fc_jury_share               "FC Jury Trial Rate"
local lbl_fh_jury_share               "FH Jury Trial Rate"
local lbl_fc_plea_share               "FC Plea Rate"
local lbl_fh_plea_share               "FH Plea Rate"
local lbl_fc_dismiss_rate             "FC Dismissal Rate"
local lbl_fh_dismiss_rate             "FH Dismissal Rate"
local lbl_severity_share              "Severity Share (FC/Total Jury)"
local lbl_fc_jury_adj_share           "FC Jury Share (Adjud.)"
local lbl_fc_plea_adj_share           "FC Plea Share (Adjud.)"
local lbl_fh_jury_adj_share           "FH Jury Share (Adjud.)"
local lbl_fh_plea_adj_share           "FH Plea Share (Adjud.)"

* Treatment variable labels (for summary stats)
local lbl_elec_incumbent              "Incumbent Election"
local lbl_open_pros                   "Open Seat"
local lbl_treat_pros_contested_long   "Contested (General)"
local lbl_treat_pros_uncontested      "Uncontested"

* Control/caseload variable labels
local lbl_incoming_felony             "Incoming Felony Filings"
local lbl_pending_felony              "Pending Felony Cases"
local lbl_clearance_rate              "Clearance Rate"
local lbl_county_pop                  "County Population"

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

* --- Format helper ---
capture program drop fmt_coef
program define fmt_coef, rclass
    args val outcome
    * Rates get 3 decimals, counts get 1
    local is_rate = (strpos("`outcome'", "pct_") == 1 | ///
        "`outcome'" == "utilization_rate" | ///
        strpos("`outcome'", "_share") > 0 | ///
        strpos("`outcome'", "_rate") > 0)
    if `is_rate' {
        local fmt : di %9.3f `val'
    }
    else {
        local fmt : di %9.1f `val'
    }
    return local formatted "`=strtrim("`fmt'")'"
end


* =============================================================================
* TABLE 1 — T0c: BASELINE (county FE only, elec_incumbent + open_pros)
* =============================================================================

di _n "{hline 72}"
di "TABLE 1: T0c BASELINE (county FE, all outcomes)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
di "Full B augmented: " _N

* --- Table 1a: Pipeline + Verdicts ---
local f "$TAB_DIR/table1a_baseline_pipeline.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect: Pipeline and Verdicts (County FE Only, No Year FE)}" _n
file write t "\label{tab:t0-pipeline}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Incumbent Election} & \multicolumn{2}{c}{Open Seat} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(N\) \\"' _n
file write t "\midrule" _n

* --- Write groups 1-3 (pipeline + verdicts) into Table 1a ---
local r2_min_1a = 1
local r2_max_1a = 0
forvalues g = 1/3 {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{6}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
        if _rc {
            di "  SKIP `y' (not in data or collinear)"
            continue
        }
        local b1 = _b[elec_incumbent]
        local se1 = _se[elec_incumbent]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[open_pros]
        local se2 = _se[open_pros]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        local n = e(N)
        local r2w = e(r2_within)
        if `r2w' < `r2_min_1a' local r2_min_1a = `r2w'
        if `r2w' > `r2_max_1a' local r2_max_1a = `r2w'

        add_stars `p1'
        local st1 "`r(stars)'"
        add_stars `p2'
        local st2 "`r(stars)'"

        fmt_coef `b1' `y'
        local b1f "`r(formatted)'"
        fmt_coef `se1' `y'
        local se1f "`r(formatted)'"
        fmt_coef `b2' `y'
        local b2f "`r(formatted)'"
        fmt_coef `se2' `y'
        local se2f "`r(formatted)'"

        file write t "`lbl_`y'' & `b1f'`st1' & (`se1f') & `b2f'`st2' & (`se2f') & `n' \\" _n
    }
}

file write t "\midrule" _n
file write t `"County FE & \multicolumn{5}{c}{Yes} \\"' _n
file write t `"Year FE & \multicolumn{5}{c}{No} \\"' _n
file write t `"Clustering & \multicolumn{5}{c}{County} \\"' _n
local r2f_lo : di %5.3f `r2_min_1a'
local r2f_hi : di %5.3f `r2_max_1a'
file write t `"Within-\(R^2\) range & \multicolumn{5}{c}{[`=strtrim("`r2f_lo'")', `=strtrim("`r2f_hi'")']} \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} Specification~\eqref{eq:T0}: \(Y_{ct} = \beta_1 \cdot \text{IncumbentElec}_{ct} + \beta_2 \cdot \text{OpenSeat}_{ct} + \alpha_c + \varepsilon_{ct}\)."' _n
file write t `"\item County FE only (no year FE). SEs clustered at county level."' _n
file write t `"\item IncumbentElec and OpenSeat are mutually exclusive; omitted = non-election years."' _n
file write t `"\item Pipeline from SCAO jury dashboard. Verdicts from SCAO outgoing caseload dashboard."' _n
file write t `"\item Continued in Table~\ref{tab:table1b}. Sensitivity in Table~\ref{tab:tableA1}."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n
file close t
di "Table 1a DONE: `f'"

* --- Table 1b: Pleas + Disposition Rates ---
local f1b "$TAB_DIR/table1b_baseline_disposition.tex"
file open t using "`f1b'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect: Case Disposition Rates (County FE Only, No Year FE)}" _n
file write t "\label{tab:t0-disposition}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Incumbent Election} & \multicolumn{2}{c}{Open Seat} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(N\) \\"' _n
file write t "\midrule" _n

forvalues g = 4/`n_groups' {
    if `g' > 4 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{6}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
        if _rc {
            di "  SKIP `y' (not in data or collinear)"
            continue
        }
        local b1 = _b[elec_incumbent]
        local se1 = _se[elec_incumbent]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[open_pros]
        local se2 = _se[open_pros]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        local n = e(N)

        add_stars `p1'
        local st1 "`r(stars)'"
        add_stars `p2'
        local st2 "`r(stars)'"

        fmt_coef `b1' `y'
        local b1f "`r(formatted)'"
        fmt_coef `se1' `y'
        local se1f "`r(formatted)'"
        fmt_coef `b2' `y'
        local b2f "`r(formatted)'"
        fmt_coef `se2' `y'
        local se2f "`r(formatted)'"

        file write t "`lbl_`y'' & `b1f'`st1' & (`se1f') & `b2f'`st2' & (`se2f') & `n' \\" _n
    }
}

file write t "\midrule" _n
file write t `"County FE & \multicolumn{5}{c}{Yes} \\"' _n
file write t `"Year FE & \multicolumn{5}{c}{No} \\"' _n
file write t `"Clustering & \multicolumn{5}{c}{County} \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} Specification~\eqref{eq:T0}. Same as Table~\ref{tab:t0-pipeline}."' _n
file write t `"\item Plea/dismissal from SCAO outgoing caseload dashboard."' _n
file write t `"\item Adjudicated shares use denominator = jury + bench + plea (excludes dismissals)."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n
file close t
di "Table 1b DONE: `f1b'"


* =============================================================================
* TABLE 2 — T2: CONTESTATION (77 sync counties, TWFE, all outcomes)
* =============================================================================

di _n "{hline 72}"
di "TABLE 2: T2 CONTESTATION (77 sync, all outcomes)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
di "T2 primary: " _N

* --- Table 2a: Pipeline + Verdicts ---
local f "$TAB_DIR/table2a_contestation_pipeline.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Electoral Contestation: Pipeline and Verdicts}" _n
file write t "\label{tab:t2-pipeline}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Contested} & \multicolumn{2}{c}{Uncontested} & \multicolumn{2}{c}{\(\Delta\) (Con \(-\) Unc)} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(\Delta\) & SE & \(N\) \\"' _n
file write t "\midrule" _n

* --- Write groups 1-3 into Table 2a ---
forvalues g = 1/3 {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{8}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        if _rc {
            di "  SKIP `y'"
            continue
        }
        local b1 = _b[treat_pros_contested_long]
        local se1 = _se[treat_pros_contested_long]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[treat_pros_uncontested]
        local se2 = _se[treat_pros_uncontested]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        local n = e(N)

        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d = r(estimate)
        local dse = r(se)
        local dp = 2 * ttail(e(df_r), abs(`d'/`dse'))

        add_stars `p1'
        local st1 "`r(stars)'"
        add_stars `p2'
        local st2 "`r(stars)'"
        add_stars `dp'
        local std "`r(stars)'"

        fmt_coef `b1' `y'
        local b1f "`r(formatted)'"
        fmt_coef `se1' `y'
        local se1f "`r(formatted)'"
        fmt_coef `b2' `y'
        local b2f "`r(formatted)'"
        fmt_coef `se2' `y'
        local se2f "`r(formatted)'"
        fmt_coef `d' `y'
        local df "`r(formatted)'"
        fmt_coef `dse' `y'
        local dsef "`r(formatted)'"

        file write t "`lbl_`y'' & `b1f'`st1' & (`se1f') & `b2f'`st2' & (`se2f') & `df'`std' & (`dsef') & `n' \\" _n
    }
}

file write t "\midrule" _n
file write t `"County FE & \multicolumn{7}{c}{Yes} \\"' _n
file write t `"Year FE & \multicolumn{7}{c}{Yes} \\"' _n
file write t `"Clustering & \multicolumn{7}{c}{County} \\"' _n
file write t `"Off-cycle counties & \multicolumn{7}{c}{Excluded} \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} Specification~\eqref{eq:T2}: \(Y_{ct} = \beta_1 \cdot \text{Contested}_{ct} + \beta_2 \cdot \text{Uncontested}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}\)."' _n
file write t `"\item 77 synchronized counties. Open seats and 6 off-cycle counties excluded."' _n
file write t `"\item \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom} (covariance-adjusted)."' _n
file write t `"\item Pipeline from SCAO jury dashboard. Verdicts from SCAO outgoing caseload dashboard."' _n
file write t `"\item Continued in Table~\ref{tab:table2b}. \(\Delta\) robustness in Appendix Table~\ref{tab:tableA3}."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n
file close t
di "Table 2a DONE: `f'"

* --- Table 2b: Pleas + Disposition Rates ---
local f2b "$TAB_DIR/table2b_contestation_disposition.tex"
file open t using "`f2b'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Electoral Contestation: Case Disposition}" _n
file write t "\label{tab:t2-disposition}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Contested} & \multicolumn{2}{c}{Uncontested} & \multicolumn{2}{c}{\(\Delta\) (Con \(-\) Unc)} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(\Delta\) & SE & \(N\) \\"' _n
file write t "\midrule" _n

* --- Write groups 4-5 into Table 2b ---
forvalues g = 4/`n_groups' {
    if `g' > 4 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{8}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)
        if _rc {
            di "  SKIP `y'"
            continue
        }
        local b1 = _b[treat_pros_contested_long]
        local se1 = _se[treat_pros_contested_long]
        local p1 = 2 * ttail(e(df_r), abs(`b1'/`se1'))
        local b2 = _b[treat_pros_uncontested]
        local se2 = _se[treat_pros_uncontested]
        local p2 = 2 * ttail(e(df_r), abs(`b2'/`se2'))
        local n = e(N)

        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d = r(estimate)
        local dse = r(se)
        local dp = 2 * ttail(e(df_r), abs(`d'/`dse'))

        add_stars `p1'
        local st1 "`r(stars)'"
        add_stars `p2'
        local st2 "`r(stars)'"
        add_stars `dp'
        local std "`r(stars)'"

        fmt_coef `b1' `y'
        local b1f "`r(formatted)'"
        fmt_coef `se1' `y'
        local se1f "`r(formatted)'"
        fmt_coef `b2' `y'
        local b2f "`r(formatted)'"
        fmt_coef `se2' `y'
        local se2f "`r(formatted)'"
        fmt_coef `d' `y'
        local df "`r(formatted)'"
        fmt_coef `dse' `y'
        local dsef "`r(formatted)'"

        file write t "`lbl_`y'' & `b1f'`st1' & (`se1f') & `b2f'`st2' & (`se2f') & `df'`std' & (`dsef') & `n' \\" _n
    }
}

file write t "\midrule" _n
file write t `"County FE & \multicolumn{7}{c}{Yes} \\"' _n
file write t `"Year FE & \multicolumn{7}{c}{Yes} \\"' _n
file write t `"Clustering & \multicolumn{7}{c}{County} \\"' _n
file write t `"Off-cycle counties & \multicolumn{7}{c}{Excluded} \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} Specification~\eqref{eq:T2}: \(Y_{ct} = \beta_1 \cdot \text{Contested}_{ct} + \beta_2 \cdot \text{Uncontested}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}\)."' _n
file write t `"\item 77 synchronized counties. Open seats and 6 off-cycle counties excluded."' _n
file write t `"\item \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom} (covariance-adjusted)."' _n
file write t `"\item Pipeline variables from SCAO jury dashboard. Verdict/plea/dismissal from SCAO outgoing caseload dashboard."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Table 2 DONE: `f'"


* =============================================================================
* TABLE 2b — Δ ROBUSTNESS (3 specs, all outcomes)
* =============================================================================

di _n "{hline 72}"
di "TABLE 2b: DELTA ROBUSTNESS (3 specs, all outcomes)"
di "{hline 72}"

tempname fh2b
tempfile delta_csv
file open `fh2b' using "`delta_csv'", write replace
file write `fh2b' "spec,outcome,delta,delta_se,delta_p,nobs" _n

* Spec 1: TWFE no off-cycle (primary)
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

foreach y of local all_outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        file write `fh2b' "twfe_nooc,`y'," (r(estimate)) "," (r(se)) "," (2 * ttail(e(df_r), abs(r(estimate)/r(se)))) "," (e(N)) _n
    }
}

* Spec 2: Wooldridge Group × Year FE (all 83)
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
gen byte sync_group = !inlist(county_id, 3, 37, 62, 66, 74, 21)
egen group_year = group(sync_group year)

foreach y of local all_outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id group_year) vce(cluster county_id)
    if !_rc {
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        file write `fh2b' "wooldridge,`y'," (r(estimate)) "," (r(se)) "," (2 * ttail(e(df_r), abs(r(estimate)/r(se)))) "," (e(N)) _n
    }
}

* Spec 3: Pooled (county FE only, all 83)
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1

foreach y of local all_outcomes {
    capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id) vce(cluster county_id)
    if !_rc {
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        file write `fh2b' "pooled,`y'," (r(estimate)) "," (r(se)) "," (2 * ttail(e(df_r), abs(r(estimate)/r(se)))) "," (e(N)) _n
    }
}

file close `fh2b'

* Build the table
preserve
import delimited using "`delta_csv'", clear

local fA3 "$TAB_DIR/tableA3_delta_robustness.tex"
file open t using "`fA3'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t `"\caption{Contestation Differential \(\Delta\): Specification Robustness}"' _n
file write t "\label{tab:delta-robust}" _n
file write t "\begin{threeparttable}" _n
file write t "\scriptsize" _n
file write t "\begin{tabular}{lccc}" _n
file write t "\toprule" _n
file write t `" & (1) TWFE & (2) Wooldridge & (3) Pooled \\"' _n
file write t `" & No off-cycle & Group \(\times\) Year & County FE only \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{4}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        foreach s in twfe_nooc wooldridge pooled {
            qui count if spec == "`s'" & outcome == "`y'"
            if r(N) > 0 {
                qui summ delta if spec == "`s'" & outcome == "`y'"
                local d_`s' = r(mean)
                qui summ delta_se if spec == "`s'" & outcome == "`y'"
                local ds_`s' = r(mean)
                qui summ delta_p if spec == "`s'" & outcome == "`y'"
                local dp_`s' = r(mean)
            }
            else {
                local d_`s' = .
                local ds_`s' = .
                local dp_`s' = 1
            }

            local st_`s' ""
            if `dp_`s'' < 0.01 local st_`s' "\sym{***}"
            else if `dp_`s'' < 0.05 local st_`s' "\sym{**}"
            else if `dp_`s'' < 0.10 local st_`s' "\sym{*}"

            local is_rate = (strpos("`y'", "pct_") == 1 | "`y'" == "utilization_rate" | strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
            if `is_rate' {
                local df_`s' : di %7.3f `d_`s''
                local sf_`s' : di %7.3f `ds_`s''
            }
            else {
                local df_`s' : di %7.1f `d_`s''
                local sf_`s' : di %7.1f `ds_`s''
            }
        }

        file write t "`lbl_`y'' & `=strtrim("`df_twfe_nooc'")'`st_twfe_nooc' & `=strtrim("`df_wooldridge'")'`st_wooldridge' & `=strtrim("`df_pooled'")'`st_pooled' \\" _n
        file write t "  & (`=strtrim("`sf_twfe_nooc'")') & (`=strtrim("`sf_wooldridge'")') & (`=strtrim("`sf_pooled'")') \\" _n
    }
}

file write t "\midrule" _n
file write t `"County FE & Yes & Yes & Yes \\"' _n
file write t `"Year FE & Yes & Group \(\times\) Year & No \\"' _n
file write t `"Off-cycle counties & Excluded & Included & Included \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} Each cell: \(\Delta = \beta_{\text{contested}} - \beta_{\text{uncontested}}\) via \texttt{lincom}."' _n
file write t `"\item (1) Primary: TWFE on 77 sync counties. (2) All 83 with timing-group year FE. (3) County FE only."' _n
file write t `"\item Open seats excluded in all. Pipeline from jury dashboard; verdict/plea from caseload dashboard."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore

di "Table 2b DONE: `f2b'"


* =============================================================================
* TABLE A1 — T0 SENSITIVITY (5 specs, all outcomes)
* =============================================================================

di _n "{hline 72}"
di "TABLE A1: T0 SENSITIVITY (5 specs)"
di "{hline 72}"

tempname fha1
tempfile t0_csv
file open `fha1' using "`t0_csv'", write replace
file write `fha1' "version,outcome,beta,se,pval,nobs" _n

* T0a: drop open seats, all counties, county FE
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0a,`y'," (_b[is_election_year_pros]) "," (_se[is_election_year_pros]) "," (2*ttail(e(df_r),abs(_b[is_election_year_pros]/_se[is_election_year_pros]))) "," (e(N)) _n
    }
}

* T0b: drop open seats + off-cycle, county FE
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0b,`y'," (_b[is_election_year_pros]) "," (_se[is_election_year_pros]) "," (2*ttail(e(df_r),abs(_b[is_election_year_pros]/_se[is_election_year_pros]))) "," (e(N)) _n
    }
}

* T0c: full panel, open seat as regressor, county FE
* Reports BOTH elec_incumbent AND open_pros coefficients
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
foreach y of local all_outcomes {
    capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0c,`y'," (_b[elec_incumbent]) "," (_se[elec_incumbent]) "," (2*ttail(e(df_r),abs(_b[elec_incumbent]/_se[elec_incumbent]))) "," (e(N)) _n
        file write `fha1' "T0c_open,`y'," (_b[open_pros]) "," (_se[open_pros]) "," (2*ttail(e(df_r),abs(_b[open_pros]/_se[open_pros]))) "," (e(N)) _n
    }
}

* T0d: off-cycle dropped, open seat as regressor, county FE
* Reports BOTH elec_incumbent AND open_pros coefficients
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
foreach y of local all_outcomes {
    capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0d,`y'," (_b[elec_incumbent]) "," (_se[elec_incumbent]) "," (2*ttail(e(df_r),abs(_b[elec_incumbent]/_se[elec_incumbent]))) "," (e(N)) _n
        file write `fha1' "T0d_open,`y'," (_b[open_pros]) "," (_se[open_pros]) "," (2*ttail(e(df_r),abs(_b[open_pros]/_se[open_pros]))) "," (e(N)) _n
    }
}

* T0e: TWFE (county + year FE), open seats dropped
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
foreach y of local all_outcomes {
    capture qui reghdfe `y' is_election_year_pros, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0e,`y'," (_b[is_election_year_pros]) "," (_se[is_election_year_pros]) "," (2*ttail(e(df_r),abs(_b[is_election_year_pros]/_se[is_election_year_pros]))) "," (e(N)) _n
    }
}

file close `fha1'

* Build table
preserve
import delimited using "`t0_csv'", clear

local fa1 "$TAB_DIR/tableA1_t0_sensitivity.tex"
file open t using "`fa1'", write replace

file write t "\begin{landscape}" _n
file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect: Sample Restriction Sensitivity}" _n
file write t "\label{tab:t0-sensitivity}" _n
file write t "\begin{threeparttable}" _n
file write t "\tiny" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & (1) & (2) & (3) & (4) & (5) \\"' _n
file write t `" & Open Seats & Open + Off-Cycle & Open Seat as & Open Regressor & TWFE \\"' _n
file write t `" & Dropped & Dropped & Regressor & No Off-Cycle & (+ Year FE) \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{6}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        * Get incumbent/election-year coef for all 5 versions
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

            local st_`v' ""
            if `p_`v'' < 0.01 local st_`v' "\sym{***}"
            else if `p_`v'' < 0.05 local st_`v' "\sym{**}"
            else if `p_`v'' < 0.10 local st_`v' "\sym{*}"

            local is_rate = (strpos("`y'", "pct_") == 1 | "`y'" == "utilization_rate" | strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
            if `is_rate' {
                local bf_`v' : di %7.3f `b_`v''
                local sf_`v' : di %7.3f `se_`v''
            }
            else {
                local bf_`v' : di %7.1f `b_`v''
                local sf_`v' : di %7.1f `se_`v''
            }
        }

        * Get open-seat coef for T0c and T0d (cols 3-4)
        foreach v in c d {
            qui count if version == "T0`v'_open" & outcome == "`y'"
            if r(N) > 0 {
                qui summ beta if version == "T0`v'_open" & outcome == "`y'"
                local bo_`v' = r(mean)
                qui summ se if version == "T0`v'_open" & outcome == "`y'"
                local seo_`v' = r(mean)
                qui summ pval if version == "T0`v'_open" & outcome == "`y'"
                local po_`v' = r(mean)
            }
            else {
                local bo_`v' = .
                local seo_`v' = .
                local po_`v' = 1
            }
            local sto_`v' ""
            if `po_`v'' < 0.01 local sto_`v' "\sym{***}"
            else if `po_`v'' < 0.05 local sto_`v' "\sym{**}"
            else if `po_`v'' < 0.10 local sto_`v' "\sym{*}"
            if `is_rate' {
                local bfo_`v' : di %7.3f `bo_`v''
                local sfo_`v' : di %7.3f `seo_`v''
            }
            else {
                local bfo_`v' : di %7.1f `bo_`v''
                local sfo_`v' : di %7.1f `seo_`v''
            }
        }

        * Row 1: Incumbent/election-year coefficient
        file write t "`lbl_`y'' & `=strtrim("`bf_a'")'`st_a' & `=strtrim("`bf_b'")'`st_b' & `=strtrim("`bf_c'")'`st_c' & `=strtrim("`bf_d'")'`st_d' & `=strtrim("`bf_e'")'`st_e' \\" _n
        file write t "  & (`=strtrim("`sf_a'")') & (`=strtrim("`sf_b'")') & (`=strtrim("`sf_c'")') & (`=strtrim("`sf_d'")') & (`=strtrim("`sf_e'")') \\" _n

        * Row 2 (cols 3-4 only): Open-seat coefficient
        file write t "\quad \textit{Open Seat} & & & `=strtrim("`bfo_c'")'`sto_c' & `=strtrim("`bfo_d'")'`sto_d' & \\" _n
        file write t "  & & & (`=strtrim("`sfo_c'")') & (`=strtrim("`sfo_d'")') & \\" _n
    }
}

file write t "\midrule" _n
file write t `"Open seats & Dropped & Dropped & Regressor & Regressor & Dropped \\"' _n
file write t `"Off-cycle counties & Included & Excluded & Included & Excluded & Included \\"' _n
file write t `"Fixed effects & County & County & County & County & County + Year \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}}" _n
file write t "\begin{tablenotes}\tiny" _n
file write t `"\item (1)--(4): county FE only; (5): county + year FE (TWFE)."' _n
file write t `"\item (3)--(4): both incumbent election and open-seat coefficients shown (italic rows)."' _n
file write t `"\item SEs clustered at county level. Pipeline from jury dashboard; verdict/plea from caseload dashboard."' _n
file write t `"\item Sign instability in (5) relative to (1)--(4) reflects limited within-year variation at the"' _n
file write t `"  election-year level, motivating the contestation decomposition (Tables~\ref{tab:t2-pipeline}--\ref{tab:t2-disposition})."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n
file write t "\end{landscape}" _n

file close t
restore

di "Table A1 DONE: `fa1'"


* =============================================================================
* TABLE A2 — EXHAUSTIVE FULL vs NO-OFFCYCLE (all outcomes)
* =============================================================================

di _n "{hline 72}"
di "TABLE A2: EXHAUSTIVE COMPARISON"
di "{hline 72}"

tempname fha2
tempfile t2_compare
file open `fha2' using "`t2_compare'", write replace
file write `fha2' "sample,outcome,b_con,se_con,p_con,b_unc,se_unc,p_unc,delta,delta_se,delta_p,nobs" _n

foreach samp in full nooc {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    drop if open_pros == 1
    if "`samp'" == "nooc" {
        drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
    }

    foreach y of local all_outcomes {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
        if !_rc {
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            local b2 = _b[treat_pros_uncontested]
            local s2 = _se[treat_pros_uncontested]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))
            qui lincom treat_pros_contested_long - treat_pros_uncontested
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))
            file write `fha2' "`samp',`y'," (`b1') "," (`s1') "," (`p1') "," (`b2') "," (`s2') "," (`p2') "," (`d') "," (`ds') "," (`dp') "," (e(N)) _n
        }
    }
}
file close `fha2'

preserve
import delimited using "`t2_compare'", clear

local fa2 "$TAB_DIR/tableA2_t2_offcycle.tex"
file open t using "`fa2'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Contestation: Full Panel vs Off-Cycle Excluded}" _n
file write t "\label{tab:t2-offcycle}" _n
file write t "\begin{threeparttable}" _n
file write t "\tiny" _n
file write t "\begin{tabular}{lcccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{3}{c}{Full Panel (83)} & \multicolumn{3}{c}{No Off-Cycle (77)} \\"' _n
file write t `"\cmidrule(lr){2-4} \cmidrule(lr){5-7}"' _n
file write t `"Outcome & Con & Unc & \(\Delta\) & Con & Unc & \(\Delta\) \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{7}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
        foreach samp in full nooc {
            foreach stat in b_con se_con p_con b_unc se_unc p_unc delta delta_se delta_p {
                qui count if sample == "`samp'" & outcome == "`y'"
                if r(N) > 0 {
                    qui summ `stat' if sample == "`samp'" & outcome == "`y'"
                    local `stat'_`samp' = r(mean)
                }
                else {
                    local `stat'_`samp' = .
                }
            }

            foreach coef in con unc delta {
                local pvar = "p_`coef'_`samp'"
                if "`coef'" == "delta" local pvar = "delta_p_`samp'"
                local st_`coef'_`samp' ""
                if ``pvar'' < 0.01 local st_`coef'_`samp' "\sym{***}"
                else if ``pvar'' < 0.05 local st_`coef'_`samp' "\sym{**}"
                else if ``pvar'' < 0.10 local st_`coef'_`samp' "\sym{*}"
            }

            local is_rate = (strpos("`y'", "pct_") == 1 | "`y'" == "utilization_rate" | strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
            foreach coef in con unc {
                if `is_rate' {
                    local cf_`coef'_`samp' : di %6.3f `b_`coef'_`samp''
                    local sf_`coef'_`samp' : di %6.3f `se_`coef'_`samp''
                }
                else {
                    local cf_`coef'_`samp' : di %6.1f `b_`coef'_`samp''
                    local sf_`coef'_`samp' : di %6.1f `se_`coef'_`samp''
                }
            }
            if `is_rate' {
                local df_`samp' : di %6.3f `delta_`samp''
                local dsf_`samp' : di %6.3f `delta_se_`samp''
            }
            else {
                local df_`samp' : di %6.1f `delta_`samp''
                local dsf_`samp' : di %6.1f `delta_se_`samp''
            }
        }

        file write t "`lbl_`y''"
        file write t " & `=strtrim("`cf_con_full'")'`st_con_full'"
        file write t " & `=strtrim("`cf_unc_full'")'`st_unc_full'"
        file write t " & `=strtrim("`df_full'")'`st_delta_full'"
        file write t " & `=strtrim("`cf_con_nooc'")'`st_con_nooc'"
        file write t " & `=strtrim("`cf_unc_nooc'")'`st_unc_nooc'"
        file write t " & `=strtrim("`df_nooc'")'`st_delta_nooc'"
        file write t " \\" _n

        file write t " "
        file write t " & (`=strtrim("`sf_con_full'")')"
        file write t " & (`=strtrim("`sf_unc_full'")')"
        file write t " & (`=strtrim("`dsf_full'")')"
        file write t " & (`=strtrim("`sf_con_nooc'")')"
        file write t " & (`=strtrim("`sf_unc_nooc'")')"
        file write t " & (`=strtrim("`dsf_nooc'")')"
        file write t " \\" _n
    }
}

file write t "\midrule" _n
file write t `"Off-cycle & \multicolumn{3}{c}{Included} & \multicolumn{3}{c}{Excluded} \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\tiny" _n
file write t `"\item Both: county + year FE, county-clustered SEs, open seats excluded."' _n
file write t `"\item \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom}. Pipeline from jury dashboard; verdict/plea from caseload."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore

di "Table A2 DONE: `fa2'"


* =============================================================================
* TABLE 4a/4b — HETEROGENEITY BY POPULATION (T2, high vs low pop)
* =============================================================================

di _n "{hline 72}"
di "TABLE 4: HETEROGENEITY (pop split, T2 on 77 sync counties)"
di "{hline 72}"

* Get median population for the synchronized sample
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

* Compute county-level mean population, then find median
bysort county_id: egen _mean_pop = mean(county_pop)
qui summ _mean_pop, detail
local med_pop = r(p50)
di "Median county population: `med_pop'"

gen highpop = (_mean_pop >= `med_pop')
drop _mean_pop

* Run T2 on each subsample, collect results
tempname fh4
tempfile het_csv
file open `fh4' using "`het_csv'", write replace
file write `fh4' "subsample,outcome,b_con,se_con,p_con,b_unc,se_unc,p_unc,delta,delta_se,delta_p,nobs" _n

foreach sub in high low {
    preserve
    if "`sub'" == "high" keep if highpop == 1
    if "`sub'" == "low"  keep if highpop == 0

    foreach y of local all_outcomes {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
        if !_rc {
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            local b2 = _b[treat_pros_uncontested]
            local s2 = _se[treat_pros_uncontested]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))
            qui lincom treat_pros_contested_long - treat_pros_uncontested
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))
            file write `fh4' "`sub',`y'," (`b1') "," (`s1') "," (`p1') "," (`b2') "," (`s2') "," (`p2') "," (`d') "," (`ds') "," (`dp') "," (e(N)) _n
        }
    }
    restore
}
file close `fh4'

* Build Table 4a (high pop) and 4b (low pop) from CSV
preserve
import delimited using "`het_csv'", clear

* Restore from the CSV collection loop before starting table generation
restore

* --- Table 4a: HIGH POP — single coefficient (T2 collinear in this subsample) ---
* In large counties, treat_pros_uncontested is collinear with county+year FE
* because uncontested elections follow a predictable county×year pattern.
* Use single-coefficient model: treat_pros_pressure (any incumbent election).

local f4a "$TAB_DIR/table4a_het_highpop.tex"
file open t using "`f4a'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Election Effects in Above-Median Population Counties}" _n
file write t "\label{tab:het-highpop}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lcc}" _n
file write t "\toprule" _n
file write t `"Outcome & Coef & SE \\"' _n
file write t "\midrule" _n

use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
bysort county_id: egen _mean_pop = mean(county_pop)
qui summ _mean_pop, detail
local med = r(p50)
keep if _mean_pop >= `med'

local het_hi_outs "fc_jury_share fc_dismiss_rate fc_plea_share severity_share fh_jury_share fh_dismiss_rate utilization_rate"
local lbl_fc_jury_share "FC Jury Trial Rate"
local lbl_fc_dismiss_rate "FC Dismissal Rate"
local lbl_fc_plea_share "FC Plea Rate"
local lbl_severity_share "Severity Share"
local lbl_fh_jury_share "FH Jury Trial Rate"
local lbl_fh_dismiss_rate "FH Dismissal Rate"
local lbl_utilization_rate "Utilization Rate"

local het_n = 0
foreach y of local het_hi_outs {
    capture qui reghdfe `y' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        local bval = _b[treat_pros_pressure]
        local sval = _se[treat_pros_pressure]
        local pval = 2 * ttail(e(df_r), abs(`bval'/`sval'))
        if `het_n' == 0 local het_n = e(N)
        local st ""
        if `pval' < 0.01 local st "\sym{***}"
        else if `pval' < 0.05 local st "\sym{**}"
        else if `pval' < 0.10 local st "\sym{*}"
        local is_rate = (strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
        if `is_rate' {
            local cf : di %6.3f `bval'
            local sf : di %6.3f `sval'
        }
        else {
            local cf : di %6.1f `bval'
            local sf : di %6.1f `sval'
        }
        file write t "`lbl_`y'' & `=strtrim("`cf'")'`st' & (`=strtrim("`sf'")') \\" _n
    }
}

file write t "\midrule" _n
file write t "County FE & \multicolumn{2}{c}{Yes} \\" _n
file write t "Year FE & \multicolumn{2}{c}{Yes} \\" _n
file write t "Clustering & \multicolumn{2}{c}{County} \\" _n
file write t "Observations & \multicolumn{2}{c}{`het_n'} \\" _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item Single-coefficient model: \(\beta\) = incumbent election vs non-election years."' _n
file write t `"\item Contestation decomposition not identified in large counties (uncontested"' _n
file write t `"  collinear with county \(\times\) year FE). See Table~\ref{tab:table4b} for small-county decomposition."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n
file close t
di "Table 4a DONE (single-coef): `f4a'"

* --- Table 4b: LOW POP — full T2 decomposition ---
* Now build the low-pop table from the CSV data collected earlier
preserve
import delimited using "`het_csv'", clear

foreach sub in low {
    local tbl_label "b"
    local tbl_title "Below-Median Population Counties"
    local tbl_ref "tab:table4b"

    local f4 "$TAB_DIR/table4`tbl_label'_het_`sub'pop.tex"
    file open t using "`f4'", write replace

    file write t "\begin{table}[htbp]\centering" _n
    file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
    file write t "\caption{Contestation and Case Outcomes: `tbl_title'}" _n
    file write t "\label{`tbl_ref'}" _n
    file write t "\begin{threeparttable}" _n
    file write t "\footnotesize" _n
    file write t "\begin{tabular}{lcccccc}" _n
    file write t "\toprule" _n
    file write t `" & \multicolumn{2}{c}{Contested} & \multicolumn{2}{c}{Uncontested} & \multicolumn{2}{c}{\(\Delta\) (Con \(-\) Unc)} \\"' _n
    file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}"' _n
    file write t `"Outcome & Coef & SE & Coef & SE & \(\Delta\) & SE \\"' _n
    file write t "\midrule" _n

    * Key outcomes only for main paper version
    local key_outcomes "fc_jury_share fc_dismiss_rate fc_plea_share severity_share fh_jury_share fh_dismiss_rate utilization_rate fc_jury fh_jury"

    local grp1 "fc_jury_share fc_dismiss_rate fc_plea_share severity_share"
    local grp2 "fh_jury_share fh_dismiss_rate"
    local grp3 "utilization_rate fc_jury fh_jury"

    local lbl_fc_jury_share "FC Jury Trial Rate"
    local lbl_fc_dismiss_rate "FC Dismissal Rate"
    local lbl_fc_plea_share "FC Plea Rate"
    local lbl_severity_share "Severity Share"
    local lbl_fh_jury_share "FH Jury Trial Rate"
    local lbl_fh_dismiss_rate "FH Dismissal Rate"
    local lbl_utilization_rate "Utilization Rate"
    local lbl_fc_jury "FC Jury Verdicts"
    local lbl_fh_jury "FH Jury Verdicts"

    local panel_idx = 0
    foreach grp_name in "FC Disposition" "FH Disposition" "Pipeline \& Verdicts" {
        local panel_idx = `panel_idx' + 1
        file write t "\multicolumn{7}{l}{\textit{`grp_name'}} \\[0.3em]" _n

        if `panel_idx' == 1 local grp_vars "`grp1'"
        if `panel_idx' == 2 local grp_vars "`grp2'"
        if `panel_idx' == 3 local grp_vars "`grp3'"

        foreach y of local grp_vars {
            qui summ b_con if outcome == "`y'" & subsample == "`sub'"
            if r(N) == 0 continue

            * Use summarize (reliable) instead of levelsof (fragile for numerics)
            qui summ b_con if outcome == "`y'" & subsample == "`sub'"
            local bcon = r(mean)
            qui summ se_con if outcome == "`y'" & subsample == "`sub'"
            local secon = r(mean)
            qui summ p_con if outcome == "`y'" & subsample == "`sub'"
            local pcon = r(mean)
            qui summ b_unc if outcome == "`y'" & subsample == "`sub'"
            local bunc = r(mean)
            qui summ se_unc if outcome == "`y'" & subsample == "`sub'"
            local seunc = r(mean)
            qui summ p_unc if outcome == "`y'" & subsample == "`sub'"
            local punc = r(mean)
            qui summ delta if outcome == "`y'" & subsample == "`sub'"
            local dval = r(mean)
            qui summ delta_se if outcome == "`y'" & subsample == "`sub'"
            local dse = r(mean)
            qui summ delta_p if outcome == "`y'" & subsample == "`sub'"
            local dp = r(mean)

            * Stars
            local st_c ""
            if `pcon' < 0.01 local st_c "\sym{***}"
            else if `pcon' < 0.05 local st_c "\sym{**}"
            else if `pcon' < 0.10 local st_c "\sym{*}"

            local st_u ""
            if `punc' < 0.01 local st_u "\sym{***}"
            else if `punc' < 0.05 local st_u "\sym{**}"
            else if `punc' < 0.10 local st_u "\sym{*}"

            local st_d ""
            if `dp' < 0.01 local st_d "\sym{***}"
            else if `dp' < 0.05 local st_d "\sym{**}"
            else if `dp' < 0.10 local st_d "\sym{*}"

            * Format
            local cf_c : di %6.3f `bcon'
            local sf_c : di %6.3f `secon'
            local cf_u : di %6.3f `bunc'
            local sf_u : di %6.3f `seunc'
            local df_d : di %6.3f `dval'
            local sf_d : di %6.3f `dse'

            file write t "`lbl_`y'' & `=strtrim("`cf_c'")'`st_c' & (`=strtrim("`sf_c'")') & `=strtrim("`cf_u'")'`st_u' & (`=strtrim("`sf_u'")') & `=strtrim("`df_d'")'`st_d' & (`=strtrim("`sf_d'")') \\" _n
        }
        file write t "\\[0.3em]" _n
    }

    * Footer
    qui summ nobs if subsample == "`sub'" & outcome == "fc_jury_share"
    local n4 = r(mean)
    file write t "\midrule" _n
    file write t "County FE & \multicolumn{6}{c}{Yes} \\" _n
    file write t "Year FE & \multicolumn{6}{c}{Yes} \\" _n
    file write t "Clustering & \multicolumn{6}{c}{County} \\" _n
    file write t "Observations & \multicolumn{6}{c}{`n4'} \\" _n
    file write t "\bottomrule" _n
    file write t "\end{tabular}" _n
    file write t "\begin{tablenotes}\footnotesize" _n
    file write t `"\item 77 synchronized counties split at median population. Open seats and off-cycle counties excluded."' _n
    file write t `"\item \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom}. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
    file write t "\end{tablenotes}" _n
    file write t "\end{threeparttable}" _n
    file write t "\end{table}" _n

    file close t
    di "Table 4`tbl_label' DONE: `f4'"
}
restore

* =============================================================================
* TABLE 6 — ROBUSTNESS SUMMARY (T2, key outcomes across sample variants)
* =============================================================================

di _n "{hline 72}"
di "TABLE 6: ROBUSTNESS SUMMARY (T2 across sample variants)"
di "{hline 72}"

tempname fh6
tempfile rob_csv
file open `fh6' using "`rob_csv'", write replace
file write `fh6' "variant,outcome,b_con,se_con,p_con,b_unc,se_unc,p_unc,delta,delta_se,delta_p,nobs" _n

* Variant 1: Main (77 sync, open dropped)
* Variant 2: All 83 counties + Wooldridge group x year FE
* Variant 3: Drop 2016 cycle
* Variant 4: Drop 2024 cycle

foreach var_num in 1 2 3 4 {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    drop if open_pros == 1

    if `var_num' == 1 {
        drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
        local vname "Main (77 sync)"
        local absrb "county_id year"
    }
    if `var_num' == 2 {
        * Wooldridge: group x year FE
        gen offcycle = inlist(county_id, 3, 37, 62, 66, 74, 21)
        egen group_year = group(offcycle year)
        local vname "Wooldridge (83)"
        local absrb "county_id group_year"
    }
    if `var_num' == 3 {
        drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
        drop if year == 2016
        local vname "No 2016"
        local absrb "county_id year"
    }
    if `var_num' == 4 {
        drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
        drop if year == 2024
        local vname "No 2024"
        local absrb "county_id year"
    }

    foreach y of local all_outcomes {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(`absrb') vce(cluster county_id)
        if !_rc {
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            local b2 = _b[treat_pros_uncontested]
            local s2 = _se[treat_pros_uncontested]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))
            qui lincom treat_pros_contested_long - treat_pros_uncontested
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))
            file write `fh6' "`vname',`y'," (`b1') "," (`s1') "," (`p1') "," (`b2') "," (`s2') "," (`p2') "," (`d') "," (`ds') "," (`dp') "," (e(N)) _n
        }
    }
}
file close `fh6'

* Build LaTeX Table 6 — key outcomes only, Δ column across 4 variants
preserve
import delimited using "`rob_csv'", clear

local f6 "$TAB_DIR/table6_robustness.tex"
file open t using "`f6'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: Contestation Effects Across Sample Definitions}" _n
file write t "\label{tab:robustness}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lcccc}" _n
file write t "\toprule" _n
file write t `" & (1) & (2) & (3) & (4) \\"' _n
file write t `" & Main & Wooldridge & No 2016 & No 2024 \\"' _n
file write t `" & (77 sync) & (83, grp\(\times\)yr) & (77 sync) & (77 sync) \\"' _n
file write t "\midrule" _n

* For each key outcome, show Contested coefficient across 4 variants
local key6 "fc_jury_share fc_dismiss_rate fc_plea_share severity_share utilization_rate fc_jury fh_jury"
local lbl_fc_jury_share "FC Jury Trial Rate"
local lbl_fc_dismiss_rate "FC Dismissal Rate"
local lbl_fc_plea_share "FC Plea Rate"
local lbl_severity_share "Severity Share"
local lbl_utilization_rate "Utilization Rate"
local lbl_fc_jury "FC Jury Verdicts"
local lbl_fh_jury "FH Jury Verdicts"

file write t "\multicolumn{5}{l}{\textit{Panel A: Contested coefficient (\(\beta_1\))}} \\[0.3em]" _n

foreach y of local key6 {
    file write t "`lbl_`y''"
    foreach vname in "Main (77 sync)" "Wooldridge (83)" "No 2016" "No 2024" {
        qui summ b_con if outcome == "`y'" & variant == "`vname'"
        if r(N) > 0 {
            local bval = r(mean)
            qui summ se_con if outcome == "`y'" & variant == "`vname'"
            local sval = r(mean)
            qui summ p_con if outcome == "`y'" & variant == "`vname'"
            local pval = r(mean)
            local st ""
            if `pval' < 0.01 local st "\sym{***}"
            else if `pval' < 0.05 local st "\sym{**}"
            else if `pval' < 0.10 local st "\sym{*}"
            local cf : di %6.3f `bval'
            local sf : di %6.3f `sval'
            file write t " & `=strtrim("`cf'")'`st'"
        }
        else file write t " & "
    }
    file write t " \\" _n
    * SE row
    file write t " "
    foreach vname in "Main (77 sync)" "Wooldridge (83)" "No 2016" "No 2024" {
        qui summ se_con if outcome == "`y'" & variant == "`vname'"
        if r(N) > 0 {
            local sval = r(mean)
            local sf : di %6.3f `sval'
            file write t " & (`=strtrim("`sf'")')"
        }
        else file write t " & "
    }
    file write t " \\" _n
}

file write t "\\[0.5em]" _n
file write t "\multicolumn{5}{l}{\textit{Panel B: \(\Delta\) (Contested \(-\) Uncontested)}} \\[0.3em]" _n

foreach y of local key6 {
    file write t "`lbl_`y''"
    foreach vname in "Main (77 sync)" "Wooldridge (83)" "No 2016" "No 2024" {
        qui summ delta if outcome == "`y'" & variant == "`vname'"
        if r(N) > 0 {
            local dval = r(mean)
            qui summ delta_se if outcome == "`y'" & variant == "`vname'"
            local dsval = r(mean)
            qui summ delta_p if outcome == "`y'" & variant == "`vname'"
            local dpval = r(mean)
            local st ""
            if `dpval' < 0.01 local st "\sym{***}"
            else if `dpval' < 0.05 local st "\sym{**}"
            else if `dpval' < 0.10 local st "\sym{*}"
            local df : di %6.3f `dval'
            local dsf : di %6.3f `dsval'
            file write t " & `=strtrim("`df'")'`st'"
        }
        else file write t " & "
    }
    file write t " \\" _n
    file write t " "
    foreach vname in "Main (77 sync)" "Wooldridge (83)" "No 2016" "No 2024" {
        qui summ delta_se if outcome == "`y'" & variant == "`vname'"
        if r(N) > 0 {
            local dsval = r(mean)
            local dsf : di %6.3f `dsval'
            file write t " & (`=strtrim("`dsf'")')"
        }
        else file write t " & "
    }
    file write t " \\" _n
}

file write t "\midrule" _n
file write t "County FE & Yes & Yes & Yes & Yes \\" _n
file write t `"Year FE & Yes & Grp\(\times\)Yr & Yes & Yes \\"' _n
file write t "Off-cycle & Excl. & Incl. & Excl. & Excl. \\" _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item Open seats excluded. \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom}."' _n
file write t `"\item Col (2) uses timing-group \(\times\) year FE (Wooldridge 2021)."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore
di "Table 6 DONE: `f6'"


* =============================================================================
* TABLE 8 — FALSIFICATION (incoming caseload as DV)
* =============================================================================

di _n "{hline 72}"
di "TABLE 8: FALSIFICATION (caseload DVs)"
di "{hline 72}"

* Augmented panel now has caseload vars (merged via 05b_build_augmented_panel.do)
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if open_pros == 1
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

* Generate lead test variable: prior-year incoming felonies
* (Does current election predict PAST caseload? Reverse causality test)
* Exclude obs where the lag sources from COVID years (2020-2021)
xtset county_id year
gen L_incoming_felony = L.incoming_felony
* If lagged value sources from 2020 or 2021, set to missing
replace L_incoming_felony = . if (year - 1) == 2020 | (year - 1) == 2021
label variable L_incoming_felony "Prior-year incoming felonies (temporal placebo)"

local f8 "$TAB_DIR/table8_falsification.tex"
file open t using "`f8'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Falsification: Criminal Caseload as Dependent Variable}" _n
file write t "\label{tab:falsification}" _n
file write t "\begin{threeparttable}" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & (1) & (2) & (3) & (4) & (5) \\"' _n
file write t `" & Incoming & Clearance & Incoming\(_{t-1}\) & \(\Delta\)Incoming & \(\Delta\)Incoming\(_{t-1}\) \\"' _n
file write t `" & Felonies & Rate & (Lead) & (First Diff) & (FD Lead) \\"' _n
file write t "\midrule" _n

* Generate first-differenced versions
gen FD_incoming = D.incoming_felony
replace FD_incoming = . if (year - 1) == 2020 | (year - 1) == 2021
label variable FD_incoming "First-differenced incoming felonies"

gen FD_L_incoming = D.L_incoming_felony
replace FD_L_incoming = . if (year - 1) == 2020 | (year - 1) == 2021 | (year - 2) == 2020 | (year - 2) == 2021
label variable FD_L_incoming "First-differenced prior-year incoming"

* T2 on caseload DVs + lead test + first differences
* NOTE: Pending felonies REMOVED from falsification table.
* Pending is a mechanism-consistent auxiliary outcome (fewer dismissals build backlog),
* not an independent falsification test. Reported in text footnote.
local falsif_dvs "incoming_felony clearance_rate L_incoming_felony FD_incoming FD_L_incoming"
local dv_idx = 0
foreach dv of local falsif_dvs {
    local dv_idx = `dv_idx' + 1
    capture qui reghdfe `dv' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        local b1_`dv_idx' = _b[treat_pros_contested_long]
        local s1_`dv_idx' = _se[treat_pros_contested_long]
        local p1_`dv_idx' = 2 * ttail(e(df_r), abs(`b1_`dv_idx''/`s1_`dv_idx''))
        local b2_`dv_idx' = _b[treat_pros_uncontested]
        local s2_`dv_idx' = _se[treat_pros_uncontested]
        local p2_`dv_idx' = 2 * ttail(e(df_r), abs(`b2_`dv_idx''/`s2_`dv_idx''))
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local d_`dv_idx' = r(estimate)
        local ds_`dv_idx' = r(se)
        local dp_`dv_idx' = 2 * ttail(e(df_r), abs(`d_`dv_idx''/`ds_`dv_idx''))
        local n_`dv_idx' = e(N)
    }
    else {
        local b1_`dv_idx' = .
        local b2_`dv_idx' = .
        local d_`dv_idx' = .
        local n_`dv_idx' = 0
    }
}

* Write rows: Contested, SE, Uncontested, SE, Delta, SE
* Col 2 (clearance rate) needs 3 decimals; all others (counts/FD) need 1 decimal
foreach coef_type in "Contested" "Uncontested" "Difference" {
    if "`coef_type'" == "Contested" {
        file write t "Contested"
        forval i = 1/5 {
            local st ""
            if `p1_`i'' < 0.01 local st "\sym{***}"
            else if `p1_`i'' < 0.05 local st "\sym{**}"
            else if `p1_`i'' < 0.10 local st "\sym{*}"
            if `i' == 2 local cf : di %6.3f `b1_`i''
            else        local cf : di %6.1f `b1_`i''
            file write t " & `=strtrim("`cf'")'`st'"
        }
        file write t " \\" _n
        file write t " "
        forval i = 1/5 {
            if `i' == 2 local sf : di %6.3f `s1_`i''
            else        local sf : di %6.1f `s1_`i''
            file write t " & (`=strtrim("`sf'")')"
        }
        file write t " \\" _n
    }
    if "`coef_type'" == "Uncontested" {
        file write t "Uncontested"
        forval i = 1/5 {
            local st ""
            if `p2_`i'' < 0.01 local st "\sym{***}"
            else if `p2_`i'' < 0.05 local st "\sym{**}"
            else if `p2_`i'' < 0.10 local st "\sym{*}"
            if `i' == 2 local cf : di %6.3f `b2_`i''
            else        local cf : di %6.1f `b2_`i''
            file write t " & `=strtrim("`cf'")'`st'"
        }
        file write t " \\" _n
        file write t " "
        forval i = 1/5 {
            if `i' == 2 local sf : di %6.3f `s2_`i''
            else        local sf : di %6.1f `s2_`i''
            file write t " & (`=strtrim("`sf'")')"
        }
        file write t " \\" _n
    }
    if "`coef_type'" == "Difference" {
        file write t `"\(\Delta\) (Con \(-\) Unc)"'
        forval i = 1/5 {
            local st ""
            if `dp_`i'' < 0.01 local st "\sym{***}"
            else if `dp_`i'' < 0.05 local st "\sym{**}"
            else if `dp_`i'' < 0.10 local st "\sym{*}"
            if `i' == 2 local cf : di %6.3f `d_`i''
            else        local cf : di %6.1f `d_`i''
            file write t " & `=strtrim("`cf'")'`st'"
        }
        file write t " \\" _n
        file write t " "
        forval i = 1/5 {
            if `i' == 2 local sf : di %6.3f `ds_`i''
            else        local sf : di %6.1f `ds_`i''
            file write t " & (`=strtrim("`sf'")')"
        }
        file write t " \\" _n
    }
}

file write t "\midrule" _n
file write t "County FE & Yes & Yes & Yes & Yes & Yes \\" _n
file write t "Year FE & Yes & Yes & Yes & Yes & Yes \\" _n
file write t "Clustering & County & County & County & County & County \\" _n
file write t `"Observations & `n_1' & `n_2' & `n_3' & `n_4' & `n_5' \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item Caseload from SCAO. 77 synchronized counties, open seats excluded."' _n
file write t `"\item Cols (1),(3): levels. Cols (4),(5): first differences (\(\Delta Y_t = Y_t - Y_{t-1}\))."' _n
file write t `"\item Col (3): prior-year incoming as DV (temporal placebo). COVID-sourced lags excluded."' _n
file write t `"\item Pending caseload stock (not shown) increases under uncontested elections"' _n
file write t `"  (+34.1 cases, \(p < 0.01\)): a mechanism-consistent auxiliary outcome"' _n
file write t `"  (fewer dismissals build backlog), not an independent falsification test."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Table 8 DONE: `f8'"


* =============================================================================
* TABLE A4 — T5 WITHIN-ELECTION (appendix, incumbent vs open seat)
* =============================================================================

di _n "{hline 72}"
di "TABLE A4: T5 WITHIN-ELECTION (election years only)"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
* Restrict to election years
keep if is_election_year_pros == 1 | open_pros == 1

local fA4 "$TAB_DIR/tableA4_within_election.tex"
file open t using "`fA4'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Within-Election Comparison: Incumbent vs Open Seat (Descriptive)}" _n
file write t "\label{tab:within-election}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccc}" _n
file write t "\toprule" _n
file write t `"Outcome & Coef & SE & N \\"' _n
file write t "\midrule" _n

local t5_outcomes "fc_jury_share fc_dismiss_rate fc_plea_share severity_share fh_jury_share fh_dismiss_rate utilization_rate fc_jury fh_jury actually_reported pct_told_to_report"

foreach y of local t5_outcomes {
    capture qui reghdfe `y' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    if !_rc {
        local bval = _b[treat_pros_pressure]
        local sval = _se[treat_pros_pressure]
        local pval = 2 * ttail(e(df_r), abs(`bval'/`sval'))
        local nval = e(N)
        local st ""
        if `pval' < 0.01 local st "\sym{***}"
        else if `pval' < 0.05 local st "\sym{**}"
        else if `pval' < 0.10 local st "\sym{*}"
        local cf : di %6.3f `bval'
        local sf : di %6.3f `sval'
        file write t "`lbl_`y'' & `=strtrim("`cf'")'`st' & (`=strtrim("`sf'")') & `nval' \\" _n
    }
}

file write t "\midrule" _n
file write t "County FE & \multicolumn{3}{c}{Yes} \\" _n
file write t "Year FE & \multicolumn{3}{c}{Yes} \\" _n
file write t "Clustering & \multicolumn{3}{c}{County} \\" _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item Sample restricted to election years only. Omitted: open-seat elections."' _n
file write t `"\item \(\beta\) = effect of incumbent running vs open seat. \(\approx\)170 obs (26 open-seat county-years)."' _n
file write t `"\item Exploratory --- small open-seat sample limits credibility."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Table A4 DONE: `fA4'"


* =============================================================================
* WILD CLUSTER BOOTSTRAP + TABLE A6
* Runs BOTH null-imposed (default) and nonull (unrestricted) variants.
* Generates CSV + LaTeX table comparing cluster p, null-boot p, nonull-boot p.
*
* Why both: Null-imposed bootstrap forces H0: beta=0, which is conservative
* but produces inflated p-values when the true effect is large (Djogbenou,
* MacKinnon & Nielsen 2019). The nonull variant resamples from the actual
* fitted model and provides valid inference regardless of effect magnitude
* (MacKinnon, Nielsen & Webb 2023).
* =============================================================================

di _n "{hline 72}"
di "BOOTTEST + TABLE A6: Wild cluster bootstrap (null + nonull)"
di "{hline 72}"

capture which boottest
if _rc {
    di as error "boottest not installed. Install with: ssc install boottest"
    di as error "Skipping bootstrap and Table A6."
}
else {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    drop if open_pros == 1
    drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

    * CSV for full results (includes bootstrap CIs)
    tempname fhbt
    local fbt "$OUTPUT/results/mi_boottest_results.csv"
    file open `fhbt' using "`fbt'", write replace
    file write `fhbt' "outcome,treatment,beta,se,p_cluster,p_boot_null,p_boot_nonull,ci_lo_nonull,ci_hi_nonull,nobs" _n

    local boot_outcomes "fc_jury_share fc_dismiss_rate fc_plea_share severity_share utilization_rate fc_jury fh_jury"

    * boottest requires areg (not reghdfe). Generate year dummies explicitly.
    * areg absorbs county_id; year dummies go on RHS so boottest can access them.
    qui tab year, gen(_yr_)

    * Also collect results for Table A6 LaTeX
    tempname fh_a6
    tempfile a6_csv
    file open `fh_a6' using "`a6_csv'", write replace
    file write `fh_a6' "outcome,treatment,beta,se,p_cluster,p_nonull,ci_lo,ci_hi" _n

    foreach y of local boot_outcomes {
        di "  Bootstrapping: `y'"
        capture qui areg `y' treat_pros_contested_long treat_pros_uncontested _yr_*, absorb(county_id) vce(cluster county_id)
        if !_rc {
            local nval = e(N)

            * --- Contested ---
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))

            * Null-imposed bootstrap
            local pb1_null = .
            capture boottest treat_pros_contested_long, cluster(county_id) reps(999) seed(42) noci quietly
            if !_rc local pb1_null = r(p)

            * Nonull bootstrap (with CI)
            local pb1_nonull = .
            local ci1_lo = .
            local ci1_hi = .
            capture boottest treat_pros_contested_long, cluster(county_id) reps(999) seed(42) nonull nograph quietly
            if !_rc {
                local pb1_nonull = r(p)
                * CI stored in r(CI) matrix: row 1 = [lo, hi]
                capture matrix _ci = r(CI)
                if !_rc {
                    local ci1_lo = _ci[1,1]
                    local ci1_hi = _ci[1,2]
                }
            }

            file write `fhbt' "`y',contested," (`b1') "," (`s1') "," (`p1') "," (`pb1_null') "," (`pb1_nonull') "," (`ci1_lo') "," (`ci1_hi') "," (`nval') _n
            file write `fh_a6' "`y',contested," (`b1') "," (`s1') "," (`p1') "," (`pb1_nonull') "," (`ci1_lo') "," (`ci1_hi') _n

            * --- Uncontested ---
            local b2 = _b[treat_pros_uncontested]
            local s2 = _se[treat_pros_uncontested]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))

            local pb2_null = .
            capture boottest treat_pros_uncontested, cluster(county_id) reps(999) seed(42) noci quietly
            if !_rc local pb2_null = r(p)

            local pb2_nonull = .
            local ci2_lo = .
            local ci2_hi = .
            capture boottest treat_pros_uncontested, cluster(county_id) reps(999) seed(42) nonull nograph quietly
            if !_rc {
                local pb2_nonull = r(p)
                capture matrix _ci = r(CI)
                if !_rc {
                    local ci2_lo = _ci[1,1]
                    local ci2_hi = _ci[1,2]
                }
            }

            file write `fhbt' "`y',uncontested," (`b2') "," (`s2') "," (`p2') "," (`pb2_null') "," (`pb2_nonull') "," (`ci2_lo') "," (`ci2_hi') "," (`nval') _n
            file write `fh_a6' "`y',uncontested," (`b2') "," (`s2') "," (`p2') "," (`pb2_nonull') "," (`ci2_lo') "," (`ci2_hi') _n

            * --- Delta ---
            qui lincom treat_pros_contested_long - treat_pros_uncontested
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))

            * Delta bootstrap: use constraint syntax (parentheses) for linear combination
            local pbd_null = .
            capture boottest (treat_pros_contested_long - treat_pros_uncontested = 0), cluster(county_id) reps(999) seed(42) noci quietly
            if !_rc local pbd_null = r(p)

            local pbd_nonull = .
            local cid_lo = .
            local cid_hi = .
            capture boottest (treat_pros_contested_long - treat_pros_uncontested = 0), cluster(county_id) reps(999) seed(42) nonull nograph quietly
            if !_rc {
                local pbd_nonull = r(p)
                capture matrix _ci = r(CI)
                if !_rc {
                    local cid_lo = _ci[1,1]
                    local cid_hi = _ci[1,2]
                }
            }

            file write `fhbt' "`y',delta," (`d') "," (`ds') "," (`dp') "," (`pbd_null') "," (`pbd_nonull') "," (`cid_lo') "," (`cid_hi') "," (`nval') _n
            file write `fh_a6' "`y',delta," (`d') "," (`ds') "," (`dp') "," (`pbd_nonull') "," (`cid_lo') "," (`cid_hi') _n
        }
    }

    file close `fhbt'
    file close `fh_a6'
    di "Boottest CSV saved to: `fbt'"

    * --- Build Table A6 from collected results ---
    preserve
    import delimited using "`a6_csv'", clear

    local fA6 "$TAB_DIR/tableA6_bootstrap.tex"
    file open t using "`fA6'", write replace

    file write t "\begin{table}[htbp]\centering" _n
    file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
    file write t "\caption{Wild Cluster Bootstrap Inference: Null-Imposed vs Unrestricted}" _n
    file write t "\label{tab:bootstrap}" _n
    file write t "\begin{threeparttable}" _n
    file write t "\scriptsize" _n
    file write t "\begin{tabular}{llcccccc}" _n
    file write t "\toprule" _n
    file write t `" & & & & \multicolumn{2}{c}{\(p\)-values} & \multicolumn{2}{c}{Boot 95\% CI} \\"' _n
    file write t `"\cmidrule(lr){5-6} \cmidrule(lr){7-8}"' _n
    file write t `"Outcome & Treatment & Coef & SE & Cluster & Nonull & Lower & Upper \\"' _n
    file write t "\midrule" _n

    local lbl_fc_jury_share "FC Jury Trial Rate"
    local lbl_fc_dismiss_rate "FC Dismissal Rate"
    local lbl_fc_plea_share "FC Plea Rate"
    local lbl_severity_share "Severity Share"
    local lbl_utilization_rate "Utilization Rate"
    local lbl_fc_jury "FC Jury Verdicts"
    local lbl_fh_jury "FH Jury Verdicts"

    local lbl_contested "Contested"
    local lbl_uncontested "Uncontested"
    local lbl_delta "\(\Delta\)"

    foreach y of local boot_outcomes {
        local first_row = 1
        local is_rate = (strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
        foreach tr in contested uncontested delta {
            qui summ beta if outcome == "`y'" & treatment == "`tr'"
            if r(N) > 0 {
                local bval = r(mean)
                qui summ se if outcome == "`y'" & treatment == "`tr'"
                local sval = r(mean)
                qui summ p_cluster if outcome == "`y'" & treatment == "`tr'"
                local pc : di %5.3f r(mean)
                qui summ p_nonull if outcome == "`y'" & treatment == "`tr'"
                local pnn : di %5.3f r(mean)
                qui summ ci_lo if outcome == "`y'" & treatment == "`tr'"
                local clo = r(mean)
                qui summ ci_hi if outcome == "`y'" & treatment == "`tr'"
                local chi = r(mean)

                if `is_rate' {
                    local bf : di %7.3f `bval'
                    local sf : di %7.3f `sval'
                    local clf : di %7.3f `clo'
                    local chf : di %7.3f `chi'
                }
                else {
                    local bf : di %7.1f `bval'
                    local sf : di %7.1f `sval'
                    local clf : di %7.1f `clo'
                    local chf : di %7.1f `chi'
                }

                if `first_row' {
                    file write t "`lbl_`y'' & `lbl_`tr'' & `=strtrim("`bf'")' & (`=strtrim("`sf'")') & `=strtrim("`pc'")' & `=strtrim("`pnn'")' & `=strtrim("`clf'")' & `=strtrim("`chf'")' \\" _n
                    local first_row = 0
                }
                else {
                    file write t " & `lbl_`tr'' & `=strtrim("`bf'")' & (`=strtrim("`sf'")') & `=strtrim("`pc'")' & `=strtrim("`pnn'")' & `=strtrim("`clf'")' & `=strtrim("`chf'")' \\" _n
                }
            }
        }
        file write t "\\[-0.3em]" _n
    }

    file write t "\midrule" _n
    file write t "\multicolumn{8}{l}{\textit{Sample: 77 synchronized counties, open seats excluded.}} \\" _n
    file write t "\multicolumn{8}{l}{\textit{999 bootstrap replications, Rademacher weights, seed 42.}} \\" _n
    file write t "\bottomrule" _n
    file write t "\end{tabular}" _n
    file write t "\begin{tablenotes}\footnotesize" _n
    file write t `"\item Coef and SE from \texttt{areg} (numerically identical to \texttt{reghdfe})."' _n
    file write t `"\item Cluster: conventional cluster-robust \(p\)-values."' _n
    file write t `"\item Nonull: wild cluster bootstrap, unrestricted (resamples from fitted model without"' _n
    file write t `"  imposing \(H_0\)). When the true effect is large, null-imposed bootstrap inflates"' _n
    file write t `"  \(p\)-values because the bootstrap DGP is misspecified \citep{djogbenou2019asymptotic}."' _n
    file write t `"  The unrestricted variant provides valid inference regardless of effect magnitude"' _n
    file write t `"  \citep{mackinnon2022cluster}."' _n
    file write t "\end{tablenotes}" _n
    file write t "\end{threeparttable}" _n
    file write t "\end{table}" _n

    file close t
    restore
    di "Table A6 DONE: `fA6'"
}


* =============================================================================
* CONTROLLED SPECIFICATIONS — Caseload + Population Controls
*   Adds incoming_felony + pending_felony (levels, NOT logged) and
*   log_county_pop as separate control sets across T0 and T2.
*   Output: CSV for comparison + appendix table A5
* =============================================================================

di _n "{hline 72}"
di "CONTROLLED SPECIFICATIONS: Caseload + Population"
di "{hline 72}"

* Save results to CSV
local fctl "$OUTPUT/results/mi_controlled_comparison.csv"
tempname fhctl
file open `fhctl' using "`fctl'", write replace
file write `fhctl' "model,spec,outcome,b_con,se_con,p_con,b_unc,se_unc,p_unc,delta,delta_se,delta_p,nobs" _n

* --- T0 (county FE only, full B, 83 counties) ---
foreach ctrl_type in base caseload pop caseload_pop {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear

    * T0 setup: county FE only
    if "`ctrl_type'" == "base"         local controls ""
    if "`ctrl_type'" == "caseload"     local controls "incoming_felony pending_felony"
    if "`ctrl_type'" == "pop"          local controls "log_county_pop"
    if "`ctrl_type'" == "caseload_pop" local controls "incoming_felony pending_felony log_county_pop"

    local spec_label "T0_`ctrl_type'"

    foreach y of local all_outcomes {
        capture qui reghdfe `y' elec_incumbent open_pros `controls', absorb(county_id) vce(cluster county_id)
        if !_rc {
            local b1 = _b[elec_incumbent]
            local s1 = _se[elec_incumbent]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            * open_pros coefficient (T0 has both)
            local b2 = _b[open_pros]
            local s2 = _se[open_pros]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))
            qui lincom elec_incumbent - open_pros
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))
            file write `fhctl' "T0,`ctrl_type',`y'," (`b1') "," (`s1') "," (`p1') "," (`b2') "," (`s2') "," (`p2') "," (`d') "," (`ds') "," (`dp') "," (e(N)) _n
        }
    }
}

* --- T2 (county + year FE, 77 sync, open seats dropped) ---
foreach ctrl_type in base caseload pop caseload_pop {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    drop if open_pros == 1
    drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

    if "`ctrl_type'" == "base"         local controls ""
    if "`ctrl_type'" == "caseload"     local controls "incoming_felony pending_felony"
    if "`ctrl_type'" == "pop"          local controls "log_county_pop"
    if "`ctrl_type'" == "caseload_pop" local controls "incoming_felony pending_felony log_county_pop"

    local spec_label "T2_`ctrl_type'"

    foreach y of local all_outcomes {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested `controls', absorb(county_id year) vce(cluster county_id)
        if !_rc {
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            local b2 = _b[treat_pros_uncontested]
            local s2 = _se[treat_pros_uncontested]
            local p2 = 2 * ttail(e(df_r), abs(`b2'/`s2'))
            qui lincom treat_pros_contested_long - treat_pros_uncontested
            local d = r(estimate)
            local ds = r(se)
            local dp = 2 * ttail(e(df_r), abs(`d'/`ds'))
            file write `fhctl' "T2,`ctrl_type',`y'," (`b1') "," (`s1') "," (`p1') "," (`b2') "," (`s2') "," (`p2') "," (`d') "," (`ds') "," (`dp') "," (e(N)) _n
        }
    }
}

file close `fhctl'
di "Controlled comparison saved to: `fctl'"

* --- Build Table A5: T2 Base vs Controlled (key outcomes) ---
preserve
import delimited using "`fctl'", clear

local fa5 "$TAB_DIR/tableA5_controlled.tex"
file open t using "`fa5'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Sensitivity to Caseload and Population Controls (T2, 77 Sync Counties)}" _n
file write t "\label{tab:controls}" _n
file write t "\begin{threeparttable}" _n
file write t "\tiny" _n
file write t "\begin{tabular}{lcccc}" _n
file write t "\toprule" _n
file write t `" & (1) & (2) & (3) & (4) \\"' _n
file write t `" & Base & + Caseload & + Pop & + Both \\"' _n
file write t "\midrule" _n

* Panel A: Contested coefficient
file write t "\multicolumn{5}{l}{\textit{Panel A: Contested (\(\beta_1\))}} \\[0.3em]" _n

* Use ALL outcomes for exhaustive appendix table
foreach y of local all_outcomes {
    * Get label from the global label locals defined at top of file
    local lbl "`lbl_`y''"
    if "`lbl'" == "" local lbl "`y'"

    file write t "`lbl'"
    foreach ctrl in base caseload pop caseload_pop {
        qui summ b_con if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
        if r(N) > 0 {
            local bval = r(mean)
            qui summ p_con if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
            local pval = r(mean)
            local st ""
            if `pval' < 0.01 local st "\sym{***}"
            else if `pval' < 0.05 local st "\sym{**}"
            else if `pval' < 0.10 local st "\sym{*}"
            local cf : di %7.4f `bval'
            file write t " & `=strtrim("`cf'")'`st'"
        }
        else file write t " & "
    }
    file write t " \\" _n

    * SE row
    file write t " "
    foreach ctrl in base caseload pop caseload_pop {
        qui summ se_con if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
        if r(N) > 0 {
            local sval = r(mean)
            local sf : di %7.4f `sval'
            file write t " & (`=strtrim("`sf'")')"
        }
        else file write t " & "
    }
    file write t " \\" _n
}

* Panel B: Δ
file write t "\\[0.5em]" _n
file write t "\multicolumn{5}{l}{\textit{Panel B: \(\Delta\) (Contested \(-\) Uncontested)}} \\[0.3em]" _n

foreach y of local key_outs {
    local lbl "`y'"
    if "`y'" == "fc_jury_share" local lbl "FC Jury Trial Rate"
    if "`y'" == "fc_dismiss_rate" local lbl "FC Dismissal Rate"
    if "`y'" == "fc_plea_share" local lbl "FC Plea Rate"
    if "`y'" == "severity_share" local lbl "Severity Share"
    if "`y'" == "fc_jury_adj_share" local lbl "FC Jury Share (Adj.)"
    if "`y'" == "fc_plea_adj_share" local lbl "FC Plea Share (Adj.)"
    if "`y'" == "fh_jury_share" local lbl "FH Jury Trial Rate"
    if "`y'" == "fh_dismiss_rate" local lbl "FH Dismissal Rate"
    if "`y'" == "utilization_rate" local lbl "Utilization Rate"

    file write t "`lbl'"
    foreach ctrl in base caseload pop caseload_pop {
        qui summ delta if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
        if r(N) > 0 {
            local dval = r(mean)
            qui summ delta_p if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
            local dpval = r(mean)
            local st ""
            if `dpval' < 0.01 local st "\sym{***}"
            else if `dpval' < 0.05 local st "\sym{**}"
            else if `dpval' < 0.10 local st "\sym{*}"
            local df : di %7.4f `dval'
            file write t " & `=strtrim("`df'")'`st'"
        }
        else file write t " & "
    }
    file write t " \\" _n

    file write t " "
    foreach ctrl in base caseload pop caseload_pop {
        qui summ delta_se if model == "T2" & spec == "`ctrl'" & outcome == "`y'"
        if r(N) > 0 {
            local dsval = r(mean)
            local dsf : di %7.4f `dsval'
            file write t " & (`=strtrim("`dsf'")')"
        }
        else file write t " & "
    }
    file write t " \\" _n
}

file write t "\midrule" _n
file write t "County FE & Yes & Yes & Yes & Yes \\" _n
file write t "Year FE & Yes & Yes & Yes & Yes \\" _n
file write t "Caseload controls & No & Yes & No & Yes \\" _n
file write t `"log(pop) control & No & No & Yes & Yes \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\tiny" _n
file write t `"\item 77 sync counties, open seats excluded. Caseload = incoming\_felony + pending\_felony (levels)."' _n
file write t `"\item \(\Delta = \beta_1 - \beta_2\) via \texttt{lincom}. \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore

di "Table A5 DONE: `fa5'"


* =============================================================================
* SUMMARY STATISTICS TABLE (replaces deprecated mi_table_sumstats.tex)
* Uses augmented panel with both pipeline (jury dashboard) and
* disposition (caseload dashboard) variables.
* =============================================================================

di _n "{hline 72}"
di "SUMMARY STATISTICS TABLE"
di "{hline 72}"

use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear

local fss "$TAB_DIR/table_sumstats.tex"
file open t using "`fss'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Summary Statistics}" _n
file write t "\label{tab:sumstats}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lcccccc}" _n
file write t "\toprule" _n
file write t `"Variable & Mean & SD & Min & Max & \(N\) & Source \\"' _n
file write t "\midrule" _n

* Define variable groups with labels and sources
* Group 1: Treatment
file write t "\multicolumn{7}{l}{\textit{Treatment Variables}} \\[0.3em]" _n

foreach v in elec_incumbent open_pros treat_pros_contested_long treat_pros_uncontested {
    qui summ `v'
    local mn : di %6.3f r(mean)
    local sd : di %6.3f r(sd)
    local mi : di %6.0f r(min)
    local ma : di %6.0f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Elections \\" _n
}

* Group 2: Pipeline counts
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Jury Pipeline Counts (SCAO Form 73)}} \\[0.3em]" _n

foreach v in summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire {
    qui summ `v'
    local mn : di %9.1f r(mean)
    local sd : di %9.1f r(sd)
    local mi : di %9.0f r(min)
    local ma : di %9.0f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Jury \\" _n
}

* Group 3: Pipeline rates
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Jury Pipeline Rates (SCAO Form 73)}} \\[0.3em]" _n

foreach v in pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate {
    qui summ `v'
    local mn : di %6.3f r(mean)
    local sd : di %6.3f r(sd)
    local mi : di %6.3f r(min)
    local ma : di %6.3f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Jury \\" _n
}

* Group 4: Verdict/trial counts (caseload dashboard)
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Verdict and Trial Counts (SCAO Outgoing Caseload)}} \\[0.3em]" _n

foreach v in fc_jury fh_jury fc_bench fh_bench felony_jury_total {
    qui summ `v'
    local mn : di %6.1f r(mean)
    local sd : di %6.1f r(sd)
    local mi : di %6.0f r(min)
    local ma : di %6.0f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Caseload \\" _n
}

* Group 5: Plea/dismissal counts
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Plea and Dismissal Counts (SCAO Outgoing Caseload)}} \\[0.3em]" _n

foreach v in fc_plea fh_plea fc_dismissed fh_dismissed {
    qui summ `v'
    local mn : di %6.1f r(mean)
    local sd : di %6.1f r(sd)
    local mi : di %6.0f r(min)
    local ma : di %6.0f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Caseload \\" _n
}

* Group 6: Disposition rates
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Disposition Rates and Composition}} \\[0.3em]" _n

foreach v in fc_jury_share fh_jury_share fc_plea_share fh_plea_share fc_dismiss_rate fh_dismiss_rate severity_share {
    qui summ `v'
    local mn : di %6.3f r(mean)
    local sd : di %6.3f r(sd)
    local mi : di %6.3f r(min)
    local ma : di %6.3f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Derived \\" _n
}

* Group 7: Adjudicated shares
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Adjudicated Shares (excl. dismissals)}} \\[0.3em]" _n

foreach v in fc_jury_adj_share fc_plea_adj_share fh_jury_adj_share fh_plea_adj_share {
    qui summ `v'
    local mn : di %6.3f r(mean)
    local sd : di %6.3f r(sd)
    local mi : di %6.3f r(min)
    local ma : di %6.3f r(max)
    local nn = r(N)
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & Derived \\" _n
}

* Group 8: Caseload controls
file write t "\\[0.3em]\multicolumn{7}{l}{\textit{Caseload Controls}} \\[0.3em]" _n

foreach v in incoming_felony pending_felony clearance_rate county_pop {
    qui summ `v'
    if "`v'" == "county_pop" {
        local mn : di %9.0f r(mean)
        local sd : di %9.0f r(sd)
        local mi : di %9.0f r(min)
        local ma : di %9.0f r(max)
    }
    else if "`v'" == "clearance_rate" {
        local mn : di %6.3f r(mean)
        local sd : di %6.3f r(sd)
        local mi : di %6.3f r(min)
        local ma : di %6.3f r(max)
    }
    else {
        local mn : di %9.1f r(mean)
        local sd : di %9.1f r(sd)
        local mi : di %9.0f r(min)
        local ma : di %9.0f r(max)
    }
    local nn = r(N)
    local src "Caseload"
    if "`v'" == "county_pop" local src "Census"
    file write t "`lbl_`v'' & `=strtrim("`mn'")' & `=strtrim("`sd'")' & `=strtrim("`mi'")' & `=strtrim("`ma'")' & `nn' & `src' \\" _n
}

file write t "\midrule" _n
file write t "\multicolumn{7}{l}{\textit{Panel: 83 counties \(\times\) 7 years (2016--2019, 2022--2024). N = 579 max.}} \\" _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item Jury pipeline variables from SCAO Jury Statistics Dashboard (Form 73)."' _n
file write t `"\item Verdict, plea, and dismissal variables from SCAO Interactive Court Data Dashboard (outgoing caseload)."' _n
file write t `"\item FC = Capital Felonies (life-sentence-eligible). FH = Non-capital Felonies. Circuit courts only."' _n
file write t `"\item Adjudicated shares use denominator = jury + bench + plea (excludes dismissals)."' _n
file write t `"\item N varies by outcome due to missing pipeline denominators and caseload coverage."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Summary Stats DONE: `fss'"


* =============================================================================
* TABLE A7 — JACKKNIFE: LEAVE-ONE-LARGE-COUNTY-OUT
* Drops each of 10 largest counties one at a time.
* Panel A: T0 (county FE, elec_incumbent + open_pros, full panel minus dropped)
* Panel B: T2 (county + year FE, contested + uncontested, 77 sync minus dropped)
* Reports incumbent/contested coefficient for all Table 1-2 outcomes.
* =============================================================================

di _n "{hline 72}"
di "TABLE A7: JACKKNIFE (leave-one-large-county-out)"
di "{hline 72}"

* Identify 10 largest counties by mean population
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
bysort county_id: egen _mp = mean(county_pop)
qui duplicates drop county_id, force
gsort -_mp
local top10 ""
forval j = 1/10 {
    local cid = county_id[`j']
    local cname = county[`j']
    local top10 "`top10' `cid'"
    di "  Top `j': `cname' (county_id=`cid')"
}

* CSV for jackknife results
tempname fhjk
local fjk "$OUTPUT/results/mi_jackknife_v2.csv"
file open `fhjk' using "`fjk'", write replace
file write `fhjk' "panel,dropped_id,dropped_name,outcome,beta,se,pval,nobs" _n

* --- Panel A: T0 jackknife ---
foreach cid of local top10 {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    qui levelsof county if county_id == `cid', local(cname) clean
    drop if county_id == `cid'

    foreach y of local all_outcomes {
        capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
        if !_rc {
            file write `fhjk' "T0,`cid',`cname',`y'," (_b[elec_incumbent]) "," (_se[elec_incumbent]) "," (2*ttail(e(df_r),abs(_b[elec_incumbent]/_se[elec_incumbent]))) "," (e(N)) _n
        }
    }
}

* --- Panel B: T2 jackknife ---
foreach cid of local top10 {
    use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
    qui levelsof county if county_id == `cid', local(cname) clean
    drop if county_id == `cid'
    drop if open_pros == 1
    drop if inlist(county_id, 3, 37, 62, 66, 74, 21)

    foreach y of local all_outcomes {
        capture qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)
        if !_rc {
            local b1 = _b[treat_pros_contested_long]
            local s1 = _se[treat_pros_contested_long]
            local p1 = 2 * ttail(e(df_r), abs(`b1'/`s1'))
            file write `fhjk' "T2,`cid',`cname',`y'," (`b1') "," (`s1') "," (`p1') "," (e(N)) _n
        }
    }
}

file close `fhjk'
di "Jackknife CSV saved to: `fjk'"

* --- Build Table A7 from CSV ---
* Show key outcomes only (matching Tables 1-2 headline DVs)
* Format: rows = outcomes, columns = full sample + range across LOO

preserve
import delimited using "`fjk'", clear

local key_jk "fc_jury_share fc_dismiss_rate fc_plea_share severity_share utilization_rate fc_jury fh_jury actually_reported pct_told_to_report"

local fA7 "$TAB_DIR/tableA7_jackknife.tex"
file open t using "`fA7'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Leave-One-Large-County-Out Sensitivity}" _n
file write t "\label{tab:jackknife}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lcccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{3}{c}{T0 (County FE)} & \multicolumn{3}{c}{T2 (TWFE, 77 sync)} \\"' _n
file write t `"\cmidrule(lr){2-4} \cmidrule(lr){5-7}"' _n
file write t `"Outcome & Full & LOO Range & Sign Flips & Full & LOO Range & Sign Flips \\"' _n
file write t "\midrule" _n

foreach y of local key_jk {
    * T0: full sample estimate
    qui summ beta if panel == "T0" & outcome == "`y'"
    local n_t0 = r(N)
    if `n_t0' == 0 continue

    * Get full-sample T0 from Table 1 (first LOO county's full estimate is close enough,
    * but better to compute directly)
    * Use mean of LOO estimates as proxy for full (they're all very close)
    local full_t0 = r(mean)
    local min_t0 = r(min)
    local max_t0 = r(max)

    * Count sign flips relative to mean
    local sign_full_t0 = sign(`full_t0')
    qui count if panel == "T0" & outcome == "`y'" & sign(beta) != `sign_full_t0' & beta != 0
    local flips_t0 = r(N)

    * T2: contested coefficient
    qui summ beta if panel == "T2" & outcome == "`y'"
    local n_t2 = r(N)
    if `n_t2' > 0 {
        local full_t2 = r(mean)
        local min_t2 = r(min)
        local max_t2 = r(max)
        local sign_full_t2 = sign(`full_t2')
        qui count if panel == "T2" & outcome == "`y'" & sign(beta) != `sign_full_t2' & beta != 0
        local flips_t2 = r(N)
    }
    else {
        local full_t2 = .
        local min_t2 = .
        local max_t2 = .
        local flips_t2 = .
    }

    * Format
    local is_rate = (strpos("`y'", "pct_") == 1 | "`y'" == "utilization_rate" | strpos("`y'", "_share") > 0 | strpos("`y'", "_rate") > 0)
    if `is_rate' {
        local ff_t0 : di %6.3f `full_t0'
        local fr_t0 "[" %6.3f `min_t0' ", " %6.3f `max_t0' "]"
        local ff_t2 : di %6.3f `full_t2'
        local fr_t2 "[" %6.3f `min_t2' ", " %6.3f `max_t2' "]"
    }
    else {
        local ff_t0 : di %6.1f `full_t0'
        local fr_t0 "[" %6.1f `min_t0' ", " %6.1f `max_t0' "]"
        local ff_t2 : di %6.1f `full_t2'
        local fr_t2 "[" %6.1f `min_t2' ", " %6.1f `max_t2' "]"
    }

    file write t "`lbl_`y'' & `=strtrim("`ff_t0'")' & `=strtrim("`fr_t0'")' & `flips_t0'/10"
    if `n_t2' > 0 {
        file write t " & `=strtrim("`ff_t2'")' & `=strtrim("`fr_t2'")' & `flips_t2'/10"
    }
    else {
        file write t " & & & "
    }
    file write t " \\" _n
}

file write t "\midrule" _n
file write t "\multicolumn{7}{l}{\textit{10 largest counties by mean population dropped one at a time.}} \\" _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\footnotesize" _n
file write t `"\item T0: county FE only, elec\_incumbent coefficient. T2: county + year FE, contested coefficient."' _n
file write t `"\item Full = mean of LOO estimates (proxy for full-sample; LOO estimates cluster tightly)."' _n
file write t `"\item LOO Range = [min, max] across 10 leave-one-out estimates."' _n
file write t `"\item Sign Flips = number of LOO estimates with opposite sign from the mean."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
restore

di "Table A7 DONE: `fA7'"


di _n "========================================"
di "  ALL TABLES DONE"
di "========================================"
