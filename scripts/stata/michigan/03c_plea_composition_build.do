/*==============================================================================
  03c_plea_composition_build.do

  Purpose:  Build plea vs. trial composition variables from SCAO outgoing
            caseload data (scraped year-specific disposition counts).
            McCannon (2013/2014)-style analysis of case resolution margins.

  Input:    $DATA_RAW/scao_caseload/outgoing_felony_by_year.csv
            $DATA_RAW/scao_caseload/outgoing_misdemeanor_by_year.csv

  Output:   $DATA_INT/mi_plea_composition_felony.dta     (circuit court felonies)
            $DATA_INT/mi_plea_composition_misdemeanor.dta (district court misdemeanors)

  Design notes:
    - Felony: circuit courts only (C-prefixed), FC + FH case types
    - Misdemeanor: district courts only (D-prefixed), SD + SM case types
    - Plea variable: "Guilty Plea/Admission" primary; "Guilty Plea" as fallback
      (circuit courts use "Guilty Plea"; district courts use both)
    - Trial variables: jury_only = Jury Verdict; trial_total = Jury + Bench Verdict
      (no "Verdict at Hearing" in circuit felony data)
    - Court codes preserved for disaggregated linking

  Scraping source: data_raw/michigan/scao_r_scripts/scrape_outgoing_caseload.R
  Requires: paths.do must be run first.
==============================================================================*/

* --- Bootstrap ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

di as text _newline "========================================"
di as text "  03c_plea_composition_build.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* #############################################################################
* STEP 1: BUILD FELONY PLEA COMPOSITION (Circuit Courts, FC + FH)
* #############################################################################
di _n "{hline 72}"
di "STEP 1: FELONY PLEA COMPOSITION"
di "{hline 72}"

* --- Import scraped year-specific data ---
import delimited "$DATA_RAW/scao_caseload/outgoing_felony_by_year.csv", ///
    clear varnames(1) encoding("UTF-8")

di "Imported felony outgoing: " _N " rows"

* --- Check structure ---
describe, short
tab action_name, sort

* --- Keep only disposition categories relevant to plea/trial ---
* Following the task spec: include Jury Verdict, Bench Verdict, Guilty Plea
* Exclude: Beginning Pending, New Filings, Disposed within X days,
*          Pending X days, Reopened, Dismissed, Transferred, Inactive, Case Type Change
gen byte is_disposition = inlist(action_name, ///
    "Jury Verdict", "Bench Verdict", "Guilty Plea", "Guilty Plea/Admission")

di _n "--- Disposition category filter ---"
tab action_name is_disposition

keep if is_disposition == 1
drop is_disposition
di "After disposition filter: " _N " rows"

* --- Reshape: action_name → wide columns ---
* Need one row per county × court_code × case_type × year
* with columns: jury_verdict, bench_verdict, guilty_plea

* Create clean variable name from action_name
gen action_var = ""
replace action_var = "jury_verdict" if action_name == "Jury Verdict"
replace action_var = "bench_verdict" if action_name == "Bench Verdict"
replace action_var = "guilty_plea" if action_name == "Guilty Plea"
replace action_var = "guilty_plea_adm" if action_name == "Guilty Plea/Admission"

