/*==============================================================================
  master_build_all.do — Michigan Jury Trial Replication Pipeline

  Purpose:  Runs entire pipeline from raw data → final regression-ready datasets.
            A referee should be able to open Stata and run this single file
            to reproduce all results.

  Usage:    do code/master/master_build_all.do

  Requirements:
    - Stata 17+ (uses reghdfe, compress, etc.)
    - reghdfe package installed (ssc install reghdfe)
    - Raw data in data_raw/michigan/ (immutable source copies)
    - Census data at path specified in paths.do

  Author:   Jensen (with Claude Code assistance)
  Date:     2026-02-23
==============================================================================*/

clear all
set more off
set maxvar 10000
set update_query off
set processors `=c(processors_max)'

* --- Set paths and globals ---
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"

* --- Start log ---
* NOTE: In batch mode, Stata auto-creates a .log in the working directory.
* This explicit log captures the full build for audit purposes.
capture log close _all
log using "$LOGS/master_build.log", replace name(master)

di as text _newline "========================================================"
di as text "  MICHIGAN JURY TRIAL REPLICATION — FULL BUILD"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================================"

timer clear
timer on 1

* --- SECTION I: DATA CONSTRUCTION ---

di as text _newline ">>> Step 1: Elections Build"
do "$CODE_MI/01_elections_build.do"

di as text _newline ">>> Step 2: Import Jury Data"
do "$CODE_MI/02_import_jury_data.do"

di as text _newline ">>> Step 3: Classify Courts + Aggregate Variants"
do "$CODE_MI/03_classify_and_aggregate.do"

di as text _newline ">>> Step 3b: Caseload Build"
do "$CODE_MI/03b_caseload_build.do"

di as text _newline ">>> Step 4: Population Build"
do "$CODE_MI/04_population_build.do"

di as text _newline ">>> Step 5: Merge Panels"
do "$CODE_MI/05_merge_panels.do"

* --- SECTION II: VARIABLE CONSTRUCTION ---

di as text _newline ">>> Step 6: Population Scaling (Per-10k)"
do "$CODE_MI/06_scaling.do"

* --- SECTION III: ANALYSIS ---

di as text _newline ">>> Step 7: TWFE Regressions"
do "$CODE_MI/07_regressions.do"

timer off 1
timer list

di as text _newline "========================================================"
di as text "  BUILD COMPLETE"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================================"

log close master
