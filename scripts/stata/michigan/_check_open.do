* Diagnostic: which counties have open_pros == 1 and what gets dropped?
if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/globals.do"
}

use "$DATA_FINAL/michigan_panel_B.dta", clear
di "Full panel: " _N " obs"
qui distinct county_id
di "Counties: " r(ndistinct)

* Which counties have open_pros == 1?
di _n "=== Counties with open_pros == 1 ==="
tab county_id year if open_pros == 1, row

* List them
di _n "=== Open-seat county-years ==="
list county_id year open_pros treat_pros_pressure is_election_year_pros if open_pros == 1, sep(0)

* Count
qui count if open_pros == 1
di _n "Total open-seat county-years: " r(N)

* For each open-seat county, what's the prior election year?
levelsof county_id if open_pros == 1, local(open_counties)
di _n "=== Lame-duck exclusion detail ==="
foreach c of local open_counties {
    qui summ year if county_id == `c' & open_pros == 1
    local open_yr = r(min)

    qui summ year if county_id == `c' & is_election_year_pros == 1 & year < `open_yr'
    if r(N) > 0 {
        local prev_yr = r(max)
        qui count if county_id == `c' & year > `prev_yr' & year <= `open_yr'
        di "County `c': open_yr=`open_yr', prev_election=`prev_yr', dropping years (`=`prev_yr'+1' to `open_yr') = " r(N) " obs"
    }
    else {
        qui count if county_id == `c' & year <= `open_yr'
        di "County `c': open_yr=`open_yr', NO prior election in panel, dropping all years <= `open_yr' = " r(N) " obs"
    }
}

* Show what survives
tempvar drop_flag
gen byte `drop_flag' = 0
foreach c of local open_counties {
    qui summ year if county_id == `c' & open_pros == 1
    local open_yr = r(min)
    qui summ year if county_id == `c' & is_election_year_pros == 1 & year < `open_yr'
    if r(N) > 0 {
        local prev_yr = r(max)
        replace `drop_flag' = 1 if county_id == `c' & year > `prev_yr' & year <= `open_yr'
    }
    else {
        replace `drop_flag' = 1 if county_id == `c' & year <= `open_yr'
    }
}
qui count if `drop_flag' == 1
di _n "Total obs dropped: " r(N)
di "Surviving obs: " _N - r(N)
qui distinct county_id if `drop_flag' == 0
di "Surviving counties: " r(ndistinct)

* Show which counties lose ALL obs
di _n "=== Counties that lose ALL observations ==="
levelsof county_id, local(all_counties)
foreach c of local all_counties {
    qui count if county_id == `c' & `drop_flag' == 0
    if r(N) == 0 {
        di "County `c': ALL obs dropped (entirely within lame-duck window)"
    }
}
