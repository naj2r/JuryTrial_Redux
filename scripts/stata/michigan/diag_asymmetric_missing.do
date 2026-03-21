/*==============================================================================
  diag_asymmetric_missing.do
  Scan ALL court-level records for asymmetric missingness:
    Cases where summoned is missing but other pipeline variables exist.
  This causes collapse (sum) to undercount the denominator, inflating
  pct_told_to_report and other rate variables.
==============================================================================*/
set update_query off
set more off

local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

log using "$DIAGNOSTICS/diag_asymmetric_missing.log", replace text

di _n as result "================================================================"
di as result "  ASYMMETRIC MISSINGNESS SCAN"
di as result "================================================================"

use "$DATA_INT/court_classified.dta", clear

* --- Part 1: Courts with summoned MISSING but told_to_report NON-MISSING ---
di _n as text "=== CASE A: summoned = . BUT told_to_report != . ==="
di "  (these INFLATE pct_told_to_report during collapse)"
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    if missing(summoned) & !missing(told_to_report), noobs

qui count if missing(summoned) & !missing(told_to_report)
di _n "  Total Case A records: " r(N)

* --- Part 2: Courts with told_to_report MISSING but summoned NON-MISSING ---
di _n as text "=== CASE B: told_to_report = . BUT summoned != . ==="
di "  (these DEFLATE told_to_report during collapse)"
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    if !missing(summoned) & missing(told_to_report), noobs

qui count if !missing(summoned) & missing(told_to_report)
di _n "  Total Case B records: " r(N)

* --- Part 3: Courts with actually_reported MISSING but told_to_report NON-MISSING ---
di _n as text "=== CASE C: actually_reported = . BUT told_to_report != . ==="
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    if missing(actually_reported) & !missing(told_to_report), noobs

qui count if missing(actually_reported) & !missing(told_to_report)
di _n "  Total Case C records: " r(N)

* --- Part 4: ANY pipeline variable missing while another is non-missing ---
di _n as text "=== CASE D: ANY asymmetric missingness in pipeline vars ==="
di "  (summoned, told_to_report, actually_reported)"

gen byte has_any = !missing(summoned) | !missing(told_to_report) | !missing(actually_reported)
gen byte all_present = !missing(summoned) & !missing(told_to_report) & !missing(actually_reported)
gen byte all_missing = missing(summoned) & missing(told_to_report) & missing(actually_reported)
gen byte asymmetric = has_any & !all_present & !all_missing

di "  Records with at least one var: "
qui count if has_any
di "    " r(N)
di "  Records with ALL three present: "
qui count if all_present
di "    " r(N)
di "  Records with ALL three missing: "
qui count if all_missing
di "    " r(N)
di "  Records with ASYMMETRIC missingness: "
qui count if asymmetric
di "    " r(N)

di _n as text "=== ASYMMETRIC RECORDS (full detail) ==="
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    if asymmetric, noobs sepby(county_mapped)

* --- Part 5: Impact on Panel B counties ---
di _n as text "=== WHICH PANEL B COUNTIES ARE AFFECTED? ==="
di "  (counties where asymmetric missingness enters the collapse)"

* Replicate Panel B filter
gen _is_combined = (court_category == "COMBINED")
bysort county_mapped year: egen has_combined = max(_is_combined)
gen keep_for_B = 0
replace keep_for_B = 1 if has_combined == 1 & court_category == "COMBINED"
replace keep_for_B = 1 if has_combined == 0 & (court_category == "STANDALONE_CP" | court_category == "DISTRICT_OR_3RD")

di "  Asymmetric records that SURVIVE Panel B filter:"
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    if asymmetric & keep_for_B == 1, noobs sepby(county_mapped)

qui count if asymmetric & keep_for_B == 1
di _n "  Total Panel B-eligible asymmetric records: " r(N)

* --- Part 6: Quantify denominator impact ---
di _n as text "=== DENOMINATOR IMPACT: summoned missing in Panel B ==="
di "  For each affected county-year, show what the county sum will be"
di "  vs what it should be (i.e., which court's summoned is missing)"

* For Case A records in Panel B, show what we know
list court_name county_mapped year court_category ///
    summoned told_to_report actually_reported ///
    if missing(summoned) & !missing(told_to_report) & keep_for_B == 1, noobs

* Show the companion court(s) for the same county-year
di _n as text "=== COMPANION COURTS for affected county-years ==="
levelsof county_mapped if asymmetric & keep_for_B == 1 & missing(summoned) & !missing(told_to_report), local(affected_counties) clean
levelsof year if asymmetric & keep_for_B == 1 & missing(summoned) & !missing(told_to_report), local(affected_years) clean

foreach c of local affected_counties {
    foreach y of local affected_years {
        qui count if county_mapped == "`c'" & year == `y' & keep_for_B == 1
        if r(N) > 0 {
            di _n "--- `c', `y' ---"
            list court_name court_category summoned told_to_report actually_reported ///
                if county_mapped == "`c'" & year == `y' & keep_for_B == 1, noobs
        }
    }
}

* --- Part 7: Check for the opposite problem on other pipeline vars ---
di _n as text "=== SENT_TO_COURTROOM asymmetric check ==="
qui count if missing(sent_to_courtroom) & !missing(actually_reported) & keep_for_B == 1
di "  sent_to_courtroom missing but actually_reported present (Panel B): " r(N)
if r(N) > 0 {
    list court_name county_mapped year summoned sent_to_courtroom actually_reported ///
        if missing(sent_to_courtroom) & !missing(actually_reported) & keep_for_B == 1, noobs
}

di _n as text "=== QUESTIONED_IN_VOIR_DIRE asymmetric check ==="
qui count if missing(questioned_in_voir_dire) & !missing(sent_to_courtroom) & keep_for_B == 1
di "  questioned missing but sent_to_courtroom present (Panel B): " r(N)
if r(N) > 0 {
    list court_name county_mapped year summoned questioned_in_voir_dire sent_to_courtroom ///
        if missing(questioned_in_voir_dire) & !missing(sent_to_courtroom) & keep_for_B == 1, noobs
}

di _n as result "================================================================"
di as result "  SCAN COMPLETE"
di as result "================================================================"

log close
