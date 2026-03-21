/*==============================================================================
  13_plea_fc_fh_tables.do

  Purpose:  Generate LaTeX tables for capital vs non-capital felony plea
            composition — the headline disaggregated finding.

            Table 5 (MAIN): FC plea share decline + FC jury verdict increase
            Table A.22: FC population split (above/below median)

  Input:    $OUTPUT/results/mi_plea_fc_fh_results.csv

  Output:   $OL/files/tab/mi_conference/mi_table5_plea_fc.tex
            $OL/files/tab/mi_conference/mi_tableA22_plea_popsplit.tex
==============================================================================*/

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
di as text   "  13_plea_fc_fh_tables.do"
di as text   "========================================================"


* =============================================================================
* Load results + extract cells
* =============================================================================

preserve
    import delimited "$OUTPUT/results/mi_plea_fc_fh_results.csv", clear varnames(1)

    capture program drop extract_result
    program define extract_result
        syntax , variant(string) spec(string) outcome(string) tvar(string) prefix(string)
        qui count if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'"
        if r(N) == 0 {
            global `prefix'_b = .
            global `prefix'_se = .
            global `prefix'_p = .
            global `prefix'_n = .
            exit
        }
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

    * === TABLE 5 cells ===
    * FC T1
    extract_result, variant("FC") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("fc_ps")
    extract_result, variant("FC") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("fc_jo")
    extract_result, variant("FC") spec("pressure") outcome("jury_share") tvar("treat_pros_pressure") prefix("fc_js")
    * FH T1
    extract_result, variant("FH") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("fh_ps")
    extract_result, variant("FH") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("fh_jo")
    * FC T2
    extract_result, variant("FC") spec("contested_long") outcome("plea_share") tvar("treat_pros_contested_long") prefix("fc_ps_c")
    extract_result, variant("FC") spec("contested_long") outcome("plea_share") tvar("treat_pros_uncontested") prefix("fc_ps_u")
    extract_result, variant("FC") spec("contested_long") outcome("jury_only") tvar("treat_pros_contested_long") prefix("fc_jo_c")
    extract_result, variant("FC") spec("contested_long") outcome("jury_only") tvar("treat_pros_uncontested") prefix("fc_jo_u")
    * FC T3
    extract_result, variant("FC") spec("contested") outcome("plea_share") tvar("treat_pros_contested") prefix("fc_ps_t3c")
    extract_result, variant("FC") spec("contested") outcome("plea_share") tvar("treat_pros_uncontested") prefix("fc_ps_t3u")

    * === TABLE A.22 cells (pop split) ===
    extract_result, variant("FC_LARGE") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("fcl_ps")
    extract_result, variant("FC_SMALL") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("fcs_ps")
    extract_result, variant("FC_LARGE") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("fcl_jo")
    extract_result, variant("FC_SMALL") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("fcs_jo")
    extract_result, variant("FC_SMALL") spec("pressure") outcome("jury_share") tvar("treat_pros_pressure") prefix("fcs_js")
    extract_result, variant("FC_LARGE") spec("pressure") outcome("jury_share") tvar("treat_pros_pressure") prefix("fcl_js")
restore


* =============================================================================
* Helper
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
* TABLE 5: Capital vs Non-Capital Plea Composition (MAIN TABLE)
* =============================================================================
di as text _n "  Building Table 5: FC vs FH Plea Composition..."

* Format cells
fmt_coef, b($fc_ps_b) se($fc_ps_se) p($fc_ps_p) fmt(%9.3f)
local a1 "`r(coef)'"
local sa1 "`r(se)'"

fmt_coef, b($fc_jo_b) se($fc_jo_se) p($fc_jo_p) fmt(%9.1f)
local a2 "`r(coef)'"
local sa2 "`r(se)'"

fmt_coef, b($fc_js_b) se($fc_js_se) p($fc_js_p) fmt(%9.3f)
local a3 "`r(coef)'"
local sa3 "`r(se)'"

fmt_coef, b($fh_ps_b) se($fh_ps_se) p($fh_ps_p) fmt(%9.3f)
local a4 "`r(coef)'"
local sa4 "`r(se)'"

