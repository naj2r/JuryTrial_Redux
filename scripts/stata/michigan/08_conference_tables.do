/*==================================================================
  08_conference_tables.do

  Purpose:  Generate conference-ready LaTeX regression tables from
            the results CSV produced by 07_regressions.do

  Input:    $OUTPUT/results/mi_regression_results.csv
            $DATA_FINAL/michigan_panel_A.dta  (for dep var means)
            $DATA_FINAL/michigan_panel_B.dta  (for dep var means)
            $DATA_FINAL/michigan_court_level.dta (for dep var means)

  Output:  11 .tex files → Overleaf project mi_conference/ folder
            Main:
              (1) mi_table1_pipeline.tex    (T1: mobilization headline)
              (2) mi_table2_competition.tex (T2/T3: competition decomposition)
              (3) mi_table3_verdicts.tex    (T2/T3: verdicts + composition)
              (4) mi_table4_cycle_robust.tex (T1: cycle robustness, 3 cols)
            Appendix:
              (A1) mi_tableA1_robustness.tex  (Variant A)
              (A2) mi_tableA2_nulls.tex       (useful nulls)
              (A3) mi_tableA3_mechanism.tex   (other cases, combined courts)
              (A4) mi_tableA4_scaling.tex     (per 10k)
              (A6) mi_tableA6_popsplit.tex    (pop heterogeneity)
              (A7) mi_tableA7_config.tex      (pipeline configuration summary)
            (A5 removed — no_offcycle exclusion folded into Table 4 Panel D)

  Prereq:   Run 07_regressions.do first to generate the CSV.
            Regressions are NOT re-run here; coefficients read from CSV.

  Notes:
  - Idempotent: re-running overwrites output with identical content
  - Stars: * p<0.10, ** p<0.05, *** p<0.01
  - All formatting decisions are in this file (edit here, not .tex)
  - Dep var means computed from panel data (unconditional sample mean)
==================================================================*/
/* FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies). From SCAO case type codes. */

* ─── Bootstrap: standalone execution ─────────────────────────────
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

* NOTE: Do NOT use `clear all` — it wipes globals set by paths.do.
clear
set more off

local texdir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26/files/tab/mi_conference"
capture mkdir "`texdir'"

di as text _n "========================================================"
di as text   "  08_conference_tables.do — Building LaTeX tables"
di as text   "========================================================"


*===================================================================
* PHASE 1: Compute dependent variable means AND within-unit SDs
*   m_X_var  = unconditional sample mean
*   w_X_var  = within-unit SD (county or court demeaned)
*===================================================================
di as text _n "  Phase 1: Computing dep var means & within-unit SDs..."

* --- Panel B (Variant B: all-courts expanded) ---
use "$DATA_FINAL/michigan_panel_B.dta", clear
foreach v in actually_reported told_to_report pct_told_to_report ///
    utilization_rate total_jury_verdicts capital_felony ///
    other_felony other_cases ///
    pct_other_felony pct_capital_felony pct_other_cases ///
    pct_questioned_in_voir_dire questioned_in_voir_dire ///
    sent_to_courtroom pct_sent_to_courtroom {
    qui sum `v' if !missing(`v'), meanonly
    global m_B_`v' = r(mean)
    * Within-county SD: demean by county, take pooled SD
    tempvar cm dm
    qui bys county_id: egen `cm' = mean(`v')
    qui gen `dm' = `v' - `cm'
    qui sum `dm'
    global w_B_`v' = r(sd)
    drop `cm' `dm'
}
foreach v in actually_reported_p10k total_jury_verdicts_p10k {
    capture confirm variable `v'
    if !_rc {
        qui sum `v' if !missing(`v'), meanonly
        global m_B_`v' = r(mean)
        tempvar cm dm
        qui bys county_id: egen `cm' = mean(`v')
        qui gen `dm' = `v' - `cm'
        qui sum `dm'
        global w_B_`v' = r(sd)
        drop `cm' `dm'
    }
    else {
        global m_B_`v' = .
        global w_B_`v' = .
    }
}
di "    Panel B means + within-county SDs computed."

* --- Panel A (Variant A: felony-focused) ---
use "$DATA_FINAL/michigan_panel_A.dta", clear
foreach v in actually_reported told_to_report pct_told_to_report ///
    capital_felony total_jury_verdicts pct_other_felony {
    qui sum `v' if !missing(`v'), meanonly
    global m_A_`v' = r(mean)
    tempvar cm dm
    qui bys county_id: egen `cm' = mean(`v')
    qui gen `dm' = `v' - `cm'
    qui sum `dm'
    global w_A_`v' = r(sd)
    drop `cm' `dm'
}
di "    Panel A means + within-county SDs computed."

* --- Court Combined (COURT_COMBINED subsample) ---
use "$DATA_FINAL/michigan_court_level.dta", clear
qui keep if court_category == "COMBINED"
foreach v in other_cases {
    qui sum `v' if !missing(`v'), meanonly
    global m_CC_`v' = r(mean)
    tempvar cm dm
    qui bys court_id: egen `cm' = mean(`v')
    qui gen `dm' = `v' - `cm'
    qui sum `dm'
    global w_CC_`v' = r(sd)
    drop `cm' `dm'
}
di "    Court Combined means + within-court SDs computed."

* --- Panel D (Variant D: all-courts county aggregate) ---
use "$DATA_FINAL/michigan_panel_D.dta", clear
foreach v in actually_reported told_to_report pct_told_to_report ///
    total_jury_verdicts pct_capital_felony pct_other_felony {
    qui sum `v' if !missing(`v'), meanonly
    global m_D_`v' = r(mean)
    tempvar cm dm
    qui bys county_id: egen `cm' = mean(`v')
    qui gen `dm' = `v' - `cm'
    qui sum `dm'
    global w_D_`v' = r(sd)
    drop `cm' `dm'
}
di "    Panel D means + within-county SDs computed."

* --- Panel E (Variant E: circuit-court-only county aggregate) ---
use "$DATA_FINAL/michigan_panel_E.dta", clear
foreach v in actually_reported told_to_report pct_told_to_report ///
    total_jury_verdicts pct_capital_felony pct_other_felony {
    qui sum `v' if !missing(`v'), meanonly
    global m_E_`v' = r(mean)
    tempvar cm dm
    qui bys county_id: egen `cm' = mean(`v')
    qui gen `dm' = `v' - `cm'
    qui sum `dm'
    global w_E_`v' = r(sd)
    drop `cm' `dm'
}
di "    Panel E means + within-county SDs computed."


*===================================================================
* PHASE 2: Import regression results CSV
*===================================================================
di as text _n "  Phase 2: Importing regression results..."

local csv "$OUTPUT/results/mi_regression_results.csv"
import delimited using "`csv'", clear varnames(1)

foreach v in beta se p_value n_obs {
    capture confirm numeric variable `v'
    if _rc  destring `v', replace force
}
di "    CSV loaded: " _N " rows."


*===================================================================
* PHASE 2b: Import equality test CSV (for p-equality rows in tables)
*===================================================================
di as text _n "  Phase 2b: Loading equality tests..."

local eq_csv "$OUTPUT/results/mi_equality_tests.csv"
capture confirm file "`eq_csv'"
if _rc {
    di as error "  Equality test CSV not found: `eq_csv'"
    di as error "  Run 07_regressions.do first. p-equality rows will show '.'."
    * Create empty tempfile so cell_eq doesn't crash
    preserve
        clear
        gen str32 variant = ""
        gen str32 spec_name = ""
        gen str40 outcome = ""
        gen float p_equality = .
        tempfile eq_data
        qui save `eq_data'
    restore
}
else {
    preserve
        import delimited using "`eq_csv'", clear varnames(1)
        foreach v in p_equality {
            capture confirm numeric variable `v'
            if _rc  destring `v', replace force
        }
        tempfile eq_data
        qui save `eq_data'
        di "    Equality tests loaded: " _N " rows."
    restore
}

global EQ_TEMP "`eq_data'"


*===================================================================
* PHASE 3: Helper program — extract one regression cell
*===================================================================
*   v  = variant (A / B / COURT_COMBINED)
*   s  = spec_name (pressure / contested_long / contested)
*   o  = outcome variable name
*   f  = Stata display format (%9.1f for counts, %9.3f for rates)
*   tv = (optional) treatment_var filter — REQUIRED for T2/T3 specs
*        where multiple treatment variables produce separate rows
*
*   Returns r(coef) r(se) r(nobs) as formatted strings

capture program drop cell
program define cell, rclass
    args v s o f tv

    * Build filter condition
    local cond `"variant == "`v'" & spec_name == "`s'" & outcome == "`o'""'
    if "`tv'" != "" {
        local cond `"`cond' & treatment_var == "`tv'""'
    }

    qui count if `cond'
    if r(N) == 0 {
        di as error "  [!] No match: variant=`v', spec=`s', outcome=`o', tvar=`tv'"
        return local coef "."
        return local se   "(.)"
        return local nobs "."
        exit
    }
    if r(N) > 1 & "`tv'" == "" {
        di as error "  [WARNING] Multiple rows (" r(N) ") for variant=`v'," ///
            " spec=`s', outcome=`o'. Specify treatment_var as 5th arg."
    }

    qui summ beta    if `cond', meanonly
    local b = r(mean)
    qui summ se      if `cond', meanonly
    local se_val = r(mean)
    qui summ p_value if `cond', meanonly
    local p = r(mean)
    qui summ n_obs   if `cond', meanonly
    local n = r(mean)

    * Format coefficient and SE
    local b_str  : di `f' `b'
    local b_str  = strtrim("`b_str'")
    local se_str : di `f' `se_val'
    local se_str = strtrim("`se_str'")

    * Significance stars
    local stars ""
    if `p' < 0.10 local stars "\sym{*}"
    if `p' < 0.05 local stars "\sym{**}"
    if `p' < 0.01 local stars "\sym{***}"

    * N (integer)
    local n_str : di %9.0f `n'
    local n_str = strtrim("`n_str'")

    return local coef "`b_str'`stars'"
    return local se   "(`se_str')"
    return local nobs "`n_str'"
    return scalar beta_raw = `b'
end


*===================================================================
* Helper program — extract equality test p-value
*   v  = variant (B / B_highpop / B_lowpop / COURT_COMBINED)
*   s  = spec_name (contested_long / contested / contested_long_pop)
*   o  = outcome variable name
*
*   Returns r(peq) as formatted string "[0.xxx]" or "." if not found
*===================================================================

capture program drop cell_eq
program define cell_eq, rclass
    args v s o

    preserve
        qui use "$EQ_TEMP", clear

        local cond `"variant == "`v'" & spec_name == "`s'" & outcome == "`o'""'
        qui count if `cond'
        if r(N) == 0 {
            local result "."
        }
        else {
            qui summ p_equality if `cond', meanonly
            local p = r(mean)
            local p_str : di %5.3f `p'
            local p_str = strtrim("`p_str'")
            local result "[`p_str']"
        }
    restore

    return local peq "`result'"
end


*===================================================================
*  REFERENCE TABLE — Sample Definitions
*  Goes before all other tables in the paper
*===================================================================
di as text _n "  Building Reference Table: Sample Definitions..."

local f "`texdir'/mi_table0_samples.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\caption{Sample Definitions}" _n
file write t "\label{tab:mi_samples}" _n
file write t "\small" _n
file write t "\begin{tabular}{llp{5.5cm}lcc}" _n
file write t "\hline\hline" _n
file write t " & \multicolumn{1}{c}{Sample}" _n
file write t " & \multicolumn{1}{c}{Court Selection Rule}" _n
file write t " & \multicolumn{1}{c}{Unit}" _n
file write t " & \multicolumn{1}{c}{Counties}" _n
file write t " & \multicolumn{1}{c}{Obs} \\" _n
file write t "\hline" _n
file write t " A & Felony-focused" _n
file write t "   & Standalone circuit/probate courts; combined courts used as fallback where no standalone exists" _n
file write t "   & County & 83 & 579 \\[0.5em]" _n
file write t " B & All-courts expanded" _n
file write t "   & Combined court if county has one; otherwise sum of non-combined courts" _n
file write t "   & County & 83 & 579 \\[0.5em]" _n
file write t " C & Combined-only" _n
file write t "   & Combined courts only (counties without a combined court excluded)" _n
file write t "   & County & 44 & 307 \\[0.5em]" _n
file write t " Court & Court-level combined" _n
file write t "       & Combined courts, one observation per court-year" _n
file write t "       & Court & 44 & 306 \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{6}{l}{\footnotesize All panels span 2016--2019 and 2022--2024 (7 years). Michigan has 83 counties.}\\"' _n
file write t `"\multicolumn{6}{l}{\footnotesize 44 of 83 counties operate combined circuit/probate courts.}\\"' _n
file write t `"\multicolumn{6}{l}{\footnotesize County-level panels (A, B, C): county and year fixed effects, SEs clustered by county.}\\"' _n
file write t `"\multicolumn{6}{l}{\footnotesize Court-level panel: court and year fixed effects, SEs clustered by county.}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  DESCRIPTIVE STATISTICS TABLE
*  Sample: Panel B (all-courts expanded, primary specification)
*  Variables: pipeline counts, pipeline rates, verdict outcomes,
*             verdict composition, treatment variables, population
*===================================================================
di as text _n "  Building Descriptive Statistics Table..."

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Construct derived variables if not present
capture confirm variable total_jury_verdicts
if _rc {
    capture confirm variable capital_felony
    if !_rc {
        gen total_jury_verdicts = capital_felony + other_felony + other_cases
    }
}
capture confirm variable pct_capital_felony
if _rc {
    capture confirm variable total_jury_verdicts
    if !_rc {
        gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
        gen pct_other_felony  = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
        gen pct_other_cases   = other_cases    / total_jury_verdicts if total_jury_verdicts > 0
    }
}
capture confirm variable log_county_pop
if _rc {
    capture confirm variable county_pop
    if !_rc {
        gen log_county_pop = ln(county_pop)
    }
}

* ---- Helper program: one summary-stats row ----
capture program drop sumrow
program define sumrow
    args fh varname label fmt
    * Count non-missing
    qui count if !missing(`varname')
    local nn = r(N)
    qui sum `varname' if !missing(`varname')
    local mn : di `fmt' r(mean)
    local mn = strtrim("`mn'")
    local sd : di `fmt' r(sd)
    local sd = strtrim("`sd'")
    local mi : di `fmt' r(min)
    local mi = strtrim("`mi'")
    local ma : di `fmt' r(max)
    local ma = strtrim("`ma'")
    file write `fh' "`label' & `nn' & `mi' & `mn' & `sd' & `ma' \\" _n
end

local f "`texdir'/mi_table_sumstats.tex"
tempname t
file open `t' using "`f'", write replace

file write `t' "\begin{table}[htbp]\centering" _n
file write `t' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `t' "\caption{Descriptive Statistics}" _n
file write `t' "\label{tab:mi_sumstats}" _n
file write `t' "\begin{tabular}{l*{5}{c}}" _n
file write `t' "\hline\hline" _n
file write `t' " &\multicolumn{1}{c}{\textit{N}}" _n
file write `t' " &\multicolumn{1}{c}{Min}" _n
file write `t' " &\multicolumn{1}{c}{Mean}" _n
file write `t' " &\multicolumn{1}{c}{Std.\ Dev.}" _n
file write `t' " &\multicolumn{1}{c}{Max} \\" _n
file write `t' "\hline" _n

* ---- Panel A: Jury Mobilization (Count Variables) ----
file write `t' "\multicolumn{6}{l}{\textit{Panel A: Jury Mobilization (Counts)}} \\[0.3em]" _n
sumrow `t' summoned               "Jurors summoned"                 %9.1f
sumrow `t' told_to_report         "Jurors told to report"           %9.1f
sumrow `t' actually_reported      "Jurors actually reported"        %9.1f
sumrow `t' sent_to_courtroom      "Jurors sent to courtroom"        %9.1f
sumrow `t' questioned_in_voir_dire "Jurors questioned in voir dire" %9.1f
file write `t' "\\[0.5em]" _n

* ---- Panel B: Jury Mobilization (Rate Variables) ----
file write `t' "\multicolumn{6}{l}{\textit{Panel B: Jury Pipeline Rates}} \\[0.3em]" _n
sumrow `t' pct_told_to_report         "\% Told to report"           %9.3f
sumrow `t' utilization_rate            "Utilization rate"            %9.3f
sumrow `t' pct_questioned_in_voir_dire "\% Questioned in voir dire" %9.3f
file write `t' "\\[0.5em]" _n

* ---- Panel C: Verdict Outcomes ----
file write `t' "\multicolumn{6}{l}{\textit{Panel C: Verdict Outcomes}} \\[0.3em]" _n
sumrow `t' total_jury_verdicts "Total jury verdicts"    %9.1f
sumrow `t' capital_felony      "Capital felony verdicts" %9.1f
sumrow `t' other_felony        "Other felony verdicts"   %9.1f
sumrow `t' other_cases         "Other case verdicts"     %9.1f
file write `t' "\\[0.5em]" _n

* ---- Panel D: Verdict Composition ----
file write `t' "\multicolumn{6}{l}{\textit{Panel D: Verdict Composition (Shares)}} \\[0.3em]" _n
sumrow `t' pct_capital_felony "\% Capital felony"  %9.3f
sumrow `t' pct_other_felony   "\% Other felony"    %9.3f
sumrow `t' pct_other_cases    "\% Other cases"     %9.3f
file write `t' "\\[0.5em]" _n

* ---- Panel E: Treatment Variables ----
file write `t' "\multicolumn{6}{l}{\textit{Panel E: Treatment Variables}} \\[0.3em]" _n
sumrow `t' treat_pros_pressure       "Electoral pressure (T1)"               %9.3f
sumrow `t' treat_pros_contested_long "Contested, general election (T2)"      %9.3f
sumrow `t' treat_pros_uncontested    "Uncontested (T2)"                      %9.3f
file write `t' "\\[0.5em]" _n

* ---- Panel F: Controls ----
file write `t' "\multicolumn{6}{l}{\textit{Panel F: Controls}} \\[0.3em]" _n
sumrow `t' county_pop     "County population"       %12.0f
sumrow `t' log_county_pop "Log(county population)"  %9.3f

file write `t' "\hline\hline" _n
file write `t' `"\multicolumn{6}{l}{\footnotesize Sample B: all-courts expanded, 83 counties, 2016--2019 \& 2022--2024.}\\"' _n
file write `t' `"\multicolumn{6}{l}{\footnotesize See Table \ref{tab:mi_samples} for sample definitions.}\\"' _n
file write `t' `"\multicolumn{6}{l}{\footnotesize Rate variables are proportions (0--1). Composition shares condition on total verdicts $> 0$.}\\"' _n
file write `t' `"\multicolumn{6}{l}{\footnotesize T2 treatment variables are defined only in election years; non-election years are missing.}\\"' _n
file write `t' "\end{tabular}" _n
file write `t' "\end{table}" _n

file close `t'
di as text "    Done: `f'"

capture program drop sumrow


*===================================================================
* Re-import regression CSV
*   The sumstats section above loaded .dta panel data, which cleared
*   the CSV from memory. Re-import before building regression tables.
*===================================================================
di as text _n "  Re-importing regression results after sumstats section..."
import delimited using "`csv'", clear varnames(1)
foreach v in beta se p_value n_obs {
    capture confirm numeric variable `v'
    if _rc  destring `v', replace force
}
di "    CSV re-loaded: " _N " rows."


*===================================================================
*  TABLE 1 — Jury Pipeline Headline
*  Variant B | T1 | treat_pros_pressure
*  Columns: (1) actually_reported  (2) told_to_report
*           (3) pct_told_to_report (4) sent_to_courtroom
*           (5) pct_sent_to_courtroom (6) questioned_in_voir_dire
*           (7) pct_questioned_in_voir_dire (8) utilization_rate
*  Row: pressure coefficient
*===================================================================
di as text _n "  Building Table 1: Pipeline Headline..."

cell B pressure actually_reported  %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell B pressure told_to_report     %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell B pressure pct_told_to_report %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

cell B pressure sent_to_courtroom  %9.1f treat_pros_pressure
local b4 "`r(coef)'"
local s4 "`r(se)'"
local n4 "`r(nobs)'"
local beta4 = r(beta_raw)

cell B pressure pct_sent_to_courtroom %9.3f treat_pros_pressure
local b5 "`r(coef)'"
local s5 "`r(se)'"
local n5 "`r(nobs)'"
local beta5 = r(beta_raw)

cell B pressure questioned_in_voir_dire %9.1f treat_pros_pressure
local b6 "`r(coef)'"
local s6 "`r(se)'"
local n6 "`r(nobs)'"
local beta6 = r(beta_raw)

cell B pressure pct_questioned_in_voir_dire %9.3f treat_pros_pressure
local b7 "`r(coef)'"
local s7 "`r(se)'"
local n7 "`r(nobs)'"
local beta7 = r(beta_raw)

cell B pressure utilization_rate   %9.3f treat_pros_pressure
local b8 "`r(coef)'"
local s8 "`r(se)'"
local n8 "`r(nobs)'"
local beta8 = r(beta_raw)

* Controlled spec (+ log population)
cell B pressure_pop actually_reported  %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell B pressure_pop told_to_report     %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell B pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"
cell B pressure_pop sent_to_courtroom  %9.1f treat_pros_pressure
local pb4 "`r(coef)'"
local ps4 "`r(se)'"
cell B pressure_pop pct_sent_to_courtroom %9.3f treat_pros_pressure
local pb5 "`r(coef)'"
local ps5 "`r(se)'"
cell B pressure_pop questioned_in_voir_dire %9.1f treat_pros_pressure
local pb6 "`r(coef)'"
local ps6 "`r(se)'"
cell B pressure_pop pct_questioned_in_voir_dire %9.3f treat_pros_pressure
local pb7 "`r(coef)'"
local ps7 "`r(se)'"
cell B pressure_pop utilization_rate   %9.3f treat_pros_pressure
local pb8 "`r(coef)'"
local ps8 "`r(se)'"

