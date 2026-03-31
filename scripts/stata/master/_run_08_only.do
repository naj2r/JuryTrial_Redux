/*==============================================================================
  _run_08_only.do — Re-run conference tables only (step 08)

  Use when regression CSV has been updated but tables haven't been regenerated.
  Requires: data_final/ and output/results/ must already exist.
==============================================================================*/

set update_query off
clear all
set more off

* --- Load paths and globals ---
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"

* --- Run step 08 only ---
di _n "=========================================="
di    "  Running 08_conference_tables.do ONLY"
di    "=========================================="

do "$CODE_MI/08_conference_tables.do"

di _n "=========================================="
di    "  Done. Tables written to Overleaf."
di    "=========================================="