fmt_coef, b($fh_jo_b) se($fh_jo_se) p($fh_jo_p) fmt(%9.1f)
local a5 "`r(coef)'"
local sa5 "`r(se)'"

* T2 contested/uncontested
fmt_coef, b($fc_ps_c_b) se($fc_ps_c_se) p($fc_ps_c_p) fmt(%9.3f)
local b1 "`r(coef)'"
local sb1 "`r(se)'"

fmt_coef, b($fc_ps_u_b) se($fc_ps_u_se) p($fc_ps_u_p) fmt(%9.3f)
local b2 "`r(coef)'"
local sb2 "`r(se)'"

fmt_coef, b($fc_jo_c_b) se($fc_jo_c_se) p($fc_jo_c_p) fmt(%9.1f)
local b3 "`r(coef)'"
local sb3 "`r(se)'"

fmt_coef, b($fc_jo_u_b) se($fc_jo_u_se) p($fc_jo_u_p) fmt(%9.1f)
local b4 "`r(coef)'"
local sb4 "`r(se)'"

* T3
fmt_coef, b($fc_ps_t3c_b) se($fc_ps_t3c_se) p($fc_ps_t3c_p) fmt(%9.3f)
local c1 "`r(coef)'"
local sc1 "`r(se)'"

fmt_coef, b($fc_ps_t3u_b) se($fc_ps_t3u_se) p($fc_ps_t3u_p) fmt(%9.3f)
local c2 "`r(coef)'"
local sc2 "`r(se)'"

tempname t
file open `t' using "`texdir'/mi_table5_plea_fc.tex", write replace

file write `t' "% Table 5: Capital vs Non-Capital Felony Plea Composition" _n
file write `t' "% Generated by 13_plea_fc_fh_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Electoral Pressure and Case Resolution: Capital vs.\ Non-Capital Felonies}" _n
file write `t' "\label{tab:plea-fc}" _n
file write `t' "\begin{tabular}{l*{5}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{3}{c}{Capital Felonies (FC)} & \multicolumn{2}{c}{Non-Capital (FH)} \\" _n
file write `t' "\cmidrule(lr){2-4}\cmidrule(lr){5-6}" _n
file write `t' " & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} \\" _n
file write `t' " & \multicolumn{1}{c}{Plea Share} & \multicolumn{1}{c}{Jury Verdicts} & \multicolumn{1}{c}{Jury Share} & \multicolumn{1}{c}{Plea Share} & \multicolumn{1}{c}{Jury Verdicts} \\" _n
file write `t' "\midrule" _n
file write `t' "\multicolumn{6}{l}{\textit{Panel A: Electoral pressure (T1)}} \\[0.1em]" _n
file write `t' "Electoral pressure & `a1' & `a2' & `a3' & `a4' & `a5' \\" _n
file write `t' "                   & `sa1' & `sa2' & `sa3' & `sa4' & `sa5' \\[0.5em]" _n
file write `t' "\multicolumn{6}{l}{\textit{Panel B: Competition decomposition (T2, capital felonies only)}} \\[0.1em]" _n
file write `t' "Contested general  & `b1' & `b3' & & & \\" _n
file write `t' "                   & `sb1' & `sb3' & & & \\[0.3em]" _n
file write `t' "Uncontested        & `b2' & `b4' & & & \\" _n
file write `t' "                   & `sb2' & `sb4' & & & \\[0.5em]" _n
file write `t' "\multicolumn{6}{l}{\textit{Panel C: Any-stage contested (T3, capital felonies only)}} \\[0.1em]" _n
file write `t' "Contested any      & `c1' & & & & \\" _n
file write `t' "                   & `sc1' & & & & \\[0.3em]" _n
file write `t' "Uncontested        & `c2' & & & & \\" _n
file write `t' "                   & `sc2' & & & & \\" _n
file write `t' "\midrule" _n
file write `t' "County FE          & Yes & Yes & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes & Yes & Yes \\" _n
file write `t' "\$N\$                & " %9.0f ($fc_ps_n) " & " %9.0f ($fc_jo_n) " & " %9.0f ($fc_js_n) " & " %9.0f ($fh_ps_n) " & " %9.0f ($fh_jo_n) " \\" _n
file write `t' "Clusters           & 80 & 81 & 80 & 81 & 81 \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{6}{l}{\scriptsize Capital felonies (FC): life-sentence-eligible. Non-capital (FH): all other felonies.} \\" _n
file write `t' "\multicolumn{6}{l}{\scriptsize Plea share = guilty pleas / (pleas + trials). Circuit courts only.} \\" _n
file write `t' "\multicolumn{6}{l}{\scriptsize County and year FE. SEs clustered at county level. \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_table5_plea_fc.tex written"