* Open-seat election (T1 decomposition)
cell B pressure actually_reported  %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell B pressure told_to_report     %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell B pressure pct_told_to_report %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"
cell B pressure sent_to_courtroom  %9.1f open_pros
local ob4 "`r(coef)'"
local os4 "`r(se)'"
cell B pressure pct_sent_to_courtroom %9.3f open_pros
local ob5 "`r(coef)'"
local os5 "`r(se)'"
cell B pressure questioned_in_voir_dire %9.1f open_pros
local ob6 "`r(coef)'"
local os6 "`r(se)'"
cell B pressure pct_questioned_in_voir_dire %9.3f open_pros
local ob7 "`r(coef)'"
local os7 "`r(se)'"
cell B pressure utilization_rate   %9.3f open_pros
local ob8 "`r(coef)'"
local os8 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_B_actually_reported
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_B_actually_reported
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_B_told_to_report
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_B_told_to_report
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_B_pct_told_to_report
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_B_pct_told_to_report
local bs3 = strtrim("`bs3'")
local bm4 : di %9.3f `beta4' / $m_B_sent_to_courtroom
local bm4 = strtrim("`bm4'")
local bs4 : di %9.2f `beta4' / $w_B_sent_to_courtroom
local bs4 = strtrim("`bs4'")
local bm5 : di %9.3f `beta5' / $m_B_pct_sent_to_courtroom
local bm5 = strtrim("`bm5'")
local bs5 : di %9.2f `beta5' / $w_B_pct_sent_to_courtroom
local bs5 = strtrim("`bs5'")
local bm6 : di %9.3f `beta6' / $m_B_questioned_in_voir_dire
local bm6 = strtrim("`bm6'")
local bs6 : di %9.2f `beta6' / $w_B_questioned_in_voir_dire
local bs6 = strtrim("`bs6'")
local bm7 : di %9.3f `beta7' / $m_B_pct_questioned_in_voir_dire
local bm7 = strtrim("`bm7'")
local bs7 : di %9.2f `beta7' / $w_B_pct_questioned_in_voir_dire
local bs7 = strtrim("`bs7'")
local bm8 : di %9.3f `beta8' / $m_B_utilization_rate
local bm8 = strtrim("`bm8'")
local bs8 : di %9.2f `beta8' / $w_B_utilization_rate
local bs8 = strtrim("`bs8'")

* Format dep var means
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_told_to_report
local m3 = strtrim("`m3'")
local m4 : di %9.1f $m_B_sent_to_courtroom
local m4 = strtrim("`m4'")
local m5 : di %9.3f $m_B_pct_sent_to_courtroom
local m5 = strtrim("`m5'")
local m6 : di %9.1f $m_B_questioned_in_voir_dire
local m6 = strtrim("`m6'")
local m7 : di %9.3f $m_B_pct_questioned_in_voir_dire
local m7 = strtrim("`m7'")
local m8 : di %9.3f $m_B_utilization_rate
local m8 = strtrim("`m8'")

* --- Panel B: Contested any stage (T3) base ---
cell B contested actually_reported  %9.1f treat_pros_contested
local bb1 "`r(coef)'"
local bse1 "`r(se)'"
local bn1 "`r(nobs)'"
cell B contested told_to_report     %9.1f treat_pros_contested
local bb2 "`r(coef)'"
local bse2 "`r(se)'"
local bn2 "`r(nobs)'"
cell B contested pct_told_to_report %9.3f treat_pros_contested
local bb3 "`r(coef)'"
local bse3 "`r(se)'"
local bn3 "`r(nobs)'"
cell B contested sent_to_courtroom  %9.1f treat_pros_contested
local bb4 "`r(coef)'"
local bse4 "`r(se)'"
local bn4 "`r(nobs)'"
cell B contested pct_sent_to_courtroom %9.3f treat_pros_contested
local bb5 "`r(coef)'"
local bse5 "`r(se)'"
local bn5 "`r(nobs)'"
cell B contested questioned_in_voir_dire %9.1f treat_pros_contested
local bb6 "`r(coef)'"
local bse6 "`r(se)'"
local bn6 "`r(nobs)'"
cell B contested pct_questioned_in_voir_dire %9.3f treat_pros_contested
local bb7 "`r(coef)'"
local bse7 "`r(se)'"
local bn7 "`r(nobs)'"
cell B contested utilization_rate   %9.3f treat_pros_contested
local bb8 "`r(coef)'"
local bse8 "`r(se)'"
local bn8 "`r(nobs)'"

* --- Panel B: Contested any (T3) + log(pop) ---
cell B contested_pop actually_reported  %9.1f treat_pros_contested
local bp1 "`r(coef)'"
local bps1 "`r(se)'"
cell B contested_pop told_to_report     %9.1f treat_pros_contested
local bp2 "`r(coef)'"
local bps2 "`r(se)'"
cell B contested_pop pct_told_to_report %9.3f treat_pros_contested
local bp3 "`r(coef)'"
local bps3 "`r(se)'"
cell B contested_pop sent_to_courtroom  %9.1f treat_pros_contested
local bp4 "`r(coef)'"
local bps4 "`r(se)'"
cell B contested_pop pct_sent_to_courtroom %9.3f treat_pros_contested
local bp5 "`r(coef)'"
local bps5 "`r(se)'"
cell B contested_pop questioned_in_voir_dire %9.1f treat_pros_contested
local bp6 "`r(coef)'"
local bps6 "`r(se)'"
cell B contested_pop pct_questioned_in_voir_dire %9.3f treat_pros_contested
local bp7 "`r(coef)'"
local bps7 "`r(se)'"
cell B contested_pop utilization_rate   %9.3f treat_pros_contested
local bp8 "`r(coef)'"
local bps8 "`r(se)'"

* --- Panel C: Contested general election (T2) base ---
cell B contested_long actually_reported  %9.1f treat_pros_contested_long
local cb1 "`r(coef)'"
local cse1 "`r(se)'"
local cn1 "`r(nobs)'"
cell B contested_long told_to_report     %9.1f treat_pros_contested_long
local cb2 "`r(coef)'"
local cse2 "`r(se)'"
local cn2 "`r(nobs)'"
cell B contested_long pct_told_to_report %9.3f treat_pros_contested_long
local cb3 "`r(coef)'"
local cse3 "`r(se)'"
local cn3 "`r(nobs)'"
cell B contested_long sent_to_courtroom  %9.1f treat_pros_contested_long
local cb4 "`r(coef)'"
local cse4 "`r(se)'"
local cn4 "`r(nobs)'"
cell B contested_long pct_sent_to_courtroom %9.3f treat_pros_contested_long
local cb5 "`r(coef)'"
local cse5 "`r(se)'"
local cn5 "`r(nobs)'"
cell B contested_long questioned_in_voir_dire %9.1f treat_pros_contested_long
local cb6 "`r(coef)'"
local cse6 "`r(se)'"
local cn6 "`r(nobs)'"
cell B contested_long pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local cb7 "`r(coef)'"
local cse7 "`r(se)'"
local cn7 "`r(nobs)'"
cell B contested_long utilization_rate   %9.3f treat_pros_contested_long
local cb8 "`r(coef)'"
local cse8 "`r(se)'"
local cn8 "`r(nobs)'"

* --- Panel C: Contested general (T2) + log(pop) ---
cell B contested_long_pop actually_reported  %9.1f treat_pros_contested_long
local cp1 "`r(coef)'"
local cps1 "`r(se)'"
cell B contested_long_pop told_to_report     %9.1f treat_pros_contested_long
local cp2 "`r(coef)'"
local cps2 "`r(se)'"
cell B contested_long_pop pct_told_to_report %9.3f treat_pros_contested_long
local cp3 "`r(coef)'"
local cps3 "`r(se)'"
cell B contested_long_pop sent_to_courtroom  %9.1f treat_pros_contested_long
local cp4 "`r(coef)'"
local cps4 "`r(se)'"
cell B contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_contested_long
local cp5 "`r(coef)'"
local cps5 "`r(se)'"
cell B contested_long_pop questioned_in_voir_dire %9.1f treat_pros_contested_long
local cp6 "`r(coef)'"
local cps6 "`r(se)'"
cell B contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local cp7 "`r(coef)'"
local cps7 "`r(se)'"
cell B contested_long_pop utilization_rate   %9.3f treat_pros_contested_long
local cp8 "`r(coef)'"
local cps8 "`r(se)'"

local f "`texdir'/mi_table1_pipeline.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Effect of Prosecutorial Electoral Pressure on Jury Mobilization}" _n
file write t "\label{tab:mi_pipeline}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{8}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)}" _n
file write t " &\multicolumn{1}{c}{(8)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{Sent to}" _n
file write t " &\multicolumn{1}{c}{\% Sent to}" _n
file write t " &\multicolumn{1}{c}{Voir Dire}" _n
file write t " &\multicolumn{1}{c}{\% Voir}" _n
file write t " &\multicolumn{1}{c}{Utilization} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Questioned}" _n
file write t " &\multicolumn{1}{c}{Dire}" _n
file write t " &\multicolumn{1}{c}{Rate} \\" _n
file write t "\hline" _n
file write t "\multicolumn{9}{l}{\textit{Panel A: Electoral pressure}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' & `b4' & `b5' & `b6' & `b7' & `b8' \\" _n
file write t "         & `s1' & `s2' & `s3' & `s4' & `s5' & `s6' & `s7' & `s8' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' & `ob4' & `ob5' & `ob6' & `ob7' & `ob8' \\" _n
file write t "         & `os1' & `os2' & `os3' & `os4' & `os5' & `os6' & `os7' & `os8' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' & `pb4' & `pb5' & `pb6' & `pb7' & `pb8' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' & `ps4' & `ps5' & `ps6' & `ps7' & `ps8' \\" _n
file write t "Observations & `n1' & `n2' & `n3' & `n4' & `n5' & `n6' & `n7' & `n8' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{Panel B: Contested --- any stage}} \\[0.3em]" _n
file write t "Contested & `bb1' & `bb2' & `bb3' & `bb4' & `bb5' & `bb6' & `bb7' & `bb8' \\" _n
file write t "          & `bse1' & `bse2' & `bse3' & `bse4' & `bse5' & `bse6' & `bse7' & `bse8' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Contested & `bp1' & `bp2' & `bp3' & `bp4' & `bp5' & `bp6' & `bp7' & `bp8' \\" _n
file write t "          & `bps1' & `bps2' & `bps3' & `bps4' & `bps5' & `bps6' & `bps7' & `bps8' \\" _n
file write t "Observations & `bn1' & `bn2' & `bn3' & `bn4' & `bn5' & `bn6' & `bn7' & `bn8' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{Panel C: Contested --- general election}} \\[0.3em]" _n
file write t "Contested & `cb1' & `cb2' & `cb3' & `cb4' & `cb5' & `cb6' & `cb7' & `cb8' \\" _n
file write t "          & `cse1' & `cse2' & `cse3' & `cse4' & `cse5' & `cse6' & `cse7' & `cse8' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Contested & `cp1' & `cp2' & `cp3' & `cp4' & `cp5' & `cp6' & `cp7' & `cp8' \\" _n
file write t "          & `cps1' & `cps2' & `cps3' & `cps4' & `cps5' & `cps6' & `cps7' & `cps8' \\" _n
file write t "Observations & `cn1' & `cn2' & `cn3' & `cn4' & `cn5' & `cn6' & `cn7' & `cn8' \\" _n
file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' & `m4' & `m5' & `m6' & `m7' & `m8' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' & `bm4' & `bm5' & `bm6' & `bm7' & `bm8' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' & `bs4' & `bs5' & `bs6' & `bs7' & `bs8' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{9}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Panel A: \textit{pressure} = incumbent faces election; \textit{open-seat} = no incumbent (open seat). Panels B--C: \textit{contested} (uncontested controlled).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Panel C excludes primary-only contested county-years. $\hat{\beta}/\bar{Y}$, $\hat{\beta}/\sigma_w$: based on Panel A base spec.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE 2 — Electoral Competition Decomposition
*  Variant B | Columns: (1) actually_reported, (2) pct_told_to_report
*  Panels show BOTH contested and uncontested coefficients as rows
*  Panel A: T2 (general election), Panel B: T3 (any stage)
*  Panel C: T2 with log(pop) control
*===================================================================
di as text _n "  Building Table 2: Competition Decomposition..."

* --- Panel A: T2 general-election decomposition ---
* Contested (general)
cell B contested_long actually_reported  %9.1f treat_pros_contested_long
local c1a "`r(coef)'"
local cs1a "`r(se)'"
local cn1a "`r(nobs)'"
local cbeta1a = r(beta_raw)
cell B contested_long pct_told_to_report %9.3f treat_pros_contested_long
local c2a "`r(coef)'"
local cs2a "`r(se)'"

* Uncontested (within T2 spec)
cell B contested_long actually_reported  %9.1f treat_pros_uncontested
local u1a "`r(coef)'"
local us1a "`r(se)'"
cell B contested_long pct_told_to_report %9.3f treat_pros_uncontested
local u2a "`r(coef)'"
local us2a "`r(se)'"

* --- Panel B: T3 any-stage decomposition ---
* Contested (any stage)
cell B contested actually_reported  %9.1f treat_pros_contested
local c1b "`r(coef)'"
local cs1b "`r(se)'"
local cn1b "`r(nobs)'"
cell B contested pct_told_to_report %9.3f treat_pros_contested
local c2b "`r(coef)'"
local cs2b "`r(se)'"

* Uncontested (within T3 spec)
cell B contested actually_reported  %9.1f treat_pros_uncontested
local u1b "`r(coef)'"
local us1b "`r(se)'"
cell B contested pct_told_to_report %9.3f treat_pros_uncontested
local u2b "`r(coef)'"
local us2b "`r(se)'"

* --- Panel C: T2 with log(population) control ---
cell B contested_long_pop actually_reported  %9.1f treat_pros_contested_long
local pc1 "`r(coef)'"
local pcs1 "`r(se)'"
cell B contested_long_pop pct_told_to_report %9.3f treat_pros_contested_long
local pc2 "`r(coef)'"
local pcs2 "`r(se)'"
cell B contested_long_pop actually_reported  %9.1f treat_pros_uncontested
local pu1 "`r(coef)'"
local pus1 "`r(se)'"
cell B contested_long_pop pct_told_to_report %9.3f treat_pros_uncontested
local pu2 "`r(coef)'"
local pus2 "`r(se)'"

* Format beta/mean and beta/SD_w (contested_long coefficient, Panel A)
local bm1 : di %9.3f `cbeta1a' / $m_B_actually_reported
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `cbeta1a' / $w_B_actually_reported
local bs1 = strtrim("`bs1'")

* Dep var means
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_B_pct_told_to_report
local m2 = strtrim("`m2'")

local f "`texdir'/mi_table2_competition.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Electoral Competition Decomposition and Jury Mobilization}" _n
file write t "\label{tab:mi_competition}" _n
file write t "\begin{tabular}{l*{2}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{\% Told to} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report} \\" _n
file write t "\hline" _n

* Panel A: T2 general-election decomposition
file write t "\multicolumn{3}{l}{\textit{Panel A: General-election decomposition}} \\[0.3em]" _n
file write t "Contested (general)  & `c1a' & `c2a' \\" _n
file write t "                     & `cs1a' & `cs2a' \\" _n
file write t "Uncontested          & `u1a' & `u2a' \\" _n
file write t "                     & `us1a' & `us2a' \\" _n
file write t "Observations         & `cn1a' & `cn1a' \\[0.5em]" _n

* Panel B: T3 any-stage decomposition
file write t "\multicolumn{3}{l}{\textit{Panel B: Any-stage decomposition}} \\[0.3em]" _n
file write t "Contested (any stage) & `c1b' & `c2b' \\" _n
file write t "                      & `cs1b' & `cs2b' \\" _n
file write t "Uncontested           & `u1b' & `u2b' \\" _n
file write t "                      & `us1b' & `us2b' \\" _n
file write t "Observations          & `cn1b' & `cn1b' \\[0.5em]" _n

* Panel C: With log(population) control (T2 only)
file write t "\multicolumn{3}{l}{\textit{Panel C: General-election with log(population) control}} \\[0.3em]" _n
file write t "Contested (general)  & `pc1' & `pc2' \\" _n
file write t "                     & `pcs1' & `pcs2' \\" _n
file write t "Uncontested          & `pu1' & `pu2' \\" _n
file write t "                     & `pus1' & `pus2' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean     & `m1' & `m2' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{3}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Omitted category: no election (off-cycle years).}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Panel A: general-election contested vs.\ uncontested. Panel B: any-stage contested vs.\ uncontested.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Panel C adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE 3 — Verdict Outcomes and Composition
*  Columns: (1) total_jury_verdicts [B], (2) capital_felony [A],
*           (3) pct_other_felony [B]
*  Panel A: T2 decomposition (contested + uncontested rows)
*  Panel B: T3 decomposition (contested + uncontested rows)
*  Panel C: T2 with log(pop) control
*===================================================================
di as text _n "  Building Table 3: Verdicts & Composition..."

* --- Panel A: T2 general-election decomposition ---
* Contested (general)
cell B contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local c1a "`r(coef)'"
local cs1a "`r(se)'"
local cn1a "`r(nobs)'"
local cbeta1a = r(beta_raw)
cell A contested_long capital_felony     %9.1f treat_pros_contested_long
local c2a "`r(coef)'"
local cs2a "`r(se)'"
local cn2a "`r(nobs)'"
local cbeta2a = r(beta_raw)
cell B contested_long pct_other_felony   %9.3f treat_pros_contested_long
local c3a "`r(coef)'"
local cs3a "`r(se)'"
local cn3a "`r(nobs)'"
local cbeta3a = r(beta_raw)

* Uncontested (within T2 spec)
cell B contested_long total_jury_verdicts %9.1f treat_pros_uncontested
local u1a "`r(coef)'"
local us1a "`r(se)'"
cell A contested_long capital_felony     %9.1f treat_pros_uncontested
local u2a "`r(coef)'"
local us2a "`r(se)'"
cell B contested_long pct_other_felony   %9.3f treat_pros_uncontested
local u3a "`r(coef)'"
local us3a "`r(se)'"

* --- Panel B: T3 any-stage decomposition ---
* Contested (any stage)
cell B contested total_jury_verdicts %9.1f treat_pros_contested
local c1b "`r(coef)'"
local cs1b "`r(se)'"
local cn1b "`r(nobs)'"
cell A contested capital_felony     %9.1f treat_pros_contested
local c2b "`r(coef)'"
local cs2b "`r(se)'"
local cn2b "`r(nobs)'"
cell B contested pct_other_felony   %9.3f treat_pros_contested
local c3b "`r(coef)'"
local cs3b "`r(se)'"
local cn3b "`r(nobs)'"

* Uncontested (within T3 spec)
cell B contested total_jury_verdicts %9.1f treat_pros_uncontested
local u1b "`r(coef)'"
local us1b "`r(se)'"
cell A contested capital_felony     %9.1f treat_pros_uncontested
local u2b "`r(coef)'"
local us2b "`r(se)'"
cell B contested pct_other_felony   %9.3f treat_pros_uncontested
local u3b "`r(coef)'"
local us3b "`r(se)'"

* --- Panel C: T2 with log(population) control ---
cell B contested_long_pop total_jury_verdicts %9.1f treat_pros_contested_long
local pc1 "`r(coef)'"
local pcs1 "`r(se)'"
cell A contested_long_pop capital_felony     %9.1f treat_pros_contested_long
local pc2 "`r(coef)'"
local pcs2 "`r(se)'"
cell B contested_long_pop pct_other_felony   %9.3f treat_pros_contested_long
local pc3 "`r(coef)'"
local pcs3 "`r(se)'"
cell B contested_long_pop total_jury_verdicts %9.1f treat_pros_uncontested
local pu1 "`r(coef)'"
local pus1 "`r(se)'"
cell A contested_long_pop capital_felony     %9.1f treat_pros_uncontested
local pu2 "`r(coef)'"
local pus2 "`r(se)'"
cell B contested_long_pop pct_other_felony   %9.3f treat_pros_uncontested
local pu3 "`r(coef)'"
local pus3 "`r(se)'"

* Dep var means
local m1 : di %9.1f $m_B_total_jury_verdicts
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_A_capital_felony
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_other_felony
local m3 = strtrim("`m3'")

local f "`texdir'/mi_table3_verdicts.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Outcomes and Composition Under Electoral Competition}" _n
file write t "\label{tab:mi_verdicts}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n

* Panel A: T2 general-election decomposition
file write t "\multicolumn{4}{l}{\textit{Panel A: General-election decomposition}} \\[0.3em]" _n
file write t "Contested (general)  & `c1a' & `c2a' & `c3a' \\" _n
file write t "                     & `cs1a' & `cs2a' & `cs3a' \\" _n
file write t "Uncontested          & `u1a' & `u2a' & `u3a' \\" _n
file write t "                     & `us1a' & `us2a' & `us3a' \\" _n
file write t "Observations         & `cn1a' & `cn2a' & `cn3a' \\[0.5em]" _n

* Panel B: T3 any-stage decomposition
file write t "\multicolumn{4}{l}{\textit{Panel B: Any-stage decomposition}} \\[0.3em]" _n
file write t "Contested (any stage) & `c1b' & `c2b' & `c3b' \\" _n
file write t "                      & `cs1b' & `cs2b' & `cs3b' \\" _n
file write t "Uncontested           & `u1b' & `u2b' & `u3b' \\" _n
file write t "                      & `us1b' & `us2b' & `us3b' \\" _n
file write t "Observations          & `cn1b' & `cn2b' & `cn3b' \\[0.5em]" _n

