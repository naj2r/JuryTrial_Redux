/*==============================================================================
  03_classify_and_aggregate.do

  Purpose:  Classify courts into 3 categories, map courts to counties,
            and build 3 county-year aggregation variants.

  Input:    $DATA_INT/court_utilization.dta  (1,213 court-year obs)
            $DATA_INT/court_jury_selection.dta (for county mapping crosswalk)

  Output:   $DATA_INT/court_classified.dta       (all courts with category + county)
            $DATA_INT/county_year_A.dta           (felony-only, ~579 obs, 83 counties)
            $DATA_INT/county_year_B.dta           (all-courts expanded, ~579 obs)
            $DATA_INT/county_year_C.dta           (combined-only, ~307 obs, 44 counties)

  Adapted from: MI_datascrape_2_2-20-26/scripts/build_3_variants_and_regress.do (Steps 1-4)
  NOTE: Regressions are NOT included here -- they live in a separate do-file.
  Requires: paths.do must be run first; 02_import_jury_data.do must have run.
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
di as text "  03_classify_and_aggregate.do"
di as text "========================================"


* #############################################################################
* STEP 1: LOAD + CLASSIFY COURTS
* #############################################################################
di _n "{hline 72}"
di "STEP 1: LOAD AND CLASSIFY COURTS"
di "{hline 72}"

* --- Load court-level utilization ---
use "$DATA_INT/court_utilization.dta", clear
di "Loaded court-level utilization: " _N " court-year obs"


* --- RECOVER MISSING SUMMONED VALUES ---
* The Power BI API returns null for `summoned` in 2 court-years (D64A-Ionia
* 2016, D79-Oceana 2023) but correctly returns pct_told_to_report AND
* told_to_report for those same records. Since pct = told / summoned, we
* algebraically recover: summoned = told / pct.
*
* This is NOT estimation or interpolation — it is solving a deterministic
* identity using values the API itself provided. The API computes the rate
* from the correct summoned value internally; it simply does not project
* the raw count in its response.
*
* Verification: recovered values match SCAO web interface (420 and 375)
* and are exact integers after rounding, confirming no precision loss.
*
* Added: 2026-03-01 after rescrape confirmed API returns identical nulls.

* Preserve original for audit trail
gen summoned_original = summoned

* Back-calculate: summoned = told_to_report / pct_told_to_report
* (pct_told_to_report here is the API-provided rate, NOT our computed rate)
gen summoned_recovered = round(told_to_report / pct_told_to_report) ///
    if missing(summoned) & !missing(pct_told_to_report) & pct_told_to_report > 0 ///
       & !missing(told_to_report)

* Flag which records were recovered
gen byte summoned_was_recovered = (!missing(summoned_recovered) & missing(summoned))

* Apply recovery
replace summoned = summoned_recovered if summoned_was_recovered == 1

* Report
qui count if summoned_was_recovered == 1
di _n as result "SUMMONED RECOVERY: " r(N) " court-years recovered via back-calculation"
if r(N) > 0 {
    list court_name year summoned_original summoned pct_told_to_report told_to_report ///
        if summoned_was_recovered == 1, noobs
    * Consistency check: recovered summoned should reproduce the API rate
    gen _check_rate = told_to_report / summoned if summoned_was_recovered == 1
    gen _rate_diff = abs(pct_told_to_report - _check_rate) if summoned_was_recovered == 1
    assert _rate_diff < 0.001 if summoned_was_recovered == 1
    di as result "  Consistency check PASSED: recovered values reproduce API rates within 0.001"
    drop _check_rate _rate_diff
}
drop summoned_recovered


* --- Classify court categories ---
* Three categories:
*   COMBINED         = "Circuit/Probate & District" in comparison_group
*   STANDALONE_CP    = "Circuit/Probate -" in comparison_group (no "District")
*   DISTRICT_OR_3RD  = "District -" or "Third-Class District" in comparison_group
gen court_category = ""
replace court_category = "COMBINED"        if regexm(comparison_group, "Circuit/Probate & District")
replace court_category = "STANDALONE_CP"   if regexm(comparison_group, "^Circuit/Probate -")
replace court_category = "DISTRICT_OR_3RD" if regexm(comparison_group, "^District -") | regexm(comparison_group, "^Third-Class District")

* Audit check: every row should be classified
assert court_category != ""
di "AUDIT CHECK 1: All " _N " rows classified. Pass."

* Frequency table
di _n "--- Frequency: court_category x year ---"
tab court_category year


* #############################################################################
* STEP 2: COUNTY MAPPING
* #############################################################################
di _n "{hline 72}"
di "STEP 2: COUNTY MAPPING"
di "{hline 72}"

* --- Check existing county field ---
gen has_county_orig = (county != "NA" & county != "" & !missing(county))
tab court_category has_county_orig

di _n "COMBINED and STANDALONE_CP have county. DISTRICT_OR_3RD = NA."

* --- Build crosswalk from jury selection file ---
* The jury selection file has county_group for ALL courts, including District.
preserve
use "$DATA_INT/court_jury_selection.dta", clear
* Get unique court_name -> county_group pairs
gen county_from_jurysel = regexr(county_group, " County$", "")
keep court_name county_from_jurysel
duplicates drop
* If a court_name maps to multiple counties (shouldn't happen), keep first
bysort court_name: keep if _n == 1
save "$DATA_INT/_temp/xwalk_jurysel.dta", replace
restore

* --- Merge crosswalk into court-level data ---
merge m:1 court_name using "$DATA_INT/_temp/xwalk_jurysel.dta", keep(master match)
tab _merge court_category

* --- Build county_mapped ---
* Priority: existing county if present; else jury selection mapping
gen county_mapped = county if has_county_orig == 1
* Clean multi-county names (e.g., "Ionia & Ionia" -> "Ionia")
replace county_mapped = regexr(county_mapped, " & .*$", "")
* For unmapped courts, use jury selection crosswalk
replace county_mapped = county_from_jurysel if has_county_orig == 0 & county_from_jurysel != ""

* Track mapping method
gen mapping_method = ""
replace mapping_method = "original_county_field" if has_county_orig == 1
replace mapping_method = "jury_selection_crosswalk" if has_county_orig == 0 & county_from_jurysel != ""
replace mapping_method = "UNMAPPED" if county_mapped == "" | county_mapped == "NA"

di _n "--- Mapping method distribution ---"
tab mapping_method court_category

* How many are still unmapped?
gen is_unmapped = (mapping_method == "UNMAPPED")
tab is_unmapped

drop _merge

* --- Save full classified court-level data ---
save "$DATA_INT/court_classified.dta", replace
di "Saved: $DATA_INT/court_classified.dta (" _N " obs)"


* #############################################################################
* STEP 3: BUILD 3 AGGREGATION VARIANTS
* #############################################################################
di _n "{hline 72}"
di "STEP 3: BUILD 3 COUNTY-YEAR AGGREGATION VARIANTS"
di "{hline 72}"

* =====================================================================
* VARIANT A: Felony-only county series
* =====================================================================
* Rules: Use STANDALONE_CP rows only.
*        For counties that only have COMBINED rows, include COMBINED
*        but flag as mixed_reporting=1.
* =====================================================================
di _n "=== VARIANT A: Felony-only ==="

use "$DATA_INT/court_classified.dta", clear

* Identify which counties have STANDALONE_CP in any year
gen _is_standalone = (court_category == "STANDALONE_CP")
bysort county_mapped year: egen has_standalone = max(_is_standalone)
drop _is_standalone

* For Variant A:
* If county-year has STANDALONE_CP -> use only STANDALONE_CP rows
* If county-year has NO STANDALONE_CP -> use COMBINED rows, flag mixed_reporting=1
gen keep_for_A = 0
replace keep_for_A = 1 if court_category == "STANDALONE_CP"
replace keep_for_A = 1 if court_category == "COMBINED" & has_standalone == 0

* Never include standalone District courts in Variant A (not felony-relevant)
keep if keep_for_A == 1

* Flag mixed reporting
gen mixed_reporting = (court_category == "COMBINED")

di "Variant A rows before aggregation: " _N
tab court_category mixed_reporting

* Aggregate to county-year
* AGGREGATION RULES:
* Counts: SUM across courts
* Rates: RECOMPUTE from summed counts (NOT averaged)
* Missing: treat NA as 0 for counts
gen one = 1
collapse (sum) summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    capital_felony other_felony other_cases ///
    (max) mixed_reporting ///
    (sum) n_courts = one, ///
    by(county_mapped year)

* Recompute rates from summed counts
gen pct_told_to_report = told_to_report / summoned if summoned > 0
gen pct_actually_reported = actually_reported / told_to_report if told_to_report > 0
gen pct_sent_to_courtroom = sent_to_courtroom / actually_reported if actually_reported > 0
gen pct_questioned_in_voir_dire = questioned_in_voir_dire / sent_to_courtroom if sent_to_courtroom > 0
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

* --- Top-code rates at theoretical bound (1.0) ---
* Timing mismatches in SCAO fiscal-year reporting can produce rates > 1
* in small counties. See Appendix B (Table B.5) and Data section for discussion.
foreach v in pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire {
    qui count if `v' > 1 & !missing(`v')
    if r(N) > 0 {
        di as text "    [Variant A] Top-coding " r(N) " obs of `v' at 1.0"
        replace `v' = 1.0 if `v' > 1 & !missing(`v')
    }
}
* Recompute utilization_rate from top-coded inputs
drop utilization_rate
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

gen total_jury_verdicts = capital_felony + other_felony + other_cases

* Verdict composition shares (conditional on positive verdicts)
* DV: share of each verdict type in total verdicts
* Denominator: published total (ID 14) per prebuild spec
* Undefined when total_jury_verdicts == 0 (composition requires >0 verdicts)
gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0

gen variant = "A"
rename county_mapped county

di "Variant A: " _N " county-year obs"
tab year
codebook county, compact

save "$DATA_INT/county_year_A.dta", replace
di "Saved: $DATA_INT/county_year_A.dta"

* =====================================================================
* VARIANT B: Expanded all-courts county series (no double counting)
* =====================================================================
* Rules:
* If county-year has COMBINED row -> use ONLY the combined row
* If county-year has NO COMBINED row -> sum STANDALONE_CP + mapped DISTRICT
* Never combine COMBINED + STANDALONE/DISTRICT for same county-year
* =====================================================================
di _n "=== VARIANT B: All courts expanded ==="

use "$DATA_INT/court_classified.dta", clear

* Drop unmapped courts
drop if mapping_method == "UNMAPPED"

* Identify whether county-year has a COMBINED row
gen _is_combined = (court_category == "COMBINED")
bysort county_mapped year: egen has_combined = max(_is_combined)
drop _is_combined

* Aggregation rule indicator
gen agg_rule = ""
replace agg_rule = "COMBINED_ONLY" if has_combined == 1 & court_category == "COMBINED"
replace agg_rule = "SUM_STANDALONE_DISTRICT" if has_combined == 0

* Keep only rows that should contribute
gen keep_for_B = 0
replace keep_for_B = 1 if has_combined == 1 & court_category == "COMBINED"
replace keep_for_B = 1 if has_combined == 0 & (court_category == "STANDALONE_CP" | court_category == "DISTRICT_OR_3RD")
keep if keep_for_B == 1

di "Variant B rows before aggregation: " _N
tab agg_rule court_category

* --- DOUBLE-COUNTING PROOF ---
* Assert: no county-year has BOTH a COMBINED row and a non-COMBINED row
gen is_comb_row = (court_category == "COMBINED")
bysort county_mapped year: egen has_comb_in_grp = max(is_comb_row)
bysort county_mapped year: egen has_noncomb_in_grp = min(is_comb_row)
* If has_comb_in_grp==1 and has_noncomb_in_grp==0, mix of COMBINED + non-COMBINED
gen double_count_flag = (has_comb_in_grp == 1 & has_noncomb_in_grp == 0)
count if double_count_flag == 1
di "Double-count violations: " r(N)
assert r(N) == 0
di "DOUBLE-COUNTING PROOF: No county-year mixes COMBINED + non-COMBINED. Pass."
drop is_comb_row has_comb_in_grp has_noncomb_in_grp double_count_flag

* Aggregate
gen one = 1
collapse (sum) summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    capital_felony other_felony other_cases ///
    (first) agg_rule ///
    (sum) n_courts = one, ///
    by(county_mapped year)

* Recompute rates
gen pct_told_to_report = told_to_report / summoned if summoned > 0
gen pct_actually_reported = actually_reported / told_to_report if told_to_report > 0
gen pct_sent_to_courtroom = sent_to_courtroom / actually_reported if actually_reported > 0
gen pct_questioned_in_voir_dire = questioned_in_voir_dire / sent_to_courtroom if sent_to_courtroom > 0
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

* --- Top-code rates at theoretical bound (1.0) ---
foreach v in pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire {
    qui count if `v' > 1 & !missing(`v')
    if r(N) > 0 {
        di as text "    [Variant B] Top-coding " r(N) " obs of `v' at 1.0"
        replace `v' = 1.0 if `v' > 1 & !missing(`v')
    }
}
drop utilization_rate
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

gen total_jury_verdicts = capital_felony + other_felony + other_cases

* Verdict composition shares (conditional on positive verdicts)
gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0

gen variant = "B"
rename county_mapped county

di "Variant B: " _N " county-year obs"
tab year
codebook county, compact

save "$DATA_INT/county_year_B.dta", replace
di "Saved: $DATA_INT/county_year_B.dta"

* =====================================================================
* VARIANT C: Combined-only county series
* =====================================================================
* Rules: Keep only COMBINED rows, mapped to county-year.
* =====================================================================
di _n "=== VARIANT C: Combined-only ==="

use "$DATA_INT/court_classified.dta", clear
keep if court_category == "COMBINED"

di "Variant C rows before aggregation: " _N

gen one = 1
collapse (sum) summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    capital_felony other_felony other_cases ///
    (sum) n_courts = one, ///
    by(county_mapped year)

gen pct_told_to_report = told_to_report / summoned if summoned > 0
gen pct_actually_reported = actually_reported / told_to_report if told_to_report > 0
gen pct_sent_to_courtroom = sent_to_courtroom / actually_reported if actually_reported > 0
gen pct_questioned_in_voir_dire = questioned_in_voir_dire / sent_to_courtroom if sent_to_courtroom > 0
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

* --- Top-code rates at theoretical bound (1.0) ---
foreach v in pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire {
    qui count if `v' > 1 & !missing(`v')
    if r(N) > 0 {
        di as text "    [Variant C] Top-coding " r(N) " obs of `v' at 1.0"
        replace `v' = 1.0 if `v' > 1 & !missing(`v')
    }
}
drop utilization_rate
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

gen total_jury_verdicts = capital_felony + other_felony + other_cases

* Verdict composition shares (conditional on positive verdicts)
gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0

gen variant = "C"
rename county_mapped county

di "Variant C: " _N " county-year obs"
tab year
codebook county, compact

save "$DATA_INT/county_year_C.dta", replace
di "Saved: $DATA_INT/county_year_C.dta"


* #############################################################################
* VARIANT D: All-courts county aggregate (Category B robustness)
*   Simple collapse: sum ALL mapped courts to county-year
*   No court selection rules — every court observation included.
*   May include minor overlap in counties with both COMBINED and standalone
*   courts. This is intentional — tests sensitivity to aggregation methodology.
* #############################################################################
di _n "{hline 72}"
di "VARIANT D: ALL-COURTS COUNTY AGGREGATE"
di "{hline 72}"

use "$DATA_INT/court_classified.dta", clear

* Keep only courts with valid county mapping
qui drop if county_mapped == "" | county_mapped == "UNMAPPED"
di "Courts with valid county mapping: " _N

* Collapse ALL courts to county-year
gen one = 1
collapse (sum) summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    capital_felony other_felony other_cases ///
    (sum) n_courts = one, ///
    by(county_mapped year)

* Recompute rates from summed counts (not averaged)
gen pct_told_to_report = told_to_report / summoned if summoned > 0
gen pct_actually_reported = actually_reported / told_to_report if told_to_report > 0
gen pct_sent_to_courtroom = sent_to_courtroom / actually_reported if actually_reported > 0
gen pct_questioned_in_voir_dire = questioned_in_voir_dire / sent_to_courtroom if sent_to_courtroom > 0
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

* Top-code rates at 1.0
foreach v in pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire {
    qui count if `v' > 1 & !missing(`v')
    if r(N) > 0 {
        di as text "    [Variant D] Top-coding " r(N) " obs of `v' at 1.0"
        replace `v' = 1.0 if `v' > 1 & !missing(`v')
    }
}
drop utilization_rate
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

gen total_jury_verdicts = capital_felony + other_felony + other_cases

* Verdict composition shares (conditional on positive verdicts)
gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0

gen variant = "D"
rename county_mapped county

di "Variant D: " _N " county-year obs"
tab year
codebook county, compact

save "$DATA_INT/county_year_D.dta", replace
di "Saved: $DATA_INT/county_year_D.dta"


* #############################################################################
* VARIANT E: Circuit-court-only county aggregate (Category C robustness)
*   Only STANDALONE_CP courts (dedicated circuit/probate courts).
*   These map 1:1 to counties — no aggregation ambiguity.
*   Counties without a standalone circuit court are excluded.
* #############################################################################
di _n "{hline 72}"
di "VARIANT E: CIRCUIT-COURT-ONLY COUNTY AGGREGATE"
di "{hline 72}"

use "$DATA_INT/court_classified.dta", clear

* Keep only standalone circuit/probate courts
qui keep if court_category == "STANDALONE_CP"
qui drop if county_mapped == "" | county_mapped == "UNMAPPED"
di "Standalone CP courts with valid county mapping: " _N

* Collapse to county-year
gen one = 1
collapse (sum) summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    capital_felony other_felony other_cases ///
    (sum) n_courts = one, ///
    by(county_mapped year)

* Recompute rates from summed counts
gen pct_told_to_report = told_to_report / summoned if summoned > 0
gen pct_actually_reported = actually_reported / told_to_report if told_to_report > 0
gen pct_sent_to_courtroom = sent_to_courtroom / actually_reported if actually_reported > 0
gen pct_questioned_in_voir_dire = questioned_in_voir_dire / sent_to_courtroom if sent_to_courtroom > 0
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

* Top-code rates at 1.0
foreach v in pct_told_to_report pct_actually_reported pct_sent_to_courtroom ///
    pct_questioned_in_voir_dire {
    qui count if `v' > 1 & !missing(`v')
    if r(N) > 0 {
        di as text "    [Variant E] Top-coding " r(N) " obs of `v' at 1.0"
        replace `v' = 1.0 if `v' > 1 & !missing(`v')
    }
}
drop utilization_rate
gen utilization_rate = pct_told_to_report * pct_sent_to_courtroom * pct_questioned_in_voir_dire ///
    if !missing(pct_told_to_report) & !missing(pct_sent_to_courtroom) & !missing(pct_questioned_in_voir_dire)

gen total_jury_verdicts = capital_felony + other_felony + other_cases

* Verdict composition shares (conditional on positive verdicts)
gen pct_capital_felony = capital_felony / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_felony   = other_felony   / total_jury_verdicts if total_jury_verdicts > 0
gen pct_other_cases    = other_cases    / total_jury_verdicts if total_jury_verdicts > 0

gen variant = "E"
rename county_mapped county

di "Variant E: " _N " county-year obs"
tab year
codebook county, compact

save "$DATA_INT/county_year_E.dta", replace
di "Saved: $DATA_INT/county_year_E.dta"


* #############################################################################
* DIAGNOSTICS
* #############################################################################
di _n "{hline 72}"
di "DIAGNOSTICS"
di "{hline 72}"

* --- Volume comparison ---
di _n "=== Volume comparison across variants ==="

di _n "VARIANT A totals:"
use "$DATA_INT/county_year_A.dta", clear
tabstat summoned capital_felony other_felony other_cases total_jury_verdicts, stat(sum) format(%15.0fc)

di _n "VARIANT B totals:"
use "$DATA_INT/county_year_B.dta", clear
tabstat summoned capital_felony other_felony other_cases total_jury_verdicts, stat(sum) format(%15.0fc)

di _n "VARIANT C totals:"
use "$DATA_INT/county_year_C.dta", clear
tabstat summoned capital_felony other_felony other_cases total_jury_verdicts, stat(sum) format(%15.0fc)

di _n "VARIANT D totals:"
use "$DATA_INT/county_year_D.dta", clear
tabstat summoned capital_felony other_felony other_cases total_jury_verdicts, stat(sum) format(%15.0fc)

di _n "VARIANT E totals:"
use "$DATA_INT/county_year_E.dta", clear
tabstat summoned capital_felony other_felony other_cases total_jury_verdicts, stat(sum) format(%15.0fc)

* Clean up temp files
capture erase "$DATA_INT/_temp/xwalk_jurysel.dta"

di _n "========================================"
di "  03_classify_and_aggregate.do COMPLETE"
di "========================================"
