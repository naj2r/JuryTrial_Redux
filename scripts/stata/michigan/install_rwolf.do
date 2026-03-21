* Install rwolf (Romano-Wolf step-down adjusted p-values)
* Clarke, Romano, Wolf (2020)
* One-time install — safe to re-run

set update_query off
ssc install rwolf, replace
ssc install boottest, replace

* Verify installation
which rwolf
di "rwolf installed successfully"
