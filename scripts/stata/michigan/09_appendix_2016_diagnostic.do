/*==============================================================================
  09_appendix_2016_diagnostic.do

  Purpose:  Generate LaTeX tables for Appendix B: 2016 Election Cycle
            Influence Diagnostic.

  Tables produced:
    mi_tableB1_year_means.tex       — Mean outcomes by year
    mi_tableB2_treatment_comp.tex   — Treatment composition in election years
    mi_tableB3_did_gaps.tex         — Raw DiD gaps (treated - untreated)
    mi_tableB4_variance_decomp.tex  — Variance decomposition
    mi_tableB5_outlier.tex          — all pipeline rate > 1 observations (raw data)

  Input:    $DATA_FINAL/michigan_panel_B.dta
  Output:   $OL_TABLES/../mi_appendix_2016/

  Run:      do code/master/paths.do
            do code/michigan/09_appendix_2016_diagnostic.do
==============================================================================*/

set update_query off
set more off

capture log close _all

local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

* Output directory for appendix tables
local odir "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26/files/tab/mi_appendix_2016"
capture mkdir "`odir'"

log using "$DIAGNOSTICS/09_appendix_2016_diagnostic.log", replace text

di _n as result "================================================================"
di as result "  APPENDIX B: 2016 DIAGNOSTIC TABLES"
di as result "================================================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear
decode county_id, gen(county_name)


/*--------------------------------------------------------------------------
  TABLE B1: Mean outcomes by year
--------------------------------------------------------------------------*/
di _n as text "--- Table B1: Mean outcomes by year ---"

