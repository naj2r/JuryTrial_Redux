/*==============================================================================
  05b_build_augmented_panel.do — Build Unified Augmented Panel

  Merges ALL data sources into a single regression-ready panel:
    1. michigan_panel_B.dta (from 05_merge_panels.do)
       - Pipeline variables: summoned through utilization_rate
       - Election treatment variables: treat_pros_pressure, open_pros, etc.
       - Population: county_pop
       - Merge key: county (string), year (numeric), county_id (numeric 1-83)
    2. mi_caseload_panel.dta (from 03b_caseload_build.do)
       - Caseload variables: incoming_felony, pending_felony, clearance_rate,
         outgoing_felony, log_incoming, log_pending, log_outgoing
       - Merge key: county (string), year (numeric)
       - N=1660 (83 counties x 20 years) — many unmatched rows expected
    3. caseload_verdict_panel.dta (from 03d_caseload_verdict_build.do)
       - FC/FH jury verdicts, bench verdicts, guilty pleas, dismissed counts
       - Derived rates: fc_jury_share, fc_dismiss_rate, severity_share, etc.
       - Adjudicated shares: fc_jury_adj_share, fc_plea_adj_share, etc.
       - Merge key: county_name (string), year (numeric)
       - N=569 — county_name must be renamed to match

  OUTPUT: $DATA_FINAL/michigan_panel_B_augmented.dta
    One file, all variables, ready for all tables in 14_paper_tables.do.

  PIPELINE POSITION: Run after 05_merge_panels.do and 03d_caseload_verdict_build.do
    master_build_all.do -> 01 -> 02 -> 03 -> 03b -> 03c -> 03d -> 04 -> 05 -> 05b -> 06 -> 07

  FC = Felony Capital (life-sentence-eligible). FH = Felony non-capital (other felonies).
  From SCAO case type codes.
==============================================================================*/

clear all
set more off

* --- Paths (set by paths.do then globals.do) ---
do "code/master/paths.do"
do "code/master/globals.do"

di _n "=============================================================="
di "  05b: Building Augmented Panel"
di "  $S_DATE $S_TIME"
di "=============================================================="


* ==========================================================================
* STEP 1: Load base panel
* ==========================================================================

use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Step 1: Base panel B loaded: " _N " obs, " c(k) " vars"
di "  Merge key: county (string) + year"

* Verify base panel structure
assert _N == 579
qui distinct county_id
assert r(ndistinct) == 83
qui tab year
di "  Years: " r(r)


* ==========================================================================
* STEP 2: Merge caseload variables (from 03b_caseload_build.do)
*   Source: mi_caseload_panel.dta (1660 obs, 83 counties x 20 years)
*   Merge key: county (string name) + year
*   Expected: many unmatched using-only rows (years outside 2016-2024)
* ==========================================================================

di _n "Step 2: Merging caseload variables..."

* Verify the caseload panel exists
capture confirm file "$DATA_INT/mi_caseload_panel.dta"
if _rc {
    di as error "ERROR: mi_caseload_panel.dta not found. Run 03b_caseload_build.do first."
    error 601
}

merge 1:1 county year using "$DATA_INT/mi_caseload_panel.dta", ///
    keep(master match) nogenerate

di "  After caseload merge: " _N " obs"

* Verify we didn't lose or gain observations
assert _N == 579

* Check caseload vars now exist
foreach v in incoming_felony pending_felony clearance_rate outgoing_felony {
    capture confirm variable `v'
    if _rc {
        di as error "  WARNING: `v' not found after caseload merge"
    }
    else {
        qui count if !missing(`v')
        di "  `v': " r(N) " non-missing of " _N
    }
}


* ==========================================================================
* STEP 3: Merge FC/FH disposition variables (from 03d_caseload_verdict_build.do)
*   Source: caseload_verdict_panel.dta (569 obs)
*   Merge key: county_name (string) + year — must rename to match
*   Expected: some unmatched if verdict panel has different coverage
* ==========================================================================

di _n "Step 3: Merging FC/FH disposition variables..."

capture confirm file "$DATA_INT/caseload_verdict_panel.dta"
if _rc {
    di as error "ERROR: caseload_verdict_panel.dta not found. Run 03d_caseload_verdict_build.do first."
    error 601
}

* The verdict panel uses county_name; the base panel uses county.
* Rename in the using dataset at merge time by preparing a tempfile.
preserve
    use "$DATA_INT/caseload_verdict_panel.dta", clear
    rename county_name county
    tempfile verdict_ready
    save `verdict_ready'
restore

merge 1:1 county year using `verdict_ready', ///
    keep(master match) nogenerate

