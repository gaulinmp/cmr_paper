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

    eststo clear

    /* Specify dependent variables to loop through, and controls */
    local depvars tobinsq oibdp_at
    local controls $controls2only I.year

    foreach vn in `depvars' {
        gen d_`vn' = ((p2_`vn' + p1_`vn')/2 - (p0_`vn' + m1_`vn')/2)
        gen l_d_`vn' = ((p0_`vn' + m1_`vn')/2 - (m2_`vn' + m3_`vn')/2)

        winsor2 d_`vn', cuts(1 99) replace
        winsor2 l_d_`vn', cuts(1 99) replace
    }
    label variable l_d_tobinsq "Lag CHG Tobin's Q"
    label variable l_d_oibdp_at "Lag CHG ROA"


    /* Set up conditionals for each column */
    local if
    local title1 "All Firms"

    local inter2 NonCompete_low
    local title2 "Low NC Enforcement"

    local inter3 ceo_preret
    local title3 "CEO Retirement Age"

    quietly sum zscore_public, d
    gen risky_zscore = cond(zscore_public <= r(p25), 1, 0) if !missing(zscore_public)
    local inter4  risky_zscore
    local title4 "High Risk Firms (Z-score < `=r(p25)')"

    gen risky_rate = cond(rate >= 10, 1, 0) if !missing(rate)
    local inter5 risky_rate
    local title5 "Low (Junk) Credit Ratings"


    /* Loop through dependent variables and create table for each */
    foreach depvar in `depvars' {
        eststo clear
        local mgroups `""All Firms" "'

        eststo: regress d_`depvar' ${depvar}              `controls' `if', cluster(${firm_id})
        eststo: regress d_`depvar' ${depvar} l_d_`depvar' `controls' `if', cluster(${firm_id})

        foreach i of numlist 2/5 {
            display "`inter`i''"
            capture gen cmr_`inter`i'' = ${depvar} * `inter`i''
            capture gen cmr_non_`inter`i'' = ${depvar} * (1-`inter`i'')
            local inter cmr_`inter`i'' cmr_non_`inter`i'' `inter`i''
            local rename `"`rename'  "cmr_`inter`i''"  "CMR\*X=1"  "cmr_non_`inter`i''"  "CMR\*X=0""'
            local mgroups `"`mgroups'  "`inter`i''""'

            eststo: regress d_`depvar' `inter'              `controls' `if', cluster(${firm_id})
            eststo: regress d_`depvar' `inter' l_d_`depvar' `controls' `if', cluster(${firm_id})
        }

        noisily ///
        esttab, varwidth(30) compress nogaps noconst noomitted nomtitles ///
                ${stars} eqlabels(none) collabels(none) ///
                cells("b(fmt(%4.3f) star)" "t(par fmt(${fmt2}))") ///
                stats(r2 N, fmt(a2 %8.0gc) labels("R2" "Obs.")) ///
                title(`depvar') ///
                keep(${depvar} CMR*) ///
                rename(`rename') ///
                mgroup(`mgroups', span pattern(1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0)) ///
                order(*${depvar}*) ///
                substitute("\*" " * " ${depvar} "CMR" ///
                            NonCompete_low "Low NC Enforcement" ///
                            ceo_preret "CEO Retirement Age" ///
                            risky_zscore "Z-score Low" ///
                            risky_rate "Junk Rating" ) ///
                indicate("Loan/Syndicate Controls=ppricing" "Year = *year" "Lag Dep. Var.=l_d*", labels(Y N))

        if $writeout ///
        esttab using "${tdir}/ia/table_ia_firm_outcome_loan_controls_`depvar'.tex", replace booktabs ///
            compress nogaps nobase noomitted nomtitles noconst nonote label ///
            ${stars} eqlabels(none) collabels(none) ///
            stats(r2 N, fmt(${fmt2} %8.0gc) labels("R$ ^2$" "Observations") ) ///
            cells("b(fmt(%4.3f) star)" "t(par fmt(${fmt2}))") ///
            indicate("\midrule Loan/Syndicate Controls=log_num_lenders scaled_amount log_maturity collat num_fincovs ppricing *.ppurpose *.ltype" "Lag Dep. Var.=l_d*", labels(Y N)) ///
            keep(${depvar} CMR*) ///
            rename(`rename') ///
            order(*${depvar}*) ///
            substitute("\*" " * " ///
                        ${depvar} "CMR" ///
                        NonCompete_low "Low NC Enforcement" ///
                        ceo_preret "CEO Retirement Age" ///
                        risky_zscore "Z-score Low" ///
                        risky_rate "Junk Rating" ///
                        _ \_ ) ///
            mgroup(`mgroups', span pattern(1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0) ///
                        prefix("\mc{@span}{") suffix("}") ///
                        erepeat(\cmidrule(lr){@span}) ///
                    ) ///
            prehead(" ") postfoot(" ")

    } // End foreach numlist

} // end quietly