* Check for duplicates before reshape
duplicates report county court_code case_type year action_var
duplicates tag county court_code case_type year action_var, gen(_dup)
qui count if _dup > 0
if r(N) > 0 {
    di as error "WARNING: " r(N) " duplicate records found"
    list county court_code case_type year action_var quantity if _dup > 0, noobs
    * Resolve by summing (shouldn't happen)
    collapse (sum) quantity, by(county court_code case_type year action_var)
}
else {
    drop _dup
}

drop action_name

* Reshape wide
reshape wide quantity, i(county court_code case_type year) j(action_var) string

* Rename to clean names
rename quantityjury_verdict jury_verdict
rename quantitybench_verdict bench_verdict
capture rename quantityguilty_plea guilty_plea
capture rename quantityguilty_plea_adm guilty_plea_adm

* Replace missing with 0 (missing = no such disposition in that county-year)
foreach v in jury_verdict bench_verdict {
    replace `v' = 0 if missing(`v')
}
* Ensure both plea columns exist (circuit courts may only have guilty_plea)
capture confirm variable guilty_plea
if _rc {
    gen guilty_plea = 0
}
else {
    replace guilty_plea = 0 if missing(guilty_plea)
}
capture confirm variable guilty_plea_adm
if _rc {
    gen guilty_plea_adm = 0
}
else {
    replace guilty_plea_adm = 0 if missing(guilty_plea_adm)
}

di "After reshape: " _N " obs (county × court × casetype × year)"


* ==========================================================
* SAVE COURT-LEVEL VERSION (before county collapse)
* ==========================================================
* Collapse across case types (FC+FH) within court×county×year
* but preserve court_code for court-level regressions
preserve
    collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm, ///
        by(county court_code year)

    * Construct composition variables at court level
    gen plea_total = guilty_plea
    capture replace plea_total = guilty_plea_adm if plea_total == 0 & guilty_plea_adm > 0
    gen jury_only = jury_verdict
    gen trial_total = jury_verdict + bench_verdict
    gen resolved_total = plea_total + trial_total
    gen plea_share = plea_total / resolved_total if resolved_total > 0
    gen jury_share = jury_only / resolved_total if resolved_total > 0
    * * gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform
    * * gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform

    * Create court_id for FE
    egen court_id = group(court_code county)

    di _n "--- Felony COURT-LEVEL: " _N " obs, " r(ndistinct) " courts ---"
    tabstat plea_share jury_only trial_total, ///
        stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

    compress
    save "$DATA_INT/mi_plea_composition_felony_court.dta", replace
    di as result "Saved COURT-LEVEL: mi_plea_composition_felony_court.dta (" _N " obs)"
restore


* ==========================================================
* COUNTY-LEVEL VERSION (collapse courts within county)
* ==========================================================
collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm, ///
    by(county year)

di "After county-year collapse: " _N " obs"

* Construct composition variables
gen plea_total = guilty_plea
capture replace plea_total = guilty_plea_adm if plea_total == 0 & guilty_plea_adm > 0

gen jury_only = jury_verdict
gen trial_total = jury_verdict + bench_verdict
gen resolved_total = plea_total + trial_total

gen plea_share = plea_total / resolved_total if resolved_total > 0
gen trial_share = trial_total / resolved_total if resolved_total > 0
gen jury_share = jury_only / resolved_total if resolved_total > 0

* gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform
* gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform
* gen log_trial_total = ln(trial_total + 1)  // REMOVED: too many zeros for log transform

* Leads
sort county year
encode county, gen(county_enc)
xtset county_enc year
gen plea_share_lead1 = F.plea_share
gen jury_only_lead1 = F.jury_only

* Labels
label variable plea_total       "Total pleas (circuit felonies)"
label variable jury_only        "Jury verdicts only"
label variable trial_total      "Total trials (jury + bench)"
label variable resolved_total   "Total resolved (plea + trial)"
label variable plea_share       "Plea share = plea / (plea + trial)"
label variable jury_share       "Jury share = jury / (plea + trial)"
label variable log_jury_only    "ln(jury verdicts + 1)"

* Validation
di _n "--- Felony COUNTY-LEVEL plea composition ---"
tabstat plea_total trial_total jury_only resolved_total plea_share jury_share, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

qui distinct county
di _n "Unique counties: " r(ndistinct)

qui count if plea_share < 0 | plea_share > 1
di "Plea share out of [0,1]: " r(N)
qui count if resolved_total == 0
di "County-years with zero resolved: " r(N)

compress
save "$DATA_INT/mi_plea_composition_felony.dta", replace
di as result "Saved COUNTY-LEVEL: mi_plea_composition_felony.dta (" _N " obs)"


* #############################################################################
* STEP 2: BUILD MISDEMEANOR PLEA COMPOSITION (District Courts, SD + SM)
* #############################################################################
di _n "{hline 72}"
di "STEP 2: MISDEMEANOR PLEA COMPOSITION"
di "{hline 72}"

import delimited "$DATA_RAW/scao_caseload/outgoing_misdemeanor_by_year.csv", ///
    clear varnames(1) encoding("UTF-8")

di "Imported misdemeanor outgoing: " _N " rows"

* --- Keep only disposition categories ---
gen byte is_disposition = inlist(action_name, ///
    "Jury Verdict", "Bench Verdict", "Guilty Plea", "Guilty Plea/Admission")

tab action_name is_disposition
keep if is_disposition == 1
drop is_disposition
di "After disposition filter: " _N " rows"

* --- Reshape wide ---
gen action_var = ""
replace action_var = "jury_verdict" if action_name == "Jury Verdict"
replace action_var = "bench_verdict" if action_name == "Bench Verdict"
replace action_var = "guilty_plea" if action_name == "Guilty Plea"
replace action_var = "guilty_plea_adm" if action_name == "Guilty Plea/Admission"

duplicates tag county court_code case_type year action_var, gen(_dup)
qui count if _dup > 0
if r(N) > 0 {
    di as error "WARNING: " r(N) " duplicate records"
    collapse (sum) quantity, by(county court_code case_type year action_var)
}
else {
    drop _dup
}

drop action_name
reshape wide quantity, i(county court_code case_type year) j(action_var) string

rename quantityjury_verdict jury_verdict
rename quantitybench_verdict bench_verdict
capture rename quantityguilty_plea guilty_plea
capture rename quantityguilty_plea_adm guilty_plea_adm

foreach v in jury_verdict bench_verdict {
    replace `v' = 0 if missing(`v')
}
* Ensure both plea columns exist
capture confirm variable guilty_plea
if _rc {
    gen guilty_plea = 0
}
else {
    replace guilty_plea = 0 if missing(guilty_plea)
}
capture confirm variable guilty_plea_adm
if _rc {
    gen guilty_plea_adm = 0
}
else {
    replace guilty_plea_adm = 0 if missing(guilty_plea_adm)
}

* --- Court-level save (before county collapse) ---
preserve
    collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm, ///
        by(county court_code year)

    gen plea_total = guilty_plea_adm
    replace plea_total = guilty_plea if plea_total == 0 & guilty_plea > 0
    gen jury_only = jury_verdict
    gen trial_total = jury_verdict + bench_verdict
    gen resolved_total = plea_total + trial_total
    gen plea_share = plea_total / resolved_total if resolved_total > 0
    gen jury_share = jury_only / resolved_total if resolved_total > 0
    * * gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform
    * * gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform
    egen court_id = group(court_code county)

    compress
    save "$DATA_INT/mi_plea_composition_misdemeanor_court.dta", replace
    di as result "Saved COURT-LEVEL: mi_plea_composition_misdemeanor_court.dta (" _N " obs)"
restore

* --- County-level collapse ---
collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm, ///
    by(county year)

di "After county-year collapse: " _N " obs"

gen plea_total = guilty_plea_adm
replace plea_total = guilty_plea if plea_total == 0 & guilty_plea > 0

gen jury_only = jury_verdict
gen trial_total = jury_verdict + bench_verdict
gen resolved_total = plea_total + trial_total

gen plea_share = plea_total / resolved_total if resolved_total > 0
gen trial_share = trial_total / resolved_total if resolved_total > 0
gen jury_share = jury_only / resolved_total if resolved_total > 0

* gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform
* gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform

sort county year
encode county, gen(county_enc)
xtset county_enc year
gen plea_share_lead1 = F.plea_share
gen jury_only_lead1 = F.jury_only

* Validation
di _n "--- Misdemeanor plea composition summary ---"
tabstat plea_total trial_total jury_only resolved_total plea_share jury_share, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

qui distinct county
di _n "Unique counties: " r(ndistinct)

compress
save "$DATA_INT/mi_plea_composition_misdemeanor.dta", replace
di as result "Saved COUNTY-LEVEL: mi_plea_composition_misdemeanor.dta (" _N " obs)"


* #############################################################################
* STEP 3: DISTRICT COURT FELONIES (FY + FD — Preliminary Exam Level)
* #############################################################################
di _n "{hline 72}"
di "STEP 3: DISTRICT COURT FELONIES (FY + FD)"
di "{hline 72}"

import delimited "$DATA_RAW/scao_caseload/outgoing_district_felony_by_year.csv", ///
    clear varnames(1) encoding("UTF-8")

di "Imported district felony outgoing: " _N " rows"

* Keep plea/trial dispositions
* District court felonies have extra categories:
*   "Felony Plea Accepted in District Court" — felony plea at district level
*   "Bindover/Transfer" — sent to circuit court
* We include the district-level plea in plea_total
gen byte is_disposition = inlist(action_name, ///
    "Jury Verdict", "Bench Verdict", "Guilty Plea", "Guilty Plea/Admission", ///
    "Felony Plea Accepted in District Court")

tab action_name if is_disposition == 1
keep if is_disposition == 1
drop is_disposition
di "After disposition filter: " _N " rows"

* Reshape
gen action_var = ""
replace action_var = "jury_verdict" if action_name == "Jury Verdict"
replace action_var = "bench_verdict" if action_name == "Bench Verdict"
replace action_var = "guilty_plea" if action_name == "Guilty Plea"
replace action_var = "guilty_plea_adm" if action_name == "Guilty Plea/Admission"
replace action_var = "felony_plea_dc" if action_name == "Felony Plea Accepted in District Court"

duplicates tag county court_code case_type year action_var, gen(_dup)
qui count if _dup > 0
if r(N) > 0 {
    di as error "WARNING: " r(N) " duplicate records"
    collapse (sum) quantity, by(county court_code case_type year action_var)
}
else {
    drop _dup
}
drop action_name

reshape wide quantity, i(county court_code case_type year) j(action_var) string

capture rename quantityjury_verdict jury_verdict
capture rename quantitybench_verdict bench_verdict
capture rename quantityguilty_plea guilty_plea
capture rename quantityguilty_plea_adm guilty_plea_adm
capture rename quantityfelony_plea_dc felony_plea_dc

* Ensure all columns exist
foreach v in jury_verdict bench_verdict guilty_plea guilty_plea_adm felony_plea_dc {
    capture confirm variable `v'
    if _rc {
        gen `v' = 0
    }
    else {
        replace `v' = 0 if missing(`v')
    }
}

