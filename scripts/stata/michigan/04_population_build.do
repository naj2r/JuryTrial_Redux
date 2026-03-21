/*==============================================================================
  04_population_build.do

  Purpose:  Build MI county-year population panel (2016-2024) from:
            (1) Census 1969-2023 data (filtered to MI, collapsed to county-year)
            (2) 2024 MI county population estimates (Excel)

  Input:    $CENSUS/CensusData1969_2023.dta  (17.1M rows -- filter to MI)
            $DATA_RAW/population/co-est2024-pop-26.xlsx

  Output:   $DATA_INT/county_pop_panel.dta   (83 counties x 9 years = 747 obs)
            $DATA_INT/county_fips_crosswalk.dta / .csv

  Adapted from: MI_datascrape_2_2-20-26/scripts/pop_scaled_regressions.do (Steps 1-4)
  NOTE: This file ONLY builds the population panel. It does NOT merge into
        jury variants or create per-10k outcomes (that happens in 05 and 06).
  Requires: paths.do must be run first.
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
di as text "  04_population_build.do"
di as text "========================================"


* =============================================================================
* STEP 1: Collapse Census data to MI county-year totals
* =============================================================================

di _n "===== STEP 1: Collapse Census to MI county-year totals ====="

use "$CENSUS/CensusData1969_2023.dta", clear

* Keep only Michigan (state_fips == "26") and years 2016-2023
keep if state_fips == "26"
keep if year >= 2016 & year <= 2023

di "MI obs after filtering: " _N

* Collapse to county-year total population (sum over race, origin, sex, age)
collapse (sum) population, by(year county_fips)

rename population county_pop

di "County-year obs after collapse: " _N
* Should be 83 counties x 8 years = 664

* Create a clean county FIPS with state prefix
gen fips5 = "26" + county_fips

* Verify
list year county_fips fips5 county_pop in 1/10, noobs

save "$DATA_INT/_temp/mi_county_pop_2016_2023.dta", replace


* =============================================================================
* STEP 2: Parse 2024 MI county population Excel
* =============================================================================

di _n "===== STEP 2: Parse 2024 MI county population Excel ====="

import excel "$DATA_RAW/population/co-est2024-pop-26.xlsx", clear

* Structure:
*   Rows 1-4: headers
*   Row 5: Michigan state total
*   Rows 6-88: ".County Name County, Michigan"
*   Column A = county name, G = 2024 population

* Drop header rows (first 5)
drop in 1/5

* Keep only A (county name) and G (2024 population)
keep A G

* Drop rows where A is empty or doesn't contain "County"
drop if missing(A)
drop if strpos(A, "County") == 0

* Parse county name: ".Alcona County, Michigan" -> "Alcona"
replace A = subinstr(A, ".", "", 1)
gen county = substr(A, 1, strpos(A, " County") - 1)
replace county = strtrim(county)

rename G county_pop
destring county_pop, replace force

gen year = 2024

di "2024 county obs: " _N
list county county_pop in 1/10, noobs

save "$DATA_INT/_temp/mi_pop_2024_raw.dta", replace


* =============================================================================
* STEP 3: Load authoritative county name <-> FIPS crosswalk
* =============================================================================

di _n "===== STEP 3: Load county name -> FIPS crosswalk ====="

* Load the authoritative reference crosswalk (83 MI counties).
* Source: U.S. Census Bureau FIPS codes for Michigan counties.
* This file was validated against Census data and the 2024 population Excel
* on 2026-03-19. It is stored in data_raw/ as a permanent reference rather
* than constructed on the fly, to avoid dependence on positional ordering
* assumptions. Michigan FIPS codes happen to follow alphabetical order, but
* the reference file approach is robust to any ordering.
*
* History: Originally built via alphabetical positional join (pre-2026-03-19).
* Replaced with static reference file for robustness after audit flagged
* fragility of the positional method.

import delimited "$DATA_RAW/mi_county_fips_reference.csv", clear varnames(1) ///
    stringcols(1)
* stringcols(1) forces county_fips to import as string "001", "003", etc.
* to match the Census data's string FIPS format
assert _N == 83

* Validate against 2024 county names (must be a perfect 1:1 match)
preserve
    tempfile ref_counties
    keep county
    sort county
    save `ref_counties'

    use "$DATA_INT/_temp/mi_pop_2024_raw.dta", clear
    keep county
    duplicates drop
    sort county
    merge 1:1 county using `ref_counties'
    qui count if _merge != 3
    if r(N) > 0 {
        di as error "ERROR: Reference crosswalk does not match 2024 county names!"
        tab _merge
        list county if _merge != 3
        error 9
    }
    else {
        di as result "CROSSWALK VALIDATION: All 83 county names match 2024 Excel. Pass."
    }
restore

* Validate against Census FIPS codes (must be a perfect 1:1 match)
preserve
    tempfile ref_fips
    keep county_fips
    sort county_fips
    save `ref_fips'

    use "$DATA_INT/_temp/mi_county_pop_2016_2023.dta", clear
    keep county_fips
    duplicates drop
    sort county_fips
    merge 1:1 county_fips using `ref_fips'
    qui count if _merge != 3
    if r(N) > 0 {
        di as error "ERROR: Reference crosswalk FIPS do not match Census data!"
        tab _merge
        list county_fips if _merge != 3
        error 9
    }
    else {
        di as result "CROSSWALK VALIDATION: All 83 FIPS codes match Census data. Pass."
    }
restore

* Verify known counties (spot check)
di _n "Verification (spot check):"
list county county_fips if county == "Wayne" | county == "Oakland" ///
    | county == "Kent" | county == "Washtenaw" | county == "Alcona", noobs

* Save crosswalk (overwrite with identical content — ensures .dta is current)
save "$DATA_INT/county_fips_crosswalk.dta", replace
export delimited "$DATA_INT/county_fips_crosswalk.csv", replace

di _n "County-FIPS crosswalk loaded and validated (" _N " counties)"


* =============================================================================
* STEP 4: Merge FIPS into 2024 data and append to census
* =============================================================================

di _n "===== STEP 4: Append 2024 pop to census data ====="

* Add FIPS to 2024 data
use "$DATA_INT/_temp/mi_pop_2024_raw.dta", clear
merge m:1 county using "$DATA_INT/county_fips_crosswalk.dta"
tab _merge
drop if _merge != 3
drop _merge A

* Keep matching structure
keep year county_fips county_pop county
gen fips5 = "26" + county_fips

* Append to census data
append using "$DATA_INT/_temp/mi_county_pop_2016_2023.dta"

* Now we have 2016-2024 population for all MI counties
tab year
sort county_fips year

* Add county names to the census years (2016-2023 only have FIPS)
merge m:1 county_fips using "$DATA_INT/county_fips_crosswalk.dta", ///
    update replace
tab _merge
drop _merge

sort county year
order year county county_fips fips5 county_pop

di _n "Final population panel:"
tab year
sum county_pop, detail

* Verify: Wayne County (largest) should be ~1.7-1.8M
di _n "Wayne County sanity check:"
list county county_pop if county == "Wayne", noobs

* Final assertion
assert _N == 747  // 83 counties x 9 years

save "$DATA_INT/county_pop_panel.dta", replace

* Clean up temp files
capture erase "$DATA_INT/_temp/mi_county_pop_2016_2023.dta"
capture erase "$DATA_INT/_temp/mi_pop_2024_raw.dta"
capture erase "$DATA_INT/_temp/names_sorted.dta"
capture erase "$DATA_INT/_temp/fips_sorted.dta"

di _n "========================================"
di "  04_population_build.do COMPLETE"
di "  Output: $DATA_INT/county_pop_panel.dta (747 obs)"
di "  Output: $DATA_INT/county_fips_crosswalk.dta (83 counties)"
di "========================================"
