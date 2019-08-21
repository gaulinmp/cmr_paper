/* -*- coding: utf-8 -*- */
quietly { // load data
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }
} // end load data

$quietly {

    noisily display "******************************************************************************************"
    noisily display "*******************************  Copy these into tex file  *******************************"
    noisily display "******************************************************************************************"


    local allindrawn "All-in spread drawn"
    local maturity "Maturity"
    local relationship "Relationship"
    local CEO_Founder "Founder CEO"

    keep if has_cmr_ever==1
    keep ${firm_id} dealactivedate facilitystartdate facilityenddate $depvar allindrawn maturity relationship CEO_Founder

    sort ${firm_id} dealactivedate

    by ${firm_id}: gen loan_num = _n

    /* Compare pre- and CMR */
    preserve
        tempfile pre_loan
        replace loan_num = loan_num + 1

        foreach v in $depvar allindrawn maturity relationship CEO_Founder {
            rename `v' `v'0
        }
        save "`pre_loan'"
    restore

    preserve
        foreach v in $depvar allindrawn maturity relationship CEO_Founder {
            rename `v' `v'1
        }

        merge 1:1 ${firm_id} loan_num using "`pre_loan'", nogenerate force keep(match master)

        keep if !missing(restrict0) & restrict0 == 0 & !missing(restrict1) & restrict1 == 1

        count
        noisily display _n _n
        noisily display "******************************************************************************************"
        noisily display "****************************  {txt}PRE --> CMR{res}  **********************************************"
        noisily display "****************************  Number: `=r(N)'  **********************************************"
        noisily display "******************************************************************************************" _n _n

        foreach v in allindrawn maturity relationship CEO_Founder {
            /* noisily display _n _n "{txt}CMR --> POST {res}ttest `v'0==`v'1" */
            ttest `v'0==`v'1 if !missing(`v'0) & !missing(`v'1)
            if r(p) <= .1  local stars "\sym{*{}} "
            if r(p) <= .05 local stars "\sym{**}  "
            if r(p) <= .01 local stars "\sym{***} "
            noisily display "    ``v''   & " $fmt2 r(mu_1)  " & " $fmt2 r(mu_2)  " & " $fmt2 (r(mu_2)-r(mu_1))  " & " $fmt2 -r(t)  "`stars' \\"
        }
    restore


    /* Compare CMR and post- */
    preserve
        tempfile post_loan

        keep if $depvar == 0 & !missing($depvar)

        foreach v in $depvar allindrawn maturity relationship CEO_Founder facilitystartdate facilityenddate {
            rename `v' `v'0
        }
        save "`post_loan'"
    restore

    preserve
        keep if $depvar == 1 & !missing($depvar)

        foreach v in $depvar allindrawn maturity relationship CEO_Founder facilitystartdate facilityenddate dealactivedate {
            rename `v' `v'1
        }

        joinby ${firm_id} using "`post_loan'",

        keep if (facilityenddate1 <= facilitystartdate0) & !missing(facilityenddate1)==1 & !missing(facilitystartdate0)==1
        // Keep first next non-overlapping (and ending first) package, then cheapest and smallest maturity if all of the above match.
        // This biases against finding out post-results that loans get more expensive and longer after CMR expires.
        sort ${firm_id} dealactivedate1 facilitystartdate0 facilityenddate0 allindrawn0 maturity0
        duplicates report ${firm_id} dealactivedate1 facilitystartdate0 facilityenddate0 allindrawn0 maturity0
        duplicates list ${firm_id} dealactivedate1 facilitystartdate0 facilityenddate0 allindrawn0 maturity0
        duplicates drop ${firm_id} dealactivedate1, force // Just keep one next facility per

        count
        noisily display _n _n
        noisily display "******************************************************************************************"
        noisily display "****************************  {txt}CMR --> POST{res}  **********************************************"
        noisily display "****************************  Number:  `=r(N)'  **********************************************"
        noisily display "******************************************************************************************" _n _n

        foreach v in allindrawn maturity relationship CEO_Founder {
            /* noisily display _n _n "{txt}CMR --> POST {res}ttest `v'0==`v'1" */
            ttest `v'0==`v'1 if !missing(`v'0) & !missing(`v'1)
            if r(p) <= .1  local stars "\sym{*{}} "
            if r(p) <= .05 local stars "\sym{**}  "
            if r(p) <= .01 local stars "\sym{***} "
            noisily display "    ``v''   & " $fmt2 r(mu_2)  " & " $fmt2 r(mu_1)  " & " $fmt2 (r(mu_1)-r(mu_2))  " & " $fmt2 r(t)  "`stars' \\"
        }
    restore

} // end quietly