* Panel C: T2 with log(population) control
file write t "\multicolumn{4}{l}{\textit{Panel C: General-election with log(population) control}} \\[0.3em]" _n
file write t "Contested (general)  & `pc1' & `pc2' & `pc3' \\" _n
file write t "                     & `pcs1' & `pcs2' & `pcs3' \\" _n
file write t "Uncontested          & `pu1' & `pu2' & `pu3' \\" _n
file write t "                     & `pus1' & `pus2' & `pus3' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean     & `m1' & `m2' & `m3' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Cols (1), (3): Sample B (all courts). Col (2): Sample A (felony courts).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize See Table \ref{tab:mi_samples} for sample definitions.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Omitted category: no election (off-cycle years).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel C adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A1 — Appendix: Robustness (Variant A vs Main)
*  Variant A | T1 | treat_pros_pressure
*  Columns: (1) actually_reported (2) told_to_report (3) pct_told_to_report
*===================================================================
di as text _n "  Building Table A1: Robustness (Variant A)..."

cell A pressure actually_reported  %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell A pressure told_to_report     %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell A pressure pct_told_to_report %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

* Controlled spec (+ log population)
cell A pressure_pop actually_reported  %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell A pressure_pop told_to_report     %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell A pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"

* Open-seat (T1 decomposition)
cell A pressure actually_reported  %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell A pressure told_to_report     %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell A pressure pct_told_to_report %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_A_actually_reported
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_A_actually_reported
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_A_told_to_report
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_A_told_to_report
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_A_pct_told_to_report
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_A_pct_told_to_report
local bs3 = strtrim("`bs3'")

local m1 : di %9.1f $m_A_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_A_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_A_pct_told_to_report
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA1_robustness.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: Variant A (Felony-Focused Courts)}" _n
file write t "\label{tab:mi_robust_A}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report} \\" _n
file write t "\hline" _n
file write t "\multicolumn{4}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' \\" _n
file write t "         & `s1' & `s2' & `s3' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' \\" _n
file write t "         & `os1' & `os2' & `os3' \\[0.5em]" _n
file write t "\multicolumn{4}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample A: felony-focused, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election. Compare to Table 1 (Sample B).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize $\hat{\beta}/\bar{Y}$, $\hat{\beta}/\sigma_w$: based on Panel A. Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A2 — Appendix: Useful Nulls
*  Variant B | T1 | treat_pros_pressure
*  Columns: (1) pct_questioned_in_voir_dire, (2) sent_to_courtroom
*===================================================================
di as text _n "  Building Table A2: Useful Nulls..."

cell B pressure pct_questioned_in_voir_dire %9.3f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell B pressure sent_to_courtroom %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

* Controlled spec (+ log population)
cell B pressure_pop pct_questioned_in_voir_dire %9.3f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell B pressure_pop sent_to_courtroom %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"

* Open-seat (T1 decomposition)
cell B pressure pct_questioned_in_voir_dire %9.3f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell B pressure sent_to_courtroom %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_B_pct_questioned_in_voir_dire
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_B_pct_questioned_in_voir_dire
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_B_sent_to_courtroom
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_B_sent_to_courtroom
local bs2 = strtrim("`bs2'")

local m1 : di %9.3f $m_B_pct_questioned_in_voir_dire
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_sent_to_courtroom
local m2 = strtrim("`m2'")

local f "`texdir'/mi_tableA2_nulls.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Downstream Jury Pipeline Outcomes (Useful Nulls)}" _n
file write t "\label{tab:mi_nulls}" _n
file write t "\begin{tabular}{l*{2}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)} \\" _n
file write t " &\multicolumn{1}{c}{\% Questioned}" _n
file write t " &\multicolumn{1}{c}{Sent to} \\" _n
file write t " &\multicolumn{1}{c}{(Voir Dire)}" _n
file write t " &\multicolumn{1}{c}{Courtroom} \\" _n
file write t "\hline" _n
file write t "\multicolumn{3}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' \\" _n
file write t "         & `s1' & `s2' \\" _n
file write t "Open-seat election & `ob1' & `ob2' \\" _n
file write t "         & `os1' & `os2' \\[0.5em]" _n
file write t "\multicolumn{3}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' \\" _n
file write t "         & `ps1' & `ps2' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{3}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize $\hat{\beta}/\bar{Y}$, $\hat{\beta}/\sigma_w$: based on Panel A. Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A3 — Appendix: Mechanism (Combined Courts, Other Cases)
*  COURT_COMBINED | T2 | treat_pros_contested_long
*  Column: (1) other_cases
*===================================================================
di as text _n "  Building Table A3: Mechanism (Other Cases)..."

cell COURT_COMBINED contested_long other_cases %9.1f treat_pros_contested_long
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

* Controlled spec (+ log population)
cell COURT_COMBINED contested_long_pop other_cases %9.1f treat_pros_contested_long
local pb1 "`r(coef)'"
local ps1 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_CC_other_cases
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_CC_other_cases
local bs1 = strtrim("`bs1'")

local m1 : di %9.1f $m_CC_other_cases
local m1 = strtrim("`m1'")

local f "`texdir'/mi_tableA3_mechanism.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Concentration: Other Cases in Combined Courts}" _n
file write t "\label{tab:mi_mechanism}" _n
file write t "\begin{tabular}{lc}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)} \\" _n
file write t " &\multicolumn{1}{c}{Other Cases} \\" _n
file write t "\hline" _n
file write t "\multicolumn{2}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Contested (general) & `b1' \\" _n
file write t "                    & `s1' \\[0.5em]" _n
file write t "\multicolumn{2}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Contested (general) & `pb1' \\" _n
file write t "                    & `ps1' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' \\" _n
file write t "Dep.\ var.\ mean & `m1' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{2}{l}{\footnotesize Court-level: combined courts only, 44 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{2}{l}{\footnotesize Court and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{2}{l}{\footnotesize Treatment: \textit{contested} in general election.}\\"' _n
file write t `"\multicolumn{2}{l}{\footnotesize $\hat{\beta}/\bar{Y}$, $\hat{\beta}/\sigma_w$: based on Panel A. Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{2}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A4 — Appendix: Scaling Check (Per 10k Population)
*  Variant B | T4 | treat_pros_pressure
*  Columns: (1) actually_reported_p10k, (2) total_jury_verdicts_p10k
*===================================================================
di as text _n "  Building Table A4: Scaling Check..."

cell B pressure actually_reported_p10k    %9.2f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell B pressure total_jury_verdicts_p10k  %9.2f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

* Controlled spec (+ log population)
cell B pressure_pop actually_reported_p10k    %9.2f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell B pressure_pop total_jury_verdicts_p10k  %9.2f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"

* Open-seat (T1 decomposition)
cell B pressure actually_reported_p10k    %9.2f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell B pressure total_jury_verdicts_p10k  %9.2f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_B_actually_reported_p10k
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_B_actually_reported_p10k
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_B_total_jury_verdicts_p10k
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_B_total_jury_verdicts_p10k
local bs2 = strtrim("`bs2'")

local m1 : di %9.2f $m_B_actually_reported_p10k
local m1 = strtrim("`m1'")
local m2 : di %9.2f $m_B_total_jury_verdicts_p10k
local m2 = strtrim("`m2'")

local f "`texdir'/mi_tableA4_scaling.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Scaling Check: Per 10,000 Population}" _n
file write t "\label{tab:mi_scaling}" _n
file write t "\begin{tabular}{l*{2}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Total} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Verdicts} \\" _n
file write t "\hline" _n
file write t "\multicolumn{3}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' \\" _n
file write t "         & `s1' & `s2' \\" _n
file write t "Open-seat election & `ob1' & `ob2' \\" _n
file write t "         & `os1' & `os2' \\[0.5em]" _n
file write t "\multicolumn{3}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' \\" _n
file write t "         & `ps1' & `ps2' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{3}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Treatment: \textit{pressure}. Outcomes per 10,000 county population.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize $\hat{\beta}/\bar{Y}$, $\hat{\beta}/\sigma_w$: based on Panel A. Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE 4 — Robustness Checks
*  All T1 pressure treatment — unified across columns
*  Columns: (1) Actually Reported [B], (2) % Told to Report [B],
*           (3) % Other Felony [B]
*  Panels: A = Full, B = No 2016, C = No 2024,
*          D = No no_offcycles 2018/2022, E = Full + log(pop) control
*===================================================================
di as text _n "  Building Table 4: Cycle Robustness..."

* Panel A: Full sample
cell B pressure actually_reported %9.1f treat_pros_pressure
local b1a "`r(coef)'"
local s1a "`r(se)'"
local n1a "`r(nobs)'"
cell B pressure pct_told_to_report %9.3f treat_pros_pressure
local b2a "`r(coef)'"
local s2a "`r(se)'"
local n2a "`r(nobs)'"
cell B pressure pct_other_felony %9.3f treat_pros_pressure
local b3a "`r(coef)'"
local s3a "`r(se)'"
local n3a "`r(nobs)'"

* Panel B: Excluding 2016
cell B_no2016 pressure actually_reported %9.1f treat_pros_pressure
local b1b "`r(coef)'"
local s1b "`r(se)'"
local n1b "`r(nobs)'"
cell B_no2016 pressure pct_told_to_report %9.3f treat_pros_pressure
local b2b "`r(coef)'"
local s2b "`r(se)'"
local n2b "`r(nobs)'"
cell B_no2016 pressure pct_other_felony %9.3f treat_pros_pressure
local b3b "`r(coef)'"
local s3b "`r(se)'"
local n3b "`r(nobs)'"

* Panel C: Excluding 2024
cell B_no2024 pressure actually_reported %9.1f treat_pros_pressure
local b1c "`r(coef)'"
local s1c "`r(se)'"
local n1c "`r(nobs)'"
cell B_no2024 pressure pct_told_to_report %9.3f treat_pros_pressure
local b2c "`r(coef)'"
local s2c "`r(se)'"
local n2c "`r(nobs)'"
cell B_no2024 pressure pct_other_felony %9.3f treat_pros_pressure
local b3c "`r(coef)'"
local s3c "`r(se)'"
local n3c "`r(nobs)'"

* Panel D: Excluding no_offcycle years (2018, 2022)
cell B_no_offcycle pressure actually_reported %9.1f treat_pros_pressure
local b1d "`r(coef)'"
local s1d "`r(se)'"
local n1d "`r(nobs)'"
cell B_no_offcycle pressure pct_told_to_report %9.3f treat_pros_pressure
local b2d "`r(coef)'"
local s2d "`r(se)'"
local n2d "`r(nobs)'"
cell B_no_offcycle pressure pct_other_felony %9.3f treat_pros_pressure
local b3d "`r(coef)'"
local s3d "`r(se)'"
local n3d "`r(nobs)'"

* Panel E: Full sample with log(population) control
cell B pressure_pop actually_reported %9.1f treat_pros_pressure
local b1e "`r(coef)'"
local s1e "`r(se)'"
cell B pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local b2e "`r(coef)'"
local s2e "`r(se)'"
cell B pressure_pop pct_other_felony %9.3f treat_pros_pressure
local b3e "`r(coef)'"
local s3e "`r(se)'"

* Open-seat (T1 decomposition) for each panel
cell B pressure actually_reported %9.1f open_pros
local o1a "`r(coef)'"
local os1a "`r(se)'"
cell B pressure pct_told_to_report %9.3f open_pros
local o2a "`r(coef)'"
local os2a "`r(se)'"
cell B pressure pct_other_felony %9.3f open_pros
local o3a "`r(coef)'"
local os3a "`r(se)'"

cell B_no2016 pressure actually_reported %9.1f open_pros
local o1b "`r(coef)'"
local os1b "`r(se)'"
cell B_no2016 pressure pct_told_to_report %9.3f open_pros
local o2b "`r(coef)'"
local os2b "`r(se)'"
cell B_no2016 pressure pct_other_felony %9.3f open_pros
local o3b "`r(coef)'"
local os3b "`r(se)'"

cell B_no2024 pressure actually_reported %9.1f open_pros
local o1c "`r(coef)'"
local os1c "`r(se)'"
cell B_no2024 pressure pct_told_to_report %9.3f open_pros
local o2c "`r(coef)'"
local os2c "`r(se)'"
cell B_no2024 pressure pct_other_felony %9.3f open_pros
local o3c "`r(coef)'"
local os3c "`r(se)'"

cell B_no_offcycle pressure actually_reported %9.1f open_pros
local o1d "`r(coef)'"
local os1d "`r(se)'"
cell B_no_offcycle pressure pct_told_to_report %9.3f open_pros
local o2d "`r(coef)'"
local os2d "`r(se)'"
cell B_no_offcycle pressure pct_other_felony %9.3f open_pros
local o3d "`r(coef)'"
local os3d "`r(se)'"

* Dep var means (full sample)
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_B_pct_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_other_felony
local m3 = strtrim("`m3'")

local f "`texdir'/mi_table4_cycle_robust.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness Checks}" _n
file write t "\label{tab:mi_robust}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n

* Panel A: Full sample
file write t "\multicolumn{4}{l}{\textit{Panel A: Full sample}} \\[0.3em]" _n
file write t "Pressure         & `b1a' & `b2a' & `b3a' \\" _n
file write t "                 & `s1a' & `s2a' & `s3a' \\" _n
file write t "Open-seat election & `o1a' & `o2a' & `o3a' \\" _n
file write t "                 & `os1a' & `os2a' & `os3a' \\" _n
file write t "Observations     & `n1a' & `n2a' & `n3a' \\[0.5em]" _n

* Panel B: Excluding 2016
file write t "\multicolumn{4}{l}{\textit{Panel B: Excluding 2016}} \\[0.3em]" _n
file write t "Pressure         & `b1b' & `b2b' & `b3b' \\" _n
file write t "                 & `s1b' & `s2b' & `s3b' \\" _n
file write t "Open-seat election & `o1b' & `o2b' & `o3b' \\" _n
file write t "                 & `os1b' & `os2b' & `os3b' \\" _n
file write t "Observations     & `n1b' & `n2b' & `n3b' \\[0.5em]" _n

* Panel C: Excluding 2024
file write t "\multicolumn{4}{l}{\textit{Panel C: Excluding 2024}} \\[0.3em]" _n
file write t "Pressure         & `b1c' & `b2c' & `b3c' \\" _n
file write t "                 & `s1c' & `s2c' & `s3c' \\" _n
file write t "Open-seat election & `o1c' & `o2c' & `o3c' \\" _n
file write t "                 & `os1c' & `os2c' & `os3c' \\" _n
file write t "Observations     & `n1c' & `n2c' & `n3c' \\[0.5em]" _n

* Panel D: Excluding no_offcycle years
file write t "\multicolumn{4}{l}{\textit{Panel D: Excluding no_offcycle years (2018, 2022)}} \\[0.3em]" _n
file write t "Pressure         & `b1d' & `b2d' & `b3d' \\" _n
file write t "                 & `s1d' & `s2d' & `s3d' \\" _n
file write t "Open-seat election & `o1d' & `o2d' & `o3d' \\" _n
file write t "                 & `os1d' & `os2d' & `os3d' \\" _n
file write t "Observations     & `n1d' & `n2d' & `n3d' \\[0.5em]" _n

* Panel E: With log(population) control
file write t "\multicolumn{4}{l}{\textit{Panel E: With log(population) control}} \\[0.3em]" _n
file write t "Pressure         & `b1e' & `b2e' & `b3e' \\" _n
file write t "                 & `s1e' & `s2e' & `s3e' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample B: all-courts expanded, 83 counties. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent prosecutor faces election.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel D: presidential-cycle years only. Panel E: adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


* TABLE A5 removed — no_offcycle exclusion now in Table 4, Panel D
* TABLE A5 .tex file (mi_tableA5_no_offcycle.tex) should be deleted from Overleaf


*===================================================================
*  TABLE A6 — Appendix: Population Split
*  Columns: (1) Actually Reported, (2) Told to Report,
*           (3) % Told to Report, (4) Utilization Rate,
*           (5) Total Verdicts, (6) Capital Felony
*  Panels: A = Above-median pop, B = Below-median pop
*===================================================================
di as text _n "  Building Table A6: Population Split..."

* Panel A: Above-median population
cell B_highpop pressure actually_reported %9.1f treat_pros_pressure
local b1a "`r(coef)'"
local s1a "`r(se)'"
local n1a "`r(nobs)'"
cell B_highpop pressure told_to_report %9.1f treat_pros_pressure
local b2a "`r(coef)'"
local s2a "`r(se)'"
local n2a "`r(nobs)'"
cell B_highpop pressure pct_told_to_report %9.3f treat_pros_pressure
local b3a "`r(coef)'"
local s3a "`r(se)'"
local n3a "`r(nobs)'"
cell B_highpop pressure utilization_rate %9.3f treat_pros_pressure
local b4a "`r(coef)'"
local s4a "`r(se)'"
local n4a "`r(nobs)'"
cell B_highpop pressure total_jury_verdicts %9.1f treat_pros_pressure
local b5a "`r(coef)'"
local s5a "`r(se)'"
local n5a "`r(nobs)'"
cell B_highpop pressure capital_felony %9.1f treat_pros_pressure
local b6a "`r(coef)'"
local s6a "`r(se)'"
local n6a "`r(nobs)'"

* Panel B: Below-median population
cell B_lowpop pressure actually_reported %9.1f treat_pros_pressure
local b1b "`r(coef)'"
local s1b "`r(se)'"
local n1b "`r(nobs)'"
cell B_lowpop pressure told_to_report %9.1f treat_pros_pressure
local b2b "`r(coef)'"
local s2b "`r(se)'"
local n2b "`r(nobs)'"
cell B_lowpop pressure pct_told_to_report %9.3f treat_pros_pressure
local b3b "`r(coef)'"
local s3b "`r(se)'"
local n3b "`r(nobs)'"
cell B_lowpop pressure utilization_rate %9.3f treat_pros_pressure
local b4b "`r(coef)'"
local s4b "`r(se)'"
local n4b "`r(nobs)'"
cell B_lowpop pressure total_jury_verdicts %9.1f treat_pros_pressure
local b5b "`r(coef)'"
local s5b "`r(se)'"
local n5b "`r(nobs)'"
cell B_lowpop pressure capital_felony %9.1f treat_pros_pressure
local b6b "`r(coef)'"
local s6b "`r(se)'"
local n6b "`r(nobs)'"

* Open-seat: Above-median
cell B_highpop pressure actually_reported %9.1f open_pros
local o1a "`r(coef)'"
local ose1a "`r(se)'"
cell B_highpop pressure told_to_report %9.1f open_pros
local o2a "`r(coef)'"
local ose2a "`r(se)'"
cell B_highpop pressure pct_told_to_report %9.3f open_pros
local o3a "`r(coef)'"
local ose3a "`r(se)'"
cell B_highpop pressure utilization_rate %9.3f open_pros
local o4a "`r(coef)'"
local ose4a "`r(se)'"
cell B_highpop pressure total_jury_verdicts %9.1f open_pros
local o5a "`r(coef)'"
local ose5a "`r(se)'"
cell B_highpop pressure capital_felony %9.1f open_pros
local o6a "`r(coef)'"
local ose6a "`r(se)'"

* Open-seat: Below-median
cell B_lowpop pressure actually_reported %9.1f open_pros
local o1b "`r(coef)'"
local ose1b "`r(se)'"
cell B_lowpop pressure told_to_report %9.1f open_pros
local o2b "`r(coef)'"
local ose2b "`r(se)'"
cell B_lowpop pressure pct_told_to_report %9.3f open_pros
local o3b "`r(coef)'"
local ose3b "`r(se)'"
cell B_lowpop pressure utilization_rate %9.3f open_pros
local o4b "`r(coef)'"
local ose4b "`r(se)'"
cell B_lowpop pressure total_jury_verdicts %9.1f open_pros
local o5b "`r(coef)'"
local ose5b "`r(se)'"
cell B_lowpop pressure capital_felony %9.1f open_pros
local o6b "`r(coef)'"
local ose6b "`r(se)'"

* Panel C: Above-median with log(population) control
cell B_highpop pressure_pop actually_reported %9.1f treat_pros_pressure
local b1c "`r(coef)'"
local s1c "`r(se)'"
cell B_highpop pressure_pop told_to_report %9.1f treat_pros_pressure
local b2c "`r(coef)'"
local s2c "`r(se)'"
cell B_highpop pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local b3c "`r(coef)'"
local s3c "`r(se)'"
cell B_highpop pressure_pop utilization_rate %9.3f treat_pros_pressure
local b4c "`r(coef)'"
local s4c "`r(se)'"
cell B_highpop pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local b5c "`r(coef)'"
local s5c "`r(se)'"
cell B_highpop pressure_pop capital_felony %9.1f treat_pros_pressure
local b6c "`r(coef)'"
local s6c "`r(se)'"

* Panel D: Below-median with log(population) control
cell B_lowpop pressure_pop actually_reported %9.1f treat_pros_pressure
local b1d "`r(coef)'"
local s1d "`r(se)'"
cell B_lowpop pressure_pop told_to_report %9.1f treat_pros_pressure
local b2d "`r(coef)'"
local s2d "`r(se)'"
cell B_lowpop pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local b3d "`r(coef)'"
local s3d "`r(se)'"
cell B_lowpop pressure_pop utilization_rate %9.3f treat_pros_pressure
local b4d "`r(coef)'"
local s4d "`r(se)'"
cell B_lowpop pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local b5d "`r(coef)'"
local s5d "`r(se)'"
cell B_lowpop pressure_pop capital_felony %9.1f treat_pros_pressure
local b6d "`r(coef)'"
local s6d "`r(se)'"

