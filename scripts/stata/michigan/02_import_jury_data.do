/*==============================================================================
  02_import_jury_data.do

  Purpose:  Import SCAO court-level CSVs, destring NA values, apply labels,
            and save as labeled .dta files.

  Input:    $DATA_RAW/scao_parsed/mi_utilization_court.csv   (1,213 rows)
            $DATA_RAW/scao_parsed/mi_jury_selection_court.csv (1,157 rows)

  Output:   $DATA_INT/court_utilization.dta
            $DATA_INT/court_jury_selection.dta

  Adapted from: MI_datascrape_2_2-20-26/scripts/mi_label_and_save.do
  Requires: paths.do must be run first
            OR: cd to results_rebuild/ and run this file directly (auto-bootstraps).
==============================================================================*/

* --- Bootstrap: allow standalone execution ---
* If called from master_build_all.do, $ROOT is already set — skip.
* If run directly, this block sets all path globals automatically.
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

di as text _newline "========================================"
di as text "  02_import_jury_data.do"
di as text "========================================"


* =============================================================================
* 1. Court-Level Utilization Report
* =============================================================================

di as text _newline "--- 1. Court-Level Utilization ---"

import delimited "$DATA_RAW/scao_parsed/mi_utilization_court.csv", clear varnames(1)

di as text "Imported: " _N " rows"

* Destring numeric variables that got imported as string due to "NA" values
local numvars summoned told_to_report actually_reported sent_to_courtroom ///
    questioned_in_voir_dire capital_felony other_felony other_cases ///
    pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire utilization_rate pct_failed_to_appear ///
    flag_rate_anomaly flag_zero_summoned flag_missing_court year
foreach var of local numvars {
    capture confirm string variable `var'
    if !_rc {
        replace `var' = "" if `var' == "NA"
        destring `var', replace
    }
}

* Variable labels
label var state "State identifier"
label var year "Calendar year"
label var comparison_group "Court size comparison group"
label var county "County name (stripped suffix, merge-ready)"
label var court_name "Court display name from dashboard"
label var summoned "Jurors summoned"
label var told_to_report "Jurors told to report"
label var actually_reported "Jurors who actually reported"
label var sent_to_courtroom "Jurors sent from assembly to courtroom"
label var questioned_in_voir_dire "Jurors questioned/seated in voir dire"
label var capital_felony "Capital felony trial count"
label var other_felony "Other felony trial count"
label var other_cases "Other (non-felony) case trial count"
label var pct_told_to_report "Part A: Told to Report / Summoned"
label var pct_actually_reported "Actually Reported / Told to Report"
label var pct_sent_to_courtroom "Part B: Sent to Courtroom / Actually Reported"
label var pct_questioned_in_voir_dire "Part C: Questioned in Voir Dire / Sent to Courtroom"
label var utilization_rate "Juror Utilization Rate: Part A * Part B * Part C"
label var pct_failed_to_appear "Failed to Appear / Told to Report (UNRELIABLE)"
label var flag_rate_anomaly "1 if any rate > 1 or < 0"
label var flag_zero_summoned "1 if summoned = 0"
label var flag_missing_court "1 if court missing from expected set"

* Data notes
note state: "Always MI for this dataset."
note year: "Years available: 2016-2019, 2022-2024. COVID gap 2020-2021."
note pct_failed_to_appear: "EXCLUDED from analysis. ~30% of source rows have raw counts instead of proportions."
note flag_rate_anomaly: "Flagged, not corrected. Anomalies are in the source dashboard data."

* Validate
di as text "Year coverage:"
tab year
di as text "Total rows: " _N

label data "MI Juror Utilization Report -- Court Level (scraped 2026-02-20)"
compress
save "$DATA_INT/court_utilization.dta", replace

di as text "Saved: $DATA_INT/court_utilization.dta (" _N " obs)"


* =============================================================================
* 2. Court-Level Jury Selection Process
* =============================================================================

di as text _newline "--- 2. Court-Level Jury Selection ---"

import delimited "$DATA_RAW/scao_parsed/mi_jury_selection_court.csv", clear varnames(1)

di as text "Imported: " _N " rows"

* Destring numeric variables
local numvars year pct_utilization_rate pct_questioned_in_voir_dire ///
    pct_told_to_report pct_questionnaires_returned ///
    pct_qualified_to_serve pct_actually_reported
foreach var of local numvars {
    capture confirm string variable `var'
    if !_rc {
        replace `var' = "" if `var' == "NA"
        destring `var', replace
    }
}

label var year "Calendar year"
label var county_group "County grouping name from dashboard"
label var court_name "Court display name"
label var pct_utilization_rate "Juror Utilization Rate (Part A * B * C)"
label var pct_questioned_in_voir_dire "Part C: Questioned in Voir Dire / Sent to Courtroom"
label var pct_told_to_report "Part A: Told to Report / Summoned"
label var pct_questionnaires_returned "Questionnaires Returned / Questionnaires Sent"
label var pct_qualified_to_serve "Qualified to Serve / Questionnaires Returned"
label var pct_actually_reported "Actually Reported / Told to Report"

note county_group: "County name from DM1 grouping. Use for county mapping of District courts."

* Validate
di as text "Year coverage:"
tab year
di as text "Total rows: " _N

label data "MI Jury Selection Process -- Court Level (scraped 2026-02-20)"
compress
save "$DATA_INT/court_jury_selection.dta", replace

di as text "Saved: $DATA_INT/court_jury_selection.dta (" _N " obs)"


di as text _newline "========================================"
di as text "  02_import_jury_data.do COMPLETE"
di as text "========================================"
