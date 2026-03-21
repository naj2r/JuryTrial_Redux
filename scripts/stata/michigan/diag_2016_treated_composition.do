/*==============================================================================
  diag_2016_treated_composition.do

  Purpose:  Diagnose WHY 2016 drives the pooled headline results. Specifically:
            - Which counties are treated vs untreated in 2016 (T1 & T2)?
            - Are big/urban counties disproportionately in one group?
            - How does 2016 treatment composition compare to 2024?
            - Do individual 2016 observations exert outsized leverage?

  User hypothesis: "2016 driving results because big counties are the treated
                    group" — we test this by examining population distributions,
                    MSA membership, and individual-observation influence.

  Input:    $DATA_FINAL/michigan_panel_B.dta
  Output:   $DIAGNOSTICS/diag_2016_treated_composition.log

  Run:      do code/michigan/diag_2016_treated_composition.do
==============================================================================*/

set update_query off
set more off

capture log close _all

* --- Bootstrap paths ---
local rb "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
do "`rb'/code/master/paths.do"

log using "$DIAGNOSTICS/diag_2016_treated_composition.log", replace text

di _n as result "================================================================"
di as result "  2016 TREATED-COUNTY COMPOSITION DIAGNOSTIC"
di as result "  Dataset: michigan_panel_B.dta"
di as result "  Date: $S_DATE"
di as result "================================================================"

use "$DATA_FINAL/michigan_panel_B.dta", clear


/*==========================================================================
  SECTION 0: Embed Michigan county → major city / MSA crosswalk
  Source: US Census Bureau CBSA delineation (2020 vintage)

  These labels are hard-coded because no MSA file exists in the pipeline.
  MSA definitions follow OMB 2020 delineation for Michigan CBSAs.
==========================================================================*/

* Create MSA variable based on county name
gen str60 msa = ""
gen str40 major_city = ""

* --- Detroit-Warren-Dearborn MSA ---
replace msa = "Detroit-Warren-Dearborn" if inlist(county, "Wayne", "Oakland", "Macomb", "Livingston", "Lapeer", "St. Clair")
replace major_city = "Detroit" if county == "Wayne"
replace major_city = "Pontiac/Troy/Southfield" if county == "Oakland"
replace major_city = "Mt. Clemens/Warren" if county == "Macomb"
replace major_city = "Howell" if county == "Livingston"
replace major_city = "Lapeer" if county == "Lapeer"
replace major_city = "Port Huron" if county == "St. Clair"

* --- Grand Rapids-Kentwood MSA ---
replace msa = "Grand Rapids-Kentwood" if inlist(county, "Kent", "Ottawa", "Barry", "Montcalm")
replace major_city = "Grand Rapids" if county == "Kent"
replace major_city = "Holland/Grand Haven" if county == "Ottawa"
replace major_city = "Hastings" if county == "Barry"
replace major_city = "Greenville/Stanton" if county == "Montcalm"

* --- Lansing-East Lansing MSA ---
replace msa = "Lansing-East Lansing" if inlist(county, "Ingham", "Eaton", "Clinton")
replace major_city = "Lansing/East Lansing" if county == "Ingham"
replace major_city = "Charlotte" if county == "Eaton"
replace major_city = "St. Johns" if county == "Clinton"

* --- Kalamazoo-Portage MSA ---
replace msa = "Kalamazoo-Portage" if inlist(county, "Kalamazoo", "Van Buren")
replace major_city = "Kalamazoo" if county == "Kalamazoo"
replace major_city = "Paw Paw/South Haven" if county == "Van Buren"

* --- Flint MSA ---
replace msa = "Flint" if county == "Genesee"
replace major_city = "Flint" if county == "Genesee"

* --- Ann Arbor MSA ---
replace msa = "Ann Arbor" if county == "Washtenaw"
replace major_city = "Ann Arbor" if county == "Washtenaw"

* --- Saginaw MSA ---
replace msa = "Saginaw" if county == "Saginaw"
replace major_city = "Saginaw" if county == "Saginaw"

* --- Bay City MSA ---
replace msa = "Bay City" if county == "Bay"
replace major_city = "Bay City" if county == "Bay"

* --- Midland MSA ---
replace msa = "Midland" if county == "Midland"
replace major_city = "Midland" if county == "Midland"

* --- Battle Creek MSA ---
replace msa = "Battle Creek" if county == "Calhoun"
replace major_city = "Battle Creek" if county == "Calhoun"

* --- Jackson MSA ---
replace msa = "Jackson" if county == "Jackson"
replace major_city = "Jackson" if county == "Jackson"

* --- Monroe MSA ---
replace msa = "Monroe" if county == "Monroe"
replace major_city = "Monroe" if county == "Monroe"

* --- Muskegon MSA ---
replace msa = "Muskegon" if inlist(county, "Muskegon", "Oceana")
replace major_city = "Muskegon" if county == "Muskegon"
replace major_city = "Hart/Shelby" if county == "Oceana"

* --- Niles MSA ---
replace msa = "Niles" if county == "Berrien"
replace major_city = "Benton Harbor/St. Joseph" if county == "Berrien"

* --- Traverse City Micro ---
replace msa = "Traverse City (micro)" if inlist(county, "Grand Traverse", "Leelanau", "Benzie", "Kalkaska")
replace major_city = "Traverse City" if county == "Grand Traverse"
replace major_city = "Suttons Bay/Leland" if county == "Leelanau"
replace major_city = "Frankfort/Beulah" if county == "Benzie"
replace major_city = "Kalkaska" if county == "Kalkaska"

* --- Marquette Micro ---
replace msa = "Marquette (micro)" if county == "Marquette"
replace major_city = "Marquette" if county == "Marquette"

* --- Allegan ---
replace major_city = "Allegan/Plainwell" if county == "Allegan"
replace msa = "Allegan (micro)" if county == "Allegan"

* Remaining counties: small/rural
replace major_city = county if major_city == ""
replace msa = "Non-MSA (rural)" if msa == ""

* Population size classification
gen str20 pop_class = ""
replace pop_class = "Large (>200k)"    if county_pop > 200000 & !missing(county_pop)
replace pop_class = "Medium (50-200k)" if county_pop > 50000 & county_pop <= 200000
replace pop_class = "Small (10-50k)"   if county_pop > 10000 & county_pop <= 50000
replace pop_class = "Rural (<10k)"     if county_pop <= 10000 & !missing(county_pop)

