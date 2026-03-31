/*==============================================================================
  06_scaling.do

  Purpose:  Create per-10,000-resident outcomes for all count variables
            in the final panels.

  Formula:  outcome_p10k = (outcome / county_pop) * 10000

  Applied to count outcomes only, NOT rates (rates are already proportions).

  Input:    $DATA_FINAL/michigan_panel_A.dta
            $DATA_FINAL/michigan_panel_B.dta
            $DATA_FINAL/michigan_panel_C.dta
            $DATA_FINAL/michigan_court_level.dta

  Output:   Same files, updated in place with _p10k variables added.

  Requires: paths.do, 01-05 must have run.
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
di as text "  06_scaling.do"
di as text "========================================"


* --- Program to add per-10k variables ---
capture program drop add_per10k
program define add_per10k
    syntax, datafile(string) pop_var(string)

    di _n "--- Scaling: `datafile' ---"
    use "`datafile'", clear
    di "Obs: " _N

    * Count outcomes to scale
    local count_vars "total_jury_verdicts capital_felony other_felony other_cases"
    local summon_vars "summoned told_to_report actually_reported sent_to_courtroom questioned_in_voir_dire"

    foreach v of local count_vars {
        capture confirm variable `v'
        if !_rc {
            capture drop `v'_p10k
            gen `v'_p10k = (`v' / `pop_var') * 10000 ///
                if !missing(`v') & !missing(`pop_var')
            label var `v'_p10k "`v' per 10,000 residents"
        }
    }

    foreach v of local summon_vars {
        capture confirm variable `v'
        if !_rc {
            capture drop `v'_p10k
            gen `v'_p10k = (`v' / `pop_var') * 10000 ///
                if !missing(`v') & !missing(`pop_var')
            label var `v'_p10k "`v' per 10,000 residents"
        }
    }

    * Verify
    count if !missing(`pop_var')
    di "  Obs with population: " r(N)
    count if missing(`pop_var')
    di "  Missing population: " r(N)

    compress
    save "`datafile'", replace
    di "  Saved with per-10k variables."
end


* --- Scale all 6 datasets ---
add_per10k, datafile("$DATA_FINAL/michigan_panel_A.dta") pop_var("county_pop")
add_per10k, datafile("$DATA_FINAL/michigan_panel_B.dta") pop_var("county_pop")
add_per10k, datafile("$DATA_FINAL/michigan_panel_C.dta") pop_var("county_pop")
add_per10k, datafile("$DATA_FINAL/michigan_panel_D.dta") pop_var("county_pop")
add_per10k, datafile("$DATA_FINAL/michigan_panel_E.dta") pop_var("county_pop")
add_per10k, datafile("$DATA_FINAL/michigan_court_level.dta") pop_var("county_pop")


di _n "========================================"
di "  06_scaling.do COMPLETE"
di "  All final panels now include _p10k variables."
di "========================================"