* Dep var means (full sample)
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_told_to_report
local m3 = strtrim("`m3'")
local m4 : di %9.3f $m_B_utilization_rate
local m4 = strtrim("`m4'")
local m5 : di %9.1f $m_B_total_jury_verdicts
local m5 = strtrim("`m5'")
local m6 : di %9.1f $m_A_capital_felony
local m6 = strtrim("`m6'")

local f "`texdir'/mi_tableA6_popsplit.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Heterogeneity by County Population Size}" _n
file write t "\label{tab:mi_popsplit}" _n
file write t "\begin{tabular}{l*{6}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{Utilization}" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Rate}" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n

* Panel A: Above-median
file write t "\multicolumn{7}{l}{\textit{Panel A: Above-median population}} \\[0.3em]" _n
file write t "Pressure         & `b1a' & `b2a' & `b3a' & `b4a' & `b5a' & `b6a' \\" _n
file write t "                 & `s1a' & `s2a' & `s3a' & `s4a' & `s5a' & `s6a' \\" _n
file write t "Open-seat election & `o1a' & `o2a' & `o3a' & `o4a' & `o5a' & `o6a' \\" _n
file write t "                 & `ose1a' & `ose2a' & `ose3a' & `ose4a' & `ose5a' & `ose6a' \\" _n
file write t "Observations     & `n1a' & `n2a' & `n3a' & `n4a' & `n5a' & `n6a' \\[0.5em]" _n

* Panel B: Below-median
file write t "\multicolumn{7}{l}{\textit{Panel B: Below-median population}} \\[0.3em]" _n
file write t "Pressure         & `b1b' & `b2b' & `b3b' & `b4b' & `b5b' & `b6b' \\" _n
file write t "                 & `s1b' & `s2b' & `s3b' & `s4b' & `s5b' & `s6b' \\" _n
file write t "Open-seat election & `o1b' & `o2b' & `o3b' & `o4b' & `o5b' & `o6b' \\" _n
file write t "                 & `ose1b' & `ose2b' & `ose3b' & `ose4b' & `ose5b' & `ose6b' \\" _n
file write t "Observations     & `n1b' & `n2b' & `n3b' & `n4b' & `n5b' & `n6b' \\[0.5em]" _n

* Panel C: With log(population) control
file write t "\multicolumn{7}{l}{\textit{Panels A--B with log(population) control:}} \\[0.3em]" _n
file write t "\multicolumn{7}{l}{\textit{\quad Above-median}} \\[0.1em]" _n
file write t "Pressure         & `b1c' & `b2c' & `b3c' & `b4c' & `b5c' & `b6c' \\" _n
file write t "                 & `s1c' & `s2c' & `s3c' & `s4c' & `s5c' & `s6c' \\[0.3em]" _n
file write t "\multicolumn{7}{l}{\textit{\quad Below-median}} \\[0.1em]" _n
file write t "Pressure         & `b1d' & `b2d' & `b3d' & `b4d' & `b5d' & `b6d' \\" _n
file write t "                 & `s1d' & `s2d' & `s3d' & `s4d' & `s5d' & `s6d' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' & `m4' & `m5' & `m6' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{7}{l}{\footnotesize Sample B (cols 1--5), Sample A (col 6) split at median county population. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent prosecutor faces election.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize Bottom panel adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A7 — Appendix: Pipeline Configuration Summary
*  Shows sign pattern under T1 pressure across all pipeline domains
*  Columns: (1) Actually Reported, (2) Told to Report,
*           (3) % Told to Report, (4) Total Verdicts,
*           (5) Capital Felony, (6) % Other Felony
*  All T1 pressure, Sample B (cols 1-4,6), Sample A (col 5)
*===================================================================
di as text _n "  Building Table A7: Pipeline Configuration Summary..."

* Mobilization outcomes (re-use from Table 1 if still in memory, else re-extract)
cell B pressure actually_reported  %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
cell B pressure told_to_report     %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
cell B pressure pct_told_to_report %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"

* Verdict outcomes
cell B pressure total_jury_verdicts %9.1f treat_pros_pressure
local b4 "`r(coef)'"
local s4 "`r(se)'"
local n4 "`r(nobs)'"
cell A pressure capital_felony     %9.1f treat_pros_pressure
local b5 "`r(coef)'"
local s5 "`r(se)'"
local n5 "`r(nobs)'"

* Composition
cell B pressure pct_other_felony   %9.3f treat_pros_pressure
local b6 "`r(coef)'"
local s6 "`r(se)'"
local n6 "`r(nobs)'"

* Open-seat (T1 decomposition)
cell B pressure actually_reported  %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell B pressure told_to_report     %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell B pressure pct_told_to_report %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"
cell B pressure total_jury_verdicts %9.1f open_pros
local ob4 "`r(coef)'"
local os4 "`r(se)'"
cell A pressure capital_felony     %9.1f open_pros
local ob5 "`r(coef)'"
local os5 "`r(se)'"
cell B pressure pct_other_felony   %9.3f open_pros
local ob6 "`r(coef)'"
local os6 "`r(se)'"

* Controlled spec
cell B pressure_pop actually_reported  %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell B pressure_pop told_to_report     %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell B pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"
cell B pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local pb4 "`r(coef)'"
local ps4 "`r(se)'"
cell A pressure_pop capital_felony     %9.1f treat_pros_pressure
local pb5 "`r(coef)'"
local ps5 "`r(se)'"
cell B pressure_pop pct_other_felony   %9.3f treat_pros_pressure
local pb6 "`r(coef)'"
local ps6 "`r(se)'"

* Dep var means
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_told_to_report
local m3 = strtrim("`m3'")
local m4 : di %9.1f $m_B_total_jury_verdicts
local m4 = strtrim("`m4'")
local m5 : di %9.1f $m_A_capital_felony
local m5 = strtrim("`m5'")
local m6 : di %9.3f $m_B_pct_other_felony
local m6 = strtrim("`m6'")

local f "`texdir'/mi_tableA7_config.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Pipeline Configuration Under Electoral Pressure}" _n
file write t "\label{tab:mi_config}" _n
file write t "\small" _n
file write t "\begin{tabular}{l*{6}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{3}{c}{\textit{Mobilization}}" _n
file write t " &\multicolumn{2}{c}{\textit{Verdicts}}" _n
file write t " &\multicolumn{1}{c}{\textit{Composition}} \\" _n
file write t "\cmidrule(lr){2-4} \cmidrule(lr){5-6} \cmidrule(lr){7-7}" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n

* Panel A: Base specification
file write t "\multicolumn{7}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' & `b4' & `b5' & `b6' \\" _n
file write t "         & `s1' & `s2' & `s3' & `s4' & `s5' & `s6' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' & `ob4' & `ob5' & `ob6' \\" _n
file write t "         & `os1' & `os2' & `os3' & `os4' & `os5' & `os6' \\[0.5em]" _n

* Panel B: With log(population) control
file write t "\multicolumn{7}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' & `pb4' & `pb5' & `pb6' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' & `ps4' & `ps5' & `ps6' \\" _n

file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' & `n4' & `n5' & `n6' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' & `m4' & `m5' & `m6' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{7}{l}{\footnotesize Cols (1)--(4), (6): Sample B. Col (5): Sample A. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election. All outcomes under single treatment.}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize Configuration: mobilization increases (cols 1--3), verdicts stable (cols 4--5), composition shifts (col 6).}\\"' _n
file write t `"\multicolumn{7}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A8 — Appendix: Composition Heterogeneity by County Size
*  Columns: (1) % Capital Felony, (2) % Other Felony, (3) % Other Cases
*  Panels: A = Above-median pop, B = Below-median pop
*===================================================================
di as text _n "  Building Table A8: Composition Heterogeneity..."

* Panel A: Above-median population
cell B_highpop pressure pct_capital_felony %9.3f treat_pros_pressure
local b1a "`r(coef)'"
local s1a "`r(se)'"
local n1a "`r(nobs)'"
cell B_highpop pressure pct_other_felony %9.3f treat_pros_pressure
local b2a "`r(coef)'"
local s2a "`r(se)'"
local n2a "`r(nobs)'"
cell B_highpop pressure pct_other_cases %9.3f treat_pros_pressure
local b3a "`r(coef)'"
local s3a "`r(se)'"
local n3a "`r(nobs)'"

* Panel B: Below-median population
cell B_lowpop pressure pct_capital_felony %9.3f treat_pros_pressure
local b1b "`r(coef)'"
local s1b "`r(se)'"
local n1b "`r(nobs)'"
cell B_lowpop pressure pct_other_felony %9.3f treat_pros_pressure
local b2b "`r(coef)'"
local s2b "`r(se)'"
local n2b "`r(nobs)'"
cell B_lowpop pressure pct_other_cases %9.3f treat_pros_pressure
local b3b "`r(coef)'"
local s3b "`r(se)'"
local n3b "`r(nobs)'"

* Open-seat: Above-median
cell B_highpop pressure pct_capital_felony %9.3f open_pros
local o1a "`r(coef)'"
local ose1a "`r(se)'"
cell B_highpop pressure pct_other_felony %9.3f open_pros
local o2a "`r(coef)'"
local ose2a "`r(se)'"
cell B_highpop pressure pct_other_cases %9.3f open_pros
local o3a "`r(coef)'"
local ose3a "`r(se)'"

* Open-seat: Below-median
cell B_lowpop pressure pct_capital_felony %9.3f open_pros
local o1b "`r(coef)'"
local ose1b "`r(se)'"
cell B_lowpop pressure pct_other_felony %9.3f open_pros
local o2b "`r(coef)'"
local ose2b "`r(se)'"
cell B_lowpop pressure pct_other_cases %9.3f open_pros
local o3b "`r(coef)'"
local ose3b "`r(se)'"

* Panel C: Above-median with log(population) control
cell B_highpop pressure_pop pct_capital_felony %9.3f treat_pros_pressure
local b1c "`r(coef)'"
local s1c "`r(se)'"
cell B_highpop pressure_pop pct_other_felony %9.3f treat_pros_pressure
local b2c "`r(coef)'"
local s2c "`r(se)'"
cell B_highpop pressure_pop pct_other_cases %9.3f treat_pros_pressure
local b3c "`r(coef)'"
local s3c "`r(se)'"

* Panel D: Below-median with log(population) control
cell B_lowpop pressure_pop pct_capital_felony %9.3f treat_pros_pressure
local b1d "`r(coef)'"
local s1d "`r(se)'"
cell B_lowpop pressure_pop pct_other_felony %9.3f treat_pros_pressure
local b2d "`r(coef)'"
local s2d "`r(se)'"
cell B_lowpop pressure_pop pct_other_cases %9.3f treat_pros_pressure
local b3d "`r(coef)'"
local s3d "`r(se)'"

* Dep var means (full Panel B sample)
local m1 : di %9.3f $m_B_pct_capital_felony
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_B_pct_other_felony
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_other_cases
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA8_comp_heterogeneity.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Composition Heterogeneity by County Population Size}" _n
file write t "\label{tab:mi_comp_het}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases} \\" _n
file write t "\hline" _n

* Panel A: Above-median
file write t "\multicolumn{4}{l}{\textit{Panel A: Above-median population}} \\[0.3em]" _n
file write t "Pressure         & `b1a' & `b2a' & `b3a' \\" _n
file write t "                 & `s1a' & `s2a' & `s3a' \\" _n
file write t "Open-seat election & `o1a' & `o2a' & `o3a' \\" _n
file write t "                 & `ose1a' & `ose2a' & `ose3a' \\" _n
file write t "Observations     & `n1a' & `n2a' & `n3a' \\[0.5em]" _n

* Panel B: Below-median
file write t "\multicolumn{4}{l}{\textit{Panel B: Below-median population}} \\[0.3em]" _n
file write t "Pressure         & `b1b' & `b2b' & `b3b' \\" _n
file write t "                 & `s1b' & `s2b' & `s3b' \\" _n
file write t "Open-seat election & `o1b' & `o2b' & `o3b' \\" _n
file write t "                 & `ose1b' & `ose2b' & `ose3b' \\" _n
file write t "Observations     & `n1b' & `n2b' & `n3b' \\[0.5em]" _n

* Panel C: With log(population) control
file write t "\multicolumn{4}{l}{\textit{Panels A--B with log(population) control:}} \\[0.3em]" _n
file write t "\multicolumn{4}{l}{\textit{\quad Above-median}} \\[0.1em]" _n
file write t "Pressure         & `b1c' & `b2c' & `b3c' \\" _n
file write t "                 & `s1c' & `s2c' & `s3c' \\[0.3em]" _n
file write t "\multicolumn{4}{l}{\textit{\quad Below-median}} \\[0.1em]" _n
file write t "Pressure         & `b1d' & `b2d' & `b3d' \\" _n
file write t "                 & `s1d' & `s2d' & `s3d' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample B split at median county population. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent prosecutor faces election.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Bottom panel adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE 5: Verdict Sensitivity to Election Cycle Exclusion
*  Treatment: T2 (contested_long) — general-election contestation
*  Purpose: Shows the sign reversal in verdict effects transparently
*           when individual election cycles are excluded.
*===================================================================
di as text _n "  Table 5: Verdict cycle-exclusion sensitivity..."

* Panel A: Full sample
cell B contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local b1a "`r(coef)'"
local s1a "`r(se)'"
local n1a "`r(nobs)'"
cell B contested_long pct_capital_felony %9.3f treat_pros_contested_long
local b2a "`r(coef)'"
local s2a "`r(se)'"
local n2a "`r(nobs)'"

* Panel B: Excluding 2016
cell B_no2016 contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local b1b "`r(coef)'"
local s1b "`r(se)'"
local n1b "`r(nobs)'"
cell B_no2016 contested_long pct_capital_felony %9.3f treat_pros_contested_long
local b2b "`r(coef)'"
local s2b "`r(se)'"
local n2b "`r(nobs)'"

* Panel C: Excluding 2024
cell B_no2024 contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local b1c "`r(coef)'"
local s1c "`r(se)'"
local n1c "`r(nobs)'"
cell B_no2024 contested_long pct_capital_felony %9.3f treat_pros_contested_long
local b2c "`r(coef)'"
local s2c "`r(se)'"
local n2c "`r(nobs)'"

* Panel D: Presidential-cycle only (excluding no_offcycle years 2018, 2022)
cell B_no_offcycle contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local b1d "`r(coef)'"
local s1d "`r(se)'"
local n1d "`r(nobs)'"
cell B_no_offcycle contested_long pct_capital_felony %9.3f treat_pros_contested_long
local b2d "`r(coef)'"
local s2d "`r(se)'"
local n2d "`r(nobs)'"

* Dep var means (full Panel B sample)
local m1 : di %9.1f $m_B_total_jury_verdicts
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_B_pct_capital_felony
local m2 = strtrim("`m2'")

local f "`texdir'/mi_table5_cycle_verdicts.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Sensitivity to Election Cycle Exclusion}" _n
file write t "\label{tab:mi_cycle_verdicts}" _n
file write t "\begin{tabular}{l*{2}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)} \\" _n
file write t " &\multicolumn{1}{c}{Total Jury}" _n
file write t " &\multicolumn{1}{c}{\% Capital} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n

* Panel A: Full sample
file write t "\multicolumn{3}{l}{\textit{Panel A: Full sample}} \\[0.3em]" _n
file write t "Contested        & `b1a' & `b2a' \\" _n
file write t "                 & `s1a' & `s2a' \\" _n
file write t "Observations     & `n1a' & `n2a' \\[0.5em]" _n

* Panel B: Excluding 2016
file write t "\multicolumn{3}{l}{\textit{Panel B: Excluding 2016}} \\[0.3em]" _n
file write t "Contested        & `b1b' & `b2b' \\" _n
file write t "                 & `s1b' & `s2b' \\" _n
file write t "Observations     & `n1b' & `n2b' \\[0.5em]" _n

* Panel C: Excluding 2024
file write t "\multicolumn{3}{l}{\textit{Panel C: Excluding 2024}} \\[0.3em]" _n
file write t "Contested        & `b1c' & `b2c' \\" _n
file write t "                 & `s1c' & `s2c' \\" _n
file write t "Observations     & `n1c' & `n2c' \\[0.5em]" _n

