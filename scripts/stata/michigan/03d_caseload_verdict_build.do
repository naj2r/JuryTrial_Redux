/*==============================================================================
  03d_caseload_verdict_build.do — Build FC/FH Verdict, Plea & Disposition Panel
                                   from SCAO Outgoing Caseload Dashboard

  Source: outgoing_felony_by_year.csv
    Scraped from SCAO Interactive Court Data Dashboard — Outgoing Caseload
    Case Group = Felony, Case Type = FC + FH
    URL: courts.michigan.gov/publications/statistics-and-reports/
         interactive-court-data-dashboard/

  WHY THIS EXISTS:
    The SCAO jury utilization dashboard's verdict columns (capital_felony,
    other_felony, other_cases) are UNRELIABLE for 2024:
    - Power BI uses MIN() aggregation for capital_felony (not SUM)
    - 2024 shows 3 FC jury verdicts statewide from jury dashboard
      vs 431 from caseload dashboard (the correct number)
    - Every major circuit court reports exactly 0 FC in jury dashboard
    - See _investigate_2024.do for full diagnosis

    The outgoing caseload dashboard reports disposition counts correctly
    at the county-court-year level with explicit FC/FH case type codes.
    Circuit courts only (codes C01-C57). No district court contamination.

  DATA STRUCTURE:
    CSV: county, court_code, case_type, action_name, quantity, year
    Case types: "FC - Capital Felonies", "FH - Non-capital Felonies"

  OUTPUT:
    $DATA_INT/caseload_verdict_panel.dta — county-year panel

  VARIABLES CREATED:
    Tier 1 (primary — verdict and plea counts):
      fc_jury, fh_jury           — jury verdict counts
      fc_plea, fh_plea           — guilty plea + guilty plea/admission
      felony_jury_total          — fc_jury + fh_jury
      severity_share             — fc_jury / felony_jury_total
      fc_jury_share, fh_jury_share   — jury trial rate (jury / total disp)
      fc_plea_share, fh_plea_share   — plea rate (plea / total disp)

    Tier 2 (mechanism — other disposition types):
      fc_bench, fh_bench         — bench verdict counts
      fc_dismissed, fh_dismissed — dismissed by party (prosecutorial)
      fc_case_change, fh_case_change — case type reclassification
      fc_court_dismissed, fh_court_dismissed — dismissed by court (judicial)

    Derived:
      fc_total_disp, fh_total_disp — total dispositions (all methods)
      fc_trial_rate              — (fc_jury + fc_bench) / fc_total_disp
      fh_trial_rate              — (fh_jury + fh_bench) / fh_total_disp

  FC = Felony Capital (life-eligible). FH = Felony non-capital. SCAO codes.
==============================================================================*/

if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear all
set more off

di _n "========================================"
di "  03d_caseload_verdict_build.do"
di "  $S_DATE $S_TIME"
di "========================================"


* =============================================================================
* STEP 1: Import and clean
* =============================================================================

import delimited using "$ROOT/data_raw/michigan/scao_caseload/outgoing_felony_by_year.csv", clear stringcols(_all)
di "Raw rows imported: " _N

* Strip quotes from all string variables
foreach v of varlist _all {
    capture replace `v' = subinstr(`v', `"""', "", .)
}

* Destring numeric fields
destring quantity year, replace force

* Rename for clarity
rename county county_name

di _n "=== Raw data structure ==="
tab case_type
tab action_name


* =============================================================================
* STEP 2: Filter to relevant case types, actions, and years
* =============================================================================

* Keep only FC and FH
keep if inlist(case_type, "FC - Capital Felonies", "FH - Non-capital Felonies")

* Keep only disposition actions (drop pending, filing, disposed-by-time categories)
keep if inlist(action_name, "Jury Verdict", "Bench Verdict", "Guilty Plea") | ///
       inlist(action_name, "Guilty Plea/Admission", "Dismissed by Party") | ///
       inlist(action_name, "Dismissed by Court", "Case Type Change")