* --- Court-level save ---
preserve
    collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm felony_plea_dc, ///
        by(county court_code year)

    * Plea: combine all plea types at district level
    gen plea_total = guilty_plea + guilty_plea_adm + felony_plea_dc
    gen jury_only = jury_verdict
    gen trial_total = jury_verdict + bench_verdict
    gen resolved_total = plea_total + trial_total
    gen plea_share = plea_total / resolved_total if resolved_total > 0
    gen jury_share = jury_only / resolved_total if resolved_total > 0
    * * gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform
    * * gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform  // REMOVED: too many zeros for log transform
    egen court_id = group(court_code county)

    compress
    save "$DATA_INT/mi_plea_composition_distfelony_court.dta", replace
    di as result "Saved COURT-LEVEL: mi_plea_composition_distfelony_court.dta (" _N " obs)"
restore

* --- County-level collapse ---
collapse (sum) jury_verdict bench_verdict guilty_plea guilty_plea_adm felony_plea_dc, ///
    by(county year)

di "After county-year collapse: " _N " obs"

gen plea_total = guilty_plea + guilty_plea_adm + felony_plea_dc
gen jury_only = jury_verdict
gen trial_total = jury_verdict + bench_verdict
gen resolved_total = plea_total + trial_total

gen plea_share = plea_total / resolved_total if resolved_total > 0
gen trial_share = trial_total / resolved_total if resolved_total > 0
gen jury_share = jury_only / resolved_total if resolved_total > 0

* gen log_jury_only = ln(jury_only + 1)  // REMOVED: too many zeros for log transform
* gen log_plea_total = ln(plea_total + 1)  // REMOVED: too many zeros for log transform

sort county year
encode county, gen(county_enc)
xtset county_enc year
gen plea_share_lead1 = F.plea_share
gen jury_only_lead1 = F.jury_only

* Validation
di _n "--- District felony plea composition ---"
tabstat plea_total trial_total jury_only resolved_total plea_share jury_share, ///
    stat(n mean sd min p50 max) columns(statistics) format(%12.3f)

qui distinct county
di _n "Unique counties: " r(ndistinct)

compress
save "$DATA_INT/mi_plea_composition_distfelony.dta", replace
di as result "Saved COUNTY-LEVEL: mi_plea_composition_distfelony.dta (" _N " obs)"


di _n "========================================"
di "  03c_plea_composition_build.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
