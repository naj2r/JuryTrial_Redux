/*==================================================================
  10_capacity_robustness_tables.do

  Purpose:  Generate three appendix robustness tables addressing
            large-county concentration and capacity heterogeneity.

            Table A.9: Joint county exclusion robustness (T2)
            Table A.10: Capacity-mediated heterogeneity (T2 × ln(pop))
            Table A.11: Contested-county composition across election cycles

  Input:    $DATA_FINAL/michigan_panel_B.dta

  Output:   $OL/files/tab/mi_conference/mi_tableA9_joint_exclusion.tex
            $OL/files/tab/mi_conference/mi_tableA10_capacity_interaction.tex
            $OL/files/tab/mi_conference/mi_tableA11_cycle_composition.tex

  Prereq:   Run 03 → 07 pipeline first (data must exist).

  Notes:
  - These tables are not in the main regression CSV — regressions run live
  - Format matches existing A-series tables (sym, hline, etc.)
  - Idempotent: re-running overwrites output with identical content
==================================================================*/

* ─── Bootstrap: standalone execution ─────────────────────────────
set update_query off
set more off

if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear

local texdir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26/files/tab/mi_conference"
capture mkdir "`texdir'"

di as text _n "========================================================"
di as text   "  10_capacity_robustness_tables.do"
di as text   "  Building 3 appendix robustness tables"
di as text   "========================================================"


*===================================================================
*  Load data
*===================================================================

use "$DATA_FINAL/michigan_panel_B.dta", clear

* Generate T2 exclusion flag (derived from treatment vars, not stored in data)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* CRITICAL: Exclude open-seat elections from T2 sample (2026-03-20 fix)
* Open seats have pressure=0, contested=0, uncontested=0 — they contaminate
* the baseline if left in. Same fix applied to 07_regressions.do and all 07* files.
qui drop if open_pros == 1

* Create interaction variables needed across tables
gen lnpop = ln(county_pop)
gen T2_x_lnpop = treat_pros_contested_long * lnpop

