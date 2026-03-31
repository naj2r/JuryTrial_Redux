/*==============================================================================
  11_caseload_tables.do

  Purpose:  Generate LaTeX tables for caseload robustness analysis.
            Table A17: Falsification (incoming felony caseload as DV)
            Table A18: Jury mobilization with caseload control

  Input:    $OUTPUT/results/mi_caseload_results.csv
            $OUTPUT/results/mi_regression_results.csv   (for baseline comparison)
            $DATA_FINAL/michigan_panel_B.dta             (for dep var means)
            $DATA_INT/mi_caseload_panel.dta              (for caseload means)

  Output:   $OL/files/tab/mi_conference/mi_tableA17_caseload_falsification.tex
            $OL/files/tab/mi_conference/mi_tableA18_caseload_control.tex

  Requires: 07_regressions.do and 07d_caseload_robustness.do must have run.
==============================================================================*/
/* FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies). From SCAO case type codes. */

* --- Bootstrap ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

local texdir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26/files/tab/mi_conference"
capture mkdir "`texdir'"

di as text _n "========================================================"
di as text   "  11_caseload_tables.do — Building caseload robustness tables"
di as text   "========================================================"


* =============================================================================
* PHASE 1: Load results and compute means
* =============================================================================

* --- Dep var means from Panel B ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
foreach v in actually_reported told_to_report pct_told_to_report {
    qui sum `v', meanonly
    global m_`v' = r(mean)
}

* --- Merge caseload to get caseload means ---
merge m:1 county year using "$DATA_INT/mi_caseload_panel.dta", ///
    keepusing(incoming_felony pending_felony incoming_felony_lag1 ///
              clearance_rate clearance_rate_lead1) keep(master match) nogen
qui sum incoming_felony, meanonly
global m_incoming = r(mean)
qui sum incoming_felony_lag1, meanonly
global m_incoming_lag = r(mean)
qui sum clearance_rate, meanonly
global m_clearance = r(mean)
qui sum clearance_rate_lead1, meanonly
global m_clearance_lead = r(mean)


* --- Load caseload results CSV ---
preserve
    import delimited "$OUTPUT/results/mi_caseload_results.csv", clear varnames(1)

    * --- Helper: Extract one result as globals ---
    * Usage: extract_result variant tier spec outcome treatvar prefix
    capture program drop extract_result
    program define extract_result
        syntax , variant(string) spec(string) outcome(string) tvar(string) prefix(string)

        qui levelsof beta if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", local(b_list) clean
        if "`b_list'" == "" {
            global `prefix'_b = .
            global `prefix'_se = .
            global `prefix'_p = .
            global `prefix'_n = .
            exit
        }
        * Take first match
        qui sum beta if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", meanonly
        global `prefix'_b = r(mean)
        qui sum se if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", meanonly
        global `prefix'_se = r(mean)
        qui sum p_value if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", meanonly
        global `prefix'_p = r(mean)
        qui sum n_obs if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", meanonly
        global `prefix'_n = r(mean)
    end

    * --- Extract Table A17 cells (falsification) ---
    extract_result, variant("B_falsi") spec("pressure") outcome("incoming_felony") tvar("treat_pros_pressure") prefix("f_t1")
    extract_result, variant("B_falsi") spec("contested_long") outcome("incoming_felony") tvar("treat_pros_contested_long") prefix("f_t2c")
    extract_result, variant("B_falsi") spec("contested_long") outcome("incoming_felony") tvar("treat_pros_uncontested") prefix("f_t2u")

    * --- Extract Table A19 cells (lag + clearance) ---
    * Incoming lag (placebo)
    extract_result, variant("B_falsi") spec("pressure_lag") outcome("incoming_felony_lag1") tvar("treat_pros_pressure") prefix("lag_t1")
    * Clearance rate (current)
    extract_result, variant("B_mech") spec("pressure") outcome("clearance_rate") tvar("treat_pros_pressure") prefix("cr_t1")
    * Clearance rate (lead)
    extract_result, variant("B_mech") spec("pressure_lead") outcome("clearance_rate_lead1") tvar("treat_pros_pressure") prefix("crl_t1")
    * Contested clearance lead (the significant one)
    extract_result, variant("B_mech") spec("contested_long_lead") outcome("clearance_rate_lead1") tvar("treat_pros_contested_long") prefix("crl_t2c")
    extract_result, variant("B_mech") spec("contested_long_lead") outcome("clearance_rate_lead1") tvar("treat_pros_uncontested") prefix("crl_t2u")

    * --- Extract Table A18 cells (congestion control) ---
    * Controlled specs
    extract_result, variant("B_caseload") spec("pressure_pending") outcome("actually_reported") tvar("treat_pros_pressure") prefix("c_ar")
    extract_result, variant("B_caseload") spec("pressure_pending") outcome("told_to_report") tvar("treat_pros_pressure") prefix("c_tr")
    extract_result, variant("B_caseload") spec("pressure_pending") outcome("pct_told_to_report") tvar("treat_pros_pressure") prefix("c_pct")
