/*==============================================================================
  01_elections_build.do

  Purpose:  Collapse Michigan candidate-level prosecutor election data into
            (1) a district x election-year summary, then
            (2) a full annual panel (83 counties x 9 years, 2016-2024)
            with treatment variables, turnover coding, carry-forward prosecutor,
            and flag variables for manual review.

  Input:    $DATA_RAW/elections/michigan_prosecutor_elections_stata.csv
            (358 candidate-level rows)

  Output 1: $DATA_INT/elections_collapsed.dta / .csv
             One row per district x election-year (~255 rows)

  Output 2: $DATA_INT/elections_panel.dta / .csv
             One row per district x year (83 x 9 = 747 rows)

  Key design note:
    Annual pressure = full-year election-year exposure when incumbent is running.
    Open-seat elections are CONTROLS, not treated.
    pressure requires an incumbent running: open_pros==1 -> pressure==0.

  Treatment families (MI has prosecutors only, no public defenders):
    Family 1  (headline):    treat_pros_pressure  (incumbent running)
    Family 1b (broad):       treat_pros_contested (primary OR general opponent)
                             treat_pros_uncontested (fully unopposed)
    Family 1c (narrow):      treat_pros_contested_long (general election opponent only)
    Family 2  (alternate):   treat_pros_incumbent_electyear

  Adapted from: Michigan Elections Data/mi_election_collapse.do
  Requires: paths.do must be run first (provides $DATA_RAW, $DATA_INT globals)
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
di as text "  01_elections_build.do"
di as text "  STEP A: Collapse Candidate-Level Data"
di as text "========================================"

/*------------------------------------------------------------------------------
  A1: Import and Validate Input
------------------------------------------------------------------------------*/

import delimited "$DATA_RAW/elections/michigan_prosecutor_elections_stata.csv", clear varnames(1)

di as text _newline "--- A1: Validate Input ---"
di as text "Row count: " _N
assert _N == 358

* Confirm valid incumbent/challenger/open codes
assert inlist(incumbent_or_challenger, "I", "C", "O")
tab incumbent_or_challenger, m

* Confirm 83 unique districts
distinct district
* (expect r(ndistinct) == 83)

* Confirm valid election years only
assert inlist(year, 2016, 2018, 2020, 2022, 2024)
tab year

* Check for duplicate (district, year, candidate)
duplicates tag district year candidate, gen(_dup)
assert _dup == 0
drop _dup

* Flag: multiple incumbents in same district-year (should not happen)
bysort district year: egen _n_inc = total(incumbent_or_challenger == "I")
gen flag_multiple_incumbents = (_n_inc > 1)
tab flag_multiple_incumbents
di as text "  (expect all 0 -- multiple incumbents would indicate data error)"

* Flag: mixed O+C groups (open seat with challengers -- unusual coding)
bysort district year: egen _has_O = max(incumbent_or_challenger == "O")
bysort district year: egen _has_C = max(incumbent_or_challenger == "C")
gen flag_mixed_open_challenger = (_has_O == 1 & _has_C == 1)
tab flag_mixed_open_challenger
di as text "  (O+C mix: open seat with challengers -- may indicate coding issue)"

drop _n_inc _has_O _has_C

di as text "--- A1 complete: input validated ---"


/*------------------------------------------------------------------------------
  A2: Compute Election Metadata per (district, year)

  IMPORTANT: All == 0 comparisons guard against missing values explicitly.
------------------------------------------------------------------------------*/

di as text _newline "--- A2: Compute Election Metadata ---"

* Count candidates per district-year
bysort district year: gen n_candidates = _N

* Incumbent running? (any row in group has "I")
bysort district year: egen incumbent_pros = max(incumbent_or_challenger == "I")

* Open seat? (no incumbent AND at least one candidate)
gen open_pros = (incumbent_pros == 0 & n_candidates > 0)

* General election contested? GUARD AGAINST MISSING
* general_uncontested == 0 means contested, but must not be missing
bysort district year: egen contested_pros = ///
    max(general_uncontested == 0 & !missing(general_uncontested))

* Primary contested? GUARD AGAINST MISSING
bysort district year: egen contested_primary = ///
    max(primary_uncontested == 0 & !missing(primary_uncontested))