* Compute population percentiles from T2 sample (excl primary-only)
qui su county_pop if treat_pros_primary_only != 1, detail
local p25_pop = r(p25)
local p50_pop = r(p50)
local p75_pop = r(p75)
local p25_lnpop = ln(`p25_pop')
local p50_lnpop = ln(`p50_pop')
local p75_lnpop = ln(`p75_pop')

di as text "Population percentiles (T2 sample):"
di as text "  25th: " %12.0fc `p25_pop' " (ln=" %5.2f `p25_lnpop' ")"
di as text "  50th: " %12.0fc `p50_pop' " (ln=" %5.2f `p50_lnpop' ")"
di as text "  75th: " %12.0fc `p75_pop' " (ln=" %5.2f `p75_lnpop' ")"


*===================================================================
*  HELPER PROGRAM: format significance stars
*===================================================================

capture program drop star_fmt
program define star_fmt, rclass
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


*===================================================================
*  TABLE A.9: Joint County Exclusion Robustness
*
*  Two panels: Baseline T2 vs. Excluding Wayne + Macomb
*  Three outcomes: actually_reported, pct_told_to_report, total_jury_verdicts
*===================================================================

di as text _n "  Building Table A.9: Joint County Exclusion..."

local f "`texdir'/mi_tableA9_joint_exclusion.tex"
tempname fh
file open `fh' using "`f'", write replace

* --- Header ---
file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `fh' "\caption{Robustness to Large-County Exclusion (Contested Elections)}" _n
file write `fh' "\label{tab:mi_joint_excl}" _n
file write `fh' "\begin{tabular}{l*{3}{c}}" _n
file write `fh' "\hline\hline" _n
file write `fh' " &\multicolumn{1}{c}{(1)}" _n
file write `fh' " &\multicolumn{1}{c}{(2)}" _n
file write `fh' " &\multicolumn{1}{c}{(3)} \\" _n
file write `fh' " &\multicolumn{1}{c}{Actually}" _n
file write `fh' " &\multicolumn{1}{c}{\% Told to}" _n
file write `fh' " &\multicolumn{1}{c}{Total} \\" _n
file write `fh' " &\multicolumn{1}{c}{Reported}" _n
file write `fh' " &\multicolumn{1}{c}{Report}" _n
file write `fh' " &\multicolumn{1}{c}{Verdicts} \\" _n
file write `fh' "\hline" _n

* --- Panel A: Baseline T2 ---
file write `fh' "\multicolumn{4}{l}{\textit{Panel A: Baseline (all counties)}} \\[0.3em]" _n

local outcomes "actually_reported pct_told_to_report total_jury_verdicts"
local coefs_a ""
local ses_a ""
local obs_a ""
local means_a ""

foreach depvar of local outcomes {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)

    local b = _b[treat_pros_contested_long]
    local se = _se[treat_pros_contested_long]
    local p = 2*ttail(e(df_r), abs(`b'/`se'))
    local n = e(N)

    star_fmt `p'
    local st "`r(stars)'"

    * Store for dep var mean
    qui su `depvar' if treat_pros_primary_only != 1 & e(sample)
    local m = r(mean)

    * Format based on variable type
    if "`depvar'" == "pct_told_to_report" {
        local coefs_a `"`coefs_a' & `=string(`b', "%5.3f")'`st'"'
        local ses_a `"`ses_a' & (`=string(`se', "%5.3f")')"'
        local means_a `"`means_a' & `=string(`m', "%5.3f")'"'
    }
    else if "`depvar'" == "total_jury_verdicts" {
        local coefs_a `"`coefs_a' & `=string(`b', "%4.1f")'`st'"'
        local ses_a `"`ses_a' & (`=string(`se', "%4.1f")')"'
        local means_a `"`means_a' & `=string(`m', "%4.1f")'"'
    }
    else {
        local coefs_a `"`coefs_a' & `=string(`b', "%6.1f")'`st'"'
        local ses_a `"`ses_a' & (`=string(`se', "%6.1f")')"'
        local means_a `"`means_a' & `=string(`m', "%6.1f")'"'
    }
    local obs_a `"`obs_a' & `n'"'
}

file write `fh' "Contested `coefs_a' \\" _n
file write `fh' "         `ses_a' \\" _n
file write `fh' "Observations `obs_a' \\[0.5em]" _n

* --- Panel B: Exclude Wayne + Macomb ---
file write `fh' "\multicolumn{4}{l}{\textit{Panel B: Excluding Wayne and Macomb}} \\[0.3em]" _n

local coefs_b ""
local ses_b ""
local obs_b ""
local means_b ""

foreach depvar of local outcomes {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & county != "Wayne" & county != "Macomb", ///
        absorb(county_id year) vce(cluster county_id)

    local b = _b[treat_pros_contested_long]
    local se = _se[treat_pros_contested_long]
    local p = 2*ttail(e(df_r), abs(`b'/`se'))
    local n = e(N)

    star_fmt `p'
    local st "`r(stars)'"

    if "`depvar'" == "pct_told_to_report" {
        local coefs_b `"`coefs_b' & `=string(`b', "%5.3f")'`st'"'
        local ses_b `"`ses_b' & (`=string(`se', "%5.3f")')"'
    }
    else if "`depvar'" == "total_jury_verdicts" {
        local coefs_b `"`coefs_b' & `=string(`b', "%4.1f")'`st'"'
        local ses_b `"`ses_b' & (`=string(`se', "%4.1f")')"'
    }
    else {
        local coefs_b `"`coefs_b' & `=string(`b', "%6.1f")'`st'"'
        local ses_b `"`ses_b' & (`=string(`se', "%6.1f")')"'
    }
    local obs_b `"`obs_b' & `n'"'
}

file write `fh' "Contested `coefs_b' \\" _n
file write `fh' "         `ses_b' \\" _n
file write `fh' "Observations `obs_b' \\" _n

