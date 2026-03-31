/*==============================================================================
  verification3_cluster_diagnostics.do

  Purpose:  Identify regressions where cluster counts are low (<45) and
            p-values are near significance thresholds (p < 0.10).
            These are candidates for wild cluster bootstrap robustness.

  Method:
    - Read the regression results CSV
    - Flag rows where n_clusters < 45 AND p_value < 0.10
    - Report as a table for review

  Note: Wild bootstrap is referee armor for small-cluster inference,
        not a correction for the baseline (which is fine for 82-83 clusters).

  Usage: do code/michigan/verification3_cluster_diagnostics.do
  Requires: paths.do has been run AND 07_regressions.do has been run
==============================================================================*/

clear all
set more off
set update_query off

* --- Set paths ---
do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"

* --- Log ---
log using "$LOGS/verification3_cluster_diagnostics.log", replace

di _n "{hline 72}"
di "VERIFICATION 3: CLUSTER COUNT DIAGNOSTICS"
di "{hline 72}"

* =============================================================================
* PART A: Read CSV and identify low-cluster specs
* =============================================================================

import delimited "$OUTPUT/results/mi_regression_results.csv", clear varnames(1)

* Destring numeric columns (they import as string from CSV)
destring beta se p_value ci_lo ci_hi n_obs n_treated n_clusters share_treated, replace force

di _n "=== Total regression results: " _N " ==="

* Distribution of cluster counts
di _n "=== Cluster count distribution ==="
tab n_clusters

* =============================================================================
* PART B: Flag small-cluster + near-significant results
* =============================================================================

di _n "{hline 72}"
di "FLAGGED: n_clusters < 45 AND p_value < 0.10"
di "(candidates for wild cluster bootstrap robustness)"
di "{hline 72}"

gen _flagged = (n_clusters < 45 & p_value < 0.10)
qui count if _flagged == 1
di "  Total flagged results: " r(N)

if r(N) > 0 {
    sort n_clusters p_value
    list variant tier outcome treatment_var beta p_value n_clusters n_obs ///
        if _flagged == 1, noobs abbreviate(20)
}

* =============================================================================
* PART C: Cluster count by variant family
* =============================================================================

di _n "{hline 72}"
di "CLUSTER COUNTS BY VARIANT"
di "{hline 72}"

* Show min/max clusters for each variant
bys variant: egen _min_cl = min(n_clusters)
bys variant: egen _max_cl = max(n_clusters)

preserve
    contract variant _min_cl _max_cl
    sort _min_cl
    list variant _min_cl _max_cl, noobs abbreviate(25)
restore

drop _min_cl _max_cl

* =============================================================================
* PART D: Specific concern — COURT_DISTRICT variants
* =============================================================================

di _n "{hline 72}"
di "COURT_DISTRICT VARIANTS (lowest cluster counts)"
di "{hline 72}"

qui count if strpos(variant, "COURT_DISTRICT") > 0
di "  Total COURT_DISTRICT results: " r(N)

qui count if strpos(variant, "COURT_DISTRICT") > 0 & p_value < 0.10
di "  COURT_DISTRICT with p < 0.10: " r(N)

if r(N) > 0 {
    list variant tier outcome treatment_var beta p_value n_clusters ///
        if strpos(variant, "COURT_DISTRICT") > 0 & p_value < 0.10, ///
        noobs abbreviate(20)
}

* =============================================================================
* PART E: Summary recommendation
* =============================================================================

di _n "{hline 72}"
di "SUMMARY"
di "{hline 72}"

qui count if n_clusters >= 45
di "  Specs with >= 45 clusters: " r(N) " (standard clustered SE is reliable)"

qui count if n_clusters >= 30 & n_clusters < 45
di "  Specs with 30-44 clusters: " r(N) " (borderline — consider wild bootstrap)"

qui count if n_clusters < 30
di "  Specs with < 30 clusters: " r(N) " (wild bootstrap recommended)"

di _n "NOTE: For main results (Panel B baseline), n_clusters = 82-83."
di "Wild bootstrap is only needed as referee armor for court-level subsamples."

drop _flagged

di _n "=== VERIFICATION 3 COMPLETE ==="

log close