* Population quartiles (within-year)
* xtile is a command, not egen function — generate then label
xtile pop_quartile = county_pop if year == 2016, n(4)
* Use 2016 quartile boundaries for all years (stable reference)
qui sum county_pop if pop_quartile == 1 & year == 2016
local q1_max = r(max)
qui sum county_pop if pop_quartile == 2 & year == 2016
local q2_max = r(max)
qui sum county_pop if pop_quartile == 3 & year == 2016
local q3_max = r(max)
replace pop_quartile = 1 if county_pop <= `q1_max' & missing(pop_quartile)
replace pop_quartile = 2 if county_pop > `q1_max' & county_pop <= `q2_max' & missing(pop_quartile)
replace pop_quartile = 3 if county_pop > `q2_max' & county_pop <= `q3_max' & missing(pop_quartile)
replace pop_quartile = 4 if county_pop > `q3_max' & !missing(county_pop) & missing(pop_quartile)
label define pop_q 1 "Q1 (smallest)" 2 "Q2" 3 "Q3" 4 "Q4 (largest)"
label values pop_quartile pop_q

* Log population for regressions
gen ln_pop = ln(county_pop)


/*==========================================================================
  SECTION 1: 2016 TREATMENT COMPOSITION — T1 (Electoral Pressure)

  T1 = treat_pros_pressure = incumbent running for re-election
  Untreated in 2016 = open-seat counties (no incumbent ran)
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 1: T1 (PRESSURE) — 2016 TREATED vs UNTREATED"
di as result "================================================================"

* --- List all UNTREATED counties in 2016 with population & city info ---
di _n as text "=== UNTREATED counties in 2016 (open seats — no incumbent ran) ==="
preserve
    keep if year == 2016 & treat_pros_pressure == 0
    sort county_pop
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)

    di _n as text "Summary of untreated group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
    di as text "  Min:  " %12.0fc r(min) "  Max: " %12.0fc r(max)
restore

* --- List TREATED counties (top 15 by population) ---
di _n as text "=== TREATED counties in 2016 — Top 15 by population ==="
preserve
    keep if year == 2016 & treat_pros_pressure == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class in 1/15, noobs sep(0)

    di _n as text "Summary of treated group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
    di as text "  Min:  " %12.0fc r(min) "  Max: " %12.0fc r(max)
restore

* --- Population distribution comparison ---
di _n as text "=== Population distribution: Treated vs Untreated in 2016 ==="
preserve
    keep if year == 2016
    tabstat county_pop, by(treat_pros_pressure) ///
        stat(n mean sd p10 p25 p50 p75 p90 sum) format(%12.0fc)

    di _n as text "T-test: population by T1 treatment status"
    ttest county_pop, by(treat_pros_pressure)

    di _n as text "Ranksum (Wilcoxon): population by T1 treatment status"
    ranksum county_pop, by(treat_pros_pressure)
restore

* --- Population class breakdown ---
di _n as text "=== Population class by T1 treatment status in 2016 ==="
preserve
    keep if year == 2016
    tab pop_class treat_pros_pressure, row col chi2
restore

* --- MSA breakdown ---
di _n as text "=== MSA membership by T1 treatment status in 2016 ==="
preserve
    keep if year == 2016
    gen in_msa = !regexm(msa, "Non-MSA|micro")
    tab in_msa treat_pros_pressure, row col chi2

    di _n as text "MSA metro membership:"
    tab msa treat_pros_pressure if in_msa == 1, col
restore


/*==========================================================================
  SECTION 2: 2016 TREATMENT COMPOSITION — T2 (Contested General Election)

  T2 = treat_pros_contested_long = incumbent faced general-election opponent
  Excludes primary-only contested counties from sample
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 2: T2 (CONTESTED) — 2016 COMPOSITION"
di as result "================================================================"

* --- List all CONTESTED counties in 2016 ---
di _n as text "=== CONTESTED counties in 2016 (general election opponent) ==="
preserve
    keep if year == 2016 & treat_pros_contested_long == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)

    di _n as text "Summary of contested group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
restore

* --- List UNCONTESTED counties (T1=1 but T2=0) in 2016 ---
di _n as text "=== UNCONTESTED counties in 2016 (incumbent ran, no general opponent) ==="
preserve
    keep if year == 2016 & treat_pros_uncontested == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class in 1/15, noobs sep(0)
    di _n as text "  N = " _N
    qui sum county_pop
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
restore

* --- Population distribution by T2 status ---
di _n as text "=== Population distribution by T2 (contested) in 2016 ==="
preserve
    keep if year == 2016 & treat_pros_pressure == 1  // T2 sample only
    tabstat county_pop, by(treat_pros_contested_long) ///
        stat(n mean sd p25 p50 p75 sum) format(%12.0fc)

    ttest county_pop, by(treat_pros_contested_long)
restore


/*==========================================================================
  SECTION 3: COMPARISON WITH 2024

  How does the 2016 treatment composition differ from 2024?
  Key question: are the same counties in the same treatment groups?
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 3: 2016 vs 2024 TREATMENT COMPOSITION"
di as result "================================================================"

* --- Side-by-side treatment rates ---
di _n as text "=== Treatment rates by election year ==="
preserve
    keep if inlist(year, 2016, 2024)
    table year, stat(mean treat_pros_pressure treat_pros_contested_long ///
        treat_pros_uncontested) stat(count county) nformat(%9.3f)
restore

* --- UNTREATED counties in 2024 ---
di _n as text "=== UNTREATED counties in 2024 (open seats) ==="
preserve
    keep if year == 2024 & treat_pros_pressure == 0
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)

    di _n as text "Summary of 2024 untreated group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
restore

* --- Population comparison: untreated groups across cycles ---
di _n as text "=== Mean population of UNTREATED counties: 2016 vs 2024 ==="
preserve
    keep if inlist(year, 2016, 2024)
    keep if treat_pros_pressure == 0
    tabstat county_pop, by(year) stat(n mean sd p50 sum) format(%12.0fc)
restore

* --- CONTESTED counties in 2024 ---
di _n as text "=== CONTESTED counties in 2024 (general election opponent) ==="
preserve
    keep if year == 2024 & treat_pros_contested_long == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)

    di _n as text "Summary of 2024 contested group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
restore

* --- Treatment stability: which counties switched treatment status? ---
di _n as text "=== Treatment stability: counties that changed T1 status 2016→2024 ==="
preserve
    keep if inlist(year, 2016, 2024)
    keep county year treat_pros_pressure county_pop major_city
    reshape wide treat_pros_pressure county_pop, i(county) j(year)

    * Counties treated in 2016 but not 2024
    gen switched_to_untreated = (treat_pros_pressure2016 == 1 & treat_pros_pressure2024 == 0)
    gen switched_to_treated = (treat_pros_pressure2016 == 0 & treat_pros_pressure2024 == 1)
    gen stayed_treated = (treat_pros_pressure2016 == 1 & treat_pros_pressure2024 == 1)
    gen stayed_untreated = (treat_pros_pressure2016 == 0 & treat_pros_pressure2024 == 0)

    di _n as text "Switchers: Treated in 2016 → Untreated in 2024"
    list county major_city county_pop2016 if switched_to_untreated, noobs
    di "  N = " _N * switched_to_untreated

    di _n as text "Switchers: Untreated in 2016 → Treated in 2024"
    list county major_city county_pop2016 if switched_to_treated, noobs
    di "  N = " _N * switched_to_treated

    di _n as text "Stayers: summary"
    tab stayed_treated
    tab stayed_untreated

    qui sum county_pop2016 if switched_to_untreated
    di as text "Mean pop of 2016→untreated switchers: " %12.0fc r(mean)
    qui sum county_pop2016 if switched_to_treated
    di as text "Mean pop of 2016→treated switchers:   " %12.0fc r(mean)
restore


/*==========================================================================
  SECTION 4: DOES POPULATION PREDICT TREATMENT?

  If treatment status is systematically related to county size,
  the TWFE estimate could be confounded by size-correlated trends.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 4: DOES POPULATION PREDICT TREATMENT?"
di as result "================================================================"

* --- Logit: T1 on log population, election years only ---
di _n as text "=== Logit: T1 ~ ln(population) in election years ==="
preserve
    keep if inlist(year, 2016, 2024)
    logit treat_pros_pressure ln_pop, robust
    margins, dydx(ln_pop) atmeans

    * Separate by year
    di _n as text "--- 2016 only ---"
    logit treat_pros_pressure ln_pop if year == 2016, robust

    di _n as text "--- 2024 only ---"
    logit treat_pros_pressure ln_pop if year == 2024, robust
restore

* --- Logit: T2 on log population, election years only ---
di _n as text "=== Logit: T2 (contested) ~ ln(population) in election years ==="
preserve
    keep if inlist(year, 2016, 2024) & treat_pros_pressure == 1
    logit treat_pros_contested_long ln_pop, robust

    di _n as text "--- 2016 only ---"
    logit treat_pros_contested_long ln_pop if year == 2016, robust

    di _n as text "--- 2024 only ---"
    logit treat_pros_contested_long ln_pop if year == 2024, robust
restore


/*==========================================================================
  SECTION 5: OUTCOME MEANS BY TREATMENT × POPULATION SIZE

  Do large treated counties drive the positive coefficient?
  Or do small untreated counties pull down the control?
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 5: OUTCOMES BY TREATMENT × POPULATION SIZE"
di as result "================================================================"

* --- 2x2: Treatment × Above/Below median population ---
di _n as text "=== Mean outcomes: Treatment × Population half, 2016 only ==="
preserve
    keep if year == 2016

    * Median population split
    qui sum county_pop, detail
    gen above_median_pop = (county_pop > r(p50))
    label define abmed 0 "Below median pop" 1 "Above median pop"
    label values above_median_pop abmed

    * Pipeline outcomes
    foreach v in actually_reported told_to_report summoned ///
                 pct_told_to_report total_jury_verdicts {
        di _n as text "=== `v' ==="
        table treat_pros_pressure above_median_pop, ///
            stat(mean `v') stat(n `v') nformat(%9.1f)
    }
restore