* --- Footer ---
file write `fh' "\hline" _n
file write `fh' "Dep.\ var.\ mean `means_a' \\" _n
file write `fh' "\hline\hline" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Sample B, exclude-primary restriction. County and year fixed effects.}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Standard errors clustered at the county level.}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Treatment: \textit{contested} = general-election contestation (see Table \ref{tab:mi_competition}).}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Panel B drops Wayne County (pop.\ 1.79M) and Macomb County (pop.\ 874K).}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" _n
file write `fh' "\end{tabular}" _n
file write `fh' "\end{table}" _n

file close `fh'
di as text "  → `f'"


*===================================================================
*  TABLE A.10: Capacity-Mediated Heterogeneity
*
*  Regression: Y = β₁T + β₂T×ln(pop) + β₃Uncontested + county_FE + year_FE
*  Plus marginal effects at 25th, 50th, 75th percentile population
*===================================================================

di as text _n "  Building Table A.10: Capacity Interaction..."

local f "`texdir'/mi_tableA10_capacity_interaction.tex"
tempname fh
file open `fh' using "`f'", write replace

* --- Header ---
file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `fh' "\caption{Electoral Contestation and Administrative Capacity}" _n
file write `fh' "\label{tab:mi_capacity}" _n
file write `fh' "\begin{tabular}{l*{3}{c}}" _n
file write `fh' "\hline\hline" _n
file write `fh' " &\multicolumn{1}{c}{(1)}" _n
file write `fh' " &\multicolumn{1}{c}{(2)}" _n
file write `fh' " &\multicolumn{1}{c}{(3)} \\" _n
file write `fh' " &\multicolumn{1}{c}{Actually}" _n
file write `fh' " &\multicolumn{1}{c}{Told to}" _n
file write `fh' " &\multicolumn{1}{c}{\% Told to} \\" _n
file write `fh' " &\multicolumn{1}{c}{Reported}" _n
file write `fh' " &\multicolumn{1}{c}{Report}" _n
file write `fh' " &\multicolumn{1}{c}{Report} \\" _n
file write `fh' "\hline" _n
file write `fh' "\multicolumn{4}{l}{\textit{Panel A: Interaction specification}} \\[0.3em]" _n

* --- Run regressions and store results ---
local outcomes "actually_reported told_to_report pct_told_to_report"

* Storage for coefficients
local coefs_t2 ""
local ses_t2 ""
local coefs_int ""
local ses_int ""
local coefs_unc ""
local ses_unc ""
local obs_line ""
local means_line ""

* Storage for marginal effect computation
local b_t2_1 = .
local b_int_1 = .
local b_t2_2 = .
local b_int_2 = .
local b_t2_3 = .
local b_int_3 = .

local i = 0
foreach depvar of local outcomes {
    local i = `i' + 1

    qui reghdfe `depvar' treat_pros_contested_long T2_x_lnpop treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)

    * Contested coefficient
    local b1 = _b[treat_pros_contested_long]
    local se1 = _se[treat_pros_contested_long]
    local p1 = 2*ttail(e(df_r), abs(`b1'/`se1'))

    * Interaction coefficient
    local b2 = _b[T2_x_lnpop]
    local se2 = _se[T2_x_lnpop]
    local p2 = 2*ttail(e(df_r), abs(`b2'/`se2'))

    * Uncontested coefficient
    local b3 = _b[treat_pros_uncontested]
    local se3 = _se[treat_pros_uncontested]
    local p3 = 2*ttail(e(df_r), abs(`b3'/`se3'))

    local n = e(N)

    * Store betas for marginal effects
    local b_t2_`i' = `b1'
    local b_int_`i' = `b2'

    star_fmt `p1'
    local st1 "`r(stars)'"
    star_fmt `p2'
    local st2 "`r(stars)'"
    star_fmt `p3'
    local st3 "`r(stars)'"

    * Dep var mean
    qui su `depvar' if treat_pros_primary_only != 1 & e(sample)
    local m = r(mean)

    if "`depvar'" == "pct_told_to_report" {
        local coefs_t2 `"`coefs_t2' & `=string(`b1', "%7.3f")'`st1'"'
        local ses_t2 `"`ses_t2' & (`=string(`se1', "%7.3f")')"'
        local coefs_int `"`coefs_int' & `=string(`b2', "%7.3f")'`st2'"'
        local ses_int `"`ses_int' & (`=string(`se2', "%7.3f")')"'
        local coefs_unc `"`coefs_unc' & `=string(`b3', "%7.3f")'`st3'"'
        local ses_unc `"`ses_unc' & (`=string(`se3', "%7.3f")')"'
        local means_line `"`means_line' & `=string(`m', "%5.3f")'"'
    }
    else {
        local coefs_t2 `"`coefs_t2' & `=string(`b1', "%7.1f")'`st1'"'
        local ses_t2 `"`ses_t2' & (`=string(`se1', "%7.1f")')"'
        local coefs_int `"`coefs_int' & `=string(`b2', "%7.1f")'`st2'"'
        local ses_int `"`ses_int' & (`=string(`se2', "%7.1f")')"'
        local coefs_unc `"`coefs_unc' & `=string(`b3', "%7.1f")'`st3'"'
        local ses_unc `"`ses_unc' & (`=string(`se3', "%7.1f")')"'
        local means_line `"`means_line' & `=string(`m', "%6.1f")'"'
    }
    local obs_line `"`obs_line' & `n'"'
}