preserve
    collapse (mean) actually_reported told_to_report summoned ///
        pct_told_to_report total_jury_verdicts, by(year)

    * Format for display
    format actually_reported told_to_report summoned %9.1f
    format pct_told_to_report %6.3f
    format total_jury_verdicts %6.1f

    local f "`odir'/mi_tableB1_year_means.tex"
    capture file close fh
    file open fh using "`f'", write replace

    file write fh "\begin{table}[ht]" _n
    file write fh "\centering" _n
    file write fh "\caption{Mean Jury Pipeline Outcomes by Year}" _n
    file write fh "\label{tab:diag-year-means}" _n
    file write fh "\begin{tabular}{lccccc}" _n
    file write fh "\toprule" _n
    file write fh "Year & Actually & Told to & Summoned & \% Told to & Jury \\" _n
    file write fh "     & Reported & Report  &          & Report     & Verdicts \\" _n
    file write fh "\midrule" _n

    local N = _N
    forvalues i = 1/`N' {
        local yr = year[`i']
        local ar : di %9.1f actually_reported[`i']
        local tr : di %9.1f told_to_report[`i']
        local su : di %9.1f summoned[`i']
        local pt : di %6.3f pct_told_to_report[`i']
        local jv : di %6.1f total_jury_verdicts[`i']
        file write fh "`yr' & `ar' & `tr' & `su' & `pt' & `jv' \\" _n
    }

    file write fh "\bottomrule" _n
    file write fh "\end{tabular}" _n
    file write fh "\begin{tablenotes}" _n
    file write fh "\small" _n
    file write fh "\item \textit{Notes:} Panel~B sample (all court structures). " _n
    file write fh "83 counties per year except 2024 (81). " _n
    file write fh "COVID years 2020--2021 excluded." _n
    file write fh "\end{tablenotes}" _n
    file write fh "\end{table}" _n

    file close fh
    di as text "  Written: `f'"
restore


/*--------------------------------------------------------------------------
  TABLE B2: Treatment composition in election years
--------------------------------------------------------------------------*/
di _n as text "--- Table B2: Treatment composition ---"

preserve
    keep if year == 2016 | year == 2024
    collapse (sum) treat_pros_pressure treat_pros_contested_long ///
        treat_pros_contested treat_pros_uncontested (count) n=county_id, by(year)

    local f "`odir'/mi_tableB2_treatment_comp.tex"
    capture file close fh
    file open fh using "`f'", write replace

    file write fh "\begin{table}[ht]" _n
    file write fh "\centering" _n
    file write fh "\caption{Treatment Composition in Election Years}" _n
    file write fh "\label{tab:diag-treatment-comp}" _n
    file write fh "\begin{tabular}{lccccc}" _n
    file write fh "\toprule" _n
    file write fh "Year & Counties & Pressure & Contested & Contested & Uncontested \\" _n
    file write fh "     &          &          & (Gen.)    & (Any)     &             \\" _n
    file write fh "\midrule" _n

    local N = _N
    forvalues i = 1/`N' {
        local yr = year[`i']
        local nc = n[`i']
        local pr = treat_pros_pressure[`i']
        local cl = treat_pros_contested_long[`i']
        local ca = treat_pros_contested[`i']
        local un = treat_pros_uncontested[`i']
        local pr_pct : di %4.1f 100*`pr'/`nc'
        local cl_pct : di %4.1f 100*`cl'/`nc'
        local ca_pct : di %4.1f 100*`ca'/`nc'
        local un_pct : di %4.1f 100*`un'/`nc'
        file write fh "`yr' & `nc' & `pr' (`pr_pct'\%) & `cl' (`cl_pct'\%) & `ca' (`ca_pct'\%) & `un' (`un_pct'\%) \\" _n
    }

    file write fh "\bottomrule" _n
    file write fh "\end{tabular}" _n
    file write fh "\begin{tablenotes}" _n
    file write fh "\small" _n
    file write fh "\item \textit{Notes:} Pressure = incumbent running for re-election. " _n
    file write fh "Contested (Gen.) = general-election opponent. " _n
    file write fh "Contested (Any) = primary or general-election opponent. " _n
    file write fh "Uncontested = running but no opponent at any stage." _n
    file write fh "\end{tablenotes}" _n
    file write fh "\end{table}" _n

    file close fh
    di as text "  Written: `f'"
restore


/*--------------------------------------------------------------------------
  TABLE B3: Raw DiD gaps
--------------------------------------------------------------------------*/
di _n as text "--- Table B3: Raw DiD gaps ---"

* Compute treated and untreated means for election years
local f "`odir'/mi_tableB3_did_gaps.tex"
capture file close fh
file open fh using "`f'", write replace

file write fh "\begin{table}[ht]" _n
file write fh "\centering" _n
file write fh "\caption{Raw Treated--Untreated Gaps in Election Years}" _n
file write fh "\label{tab:diag-did-gaps}" _n
file write fh "\begin{tabular}{lrrrrr}" _n
file write fh "\toprule" _n
file write fh " & \multicolumn{2}{c}{Actually Reported} & \multicolumn{2}{c}{\% Told to Report} & \\" _n
file write fh "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" _n
local ds = char(36) // literal dollar sign — prevents Stata macro expansion of $N_
file write fh "Year & Treated & Untreated & Treated & Untreated & `ds'N_{\text{untreated}}`ds' \\" _n
file write fh "\midrule" _n

foreach yr in 2016 2024 {
    qui sum actually_reported if year == `yr' & treat_pros_pressure == 1
    local ar_t : di %9.1f r(mean)
    qui sum actually_reported if year == `yr' & treat_pros_pressure == 0
    local ar_u : di %9.1f r(mean)
    local n_u = r(N)
    qui sum pct_told_to_report if year == `yr' & treat_pros_pressure == 1
    local pt_t : di %6.3f r(mean)
    qui sum pct_told_to_report if year == `yr' & treat_pros_pressure == 0
    local pt_u : di %6.3f r(mean)
    file write fh "`yr' & `ar_t' & `ar_u' & `pt_t' & `pt_u' & `n_u' \\" _n
}

file write fh "\midrule" _n
file write fh "\multicolumn{6}{l}{\textit{Treated $-$ Untreated Gap:}} \\" _n

foreach yr in 2016 2024 {
    qui sum actually_reported if year == `yr' & treat_pros_pressure == 1
    local ar_t = r(mean)
    qui sum actually_reported if year == `yr' & treat_pros_pressure == 0
    local ar_u = r(mean)
    local ar_g : di %9.1f `ar_t' - `ar_u'
    qui sum pct_told_to_report if year == `yr' & treat_pros_pressure == 1
    local pt_t = r(mean)
    qui sum pct_told_to_report if year == `yr' & treat_pros_pressure == 0
    local pt_u = r(mean)
    local pt_g : di %7.3f `pt_t' - `pt_u'
    file write fh "`yr' & \multicolumn{2}{c}{`ar_g'} & \multicolumn{2}{c}{`pt_g'} & \\" _n
}

file write fh "\bottomrule" _n
file write fh "\end{tabular}" _n
file write fh "\begin{tablenotes}" _n
file write fh "\small" _n
file write fh "\item \textit{Notes:} Raw group means by treatment status (electoral pressure). " _n
file write fh "In 2016, 9 counties are untreated (large counties, mean actually reported = 1,947). " _n
file write fh "In 2024, 15 counties are untreated (smaller counties, mean = 503). " _n
file write fh "County and year fixed effects absorb these compositional differences." _n
file write fh "\end{tablenotes}" _n
file write fh "\end{table}" _n

file close fh
di as text "  Written: `f'"


/*--------------------------------------------------------------------------
  TABLE B4: Variance decomposition
--------------------------------------------------------------------------*/
di _n as text "--- Table B4: Variance decomposition ---"

local f "`odir'/mi_tableB4_variance_decomp.tex"
capture file close fh
file open fh using "`f'", write replace

file write fh "\begin{table}[ht]" _n
file write fh "\centering" _n
file write fh "\caption{Variance Decomposition: 2016 Share of Within-County Variation}" _n
file write fh "\label{tab:diag-variance}" _n
file write fh "\begin{tabular}{lcccc}" _n
file write fh "\toprule" _n
file write fh "Outcome & 2016 \% of & 2016 \% of & Leverage \\" _n
file write fh "        & Variance   & Observations & Ratio   \\" _n
file write fh "\midrule" _n

foreach v in actually_reported told_to_report pct_told_to_report {
    bys county_id: egen cmean_`v' = mean(`v')
    gen resid_`v' = (`v' - cmean_`v')^2

    qui sum resid_`v'
    local total_var = r(sum)
    local total_n   = r(N)

    qui sum resid_`v' if year == 2016
    local var_2016 = r(sum)
    local n_2016   = r(N)

    local pct_var : di %5.1f 100 * `var_2016' / `total_var'
    local pct_n   : di %5.1f 100 * `n_2016'   / `total_n'
    local lev     : di %5.2f (`pct_var'/`pct_n')

    local vlab "`v'"
    if "`v'" == "actually_reported"   local vlab "Actually Reported"
    if "`v'" == "told_to_report"      local vlab "Told to Report"
    if "`v'" == "pct_told_to_report"  local vlab "\% Told to Report"

    file write fh "`vlab' & `pct_var'\% & `pct_n'\% & `lev' \\" _n

    drop cmean_`v' resid_`v'
}

file write fh "\bottomrule" _n
file write fh "\end{tabular}" _n
file write fh "\begin{tablenotes}" _n
file write fh "\small" _n
file write fh "\item \textit{Notes:} Leverage ratio = (2016 share of within-county sum of squares) / " _n
file write fh "(2016 share of observations). A ratio of 1.0 indicates proportional contribution. " _n
file write fh "Values above 1.0 indicate disproportionate influence; below 1.0 indicates under-leverage." _n
file write fh "\end{tablenotes}" _n
file write fh "\end{table}" _n

file close fh
di as text "  Written: `f'"


/*--------------------------------------------------------------------------
  TABLE B5: Outlier observations — mechanically impossible pipeline rates
  (raw data, BEFORE top-coding at 1.0)

  After upstream top-coding in 03_classify_and_aggregate.do, the estimation
  sample has all rates bounded [0,1]. This table preserves the raw snapshot
  for transparency. Recompute rates from raw counts to bypass top-coding.
--------------------------------------------------------------------------*/
di _n as text "--- Table B5: Outlier observations (raw rates) ---"

local f "`odir'/mi_tableB5_outlier.tex"
capture file close fh
file open fh using "`f'", write replace

* --- Recompute raw rates from counts (bypasses top-coding) ---
tempvar raw_ptr raw_pvd
gen `raw_ptr' = told_to_report / summoned if summoned > 0 & !missing(told_to_report)
gen `raw_pvd' = questioned_in_voir_dire / sent_to_courtroom ///
    if sent_to_courtroom > 0 & !missing(questioned_in_voir_dire)

file write fh "\begin{table}[ht]" _n
file write fh "\centering" _n
file write fh "\caption{County-Year Observations with Mechanically Impossible Jury Pipeline Ratios (Raw Data)}" _n
file write fh "\label{tab:diag-outlier}" _n
file write fh "\begin{tabular}{llccrrr}" _n
file write fh "\toprule" _n
file write fh "County & Year & Rate Variable & Ratio & Numerator & Denominator & Treated \\" _n
file write fh "\midrule" _n

* --- Part 1: pct_told_to_report > 1 ---
file write fh "\multicolumn{7}{l}{\textit{Panel A: \% Told to Report $> 1$}} \\[0.3em]" _n

preserve
    keep if `raw_ptr' > 1 & !missing(`raw_ptr')
    gsort -`raw_ptr'

    local N = _N
    forvalues i = 1/`N' {
        local cn = county_name[`i']
        local yr = year[`i']
        local rt : di %5.3f `raw_ptr'[`i']
        local nu = told_to_report[`i']
        local de = summoned[`i']
        local tx = cond(treat_pros_pressure[`i'] == 1, "Yes", "No")
        file write fh "`cn' & `yr' & Told/Summoned & `rt' & `nu' & `de' & `tx' \\" _n
    }
    if `N' == 0 {
        file write fh "\multicolumn{7}{c}{\textit{(None)}} \\" _n
    }
restore

* --- Part 2: pct_questioned_in_voir_dire > 1 ---
file write fh "\\[0.5em]" _n
file write fh "\multicolumn{7}{l}{\textit{Panel B: \% Questioned in Voir Dire $> 1$}} \\[0.3em]" _n

preserve
    keep if `raw_pvd' > 1 & !missing(`raw_pvd')
    gsort -`raw_pvd'

    local N = _N
    forvalues i = 1/`N' {
        local cn = county_name[`i']
        local yr = year[`i']
        local rt : di %5.3f `raw_pvd'[`i']
        local nu = questioned_in_voir_dire[`i']
        local de = sent_to_courtroom[`i']
        local tx = cond(treat_pros_pressure[`i'] == 1, "Yes", "No")
        file write fh "`cn' & `yr' & Questioned/Sent & `rt' & `nu' & `de' & `tx' \\" _n
    }
    if `N' == 0 {
        file write fh "\multicolumn{7}{c}{\textit{(None)}} \\" _n
    }
restore

file write fh "\bottomrule" _n
file write fh "\end{tabular}" _n
file write fh "\begin{tablenotes}" _n
file write fh "\small" _n
file write fh "\item \textit{Notes:} Ratios recomputed from raw counts prior to top-coding. " _n
file write fh "These timing mismatches arise from fiscal-year reporting in Michigan's SCAO data, " _n
file write fh "where numerator and denominator juror flows can span different reporting periods. " _n
file write fh "All rate variables are top-coded at 1.0 in the estimation samples to enforce " _n
file write fh "theoretical bounds. Results are robust to alternatively dropping these observations " _n
file write fh "entirely." _n
file write fh "\end{tablenotes}" _n
file write fh "\end{table}" _n

file close fh
di as text "  Written: `f'"


di _n as result "================================================================"
di as result "  ALL APPENDIX B TABLES WRITTEN"
di as result "================================================================"

log close
