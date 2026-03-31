* Check if boottest and twowayfeweights are installed
capture which boottest
if _rc {
    di "boottest: NOT INSTALLED"
}
else {
    di "boottest: INSTALLED"
}

capture which twowayfeweights
if _rc {
    di "twowayfeweights: NOT INSTALLED"
}
else {
    di "twowayfeweights: INSTALLED"
}