* Write Panel A
file write `fh' "Contested `coefs_t2' \\" _n
file write `fh' "         `ses_t2' \\" _n
file write `fh' "Contested $\times$ ln(pop) `coefs_int' \\" _n
file write `fh' "         `ses_int' \\" _n
file write `fh' "Uncontested `coefs_unc' \\" _n
file write `fh' "         `ses_unc' \\" _n
file write `fh' "Observations `obs_line' \\[0.5em]" _n

* --- Panel B: Marginal effects at population percentiles ---
file write `fh' "\multicolumn{4}{l}{\textit{Panel B: Implied marginal effects}} \\[0.3em]" _n

* Compute marginal effects for each outcome at each percentile
foreach pct in 25 50 75 {
    local lp = `p`pct'_lnpop'
    local popval = `p`pct'_pop'

    local me_line ""
    forvalues i = 1/3 {
        local me = `b_t2_`i'' + `b_int_`i'' * `lp'

        if `i' == 3 {
            local me_line `"`me_line' & `=string(`me', "%7.3f")'"'
        }
        else {
            local me_line `"`me_line' & `=string(`me', "%7.1f")'"'
        }
    }

    local popfmt = string(`popval', "%9.0fc")
    file write `fh' "At `pct'th pctile (pop $\approx$ `popfmt') `me_line' \\" _n
}

* --- Footer ---
file write `fh' "\hline" _n
file write `fh' "Dep.\ var.\ mean `means_line' \\" _n
file write `fh' "\hline\hline" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Sample B, exclude-primary restriction. County and year fixed effects.}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Standard errors clustered at the county level.}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Panel A: \textit{contested} interacted with log(county population).}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize Panel B: $\hat{\beta}_1 + \hat{\beta}_2 \times \ln(\text{pop})$ at sample percentiles.}\\" _n
file write `fh' "\multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\" _n
file write `fh' "\end{tabular}" _n
file write `fh' "\end{table}" _n

file close `fh'
di as text "  → `f'"


*===================================================================
*  TABLE A.11: Contested-County Composition Across Election Cycles
*
*  Descriptive table: 2016 vs 2024 T2 contested counties
*  Columns: N contested, mean pop, total pop, volume from top 3
*===================================================================

di as text _n "  Building Table A.11: Cycle Composition..."

local f "`texdir'/mi_tableA11_cycle_composition.tex"
tempname fh
file open `fh' using "`f'", write replace

* --- Compute descriptive stats for each cycle ---
foreach yr in 2016 2024 {
    preserve
        keep if year == `yr' & treat_pros_contested_long == 1
        local n_`yr' = _N

        qui su county_pop
        local meanpop_`yr' = r(mean)
        local totpop_`yr' = r(sum)

        qui su actually_reported
        local totar_`yr' = r(sum)

        * Top 3 volume share
        gsort -actually_reported
        local top3_`yr' = 0
        forvalues i = 1/3 {
            if `i' <= _N {
                local top3_`yr' = `top3_`yr'' + actually_reported[`i']
            }
        }
        local pct3_`yr' = `top3_`yr'' / `totar_`yr'' * 100
    restore
}

* --- Also compute overlap stats ---
preserve
    keep if treat_pros_contested_long == 1 & inlist(year, 2016, 2024)
    bys county_id: gen n_cyears = _N
    qui count if n_cyears == 2 & year == 2016
    local n_both = r(N)
restore

* --- Write table ---
file write `fh' "\begin{table}[htbp]\centering" _n
file write `fh' "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n
file write `fh' "\caption{Contested-County Composition Across Election Cycles}" _n
file write `fh' "\label{tab:mi_cycle_comp}" _n
file write `fh' "\begin{tabular}{l*{5}{c}}" _n
file write `fh' "\hline\hline" _n
file write `fh' " &\multicolumn{1}{c}{Counties}" _n
file write `fh' " &\multicolumn{1}{c}{Mean}" _n
file write `fh' " &\multicolumn{1}{c}{Total}" _n
file write `fh' " &\multicolumn{1}{c}{Juror Volume}" _n
file write `fh' " &\multicolumn{1}{c}{Counties in} \\" _n
file write `fh' " &\multicolumn{1}{c}{Contested}" _n
file write `fh' " &\multicolumn{1}{c}{Population}" _n
file write `fh' " &\multicolumn{1}{c}{Population}" _n
file write `fh' " &\multicolumn{1}{c}{Top 3 (\%)}" _n
file write `fh' " &\multicolumn{1}{c}{Both Cycles} \\" _n
file write `fh' "\hline" _n

