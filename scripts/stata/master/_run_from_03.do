/*==============================================================================
  _run_from_03.do — Partial pipeline: re-run from step 03 forward

  Purpose: After adding verdict composition shares to 03 and 07,
           re-run the downstream pipeline without rebuilding elections/imports.

  Runs: 03 → 05 → 06 → 07
  Skips: 01 (elections), 02 (import), 04 (population) — unchanged
==============================================================================*/

clear all
set more off
set maxvar 10000
set update_query off
set processors `=c(processors_max)'

do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"

capture log close _all
log using "$LOGS/run_from_03.log", replace name(partial)

di as text _newline "========================================================"
di as text "  PARTIAL PIPELINE: Steps 03 → 05 → 06 → 07"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================================"

timer clear
timer on 1

di as text _newline ">>> Step 3: Classify Courts + Aggregate Variants"
do "$CODE_MI/03_classify_and_aggregate.do"

di as text _newline ">>> Step 5: Merge Panels"
do "$CODE_MI/05_merge_panels.do"

di as text _newline ">>> Step 6: Population Scaling (Per-10k)"
do "$CODE_MI/06_scaling.do"

di as text _newline ">>> Step 7: TWFE Regressions"
do "$CODE_MI/07_regressions.do"

timer off 1
timer list

di as text _newline "========================================================"
di as text "  PARTIAL PIPELINE COMPLETE"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================================"

log close partial
