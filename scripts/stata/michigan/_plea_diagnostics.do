if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}
clear
set more off

* Load misdemeanor plea data merged with elections
use "$DATA_FINAL/michigan_panel_B.dta", clear
merge m:1 county year using "$DATA_INT/mi_plea_composition_misdemeanor.dta", ///
    keepusing(plea_share jury_only trial_total plea_total log_jury_only jury_share) ///
    keep(match) nogen

capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* ============================================
* DIAGNOSTIC 1: How many zeros in jury_only?
* ============================================
di _n "=== ZERO DIAGNOSTIC ==="
qui count if jury_only == 0
di "Misdemeanor jury_only == 0: " r(N) " of " _N " (" %4.1f (r(N)/_N*100) "%)"
qui count if jury_only <= 1
di "Misdemeanor jury_only <= 1: " r(N) " of " _N
qui count if jury_only <= 3
di "Misdemeanor jury_only <= 3: " r(N) " of " _N

di _n "--- Distribution of jury_only ---"
tabstat jury_only, stat(n mean sd min p5 p10 p25 p50 p75 p90 p95 max) format(%9.1f)

* ============================================
* DIAGNOSTIC 2: Compare ln(y+1) vs IHS vs Poisson
* ============================================
di _n "=== TRANSFORMATION COMPARISON ==="

* Generate IHS transformation
gen ihs_jury_only = asinh(jury_only)

di _n "--- T1: ln(jury+1) ---"
reghdfe log_jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

di _n "--- T1: IHS(jury) ---"
reghdfe ihs_jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

di _n "--- T1: Poisson (ppmlhdfe) ---"
capture ppmlhdfe jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
if _rc {
    di "ppmlhdfe not installed — trying poisson"
    capture poisson jury_only treat_pros_pressure i.county_id i.year, vce(cluster county_id)
}

di _n "--- T1: LEVELS (jury_only) ---"
reghdfe jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

* ============================================
* DIAGNOSTIC 3: T2 contested — same comparisons
* ============================================
di _n "=== T2 CONTESTED COMPARISON ==="

preserve
qui drop if treat_pros_primary_only == 1

di _n "--- T2: ln(jury+1) ---"
reghdfe log_jury_only treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)

di _n "--- T2: IHS(jury) ---"
reghdfe ihs_jury_only treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)

di _n "--- T2: LEVELS ---"
reghdfe jury_only treat_pros_contested_long treat_pros_uncontested, absorb(county_id year) vce(cluster county_id)

restore

* ============================================
* DIAGNOSTIC 4: Where does the log effect come from?
* ============================================
di _n "=== WHO DRIVES THE LOG EFFECT? ==="

* Split by whether jury_only has zeros
gen byte has_zeros = (jury_only == 0)
tab has_zeros treat_pros_pressure

* Compare: counties WITH zero jury trials vs WITHOUT
di _n "--- Among county-years with jury_only > 0 ---"
reghdfe log_jury_only treat_pros_pressure if jury_only > 0, absorb(county_id year) vce(cluster county_id)

di _n "--- Among county-years with jury_only >= 0 (full sample) ---"
reghdfe log_jury_only treat_pros_pressure, absorb(county_id year) vce(cluster county_id)

* ============================================
* DIAGNOSTIC 5: Felony subtypes FC vs FH separately
* ============================================
di _n "=== FELONY SUBTYPES ==="
* Load the felony data BEFORE collapse
import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", clear varnames(1) encoding("UTF-8")

* Keep only plea/trial dispositions
gen byte is_disp = inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea")
keep if is_disp == 1

* Separate FC and FH
gen byte is_fc = regexm(case_type, "^FC ")
gen byte is_fh = regexm(case_type, "^FH ")

* Collapse to county × casetype × year (keep FC and FH separate)
collapse (sum) quantity, by(county case_type year action_name)

* Reshape
gen action_var = ""
replace action_var = "jury" if action_name == "Jury Verdict"
replace action_var = "bench" if action_name == "Bench Verdict"
replace action_var = "plea" if action_name == "Guilty Plea"
drop action_name

reshape wide quantity, i(county case_type year) j(action_var) string

rename quantityjury jury_only
rename quantitybench bench_verdict
rename quantityplea plea_total
replace jury_only = 0 if missing(jury_only)
replace bench_verdict = 0 if missing(bench_verdict)
replace plea_total = 0 if missing(plea_total)

gen trial_total = jury_only + bench_verdict
gen resolved = plea_total + trial_total
gen plea_share = plea_total / resolved if resolved > 0

* Split by case type
gen byte is_fc = regexm(case_type, "^FC ")

di _n "--- FC (Capital Felony) summary ---"
tabstat jury_only plea_total trial_total plea_share if is_fc == 1, ///
    stat(n mean sd min p50 max) format(%12.3f)

di _n "--- FH (Non-capital Felony) summary ---"
tabstat jury_only plea_total trial_total plea_share if is_fc == 0, ///
    stat(n mean sd min p50 max) format(%12.3f)

* Merge with elections for FC regressions
merge m:1 county year using "$DATA_FINAL/michigan_panel_B.dta", ///
    keepusing(county_id treat_pros_pressure treat_pros_contested_long ///
              treat_pros_uncontested treat_pros_contested) ///
    keep(match) nogen

di _n "--- FC: plea_share ~ pressure ---"
reghdfe plea_share treat_pros_pressure if is_fc == 1, absorb(county_id year) vce(cluster county_id)

di _n "--- FH: plea_share ~ pressure ---"
reghdfe plea_share treat_pros_pressure if is_fc == 0, absorb(county_id year) vce(cluster county_id)

di _n "--- FC: jury_only ~ pressure ---"
reghdfe jury_only treat_pros_pressure if is_fc == 1, absorb(county_id year) vce(cluster county_id)

di _n "--- FH: jury_only ~ pressure ---"
reghdfe jury_only treat_pros_pressure if is_fc == 0, absorb(county_id year) vce(cluster county_id)

di _n "--- FC: plea_total ~ pressure ---"
reghdfe plea_total treat_pros_pressure if is_fc == 1, absorb(county_id year) vce(cluster county_id)

di _n "--- FH: plea_total ~ pressure ---"
reghdfe plea_total treat_pros_pressure if is_fc == 0, absorb(county_id year) vce(cluster county_id)

di _n "=== DIAGNOSTICS COMPLETE ==="
