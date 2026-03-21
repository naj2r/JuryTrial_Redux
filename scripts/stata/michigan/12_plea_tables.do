/*==============================================================================
  12_plea_tables.do

  Purpose:  Generate LaTeX tables for plea vs. trial composition analysis.
            Table A.20: Plea composition — felony + misdemeanor + combined
            Table A.21: Court-level plea composition (appendix deep dive)

  Input:    $OUTPUT/results/mi_plea_composition_results.csv
            $DATA_INT/mi_plea_composition_*.dta (for dep var means)

  Output:   $OL/files/tab/mi_conference/mi_tableA20_plea_composition.tex
            $OL/files/tab/mi_conference/mi_tableA21_plea_court_level.tex

  Requires: 07e_plea_composition.do must have run.
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
di as text   "  12_plea_tables.do — Building plea composition tables"
di as text   "========================================================"


* =============================================================================
* PHASE 1: Compute dep var means
* =============================================================================

* Felony means (merge with jury panel years only)
use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using "$DATA_INT/mi_plea_composition_felony.dta", ///
    keepusing(plea_share jury_only trial_total plea_total) keep(match) nogen
foreach v in plea_share jury_only trial_total plea_total {
    qui sum `v', meanonly
    global m_f_`v' = r(mean)
}

* Misdemeanor means
use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using "$DATA_INT/mi_plea_composition_misdemeanor.dta", ///
    keepusing(plea_share jury_only trial_total plea_total) keep(match) nogen
foreach v in plea_share jury_only trial_total plea_total {
    qui sum `v', meanonly
    global m_m_`v' = r(mean)
}


* =============================================================================
* PHASE 2: Load results and extract cells
* =============================================================================

preserve
    import delimited "$OUTPUT/results/mi_plea_composition_results.csv", clear varnames(1)

    capture program drop extract_result
    program define extract_result
        syntax , variant(string) spec(string) outcome(string) tvar(string) prefix(string)
        qui sum beta if variant == "`variant'" & spec_name == "`spec'" ///
            & outcome == "`outcome'" & treatment_var == "`tvar'", meanonly
        if r(N) == 0 {
            global `prefix'_b = .
            global `prefix'_se = .
            global `prefix'_p = .
            global `prefix'_n = .
            exit
        }
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

    * === TABLE A.20 cells ===
    * Felony T1
    extract_result, variant("FELONY") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("f_ps")
    extract_result, variant("FELONY") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("f_jo")
    extract_result, variant("FELONY") spec("pressure") outcome("plea_total") tvar("treat_pros_pressure") prefix("f_pt")

    * Misdemeanor T1
    extract_result, variant("MISDEM") spec("pressure") outcome("plea_share") tvar("treat_pros_pressure") prefix("m_ps")
    extract_result, variant("MISDEM") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("m_jo")
    extract_result, variant("MISDEM") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("m_ljo")
    extract_result, variant("MISDEM") spec("pressure") outcome("plea_total") tvar("treat_pros_pressure") prefix("m_pt")

    * Misdemeanor T2 contested
    extract_result, variant("MISDEM") spec("contested_long") outcome("jury_only") tvar("treat_pros_contested_long") prefix("m_ljo_c")
    extract_result, variant("MISDEM") spec("contested_long") outcome("jury_only") tvar("treat_pros_uncontested") prefix("m_ljo_u")

    * === TABLE A.21 cells (court-level) ===
    extract_result, variant("COURT_MISDEM") spec("pressure") outcome("jury_only") tvar("treat_pros_pressure") prefix("cm_ljo")
    extract_result, variant("COURT_MISDEM") spec("pressure") outcome("plea_total") tvar("treat_pros_pressure") prefix("cm_pt")
    extract_result, variant("COURT_MISDEM") spec("contested_long") outcome("jury_only") tvar("treat_pros_contested_long") prefix("cm_ljo_c")
    extract_result, variant("COURT_MISDEM") spec("contested_long") outcome("jury_only") tvar("treat_pros_uncontested") prefix("cm_ljo_u")
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
* TABLE A.20: Plea Composition — County Level
* =============================================================================
di as text _n "  Building Table A20: Plea Composition..."

* Format felony cells
fmt_coef, b($f_ps_b) se($f_ps_se) p($f_ps_p) fmt(%9.3f)
local fps "`r(coef)'"
local sfps "`r(se)'"

fmt_coef, b($f_jo_b) se($f_jo_se) p($f_jo_p) fmt(%9.1f)
local fjo "`r(coef)'"
local sfjo "`r(se)'"

fmt_coef, b($f_pt_b) se($f_pt_se) p($f_pt_p) fmt(%9.1f)
local fpt "`r(coef)'"
local sfpt "`r(se)'"

* Format misdemeanor cells
fmt_coef, b($m_ps_b) se($m_ps_se) p($m_ps_p) fmt(%9.3f)
local mps "`r(coef)'"
local smps "`r(se)'"

fmt_coef, b($m_jo_b) se($m_jo_se) p($m_jo_p) fmt(%9.1f)
local mjo "`r(coef)'"
local smjo "`r(se)'"

fmt_coef, b($m_ljo_b) se($m_ljo_se) p($m_ljo_p) fmt(%9.3f)
local mljo "`r(coef)'"
local smljo "`r(se)'"

fmt_coef, b($m_pt_b) se($m_pt_se) p($m_pt_p) fmt(%9.1f)
local mpt "`r(coef)'"
local smpt "`r(se)'"

* Format T2 contested misdemeanor cells
fmt_coef, b($m_ljo_c_b) se($m_ljo_c_se) p($m_ljo_c_p) fmt(%9.3f)
local mljoc "`r(coef)'"
local smljoc "`r(se)'"

fmt_coef, b($m_ljo_u_b) se($m_ljo_u_se) p($m_ljo_u_p) fmt(%9.3f)
local mljou "`r(coef)'"
local smljou "`r(se)'"

* Dep var means
local mfps : di %9.3f $m_f_plea_share
local mfps = strtrim("`mfps'")
local mfjo : di %9.1f $m_f_jury_only
local mfjo = strtrim("`mfjo'")
local mfpt : di %9.1f $m_f_plea_total
local mfpt = strtrim("`mfpt'")
local mmps : di %9.3f $m_m_plea_share
local mmps = strtrim("`mmps'")
local mmjo : di %9.1f $m_m_jury_only
local mmjo = strtrim("`mmjo'")
local mmljo : di %9.1f $m_m_jury_only
local mmljo = strtrim("`mmljo'")
local mmpt : di %9.1f $m_m_plea_total
local mmpt = strtrim("`mmpt'")

* Write table
tempname t
file open `t' using "`texdir'/mi_tableA20_plea_composition.tex", write replace

file write `t' "% Table A20: Plea vs Trial Composition" _n
file write `t' "% Generated by 12_plea_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Electoral Pressure and Case Resolution Composition}" _n
file write `t' "\label{tab:plea-composition}" _n
file write `t' "\begin{tabular}{l*{4}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{2}{c}{Circuit Court Felonies} & \multicolumn{2}{c}{District Court Misdemeanors} \\" _n
file write `t' "\cmidrule(lr){2-3}\cmidrule(lr){4-5}" _n
file write `t' " & \multicolumn{1}{c}{(1) Plea Share} & \multicolumn{1}{c}{(2) Jury Verdicts} & \multicolumn{1}{c}{(3) Plea Share} & \multicolumn{1}{c}{(4) Jury Verdicts} \\" _n
file write `t' "\midrule" _n
file write `t' "\multicolumn{5}{l}{\textit{Panel A: Electoral pressure (T1)}} \\[0.1em]" _n
file write `t' "Electoral pressure & `fps' & `fjo' & `mps' & `mljo' \\" _n
file write `t' "                   & `sfps' & `sfjo' & `smps' & `smljo' \\[0.5em]" _n
file write `t' "\multicolumn{5}{l}{\textit{Panel B: Competition decomposition (T2, misdemeanor jury verdicts only)}} \\[0.1em]" _n
file write `t' "Contested general  & & & & `mljoc' \\" _n
file write `t' "                   & & & & `smljoc' \\[0.3em]" _n
file write `t' "Uncontested        & & & & `mljou' \\" _n
file write `t' "                   & & & & `smljou' \\" _n
file write `t' "\midrule" _n
file write `t' "Dep.\ var.\ mean   & `mfps' & `mfjo' & `mmps' & `mmljo' \\" _n
file write `t' "County FE          & Yes & Yes & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes & Yes & Yes \\" _n
file write `t' "\$N\$                & " %9.0f ($f_ps_n) " & " %9.0f ($f_jo_n) " & " %9.0f ($m_ps_n) " & " %9.0f ($m_ljo_n) " \\" _n
file write `t' "Clusters           & 83 & 83 & 83 & 83 \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{5}{l}{\scriptsize Felony: FC + FH case types at circuit courts. Misdemeanor: SD + SM at district courts.} \\" _n
file write `t' "\multicolumn{5}{l}{\scriptsize Plea share = guilty pleas / (pleas + trials). Jury = jury verdicts only.} \\" _n
file write `t' "\multicolumn{5}{l}{\scriptsize County and year FE. SEs clustered at county level. \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA20_plea_composition.tex written"


* =============================================================================
* TABLE A.21: Court-Level Plea Composition
* =============================================================================
di as text _n "  Building Table A21: Court-Level Plea Composition..."

fmt_coef, b($cm_ljo_b) se($cm_ljo_se) p($cm_ljo_p) fmt(%9.3f)
local cmljo "`r(coef)'"
local scmljo "`r(se)'"

fmt_coef, b($cm_pt_b) se($cm_pt_se) p($cm_pt_p) fmt(%9.1f)
local cmpt "`r(coef)'"
local scmpt "`r(se)'"

fmt_coef, b($cm_ljo_c_b) se($cm_ljo_c_se) p($cm_ljo_c_p) fmt(%9.3f)
local cmljoc "`r(coef)'"
local scmljoc "`r(se)'"

fmt_coef, b($cm_ljo_u_b) se($cm_ljo_u_se) p($cm_ljo_u_p) fmt(%9.3f)
local cmljou "`r(coef)'"
local scmljou "`r(se)'"

tempname t
file open `t' using "`texdir'/mi_tableA21_plea_court_level.tex", write replace

file write `t' "% Table A21: Court-Level Plea Composition" _n
file write `t' "% Generated by 12_plea_tables.do on $S_DATE $S_TIME" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\begin{table}[htbp]" _n
file write `t' "\centering" _n
file write `t' "\caption{Court-Level Misdemeanor Case Resolution (District Courts)}" _n
file write `t' "\label{tab:plea-court-level}" _n
file write `t' "\begin{tabular}{l*{2}{c}}" _n
file write `t' "\toprule" _n
file write `t' " & \multicolumn{1}{c}{(1) ln(Jury Verdicts)} & \multicolumn{1}{c}{(2) Plea Volume} \\" _n
file write `t' "\midrule" _n
file write `t' "\multicolumn{3}{l}{\textit{Panel A: Electoral pressure (T1)}} \\[0.1em]" _n
file write `t' "Electoral pressure & `cmljo' & `cmpt' \\" _n
file write `t' "                   & `scmljo' & `scmpt' \\[0.5em]" _n
file write `t' "\multicolumn{3}{l}{\textit{Panel B: Competition decomposition (T2)}} \\[0.1em]" _n
file write `t' "Contested general  & `cmljoc' & \\" _n
file write `t' "                   & `scmljoc' & \\[0.3em]" _n
file write `t' "Uncontested        & `cmljou' & \\" _n
file write `t' "                   & `scmljou' & \\" _n
file write `t' "\midrule" _n
file write `t' "Court FE           & Yes & Yes \\" _n
file write `t' "Year FE            & Yes & Yes \\" _n
file write `t' "Cluster            & County & County \\" _n
file write `t' "\$N\$                & " %9.0f ($cm_ljo_n) " & " %9.0f ($cm_pt_n) " \\" _n
file write `t' "\bottomrule" _n
file write `t' "\multicolumn{3}{l}{\scriptsize Court-level FE with county-level clustering. District courts (SD + SM).} \\" _n
file write `t' "\multicolumn{3}{l}{\scriptsize \sym{*} \$p\$<0.10, \sym{**} \$p\$<0.05, \sym{***} \$p\$<0.01} \\" _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di "  → mi_tableA21_plea_court_level.tex written"


di as text _n "========================================================"
di as text   "  12_plea_tables.do COMPLETE"
di as text   "========================================================"
