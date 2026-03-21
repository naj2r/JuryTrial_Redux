/*==============================================================================
  03b_caseload_build.do

  Purpose:  Import SCAO caseload CSVs (incoming + pending), filter to circuit
            court felonies (FC + FH), reshape wide→long, collapse to county-year
            panel, and generate variables for caseload robustness analysis.

  Input:    $DATA_RAW/scao_caseload/incoming_caseload.csv
            $DATA_RAW/scao_caseload/pending_caseload.csv

  Output:   $DATA_INT/mi_caseload_panel.dta  (county × year, ~1,660 obs)

  Design notes:
    - Circuit courts only (code starts with "C") — maps to prosecutor jurisdiction
    - FC (Capital Felonies) + FH (Non-capital Felonies) — trial-eligible cases
    - Multi-county circuits have separate rows per county in CSV (no double-counting)
    - Pending is a CONTEMPORANEOUS control (stock variable, evolves gradually)
    - See plan file for identification triangle justification

  Requires: paths.do must be run first.
            OR: cd to results_rebuild/ and run this file directly (auto-bootstraps).
==============================================================================*/

* --- Bootstrap: allow standalone execution ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

di as text _newline "========================================"
di as text "  03b_caseload_build.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* #############################################################################
* STEP 1: IMPORT AND CLEAN INCOMING CASELOAD
* #############################################################################
di _n "{hline 72}"
di "STEP 1: IMPORT INCOMING CASELOAD"
di "{hline 72}"

import delimited "$DATA_RAW/scao_caseload/incoming_caseload.csv", ///
    clear varnames(1) encoding("UTF-8")

di "Imported incoming_caseload: " _N " rows"

* Check variable names assigned by Stata
describe, short

* Rename columns for clarity
* Stata names: county, courtcode, casetypewithname, v2006-v2025
rename courtcode court_code
rename casetypewithname case_type

* --- Filter circuit courts only (code starts with "C") ---
gen byte is_circuit = (substr(court_code, 1, 1) == "C")
tab is_circuit
keep if is_circuit == 1
drop is_circuit
di "After circuit-court filter: " _N " rows"

* --- Filter felony case types: FC (Capital) + FH (Non-capital) ---
gen byte is_felony = (regexm(case_type, "^FC ") | regexm(case_type, "^FH "))
tab case_type if is_felony == 1
keep if is_felony == 1
drop is_felony
di "After felony filter (FC + FH): " _N " rows"

* --- Rename year columns ---
* Stata's import delimited names columns v4-v23 (positional) when CSV headers
* start with digits. Labels contain actual years. Rename: v4=2006 ... v23=2025.
local col = 4
forvalues y = 2006/2025 {
    capture confirm string variable v`col'
    if !_rc {
        destring v`col', replace force
    }
    replace v`col' = 0 if missing(v`col')
    rename v`col' incoming`y'
    local col = `col' + 1
}

* --- Reshape wide → long ---
reshape long incoming, i(county court_code case_type) j(year)
di "After reshape: " _N " obs (should be rows × 20 years)"

* --- Collapse to county-year (sum FC + FH across case types and courts) ---
collapse (sum) incoming_felony = incoming, by(county year)
di "After collapse to county-year: " _N " obs"

* Report summary
di _n "--- Incoming felony caseload summary ---"
sum incoming_felony, detail
qui distinct county
di "Unique counties: " r(ndistinct)
tab year

* Save tempfile for merge
tempfile incoming_temp
save `incoming_temp'


* #############################################################################
* STEP 2: IMPORT AND CLEAN PENDING CASELOAD
* #############################################################################
di _n "{hline 72}"
di "STEP 2: IMPORT PENDING CASELOAD"
di "{hline 72}"

import delimited "$DATA_RAW/scao_caseload/pending_caseload.csv", ///
    clear varnames(1) encoding("UTF-8")

di "Imported pending_caseload: " _N " rows"

* Rename columns
rename courtcode court_code
rename casetypewithname case_type

* --- Drop "Total" column (exists only in pending, not incoming) ---
* Pending CSV has 24 columns; column 24 (v24) is "Total"
capture drop v24
capture drop total

* --- Filter circuit courts ---
gen byte is_circuit = (substr(court_code, 1, 1) == "C")
keep if is_circuit == 1
drop is_circuit
di "After circuit-court filter: " _N " rows"

* --- Filter felony case types ---
gen byte is_felony = (regexm(case_type, "^FC ") | regexm(case_type, "^FH "))
keep if is_felony == 1
drop is_felony
di "After felony filter (FC + FH): " _N " rows"

