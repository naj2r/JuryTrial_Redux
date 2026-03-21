/*==============================================================================
  07c_tost_and_rwolf.do

  Purpose:  Supplementary equality/equivalence tests for decomposition analysis.
            Saved separately — NOT part of the main 07_regressions.do pipeline.
            Run AFTER 07_regressions.do has completed.

  Contents:
    Part 1: TOST equivalence tests for "election-cycle" outcomes
    Part 2: Romano-Wolf adjusted p-values for multiple testing

  Input:    $DATA_FINAL/michigan_panel_B.dta
  Output:   $OUTPUT/results/mi_tost_tests.csv
            $OUTPUT/results/mi_rwolf_results.csv (if rwolf installed)

  Note:     Romano-Wolf requires: ssc install rwolf
            TOST is computed manually from lincom output.
==============================================================================*/

* --- Bootstrap: allow standalone execution ---
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

clear
set more off

di as text _newline "========================================"
di as text "  07c_tost_and_rwolf.do"
di as text "  Date: $S_DATE  Time: $S_TIME"
di as text "========================================"


* =============================================================================
* PART 1: TOST Equivalence Tests
* =============================================================================
*
* Two One-Sided Tests (TOST) procedure:
*   H01: beta_con - beta_uncon <= -delta   (test if diff > -delta)
*   H02: beta_con - beta_uncon >=  delta   (test if diff <  delta)
*   If both rejected, conclude equivalence within ±delta.
*
* Equivalence margin (delta):
*   We use the SE of the T1 (pressure) coefficient as the margin.
*   This means: "the two coefficients are equivalent if their difference
*   is smaller than the precision with which we estimate the combined effect."
*   This is a conservative, data-driven margin.
*
* Applied to outcomes classified as "election-cycle":
*   - pct_told_to_report
*   - utilization_rate
*   - pct_other_felony
*
* Also applied to the purest null (for comparison):
*   - pct_questioned_in_voir_dire
* =============================================================================

* ---------------------------------------------------------------
* Wrapper program: reghdfe_rc0
*
* reghdfe v6+ (Stata 19) returns _rc=111 even on successful completion
* (singleton-drop notification). rwolf v3.1.0 treats any non-zero _rc
* as a regression failure. This wrapper catches the spurious _rc and
* returns 0 if the regression actually completed (e(N) populated).
* ---------------------------------------------------------------
capture program drop reghdfe_rc0
program define reghdfe_rc0
    capture noisily reghdfe `0'
    local rc_inner = _rc
    if `rc_inner' != 0 & e(N) > 0 & e(N) < . {
        * Regression completed successfully despite non-zero _rc
        exit 0
    }
    else if `rc_inner' != 0 {
        * Genuine failure
        exit `rc_inner'
    }
end


use "$DATA_FINAL/michigan_panel_B.dta", clear
capture gen log_county_pop = ln(county_pop)
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

