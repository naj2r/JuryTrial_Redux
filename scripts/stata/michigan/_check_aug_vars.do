* Quick check: what variables exist in the augmented panel?
global DATA_FINAL "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild/data_final"
use "$DATA_FINAL/michigan_panel_B_augmented.dta", clear
describe incoming_felony pending_felony clearance_rate, simple
di "N = " _N