* --- Same for T2 ---
di _n as text "=== Mean outcomes: Contested × Population half, 2016 only ==="
preserve
    keep if year == 2016 & treat_pros_pressure == 1
    qui sum county_pop, detail
    gen above_median_pop = (county_pop > r(p50))
    label values above_median_pop abmed

    foreach v in actually_reported told_to_report summoned {
        di _n as text "=== `v' ==="
        table treat_pros_contested_long above_median_pop, ///
            stat(mean `v') stat(n `v') nformat(%9.1f)
    }
restore

* --- Population quartile breakdown in all years ---
di _n as text "=== Mean outcomes by T1 × Pop quartile, all years ==="
table treat_pros_pressure pop_quartile, ///
    stat(mean actually_reported) stat(n actually_reported) nformat(%9.1f)


/*==========================================================================
  SECTION 6: INDIVIDUAL OBSERVATION INFLUENCE (2016)

  Leave-one-out: drop each 2016 county and re-estimate the T1 coefficient.
  Identifies which specific counties are most influential.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 6: LEAVE-ONE-OUT INFLUENCE ANALYSIS (2016)"
di as result "================================================================"

* --- Baseline regression (full sample) ---
di _n as text "=== Baseline T1 regression: actually_reported ==="
qui reghdfe actually_reported treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
local beta_full = _b[treat_pros_pressure]
local se_full = _se[treat_pros_pressure]
local t_full = `beta_full' / `se_full'
di as text "Full-sample beta: " %9.3f `beta_full' "  SE: " %9.3f `se_full' "  t: " %6.3f `t_full'

* --- Leave-one-out: drop each 2016 county ---
* Store county IDs present in 2016
preserve
    keep if year == 2016
    levelsof county_id, local(counties_2016)
restore

* Create results storage
tempfile loo_results
postfile loo_handle str40 county_name double(beta_loo se_loo t_loo dfbeta pct_change county_pop_val) ///
    byte(was_treated) using `loo_results'

foreach cid of local counties_2016 {
    * Get county name and treatment status
    qui sum treat_pros_pressure if county_id == `cid' & year == 2016
    local was_trt = r(mean)

    qui levelsof county if county_id == `cid', local(cname) clean

    qui sum county_pop if county_id == `cid' & year == 2016
    local cpop = r(mean)

    * Re-estimate dropping this county's 2016 observation
    qui reghdfe actually_reported treat_pros_pressure ///
        if !(county_id == `cid' & year == 2016), ///
        absorb(county_id year) vce(cluster county_id)

    local b_loo = _b[treat_pros_pressure]
    local s_loo = _se[treat_pros_pressure]
    local t_loo = `b_loo' / `s_loo'
    local dfb = `beta_full' - `b_loo'
    local pctchg = 100 * (`beta_full' - `b_loo') / abs(`beta_full')

    post loo_handle ("`cname'") (`b_loo') (`s_loo') (`t_loo') (`dfb') (`pctchg') (`cpop') (`was_trt')
}

postclose loo_handle

* --- Display influence results ---
di _n as text "=== Leave-one-out influence: T1 coefficient on actually_reported ==="
di as text "  Full-sample: beta = " %9.3f `beta_full' "  SE = " %9.3f `se_full' "  t = " %6.3f `t_full'

preserve
    use `loo_results', clear

    * Sort by absolute DFBETA (most influential first)
    gen abs_dfbeta = abs(dfbeta)
    gsort -abs_dfbeta

    di _n as text "--- Top 20 most influential 2016 counties (by |DFBETA|) ---"
    di as text "  county            | beta_loo  |  SE_loo  |  t_loo | DFBETA  |  %chg  |  pop    | treated"
    di as text "  ------------------+-----------+----------+--------+---------+--------+---------+--------"

    list county_name beta_loo se_loo t_loo dfbeta pct_change county_pop_val was_treated in 1/20, ///
        noobs sep(0) table

    * Summary statistics
    di _n as text "--- Influence summary ---"
    di as text "Range of LOO betas:  " %9.3f beta_loo[_N] " to " %9.3f beta_loo[1]
    qui sum beta_loo
    di as text "Mean LOO beta:       " %9.3f r(mean)
    di as text "SD LOO beta:         " %9.3f r(sd)

    * Count how many LOO drops flip significance
    gen sig_loo = abs(t_loo) > 1.96
    qui sum sig_loo
    di as text "LOO drops where coefficient stays significant (p<.05): " r(sum) " / " r(N)

    gen sig10_loo = abs(t_loo) > 1.645
    qui sum sig10_loo
    di as text "LOO drops where coefficient stays significant (p<.10): " r(sum) " / " r(N)

    * Correlation: influence vs population
    di _n as text "--- Correlation: |DFBETA| vs population ---"
    corr abs_dfbeta county_pop_val

    di _n as text "--- Correlation: |DFBETA| vs ln(population) ---"
    gen ln_pop_val = ln(county_pop_val)
    corr abs_dfbeta ln_pop_val

    * Is influence concentrated in treated or untreated?
    di _n as text "--- Mean |DFBETA| by treatment status ---"
    tabstat abs_dfbeta, by(was_treated) stat(mean sd max n) format(%9.4f)

    drop abs_dfbeta sig_loo sig10_loo ln_pop_val
restore


/*==========================================================================
  SECTION 7: LEAVE-ONE-OUT FOR told_to_report AND pct_told_to_report

  Repeat the LOO analysis for the other headline outcomes.
  These are the borderline-significant results (p ≈ 0.05-0.07).
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 7: LOO INFLUENCE — told_to_report & pct_told_to_report"
di as result "================================================================"

foreach depvar in told_to_report pct_told_to_report {

    di _n as text "=============================================="
    di as text "  LOO for: `depvar'"
    di as text "=============================================="

    * Baseline
    qui reghdfe `depvar' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    local beta_full = _b[treat_pros_pressure]
    local se_full = _se[treat_pros_pressure]
    local t_full = `beta_full' / `se_full'
    di as text "Full-sample: beta = " %9.4f `beta_full' "  SE = " %9.4f `se_full' "  t = " %6.3f `t_full'

    * LOO
    preserve
        keep if year == 2016
        levelsof county_id, local(counties_2016)
    restore

    tempfile loo_`depvar'
    postfile loo2_handle str40 county_name double(beta_loo dfbeta county_pop_val) ///
        byte(was_treated) using `loo_`depvar''

    foreach cid of local counties_2016 {
        qui levelsof county if county_id == `cid', local(cname) clean
        qui sum county_pop if county_id == `cid' & year == 2016
        local cpop = r(mean)
        qui sum treat_pros_pressure if county_id == `cid' & year == 2016
        local was_trt = r(mean)

        qui reghdfe `depvar' treat_pros_pressure ///
            if !(county_id == `cid' & year == 2016), ///
            absorb(county_id year) vce(cluster county_id)

        local b_loo = _b[treat_pros_pressure]
        local dfb = `beta_full' - `b_loo'

        post loo2_handle ("`cname'") (`b_loo') (`dfb') (`cpop') (`was_trt')
    }
    postclose loo2_handle

    preserve
        use `loo_`depvar'', clear
        gen abs_dfbeta = abs(dfbeta)
        gsort -abs_dfbeta

        di _n as text "--- Top 10 most influential (|DFBETA|) ---"
        list county_name beta_loo dfbeta county_pop_val was_treated in 1/10, noobs sep(0)

        di _n as text "--- Mean |DFBETA| by treatment status ---"
        tabstat abs_dfbeta, by(was_treated) stat(mean sd max n) format(%9.5f)

        drop abs_dfbeta
    restore
}


/*==========================================================================
  SECTION 8: FULL ELECTION-YEAR COMPARISON

  Drop entire 2016 cycle (2016+2017) vs drop 2024 cycle (2024+off-years)
  to see which cycle drives the estimate.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 8: CYCLE-SPECIFIC REGRESSIONS"
di as result "================================================================"

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "=== `depvar' ==="

    * Full sample
    qui reghdfe `depvar' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    di as text "Full sample: beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] ///
        "  p = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

    * Drop 2016
    qui reghdfe `depvar' treat_pros_pressure if year != 2016, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "Drop 2016:   beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] ///
        "  p = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

    * Drop 2024
    qui reghdfe `depvar' treat_pros_pressure if year != 2024, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "Drop 2024:   beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] ///
        "  p = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

    * Only 2016 cycle (2016-2019)
    qui reghdfe `depvar' treat_pros_pressure if year <= 2019, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "2016 cycle:  beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] ///
        "  p = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))

    * Only 2024 cycle (2022-2024)
    qui reghdfe `depvar' treat_pros_pressure if year >= 2022, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "2024 cycle:  beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] ///
        "  p = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
}


/*==========================================================================
  SECTION 9: TREATMENT-POPULATION INTERACTION

  Does the treatment effect vary with county size?
  If the 2016 result is driven by large treated counties, an interaction
  of treatment × ln(population) should be significant.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 9: TREATMENT × POPULATION INTERACTION"
di as result "================================================================"

gen treat_x_lnpop = treat_pros_pressure * ln_pop

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "=== `depvar' ==="

    * Main effect only
    qui reghdfe `depvar' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    di as text "Main only:    beta_treat = " %9.3f _b[treat_pros_pressure]

    * With interaction (absorbing ln_pop isn't possible with county FE, so just interaction)
    reghdfe `depvar' treat_pros_pressure treat_x_lnpop, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "With interaction: beta_treat = " %9.3f _b[treat_pros_pressure] ///
        "  beta_interact = " %9.5f _b[treat_x_lnpop] ///
        "  p(interact) = " %6.4f 2*ttail(e(N_clust)-1, abs(_b[treat_x_lnpop]/_se[treat_x_lnpop]))
}

drop treat_x_lnpop


/*==========================================================================
  SECTION 10: WEIGHTED vs UNWEIGHTED COMPARISON

  If big counties drive the result, population-weighting should change
  the estimate substantially. Compare weighted vs unweighted.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 10: WEIGHTED vs UNWEIGHTED REGRESSIONS"
di as result "================================================================"

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "=== `depvar' ==="

    * Unweighted (our specification)
    qui reghdfe `depvar' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    di as text "Unweighted:   beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure]

    * Population-weighted
    qui reghdfe `depvar' treat_pros_pressure [aw=county_pop], absorb(county_id year) vce(cluster county_id)
    di as text "Pop-weighted: beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure]

    * Inverse-pop-weighted (upweights small counties)
    gen inv_pop = 1/county_pop
    qui reghdfe `depvar' treat_pros_pressure [aw=inv_pop], absorb(county_id year) vce(cluster county_id)
    di as text "Inv-pop-wt:   beta = " %9.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure]
    drop inv_pop
}


/*==========================================================================
  SECTION 11: CONTROL GROUP DEEP DIVE

  The key TWFE insight: with county FEs, the "control" in an election year
  is (a) counties that are untreated in that election year, AND
  (b) all counties in non-election years. The 9 open-seat counties in 2016
  serve as the within-election-year control. If those counties happen to have
  an unusual 2016 (e.g., Kent and Ingham pull down the control mean),
  the treatment effect is inflated.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 11: CONTROL GROUP DEEP DIVE (2016 UNTREATED COUNTIES)"
di as result "================================================================"

* For each untreated 2016 county: how does their 2016 outcome compare
* to their own time-series mean?
di _n as text "=== Within-county deviations: UNTREATED 2016 counties ==="
preserve
    * Keep the 9 untreated 2016 counties
    keep if year == 2016 & treat_pros_pressure == 0
    levelsof county_id, local(untrt_counties)
restore

preserve
    * Get all years for these counties
    gen is_untrt_2016 = 0
    foreach cid of local untrt_counties {
        replace is_untrt_2016 = 1 if county_id == `cid'
    }
    keep if is_untrt_2016 == 1

    * County mean over all years
    bys county_id: egen cmean_ar = mean(actually_reported)
    bys county_id: egen cmean_ttr = mean(told_to_report)

    * 2016 deviation
    gen dev_ar = actually_reported - cmean_ar
    gen dev_ttr = told_to_report - cmean_ttr

    di as text "Within-county deviations for the 2016 control group:"
    keep if year == 2016
    gsort -county_pop
    list county county_pop actually_reported cmean_ar dev_ar ///
        told_to_report cmean_ttr dev_ttr, noobs sep(0)

    di _n as text "Summary: are untreated 2016 counties below their own mean?"
    tabstat dev_ar dev_ttr, stat(mean sd min max) format(%9.1f)

    * One-sample t-test: is mean deviation significantly different from 0?
    di _n as text "One-sample t-test: mean deviation = 0?"
    ttest dev_ar == 0
    ttest dev_ttr == 0

    drop is_untrt_2016
restore


/*==========================================================================
  SECTION 12: T3 (CONTESTED — ANY STAGE) COMPOSITION IN 2016

  T3 = treat_pros_contested = incumbent faced opponent in primary OR general
  This is the broader definition. T2 (contested_long) ⊂ T3 (contested).
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 12: T3 (CONTESTED ANY STAGE) — 2016 COMPOSITION"
di as result "================================================================"

* Generate primary-only flag
capture gen treat_pros_primary_only = (treat_pros_contested == 1 & treat_pros_contested_long == 0)

di _n as text "=== T3: CONTESTED counties in 2016 (any-stage opponent) ==="
preserve
    keep if year == 2016 & treat_pros_contested == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)

    di _n as text "Summary of T3 contested group:"
    di as text "  N = " _N
    qui sum county_pop
    di as text "  Total population:  " %12.0fc r(sum)
    di as text "  Mean population:   " %12.0fc r(mean)
    di as text "  Median population: " %12.0fc r(p50)
restore

di _n as text "=== PRIMARY-ONLY contested in 2016 (in T3 but not T2) ==="
preserve
    keep if year == 2016 & treat_pros_primary_only == 1
    gsort -county_pop
    list county major_city msa county_pop pop_class, noobs sep(0)
    di _n as text "  N = " _N
    qui sum county_pop
    if _N > 0 di as text "  Mean population: " %12.0fc r(mean)
restore

di _n as text "=== Treatment variable summary: 2016 ==="
preserve
    keep if year == 2016
    di "  T1 (pressure):         " _N " obs, " %3.0f 100*r(mean) "% treated"
    qui sum treat_pros_pressure
    di "  T1 (pressure):         " _N " obs, N_treated = " %3.0f r(sum)
    qui sum treat_pros_contested_long
    di "  T2 (contested_long):   " _N " obs, N_treated = " %3.0f r(sum)
    qui sum treat_pros_contested
    di "  T3 (contested_any):    " _N " obs, N_treated = " %3.0f r(sum)
    qui sum treat_pros_uncontested
    di "  Uncontested:           " _N " obs, N = " %3.0f r(sum)
    qui sum treat_pros_primary_only
    di "  Primary-only:          " _N " obs, N = " %3.0f r(sum)

    di _n as text "Cross-tabulation: T1 × T2 × T3"
    tab treat_pros_pressure treat_pros_contested_long
    tab treat_pros_pressure treat_pros_contested
    tab treat_pros_contested_long treat_pros_contested
restore


/*==========================================================================
  SECTION 13: CYCLE-SPECIFIC REGRESSIONS — ALL THREE TIERS

  The CRITICAL diagnostic: Does the 2016 sensitivity affect all treatment
  definitions, or only T1 (pressure)? If T2 and T3 also collapse when 2016
  is dropped, this is a broader data issue, not a T1-specific composition
  problem.

  T1: treat_pros_pressure (full sample)
  T2: treat_pros_contested_long + treat_pros_uncontested (exclude primary-only)
  T3: treat_pros_contested + treat_pros_uncontested (full sample)
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 13: CYCLE-SPECIFIC REGRESSIONS — ALL TIERS"
di as result "================================================================"

* --- T1: Already in Section 8, but repeat here for clean comparison ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  TIER 1: treat_pros_pressure (full sample)                 ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach depvar in actually_reported told_to_report pct_told_to_report ///
                  total_jury_verdicts {
    di _n as text "--- T1: `depvar' ---"

    * Full sample
    qui reghdfe `depvar' treat_pros_pressure, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
    di as text "  Full:      beta = " %10.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] "  p = " %6.4f `p' "  N = " e(N)

    * Drop 2016
    qui reghdfe `depvar' treat_pros_pressure if year != 2016, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
    di as text "  No 2016:   beta = " %10.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] "  p = " %6.4f `p' "  N = " e(N)

    * Drop 2024
    qui reghdfe `depvar' treat_pros_pressure if year != 2024, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
    di as text "  No 2024:   beta = " %10.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] "  p = " %6.4f `p' "  N = " e(N)

    * 2016 cycle only (2016-2019)
    qui reghdfe `depvar' treat_pros_pressure if year <= 2019, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
    di as text "  2016 cyc:  beta = " %10.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] "  p = " %6.4f `p' "  N = " e(N)

    * 2024 cycle only (2022-2024)
    qui reghdfe `depvar' treat_pros_pressure if year >= 2022, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_pressure]/_se[treat_pros_pressure]))
    di as text "  2024 cyc:  beta = " %10.3f _b[treat_pros_pressure] ///
        "  SE = " %9.3f _se[treat_pros_pressure] "  p = " %6.4f `p' "  N = " e(N)
}


* --- T2: Contested general (exclude primary-only) ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  TIER 2: treat_pros_contested_long (excl. primary-only)    ║"
di as text    "║  Coefficient reported: treat_pros_contested_long           ║"
di as text    "║  Also includes: treat_pros_uncontested                     ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach depvar in actually_reported told_to_report pct_told_to_report ///
                  total_jury_verdicts {
    di _n as text "--- T2: `depvar' ---"

    * Full T2 sample
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  Full:      b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * Drop 2016
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & year != 2016, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  No 2016:   b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * Drop 2024
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & year != 2024, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  No 2024:   b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * 2016 cycle only
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & year <= 2019, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  2016 cyc:  b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * 2024 cycle only
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & year >= 2022, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  2024 cyc:  b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)
}


* --- T3: Contested any stage (full sample) ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  TIER 3: treat_pros_contested (any-stage, full sample)     ║"
di as text    "║  Coefficient reported: treat_pros_contested                ║"
di as text    "║  Also includes: treat_pros_uncontested                     ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach depvar in actually_reported told_to_report pct_told_to_report ///
                  total_jury_verdicts {
    di _n as text "--- T3: `depvar' ---"

    * Full sample
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested]/_se[treat_pros_contested]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  Full:      b_cont = " %10.3f _b[treat_pros_contested] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * Drop 2016
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        if year != 2016, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested]/_se[treat_pros_contested]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  No 2016:   b_cont = " %10.3f _b[treat_pros_contested] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * Drop 2024
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        if year != 2024, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested]/_se[treat_pros_contested]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  No 2024:   b_cont = " %10.3f _b[treat_pros_contested] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * 2016 cycle only
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        if year <= 2019, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested]/_se[treat_pros_contested]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  2016 cyc:  b_cont = " %10.3f _b[treat_pros_contested] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)

    * 2024 cycle only
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        if year >= 2022, absorb(county_id year) vce(cluster county_id)
    local p = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_contested]/_se[treat_pros_contested]))
    local p_unc = 2*ttail(e(N_clust)-1, abs(_b[treat_pros_uncontested]/_se[treat_pros_uncontested]))
    di as text "  2024 cyc:  b_cont = " %10.3f _b[treat_pros_contested] ///
        "  p = " %6.4f `p' "  b_unc = " %10.3f _b[treat_pros_uncontested] ///
        "  p = " %6.4f `p_unc' "  N = " e(N)
}


/*==========================================================================
  SECTION 14: LEAVE-ONE-OUT INFLUENCE — T2 AND T3

  Same approach as Sections 6-7 but for the T2 and T3 treatment coefficients.
  For T2: drop each 2016 county (in T2 sample) and re-estimate
  For T3: drop each 2016 county and re-estimate

  Focus on actually_reported (headline outcome) for computational tractability.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 14: LOO INFLUENCE — T2 (contested_long) on actually_reported"
di as result "================================================================"

* --- T2 baseline ---
qui reghdfe actually_reported treat_pros_contested_long treat_pros_uncontested ///
    if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
local beta_full_t2 = _b[treat_pros_contested_long]
local se_full_t2 = _se[treat_pros_contested_long]
local t_full_t2 = `beta_full_t2' / `se_full_t2'
di as text "T2 Full-sample: beta_contested = " %9.3f `beta_full_t2' ///
    "  SE = " %9.3f `se_full_t2' "  t = " %6.3f `t_full_t2'

* --- Get 2016 counties in T2 sample ---
preserve
    keep if year == 2016 & treat_pros_primary_only != 1
    levelsof county_id, local(t2_counties_2016)
restore

* --- LOO loop ---
tempfile loo_t2
postfile loo_t2h str40 county_name double(beta_loo dfbeta county_pop_val) ///
    byte(was_contested) using `loo_t2'

foreach cid of local t2_counties_2016 {
    qui levelsof county if county_id == `cid', local(cname) clean
    qui sum county_pop if county_id == `cid' & year == 2016
    local cpop = r(mean)
    qui sum treat_pros_contested_long if county_id == `cid' & year == 2016
    local was_cont = r(mean)

    qui reghdfe actually_reported treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & !(county_id == `cid' & year == 2016), ///
        absorb(county_id year) vce(cluster county_id)

    local b_loo = _b[treat_pros_contested_long]
    local dfb = `beta_full_t2' - `b_loo'

    post loo_t2h ("`cname'") (`b_loo') (`dfb') (`cpop') (`was_cont')
}
postclose loo_t2h

preserve
    use `loo_t2', clear
    gen abs_dfbeta = abs(dfbeta)
    gsort -abs_dfbeta

    di _n as text "--- T2 LOO: Top 15 most influential (|DFBETA|) ---"
    list county_name beta_loo dfbeta county_pop_val was_contested in 1/15, noobs sep(0) table

    di _n as text "--- T2 Mean |DFBETA| by contested status ---"
    tabstat abs_dfbeta, by(was_contested) stat(mean sd max n) format(%9.4f)

    * How many LOO drops change sign or significance?
    gen sig_loo = abs(beta_loo / `se_full_t2') > 1.96
    qui sum sig_loo
    di as text "T2 LOO: stays significant (p<.05): " r(sum) " / " r(N)

    gen sig10 = abs(beta_loo / `se_full_t2') > 1.645
    qui sum sig10
    di as text "T2 LOO: stays significant (p<.10): " r(sum) " / " r(N)

    drop abs_dfbeta sig_loo sig10
restore


* --- T3: Contested any ---
di _n as result "================================================================"
di as result "  SECTION 14b: LOO INFLUENCE — T3 (contested) on actually_reported"
di as result "================================================================"

qui reghdfe actually_reported treat_pros_contested treat_pros_uncontested, ///
    absorb(county_id year) vce(cluster county_id)
local beta_full_t3 = _b[treat_pros_contested]
local se_full_t3 = _se[treat_pros_contested]
local t_full_t3 = `beta_full_t3' / `se_full_t3'
di as text "T3 Full-sample: beta_contested = " %9.3f `beta_full_t3' ///
    "  SE = " %9.3f `se_full_t3' "  t = " %6.3f `t_full_t3'

preserve
    keep if year == 2016
    levelsof county_id, local(t3_counties_2016)
restore

tempfile loo_t3
postfile loo_t3h str40 county_name double(beta_loo dfbeta county_pop_val) ///
    byte(was_contested) using `loo_t3'

foreach cid of local t3_counties_2016 {
    qui levelsof county if county_id == `cid', local(cname) clean
    qui sum county_pop if county_id == `cid' & year == 2016
    local cpop = r(mean)
    qui sum treat_pros_contested if county_id == `cid' & year == 2016
    local was_cont = r(mean)

    qui reghdfe actually_reported treat_pros_contested treat_pros_uncontested ///
        if !(county_id == `cid' & year == 2016), ///
        absorb(county_id year) vce(cluster county_id)

    local b_loo = _b[treat_pros_contested]
    local dfb = `beta_full_t3' - `b_loo'

    post loo_t3h ("`cname'") (`b_loo') (`dfb') (`cpop') (`was_cont')
}
postclose loo_t3h

preserve
    use `loo_t3', clear
    gen abs_dfbeta = abs(dfbeta)
    gsort -abs_dfbeta

    di _n as text "--- T3 LOO: Top 15 most influential (|DFBETA|) ---"
    list county_name beta_loo dfbeta county_pop_val was_contested in 1/15, noobs sep(0) table

    di _n as text "--- T3 Mean |DFBETA| by contested status ---"
    tabstat abs_dfbeta, by(was_contested) stat(mean sd max n) format(%9.4f)

    gen sig_loo = abs(beta_loo / `se_full_t3') > 1.96
    qui sum sig_loo
    di as text "T3 LOO: stays significant (p<.05): " r(sum) " / " r(N)

    gen sig10 = abs(beta_loo / `se_full_t3') > 1.645
    qui sum sig10
    di as text "T3 LOO: stays significant (p<.10): " r(sum) " / " r(N)

    drop abs_dfbeta sig_loo sig10
restore


/*==========================================================================
  SECTION 15: TREATMENT × POPULATION INTERACTION — ALL TIERS

  Does the treatment effect vary with county size for T2 and T3?
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 15: TREATMENT × POPULATION INTERACTION — ALL TIERS"
di as result "================================================================"

* --- T2: Contested_long × ln(pop) ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T2: treat_pros_contested_long × ln(pop)                   ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

gen cont_long_x_lnpop = treat_pros_contested_long * ln_pop
gen uncontested_x_lnpop = treat_pros_uncontested * ln_pop

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "--- T2: `depvar' ---"

    * Main effects only
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    di as text "  Main only:   b_cont = " %9.3f _b[treat_pros_contested_long]

    * With interaction
    reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        cont_long_x_lnpop uncontested_x_lnpop ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    local p_int = 2*ttail(e(N_clust)-1, abs(_b[cont_long_x_lnpop]/_se[cont_long_x_lnpop]))
    di as text "  Interact:    b_cont = " %9.3f _b[treat_pros_contested_long] ///
        "  b_int = " %9.5f _b[cont_long_x_lnpop] "  p(int) = " %6.4f `p_int'
}

drop cont_long_x_lnpop uncontested_x_lnpop


* --- T3: Contested × ln(pop) ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T3: treat_pros_contested × ln(pop)                        ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

gen cont_x_lnpop = treat_pros_contested * ln_pop
gen uncontested_x_lnpop = treat_pros_uncontested * ln_pop

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "--- T3: `depvar' ---"

    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  Main only:   b_cont = " %9.3f _b[treat_pros_contested]

    reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        cont_x_lnpop uncontested_x_lnpop, ///
        absorb(county_id year) vce(cluster county_id)
    local p_int = 2*ttail(e(N_clust)-1, abs(_b[cont_x_lnpop]/_se[cont_x_lnpop]))
    di as text "  Interact:    b_cont = " %9.3f _b[treat_pros_contested] ///
        "  b_int = " %9.5f _b[cont_x_lnpop] "  p(int) = " %6.4f `p_int'
}

drop cont_x_lnpop uncontested_x_lnpop


/*==========================================================================
  SECTION 16: WEIGHTED vs UNWEIGHTED — T2 AND T3
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 16: WEIGHTED vs UNWEIGHTED — T2 AND T3"
di as result "================================================================"

* --- T2 ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T2: Weighted regressions (contested_long)                 ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "--- T2: `depvar' ---"

    * Unweighted
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    di as text "  Unweighted:   b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  SE = " %9.3f _se[treat_pros_contested_long]

    * Pop-weighted
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        [aw=county_pop] if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    di as text "  Pop-wt:       b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  SE = " %9.3f _se[treat_pros_contested_long]

    * Inverse-pop-weighted
    gen inv_pop = 1/county_pop
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        [aw=inv_pop] if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    di as text "  Inv-pop-wt:   b_cont = " %10.3f _b[treat_pros_contested_long] ///
        "  SE = " %9.3f _se[treat_pros_contested_long]
    drop inv_pop
}

* --- T3 ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T3: Weighted regressions (contested any)                  ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach depvar in actually_reported told_to_report pct_told_to_report {
    di _n as text "--- T3: `depvar' ---"

    * Unweighted
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested, ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  Unweighted:   b_cont = " %10.3f _b[treat_pros_contested] ///
        "  SE = " %9.3f _se[treat_pros_contested]

    * Pop-weighted
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        [aw=county_pop], absorb(county_id year) vce(cluster county_id)
    di as text "  Pop-wt:       b_cont = " %10.3f _b[treat_pros_contested] ///
        "  SE = " %9.3f _se[treat_pros_contested]

    * Inverse-pop-weighted
    gen inv_pop = 1/county_pop
    qui reghdfe `depvar' treat_pros_contested treat_pros_uncontested ///
        [aw=inv_pop], absorb(county_id year) vce(cluster county_id)
    di as text "  Inv-pop-wt:   b_cont = " %10.3f _b[treat_pros_contested] ///
        "  SE = " %9.3f _se[treat_pros_contested]
    drop inv_pop
}


/*==========================================================================
  SECTION 17: CONTROL GROUP DEEP DIVE — T2 AND T3

  For T2/T3, the "control" within an election year is UNCONTESTED counties.
  If uncontested counties happen to have anomalously low outcomes in 2016,
  this inflates the contested-vs-uncontested gap just like the T1 case.
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 17: CONTROL GROUP DEEP DIVE — T2 & T3 UNCONTESTED"
di as result "================================================================"

* --- T2 control group: uncontested counties in 2016 ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T2 control group: UNCONTESTED counties in 2016            ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

preserve
    keep if year == 2016 & treat_pros_uncontested == 1
    levelsof county_id, local(unc_counties)
    di as text "N uncontested in 2016: " _N
restore

preserve
    gen is_unc_2016 = 0
    foreach cid of local unc_counties {
        replace is_unc_2016 = 1 if county_id == `cid'
    }
    keep if is_unc_2016 == 1

    bys county_id: egen cmean_ar = mean(actually_reported)
    bys county_id: egen cmean_ttr = mean(told_to_report)

    gen dev_ar = actually_reported - cmean_ar
    gen dev_ttr = told_to_report - cmean_ttr

    di as text "Within-county deviations for 2016 UNCONTESTED counties:"
    keep if year == 2016
    gsort -county_pop

    * Show top 15 (there may be 50+ uncontested counties)
    di _n as text "Top 15 by population:"
    list county county_pop actually_reported cmean_ar dev_ar ///
        told_to_report cmean_ttr dev_ttr in 1/15, noobs sep(0)

    di _n as text "Summary: are uncontested 2016 counties below their own mean?"
    tabstat dev_ar dev_ttr, stat(mean sd min max n) format(%9.1f)

    di _n as text "One-sample t-test: mean deviation = 0?"
    ttest dev_ar == 0
    ttest dev_ttr == 0

    drop is_unc_2016
restore

* --- T2 treated group: contested_long counties in 2016 ---
di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  T2 treated group: CONTESTED (general) counties in 2016    ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

preserve
    keep if year == 2016 & treat_pros_contested_long == 1
    levelsof county_id, local(cont_counties)
    di as text "N contested_long in 2016: " _N
restore

preserve
    gen is_cont_2016 = 0
    foreach cid of local cont_counties {
        replace is_cont_2016 = 1 if county_id == `cid'
    }
    keep if is_cont_2016 == 1

    bys county_id: egen cmean_ar = mean(actually_reported)
    bys county_id: egen cmean_ttr = mean(told_to_report)

    gen dev_ar = actually_reported - cmean_ar
    gen dev_ttr = told_to_report - cmean_ttr

    di as text "Within-county deviations for 2016 CONTESTED (general) counties:"
    keep if year == 2016
    gsort -county_pop

    di _n as text "Top 15 by population:"
    list county county_pop actually_reported cmean_ar dev_ar ///
        told_to_report cmean_ttr dev_ttr in 1/15, noobs sep(0)

    di _n as text "Summary: are contested 2016 counties above their own mean?"
    tabstat dev_ar dev_ttr, stat(mean sd min max n) format(%9.1f)

    di _n as text "One-sample t-test: mean deviation = 0?"
    ttest dev_ar == 0
    ttest dev_ttr == 0

    drop is_cont_2016
restore


/*==========================================================================
  SECTION 18: ChatGPT follow-up diagnostics

  Addresses 6 specific follow-up questions from structured review:

  Q1: What % of total treated jury volume comes from top 3 counties in 2016?
      (concentration of treatment effect in large counties)
  Q2: Re-run T2 excluding Wayne AND Macomb simultaneously — does the effect
      survive? (joint influence test, stronger than single-county LOO)
  Q3: 2024 contested counties population distribution vs 2016
      (is the large-county concentration stable across election cycles?)
  Q4: Wayne's within-2016 deviation from its own 2017-2023 average
      (is Wayne's 2016 an outlier relative to its OWN time series?)
  Q5: Were Wayne and Macomb contested in 2024?
      (if yes, the 2024 rate results also reflect large-county influence)
  Q6: Confirm that population interactions (Section 15) include year FE
      (already confirmed: absorb(county_id year) in Section 15 code)
==========================================================================*/

di _n as result "================================================================"
di as result "  SECTION 18: ChatGPT follow-up diagnostics"
di as result "================================================================"


* ─────────────────────────────────────────────────────────────────────
* Q1: Treatment-volume concentration in 2016 (all three tiers)
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q1: What % of treated jury volume comes from top 3        ║"
di as text    "║      counties in 2016?                                     ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

* T1 concentration
preserve
    keep if year == 2016 & treat_pros_pressure == 1
    local total_ar = 0
    local total_ttr = 0

    * Sum total across all treated counties
    qui su actually_reported
    local total_ar = r(sum)
    qui su told_to_report
    local total_ttr = r(sum)
    qui su county_pop
    local total_pop = r(sum)
    local n_treated = _N

    gsort -actually_reported

    di _n as text "─── T1 (pressure): `n_treated' treated counties in 2016 ───"
    di as text "Total actually_reported across all T1-treated: " %12.0fc `total_ar'
    di as text "Total told_to_report across all T1-treated:    " %12.0fc `total_ttr'

    * Top 3 by actually_reported
    local top3_ar = 0
    local top3_ttr = 0
    local top3_pop = 0
    forvalues i = 1/3 {
        local top3_ar = `top3_ar' + actually_reported[`i']
        local top3_ttr = `top3_ttr' + told_to_report[`i']
        local top3_pop = `top3_pop' + county_pop[`i']
    }

    di _n as text "Top 3 counties by actually_reported:"
    list county county_pop actually_reported told_to_report in 1/3, noobs sep(0)

    di _n as text "Concentration metrics:"
    di as text "  Top 3 share of actually_reported: " %5.1f (`top3_ar'/`total_ar'*100) "%"
    di as text "  Top 3 share of told_to_report:    " %5.1f (`top3_ttr'/`total_ttr'*100) "%"
    di as text "  Top 3 share of population:        " %5.1f (`top3_pop'/`total_pop'*100) "%"
    di as text "  → If pop share ≈ volume share: mechanical. If volume >> pop: something extra."

    * Full ranked list
    di _n as text "Full 2016 T1-treated counties ranked by actually_reported:"
    list county county_pop actually_reported told_to_report, noobs sep(0)
restore

* T2 concentration
preserve
    keep if year == 2016 & treat_pros_contested_long == 1
    local total_ar = 0
    local total_ttr = 0

    qui su actually_reported
    local total_ar = r(sum)
    qui su told_to_report
    local total_ttr = r(sum)
    qui su county_pop
    local total_pop = r(sum)
    local n_treated = _N

    gsort -actually_reported

    di _n as text "─── T2 (contested general): `n_treated' treated counties in 2016 ───"
    di as text "Total actually_reported across all T2-treated: " %12.0fc `total_ar'
    di as text "Total told_to_report across all T2-treated:    " %12.0fc `total_ttr'

    * Top 3 by actually_reported
    local top3_ar = 0
    local top3_ttr = 0
    local top3_pop = 0
    forvalues i = 1/3 {
        local top3_ar = `top3_ar' + actually_reported[`i']
        local top3_ttr = `top3_ttr' + told_to_report[`i']
        local top3_pop = `top3_pop' + county_pop[`i']
    }

    di _n as text "Top 3 counties by actually_reported:"
    list county county_pop actually_reported told_to_report in 1/3, noobs sep(0)

    di _n as text "Concentration metrics:"
    di as text "  Top 3 share of actually_reported: " %5.1f (`top3_ar'/`total_ar'*100) "%"
    di as text "  Top 3 share of told_to_report:    " %5.1f (`top3_ttr'/`total_ttr'*100) "%"
    di as text "  Top 3 share of population:        " %5.1f (`top3_pop'/`total_pop'*100) "%"

    di _n as text "Full 2016 T2-treated counties ranked by actually_reported:"
    list county county_pop actually_reported told_to_report, noobs sep(0)
restore

* T3 concentration
preserve
    keep if year == 2016 & treat_pros_contested == 1
    local total_ar = 0
    local total_ttr = 0

    qui su actually_reported
    local total_ar = r(sum)
    qui su told_to_report
    local total_ttr = r(sum)
    qui su county_pop
    local total_pop = r(sum)
    local n_treated = _N

    gsort -actually_reported

    di _n as text "─── T3 (contested any): `n_treated' treated counties in 2016 ───"
    di as text "Total actually_reported across all T3-treated: " %12.0fc `total_ar'
    di as text "Total told_to_report across all T3-treated:    " %12.0fc `total_ttr'

    * Top 3 by actually_reported
    local top3_ar = 0
    local top3_ttr = 0
    local top3_pop = 0
    forvalues i = 1/3 {
        local top3_ar = `top3_ar' + actually_reported[`i']
        local top3_ttr = `top3_ttr' + told_to_report[`i']
        local top3_pop = `top3_pop' + county_pop[`i']
    }

    di _n as text "Top 3 counties by actually_reported:"
    list county county_pop actually_reported told_to_report in 1/3, noobs sep(0)

    di _n as text "Concentration metrics:"
    di as text "  Top 3 share of actually_reported: " %5.1f (`top3_ar'/`total_ar'*100) "%"
    di as text "  Top 3 share of told_to_report:    " %5.1f (`top3_ttr'/`total_ttr'*100) "%"
    di as text "  Top 3 share of population:        " %5.1f (`top3_pop'/`total_pop'*100) "%"

    di _n as text "Full 2016 T3-treated counties ranked by actually_reported:"
    list county county_pop actually_reported told_to_report, noobs sep(0)
restore


* ─────────────────────────────────────────────────────────────────────
* Q2: T2 excluding Wayne AND Macomb simultaneously
*     (Joint influence test — stronger than single-county LOO)
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q2: T2 regression excluding Wayne + Macomb together       ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

di _n as text "─── Baseline T2 (full sample excl primary-only) ───"
foreach depvar in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)
    di as text "  `depvar': b=" %9.1f _b[treat_pros_contested_long] ///
        " se=" %8.1f _se[treat_pros_contested_long] ///
        " p=" %5.3f (2*ttail(e(df_r), abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))) ///
        " N=" %5.0f e(N)
}

di _n as text "─── T2 EXCLUDING Wayne AND Macomb (joint drop) ───"
foreach depvar in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & county != "Wayne" & county != "Macomb", ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  `depvar': b=" %9.1f _b[treat_pros_contested_long] ///
        " se=" %8.1f _se[treat_pros_contested_long] ///
        " p=" %5.3f (2*ttail(e(df_r), abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))) ///
        " N=" %5.0f e(N)
}

di _n as text "─── T2 EXCLUDING Wayne only ───"
foreach depvar in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & county != "Wayne", ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  `depvar': b=" %9.1f _b[treat_pros_contested_long] ///
        " se=" %8.1f _se[treat_pros_contested_long] ///
        " p=" %5.3f (2*ttail(e(df_r), abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))) ///
        " N=" %5.0f e(N)
}

di _n as text "─── T2 EXCLUDING Macomb only ───"
foreach depvar in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & county != "Macomb", ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  `depvar': b=" %9.1f _b[treat_pros_contested_long] ///
        " se=" %8.1f _se[treat_pros_contested_long] ///
        " p=" %5.3f (2*ttail(e(df_r), abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))) ///
        " N=" %5.0f e(N)
}

di _n as text "─── T2 EXCLUDING Wayne + Macomb + Kent (top 3) ───"
foreach depvar in actually_reported told_to_report pct_told_to_report total_jury_verdicts {
    qui reghdfe `depvar' treat_pros_contested_long treat_pros_uncontested ///
        if treat_pros_primary_only != 1 & county != "Wayne" & county != "Macomb" & county != "Kent", ///
        absorb(county_id year) vce(cluster county_id)
    di as text "  `depvar': b=" %9.1f _b[treat_pros_contested_long] ///
        " se=" %8.1f _se[treat_pros_contested_long] ///
        " p=" %5.3f (2*ttail(e(df_r), abs(_b[treat_pros_contested_long]/_se[treat_pros_contested_long]))) ///
        " N=" %5.0f e(N)
}


* ─────────────────────────────────────────────────────────────────────
* Q3: 2024 vs 2016 contested county population distributions
*     (Is the large-county concentration stable across cycles?)
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q3: Population distributions — 2016 vs 2024 contested     ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

* T2 contested counties by year
foreach yr in 2016 2024 {
    di _n as text "─── T2 contested_long counties in `yr' ───"
    preserve
        keep if year == `yr' & treat_pros_contested_long == 1
        gsort -county_pop
        di as text "N counties: " _N

        qui su county_pop
        di as text "Total pop: " %12.0fc r(sum)
        di as text "Mean pop:  " %12.0fc r(mean)
        di as text "Median pop:" %12.0fc r(p50)
        di as text "Max pop:   " %12.0fc r(max)
        di as text "Min pop:   " %12.0fc r(min)

        list county county_pop msa actually_reported told_to_report, noobs sep(0)
    restore
}

* Compare overlap: which counties were contested in BOTH 2016 and 2024?
di _n as text "─── Counties contested (T2) in BOTH 2016 and 2024 ───"
preserve
    keep if treat_pros_contested_long == 1 & inlist(year, 2016, 2024)
    bys county_id: gen n_contested_years = _N
    keep if n_contested_years == 2 & year == 2016  // one row per county
    gsort -county_pop
    di as text "N counties contested in both 2016 and 2024: " _N
    list county county_pop msa, noobs sep(0)
restore

* Counties contested in 2016 but NOT 2024
di _n as text "─── Counties contested (T2) in 2016 but NOT 2024 ───"
preserve
    * Get 2024 contested counties
    gen cont_2024 = (year == 2024 & treat_pros_contested_long == 1)
    bys county_id: egen ever_cont_2024 = max(cont_2024)

    keep if year == 2016 & treat_pros_contested_long == 1 & ever_cont_2024 == 0
    gsort -county_pop
    di as text "N counties: " _N
    list county county_pop msa actually_reported, noobs sep(0)
restore

* Counties contested in 2024 but NOT 2016
di _n as text "─── Counties contested (T2) in 2024 but NOT 2016 ───"
preserve
    gen cont_2016 = (year == 2016 & treat_pros_contested_long == 1)
    bys county_id: egen ever_cont_2016 = max(cont_2016)

    keep if year == 2024 & treat_pros_contested_long == 1 & ever_cont_2016 == 0
    gsort -county_pop
    di as text "N counties: " _N
    list county county_pop msa actually_reported, noobs sep(0)
restore


* ─────────────────────────────────────────────────────────────────────
* Q4: Wayne's within-county 2016 deviation from its 2017-2023 average
*     (Is Wayne's 2016 an outlier relative to its OWN time series?)
*     Extended: also show Macomb and Kent
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q4: Wayne, Macomb, Kent — 2016 vs own time-series mean    ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach bigcounty in "Wayne" "Macomb" "Kent" "Oakland" "Genesee" {
    di _n as text "═══ `bigcounty' County ═══"
    preserve
        keep if county == "`bigcounty'"

        * Non-2016 mean (the county's own baseline)
        qui su actually_reported if year != 2016
        local baseline_ar = r(mean)
        local baseline_ar_sd = r(sd)

        qui su told_to_report if year != 2016
        local baseline_ttr = r(mean)
        local baseline_ttr_sd = r(sd)

        qui su total_jury_verdicts if year != 2016
        local baseline_vjur = r(mean)

        * 2016 value
        qui su actually_reported if year == 2016
        local val_2016_ar = r(mean)

        qui su told_to_report if year == 2016
        local val_2016_ttr = r(mean)

        qui su total_jury_verdicts if year == 2016
        local val_2016_vjur = r(mean)

        * 2024 value (if exists)
        qui su actually_reported if year == 2024
        local val_2024_ar = r(mean)

        qui su told_to_report if year == 2024
        local val_2024_ttr = r(mean)

        * Deviation and z-score
        local dev_ar = `val_2016_ar' - `baseline_ar'
        local z_ar = `dev_ar' / `baseline_ar_sd'
        local dev_ttr = `val_2016_ttr' - `baseline_ttr'
        local z_ttr = `dev_ttr' / `baseline_ttr_sd'

        di as text "  Non-2016 mean actually_reported:  " %9.1f `baseline_ar' " (SD=" %6.1f `baseline_ar_sd' ")"
        di as text "  2016 actually_reported:           " %9.1f `val_2016_ar'
        di as text "  Deviation from mean:              " %9.1f `dev_ar' " (z=" %5.2f `z_ar' ")"
        di as text ""
        di as text "  Non-2016 mean told_to_report:     " %9.1f `baseline_ttr' " (SD=" %6.1f `baseline_ttr_sd' ")"
        di as text "  2016 told_to_report:              " %9.1f `val_2016_ttr'
        di as text "  Deviation from mean:              " %9.1f `dev_ttr' " (z=" %5.2f `z_ttr' ")"
        di as text ""
        di as text "  Non-2016 mean jury_verdicts:      " %9.1f `baseline_vjur'
        di as text "  2016 jury_verdicts:               " %9.1f `val_2016_vjur'
        di as text "  Verdict deviation:                " %9.1f (`val_2016_vjur' - `baseline_vjur')

        if `val_2024_ar' != . {
            local dev_2024_ar = `val_2024_ar' - `baseline_ar'
            local z_2024_ar = `dev_2024_ar' / `baseline_ar_sd'
            di as text ""
            di as text "  2024 actually_reported:           " %9.1f `val_2024_ar'
            di as text "  2024 deviation from mean:         " %9.1f `dev_2024_ar' " (z=" %5.2f `z_2024_ar' ")"
            di as text "  → Compare: 2016 z=" %5.2f `z_ar' " vs 2024 z=" %5.2f `z_2024_ar'
        }

        di _n as text "  Full time series:"
        list year actually_reported told_to_report total_jury_verdicts pct_told_to_report, noobs sep(0)

        * Treatment status by year
        di _n as text "  Treatment status by year:"
        list year treat_pros_pressure treat_pros_contested_long treat_pros_contested treat_pros_uncontested, noobs sep(0)
    restore
}


* ─────────────────────────────────────────────────────────────────────
* Q5: Were Wayne and Macomb contested in 2024?
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q5: Wayne and Macomb — treatment status in 2024           ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

foreach bigcounty in "Wayne" "Macomb" {
    di _n as text "─── `bigcounty' in 2024 ───"
    preserve
        keep if county == "`bigcounty'" & year == 2024
        if _N == 0 {
            di as error "  No 2024 observation for `bigcounty'"
        }
        else {
            di as text "  treat_pros_pressure:       " treat_pros_pressure[1]
            di as text "  treat_pros_contested_long: " treat_pros_contested_long[1]
            di as text "  treat_pros_contested:      " treat_pros_contested[1]
            di as text "  treat_pros_uncontested:    " treat_pros_uncontested[1]
            di as text "  treat_pros_primary_only:   " treat_pros_primary_only[1]
        }
    restore
}

* Bonus: Show ALL counties' 2024 treatment status for context
di _n as text "─── All counties' 2024 treatment status ───"
preserve
    keep if year == 2024
    tab treat_pros_pressure, mi
    di _n as text "Among T1 (pressure) in 2024:"
    tab treat_pros_contested_long treat_pros_uncontested if treat_pros_pressure == 1, mi

    di _n as text "Contested general (T2) in 2024:"
    gsort -county_pop
    list county county_pop if treat_pros_contested_long == 1 & year == 2024, noobs sep(0)
restore


* ─────────────────────────────────────────────────────────────────────
* Q6: Confirm population interactions include year FE
*     (Already confirmed in Section 15 code: absorb(county_id year))
*     Reprint the T2 interaction for documentation completeness
* ─────────────────────────────────────────────────────────────────────

di _n as text "╔══════════════════════════════════════════════════════════════╗"
di as text    "║  Q6: Population interaction with full FE structure          ║"
di as text    "╚══════════════════════════════════════════════════════════════╝"

di as text "Specification: Y = β1*T + β2*T×ln(pop) + county_FE + year_FE + ε"
di as text "Absorbed: county_id, year (identical to main paper spec)"
di as text ""

gen lnpop = ln(county_pop)
gen T2_x_lnpop = treat_pros_contested_long * lnpop

di _n as text "─── T2 actually_reported with interaction (full output) ───"
reghdfe actually_reported treat_pros_contested_long T2_x_lnpop treat_pros_uncontested ///
    if treat_pros_primary_only != 1, absorb(county_id year) vce(cluster county_id)

di _n as text "─── Interpretation helper ───"
di as text "At median county pop (ln=" %5.2f ln(30000) ", ~30k):"
di as text "  Marginal effect = b_T2 + b_interaction * " %5.2f ln(30000)
di as text "At Wayne pop (ln=" %5.2f ln(1750000) ", ~1.75M):"
di as text "  Marginal effect = b_T2 + b_interaction * " %5.2f ln(1750000)

* Calculate marginal effects at different population levels
local b_t2 = _b[treat_pros_contested_long]
local b_int = _b[T2_x_lnpop]

di _n as text "Marginal effect of T2 contestation at different population levels:"
foreach pop_val in 10000 30000 100000 300000 600000 1000000 1750000 {
    local lp = ln(`pop_val')
    local me = `b_t2' + `b_int' * `lp'
    di as text "  Pop=" %12.0fc `pop_val' " (ln=" %5.2f `lp' "): marginal effect = " %9.1f `me'
}

drop lnpop T2_x_lnpop


di _n as result "================================================================"
di as result "  DIAGNOSTIC COMPLETE — ALL THREE TIERS + FOLLOW-UP"
di as result "  T1: treat_pros_pressure (incumbent running)"
di as result "  T2: treat_pros_contested_long (general-election, excl primary-only)"
di as result "  T3: treat_pros_contested (any-stage contested)"
di as result "================================================================"

log close