* Initialize TOST CSV
capture mkdir "$OUTPUT/results"
global TOST_CSV "$OUTPUT/results/mi_tost_tests.csv"
tempname fht
file open `fht' using "$TOST_CSV", write replace
file write `fht' "outcome,delta,diff,se_diff,t_lower,p_lower,t_upper,p_upper,p_tost,equivalent" _n
file close `fht'

* --- Get T1 (pressure) SEs as equivalence margins ---
* Run T1 regressions for each outcome to get the SE of pressure coefficient

local tost_outcomes "pct_told_to_report utilization_rate pct_other_felony pct_questioned_in_voir_dire"

foreach y of local tost_outcomes {

    * Step 1: Get T1 SE as equivalence margin (with open_pros decomposition)
    qui reghdfe `y' treat_pros_pressure open_pros, absorb(county_id year) vce(cluster county_id)
    local delta = _se[treat_pros_pressure]
    di _n "=== TOST for `y' ==="
    di "  Equivalence margin (delta = SE_pressure): " %9.6f `delta'

    * Step 2: Run T2 decomposition regression (drop primary-only first)
    preserve
        qui drop if treat_pros_primary_only == 1
        qui drop if open_pros == 1

        qui reghdfe `y' treat_pros_contested_long treat_pros_uncontested, ///
            absorb(county_id year) vce(cluster county_id)

        * Step 3: Get difference and its SE via lincom
        qui lincom treat_pros_contested_long - treat_pros_uncontested
        local diff    = r(estimate)
        local se_diff = r(se)
        local df_r    = e(df_r)

        * Step 4: TOST computations
        * Test 1 (lower): H01: diff <= -delta  →  t = (diff + delta) / se_diff
        *   Reject H01 when t_lower is large and positive (evidence diff > -delta)
        *   p_lower = P(T >= t_lower) = right-tail probability
        local t_lower = (`diff' + `delta') / `se_diff'
        local p_lower = ttail(`df_r', `t_lower')

        * Test 2 (upper): H02: diff >= +delta  →  t = (diff - delta) / se_diff
        *   Reject H02 when t_upper is large and negative (evidence diff < delta)
        *   p_upper = P(T <= t_upper) = left-tail probability
        local t_upper = (`diff' - `delta') / `se_diff'
        local p_upper = 1 - ttail(`df_r', `t_upper')

        * TOST p-value = max(p_lower, p_upper)
        local p_tost = max(`p_lower', `p_upper')

        * Equivalence conclusion
        local equiv = "NO"
        if `p_tost' < 0.05 {
            local equiv = "YES_05"
        }
        else if `p_tost' < 0.10 {
            local equiv = "YES_10"
        }

        di "  diff = " %9.6f `diff' "  SE(diff) = " %9.6f `se_diff'
        di "  t_lower = " %7.4f `t_lower' "  p_lower = " %6.4f `p_lower'
        di "  t_upper = " %7.4f `t_upper' "  p_upper = " %6.4f `p_upper'
        di "  p_TOST  = " %6.4f `p_tost' "  Equivalent? `equiv'"

        * Save to CSV
        tempname fht
        file open `fht' using "$TOST_CSV", write append
        file write `fht' ///
            `"`y'"' "," (`delta') "," (`diff') "," (`se_diff') "," ///
            (`t_lower') "," (`p_lower') "," (`t_upper') "," (`p_upper') "," ///
            (`p_tost') "," `"`equiv'"' _n
        file close `fht'

    restore
}

di _n "TOST results saved to: $TOST_CSV"


* =============================================================================
* PART 2: Romano-Wolf Adjusted P-Values
* =============================================================================
*
* Romano-Wolf step-down procedure accounts for the correlation structure
* across outcomes when adjusting for multiple hypothesis testing.
*
* We test equality of contested vs. uncontested coefficients across
* all 16 outcomes simultaneously.
*
* The rwolf command (Clarke, Romano, Wolf 2020) is available via:
*   ssc install rwolf
*
* Strategy: Since rwolf tests multiple hypotheses from the SAME regression,
*   and our equality tests come from separate regressions (one per outcome),
*   we instead use rwolf to test multiple treatment effects, then report
*   the adjusted p-values.
*
* NOTE: rwolf requires that all outcomes be tested from a single model
*   specification. Our application has one regression per outcome, each with
*   two treatment variables. The correct multiple-testing adjustment is:
*   - For each outcome's equality test, we have a test statistic (F or t)
*   - We want to adjust across the 16 test statistics
*   - rwolf handles this by bootstrapping the joint null distribution
*
* Alternative approach: Since rwolf may not directly support cross-equation
*   equality tests, we implement a bootstrap-based adjustment manually.
*   But first, try the direct rwolf approach.
* =============================================================================

* Check if rwolf is installed
capture which rwolf
if _rc {
    di as error "rwolf not installed. Install with: ssc install rwolf"
    di as error "Skipping Romano-Wolf adjustment."
    di as error "Proceeding with Bonferroni-Holm as fallback."

    * --- Bonferroni-Holm fallback ---
    * Read equality test p-values for B variant, T2, sort, adjust
    * We do this manually from the equality test CSV values

    * Hard-code the 16 p-values from B variant T2 (contested_long)
    * (sourced from mi_equality_tests.csv)
    clear
    input str32 outcome float p_raw
        "pct_told_to_report"       0.9893
        "pct_sent_to_courtroom"    0.1312
        "pct_questioned_voir_dire" 0.6706
        "utilization_rate"         0.4463
        "pct_capital_felony"       0.0084
        "pct_other_felony"         0.9364
        "pct_other_cases"          0.1277
        "summoned"                 0.1781
        "told_to_report"           0.0996
        "actually_reported"        0.0868
        "sent_to_courtroom"        0.1747
        "questioned_voir_dire"     0.1679
        "total_jury_verdicts"      0.0491
        "capital_felony"           0.0496
        "other_felony"             0.5696
        "other_cases"              0.8747
    end

    * Sort by p-value (ascending) for Holm procedure
    sort p_raw
    gen rank = _n
    gen n_tests = _N

    * Holm adjustment: p_adj_i = max(p_adj_{i-1}, p_raw_i * (n - rank + 1))
    gen p_holm = p_raw * (n_tests - rank + 1)
    replace p_holm = min(p_holm, 1)

    * Enforce monotonicity (adjusted p can't decrease as raw p increases)
    replace p_holm = max(p_holm, p_holm[_n-1]) if _n > 1

    * Also compute simple Bonferroni
    gen p_bonf = min(p_raw * n_tests, 1)

    * Display
    di _n "=== Multiple Testing Adjustment (Bonferroni-Holm) ==="
    di "  16 equality tests: H0: beta_contested = beta_uncontested"
    di ""
    list outcome p_raw p_holm p_bonf, clean noobs

    * Save
    global RWOLF_CSV "$OUTPUT/results/mi_multiple_testing_adj.csv"
    export delimited outcome p_raw p_holm p_bonf using "$RWOLF_CSV", replace
    di _n "Multiple testing results saved to: $RWOLF_CSV"
}
else {
    * --- rwolf IS installed ---
    * The rwolf approach: test the treatment effect (contested_long) across
    * multiple outcomes simultaneously, adjusting for correlation.
    *
    * But rwolf tests a SINGLE coefficient across multiple regressions,
    * not equality of two coefficients. So we construct the DIFFERENCE
    * as a new variable and test whether its coefficient equals zero.
    *
    * Alternative: use the bootstrap manually.
    *
    * For now, use rwolf on the T1 (pressure) results as the primary
    * multiple-testing concern, and use Bonferroni-Holm on the equality tests.

    di _n "rwolf is installed. Running Romano-Wolf on T1 pressure effects..."

    * Drop primary-only for T2 sample
    preserve
        qui drop if treat_pros_primary_only == 1
        qui drop if open_pros == 1

        * ---------------------------------------------------------------
        * WORKAROUND: rwolf v3.1.0 macro name length bug
        *
        * rwolf internally creates local macros named pv{outcome}_{indepvar}.
        * With our long variable names (e.g., pct_told_to_report + treat_pros_pressure),
        * the macro name exceeds Stata's 31-character limit.
        * Fix: clone all outcomes and treatment into short-name aliases.
        * ---------------------------------------------------------------

        * Create short aliases for treatment + open seat control
        clonevar tp = treat_pros_pressure
        clonevar op = open_pros

        * Create short aliases for outcomes (y01-y16)
        * Rate outcomes
        clonevar y01 = pct_told_to_report
        clonevar y02 = pct_sent_to_courtroom
        clonevar y03 = pct_questioned_in_voir_dire
        clonevar y04 = utilization_rate
        clonevar y05 = pct_capital_felony
        clonevar y06 = pct_other_felony
        clonevar y07 = pct_other_cases
        * Count outcomes
        clonevar y08 = total_jury_verdicts
        clonevar y09 = capital_felony
        clonevar y10 = other_felony
        clonevar y11 = other_cases
        * Summon outcomes
        clonevar y12 = summoned
        clonevar y13 = told_to_report
        clonevar y14 = actually_reported
        clonevar y15 = sent_to_courtroom
        clonevar y16 = questioned_in_voir_dire

        * Mapping for display
        local name_y01 "pct_told_to_report"
        local name_y02 "pct_sent_to_courtroom"
        local name_y03 "pct_questioned_in_voir_dire"
        local name_y04 "utilization_rate"
        local name_y05 "pct_capital_felony"
        local name_y06 "pct_other_felony"
        local name_y07 "pct_other_cases"
        local name_y08 "total_jury_verdicts"
        local name_y09 "capital_felony"
        local name_y10 "other_felony"
        local name_y11 "other_cases"
        local name_y12 "summoned"
        local name_y13 "told_to_report"
        local name_y14 "actually_reported"
        local name_y15 "sent_to_courtroom"
        local name_y16 "questioned_in_voir_dire"

        local all_short "y01 y02 y03 y04 y05 y06 y07 y08 y09 y10 y11 y12 y13 y14 y15 y16"

        * First verify the underlying reghdfe works
        di _n "Verifying reghdfe specification..."
        qui reghdfe_rc0 y01 tp op, absorb(county_id year) vce(cluster county_id)
        di "  reghdfe OK. N=" e(N) " clusters=" e(N_clust)

        * rwolf for T1 (pressure) across all outcomes
        * Uses reghdfe_rc0 wrapper (see top of file) to handle reghdfe v6+
        * compatibility with rwolf v3.1.0.
        * Uses short aliases (y01-y16, tp) to avoid rwolf macro name length bug
        * (rwolf constructs internal macros pv{outcome}_{indepvar} that exceed
        *  Stata's 31-char local name limit with our long variable names).
        * cluster() provides bootstrap resampling; vce(cluster) provides SEs.
        * absorb() passes through to reghdfe for fixed effects.
        di _n "Running Romano-Wolf (1000 reps, cluster bootstrap)..."
        di "  Using reghdfe_rc0 wrapper + short aliases (y01-y16)."
        capture noisily rwolf `all_short', ///
            indepvar(tp) controls(op) ///
            method(reghdfe_rc0) ///
            absorb(county_id year) vce(cluster county_id) ///
            cluster(county_id) ///
            reps(1000) seed(42) holm

        if !_rc {
            * Save rwolf output
            * rwolf stores results in e() matrix named RW
            mat rw = e(RW)
            di _n "Romano-Wolf adjusted p-values (T1 pressure):"
            di _n "  Outcome mapping:"
            forvalues i = 1/16 {
                local yvar : word `i' of `all_short'
                di "    `yvar' = `name_`yvar''"
            }
            mat list rw

            * Export to CSV with full outcome names
            * Note: Cannot nest preserve (already inside one from line 262).
            * Use file write instead of preserve/clear/svmat.
            global RWOLF_T1_CSV "$OUTPUT/results/mi_rwolf_t1_pressure.csv"
            tempname fhw
            file open `fhw' using "$RWOLF_T1_CSV", write replace
            file write `fhw' "outcome,model_p,resample_p,rw_p,holm_p" _n
            forvalues i = 1/16 {
                local yvar : word `i' of `all_short'
                local fullname "`name_`yvar''"
                file write `fhw' "`fullname'" "," ///
                    (rw[`i',1]) "," (rw[`i',2]) "," ///
                    (rw[`i',3]) "," (rw[`i',4]) _n
            }
            file close `fhw'
            di "Romano-Wolf T1 results saved to: $RWOLF_T1_CSV"
        }
        else {
            di as error "rwolf failed with rc = " _rc
            di as error "Falling back to Bonferroni-Holm only."
        }

    restore

    * --- Bonferroni-Holm on equality tests (always run as backup) ---
    preserve
        clear
        input str32 outcome float p_raw
            "pct_told_to_report"       0.9893
            "pct_sent_to_courtroom"    0.1312
            "pct_questioned_voir_dire" 0.6706
            "utilization_rate"         0.4463
            "pct_capital_felony"       0.0084
            "pct_other_felony"         0.9364
            "pct_other_cases"          0.1277
            "summoned"                 0.1781
            "told_to_report"           0.0996
            "actually_reported"        0.0868
            "sent_to_courtroom"        0.1747
            "questioned_voir_dire"     0.1679
            "total_jury_verdicts"      0.0491
            "capital_felony"           0.0496
            "other_felony"             0.5696
            "other_cases"              0.8747
        end

        sort p_raw
        gen rank = _n
        gen n_tests = _N
        gen p_holm = p_raw * (n_tests - rank + 1)
        replace p_holm = min(p_holm, 1)
        replace p_holm = max(p_holm, p_holm[_n-1]) if _n > 1
        gen p_bonf = min(p_raw * n_tests, 1)

        di _n "=== Multiple Testing Adjustment (Bonferroni-Holm) ==="
        list outcome p_raw p_holm p_bonf, clean noobs

        global RWOLF_CSV "$OUTPUT/results/mi_multiple_testing_adj.csv"
        export delimited outcome p_raw p_holm p_bonf using "$RWOLF_CSV", replace
        di _n "Multiple testing results saved to: $RWOLF_CSV"
    restore
}


* =============================================================================
* WRAP-UP
* =============================================================================

di _n "========================================"
di "  07c_tost_and_rwolf.do COMPLETE"
di "  TOST results: $TOST_CSV"
di "  Multiple testing: $RWOLF_CSV"
di "========================================"
