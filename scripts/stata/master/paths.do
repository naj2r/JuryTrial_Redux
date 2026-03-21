/*==============================================================================
  paths.do — Path Globals for Michigan Replication Pipeline

  All paths in the pipeline reference these globals.
  Edit ONLY this file to adjust for a different machine.

  Usage: do code/master/paths.do
==============================================================================*/

* --- Project root ---
* This must be set to wherever results_rebuild/ lives on your machine.
global ROOT "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"

* --- Data directories ---
global DATA_RAW   "$ROOT/data_raw/michigan"
global DATA_INT   "$ROOT/data_intermediate/michigan"
global DATA_FINAL "$ROOT/data_final"

* --- Code directories ---
global CODE_MASTER  "$ROOT/code/master"
global CODE_MI      "$ROOT/code/michigan"

* --- Output directories ---
global OUTPUT     "$ROOT/output"
global LOGS       "$OUTPUT/logs"
global TABLES     "$OUTPUT/tables"
global FIGURES    "$OUTPUT/figures"
global DIAGNOSTICS "$OUTPUT/diagnostics"

* --- External data (too large to copy into project) ---
* Census 1969-2023: 17.1M rows. Filter to state_fips=="26" for Michigan.
global CENSUS "C:/Users/jensenn/Dropbox/Data_research"

* --- Ensure output directories exist ---
capture mkdir "$DATA_INT"
capture mkdir "$DATA_FINAL"
capture mkdir "$LOGS"
capture mkdir "$TABLES"
capture mkdir "$FIGURES"
capture mkdir "$DIAGNOSTICS"
capture mkdir "$DATA_INT/_temp"

di as text "=== Path globals set ==="
di as text "  ROOT:       $ROOT"
di as text "  DATA_RAW:   $DATA_RAW"
di as text "  DATA_INT:   $DATA_INT"
di as text "  DATA_FINAL: $DATA_FINAL"
di as text "  OUTPUT:     $OUTPUT"
di as text "  CENSUS:     $CENSUS"
