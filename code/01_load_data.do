/* -*- coding: utf-8 -*- */

set more off
/* Assumes paper was extracted to desktop, change the below if extracted elsewhere */
capture cd "~/Desktop/cmr_paper/"

/* Load global variables, e.g. specification controls, or whether to output .tex files */
run code/00_global_variables.do

run "${cdir}/programs/cmr_basereg"
run "${cdir}/programs/cmr_diffsumstats"
run "${cdir}/programs/cmr_pricingreg"
run "${cdir}/programs/ffind.ado"
run "${cdir}/programs/winsorize_all.ado"
run "${cdir}/programs/wsum.ado"


capture use "${ddir}/loan_level.dta", clear
if _rc {
    noisily display as error "ERROR! Something went wrong loading data"
    exit 3
}

run "${cdir}/00_label_variables.do"