restore

* --- Load baseline results for comparison ---
preserve
    import delimited "$OUTPUT/results/mi_regression_results.csv", clear varnames(1)

    * Baseline (no control) — T1 pressure from Variant B
    extract_result, variant("B") spec("pressure") outcome("actually_reported") tvar("treat_pros_pressure") prefix("b_ar")
    extract_result, variant("B") spec("pressure") outcome("told_to_report") tvar("treat_pros_pressure") prefix("b_tr")
    extract_result, variant("B") spec("pressure") outcome("pct_told_to_report") tvar("treat_pros_pressure") prefix("b_pct")
restore


* =============================================================================
* Helper: format coefficient with significance stars
* =============================================================================
capture program drop fmt_coef
program define fmt_coef, rclass
    syntax , b(real) se(real) p(real) fmt(string)

    local bfmt : di `fmt' `b'
    local bfmt = strtrim("`bfmt'")

    if `p' < 0.01 {
        local stars "\sym{***}"
    }
    else if `p' < 0.05 {
        local stars "\sym{**}"
    }
    else if `p' < 0.10 {
        local stars "\sym{*}"
    }
    else {
        local stars ""
    }

    local sefmt : di `fmt' `se'
    local sefmt = strtrim("`sefmt'")

    return local coef "`bfmt'`stars'"
    return local se "(`sefmt')"
end


* =============================================================================
* TABLE A17: Caseload Falsification
* =============================================================================
di as text _n "  Building Table A17: Caseload Falsification..."

* Format cells
fmt_coef, b($f_t1_b) se($f_t1_se) p($f_t1_p) fmt(%9.1f)
local b1 "`r(coef)'"
local s1 "`r(se)'"

fmt_coef, b($f_t2c_b) se($f_t2c_se) p($f_t2c_p) fmt(%9.1f)
local b2 "`r(coef)'"
local s2 "`r(se)'"

fmt_coef, b($f_t2u_b) se($f_t2u_se) p($f_t2u_p) fmt(%9.1f)
local b3 "`r(coef)'"
local s3 "`r(se)'"

local depvar : di %9.1f $m_incoming
local depvar = strtrim("`depvar'")

* Write table
tempname t
file open `t' using "`texdir'/mi_tableA17_caseload_falsification.tex", write replace

