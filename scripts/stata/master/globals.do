/*==============================================================================
  globals.do — Project-Level Settings for Michigan Replication Pipeline

  Usage: do code/master/globals.do  (called by master_build_all.do)
  Requires: paths.do must be run first.
==============================================================================*/

* --- Years ---
* Panel covers 2016-2024 for elections.
* Jury data available: 2016-2019, 2022-2024 (7 years).
* COVID gap: 2020-2021 excluded — SCAO dashboard has no jury data for these years.
global YEAR_MIN 2016
global YEAR_MAX 2024
global COVID_DROP "2020 2021"

* --- State ---
* Michigan only. Florida excluded from this build.
global STATE "MI"
global STATE_FIPS "26"

* --- Election years ---
* MI prosecutor elections: every even year.
* Primary election years: 2016, 2020, 2024 (presidential years)
* Off-cycle election years: 2018, 2022 (sparse — flagged with flag_sparse_election)
global ELECTION_YEARS "2016 2018 2020 2022 2024"

* --- Counties ---
global N_COUNTIES 83

* --- Treatment definitions (three tiers, broadest → strictest) ---
* treat_pros_pressure: 1 iff election year AND incumbent running.
*   Open-seat elections EXCLUDED — open_pros==1 → pressure==0.
*   Open seats are controls, not treated observations.
* treat_pros_contested: pressure AND opponent in EITHER primary OR general (broad).
*   Captures any challenger at any stage of the election.
* treat_pros_uncontested: pressure AND no opponent in either primary or general.
*   Incumbent completely unopposed at every stage.
* treat_pros_contested_long: pressure AND general election contested (narrow/strict).
*   Requires a general election opponent specifically.
*   Primary-only challenges are excluded from this measure.
* Identity: contested + uncontested == pressure (must hold exactly).
* Restriction: contested_long is a strict subset of contested.

* --- Excluded variables ---
* pct_failed_to_appear: EXCLUDED from analysis — unreliable data
*   (~30% of source rows have raw counts instead of proportions)

di as text "=== Project globals set ==="
di as text "  State: $STATE (FIPS $STATE_FIPS)"
di as text "  Years: $YEAR_MIN - $YEAR_MAX"
di as text "  COVID drop: $COVID_DROP"
di as text "  Counties: $N_COUNTIES"