* Panel D: Presidential-cycle only
file write t "\multicolumn{3}{l}{\textit{Panel D: Excluding no_offcycle years (2018, 2022)}} \\[0.3em]" _n
file write t "Contested        & `b1d' & `b2d' \\" _n
file write t "                 & `s1d' & `s2d' \\" _n
file write t "Observations     & `n1d' & `n2d' \\" _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{3}{l}{\footnotesize Sample B: all-courts expanded, 83 counties. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize Treatment: \textit{contested} = 1 if incumbent faces general-election challenger}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize (exclude-primary restriction). Panel D: presidential-cycle years only.}\\"' _n
file write t `"\multicolumn{3}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A9 — Appendix: Full Pipeline Decomposition
*  All 8 pipeline outcomes × decomposition (contested + uncontested)
*  Panel A: General-election (T2), Panel B: Any-stage (T3),
*  Panel C: General-election + log(pop)
*===================================================================
di as text _n "  Building Table A9: Full Pipeline Decomposition..."

* --- Panel A: T2 general-election decomposition ---
foreach v in actually_reported told_to_report pct_told_to_report ///
    sent_to_courtroom pct_sent_to_courtroom questioned_in_voir_dire ///
    pct_questioned_in_voir_dire utilization_rate {
    cell B contested_long `v' %9.1f treat_pros_contested_long
    if "`v'" == "pct_told_to_report" | "`v'" == "pct_sent_to_courtroom" | ///
       "`v'" == "pct_questioned_in_voir_dire" | "`v'" == "utilization_rate" {
        cell B contested_long `v' %9.3f treat_pros_contested_long
    }
}

* Extract individually for precise macro control
cell B contested_long actually_reported  %9.1f treat_pros_contested_long
local ca1 "`r(coef)'"
local cas1 "`r(se)'"
local can1 "`r(nobs)'"
cell B contested_long told_to_report     %9.1f treat_pros_contested_long
local ca2 "`r(coef)'"
local cas2 "`r(se)'"
cell B contested_long pct_told_to_report %9.3f treat_pros_contested_long
local ca3 "`r(coef)'"
local cas3 "`r(se)'"
local can3 "`r(nobs)'"
cell B contested_long sent_to_courtroom  %9.1f treat_pros_contested_long
local ca4 "`r(coef)'"
local cas4 "`r(se)'"
cell B contested_long pct_sent_to_courtroom %9.3f treat_pros_contested_long
local ca5 "`r(coef)'"
local cas5 "`r(se)'"
local can5 "`r(nobs)'"
cell B contested_long questioned_in_voir_dire %9.1f treat_pros_contested_long
local ca6 "`r(coef)'"
local cas6 "`r(se)'"
cell B contested_long pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local ca7 "`r(coef)'"
local cas7 "`r(se)'"
local can7 "`r(nobs)'"
cell B contested_long utilization_rate   %9.3f treat_pros_contested_long
local ca8 "`r(coef)'"
local cas8 "`r(se)'"
* Uncontested within T2
cell B contested_long actually_reported  %9.1f treat_pros_uncontested
local ua1 "`r(coef)'"
local uas1 "`r(se)'"
cell B contested_long told_to_report     %9.1f treat_pros_uncontested
local ua2 "`r(coef)'"
local uas2 "`r(se)'"
cell B contested_long pct_told_to_report %9.3f treat_pros_uncontested
local ua3 "`r(coef)'"
local uas3 "`r(se)'"
cell B contested_long sent_to_courtroom  %9.1f treat_pros_uncontested
local ua4 "`r(coef)'"
local uas4 "`r(se)'"
cell B contested_long pct_sent_to_courtroom %9.3f treat_pros_uncontested
local ua5 "`r(coef)'"
local uas5 "`r(se)'"
cell B contested_long questioned_in_voir_dire %9.1f treat_pros_uncontested
local ua6 "`r(coef)'"
local uas6 "`r(se)'"
cell B contested_long pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local ua7 "`r(coef)'"
local uas7 "`r(se)'"
cell B contested_long utilization_rate   %9.3f treat_pros_uncontested
local ua8 "`r(coef)'"
local uas8 "`r(se)'"

* Equality tests (Panel A: T2 contested_long)
cell_eq B contested_long actually_reported
local eqa1 "`r(peq)'"
cell_eq B contested_long told_to_report
local eqa2 "`r(peq)'"
cell_eq B contested_long pct_told_to_report
local eqa3 "`r(peq)'"
cell_eq B contested_long sent_to_courtroom
local eqa4 "`r(peq)'"
cell_eq B contested_long pct_sent_to_courtroom
local eqa5 "`r(peq)'"
cell_eq B contested_long questioned_in_voir_dire
local eqa6 "`r(peq)'"
cell_eq B contested_long pct_questioned_in_voir_dire
local eqa7 "`r(peq)'"
cell_eq B contested_long utilization_rate
local eqa8 "`r(peq)'"

* --- Panel B: T3 any-stage decomposition ---
cell B contested actually_reported  %9.1f treat_pros_contested
local cb1 "`r(coef)'"
local cbs1 "`r(se)'"
local cbn1 "`r(nobs)'"
cell B contested told_to_report     %9.1f treat_pros_contested
local cb2 "`r(coef)'"
local cbs2 "`r(se)'"
cell B contested pct_told_to_report %9.3f treat_pros_contested
local cb3 "`r(coef)'"
local cbs3 "`r(se)'"
local cbn3 "`r(nobs)'"
cell B contested sent_to_courtroom  %9.1f treat_pros_contested
local cb4 "`r(coef)'"
local cbs4 "`r(se)'"
cell B contested pct_sent_to_courtroom %9.3f treat_pros_contested
local cb5 "`r(coef)'"
local cbs5 "`r(se)'"
local cbn5 "`r(nobs)'"
cell B contested questioned_in_voir_dire %9.1f treat_pros_contested
local cb6 "`r(coef)'"
local cbs6 "`r(se)'"
cell B contested pct_questioned_in_voir_dire %9.3f treat_pros_contested
local cb7 "`r(coef)'"
local cbs7 "`r(se)'"
local cbn7 "`r(nobs)'"
cell B contested utilization_rate   %9.3f treat_pros_contested
local cb8 "`r(coef)'"
local cbs8 "`r(se)'"
* Uncontested within T3
cell B contested actually_reported  %9.1f treat_pros_uncontested
local ub1 "`r(coef)'"
local ubs1 "`r(se)'"
cell B contested told_to_report     %9.1f treat_pros_uncontested
local ub2 "`r(coef)'"
local ubs2 "`r(se)'"
cell B contested pct_told_to_report %9.3f treat_pros_uncontested
local ub3 "`r(coef)'"
local ubs3 "`r(se)'"
cell B contested sent_to_courtroom  %9.1f treat_pros_uncontested
local ub4 "`r(coef)'"
local ubs4 "`r(se)'"
cell B contested pct_sent_to_courtroom %9.3f treat_pros_uncontested
local ub5 "`r(coef)'"
local ubs5 "`r(se)'"
cell B contested questioned_in_voir_dire %9.1f treat_pros_uncontested
local ub6 "`r(coef)'"
local ubs6 "`r(se)'"
cell B contested pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local ub7 "`r(coef)'"
local ubs7 "`r(se)'"
cell B contested utilization_rate   %9.3f treat_pros_uncontested
local ub8 "`r(coef)'"
local ubs8 "`r(se)'"

* Equality tests (Panel B: T3 contested)
cell_eq B contested actually_reported
local eqb1 "`r(peq)'"
cell_eq B contested told_to_report
local eqb2 "`r(peq)'"
cell_eq B contested pct_told_to_report
local eqb3 "`r(peq)'"
cell_eq B contested sent_to_courtroom
local eqb4 "`r(peq)'"
cell_eq B contested pct_sent_to_courtroom
local eqb5 "`r(peq)'"
cell_eq B contested questioned_in_voir_dire
local eqb6 "`r(peq)'"
cell_eq B contested pct_questioned_in_voir_dire
local eqb7 "`r(peq)'"
cell_eq B contested utilization_rate
local eqb8 "`r(peq)'"

* --- Panel C: T2 general-election + log(pop) ---
cell B contested_long_pop actually_reported  %9.1f treat_pros_contested_long
local pc1 "`r(coef)'"
local pcs1 "`r(se)'"
cell B contested_long_pop told_to_report     %9.1f treat_pros_contested_long
local pc2 "`r(coef)'"
local pcs2 "`r(se)'"
cell B contested_long_pop pct_told_to_report %9.3f treat_pros_contested_long
local pc3 "`r(coef)'"
local pcs3 "`r(se)'"
cell B contested_long_pop sent_to_courtroom  %9.1f treat_pros_contested_long
local pc4 "`r(coef)'"
local pcs4 "`r(se)'"
cell B contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_contested_long
local pc5 "`r(coef)'"
local pcs5 "`r(se)'"
cell B contested_long_pop questioned_in_voir_dire %9.1f treat_pros_contested_long
local pc6 "`r(coef)'"
local pcs6 "`r(se)'"
cell B contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local pc7 "`r(coef)'"
local pcs7 "`r(se)'"
cell B contested_long_pop utilization_rate   %9.3f treat_pros_contested_long
local pc8 "`r(coef)'"
local pcs8 "`r(se)'"
cell B contested_long_pop actually_reported  %9.1f treat_pros_uncontested
local pu1 "`r(coef)'"
local pus1 "`r(se)'"
cell B contested_long_pop told_to_report     %9.1f treat_pros_uncontested
local pu2 "`r(coef)'"
local pus2 "`r(se)'"
cell B contested_long_pop pct_told_to_report %9.3f treat_pros_uncontested
local pu3 "`r(coef)'"
local pus3 "`r(se)'"
cell B contested_long_pop sent_to_courtroom  %9.1f treat_pros_uncontested
local pu4 "`r(coef)'"
local pus4 "`r(se)'"
cell B contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_uncontested
local pu5 "`r(coef)'"
local pus5 "`r(se)'"
cell B contested_long_pop questioned_in_voir_dire %9.1f treat_pros_uncontested
local pu6 "`r(coef)'"
local pus6 "`r(se)'"
cell B contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local pu7 "`r(coef)'"
local pus7 "`r(se)'"
cell B contested_long_pop utilization_rate   %9.3f treat_pros_uncontested
local pu8 "`r(coef)'"
local pus8 "`r(se)'"

* Equality tests (Panel C: T2 contested_long + pop)
cell_eq B contested_long_pop actually_reported
local eqc1 "`r(peq)'"
cell_eq B contested_long_pop told_to_report
local eqc2 "`r(peq)'"
cell_eq B contested_long_pop pct_told_to_report
local eqc3 "`r(peq)'"
cell_eq B contested_long_pop sent_to_courtroom
local eqc4 "`r(peq)'"
cell_eq B contested_long_pop pct_sent_to_courtroom
local eqc5 "`r(peq)'"
cell_eq B contested_long_pop questioned_in_voir_dire
local eqc6 "`r(peq)'"
cell_eq B contested_long_pop pct_questioned_in_voir_dire
local eqc7 "`r(peq)'"
cell_eq B contested_long_pop utilization_rate
local eqc8 "`r(peq)'"

* Dep var means
local dm1 : di %9.1f $m_B_actually_reported
local dm1 = strtrim("`dm1'")
local dm2 : di %9.1f $m_B_told_to_report
local dm2 = strtrim("`dm2'")
local dm3 : di %9.3f $m_B_pct_told_to_report
local dm3 = strtrim("`dm3'")
local dm4 : di %9.1f $m_B_sent_to_courtroom
local dm4 = strtrim("`dm4'")
local dm5 : di %9.3f $m_B_pct_sent_to_courtroom
local dm5 = strtrim("`dm5'")
local dm6 : di %9.1f $m_B_questioned_in_voir_dire
local dm6 = strtrim("`dm6'")
local dm7 : di %9.3f $m_B_pct_questioned_in_voir_dire
local dm7 = strtrim("`dm7'")
local dm8 : di %9.3f $m_B_utilization_rate
local dm8 = strtrim("`dm8'")

* --- Write table A9 ---
local f "`texdir'/mi_tableA9_pipeline_decomp.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Electoral Competition Decomposition: Full Jury Pipeline}" _n
file write t "\label{tab:mi_pipeline_decomp}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{8}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)}" _n
file write t " &\multicolumn{1}{c}{(8)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{Sent to}" _n
file write t " &\multicolumn{1}{c}{\% Sent to}" _n
file write t " &\multicolumn{1}{c}{Voir Dire}" _n
file write t " &\multicolumn{1}{c}{\% Voir}" _n
file write t " &\multicolumn{1}{c}{Utilization} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Questioned}" _n
file write t " &\multicolumn{1}{c}{Dire}" _n
file write t " &\multicolumn{1}{c}{Rate} \\" _n
file write t "\hline" _n
file write t "\multicolumn{9}{l}{\textit{Panel A: General-election decomposition}} \\[0.3em]" _n
file write t "Contested (general)  & `ca1' & `ca2' & `ca3' & `ca4' & `ca5' & `ca6' & `ca7' & `ca8' \\" _n
file write t "                     & `cas1' & `cas2' & `cas3' & `cas4' & `cas5' & `cas6' & `cas7' & `cas8' \\" _n
file write t "Uncontested          & `ua1' & `ua2' & `ua3' & `ua4' & `ua5' & `ua6' & `ua7' & `ua8' \\" _n
file write t "                     & `uas1' & `uas2' & `uas3' & `uas4' & `uas5' & `uas6' & `uas7' & `uas8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqa1' & `eqa2' & `eqa3' & `eqa4' & `eqa5' & `eqa6' & `eqa7' & `eqa8' \\"' _n
file write t "Observations         & `can1' & `can1' & `can3' & `can1' & `can5' & `can1' & `can7' & `can7' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{Panel B: Any-stage decomposition}} \\[0.3em]" _n
file write t "Contested (any stage) & `cb1' & `cb2' & `cb3' & `cb4' & `cb5' & `cb6' & `cb7' & `cb8' \\" _n
file write t "                      & `cbs1' & `cbs2' & `cbs3' & `cbs4' & `cbs5' & `cbs6' & `cbs7' & `cbs8' \\" _n
file write t "Uncontested           & `ub1' & `ub2' & `ub3' & `ub4' & `ub5' & `ub6' & `ub7' & `ub8' \\" _n
file write t "                      & `ubs1' & `ubs2' & `ubs3' & `ubs4' & `ubs5' & `ubs6' & `ubs7' & `ubs8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqb1' & `eqb2' & `eqb3' & `eqb4' & `eqb5' & `eqb6' & `eqb7' & `eqb8' \\"' _n
file write t "Observations          & `cbn1' & `cbn1' & `cbn3' & `cbn1' & `cbn5' & `cbn1' & `cbn7' & `cbn7' \\[0.5em]" _n
file write t "\multicolumn{9}{l}{\textit{Panel C: General-election with log(population) control}} \\[0.3em]" _n
file write t "Contested (general)  & `pc1' & `pc2' & `pc3' & `pc4' & `pc5' & `pc6' & `pc7' & `pc8' \\" _n
file write t "                     & `pcs1' & `pcs2' & `pcs3' & `pcs4' & `pcs5' & `pcs6' & `pcs7' & `pcs8' \\" _n
file write t "Uncontested          & `pu1' & `pu2' & `pu3' & `pu4' & `pu5' & `pu6' & `pu7' & `pu8' \\" _n
file write t "                     & `pus1' & `pus2' & `pus3' & `pus4' & `pus5' & `pus6' & `pus7' & `pus8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqc1' & `eqc2' & `eqc3' & `eqc4' & `eqc5' & `eqc6' & `eqc7' & `eqc8' \\"' _n
file write t "\hline" _n
file write t "Dep.\ var.\ mean & `dm1' & `dm2' & `dm3' & `dm4' & `dm5' & `dm6' & `dm7' & `dm8' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{9}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Omitted category: no election (off-cycle years).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Panel A: general-election contested vs.\ uncontested. Panel B: any-stage contested vs.\ uncontested.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Panel C adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize \(p\)-values in square brackets test \(H_0\): \(\beta_{\text{con}}=\beta_{\text{uncon}}\) (Wald \(F\)-test).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A10 — Appendix: Full Verdict Decomposition
*  All 7 verdict outcomes × decomposition (contested + uncontested)
*  Panel A: General-election (T2), Panel B: Any-stage (T3),
*  Panel C: General-election + log(pop)
*===================================================================
di as text _n "  Building Table A10: Full Verdict Decomposition..."

* --- Panel A: T2 general-election decomposition ---
* Contested (general)
cell B contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local ca1 "`r(coef)'"
local cas1 "`r(se)'"
local can1 "`r(nobs)'"
cell B contested_long capital_felony %9.1f treat_pros_contested_long
local ca2 "`r(coef)'"
local cas2 "`r(se)'"
cell B contested_long other_felony %9.1f treat_pros_contested_long
local ca3 "`r(coef)'"
local cas3 "`r(se)'"
cell B contested_long other_cases %9.1f treat_pros_contested_long
local ca4 "`r(coef)'"
local cas4 "`r(se)'"
cell B contested_long pct_capital_felony %9.3f treat_pros_contested_long
local ca5 "`r(coef)'"
local cas5 "`r(se)'"
local can5 "`r(nobs)'"
cell B contested_long pct_other_felony %9.3f treat_pros_contested_long
local ca6 "`r(coef)'"
local cas6 "`r(se)'"
cell B contested_long pct_other_cases %9.3f treat_pros_contested_long
local ca7 "`r(coef)'"
local cas7 "`r(se)'"
* Uncontested within T2
cell B contested_long total_jury_verdicts %9.1f treat_pros_uncontested
local ua1 "`r(coef)'"
local uas1 "`r(se)'"
cell B contested_long capital_felony %9.1f treat_pros_uncontested
local ua2 "`r(coef)'"
local uas2 "`r(se)'"
cell B contested_long other_felony %9.1f treat_pros_uncontested
local ua3 "`r(coef)'"
local uas3 "`r(se)'"
cell B contested_long other_cases %9.1f treat_pros_uncontested
local ua4 "`r(coef)'"
local uas4 "`r(se)'"
cell B contested_long pct_capital_felony %9.3f treat_pros_uncontested
local ua5 "`r(coef)'"
local uas5 "`r(se)'"
cell B contested_long pct_other_felony %9.3f treat_pros_uncontested
local ua6 "`r(coef)'"
local uas6 "`r(se)'"
cell B contested_long pct_other_cases %9.3f treat_pros_uncontested
local ua7 "`r(coef)'"
local uas7 "`r(se)'"

* Equality tests (Panel A: T2 contested_long — verdicts)
cell_eq B contested_long total_jury_verdicts
local eqa1 "`r(peq)'"
cell_eq B contested_long capital_felony
local eqa2 "`r(peq)'"
cell_eq B contested_long other_felony
local eqa3 "`r(peq)'"
cell_eq B contested_long other_cases
local eqa4 "`r(peq)'"
cell_eq B contested_long pct_capital_felony
local eqa5 "`r(peq)'"
cell_eq B contested_long pct_other_felony
local eqa6 "`r(peq)'"
cell_eq B contested_long pct_other_cases
local eqa7 "`r(peq)'"

* --- Panel B: T3 any-stage decomposition ---
cell B contested total_jury_verdicts %9.1f treat_pros_contested
local cb1 "`r(coef)'"
local cbs1 "`r(se)'"
local cbn1 "`r(nobs)'"
cell B contested capital_felony %9.1f treat_pros_contested
local cb2 "`r(coef)'"
local cbs2 "`r(se)'"
cell B contested other_felony %9.1f treat_pros_contested
local cb3 "`r(coef)'"
local cbs3 "`r(se)'"
cell B contested other_cases %9.1f treat_pros_contested
local cb4 "`r(coef)'"
local cbs4 "`r(se)'"
cell B contested pct_capital_felony %9.3f treat_pros_contested
local cb5 "`r(coef)'"
local cbs5 "`r(se)'"
local cbn5 "`r(nobs)'"
cell B contested pct_other_felony %9.3f treat_pros_contested
local cb6 "`r(coef)'"
local cbs6 "`r(se)'"
cell B contested pct_other_cases %9.3f treat_pros_contested
local cb7 "`r(coef)'"
local cbs7 "`r(se)'"
* Uncontested within T3
cell B contested total_jury_verdicts %9.1f treat_pros_uncontested
local ub1 "`r(coef)'"
local ubs1 "`r(se)'"
cell B contested capital_felony %9.1f treat_pros_uncontested
local ub2 "`r(coef)'"
local ubs2 "`r(se)'"
cell B contested other_felony %9.1f treat_pros_uncontested
local ub3 "`r(coef)'"
local ubs3 "`r(se)'"
cell B contested other_cases %9.1f treat_pros_uncontested
local ub4 "`r(coef)'"
local ubs4 "`r(se)'"
cell B contested pct_capital_felony %9.3f treat_pros_uncontested
local ub5 "`r(coef)'"
local ubs5 "`r(se)'"
cell B contested pct_other_felony %9.3f treat_pros_uncontested
local ub6 "`r(coef)'"
local ubs6 "`r(se)'"
cell B contested pct_other_cases %9.3f treat_pros_uncontested
local ub7 "`r(coef)'"
local ubs7 "`r(se)'"

* Equality tests (Panel B: T3 contested — verdicts)
cell_eq B contested total_jury_verdicts
local eqb1 "`r(peq)'"
cell_eq B contested capital_felony
local eqb2 "`r(peq)'"
cell_eq B contested other_felony
local eqb3 "`r(peq)'"
cell_eq B contested other_cases
local eqb4 "`r(peq)'"
cell_eq B contested pct_capital_felony
local eqb5 "`r(peq)'"
cell_eq B contested pct_other_felony
local eqb6 "`r(peq)'"
cell_eq B contested pct_other_cases
local eqb7 "`r(peq)'"

* --- Panel C: T2 + log(pop) ---
cell B contested_long_pop total_jury_verdicts %9.1f treat_pros_contested_long
local pc1 "`r(coef)'"
local pcs1 "`r(se)'"
cell B contested_long_pop capital_felony %9.1f treat_pros_contested_long
local pc2 "`r(coef)'"
local pcs2 "`r(se)'"
cell B contested_long_pop other_felony %9.1f treat_pros_contested_long
local pc3 "`r(coef)'"
local pcs3 "`r(se)'"
cell B contested_long_pop other_cases %9.1f treat_pros_contested_long
local pc4 "`r(coef)'"
local pcs4 "`r(se)'"
cell B contested_long_pop pct_capital_felony %9.3f treat_pros_contested_long
local pc5 "`r(coef)'"
local pcs5 "`r(se)'"
cell B contested_long_pop pct_other_felony %9.3f treat_pros_contested_long
local pc6 "`r(coef)'"
local pcs6 "`r(se)'"
cell B contested_long_pop pct_other_cases %9.3f treat_pros_contested_long
local pc7 "`r(coef)'"
local pcs7 "`r(se)'"
cell B contested_long_pop total_jury_verdicts %9.1f treat_pros_uncontested
local pu1 "`r(coef)'"
local pus1 "`r(se)'"
cell B contested_long_pop capital_felony %9.1f treat_pros_uncontested
local pu2 "`r(coef)'"
local pus2 "`r(se)'"
cell B contested_long_pop other_felony %9.1f treat_pros_uncontested
local pu3 "`r(coef)'"
local pus3 "`r(se)'"
cell B contested_long_pop other_cases %9.1f treat_pros_uncontested
local pu4 "`r(coef)'"
local pus4 "`r(se)'"
cell B contested_long_pop pct_capital_felony %9.3f treat_pros_uncontested
local pu5 "`r(coef)'"
local pus5 "`r(se)'"
cell B contested_long_pop pct_other_felony %9.3f treat_pros_uncontested
local pu6 "`r(coef)'"
local pus6 "`r(se)'"
cell B contested_long_pop pct_other_cases %9.3f treat_pros_uncontested
local pu7 "`r(coef)'"
local pus7 "`r(se)'"

* Equality tests (Panel C: T2 contested_long + pop — verdicts)
cell_eq B contested_long_pop total_jury_verdicts
local eqc1 "`r(peq)'"
cell_eq B contested_long_pop capital_felony
local eqc2 "`r(peq)'"
cell_eq B contested_long_pop other_felony
local eqc3 "`r(peq)'"
cell_eq B contested_long_pop other_cases
local eqc4 "`r(peq)'"
cell_eq B contested_long_pop pct_capital_felony
local eqc5 "`r(peq)'"
cell_eq B contested_long_pop pct_other_felony
local eqc6 "`r(peq)'"
cell_eq B contested_long_pop pct_other_cases
local eqc7 "`r(peq)'"

* Dep var means
local dm1 : di %9.1f $m_B_total_jury_verdicts
local dm1 = strtrim("`dm1'")
local dm2 : di %9.1f $m_B_capital_felony
local dm2 = strtrim("`dm2'")
local dm3 : di %9.1f $m_B_other_felony
local dm3 = strtrim("`dm3'")
local dm4 : di %9.1f $m_B_other_cases
local dm4 = strtrim("`dm4'")
local dm5 : di %9.3f $m_B_pct_capital_felony
local dm5 = strtrim("`dm5'")
local dm6 : di %9.3f $m_B_pct_other_felony
local dm6 = strtrim("`dm6'")
local dm7 : di %9.3f $m_B_pct_other_cases
local dm7 = strtrim("`dm7'")

* --- Write table A10 ---
local f "`texdir'/mi_tableA10_verdict_decomp.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Electoral Competition Decomposition: Verdict Outcomes}" _n
file write t "\label{tab:mi_verdict_decomp}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{7}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{4}{c}{Verdict Counts}" _n
file write t " &\multicolumn{3}{c}{Verdict Composition} \\" _n
file write t "\cmidrule(lr){2-5}\cmidrule(lr){6-8}" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)} \\" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases} \\" _n
file write t "\hline" _n
file write t "\multicolumn{8}{l}{\textit{Panel A: General-election decomposition}} \\[0.3em]" _n
file write t "Contested (general)  & `ca1' & `ca2' & `ca3' & `ca4' & `ca5' & `ca6' & `ca7' \\" _n
file write t "                     & `cas1' & `cas2' & `cas3' & `cas4' & `cas5' & `cas6' & `cas7' \\" _n
file write t "Uncontested          & `ua1' & `ua2' & `ua3' & `ua4' & `ua5' & `ua6' & `ua7' \\" _n
file write t "                     & `uas1' & `uas2' & `uas3' & `uas4' & `uas5' & `uas6' & `uas7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqa1' & `eqa2' & `eqa3' & `eqa4' & `eqa5' & `eqa6' & `eqa7' \\"' _n
file write t "Observations         & `can1' & `can1' & `can1' & `can1' & `can5' & `can5' & `can5' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{Panel B: Any-stage decomposition}} \\[0.3em]" _n
file write t "Contested (any stage) & `cb1' & `cb2' & `cb3' & `cb4' & `cb5' & `cb6' & `cb7' \\" _n
file write t "                      & `cbs1' & `cbs2' & `cbs3' & `cbs4' & `cbs5' & `cbs6' & `cbs7' \\" _n
file write t "Uncontested           & `ub1' & `ub2' & `ub3' & `ub4' & `ub5' & `ub6' & `ub7' \\" _n
file write t "                      & `ubs1' & `ubs2' & `ubs3' & `ubs4' & `ubs5' & `ubs6' & `ubs7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqb1' & `eqb2' & `eqb3' & `eqb4' & `eqb5' & `eqb6' & `eqb7' \\"' _n
file write t "Observations          & `cbn1' & `cbn1' & `cbn1' & `cbn1' & `cbn5' & `cbn5' & `cbn5' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{Panel C: General-election with log(population) control}} \\[0.3em]" _n
file write t "Contested (general)  & `pc1' & `pc2' & `pc3' & `pc4' & `pc5' & `pc6' & `pc7' \\" _n
file write t "                     & `pcs1' & `pcs2' & `pcs3' & `pcs4' & `pcs5' & `pcs6' & `pcs7' \\" _n
file write t "Uncontested          & `pu1' & `pu2' & `pu3' & `pu4' & `pu5' & `pu6' & `pu7' \\" _n
file write t "                     & `pus1' & `pus2' & `pus3' & `pus4' & `pus5' & `pus6' & `pus7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqc1' & `eqc2' & `eqc3' & `eqc4' & `eqc5' & `eqc6' & `eqc7' \\"' _n
file write t "\hline" _n
file write t "Dep.\ var.\ mean & `dm1' & `dm2' & `dm3' & `dm4' & `dm5' & `dm6' & `dm7' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{8}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Omitted category: no election (off-cycle years).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Panel A: general-election contested vs.\ uncontested. Panel B: any-stage contested vs.\ uncontested.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Panel C adds log(county population) as control. Composition shares condition on total verdicts \(> 0\).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize \(p\)-values in square brackets test \(H_0\): \(\beta_{\text{con}}=\beta_{\text{uncon}}\) (Wald \(F\)-test).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE 15 — All Verdict Outcomes × All Treatment Definitions
*  Variant B | Columns: 4 counts + 3 composition shares = 7 cols
*  Panel A: Pressure (T1), Panel B: Contested gen (T2),
*  Panel C: Contested any (T3)
*===================================================================
di as text _n "  Building Table 15: All Verdicts × All Treatments..."