file write `t' "% Table A17: Caseload Falsification Test" _n
file write `t' "% Generated by 11_caseload_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Caseload Falsification: Electoral Pressure and Incoming Felony Cases}" _n
file write `t' "\label{tab:caseload-falsification}" _n
file write `t' "\begin{tabular}{l*{3}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\" _n
file write `t' " & \multicolumn{1}{c}{Pressure} & \multicolumn{1}{c}{Contested} & \multicolumn{1}{c}{Uncontested} \\" _n
file write `t' "\midrule" _n
file write `t' "Electoral pressure & `b1' & & \\" _n
file write `t' "                   & `s1' & & \\[0.3em]" _n
file write `t' "Contested general  & & `b2' & \\" _n
file write `t' "                   & & `s2' & \\[0.3em]" _n
file write `t' "Uncontested        & & & `b3' \\" _n
file write `t' "                   & & & `s3' \\" _n
file write `t' "\midrule" _n
file write `t' "Dep.\ var.\ mean   & `depvar' & `depvar' & `depvar' \\" _n
file write `t' "County FE          & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes \\" _n
file write `t' "\$N\$                & " %9.0f ($f_t1_n) " & " %9.0f ($f_t2c_n) " & " %9.0f ($f_t2c_n) " \\" _n
file write `t' "Clusters           & 83 & 83 & 83 \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{4}{l}{\scriptsize Dependent variable: incoming circuit court felony cases (FC + FH).} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize County and year FE. SEs clustered at county level.} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA17_caseload_falsification.tex written"


* =============================================================================
* TABLE A18: Jury Mobilization with Caseload Control
* =============================================================================
di as text _n "  Building Table A18: Jury Mobilization with Caseload Control..."

* Format baseline cells
fmt_coef, b($b_ar_b) se($b_ar_se) p($b_ar_p) fmt(%9.1f)
local bar "`r(coef)'"
local sar "`r(se)'"

fmt_coef, b($b_tr_b) se($b_tr_se) p($b_tr_p) fmt(%9.1f)
local btr "`r(coef)'"
local str "`r(se)'"

fmt_coef, b($b_pct_b) se($b_pct_se) p($b_pct_p) fmt(%9.3f)
local bpct "`r(coef)'"
local spct "`r(se)'"

* Format controlled cells
fmt_coef, b($c_ar_b) se($c_ar_se) p($c_ar_p) fmt(%9.1f)
local car "`r(coef)'"
local csar "`r(se)'"

fmt_coef, b($c_tr_b) se($c_tr_se) p($c_tr_p) fmt(%9.1f)
local ctr "`r(coef)'"
local cstr "`r(se)'"

fmt_coef, b($c_pct_b) se($c_pct_se) p($c_pct_p) fmt(%9.3f)
local cpct "`r(coef)'"
local cspct "`r(se)'"

* Dep var means
local m1 : di %9.1f $m_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_pct_told_to_report
local m3 = strtrim("`m3'")

* Write table
tempname t
file open `t' using "`texdir'/mi_tableA18_caseload_control.tex", write replace

file write `t' "% Table A18: Jury Mobilization with Caseload Control" _n
file write `t' "% Generated by 11_caseload_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Jury Mobilization Robustness: Controlling for Criminal Caseload}" _n
file write `t' "\label{tab:caseload-control}" _n
file write `t' "\begin{tabular}{l*{3}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\" _n
file write `t' " & \multicolumn{1}{c}{Act.\ Reported} & \multicolumn{1}{c}{Told to Report} & \multicolumn{1}{c}{\% Told to Report} \\" _n
file write `t' "\midrule" _n
file write `t' "\multicolumn{4}{l}{\textit{Panel A: Baseline specification}} \\[0.1em]" _n
file write `t' "Electoral pressure & `bar' & `btr' & `bpct' \\" _n
file write `t' "                   & `sar' & `str' & `spct' \\[0.5em]" _n
file write `t' "\multicolumn{4}{l}{\textit{Panel B: + log(pending felony caseload)}} \\[0.1em]" _n
file write `t' "Electoral pressure & `car' & `ctr' & `cpct' \\" _n
file write `t' "                   & `csar' & `cstr' & `cspct' \\" _n
file write `t' "\midrule" _n
file write `t' "Dep.\ var.\ mean   & `m1' & `m2' & `m3' \\" _n
file write `t' "County FE          & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes \\" _n
file write `t' "Caseload control   & Panel B only & Panel B only & Panel B only \\" _n
file write `t' "\$N\$                & " %9.0f ($b_ar_n) " & " %9.0f ($b_ar_n) " & " %9.0f ($b_pct_n) " \\" _n
file write `t' "Clusters           & 83 & 83 & 83 \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{4}{l}{\scriptsize Caseload control: log(pending circuit court felony cases + 1), contemporaneous.} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize County and year FE. SEs clustered at county level.} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA18_caseload_control.tex written"