* =============================================================================
* TABLE A.22: Population Split — Capital Felony Plea Composition
* =============================================================================
di as text _n "  Building Table A22: FC Population Split..."

fmt_coef, b($fcl_ps_b) se($fcl_ps_se) p($fcl_ps_p) fmt(%9.3f)
local l1 "`r(coef)'"
local sl1 "`r(se)'"

fmt_coef, b($fcs_ps_b) se($fcs_ps_se) p($fcs_ps_p) fmt(%9.3f)
local s1 "`r(coef)'"
local ss1 "`r(se)'"

fmt_coef, b($fcl_jo_b) se($fcl_jo_se) p($fcl_jo_p) fmt(%9.1f)
local l2 "`r(coef)'"
local sl2 "`r(se)'"

fmt_coef, b($fcs_jo_b) se($fcs_jo_se) p($fcs_jo_p) fmt(%9.1f)
local s2 "`r(coef)'"
local ss2 "`r(se)'"

fmt_coef, b($fcs_js_b) se($fcs_js_se) p($fcs_js_p) fmt(%9.3f)
local s3 "`r(coef)'"
local ss3 "`r(se)'"

fmt_coef, b($fcl_js_b) se($fcl_js_se) p($fcl_js_p) fmt(%9.3f)
local l3 "`r(coef)'"
local sl3 "`r(se)'"

tempname t
file open `t' using "`texdir'/mi_tableA22_plea_popsplit.tex", write replace

file write `t' "% Table A22: Capital Felony Plea Composition — Population Split" _n
file write `t' "% Generated by 13_plea_fc_fh_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Capital Felony Plea Composition: Large vs.\ Small Counties}" _n
file write `t' "\label{tab:plea-popsplit}" _n
file write `t' "\begin{tabular}{l*{3}{c}*{3}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{3}{c}{Large Counties} & \multicolumn{3}{c}{Small Counties} \\" _n
file write `t' "\cmidrule(lr){2-4}\cmidrule(lr){5-7}" _n
file write `t' " & \multicolumn{1}{c}{Plea Share} & \multicolumn{1}{c}{Jury} & \multicolumn{1}{c}{Jury Share} & \multicolumn{1}{c}{Plea Share} & \multicolumn{1}{c}{Jury} & \multicolumn{1}{c}{Jury Share} \\" _n
file write `t' "\midrule" _n
file write `t' "Electoral pressure & `l1' & `l2' & `l3' & `s1' & `s2' & `s3' \\" _n
file write `t' "                   & `sl1' & `sl2' & `sl3' & `ss1' & `ss2' & `ss3' \\" _n
file write `t' "\midrule" _n
file write `t' "County FE          & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write `t' "\$N\$                & " %9.0f ($fcl_ps_n) " & " %9.0f ($fcl_jo_n) " & " %9.0f ($fcl_js_n) " & " %9.0f ($fcs_ps_n) " & " %9.0f ($fcs_jo_n) " & " %9.0f ($fcs_js_n) " \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{7}{l}{\scriptsize Capital felonies (FC) only. Population split at median county population.} \\" _n
file write `t' "\multicolumn{7}{l}{\scriptsize County and year FE. SEs clustered at county level. \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA22_plea_popsplit.tex written"


di as text _n "========================================================"
di as text   "  13_plea_fc_fh_tables.do COMPLETE"
di as text   "========================================================"
