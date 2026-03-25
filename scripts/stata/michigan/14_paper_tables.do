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

local f "$TAB_DIR/table1_baseline.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect (T0)}" _n
file write t "\label{tab:table1}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Incumbent Election} & \multicolumn{2}{c}{Open Seat} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(N\) \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
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
file write t `"\item \textit{Notes.} \(Y_{ct} = \beta_1 \cdot \text{IncumbentElec}_{ct} + \beta_2 \cdot \text{OpenSeat}_{ct} + \alpha_c + \varepsilon_{ct}\)."' _n
file write t `"\item County FE only (no year FE). SEs clustered at county level."' _n
file write t `"\item IncumbentElec and OpenSeat are mutually exclusive; omitted = non-election years."' _n
file write t `"\item Pipeline variables from SCAO jury dashboard. Verdict/plea/dismissal from SCAO outgoing caseload dashboard."' _n
file write t `"\item See Table~\ref{tab:tableA1} for sample restriction sensitivity."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

file close t
di "Table 1 DONE: `f'"


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

local f "$TAB_DIR/table2_contestation.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Effect of Electoral Contestation on Jury and Case Outcomes}" _n
file write t "\label{tab:table2}" _n
file write t "\begin{threeparttable}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{lccccccc}" _n
file write t "\toprule" _n
file write t `" & \multicolumn{2}{c}{Contested} & \multicolumn{2}{c}{Uncontested} & \multicolumn{2}{c}{\(\Delta\) (Con \(-\) Unc)} & \\"' _n
file write t `"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}"' _n
file write t `"Outcome & Coef & SE & Coef & SE & \(\Delta\) & SE & \(N\) \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
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
file write t `"\item \textit{Notes.} \(Y_{ct} = \beta_1 \cdot \text{Contested}_{ct} + \beta_2 \cdot \text{Uncontested}_{ct} + \alpha_c + \gamma_t + \varepsilon_{ct}\)."' _n
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

local f2b "$TAB_DIR/table2b_delta_robustness.tex"
file open t using "`f2b'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t `"\caption{Contestation Differential \(\Delta\): Specification Robustness}"' _n
file write t "\label{tab:table2b}" _n
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
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
foreach y of local all_outcomes {
    capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0c,`y'," (_b[elec_incumbent]) "," (_se[elec_incumbent]) "," (2*ttail(e(df_r),abs(_b[elec_incumbent]/_se[elec_incumbent]))) "," (e(N)) _n
    }
}

* T0d: off-cycle dropped, open seat as regressor, county FE
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
drop if inlist(county_id, 3, 37, 62, 66, 74, 21)
foreach y of local all_outcomes {
    capture qui reghdfe `y' elec_incumbent open_pros, absorb(county_id) vce(cluster county_id)
    if !_rc {
        file write `fha1' "T0d,`y'," (_b[elec_incumbent]) "," (_se[elec_incumbent]) "," (2*ttail(e(df_r),abs(_b[elec_incumbent]/_se[elec_incumbent]))) "," (e(N)) _n
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

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Baseline Election Effect: Sample Restriction Sensitivity}" _n
file write t "\label{tab:tableA1}" _n
file write t "\begin{threeparttable}" _n
file write t "\scriptsize" _n
file write t "\begin{tabular}{lccccc}" _n
file write t "\toprule" _n
file write t `" & (1) T0a & (2) T0b & (3) T0c & (4) T0d & (5) T0e \\"' _n
file write t "\midrule" _n

forvalues g = 1/`n_groups' {
    if `g' > 1 {
        file write t "\\[-0.3em]" _n
    }
    file write t "\multicolumn{6}{l}{\textit{`grp`g'_lbl'}} \\[0.3em]" _n

    foreach y of local grp`g' {
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

        file write t "`lbl_`y'' & `=strtrim("`bf_a'")'`st_a' & `=strtrim("`bf_b'")'`st_b' & `=strtrim("`bf_c'")'`st_c' & `=strtrim("`bf_d'")'`st_d' & `=strtrim("`bf_e'")'`st_e' \\" _n
        file write t "  & (`=strtrim("`sf_a'")') & (`=strtrim("`sf_b'")') & (`=strtrim("`sf_c'")') & (`=strtrim("`sf_d'")') & (`=strtrim("`sf_e'")') \\" _n
    }
}

file write t "\midrule" _n
file write t `"Open seats & Dropped & Dropped & Regressor & Regressor & Dropped \\"' _n
file write t `"Off-cycle counties & Included & Excluded & Included & Excluded & Included \\"' _n
file write t `"Fixed effects & County & County & County & County & County + Year \\"' _n
file write t "\bottomrule" _n
file write t "\end{tabular}" _n
file write t "\begin{tablenotes}\scriptsize" _n
file write t `"\item \textit{Notes.} (1)--(4) county FE only. (5) adds year FE (TWFE)."' _n
file write t `"\item SEs clustered at county level. Pipeline from jury dashboard; verdict/plea from caseload dashboard."' _n
file write t `"\item \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)."' _n
file write t "\end{tablenotes}" _n
file write t "\end{threeparttable}" _n
file write t "\end{table}" _n

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
file write t "\label{tab:tableA2}" _n
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


di _n "========================================"
di "  ALL TABLES DONE"
di "========================================"