* --- Panel A: Pressure (T1) ---
cell B pressure total_jury_verdicts %9.1f treat_pros_pressure
local a1 "`r(coef)'"
local as1 "`r(se)'"
local an1 "`r(nobs)'"
local abeta1 = r(beta_raw)

cell B pressure capital_felony %9.1f treat_pros_pressure
local a2 "`r(coef)'"
local as2 "`r(se)'"

cell B pressure other_felony %9.1f treat_pros_pressure
local a3 "`r(coef)'"
local as3 "`r(se)'"

cell B pressure other_cases %9.1f treat_pros_pressure
local a4 "`r(coef)'"
local as4 "`r(se)'"

cell B pressure pct_capital_felony %9.3f treat_pros_pressure
local a5 "`r(coef)'"
local as5 "`r(se)'"
local an5 "`r(nobs)'"

cell B pressure pct_other_felony %9.3f treat_pros_pressure
local a6 "`r(coef)'"
local as6 "`r(se)'"

cell B pressure pct_other_cases %9.3f treat_pros_pressure
local a7 "`r(coef)'"
local as7 "`r(se)'"

* --- Panel A: Open-seat (T1 decomposition) ---
cell B pressure total_jury_verdicts %9.1f open_pros
local oa1 "`r(coef)'"
local oas1 "`r(se)'"
cell B pressure capital_felony %9.1f open_pros
local oa2 "`r(coef)'"
local oas2 "`r(se)'"
cell B pressure other_felony %9.1f open_pros
local oa3 "`r(coef)'"
local oas3 "`r(se)'"
cell B pressure other_cases %9.1f open_pros
local oa4 "`r(coef)'"
local oas4 "`r(se)'"
cell B pressure pct_capital_felony %9.3f open_pros
local oa5 "`r(coef)'"
local oas5 "`r(se)'"
cell B pressure pct_other_felony %9.3f open_pros
local oa6 "`r(coef)'"
local oas6 "`r(se)'"
cell B pressure pct_other_cases %9.3f open_pros
local oa7 "`r(coef)'"
local oas7 "`r(se)'"

* --- Panel B: Contested general election (T2) ---
cell B contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local b1 "`r(coef)'"
local bs1 "`r(se)'"
local bn1 "`r(nobs)'"
local bbeta1 = r(beta_raw)

cell B contested_long capital_felony %9.1f treat_pros_contested_long
local b2 "`r(coef)'"
local bs2 "`r(se)'"

cell B contested_long other_felony %9.1f treat_pros_contested_long
local b3 "`r(coef)'"
local bs3 "`r(se)'"

cell B contested_long other_cases %9.1f treat_pros_contested_long
local b4 "`r(coef)'"
local bs4 "`r(se)'"

cell B contested_long pct_capital_felony %9.3f treat_pros_contested_long
local b5 "`r(coef)'"
local bs5 "`r(se)'"
local bn5 "`r(nobs)'"

cell B contested_long pct_other_felony %9.3f treat_pros_contested_long
local b6 "`r(coef)'"
local bs6 "`r(se)'"

cell B contested_long pct_other_cases %9.3f treat_pros_contested_long
local b7 "`r(coef)'"
local bs7 "`r(se)'"

* --- Panel C: Contested any stage (T3) ---
cell B contested total_jury_verdicts %9.1f treat_pros_contested
local c1 "`r(coef)'"
local cs1 "`r(se)'"
local cn1 "`r(nobs)'"
local cbeta1 = r(beta_raw)

cell B contested capital_felony %9.1f treat_pros_contested
local c2 "`r(coef)'"
local cs2 "`r(se)'"

cell B contested other_felony %9.1f treat_pros_contested
local c3 "`r(coef)'"
local cs3 "`r(se)'"

cell B contested other_cases %9.1f treat_pros_contested
local c4 "`r(coef)'"
local cs4 "`r(se)'"

cell B contested pct_capital_felony %9.3f treat_pros_contested
local c5 "`r(coef)'"
local cs5 "`r(se)'"
local cn5 "`r(nobs)'"

cell B contested pct_other_felony %9.3f treat_pros_contested
local c6 "`r(coef)'"
local cs6 "`r(se)'"

cell B contested pct_other_cases %9.3f treat_pros_contested
local c7 "`r(coef)'"
local cs7 "`r(se)'"

* --- Panel A: Pressure (T1) + log(pop) ---
cell B pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local ap1 "`r(coef)'"
local aps1 "`r(se)'"
cell B pressure_pop capital_felony %9.1f treat_pros_pressure
local ap2 "`r(coef)'"
local aps2 "`r(se)'"
cell B pressure_pop other_felony %9.1f treat_pros_pressure
local ap3 "`r(coef)'"
local aps3 "`r(se)'"
cell B pressure_pop other_cases %9.1f treat_pros_pressure
local ap4 "`r(coef)'"
local aps4 "`r(se)'"
cell B pressure_pop pct_capital_felony %9.3f treat_pros_pressure
local ap5 "`r(coef)'"
local aps5 "`r(se)'"
cell B pressure_pop pct_other_felony %9.3f treat_pros_pressure
local ap6 "`r(coef)'"
local aps6 "`r(se)'"
cell B pressure_pop pct_other_cases %9.3f treat_pros_pressure
local ap7 "`r(coef)'"
local aps7 "`r(se)'"

* --- Panel B (T2 contested_long) + log(pop) ---
cell B contested_long_pop total_jury_verdicts %9.1f treat_pros_contested_long
local bp1 "`r(coef)'"
local bps1 "`r(se)'"
cell B contested_long_pop capital_felony %9.1f treat_pros_contested_long
local bp2 "`r(coef)'"
local bps2 "`r(se)'"
cell B contested_long_pop other_felony %9.1f treat_pros_contested_long
local bp3 "`r(coef)'"
local bps3 "`r(se)'"
cell B contested_long_pop other_cases %9.1f treat_pros_contested_long
local bp4 "`r(coef)'"
local bps4 "`r(se)'"
cell B contested_long_pop pct_capital_felony %9.3f treat_pros_contested_long
local bp5 "`r(coef)'"
local bps5 "`r(se)'"
cell B contested_long_pop pct_other_felony %9.3f treat_pros_contested_long
local bp6 "`r(coef)'"
local bps6 "`r(se)'"
cell B contested_long_pop pct_other_cases %9.3f treat_pros_contested_long
local bp7 "`r(coef)'"
local bps7 "`r(se)'"

* --- Panel C (T3 contested) + log(pop) ---
cell B contested_pop total_jury_verdicts %9.1f treat_pros_contested
local cp1 "`r(coef)'"
local cps1 "`r(se)'"
cell B contested_pop capital_felony %9.1f treat_pros_contested
local cp2 "`r(coef)'"
local cps2 "`r(se)'"
cell B contested_pop other_felony %9.1f treat_pros_contested
local cp3 "`r(coef)'"
local cps3 "`r(se)'"
cell B contested_pop other_cases %9.1f treat_pros_contested
local cp4 "`r(coef)'"
local cps4 "`r(se)'"
cell B contested_pop pct_capital_felony %9.3f treat_pros_contested
local cp5 "`r(coef)'"
local cps5 "`r(se)'"
cell B contested_pop pct_other_felony %9.3f treat_pros_contested
local cp6 "`r(coef)'"
local cps6 "`r(se)'"
cell B contested_pop pct_other_cases %9.3f treat_pros_contested
local cp7 "`r(coef)'"
local cps7 "`r(se)'"

* --- Dep var means ---
local dm1 : di %9.1f $m_B_total_jury_verdicts
local dm1 = strtrim("`dm1'")
local dm2 : di %9.1f $m_B_capital_felony
local dm2 = strtrim("`dm2'")
local dm3 : di %9.1f $m_B_other_felony
local dm3 = strtrim("`dm3'")
local dm4 : di %9.1f $m_B_other_cases
local dm4 = strtrim("`dm4'")
local dm5 : di %9.3f $m_B_pct_capital_felony
local dm5 = strtrim("`dm5'")
local dm6 : di %9.3f $m_B_pct_other_felony
local dm6 = strtrim("`dm6'")
local dm7 : di %9.3f $m_B_pct_other_cases
local dm7 = strtrim("`dm7'")

* --- Write table ---
local f "`texdir'/mi_table15_verdicts_all.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Outcomes Across Treatment Definitions}" _n
file write t "\label{tab:mi_verdicts_all}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{7}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{4}{c}{Verdict Counts}" _n
file write t " &\multicolumn{3}{c}{Verdict Composition} \\" _n
file write t "\cmidrule(lr){2-5}\cmidrule(lr){6-8}" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)} \\" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases} \\" _n
file write t "\hline" _n
file write t "\multicolumn{8}{l}{\textit{Panel A: Electoral pressure}} \\[0.3em]" _n
file write t "Pressure    & `a1' & `a2' & `a3' & `a4' & `a5' & `a6' & `a7' \\" _n
file write t "            & `as1' & `as2' & `as3' & `as4' & `as5' & `as6' & `as7' \\" _n
file write t "Open-seat election & `oa1' & `oa2' & `oa3' & `oa4' & `oa5' & `oa6' & `oa7' \\" _n
file write t "            & `oas1' & `oas2' & `oas3' & `oas4' & `oas5' & `oas6' & `oas7' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Pressure    & `ap1' & `ap2' & `ap3' & `ap4' & `ap5' & `ap6' & `ap7' \\" _n
file write t "            & `aps1' & `aps2' & `aps3' & `aps4' & `aps5' & `aps6' & `aps7' \\" _n
file write t "Observations & `an1' & `an1' & `an1' & `an1' & `an5' & `an5' & `an5' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{Panel B: Contested --- any stage}} \\[0.3em]" _n
file write t "Contested   & `c1' & `c2' & `c3' & `c4' & `c5' & `c6' & `c7' \\" _n
file write t "            & `cs1' & `cs2' & `cs3' & `cs4' & `cs5' & `cs6' & `cs7' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Contested   & `cp1' & `cp2' & `cp3' & `cp4' & `cp5' & `cp6' & `cp7' \\" _n
file write t "            & `cps1' & `cps2' & `cps3' & `cps4' & `cps5' & `cps6' & `cps7' \\" _n
file write t "Observations & `cn1' & `cn1' & `cn1' & `cn1' & `cn5' & `cn5' & `cn5' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{Panel C: Contested --- general election}} \\[0.3em]" _n
file write t "Contested   & `b1' & `b2' & `b3' & `b4' & `b5' & `b6' & `b7' \\" _n
file write t "            & `bs1' & `bs2' & `bs3' & `bs4' & `bs5' & `bs6' & `bs7' \\[0.5em]" _n
file write t "\multicolumn{8}{l}{\textit{\quad With log(population) control}} \\[0.3em]" _n
file write t "Contested   & `bp1' & `bp2' & `bp3' & `bp4' & `bp5' & `bp6' & `bp7' \\" _n
file write t "            & `bps1' & `bps2' & `bps3' & `bps4' & `bps5' & `bps6' & `bps7' \\" _n
file write t "Observations & `bn1' & `bn1' & `bn1' & `bn1' & `bn5' & `bn5' & `bn5' \\" _n
file write t "\hline" _n
file write t "Dep.\ var.\ mean & `dm1' & `dm2' & `dm3' & `dm4' & `dm5' & `dm6' & `dm7' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{8}{l}{\footnotesize Sample B: all-courts expanded, 83 counties (see Table \ref{tab:mi_samples}).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Panel A: \textit{pressure} = incumbent faces election. Panels B--C: coefficient on \textit{contested} (uncontested controlled).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Panel C excludes primary-only contested county-years. Composition shares condition on total verdicts $> 0$.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A11 — Appendix: Pipeline Decomposition × Population Size
*  All 8 pipeline outcomes × decomposition (contested + uncontested)
*  Panel A: Above-median, Panel B: Below-median,
*  Panel C: Above with pop control, Panel D: Below with pop control
*===================================================================
di as text _n "  Table A11: Pipeline decomposition × population heterogeneity..."

* --- Panel A: Above-median (general-election T2) ---
cell B_highpop contested_long actually_reported %9.1f treat_pros_contested_long
local ha1 "`r(coef)'"
local has1 "`r(se)'"
local han1 "`r(nobs)'"
cell B_highpop contested_long told_to_report %9.1f treat_pros_contested_long
local ha2 "`r(coef)'"
local has2 "`r(se)'"
cell B_highpop contested_long pct_told_to_report %9.3f treat_pros_contested_long
local ha3 "`r(coef)'"
local has3 "`r(se)'"
local han3 "`r(nobs)'"
cell B_highpop contested_long sent_to_courtroom %9.1f treat_pros_contested_long
local ha4 "`r(coef)'"
local has4 "`r(se)'"
cell B_highpop contested_long pct_sent_to_courtroom %9.3f treat_pros_contested_long
local ha5 "`r(coef)'"
local has5 "`r(se)'"
local han5 "`r(nobs)'"
cell B_highpop contested_long questioned_in_voir_dire %9.1f treat_pros_contested_long
local ha6 "`r(coef)'"
local has6 "`r(se)'"
cell B_highpop contested_long pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local ha7 "`r(coef)'"
local has7 "`r(se)'"
local han7 "`r(nobs)'"
cell B_highpop contested_long utilization_rate %9.3f treat_pros_contested_long
local ha8 "`r(coef)'"
local has8 "`r(se)'"
local han8 "`r(nobs)'"

* Uncontested (above-median, T2)
cell B_highpop contested_long actually_reported %9.1f treat_pros_uncontested
local hua1 "`r(coef)'"
local huas1 "`r(se)'"
cell B_highpop contested_long told_to_report %9.1f treat_pros_uncontested
local hua2 "`r(coef)'"
local huas2 "`r(se)'"
cell B_highpop contested_long pct_told_to_report %9.3f treat_pros_uncontested
local hua3 "`r(coef)'"
local huas3 "`r(se)'"
cell B_highpop contested_long sent_to_courtroom %9.1f treat_pros_uncontested
local hua4 "`r(coef)'"
local huas4 "`r(se)'"
cell B_highpop contested_long pct_sent_to_courtroom %9.3f treat_pros_uncontested
local hua5 "`r(coef)'"
local huas5 "`r(se)'"
cell B_highpop contested_long questioned_in_voir_dire %9.1f treat_pros_uncontested
local hua6 "`r(coef)'"
local huas6 "`r(se)'"
cell B_highpop contested_long pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local hua7 "`r(coef)'"
local huas7 "`r(se)'"
cell B_highpop contested_long utilization_rate %9.3f treat_pros_uncontested
local hua8 "`r(coef)'"
local huas8 "`r(se)'"

* Equality tests (A11 Panel A: B_highpop contested_long)
cell_eq B_highpop contested_long actually_reported
local eqha1 "`r(peq)'"
cell_eq B_highpop contested_long told_to_report
local eqha2 "`r(peq)'"
cell_eq B_highpop contested_long pct_told_to_report
local eqha3 "`r(peq)'"
cell_eq B_highpop contested_long sent_to_courtroom
local eqha4 "`r(peq)'"
cell_eq B_highpop contested_long pct_sent_to_courtroom
local eqha5 "`r(peq)'"
cell_eq B_highpop contested_long questioned_in_voir_dire
local eqha6 "`r(peq)'"
cell_eq B_highpop contested_long pct_questioned_in_voir_dire
local eqha7 "`r(peq)'"
cell_eq B_highpop contested_long utilization_rate
local eqha8 "`r(peq)'"

* --- Panel B: Below-median (general-election T2) ---
cell B_lowpop contested_long actually_reported %9.1f treat_pros_contested_long
local la1 "`r(coef)'"
local las1 "`r(se)'"
local lan1 "`r(nobs)'"
cell B_lowpop contested_long told_to_report %9.1f treat_pros_contested_long
local la2 "`r(coef)'"
local las2 "`r(se)'"
cell B_lowpop contested_long pct_told_to_report %9.3f treat_pros_contested_long
local la3 "`r(coef)'"
local las3 "`r(se)'"
local lan3 "`r(nobs)'"
cell B_lowpop contested_long sent_to_courtroom %9.1f treat_pros_contested_long
local la4 "`r(coef)'"
local las4 "`r(se)'"
cell B_lowpop contested_long pct_sent_to_courtroom %9.3f treat_pros_contested_long
local la5 "`r(coef)'"
local las5 "`r(se)'"
local lan5 "`r(nobs)'"
cell B_lowpop contested_long questioned_in_voir_dire %9.1f treat_pros_contested_long
local la6 "`r(coef)'"
local las6 "`r(se)'"
cell B_lowpop contested_long pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local la7 "`r(coef)'"
local las7 "`r(se)'"
local lan7 "`r(nobs)'"
cell B_lowpop contested_long utilization_rate %9.3f treat_pros_contested_long
local la8 "`r(coef)'"
local las8 "`r(se)'"
local lan8 "`r(nobs)'"

* Uncontested (below-median, T2)
cell B_lowpop contested_long actually_reported %9.1f treat_pros_uncontested
local lua1 "`r(coef)'"
local luas1 "`r(se)'"
cell B_lowpop contested_long told_to_report %9.1f treat_pros_uncontested
local lua2 "`r(coef)'"
local luas2 "`r(se)'"
cell B_lowpop contested_long pct_told_to_report %9.3f treat_pros_uncontested
local lua3 "`r(coef)'"
local luas3 "`r(se)'"
cell B_lowpop contested_long sent_to_courtroom %9.1f treat_pros_uncontested
local lua4 "`r(coef)'"
local luas4 "`r(se)'"
cell B_lowpop contested_long pct_sent_to_courtroom %9.3f treat_pros_uncontested
local lua5 "`r(coef)'"
local luas5 "`r(se)'"
cell B_lowpop contested_long questioned_in_voir_dire %9.1f treat_pros_uncontested
local lua6 "`r(coef)'"
local luas6 "`r(se)'"
cell B_lowpop contested_long pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local lua7 "`r(coef)'"
local luas7 "`r(se)'"
cell B_lowpop contested_long utilization_rate %9.3f treat_pros_uncontested
local lua8 "`r(coef)'"
local luas8 "`r(se)'"

* Equality tests (A11 Panel B: B_lowpop contested_long)
cell_eq B_lowpop contested_long actually_reported
local eqla1 "`r(peq)'"
cell_eq B_lowpop contested_long told_to_report
local eqla2 "`r(peq)'"
cell_eq B_lowpop contested_long pct_told_to_report
local eqla3 "`r(peq)'"
cell_eq B_lowpop contested_long sent_to_courtroom
local eqla4 "`r(peq)'"
cell_eq B_lowpop contested_long pct_sent_to_courtroom
local eqla5 "`r(peq)'"
cell_eq B_lowpop contested_long questioned_in_voir_dire
local eqla6 "`r(peq)'"
cell_eq B_lowpop contested_long pct_questioned_in_voir_dire
local eqla7 "`r(peq)'"
cell_eq B_lowpop contested_long utilization_rate
local eqla8 "`r(peq)'"