* --- Rename year columns (same positional naming: v4=2006 ... v23=2025) ---
local col = 4
forvalues y = 2006/2025 {
    capture confirm string variable v`col'
    if !_rc {
        destring v`col', replace force
    }
    replace v`col' = 0 if missing(v`col')
    rename v`col' pending`y'
    local col = `col' + 1
}

* --- Reshape wide → long ---
reshape long pending, i(county court_code case_type) j(year)

* --- Collapse to county-year ---
collapse (sum) pending_felony = pending, by(county year)
di "After collapse to county-year: " _N " obs"

* Report summary
di _n "--- Pending felony caseload summary ---"
sum pending_felony, detail
qui distinct county
di "Unique counties: " r(ndistinct)


* #############################################################################
* STEP 3: MERGE INCOMING + PENDING
* #############################################################################
di _n "{hline 72}"
di "STEP 3: MERGE INCOMING AND PENDING"
di "{hline 72}"

merge 1:1 county year using `incoming_temp'

* Diagnostic: should be all matched
tab _merge
qui count if _merge != 3
if r(N) > 0 {
    di as error "WARNING: " r(N) " non-matched observations in incoming/pending merge"
    list county year _merge if _merge != 3
}
else {
    di as result "MERGE: Perfect 1:1 match — all " _N " obs matched"
}
drop _merge


* #############################################################################
* STEP 4: GENERATE DERIVED VARIABLES
* #############################################################################
di _n "{hline 72}"
di "STEP 4: GENERATE DERIVED VARIABLES"
di "{hline 72}"

* --- Panel setup ---
sort county year
encode county, gen(county_enc)
xtset county_enc year

* --- Log transformations (add 1 for zeros) ---
gen log_incoming = ln(incoming_felony + 1)
gen log_pending  = ln(pending_felony + 1)

* --- Lag of incoming (t-1: placebo/pre-trends test) ---
gen incoming_felony_lag1 = L.incoming_felony

* --- Derive outgoing via stock-flow identity ---
* Accounting identity: pending_t = pending_{t-1} + incoming_t - outgoing_t
* Therefore: outgoing_t = pending_{t-1} + incoming_t - pending_t
* This gives year-specific outgoing for 2007+ (need pending_{t-1})
gen pending_lag1 = L.pending_felony
gen outgoing_felony = pending_lag1 + incoming_felony - pending_felony

* Clearance rate = outgoing / incoming (undefined when incoming = 0)
gen clearance_rate = outgoing_felony / incoming_felony if incoming_felony > 0

* Lead of clearance rate (t+1: does pressure today predict clearing tomorrow?)
gen clearance_rate_lead1 = F.clearance_rate

* --- COVID YEAR CONTAMINATION HANDLING ---
* The jury panel excludes 2020-2021, but lag/lead operators pull FROM those years.
* Criminal justice research documents substantial crime and court processing
* changes during COVID lockdowns. Both incoming filings and case resolution
* were disrupted — incoming due to policing/charging changes, outgoing due to
* court shutdowns. ALL caseload variables for 2020-2021 are contaminated.
*
* Policy: null ALL derived variables for 2020-2021, then regenerate leads/lags
* so that any variable that SOURCES from a COVID year is also nulled.
*   - All caseload variables for 2020, 2021: null
*   - incoming_felony_lag1 for 2022: pulls from 2021 → null
*   - clearance_rate_lead1 for 2019: pulls from 2020 → null

