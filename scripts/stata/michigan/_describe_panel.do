if "$ROOT" == "" {
    do "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/code/master/paths.do"
}
use "$DATA_FINAL/michigan_panel_B.dta", clear

di _n "--- current_prosecutor and turnover for Wayne ---"
list county year current_prosecutor turnover_pros incumbent_pros open_pros treat_pros_pressure if county == "Wayne", noobs

di _n "--- current_prosecutor for Allegan ---"
list county year current_prosecutor turnover_pros incumbent_pros treat_pros_pressure if county == "Allegan", noobs

di _n "--- Summary of turnover ---"
tab year turnover_pros

di _n "--- How to detect same prosecutor in t+1 ---"
* Generate: same_pros_next = (current_prosecutor == current_prosecutor[_n+1])
sort county year
by county: gen same_pros_next = (current_prosecutor == current_prosecutor[_n+1]) if _n < _N
tab year same_pros_next