* --- Panel C: Above-median with pop control ---
cell B_highpop contested_long_pop actually_reported %9.1f treat_pros_contested_long
local hpa1 "`r(coef)'"
local hpas1 "`r(se)'"
cell B_highpop contested_long_pop told_to_report %9.1f treat_pros_contested_long
local hpa2 "`r(coef)'"
local hpas2 "`r(se)'"
cell B_highpop contested_long_pop pct_told_to_report %9.3f treat_pros_contested_long
local hpa3 "`r(coef)'"
local hpas3 "`r(se)'"
cell B_highpop contested_long_pop sent_to_courtroom %9.1f treat_pros_contested_long
local hpa4 "`r(coef)'"
local hpas4 "`r(se)'"
cell B_highpop contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_contested_long
local hpa5 "`r(coef)'"
local hpas5 "`r(se)'"
cell B_highpop contested_long_pop questioned_in_voir_dire %9.1f treat_pros_contested_long
local hpa6 "`r(coef)'"
local hpas6 "`r(se)'"
cell B_highpop contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local hpa7 "`r(coef)'"
local hpas7 "`r(se)'"
cell B_highpop contested_long_pop utilization_rate %9.3f treat_pros_contested_long
local hpa8 "`r(coef)'"
local hpas8 "`r(se)'"

* Uncontested (above-median, pop control)
cell B_highpop contested_long_pop actually_reported %9.1f treat_pros_uncontested
local hpua1 "`r(coef)'"
local hpuas1 "`r(se)'"
cell B_highpop contested_long_pop told_to_report %9.1f treat_pros_uncontested
local hpua2 "`r(coef)'"
local hpuas2 "`r(se)'"
cell B_highpop contested_long_pop pct_told_to_report %9.3f treat_pros_uncontested
local hpua3 "`r(coef)'"
local hpuas3 "`r(se)'"
cell B_highpop contested_long_pop sent_to_courtroom %9.1f treat_pros_uncontested
local hpua4 "`r(coef)'"
local hpuas4 "`r(se)'"
cell B_highpop contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_uncontested
local hpua5 "`r(coef)'"
local hpuas5 "`r(se)'"
cell B_highpop contested_long_pop questioned_in_voir_dire %9.1f treat_pros_uncontested
local hpua6 "`r(coef)'"
local hpuas6 "`r(se)'"
cell B_highpop contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local hpua7 "`r(coef)'"
local hpuas7 "`r(se)'"
cell B_highpop contested_long_pop utilization_rate %9.3f treat_pros_uncontested
local hpua8 "`r(coef)'"
local hpuas8 "`r(se)'"

* Equality tests (A11 Panel C: B_highpop contested_long_pop)
cell_eq B_highpop contested_long_pop actually_reported
local eqhpa1 "`r(peq)'"
cell_eq B_highpop contested_long_pop told_to_report
local eqhpa2 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_told_to_report
local eqhpa3 "`r(peq)'"
cell_eq B_highpop contested_long_pop sent_to_courtroom
local eqhpa4 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_sent_to_courtroom
local eqhpa5 "`r(peq)'"
cell_eq B_highpop contested_long_pop questioned_in_voir_dire
local eqhpa6 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_questioned_in_voir_dire
local eqhpa7 "`r(peq)'"
cell_eq B_highpop contested_long_pop utilization_rate
local eqhpa8 "`r(peq)'"

* --- Panel D: Below-median with pop control ---
cell B_lowpop contested_long_pop actually_reported %9.1f treat_pros_contested_long
local lpa1 "`r(coef)'"
local lpas1 "`r(se)'"
cell B_lowpop contested_long_pop told_to_report %9.1f treat_pros_contested_long
local lpa2 "`r(coef)'"
local lpas2 "`r(se)'"
cell B_lowpop contested_long_pop pct_told_to_report %9.3f treat_pros_contested_long
local lpa3 "`r(coef)'"
local lpas3 "`r(se)'"
cell B_lowpop contested_long_pop sent_to_courtroom %9.1f treat_pros_contested_long
local lpa4 "`r(coef)'"
local lpas4 "`r(se)'"
cell B_lowpop contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_contested_long
local lpa5 "`r(coef)'"
local lpas5 "`r(se)'"
cell B_lowpop contested_long_pop questioned_in_voir_dire %9.1f treat_pros_contested_long
local lpa6 "`r(coef)'"
local lpas6 "`r(se)'"
cell B_lowpop contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_contested_long
local lpa7 "`r(coef)'"
local lpas7 "`r(se)'"
cell B_lowpop contested_long_pop utilization_rate %9.3f treat_pros_contested_long
local lpa8 "`r(coef)'"
local lpas8 "`r(se)'"

* Uncontested (below-median, pop control)
cell B_lowpop contested_long_pop actually_reported %9.1f treat_pros_uncontested
local lpua1 "`r(coef)'"
local lpuas1 "`r(se)'"
cell B_lowpop contested_long_pop told_to_report %9.1f treat_pros_uncontested
local lpua2 "`r(coef)'"
local lpuas2 "`r(se)'"
cell B_lowpop contested_long_pop pct_told_to_report %9.3f treat_pros_uncontested
local lpua3 "`r(coef)'"
local lpuas3 "`r(se)'"
cell B_lowpop contested_long_pop sent_to_courtroom %9.1f treat_pros_uncontested
local lpua4 "`r(coef)'"
local lpuas4 "`r(se)'"
cell B_lowpop contested_long_pop pct_sent_to_courtroom %9.3f treat_pros_uncontested
local lpua5 "`r(coef)'"
local lpuas5 "`r(se)'"
cell B_lowpop contested_long_pop questioned_in_voir_dire %9.1f treat_pros_uncontested
local lpua6 "`r(coef)'"
local lpuas6 "`r(se)'"
cell B_lowpop contested_long_pop pct_questioned_in_voir_dire %9.3f treat_pros_uncontested
local lpua7 "`r(coef)'"
local lpuas7 "`r(se)'"
cell B_lowpop contested_long_pop utilization_rate %9.3f treat_pros_uncontested
local lpua8 "`r(coef)'"
local lpuas8 "`r(se)'"

* Equality tests (A11 Panel D: B_lowpop contested_long_pop)
cell_eq B_lowpop contested_long_pop actually_reported
local eqlpa1 "`r(peq)'"
cell_eq B_lowpop contested_long_pop told_to_report
local eqlpa2 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_told_to_report
local eqlpa3 "`r(peq)'"
cell_eq B_lowpop contested_long_pop sent_to_courtroom
local eqlpa4 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_sent_to_courtroom
local eqlpa5 "`r(peq)'"
cell_eq B_lowpop contested_long_pop questioned_in_voir_dire
local eqlpa6 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_questioned_in_voir_dire
local eqlpa7 "`r(peq)'"
cell_eq B_lowpop contested_long_pop utilization_rate
local eqlpa8 "`r(peq)'"

* --- Dep var means (full B sample) ---
local m1 : di %9.1f $m_B_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_B_pct_told_to_report
local m3 = strtrim("`m3'")
local m4 : di %9.1f $m_B_sent_to_courtroom
local m4 = strtrim("`m4'")
local m5 : di %9.3f $m_B_pct_sent_to_courtroom
local m5 = strtrim("`m5'")
local m6 : di %9.1f $m_B_questioned_in_voir_dire
local m6 = strtrim("`m6'")
local m7 : di %9.3f $m_B_pct_questioned_in_voir_dire
local m7 = strtrim("`m7'")
local m8 : di %9.3f $m_B_utilization_rate
local m8 = strtrim("`m8'")

* --- Write LaTeX ---
local f "`texdir'/mi_tableA11_pipeline_pop_decomp.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Pipeline Decomposition by County Population Size}" _n
file write t "\label{tab:mi_pipeline_pop_decomp}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{8}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)}" _n
file write t " &\multicolumn{1}{c}{(8)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to}" _n
file write t " &\multicolumn{1}{c}{Sent to}" _n
file write t " &\multicolumn{1}{c}{\% Sent to}" _n
file write t " &\multicolumn{1}{c}{Voir Dire}" _n
file write t " &\multicolumn{1}{c}{\% Voir}" _n
file write t " &\multicolumn{1}{c}{Utilization} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Courtroom}" _n
file write t " &\multicolumn{1}{c}{Questioned}" _n
file write t " &\multicolumn{1}{c}{Dire}" _n
file write t " &\multicolumn{1}{c}{Rate} \\" _n
file write t "\hline" _n

* Panel A: Above-median
file write t "\multicolumn{9}{l}{\textit{Panel A: Above-median population}} \\[0.3em]" _n
file write t "Contested (general)  & `ha1' & `ha2' & `ha3' & `ha4' & `ha5' & `ha6' & `ha7' & `ha8' \\" _n
file write t "                     & `has1' & `has2' & `has3' & `has4' & `has5' & `has6' & `has7' & `has8' \\" _n
file write t "Uncontested          & `hua1' & `hua2' & `hua3' & `hua4' & `hua5' & `hua6' & `hua7' & `hua8' \\" _n
file write t "                     & `huas1' & `huas2' & `huas3' & `huas4' & `huas5' & `huas6' & `huas7' & `huas8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqha1' & `eqha2' & `eqha3' & `eqha4' & `eqha5' & `eqha6' & `eqha7' & `eqha8' \\"' _n
file write t "Observations         & `han1' & `han1' & `han3' & `han1' & `han5' & `han1' & `han7' & `han8' \\[0.5em]" _n

* Panel B: Below-median
file write t "\multicolumn{9}{l}{\textit{Panel B: Below-median population}} \\[0.3em]" _n
file write t "Contested (general)  & `la1' & `la2' & `la3' & `la4' & `la5' & `la6' & `la7' & `la8' \\" _n
file write t "                     & `las1' & `las2' & `las3' & `las4' & `las5' & `las6' & `las7' & `las8' \\" _n
file write t "Uncontested          & `lua1' & `lua2' & `lua3' & `lua4' & `lua5' & `lua6' & `lua7' & `lua8' \\" _n
file write t "                     & `luas1' & `luas2' & `luas3' & `luas4' & `luas5' & `luas6' & `luas7' & `luas8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqla1' & `eqla2' & `eqla3' & `eqla4' & `eqla5' & `eqla6' & `eqla7' & `eqla8' \\"' _n
file write t "Observations         & `lan1' & `lan1' & `lan3' & `lan1' & `lan5' & `lan1' & `lan7' & `lan8' \\[0.5em]" _n

* Panel C: With log(population) control
file write t "\multicolumn{9}{l}{\textit{Panels A--B with log(population) control:}} \\[0.3em]" _n
file write t "\multicolumn{9}{l}{\textit{\quad Above-median}} \\[0.1em]" _n
file write t "Contested (general)  & `hpa1' & `hpa2' & `hpa3' & `hpa4' & `hpa5' & `hpa6' & `hpa7' & `hpa8' \\" _n
file write t "                     & `hpas1' & `hpas2' & `hpas3' & `hpas4' & `hpas5' & `hpas6' & `hpas7' & `hpas8' \\" _n
file write t "Uncontested          & `hpua1' & `hpua2' & `hpua3' & `hpua4' & `hpua5' & `hpua6' & `hpua7' & `hpua8' \\" _n
file write t "                     & `hpuas1' & `hpuas2' & `hpuas3' & `hpuas4' & `hpuas5' & `hpuas6' & `hpuas7' & `hpuas8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqhpa1' & `eqhpa2' & `eqhpa3' & `eqhpa4' & `eqhpa5' & `eqhpa6' & `eqhpa7' & `eqhpa8' \\[0.3em]"' _n
file write t "\multicolumn{9}{l}{\textit{\quad Below-median}} \\[0.1em]" _n
file write t "Contested (general)  & `lpa1' & `lpa2' & `lpa3' & `lpa4' & `lpa5' & `lpa6' & `lpa7' & `lpa8' \\" _n
file write t "                     & `lpas1' & `lpas2' & `lpas3' & `lpas4' & `lpas5' & `lpas6' & `lpas7' & `lpas8' \\" _n
file write t "Uncontested          & `lpua1' & `lpua2' & `lpua3' & `lpua4' & `lpua5' & `lpua6' & `lpua7' & `lpua8' \\" _n
file write t "                     & `lpuas1' & `lpuas2' & `lpuas3' & `lpuas4' & `lpuas5' & `lpuas6' & `lpuas7' & `lpuas8' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqlpa1' & `eqlpa2' & `eqlpa3' & `eqlpa4' & `eqlpa5' & `eqlpa6' & `eqlpa7' & `eqlpa8' \\"' _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' & `m4' & `m5' & `m6' & `m7' & `m8' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{9}{l}{\footnotesize Sample B split at median county population. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Omitted category: no election (off-cycle years). Exclude-primary restriction.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize Bottom panel adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize \(p\)-values in square brackets test \(H_0\): \(\beta_{\text{con}}=\beta_{\text{uncon}}\) (Wald \(F\)-test).}\\"' _n
file write t `"\multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A12 — Appendix: Verdict Decomposition × Population Size
*  All 7 verdict outcomes × decomposition (contested + uncontested)
*  Panel A: Above-median, Panel B: Below-median,
*  Panel C: Above with pop control, Panel D: Below with pop control
*===================================================================
di as text _n "  Table A12: Verdict decomposition × population heterogeneity..."

* --- Panel A: Above-median (general-election T2) ---
cell B_highpop contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local ha1 "`r(coef)'"
local has1 "`r(se)'"
local han1 "`r(nobs)'"
cell B_highpop contested_long capital_felony %9.1f treat_pros_contested_long
local ha2 "`r(coef)'"
local has2 "`r(se)'"
cell B_highpop contested_long other_felony %9.1f treat_pros_contested_long
local ha3 "`r(coef)'"
local has3 "`r(se)'"
cell B_highpop contested_long other_cases %9.1f treat_pros_contested_long
local ha4 "`r(coef)'"
local has4 "`r(se)'"
cell B_highpop contested_long pct_capital_felony %9.3f treat_pros_contested_long
local ha5 "`r(coef)'"
local has5 "`r(se)'"
local han5 "`r(nobs)'"
cell B_highpop contested_long pct_other_felony %9.3f treat_pros_contested_long
local ha6 "`r(coef)'"
local has6 "`r(se)'"
cell B_highpop contested_long pct_other_cases %9.3f treat_pros_contested_long
local ha7 "`r(coef)'"
local has7 "`r(se)'"

* Uncontested (above-median, T2)
cell B_highpop contested_long total_jury_verdicts %9.1f treat_pros_uncontested
local hua1 "`r(coef)'"
local huas1 "`r(se)'"
cell B_highpop contested_long capital_felony %9.1f treat_pros_uncontested
local hua2 "`r(coef)'"
local huas2 "`r(se)'"
cell B_highpop contested_long other_felony %9.1f treat_pros_uncontested
local hua3 "`r(coef)'"
local huas3 "`r(se)'"
cell B_highpop contested_long other_cases %9.1f treat_pros_uncontested
local hua4 "`r(coef)'"
local huas4 "`r(se)'"
cell B_highpop contested_long pct_capital_felony %9.3f treat_pros_uncontested
local hua5 "`r(coef)'"
local huas5 "`r(se)'"
cell B_highpop contested_long pct_other_felony %9.3f treat_pros_uncontested
local hua6 "`r(coef)'"
local huas6 "`r(se)'"
cell B_highpop contested_long pct_other_cases %9.3f treat_pros_uncontested
local hua7 "`r(coef)'"
local huas7 "`r(se)'"

* Equality tests (A12 Panel A: B_highpop contested_long)
cell_eq B_highpop contested_long total_jury_verdicts
local eqha1 "`r(peq)'"
cell_eq B_highpop contested_long capital_felony
local eqha2 "`r(peq)'"
cell_eq B_highpop contested_long other_felony
local eqha3 "`r(peq)'"
cell_eq B_highpop contested_long other_cases
local eqha4 "`r(peq)'"
cell_eq B_highpop contested_long pct_capital_felony
local eqha5 "`r(peq)'"
cell_eq B_highpop contested_long pct_other_felony
local eqha6 "`r(peq)'"
cell_eq B_highpop contested_long pct_other_cases
local eqha7 "`r(peq)'"

* --- Panel B: Below-median (general-election T2) ---
cell B_lowpop contested_long total_jury_verdicts %9.1f treat_pros_contested_long
local la1 "`r(coef)'"
local las1 "`r(se)'"
local lan1 "`r(nobs)'"
cell B_lowpop contested_long capital_felony %9.1f treat_pros_contested_long
local la2 "`r(coef)'"
local las2 "`r(se)'"
cell B_lowpop contested_long other_felony %9.1f treat_pros_contested_long
local la3 "`r(coef)'"
local las3 "`r(se)'"
cell B_lowpop contested_long other_cases %9.1f treat_pros_contested_long
local la4 "`r(coef)'"
local las4 "`r(se)'"
cell B_lowpop contested_long pct_capital_felony %9.3f treat_pros_contested_long
local la5 "`r(coef)'"
local las5 "`r(se)'"
local lan5 "`r(nobs)'"
cell B_lowpop contested_long pct_other_felony %9.3f treat_pros_contested_long
local la6 "`r(coef)'"
local las6 "`r(se)'"
cell B_lowpop contested_long pct_other_cases %9.3f treat_pros_contested_long
local la7 "`r(coef)'"
local las7 "`r(se)'"

* Uncontested (below-median, T2)
cell B_lowpop contested_long total_jury_verdicts %9.1f treat_pros_uncontested
local lua1 "`r(coef)'"
local luas1 "`r(se)'"
cell B_lowpop contested_long capital_felony %9.1f treat_pros_uncontested
local lua2 "`r(coef)'"
local luas2 "`r(se)'"
cell B_lowpop contested_long other_felony %9.1f treat_pros_uncontested
local lua3 "`r(coef)'"
local luas3 "`r(se)'"
cell B_lowpop contested_long other_cases %9.1f treat_pros_uncontested
local lua4 "`r(coef)'"
local luas4 "`r(se)'"
cell B_lowpop contested_long pct_capital_felony %9.3f treat_pros_uncontested
local lua5 "`r(coef)'"
local luas5 "`r(se)'"
cell B_lowpop contested_long pct_other_felony %9.3f treat_pros_uncontested
local lua6 "`r(coef)'"
local luas6 "`r(se)'"
cell B_lowpop contested_long pct_other_cases %9.3f treat_pros_uncontested
local lua7 "`r(coef)'"
local luas7 "`r(se)'"

* Equality tests (A12 Panel B: B_lowpop contested_long)
cell_eq B_lowpop contested_long total_jury_verdicts
local eqla1 "`r(peq)'"
cell_eq B_lowpop contested_long capital_felony
local eqla2 "`r(peq)'"
cell_eq B_lowpop contested_long other_felony
local eqla3 "`r(peq)'"
cell_eq B_lowpop contested_long other_cases
local eqla4 "`r(peq)'"
cell_eq B_lowpop contested_long pct_capital_felony
local eqla5 "`r(peq)'"
cell_eq B_lowpop contested_long pct_other_felony
local eqla6 "`r(peq)'"
cell_eq B_lowpop contested_long pct_other_cases
local eqla7 "`r(peq)'"

* --- Panel C: Above-median with pop control ---
cell B_highpop contested_long_pop total_jury_verdicts %9.1f treat_pros_contested_long
local hpa1 "`r(coef)'"
local hpas1 "`r(se)'"
cell B_highpop contested_long_pop capital_felony %9.1f treat_pros_contested_long
local hpa2 "`r(coef)'"
local hpas2 "`r(se)'"
cell B_highpop contested_long_pop other_felony %9.1f treat_pros_contested_long
local hpa3 "`r(coef)'"
local hpas3 "`r(se)'"
cell B_highpop contested_long_pop other_cases %9.1f treat_pros_contested_long
local hpa4 "`r(coef)'"
local hpas4 "`r(se)'"
cell B_highpop contested_long_pop pct_capital_felony %9.3f treat_pros_contested_long
local hpa5 "`r(coef)'"
local hpas5 "`r(se)'"
cell B_highpop contested_long_pop pct_other_felony %9.3f treat_pros_contested_long
local hpa6 "`r(coef)'"
local hpas6 "`r(se)'"
cell B_highpop contested_long_pop pct_other_cases %9.3f treat_pros_contested_long
local hpa7 "`r(coef)'"
local hpas7 "`r(se)'"

* Uncontested (above-median, pop control)
cell B_highpop contested_long_pop total_jury_verdicts %9.1f treat_pros_uncontested
local hpua1 "`r(coef)'"
local hpuas1 "`r(se)'"
cell B_highpop contested_long_pop capital_felony %9.1f treat_pros_uncontested
local hpua2 "`r(coef)'"
local hpuas2 "`r(se)'"
cell B_highpop contested_long_pop other_felony %9.1f treat_pros_uncontested
local hpua3 "`r(coef)'"
local hpuas3 "`r(se)'"
cell B_highpop contested_long_pop other_cases %9.1f treat_pros_uncontested
local hpua4 "`r(coef)'"
local hpuas4 "`r(se)'"
cell B_highpop contested_long_pop pct_capital_felony %9.3f treat_pros_uncontested
local hpua5 "`r(coef)'"
local hpuas5 "`r(se)'"
cell B_highpop contested_long_pop pct_other_felony %9.3f treat_pros_uncontested
local hpua6 "`r(coef)'"
local hpuas6 "`r(se)'"
cell B_highpop contested_long_pop pct_other_cases %9.3f treat_pros_uncontested
local hpua7 "`r(coef)'"
local hpuas7 "`r(se)'"

* Equality tests (A12 Panel C: B_highpop contested_long_pop)
cell_eq B_highpop contested_long_pop total_jury_verdicts
local eqhpa1 "`r(peq)'"
cell_eq B_highpop contested_long_pop capital_felony
local eqhpa2 "`r(peq)'"
cell_eq B_highpop contested_long_pop other_felony
local eqhpa3 "`r(peq)'"
cell_eq B_highpop contested_long_pop other_cases
local eqhpa4 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_capital_felony
local eqhpa5 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_other_felony
local eqhpa6 "`r(peq)'"
cell_eq B_highpop contested_long_pop pct_other_cases
local eqhpa7 "`r(peq)'"