* Keep panel years only (match jury utilization panel: 2016-2019, 2022-2024)
keep if inlist(year, 2016, 2017, 2018, 2019, 2022, 2023, 2024)

di _n "=== Filtered data ==="
di "Rows: " _N
tab case_type action_name


* =============================================================================
* STEP 3: Create variable name from case_type × action_name
* =============================================================================

* Case type prefix
gen prefix = "fc" if case_type == "FC - Capital Felonies"
replace prefix = "fh" if case_type == "FH - Non-capital Felonies"

* Disposition suffix
gen suffix = ""
replace suffix = "_jury"            if action_name == "Jury Verdict"
replace suffix = "_bench"           if action_name == "Bench Verdict"
replace suffix = "_plea"            if inlist(action_name, "Guilty Plea", "Guilty Plea/Admission")
replace suffix = "_dismissed"       if action_name == "Dismissed by Party"
replace suffix = "_court_dismissed" if action_name == "Dismissed by Court"
replace suffix = "_case_change"     if action_name == "Case Type Change"

gen varname = prefix + suffix

* Verify no missing
assert !missing(varname)
tab varname


* =============================================================================
* STEP 4: Collapse to county-year × variable
*   Sums across: court codes within county (multi-court circuits)
*                Guilty Plea + Guilty Plea/Admission (combined into _plea)
* =============================================================================

collapse (sum) quantity, by(county_name year varname)

* Reshape wide: one row per county-year, columns = disposition variables
reshape wide quantity, i(county_name year) j(varname) string

* Clean variable names (remove "quantity" prefix)
foreach v of varlist quantity* {
    local newname = subinstr("`v'", "quantity", "", 1)
    rename `v' `newname'
}

* Fill missing with 0
* (County-years with no FC jury verdicts have missing after reshape)
foreach v of varlist fc_* fh_* {
    replace `v' = 0 if missing(`v')
}

di _n "=== Panel dimensions ==="
di "Obs: " _N
tab year
qui distinct county_name
di "Counties: " r(ndistinct)


* =============================================================================
* STEP 5: Construct derived variables
* =============================================================================

* --- Total dispositions (all methods except case type change) ---
gen fc_total_disp = fc_jury + fc_bench + fc_plea + fc_dismissed + fc_court_dismissed
gen fh_total_disp = fh_jury + fh_bench + fh_plea + fh_dismissed + fh_court_dismissed

* --- Jury verdict totals ---
gen felony_jury_total = fc_jury + fh_jury

* --- Trial totals (jury + bench) ---
gen fc_trial = fc_jury + fc_bench
gen fh_trial = fh_jury + fh_bench

* --- Shares (conditional on positive denominators) ---
* Jury trial rate
gen fc_jury_share = fc_jury / fc_total_disp if fc_total_disp > 0
gen fh_jury_share = fh_jury / fh_total_disp if fh_total_disp > 0

* Plea rate
gen fc_plea_share = fc_plea / fc_total_disp if fc_total_disp > 0
gen fh_plea_share = fh_plea / fh_total_disp if fh_total_disp > 0

* Trial rate (jury + bench)
gen fc_trial_rate = fc_trial / fc_total_disp if fc_total_disp > 0
gen fh_trial_rate = fh_trial / fh_total_disp if fh_total_disp > 0

* Dismissal rate (by party = prosecutorial discretion)
gen fc_dismiss_rate = fc_dismissed / fc_total_disp if fc_total_disp > 0
gen fh_dismiss_rate = fh_dismissed / fh_total_disp if fh_total_disp > 0

* Severity composition: FC share of felony jury verdicts
gen severity_share = fc_jury / felony_jury_total if felony_jury_total > 0
gen fh_severity_share = fh_jury / felony_jury_total if felony_jury_total > 0

* Case type change rate (reclassification intensity)
gen fc_reclass_rate = fc_case_change / fc_total_disp if fc_total_disp > 0


* =============================================================================
* STEP 6: Labels
* =============================================================================