di "  After verdict merge: " _N " obs"
assert _N == 579

* Check key disposition vars exist
foreach v in fc_jury fh_jury fc_plea fh_plea fc_dismissed fh_dismissed ///
             fc_jury_share fh_jury_share fc_dismiss_rate fh_dismiss_rate ///
             severity_share fc_jury_adj_share fc_plea_adj_share {
    capture confirm variable `v'
    if _rc {
        di as error "  WARNING: `v' not found after verdict merge"
    }
    else {
        qui count if !missing(`v')
        di "  `v': " r(N) " non-missing of " _N
    }
}


* ==========================================================================
* STEP 3b: Drop deprecated jury dashboard verdict variables
*   These came from the base panel but are UNRELIABLE for 2024:
*   Power BI uses MIN() aggregation for capital_felony (reports 3 statewide
*   vs 431 in the caseload data). All verdict/plea/dismissal analysis should
*   use the caseload-sourced variables (fc_jury, fh_jury, etc.) instead.
*   Dropping prevents accidental use of the broken variables.
* ==========================================================================

di _n "Step 3b: Dropping deprecated jury dashboard verdict variables..."

local deprecated_vars "total_jury_verdicts capital_felony other_felony other_cases"
local deprecated_vars "`deprecated_vars' pct_capital_felony pct_other_felony pct_other_cases"
* Also drop per-10k versions if they exist
local deprecated_vars "`deprecated_vars' total_jury_verdicts_p10k capital_felony_p10k other_felony_p10k other_cases_p10k"

foreach v of local deprecated_vars {
    capture drop `v'
    if !_rc di "  Dropped: `v'"
}

di "  Use fc_jury, fh_jury, fc_plea, fc_dismissed, etc. (caseload-sourced) instead."


* ==========================================================================
* STEP 4: Create elec_incumbent alias
* ==========================================================================

di _n "Step 4: Creating elec_incumbent alias..."

capture drop elec_incumbent
clonevar elec_incumbent = treat_pros_pressure
label variable elec_incumbent "Incumbent running for re-election (= treat_pros_pressure)"

* Verify mutual exclusivity
assert elec_incumbent + open_pros <= 1 if !missing(elec_incumbent) & !missing(open_pros)
di "  elec_incumbent + open_pros <= 1 confirmed (mutually exclusive)"


* ==========================================================================
* STEP 5: Final verification
* ==========================================================================

di _n "Step 5: Final verification..."

* Required variables — grouped by source
local vars_pipeline "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"
local vars_rates "pct_told_to_report pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate"
local vars_election "treat_pros_pressure open_pros treat_pros_contested_long treat_pros_uncontested is_election_year_pros elec_incumbent"
local vars_caseload "incoming_felony pending_felony clearance_rate outgoing_felony"
local vars_disposition "fc_jury fh_jury fc_plea fh_plea fc_dismissed fh_dismissed"
local vars_disp_rates "fc_jury_share fh_jury_share fc_dismiss_rate fh_dismiss_rate fc_plea_share fh_plea_share severity_share"
local vars_adj "fc_jury_adj_share fc_plea_adj_share"
local vars_other "county_id county year county_pop"

local all_required "`vars_pipeline' `vars_rates' `vars_election' `vars_caseload' `vars_disposition' `vars_disp_rates' `vars_adj' `vars_other'"

local missing_count = 0
local present_count = 0
foreach v of local all_required {
    capture confirm variable `v'
    if _rc {
        di as error "  MISSING: `v'"
        local missing_count = `missing_count' + 1
    }
    else {
        local present_count = `present_count' + 1
    }
}

di _n "  Variables: `present_count' present, `missing_count' missing"
if `missing_count' > 0 {
    di as error "  WARNING: `missing_count' required variables are missing."
    di as error "  Check pipeline: 03b (caseload), 03d (verdict), 05 (merge)."
}
else {
    di as text "  All required variables confirmed present."
}

* Panel structure check
di _n "--- Panel structure ---"
qui distinct county_id
di "  Counties: " r(ndistinct)
qui tab year
di "  Years: " r(r)
di "  Total obs: " _N


* ==========================================================================
* STEP 6: Save
* ==========================================================================

compress
label data "MI panel B augmented — pipeline + caseload + FC/FH disposition"
save "$DATA_FINAL/michigan_panel_B_augmented.dta", replace

di _n "=============================================================="
di "  Augmented panel saved: " _N " obs, " c(k) " vars"
di "  Path: $DATA_FINAL/michigan_panel_B_augmented.dta"
di "  Sources: michigan_panel_B + mi_caseload_panel + caseload_verdict_panel"
di "=============================================================="