* =============================================================================
* TABLE A19: Caseload Timing & Mechanism
*   Col 1: Incoming_{t-1} (placebo)
*   Col 2: Clearance rate (current)
*   Col 3: Clearance rate_{t+1} (lead, T1)
*   Col 4: Clearance rate_{t+1} (lead, T2 contested)
*   Col 5: Clearance rate_{t+1} (lead, T2 uncontested)
* =============================================================================
di as text _n "  Building Table A19: Caseload Timing & Mechanism..."

* Format cells
fmt_coef, b($lag_t1_b) se($lag_t1_se) p($lag_t1_p) fmt(%9.1f)
local blag "`r(coef)'"
local slag "`r(se)'"

fmt_coef, b($cr_t1_b) se($cr_t1_se) p($cr_t1_p) fmt(%9.3f)
local bcr "`r(coef)'"
local scr "`r(se)'"

fmt_coef, b($crl_t1_b) se($crl_t1_se) p($crl_t1_p) fmt(%9.3f)
local bcrl "`r(coef)'"
local scrl "`r(se)'"

fmt_coef, b($crl_t2c_b) se($crl_t2c_se) p($crl_t2c_p) fmt(%9.3f)
local bcrlc "`r(coef)'"
local scrlc "`r(se)'"

fmt_coef, b($crl_t2u_b) se($crl_t2u_se) p($crl_t2u_p) fmt(%9.3f)
local bcrlu "`r(coef)'"
local scrlu "`r(se)'"

* Dep var means
local mlag : di %9.1f $m_incoming_lag
local mlag = strtrim("`mlag'")
local mcr : di %9.3f $m_clearance
local mcr = strtrim("`mcr'")
local mcrl : di %9.3f $m_clearance_lead
local mcrl = strtrim("`mcrl'")

* Write table
tempname t
file open `t' using "`texdir'/mi_tableA19_caseload_timing.tex", write replace

file write `t' "% Table A19: Caseload Timing & Mechanism" _n
file write `t' "% Generated by 11_caseload_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Caseload Timing and Case Resolution Mechanism}" _n
file write `t' "\label{tab:caseload-timing}" _n
file write `t' "\begin{tabular}{l*{3}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} \\" _n
file write `t' " & \multicolumn{1}{c}{Incoming\$_{t-1}\$} & \multicolumn{1}{c}{Clearance\$_t\$} & \multicolumn{1}{c}{Clearance\$_{t+1}\$} \\" _n
file write `t' "\midrule" _n
file write `t' "\multicolumn{4}{l}{\textit{Panel A: Electoral pressure (T1)}} \\[0.1em]" _n
file write `t' "Electoral pressure & `blag' & `bcr' & `bcrl' \\" _n
file write `t' "                   & `slag' & `scr' & `scrl' \\[0.5em]" _n
file write `t' "\multicolumn{4}{l}{\textit{Panel B: Competition decomposition (T2, clearance\$_{t+1}\$ only)}} \\[0.1em]" _n
file write `t' "Contested general  & & & `bcrlc' \\" _n
file write `t' "                   & & & `scrlc' \\[0.3em]" _n
file write `t' "Uncontested        & & & `bcrlu' \\" _n
file write `t' "                   & & & `scrlu' \\" _n
file write `t' "\midrule" _n
file write `t' "Dep.\ var.\ mean   & `mlag' & `mcr' & `mcrl' \\" _n
file write `t' "County FE          & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes \\" _n
file write `t' "\$N\$                & " %9.0f ($lag_t1_n) " & " %9.0f ($cr_t1_n) " & " %9.0f ($crl_t1_n) " \\" _n
file write `t' "Clusters           & 83 & 81 & 82 \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{4}{l}{\scriptsize Col.\ (1): placebo test (DV is prior-year incoming cases). Cols.\ (2)--(3): clearance rate = outgoing/incoming,} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize derived from stock-flow identity. Lead/lag outcomes as DVs do not induce Nickell (1981) bias, but with} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize \$T\$=7 and 2 treated cycles, results should be interpreted as suggestive. SEs clustered at county level.} \\" _n
file write `t' "\multicolumn{4}{l}{\scriptsize \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA19_caseload_timing.tex written"


di as text _n "========================================================"
di as text   "  11_caseload_tables.do COMPLETE"
di as text   "========================================================"