* Counts
label var fc_jury             "FC jury verdicts (capital felony)"
label var fh_jury             "FH jury verdicts (non-capital felony)"
label var fc_bench            "FC bench verdicts"
label var fh_bench            "FH bench verdicts"
label var fc_plea             "FC guilty pleas (plea + admission)"
label var fh_plea             "FH guilty pleas (plea + admission)"
label var fc_dismissed        "FC dismissed by party (prosecutorial)"
label var fh_dismissed        "FH dismissed by party (prosecutorial)"
label var fc_court_dismissed  "FC dismissed by court (judicial)"
label var fh_court_dismissed  "FH dismissed by court (judicial)"
label var fc_case_change      "FC case type changes (reclassification)"
label var fh_case_change      "FH case type changes (reclassification)"
label var fc_total_disp       "FC total dispositions"
label var fh_total_disp       "FH total dispositions"
label var fc_trial            "FC total trials (jury + bench)"
label var fh_trial            "FH total trials (jury + bench)"
label var felony_jury_total   "Total felony jury verdicts (FC + FH)"

* Shares
label var fc_jury_share       "FC jury trial rate (jury / total disp)"
label var fh_jury_share       "FH jury trial rate"
label var fc_plea_share       "FC plea rate (plea / total disp)"
label var fh_plea_share       "FH plea rate"
label var fc_trial_rate       "FC trial rate (jury+bench / total disp)"
label var fh_trial_rate       "FH trial rate"
label var fc_dismiss_rate     "FC prosecutorial dismissal rate"
label var fh_dismiss_rate     "FH prosecutorial dismissal rate"
label var severity_share      "FC share of felony jury verdicts"
label var fh_severity_share   "FH share of felony jury verdicts"
label var fc_reclass_rate     "FC case type change rate"


* =============================================================================
* STEP 7: Diagnostics
* =============================================================================

di _n "=== Statewide totals by year ==="
preserve
collapse (sum) fc_jury fh_jury fc_plea fh_plea fc_bench fh_bench ///
    fc_dismissed fh_dismissed fc_case_change fh_case_change ///
    felony_jury_total fc_total_disp fh_total_disp, by(year)
list year fc_jury fh_jury fc_bench fc_plea fc_dismissed fc_case_change, sep(0)
list year fh_jury fh_bench fh_plea fh_dismissed fh_case_change, sep(0)
restore

di _n "=== County completeness (non-zero FC jury verdict counties by year) ==="
forvalues y = 2016/2024 {
    if inlist(`y', 2020, 2021) continue
    qui count if year == `y' & fc_jury > 0
    local nfc = r(N)
    qui count if year == `y' & fh_jury > 0
    local nfh = r(N)
    qui count if year == `y'
    local ntot = r(N)
    di "`y': FC>0 = `nfc', FH>0 = `nfh', Total counties = `ntot'"
}

di _n "=== Summary statistics (panel years) ==="
tabstat fc_jury fh_jury fc_plea fh_plea fc_bench fc_dismissed fc_case_change ///
    severity_share fc_plea_share fc_jury_share, ///
    stat(n mean sd min p50 max) columns(statistics) format(%9.3f)


* =============================================================================
* STEP 8: Save
* =============================================================================

order county_name year ///
    fc_jury fh_jury fc_bench fh_bench fc_plea fh_plea ///
    fc_dismissed fh_dismissed fc_court_dismissed fh_court_dismissed ///
    fc_case_change fh_case_change ///
    fc_total_disp fh_total_disp fc_trial fh_trial felony_jury_total ///
    fc_jury_share fh_jury_share fc_plea_share fh_plea_share ///
    fc_trial_rate fh_trial_rate fc_dismiss_rate fh_dismiss_rate ///
    severity_share fh_severity_share fc_reclass_rate

sort county_name year

save "$DATA_INT/caseload_verdict_panel.dta", replace

di _n "========================================"
di "  03d COMPLETE"
di "  Output: $DATA_INT/caseload_verdict_panel.dta"
di "  Obs: " _N
di "========================================"