* 2016 row
local mp16 = string(`meanpop_2016', "%9.0fc")
local tp16 = string(`totpop_2016', "%12.0fc")
local p316 = string(`pct3_2016', "%4.1f")
file write `fh' "2016 & `n_2016' & `mp16' & `tp16' & `p316' & `n_both' \\" _n

* 2024 row
local mp24 = string(`meanpop_2024', "%9.0fc")
local tp24 = string(`totpop_2024', "%12.0fc")
local p324 = string(`pct3_2024', "%4.1f")
file write `fh' "2024 & `n_2024' & `mp24' & `tp24' & `p324' & `n_both' \\" _n

file write `fh' "\hline\hline" _n
file write `fh' "\multicolumn{6}{l}{\footnotesize General-election contested counties (exclude-primary restriction).}\\" _n
file write `fh' "\multicolumn{6}{l}{\footnotesize \textit{Juror Volume Top 3} = share of total \textit{actually reported} from three largest counties.}\\" _n
file write `fh' "\multicolumn{6}{l}{\footnotesize \textit{Both Cycles} = counties contested in both 2016 and 2024 general elections.}\\" _n
file write `fh' "\end{tabular}" _n
file write `fh' "\end{table}" _n

file close `fh'
di as text "  → `f'"


*===================================================================
*  Summary
*===================================================================

di as text _n "========================================================"
di as text   "  Tables written:"
di as text   "    mi_tableA9_joint_exclusion.tex"
di as text   "    mi_tableA10_capacity_interaction.tex"
di as text   "    mi_tableA11_cycle_composition.tex"
di as text   "  Output: `texdir'"
di as text   "========================================================"

drop lnpop T2_x_lnpop
