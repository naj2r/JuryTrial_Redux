/*==============================================================
  diag_rate_outliers.do
  Purpose: Identify county-years where pipeline rates exceed 1.0
  Issues:  pct_told_to_report max = 1.079
           pct_questioned_in_voir_dire max = 8.889
==============================================================*/
set update_query off
clear all
set more off

* Load panel B (main estimating sample)
use "C:\Users\jensenn\Dropbox\Research Papers\Jury Trials\master\jury_trial_documentation\Documentation\Michigan_replication_cleaned\results_rebuild\data_final\michigan_panel_B.dta", clear

* --- Outliers: pct_told_to_report > 1 ---
di _n(2) "=============================================="
di "OUTLIERS: pct_told_to_report > 1.0"
di "=============================================="
list county year summoned told_to_report pct_told_to_report ///
    if pct_told_to_report > 1 & !missing(pct_told_to_report), ///
    sep(0) noobs

* --- Outliers: pct_questioned_in_voir_dire > 1 ---
di _n(2) "=============================================="
di "OUTLIERS: pct_questioned_in_voir_dire > 1.0"
di "=============================================="
list county year sent_to_courtroom questioned_in_voir_dire pct_questioned_in_voir_dire ///
    if pct_questioned_in_voir_dire > 1 & !missing(pct_questioned_in_voir_dire), ///
    sep(0) noobs

* --- Outliers: any rate > 1 ---
di _n(2) "=============================================="
di "ALL RATE VARIABLES > 1.0 (any)"
di "=============================================="
gen byte any_rate_gt1 = 0
replace any_rate_gt1 = 1 if pct_told_to_report > 1 & !missing(pct_told_to_report)
replace any_rate_gt1 = 1 if pct_actually_reported > 1 & !missing(pct_actually_reported)
replace any_rate_gt1 = 1 if pct_sent_to_courtroom > 1 & !missing(pct_sent_to_courtroom)
replace any_rate_gt1 = 1 if pct_questioned_in_voir_dire > 1 & !missing(pct_questioned_in_voir_dire)
replace any_rate_gt1 = 1 if utilization_rate > 1 & !missing(utilization_rate)

di "Total county-years with any rate > 1: " _N * any_rate_gt1
tab any_rate_gt1

list county year pct_told_to_report pct_actually_reported ///
    pct_sent_to_courtroom pct_questioned_in_voir_dire utilization_rate ///
    if any_rate_gt1 == 1, sep(0) noobs

* --- Context: full pipeline for the worst offender (pct_vd = 8.889) ---
di _n(2) "=============================================="
di "WORST pct_questioned_in_voir_dire OFFENDER - FULL PIPELINE"
di "=============================================="
* Find the max
summ pct_questioned_in_voir_dire, detail
local maxval = r(max)
list county year summoned told_to_report actually_reported ///
    sent_to_courtroom questioned_in_voir_dire ///
    pct_told_to_report pct_questioned_in_voir_dire ///
    if abs(pct_questioned_in_voir_dire - `maxval') < 0.001, sep(0) noobs

* --- Also check court-level data ---
di _n(2) "=============================================="
di "COURT-LEVEL DATA: ALL pct_questioned_in_voir_dire > 1"
di "=============================================="

preserve
use "C:\Users\jensenn\Dropbox\Research Papers\Jury Trials\master\jury_trial_documentation\Documentation\Michigan_replication_cleaned\results_rebuild\data_final\michigan_court_level.dta", clear
describe, short
* List all courts with pct_questioned_in_voir_dire issues
capture list court_name year sent_to_courtroom questioned_in_voir_dire ///
    if pct_questioned_in_voir_dire > 1 & !missing(pct_questioned_in_voir_dire), ///
    sep(0) noobs
* If court_name doesn't exist, try other identifiers
capture list court year sent_to_courtroom questioned_in_voir_dire ///
    if pct_questioned_in_voir_dire > 1 & !missing(pct_questioned_in_voir_dire), ///
    sep(0) noobs
restore

* --- Summary stats with and without outliers ---
di _n(2) "=============================================="
di "SUMMARY: pct_questioned_in_voir_dire"
di "=============================================="
di "WITH outliers:"
summ pct_questioned_in_voir_dire, detail

di _n "WITHOUT observations > 1:"
summ pct_questioned_in_voir_dire if pct_questioned_in_voir_dire <= 1, detail

di _n(2) "=============================================="
di "SUMMARY: pct_told_to_report"
di "=============================================="
di "WITH outliers:"
summ pct_told_to_report, detail

di _n "WITHOUT observations > 1:"
summ pct_told_to_report if pct_told_to_report <= 1, detail

log close _all