* --- Panel D: Below-median with pop control ---
cell B_lowpop contested_long_pop total_jury_verdicts %9.1f treat_pros_contested_long
local lpa1 "`r(coef)'"
local lpas1 "`r(se)'"
cell B_lowpop contested_long_pop capital_felony %9.1f treat_pros_contested_long
local lpa2 "`r(coef)'"
local lpas2 "`r(se)'"
cell B_lowpop contested_long_pop other_felony %9.1f treat_pros_contested_long
local lpa3 "`r(coef)'"
local lpas3 "`r(se)'"
cell B_lowpop contested_long_pop other_cases %9.1f treat_pros_contested_long
local lpa4 "`r(coef)'"
local lpas4 "`r(se)'"
cell B_lowpop contested_long_pop pct_capital_felony %9.3f treat_pros_contested_long
local lpa5 "`r(coef)'"
local lpas5 "`r(se)'"
cell B_lowpop contested_long_pop pct_other_felony %9.3f treat_pros_contested_long
local lpa6 "`r(coef)'"
local lpas6 "`r(se)'"
cell B_lowpop contested_long_pop pct_other_cases %9.3f treat_pros_contested_long
local lpa7 "`r(coef)'"
local lpas7 "`r(se)'"

* Uncontested (below-median, pop control)
cell B_lowpop contested_long_pop total_jury_verdicts %9.1f treat_pros_uncontested
local lpua1 "`r(coef)'"
local lpuas1 "`r(se)'"
cell B_lowpop contested_long_pop capital_felony %9.1f treat_pros_uncontested
local lpua2 "`r(coef)'"
local lpuas2 "`r(se)'"
cell B_lowpop contested_long_pop other_felony %9.1f treat_pros_uncontested
local lpua3 "`r(coef)'"
local lpuas3 "`r(se)'"
cell B_lowpop contested_long_pop other_cases %9.1f treat_pros_uncontested
local lpua4 "`r(coef)'"
local lpuas4 "`r(se)'"
cell B_lowpop contested_long_pop pct_capital_felony %9.3f treat_pros_uncontested
local lpua5 "`r(coef)'"
local lpuas5 "`r(se)'"
cell B_lowpop contested_long_pop pct_other_felony %9.3f treat_pros_uncontested
local lpua6 "`r(coef)'"
local lpuas6 "`r(se)'"
cell B_lowpop contested_long_pop pct_other_cases %9.3f treat_pros_uncontested
local lpua7 "`r(coef)'"
local lpuas7 "`r(se)'"

* Equality tests (A12 Panel D: B_lowpop contested_long_pop)
cell_eq B_lowpop contested_long_pop total_jury_verdicts
local eqlpa1 "`r(peq)'"
cell_eq B_lowpop contested_long_pop capital_felony
local eqlpa2 "`r(peq)'"
cell_eq B_lowpop contested_long_pop other_felony
local eqlpa3 "`r(peq)'"
cell_eq B_lowpop contested_long_pop other_cases
local eqlpa4 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_capital_felony
local eqlpa5 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_other_felony
local eqlpa6 "`r(peq)'"
cell_eq B_lowpop contested_long_pop pct_other_cases
local eqlpa7 "`r(peq)'"

* --- Dep var means ---
local m1 : di %9.1f $m_B_total_jury_verdicts
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_B_capital_felony
local m2 = strtrim("`m2'")
local m3 : di %9.1f $m_B_other_felony
local m3 = strtrim("`m3'")
local m4 : di %9.1f $m_B_other_cases
local m4 = strtrim("`m4'")
local m5 : di %9.3f $m_B_pct_capital_felony
local m5 = strtrim("`m5'")
local m6 : di %9.3f $m_B_pct_other_felony
local m6 = strtrim("`m6'")
local m7 : di %9.3f $m_B_pct_other_cases
local m7 = strtrim("`m7'")

* --- Write LaTeX ---
local f "`texdir'/mi_tableA12_verdict_pop_decomp.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Verdict Decomposition by County Population Size}" _n
file write t "\label{tab:mi_verdict_pop_decomp}" _n
file write t "\footnotesize" _n
file write t "\begin{tabular}{l*{7}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{4}{c}{Verdict Counts}" _n
file write t " &\multicolumn{3}{c}{Verdict Composition} \\" _n
file write t "\cmidrule(lr){2-5}\cmidrule(lr){6-8}" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)}" _n
file write t " &\multicolumn{1}{c}{(4)}" _n
file write t " &\multicolumn{1}{c}{(5)}" _n
file write t " &\multicolumn{1}{c}{(6)}" _n
file write t " &\multicolumn{1}{c}{(7)} \\" _n
file write t " &\multicolumn{1}{c}{Total}" _n
file write t " &\multicolumn{1}{c}{Capital}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{Other}" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Cases} \\" _n
file write t "\hline" _n

* Panel A: Above-median
file write t "\multicolumn{8}{l}{\textit{Panel A: Above-median population}} \\[0.3em]" _n
file write t "Contested (general)  & `ha1' & `ha2' & `ha3' & `ha4' & `ha5' & `ha6' & `ha7' \\" _n
file write t "                     & `has1' & `has2' & `has3' & `has4' & `has5' & `has6' & `has7' \\" _n
file write t "Uncontested          & `hua1' & `hua2' & `hua3' & `hua4' & `hua5' & `hua6' & `hua7' \\" _n
file write t "                     & `huas1' & `huas2' & `huas3' & `huas4' & `huas5' & `huas6' & `huas7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqha1' & `eqha2' & `eqha3' & `eqha4' & `eqha5' & `eqha6' & `eqha7' \\"' _n
file write t "Observations         & `han1' & `han1' & `han1' & `han1' & `han5' & `han5' & `han5' \\[0.5em]" _n

* Panel B: Below-median
file write t "\multicolumn{8}{l}{\textit{Panel B: Below-median population}} \\[0.3em]" _n
file write t "Contested (general)  & `la1' & `la2' & `la3' & `la4' & `la5' & `la6' & `la7' \\" _n
file write t "                     & `las1' & `las2' & `las3' & `las4' & `las5' & `las6' & `las7' \\" _n
file write t "Uncontested          & `lua1' & `lua2' & `lua3' & `lua4' & `lua5' & `lua6' & `lua7' \\" _n
file write t "                     & `luas1' & `luas2' & `luas3' & `luas4' & `luas5' & `luas6' & `luas7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqla1' & `eqla2' & `eqla3' & `eqla4' & `eqla5' & `eqla6' & `eqla7' \\"' _n
file write t "Observations         & `lan1' & `lan1' & `lan1' & `lan1' & `lan5' & `lan5' & `lan5' \\[0.5em]" _n

* Panel C: With log(population) control
file write t "\multicolumn{8}{l}{\textit{Panels A--B with log(population) control:}} \\[0.3em]" _n
file write t "\multicolumn{8}{l}{\textit{\quad Above-median}} \\[0.1em]" _n
file write t "Contested (general)  & `hpa1' & `hpa2' & `hpa3' & `hpa4' & `hpa5' & `hpa6' & `hpa7' \\" _n
file write t "                     & `hpas1' & `hpas2' & `hpas3' & `hpas4' & `hpas5' & `hpas6' & `hpas7' \\" _n
file write t "Uncontested          & `hpua1' & `hpua2' & `hpua3' & `hpua4' & `hpua5' & `hpua6' & `hpua7' \\" _n
file write t "                     & `hpuas1' & `hpuas2' & `hpuas3' & `hpuas4' & `hpuas5' & `hpuas6' & `hpuas7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqhpa1' & `eqhpa2' & `eqhpa3' & `eqhpa4' & `eqhpa5' & `eqhpa6' & `eqhpa7' \\[0.3em]"' _n
file write t "\multicolumn{8}{l}{\textit{\quad Below-median}} \\[0.1em]" _n
file write t "Contested (general)  & `lpa1' & `lpa2' & `lpa3' & `lpa4' & `lpa5' & `lpa6' & `lpa7' \\" _n
file write t "                     & `lpas1' & `lpas2' & `lpas3' & `lpas4' & `lpas5' & `lpas6' & `lpas7' \\" _n
file write t "Uncontested          & `lpua1' & `lpua2' & `lpua3' & `lpua4' & `lpua5' & `lpua6' & `lpua7' \\" _n
file write t "                     & `lpuas1' & `lpuas2' & `lpuas3' & `lpuas4' & `lpuas5' & `lpuas6' & `lpuas7' \\" _n
file write t `"\emph{\(p\): \(\beta_{c}=\beta_{u}\)} & `eqlpa1' & `eqlpa2' & `eqlpa3' & `eqlpa4' & `eqlpa5' & `eqlpa6' & `eqlpa7' \\"' _n

file write t "\hline" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' & `m4' & `m5' & `m6' & `m7' \\" _n
file write t "\hline\hline" _n
file write t `"\multicolumn{8}{l}{\footnotesize Sample B split at median county population. See Table \ref{tab:mi_samples}.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Omitted category: no election (off-cycle years). Exclude-primary restriction.}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize Bottom panel adds log(county population) as control. Composition shares condition on total verdicts \(> 0\).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize \(p\)-values in square brackets test \(H_0\): \(\beta_{\text{con}}=\beta_{\text{uncon}}\) (Wald \(F\)-test).}\\"' _n
file write t `"\multicolumn{8}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A13 — County-Aggregate Pipeline (Category B robustness)
*  Variant D (all-courts aggregate) | T1 | treat_pros_pressure
*  Columns: (1) actually_reported (2) told_to_report (3) pct_told_to_report
*===================================================================
di as text _n "  Building Table A13: County-Aggregate Pipeline..."

cell D pressure actually_reported  %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell D pressure told_to_report     %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell D pressure pct_told_to_report %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

* Controlled spec (+ log population)
cell D pressure_pop actually_reported  %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell D pressure_pop told_to_report     %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell D pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"

* Open-seat (T1 decomposition)
cell D pressure actually_reported  %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell D pressure told_to_report     %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell D pressure pct_told_to_report %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_D_actually_reported
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_D_actually_reported
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_D_told_to_report
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_D_told_to_report
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_D_pct_told_to_report
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_D_pct_told_to_report
local bs3 = strtrim("`bs3'")

local m1 : di %9.1f $m_D_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_D_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_D_pct_told_to_report
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA13_pipeline_county.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: County-Level Aggregation --- All Courts}" _n
file write t "\label{tab:mi_county_agg_pipeline}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report} \\" _n
file write t "\hline" _n
file write t "\multicolumn{4}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' \\" _n
file write t "         & `s1' & `s2' & `s3' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' \\" _n
file write t "         & `os1' & `os2' & `os3' \\[0.5em]" _n
file write t "\multicolumn{4}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample D: all courts collapsed to county-year (simple sum).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election. Compare to Table 1 (Sample B).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A14 — County-Aggregate Verdicts (Category B robustness)
*  Variant D | T1 | treat_pros_pressure
*  Columns: (1) total_jury_verdicts (2) pct_capital_felony (3) pct_other_felony
*===================================================================
di as text _n "  Building Table A14: County-Aggregate Verdicts..."

cell D pressure total_jury_verdicts %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell D pressure pct_capital_felony %9.3f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell D pressure pct_other_felony   %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

* Controlled spec
cell D pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell D pressure_pop pct_capital_felony %9.3f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell D pressure_pop pct_other_felony   %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"

* Open-seat (T1 decomposition)
cell D pressure total_jury_verdicts %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell D pressure pct_capital_felony %9.3f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell D pressure pct_other_felony   %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_D_total_jury_verdicts
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_D_total_jury_verdicts
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_D_pct_capital_felony
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_D_pct_capital_felony
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_D_pct_other_felony
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_D_pct_other_felony
local bs3 = strtrim("`bs3'")

local m1 : di %9.1f $m_D_total_jury_verdicts
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_D_pct_capital_felony
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_D_pct_other_felony
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA14_verdict_county.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: County-Level Aggregation --- Verdict Outcomes}" _n
file write t "\label{tab:mi_county_agg_verdicts}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Jury}" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n
file write t "\multicolumn{4}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' \\" _n
file write t "         & `s1' & `s2' & `s3' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' \\" _n
file write t "         & `os1' & `os2' & `os3' \\[0.5em]" _n
file write t "\multicolumn{4}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample D: all courts collapsed to county-year (simple sum).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A15 — Circuit-Court Pipeline (Category C robustness)
*  Variant E (circuit-court-only) | T1 | treat_pros_pressure
*  Columns: (1) actually_reported (2) told_to_report (3) pct_told_to_report
*===================================================================
di as text _n "  Building Table A15: Circuit-Court Pipeline..."

cell E pressure actually_reported  %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell E pressure told_to_report     %9.1f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell E pressure pct_told_to_report %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

* Controlled spec
cell E pressure_pop actually_reported  %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell E pressure_pop told_to_report     %9.1f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell E pressure_pop pct_told_to_report %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"

* Open-seat (T1 decomposition)
cell E pressure actually_reported  %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell E pressure told_to_report     %9.1f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell E pressure pct_told_to_report %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_E_actually_reported
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_E_actually_reported
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_E_told_to_report
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_E_told_to_report
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_E_pct_told_to_report
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_E_pct_told_to_report
local bs3 = strtrim("`bs3'")

local m1 : di %9.1f $m_E_actually_reported
local m1 = strtrim("`m1'")
local m2 : di %9.1f $m_E_told_to_report
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_E_pct_told_to_report
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA15_pipeline_circuit.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: Circuit-Court-Only Aggregation --- Pipeline}" _n
file write t "\label{tab:mi_circuit_pipeline}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Actually}" _n
file write t " &\multicolumn{1}{c}{Told to}" _n
file write t " &\multicolumn{1}{c}{\% Told to} \\" _n
file write t " &\multicolumn{1}{c}{Reported}" _n
file write t " &\multicolumn{1}{c}{Report}" _n
file write t " &\multicolumn{1}{c}{Report} \\" _n
file write t "\hline" _n
file write t "\multicolumn{4}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' \\" _n
file write t "         & `s1' & `s2' & `s3' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' \\" _n
file write t "         & `os1' & `os2' & `os3' \\[0.5em]" _n
file write t "\multicolumn{4}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample E: standalone circuit/probate courts only, collapsed to county-year.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Counties without standalone circuit courts are excluded.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election. Compare to Table 1 (Sample B).}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  TABLE A16 — Circuit-Court Verdicts (Category C robustness)
*  Variant E | T1 | treat_pros_pressure
*  Columns: (1) total_jury_verdicts (2) pct_capital_felony (3) pct_other_felony
*===================================================================
di as text _n "  Building Table A16: Circuit-Court Verdicts..."

cell E pressure total_jury_verdicts %9.1f treat_pros_pressure
local b1 "`r(coef)'"
local s1 "`r(se)'"
local n1 "`r(nobs)'"
local beta1 = r(beta_raw)

cell E pressure pct_capital_felony %9.3f treat_pros_pressure
local b2 "`r(coef)'"
local s2 "`r(se)'"
local n2 "`r(nobs)'"
local beta2 = r(beta_raw)

cell E pressure pct_other_felony   %9.3f treat_pros_pressure
local b3 "`r(coef)'"
local s3 "`r(se)'"
local n3 "`r(nobs)'"
local beta3 = r(beta_raw)

* Controlled spec
cell E pressure_pop total_jury_verdicts %9.1f treat_pros_pressure
local pb1 "`r(coef)'"
local ps1 "`r(se)'"
cell E pressure_pop pct_capital_felony %9.3f treat_pros_pressure
local pb2 "`r(coef)'"
local ps2 "`r(se)'"
cell E pressure_pop pct_other_felony   %9.3f treat_pros_pressure
local pb3 "`r(coef)'"
local ps3 "`r(se)'"

* Open-seat (T1 decomposition)
cell E pressure total_jury_verdicts %9.1f open_pros
local ob1 "`r(coef)'"
local os1 "`r(se)'"
cell E pressure pct_capital_felony %9.3f open_pros
local ob2 "`r(coef)'"
local os2 "`r(se)'"
cell E pressure pct_other_felony   %9.3f open_pros
local ob3 "`r(coef)'"
local os3 "`r(se)'"

* Format beta/mean and beta/SD_w
local bm1 : di %9.3f `beta1' / $m_E_total_jury_verdicts
local bm1 = strtrim("`bm1'")
local bs1 : di %9.2f `beta1' / $w_E_total_jury_verdicts
local bs1 = strtrim("`bs1'")
local bm2 : di %9.3f `beta2' / $m_E_pct_capital_felony
local bm2 = strtrim("`bm2'")
local bs2 : di %9.2f `beta2' / $w_E_pct_capital_felony
local bs2 = strtrim("`bs2'")
local bm3 : di %9.3f `beta3' / $m_E_pct_other_felony
local bm3 = strtrim("`bm3'")
local bs3 : di %9.2f `beta3' / $w_E_pct_other_felony
local bs3 = strtrim("`bs3'")

local m1 : di %9.1f $m_E_total_jury_verdicts
local m1 = strtrim("`m1'")
local m2 : di %9.3f $m_E_pct_capital_felony
local m2 = strtrim("`m2'")
local m3 : di %9.3f $m_E_pct_other_felony
local m3 = strtrim("`m3'")

local f "`texdir'/mi_tableA16_verdict_circuit.tex"
file open t using "`f'", write replace

file write t "\begin{table}[htbp]\centering" _n
file write t "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write t "\caption{Robustness: Circuit-Court-Only Aggregation --- Verdict Outcomes}" _n
file write t "\label{tab:mi_circuit_verdicts}" _n
file write t "\begin{tabular}{l*{3}{c}}" _n
file write t "\hline\hline" _n
file write t " &\multicolumn{1}{c}{(1)}" _n
file write t " &\multicolumn{1}{c}{(2)}" _n
file write t " &\multicolumn{1}{c}{(3)} \\" _n
file write t " &\multicolumn{1}{c}{Jury}" _n
file write t " &\multicolumn{1}{c}{\% Capital}" _n
file write t " &\multicolumn{1}{c}{\% Other} \\" _n
file write t " &\multicolumn{1}{c}{Verdicts}" _n
file write t " &\multicolumn{1}{c}{Felony}" _n
file write t " &\multicolumn{1}{c}{Felony} \\" _n
file write t "\hline" _n
file write t "\multicolumn{4}{l}{\textit{Panel A: Base specification}} \\[0.3em]" _n
file write t "Pressure & `b1' & `b2' & `b3' \\" _n
file write t "         & `s1' & `s2' & `s3' \\" _n
file write t "Open-seat election & `ob1' & `ob2' & `ob3' \\" _n
file write t "         & `os1' & `os2' & `os3' \\[0.5em]" _n
file write t "\multicolumn{4}{l}{\textit{Panel B: With log(population) control}} \\[0.3em]" _n
file write t "Pressure & `pb1' & `pb2' & `pb3' \\" _n
file write t "         & `ps1' & `ps2' & `ps3' \\" _n
file write t "\hline" _n
file write t "Observations     & `n1' & `n2' & `n3' \\" _n
file write t "Dep.\ var.\ mean & `m1' & `m2' & `m3' \\" _n
file write t `"$\hat{\beta}/\bar{Y}$ & `bm1' & `bm2' & `bm3' \\"' _n
file write t `"$\hat{\beta}/\sigma_w$ & `bs1' & `bs2' & `bs3' \\"' _n
file write t "\hline\hline" _n
file write t `"\multicolumn{4}{l}{\footnotesize Sample E: standalone circuit/probate courts only, collapsed to county-year.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Counties without standalone circuit courts are excluded.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize County and year fixed effects. Standard errors clustered at the county level.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Treatment: \textit{pressure} = 1 if incumbent faces election.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize Panel B adds log(county population) as control.}\\"' _n
file write t `"\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\"' _n
file write t "\end{tabular}" _n
file write t "\end{table}" _n

file close t
di as text "    Done: `f'"


*===================================================================
*  Wrap up
*===================================================================
di as text _n "========================================================"
di as text   "  All 23 tables written to:"
di as text   "  `texdir'"
di as text   "  Reference: mi_table0_samples.tex"
di as text   "  Data:      mi_table_sumstats.tex"
di as text   "  Main:      mi_table1_pipeline.tex"
di as text   "             mi_table2_competition.tex"
di as text   "             mi_table3_verdicts.tex"
di as text   "             mi_table4_cycle_robust.tex"
di as text   "             mi_table5_cycle_verdicts.tex"
di as text   "             mi_table15_verdicts_all.tex"
di as text   "  Appendix:  mi_tableA1_robustness.tex"
di as text   "             mi_tableA2_nulls.tex"
di as text   "             mi_tableA3_mechanism.tex"
di as text   "             mi_tableA4_scaling.tex"
di as text   "             mi_tableA6_popsplit.tex"
di as text   "             mi_tableA7_config.tex"
di as text   "             mi_tableA8_comp_heterogeneity.tex"
di as text   "             mi_tableA9_pipeline_decomp.tex"
di as text   "             mi_tableA10_verdict_decomp.tex"
di as text   "             mi_tableA11_pipeline_pop_decomp.tex"
di as text   "             mi_tableA12_verdict_pop_decomp.tex"
di as text   "             mi_tableA13_pipeline_county.tex"
di as text   "             mi_tableA14_verdict_county.tex"
di as text   "             mi_tableA15_pipeline_circuit.tex"
di as text   "             mi_tableA16_verdict_circuit.tex"
di as text   "  (A5 removed — no_offcycle exclusion now in Table 4 Panel D)"
di as text   "========================================================"