di _n "--- COVID contamination handling ---"
di "  Nulling ALL caseload-derived variables for 2020-2021"
foreach v in clearance_rate outgoing_felony {
    qui count if (`v' != . & (year == 2020 | year == 2021))
    di "    `v': " r(N) " obs nulled"
    replace `v' = . if year == 2020 | year == 2021
}

* Regenerate lag/lead AFTER nulling COVID years
* This ensures anything that sources from 2020-2021 is missing
drop incoming_felony_lag1 clearance_rate_lead1
gen incoming_felony_lag1 = L.incoming_felony
* Null incoming_lag1 for 2022 (sources from 2021 COVID year)
replace incoming_felony_lag1 = . if year == 2022
gen clearance_rate_lead1 = F.clearance_rate
* 2019's lead is now missing (sources from nulled 2020)

qui count if incoming_felony_lag1 != . & year == 2022
di "  incoming_felony_lag1 for 2022 (should be 0 — COVID source): " r(N)
qui count if clearance_rate_lead1 != . & year == 2019
di "  clearance_rate_lead1 for 2019 (should be 0 — COVID source): " r(N)

* --- Log outgoing (must come after COVID nulling) ---
gen log_outgoing = ln(outgoing_felony + 1) if outgoing_felony >= 0

* --- First-differenced clearance rate ---
* FD removes level persistence, focuses on year-to-year changes.
* Robust to serial correlation concerns that afflict FE with persistent stocks.
* D. operator respects the nulled COVID years (produces missing across the gap)
gen d_clearance_rate = D.clearance_rate
gen d_clearance_rate_lead1 = F.d_clearance_rate
label variable d_clearance_rate      "First-differenced clearance rate"
label variable d_clearance_rate_lead1 "First-differenced clearance rate, t+1 (lead)"

* --- Variable labels ---
label variable incoming_felony       "Incoming felony cases (FC+FH, circuit courts)"
label variable pending_felony        "Pending felony cases (FC+FH, circuit courts)"
label variable log_incoming          "ln(incoming felony + 1)"
label variable log_pending           "ln(pending felony + 1)"
label variable incoming_felony_lag1  "Incoming felony cases, t-1 (lag)"
label variable outgoing_felony       "Outgoing felony cases (derived: pending_{t-1} + incoming - pending)"
label variable clearance_rate        "Clearance rate = outgoing / incoming"
label variable clearance_rate_lead1  "Clearance rate, t+1 (lead)"
label variable log_outgoing          "ln(outgoing felony + 1)"

* Report zero counts and derived variable diagnostics
qui count if incoming_felony == 0
di _n "County-years with zero incoming felony: " r(N) " of " _N
qui count if pending_felony == 0
di "County-years with zero pending felony: " r(N) " of " _N
qui count if outgoing_felony < 0 & !missing(outgoing_felony)
di "County-years with NEGATIVE outgoing (stock-flow anomaly): " r(N) " of " _N
qui sum clearance_rate, detail
di "Clearance rate: mean=" %6.3f r(mean) " median=" %6.3f r(p50) " N=" r(N)


* #############################################################################
* STEP 5: VALIDATION
* #############################################################################
di _n "{hline 72}"
di "STEP 5: VALIDATION"
di "{hline 72}"

* --- Check panel structure ---
qui distinct county
local n_counties = r(ndistinct)
di "Unique counties: `n_counties'"
qui distinct year
local n_years = r(ndistinct)
di "Unique years: `n_years'"
di "Total obs: " _N " (expected: " `n_counties' * `n_years' ")"

* --- Verify balance ---
qui xtdescribe
di "Panel balance check: see xtdescribe output above"

* --- Year range check ---
qui sum year
di "Year range: " r(min) " to " r(max)
assert r(min) == 2006
assert r(max) == 2025

* --- Summary statistics table ---
di _n "--- Full summary statistics ---"
tabstat incoming_felony pending_felony, ///
    stat(n mean sd min p25 p50 p75 max) columns(statistics) format(%12.1f)

* --- County name cross-check against jury panel ---
* (Load jury panel county names, compare)
preserve
    keep county
    duplicates drop
    sort county
    tempfile caseload_counties
    save `caseload_counties'

    * Load jury panel county names
    use "$DATA_FINAL/michigan_panel_B.dta", clear
    keep county
    duplicates drop
    sort county
    tempfile jury_counties
    save `jury_counties'

    * Merge to check overlap
    use `caseload_counties', clear
    merge 1:1 county using `jury_counties'
    tab _merge

    * Report
    qui count if _merge == 1
    local only_caseload = r(N)
    qui count if _merge == 2
    local only_jury = r(N)
    qui count if _merge == 3
    local matched = r(N)

    di _n "--- County name cross-check ---"
    di "Matched (in both):      `matched'"
    di "Only in caseload:       `only_caseload'"
    di "Only in jury panel:     `only_jury'"

    if `only_jury' > 0 {
        di as error "WARNING: Jury panel counties not found in caseload data:"
        list county if _merge == 2
    }
    if `only_caseload' > 0 {
        di "NOTE: Caseload counties not in jury panel (extra counties):"
        list county if _merge == 1
    }
restore


* #############################################################################
* STEP 6: SAVE
* #############################################################################
di _n "{hline 72}"
di "STEP 6: SAVE"
di "{hline 72}"

compress
save "$DATA_INT/mi_caseload_panel.dta", replace
di as result "Saved: $DATA_INT/mi_caseload_panel.dta"
di "Observations: " _N
di "Variables: " c(k)

di _n "========================================"
di "  03b_caseload_build.do COMPLETE"
di "  Date: $S_DATE  Time: $S_TIME"
di "========================================"
