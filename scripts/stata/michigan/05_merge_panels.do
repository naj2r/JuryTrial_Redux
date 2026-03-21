/*==============================================================================
  05_merge_panels.do

  Purpose:  Merge elections panel + population panel into each jury variant
            to create final regression-ready datasets.

  Input:    $DATA_INT/elections_panel.dta       (747 obs, district x year)
            $DATA_INT/county_pop_panel.dta      (747 obs, county x year)
            $DATA_INT/county_year_A.dta          (felony-only)
            $DATA_INT/county_year_B.dta          (all-courts expanded)
            $DATA_INT/county_year_C.dta          (combined-only)
            $DATA_INT/court_classified.dta       (court-level)

  Output:   $DATA_FINAL/michigan_panel_A.dta
            $DATA_FINAL/michigan_panel_B.dta
            $DATA_FINAL/michigan_panel_C.dta
            $DATA_FINAL/michigan_court_level.dta

  Merge keys:
    Elections: district + year  <->  Jury: county + year (bare county names)
    Population: county + year

  Requires: paths.do, 01-04 must have run.
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
di as text "  05_merge_panels.do"
di as text "========================================"


* --- Program to merge one county-level variant ---
capture program drop merge_variant
program define merge_variant
    syntax, variant(string) datafile(string) outfile(string)

    di _n "{hline 60}"
    di "MERGING VARIANT `variant'"
    di "{hline 60}"

    use "`datafile'", clear
    di "Loaded jury data: " _N " obs"

    * --- Merge elections ---
    * Elections use `district`, jury data uses `county` -- same bare names
    rename county district
    merge m:1 district year using "$DATA_INT/elections_panel.dta", ///
        keepusing(treat_pros_pressure treat_pros_contested ///
        treat_pros_uncontested treat_pros_contested_long ///
        treat_pros_incumbent_electyear is_election_year_pros ///
        incumbent_pros open_pros contested_pros turnover_pros ///
        current_prosecutor current_party ///
        general_closeness primary_closeness max_closeness) ///
        nogen keep(match)
    rename district county

    di "After elections merge: " _N " obs"

    * --- Merge population ---
    merge m:1 county year using "$DATA_INT/county_pop_panel.dta", ///
        keepusing(county_pop county_fips) nogen keep(master match)

    di "After pop merge: " _N " obs"
    count if missing(county_pop)
    di "  Missing county_pop: " r(N)

    * --- Drop COVID years ---
    drop if year == 2020 | year == 2021
    di "After dropping 2020-2021: " _N " obs"

    * --- Encode county for FE ---
    encode county, gen(county_id)

    * --- Final checks ---
    tab year
    tab treat_pros_contested_long year

    * Decomposition check
    assert treat_pros_contested + treat_pros_uncontested == treat_pros_pressure

    * Open seat guard
    assert treat_pros_pressure == 0 if open_pros == 1

    * --- Save ---
    label data "MI panel variant `variant' -- regression-ready"
    compress
    save "`outfile'", replace

    di "Saved: `outfile' (" _N " obs)"
end


* --- Merge all 3 county-level variants ---

merge_variant, variant("A") ///
    datafile("$DATA_INT/county_year_A.dta") ///
    outfile("$DATA_FINAL/michigan_panel_A.dta")

merge_variant, variant("B") ///
    datafile("$DATA_INT/county_year_B.dta") ///
    outfile("$DATA_FINAL/michigan_panel_B.dta")

merge_variant, variant("C") ///
    datafile("$DATA_INT/county_year_C.dta") ///
    outfile("$DATA_FINAL/michigan_panel_C.dta")


* --- Court-level panel ---
di _n "{hline 60}"
di "MERGING COURT-LEVEL PANEL"
di "{hline 60}"

use "$DATA_INT/court_classified.dta", clear
di "Loaded court-level: " _N " obs"

* Drop unmapped courts
drop if mapping_method == "UNMAPPED"
di "After dropping unmapped: " _N " obs"

* --- Merge elections ---
* county_mapped is the county name for court-level data
gen district = county_mapped
merge m:1 district year using "$DATA_INT/elections_panel.dta", ///
    keepusing(treat_pros_pressure treat_pros_contested ///
    treat_pros_uncontested treat_pros_contested_long ///
    treat_pros_incumbent_electyear is_election_year_pros ///
    incumbent_pros open_pros contested_pros turnover_pros ///
    current_prosecutor current_party ///
    general_closeness primary_closeness max_closeness)
drop if _merge == 2
drop _merge
drop district

di "After elections merge: " _N " obs"

* --- Merge population ---
* Court-level has both `county` (may be NA for district courts) and `county_mapped`
* We merge by county_mapped
drop county
rename county_mapped county
merge m:1 county year using "$DATA_INT/county_pop_panel.dta", ///
    keepusing(county_pop county_fips)
drop if _merge == 2
drop _merge
rename county county_mapped

di "After pop merge: " _N " obs"
count if missing(county_pop)
di "  Missing county_pop: " r(N)

* --- Drop COVID years ---
drop if year == 2020 | year == 2021
di "After dropping 2020-2021: " _N " obs"

* --- Encode for FE ---
encode court_name, gen(court_id)
encode county_mapped, gen(county_id)

* --- Save ---
label data "MI court-level panel -- regression-ready"
compress
save "$DATA_FINAL/michigan_court_level.dta", replace

di "Saved: $DATA_FINAL/michigan_court_level.dta (" _N " obs)"


* =============================================================================
* VARIANT D: All-courts county aggregate (Category B robustness)
* =============================================================================
merge_variant, variant("D") ///
    datafile("$DATA_INT/county_year_D.dta") ///
    outfile("$DATA_FINAL/michigan_panel_D.dta")

* =============================================================================
* VARIANT E: Circuit-court-only county aggregate (Category C robustness)
* =============================================================================
merge_variant, variant("E") ///
    datafile("$DATA_INT/county_year_E.dta") ///
    outfile("$DATA_FINAL/michigan_panel_E.dta")


di _n "========================================"
di "  05_merge_panels.do COMPLETE"
di "========================================"
di "  $DATA_FINAL/michigan_panel_A.dta"
di "  $DATA_FINAL/michigan_panel_B.dta"
di "  $DATA_FINAL/michigan_panel_C.dta"
di "  $DATA_FINAL/michigan_panel_D.dta"
di "  $DATA_FINAL/michigan_panel_E.dta"
di "  $DATA_FINAL/michigan_court_level.dta"