* --- PPP CODING ARTIFACT CORRECTIONS ---
* Verified 2026-03-19 against PPP website (https://ppp.unc.edu/).
* Three incumbent observations have primary_uncontested incorrectly set to 0
* despite no opponent appearing on the PPP site or ballot. These are coding
* artifacts where the PPP didn't set the uncontested flag for nonpartisan
* incumbents who ran without opposition.
*
* Impact: These corrections affect ONLY contested_primary (and downstream
* primary_contest_only_pros and treat_pros_primary_only). They do NOT affect
* contested_pros, treat_pros_pressure, treat_pros_contested_long, or any
* variable derived from the general election. Since these three districts
* were already coded as general-uncontested and primary-only-contested,
* and primary-only observations are DROPPED from T2 regressions, the
* corrections have NO effect on any regression output. They are applied
* for internal consistency and to prevent margin-variable artifacts.

* Keweenaw 2024: Charles Miller (Dem, I) — only candidate, 100% general
replace contested_primary = 0 if district == "Keweenaw" & year == 2024 ///
    & incumbent_or_challenger == "I"

* Montmorency 2020: Vicki Kundinger (NP, I) — only candidate, 100% general
replace contested_primary = 0 if district == "Montmorency" & year == 2020 ///
    & incumbent_or_challenger == "I"

* Montmorency 2024: Vicki Kundinger (NP, I) — only candidate, 97% general (3% write-in)
replace contested_primary = 0 if district == "Montmorency" & year == 2024 ///
    & incumbent_or_challenger == "I"

di as text "  PPP artifact corrections applied: 3 primary_uncontested recodes"
di as text "  (Keweenaw 2024, Montmorency 2020, Montmorency 2024)"
di as text "  No effect on regression outputs — applied for internal consistency."

* Unopposed: incumbent runs AND uncontested in BOTH stages
* NOTE: This is functionally identical to treat_pros_uncontested (defined in A4).
*   Retained as descriptive metadata; candidate for removal in a future cleanup.
gen unopposed_pros = (incumbent_pros == 1 & contested_pros == 0 & contested_primary == 0)

* Primary-only contest: primary was contested but general was not, with incumbent
gen primary_contest_only_pros = ///
    (contested_primary == 1 & contested_pros == 0 & incumbent_pros == 1)

* Mark all rows as election years (they all are in this input)
gen is_election_year_pros = 1

tab contested_pros
tab contested_primary
tab unopposed_pros
tab primary_contest_only_pros

di as text "--- A2 complete: metadata computed ---"


/*------------------------------------------------------------------------------
  A3: Winner Identification & Turnover Coding

  Hierarchical winner logic:
    Level 1: general_won == 1
    Level 2: general_uncontested == 1 AND primary_won == 1 (fallback)
    Level 3: flag_no_winner = 1 (neither condition met)

  Turnover: winner != incumbent in election years where incumbent ran.
  Election-year winner becomes current_prosecutor IMMEDIATELY (not lagged).
------------------------------------------------------------------------------*/

di as text _newline "--- A3: Winner & Turnover ---"

* --- Hierarchical winner identification ---
gen is_winner = 0
* Level 1: won the general election
replace is_winner = 1 if general_won == 1
* Level 2: general was uncontested AND won primary (handles missing general_won)
replace is_winner = 1 if is_winner == 0 & general_uncontested == 1 ///
    & primary_won == 1 & !missing(primary_won)

tab is_winner

* Flag: no winner found for this district-year
bysort district year: egen _any_winner = max(is_winner)
gen flag_no_winner = (_any_winner == 0 & is_election_year_pros == 1)
tab flag_no_winner
di as text "  (flag_no_winner: district-years where no winner could be identified)"

* Extract winner name and party
gen str80 _w_name = candidate if is_winner == 1
gen str20 _w_party = party if is_winner == 1
bysort district year: egen str80 winner_pros = mode(_w_name), minmode
bysort district year: egen str20 party_pros = mode(_w_party), minmode

* --- Identify incumbent name ---
gen str80 _inc_name = candidate if incumbent_or_challenger == "I"
bysort district year: egen str80 _incumbent_name = mode(_inc_name), minmode

* --- Turnover ---
* Turnover = 1 when incumbent ran but a different person won
gen turnover_pros = 0
replace turnover_pros = 1 if incumbent_pros == 1 ///
    & winner_pros != "" & _incumbent_name != "" ///
    & winner_pros != _incumbent_name

* Predecessor: who was the incumbent that lost/retired
gen str80 predecessor_pros = _incumbent_name if turnover_pros == 1

tab turnover_pros
di as text "  Turnover cases (incumbent ran but lost):"
list district year _incumbent_name winner_pros if turnover_pros == 1, noobs

di as text "--- A3 complete: winners and turnover coded ---"


/*------------------------------------------------------------------------------
  A4: Treatment Variables

  Family 1 (headline):    treat_pros_pressure = election year x incumbent running
    CRITICAL: Open-seat elections are EXCLUDED from pressure.
    open_pros==1 -> incumbent_pros==0 -> pressure==0.
    Open seats are controls, not treated observations.

  Family 1b (mechanism):  treat_pros_contested / treat_pros_uncontested
  Family 1c (restriction): treat_pros_contested_long (general election only)
  Family 2  (alternate):   treat_pros_incumbent_electyear

  Three treatment intensities:
    pressure        = incumbent running (broadest)
    contested       = pressure + opponent in EITHER primary OR general (broad)
    contested_long  = pressure + opponent in the GENERAL election (narrow/strict)
    uncontested     = pressure + no opponent in either stage (fully unopposed)

  Decomposition: contested + uncontested == pressure
  Restriction:   contested_long is a strict subset of contested
------------------------------------------------------------------------------*/

di as text _newline "--- A4: Treatment Variables ---"

* --- Family 1: Headline pressure ---
* Pressure = election year where incumbent is running (not open seat)
gen treat_pros_pressure = (incumbent_pros == 1)

* --- Family 1b: Broad contested / uncontested mechanism split ---
* Contested (BROAD) = pressure AND opponent in EITHER primary OR general
* This captures all forms of electoral challenge to the incumbent.
gen treat_pros_contested = (treat_pros_pressure == 1 & ///
    (contested_pros == 1 | contested_primary == 1))

* Uncontested = pressure AND no opponent in either stage (fully unopposed)
gen treat_pros_uncontested = (treat_pros_pressure == 1 & ///
    contested_pros == 0 & contested_primary == 0)

* --- Family 1c: Narrow contested (general election only) ---
* Contested_long = pressure AND opponent in the GENERAL election specifically.
* This is the strictest treatment — only long-campaign general election pressure.
* It is a strict subset of contested (excludes primary-only challengers).
gen treat_pros_contested_long = (treat_pros_pressure == 1 & contested_pros == 1)

* --- Family 2: Alternate (incumbent x election year) ---
* NOTE: In all-election-year data, this equals treat_pros_pressure.
* They diverge in the panel where non-election years exist.
gen treat_pros_incumbent_electyear = (incumbent_pros == 1)

tab treat_pros_pressure
tab treat_pros_contested
tab treat_pros_uncontested
tab treat_pros_contested_long

* --- Family 1d: Primary-only contested (contested but not in general election) ---
* This captures incumbents who faced a primary challenger but ran unopposed in
* the general election. Used as a SAMPLE RESTRICTION flag in T2 regressions:
* these county-years are dropped from T2 because they are irrelevant to the
* general-election channel. Identity: contested_long + primary_only + uncontested == pressure
gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* Cross-tab to verify the three-way split
di as text _newline "--- Treatment decomposition ---"
di as text "  pressure = contested + uncontested"
di as text "  contested = contested_long + primary_only_contested"
tab treat_pros_primary_only
di as text "  Primary-only contested cases (in contested but NOT in contested_long):"
count if treat_pros_primary_only == 1

di as text "--- A4 complete: treatment variables created ---"


/*------------------------------------------------------------------------------
  A4b: Closeness Variables (Election Margin Intensity)

  Closeness = 1 - |incumbent_pct - 50| / 50
    Range: 0 (blowout) to 1 (tied at 50%)
    Close to 50% = high closeness = maximum competitive pressure
    Close to 100% or 0% = low closeness = blowout win or loss

  Construction:
    general_closeness  — from general_pct (incumbent's general election %)
    primary_closeness  — from primary_pct (incumbent's primary %)
    max_closeness      — max of general and primary (tightest race)

  Fill rules:
    Non-election years: closeness = 0 (filled after merge into panel)
    Open seats: closeness = 0 (no incumbent -> no competitive pressure)
    Uncontested incumbents with missing pct: closeness = 0

  Source: Audit 3-19-26/check_margin_regressions_v2.do
------------------------------------------------------------------------------*/

di as text _newline "--- A4b: Closeness Variables ---"

* Build closeness from incumbent vote shares (candidate-level data)
gen general_closeness = .
gen primary_closeness = .

* General closeness: 1 - |pct - 50| / 50
replace general_closeness = 1 - abs(general_pct - 50) / 50 ///
    if incumbent_or_challenger == "I" & !missing(general_pct)

* Primary closeness: 1 - |pct - 50| / 50
replace primary_closeness = 1 - abs(primary_pct - 50) / 50 ///
    if incumbent_or_challenger == "I" & !missing(primary_pct)

* Propagate incumbent closeness to all rows in the same district-year
bysort district year: egen _gc = max(general_closeness)
bysort district year: egen _pc = max(primary_closeness)
replace general_closeness = _gc
replace primary_closeness = _pc
drop _gc _pc

* Max closeness = tightest race across stages
gen max_closeness = .
replace max_closeness = max(general_closeness, primary_closeness) ///
    if !missing(general_closeness) & !missing(primary_closeness)
replace max_closeness = general_closeness ///
    if missing(primary_closeness) & !missing(general_closeness)
replace max_closeness = primary_closeness ///
    if missing(general_closeness) & !missing(primary_closeness)

* Fill missing closeness with 0
* (open seats, uncontested with no vote share data)
foreach v in general_closeness primary_closeness max_closeness {
    replace `v' = 0 if missing(`v')
}

label var general_closeness "General election closeness (0=blowout, 1=tied)"
label var primary_closeness "Primary election closeness (0=blowout, 1=tied)"
label var max_closeness     "Max closeness across stages (tightest race)"

di as text "--- Closeness summary (incumbent-running obs only) ---"
tabstat general_closeness primary_closeness max_closeness ///
    if treat_pros_pressure == 1, ///
    stat(n mean sd min p25 p50 p75 max) columns(statistics) format(%9.3f)

di as text "--- A4b complete: closeness variables created ---"


/*------------------------------------------------------------------------------
  A5: Assertions (pre-collapse, still candidate-level but vars are group-level)
------------------------------------------------------------------------------*/

di as text _newline "--- A5: Assertions ---"

* Decomposition: contested + uncontested == pressure (must hold exactly)
assert treat_pros_contested + treat_pros_uncontested == treat_pros_pressure

* Restriction: contested_long is a strict subset of contested
assert treat_pros_contested_long <= treat_pros_contested

* Exhaustive T2 decomposition: contested_long + primary_only + uncontested == pressure
assert treat_pros_contested_long + treat_pros_primary_only + treat_pros_uncontested == treat_pros_pressure

* contested_long requires general contest; contested allows primary OR general
* So contested_long should be <= contested (never exceed)
* And any case with contested_long==1 must also have contested==1
assert treat_pros_contested == 1 if treat_pros_contested_long == 1

* Open seats: pressure must be 0
assert treat_pros_pressure == 0 if open_pros == 1

* Consistency: cannot be both incumbent and open
assert incumbent_pros + open_pros <= 1

* Turnover implies incumbent existed
assert incumbent_pros == 1 if turnover_pros == 1

di as text "--- A5 complete: all assertions passed ---"


/*------------------------------------------------------------------------------
  A6: Collapse to One Row per District-Year

  All computed variables are constant within (district, year) groups,
  so keeping the first row per group suffices.
------------------------------------------------------------------------------*/

di as text _newline "--- A6: Collapse to district-year ---"

* Drop candidate-level variables before collapsing
drop candidate incumbent_or_challenger party primary_pct primary_uncontested ///
    primary_won general_pct general_uncontested general_won

* Drop temporary variables
drop is_winner _any_winner _w_name _w_party _inc_name _incumbent_name

* Keep one row per (district, year)
bysort district year: keep if _n == 1

di as text "Collapsed row count: " _N
di as text "  (expect ~255, one row per district x election-year)"

* Confirm no duplicates remain
duplicates tag district year, gen(_dup)
assert _dup == 0
drop _dup


/*------------------------------------------------------------------------------
  A7: Sparse Election Flag
------------------------------------------------------------------------------*/

gen flag_sparse_election = inlist(year, 2018, 2022)
tab year flag_sparse_election


/*------------------------------------------------------------------------------
  A8: Save Collapsed Output
------------------------------------------------------------------------------*/

di as text _newline "--- A8: Save collapsed data ---"

label data "MI prosecutor elections collapsed (district x election-year)"

compress
save "$DATA_INT/elections_collapsed.dta", replace
export delimited "$DATA_INT/elections_collapsed.csv", replace

di as text "Saved: $DATA_INT/elections_collapsed.dta"
di as text "Saved: $DATA_INT/elections_collapsed.csv"
di as text "  Observations: " _N


di as text _newline "========================================"
di as text "  STEP B: Expand to Full Annual Panel"
di as text "========================================"


/*------------------------------------------------------------------------------
  B1: Create Panel Skeleton and Merge

  IMPORTANT: Skeleton is master. Collapsed election data merges INTO it.
  83 districts x 9 years (2016-2024) = 747 rows.
------------------------------------------------------------------------------*/

di as text _newline "--- B1: Panel skeleton + merge ---"

* --- Build skeleton: 83 districts x 9 years ---
use "$DATA_INT/elections_collapsed.dta", clear
keep district
duplicates drop
local n_districts = _N
di as text "Unique districts: " `n_districts'
assert `n_districts' == 83

expand 9
bysort district: gen year = 2015 + _n   // generates 2016, 2017, ..., 2024
assert _N == 747

save "$DATA_INT/_temp/_mi_skeleton.dta", replace

* --- Merge collapsed elections into skeleton ---
use "$DATA_INT/_temp/_mi_skeleton.dta", clear
merge 1:1 district year using "$DATA_INT/elections_collapsed.dta"

* Expected merge results:
*   _merge == 1: non-election year (skeleton only) -- normal
*   _merge == 3: election year (matched) -- normal
*   _merge == 2: should NEVER happen (collapsed data not in skeleton)
tab _merge
assert inlist(_merge, 1, 3)
count if _merge == 1
di as text "  Non-election year rows (merge==1): " r(N)
count if _merge == 3
di as text "  Election year rows (merge==3): " r(N)

gen is_from_election = (_merge == 3)
drop _merge

di as text "--- B1 complete: panel merged ---"


/*------------------------------------------------------------------------------
  B2: Fill Non-Election Years with 0

  Binary election metadata and treatment vars are missing for non-election
  years after the merge. Semantically, missing = "no election" = 0.
------------------------------------------------------------------------------*/

di as text _newline "--- B2: Fill non-election years ---"

foreach var of varlist is_election_year_pros incumbent_pros open_pros ///
    contested_pros contested_primary unopposed_pros turnover_pros ///
    primary_contest_only_pros n_candidates ///
    treat_pros_pressure treat_pros_contested treat_pros_uncontested ///
    treat_pros_contested_long treat_pros_incumbent_electyear ///
    treat_pros_primary_only ///
    flag_no_winner flag_multiple_incumbents flag_mixed_open_challenger ///
    flag_sparse_election ///
    general_closeness primary_closeness max_closeness {
    replace `var' = 0 if missing(`var')
}

di as text "--- B2 complete: non-election years filled with 0 ---"


/*------------------------------------------------------------------------------
  B3: Carry Forward Current Prosecutor

  CRITICAL: In election years, current_prosecutor = winner_pros (the winner
  takes office immediately in that year). NOT the incumbent.
  In non-election years, carry forward from the most recent election year.
------------------------------------------------------------------------------*/

di as text _newline "--- B3: Carry forward prosecutor ---"

* --- current_prosecutor = winner in election years ---
gen str80 current_prosecutor = winner_pros if is_election_year_pros == 1
gen str20 current_party = party_pros if is_election_year_pros == 1

* --- Carry forward through non-election years ---
sort district year
by district (year): replace current_prosecutor = current_prosecutor[_n-1] ///
    if (missing(current_prosecutor) | current_prosecutor == "") & _n > 1
by district (year): replace current_party = current_party[_n-1] ///
    if (missing(current_party) | current_party == "") & _n > 1

* --- Flag rows where prosecutor was inferred (not directly from election) ---
gen flag_inferred_prosecutor = (is_election_year_pros == 0)

* Also flag if current_prosecutor is still empty after carry-forward
replace flag_inferred_prosecutor = 1 if current_prosecutor == "" | missing(current_prosecutor)

count if missing(current_prosecutor) | current_prosecutor == ""
di as text "  Rows with empty current_prosecutor after carry-forward: " r(N)
di as text "  (these lack an election in or before their year)"

di as text "--- B3 complete: prosecutor carried forward ---"


/*------------------------------------------------------------------------------
  B4: Add State Identifier
------------------------------------------------------------------------------*/

gen str2 state = "MI"


/*------------------------------------------------------------------------------
  B5: Final Checks
------------------------------------------------------------------------------*/

di as text _newline "--- B5: Final assertions ---"

* Panel dimensions: 83 x 9 = 747
assert _N == 747

* No duplicates
duplicates tag district year, gen(_dup)
assert _dup == 0
drop _dup

* Treatment vars = 0 for non-election years
assert treat_pros_pressure == 0 if is_election_year_pros == 0
assert treat_pros_contested == 0 if is_election_year_pros == 0
assert treat_pros_uncontested == 0 if is_election_year_pros == 0
assert treat_pros_contested_long == 0 if is_election_year_pros == 0
assert treat_pros_incumbent_electyear == 0 if is_election_year_pros == 0

* Decomposition holds in full panel
assert treat_pros_contested + treat_pros_uncontested == treat_pros_pressure

* Restriction holds in full panel
assert treat_pros_contested_long <= treat_pros_contested

* Open seats still not treated
assert treat_pros_pressure == 0 if open_pros == 1

* Current prosecutor should be populated for most rows
count if missing(current_prosecutor) | current_prosecutor == ""
di as text "  Empty current_prosecutor rows: " r(N)

* Cross-tab for sanity
di as text _newline "--- Cross-tabs ---"
tab year is_election_year_pros
tab year treat_pros_pressure
tab year treat_pros_contested
tab year turnover_pros

di as text "--- B5 complete: all final assertions passed ---"


/*------------------------------------------------------------------------------
  B6: Save Panel Output
------------------------------------------------------------------------------*/

di as text _newline "--- B6: Save final panel ---"

* Drop intermediate variables
drop is_from_election

* Variable ordering: identifiers -> prosecutor -> election metadata ->
*   treatment -> string metadata -> flags
order state district year current_prosecutor current_party ///
    is_election_year_pros n_candidates incumbent_pros open_pros ///
    contested_pros contested_primary unopposed_pros turnover_pros ///
    primary_contest_only_pros ///
    treat_pros_pressure treat_pros_contested treat_pros_uncontested ///
    treat_pros_contested_long treat_pros_incumbent_electyear ///
    winner_pros predecessor_pros party_pros ///
    flag_*

label data "MI prosecutor elections panel (district x year, 2016-2024)"

compress
save "$DATA_INT/elections_panel.dta", replace
export delimited "$DATA_INT/elections_panel.csv", replace

* Clean up temp file
capture erase "$DATA_INT/_temp/_mi_skeleton.dta"

di as text _newline "========================================"
di as text "  01_elections_build.do COMPLETE"
di as text "========================================"
di as text "Output 1: $DATA_INT/elections_collapsed.dta (.csv)"
di as text "  Unit: district x election-year"
di as text "  Observations: see above"
di as text ""
di as text "Output 2: $DATA_INT/elections_panel.dta (.csv)"
di as text "  Unit: district x year (2016-2024)"
di as text "  Observations: " _N " (expect 747)"
