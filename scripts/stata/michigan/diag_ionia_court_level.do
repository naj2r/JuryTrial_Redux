/*==============================================================================
  diag_ionia_court_level.do
  Quick diagnostic: trace Ionia's raw court-level data through the pipeline.
==============================================================================*/
set update_query off
set more off

local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

log using "$DIAGNOSTICS/diag_ionia_court_level.log", replace text

di _n as result "================================================================"
di as result "  IONIA COUNTY: COURT-LEVEL TRACE"
di as result "================================================================"

* --- Step 1: Raw classified court data ---
di _n as text "=== CLASSIFIED COURT DATA (all Ionia courts, all years) ==="
use "$DATA_INT/court_classified.dta", clear

* Find Ionia
di "All county_mapped values containing 'Ionia':"
list court_name county_mapped county comparison_group court_category ///
    mapping_method year if regexm(county_mapped, "Ionia"), noobs sepby(year)

di _n as text "=== KEY PIPELINE VARIABLES FOR IONIA ==="
list court_name year court_category summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    if regexm(county_mapped, "Ionia"), noobs sepby(year)

* --- Step 2: Check has_combined flag ---
di _n as text "=== PANEL B AGGREGATION RULE FOR IONIA ==="
gen _is_combined = (court_category == "COMBINED")
bysort county_mapped year: egen has_combined = max(_is_combined)
list court_name year court_category has_combined ///
    if regexm(county_mapped, "Ionia"), noobs sepby(year)

* --- Step 3: What survives the Panel B filter? ---
di _n as text "=== ROWS THAT SURVIVE PANEL B FILTER ==="
gen keep_for_B = 0
replace keep_for_B = 1 if has_combined == 1 & court_category == "COMBINED"
replace keep_for_B = 1 if has_combined == 0 & (court_category == "STANDALONE_CP" | court_category == "DISTRICT_OR_3RD")
list court_name year court_category keep_for_B summoned told_to_report actually_reported ///
    if regexm(county_mapped, "Ionia"), noobs sepby(year)

* --- Step 4: Post-aggregation Panel B values for Ionia ---
di _n as text "=== PANEL B COUNTY-LEVEL VALUES (post-collapse) ==="
use "$DATA_INT/county_year_B.dta", clear
list county year summoned told_to_report actually_reported ///
    n_courts agg_rule ///
    if county == "Ionia", noobs

* --- Step 5: Compare with what's in the final regression dataset ---
di _n as text "=== FINAL REGRESSION DATASET VALUES ==="
use "$DATA_FINAL/michigan_panel_B.dta", clear
decode county_id, gen(county_name)
list county_name year summoned told_to_report actually_reported ///
    pct_told_to_report ///
    if county_name == "Ionia", noobs


* --- Step 6: Also check Macomb (the other >1 outlier) ---
di _n as text "=== MACOMB COURT-LEVEL TRACE ==="
use "$DATA_INT/court_classified.dta", clear
list court_name year court_category summoned told_to_report actually_reported ///
    if regexm(county_mapped, "Macomb"), noobs sepby(year)

* --- Step 7: Oceana too ---
di _n as text "=== OCEANA COURT-LEVEL TRACE ==="
list court_name year court_category summoned told_to_report actually_reported ///
    if regexm(county_mapped, "Oceana"), noobs sepby(year)


di _n as result "================================================================"
di as result "  DIAGNOSTIC COMPLETE"
di as result "================================================================"

log close
