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

    /* Add Firm age, and subsample on > median age. */
    sum crsp_age, d
    local med_age=r(p50)
    noisily display "Median age: `med_age'"

    eststo clear

    runmainspec i.CEO_Founder                     crsp_age, margins debug
    runmainspec c.CG_PercInsider                  crsp_age, margins debug
    runmainspec i.no_heir age age2 tenure new_ceo crsp_age, margins debug
    runmainspec i.CEO_Founder                     crsp_age if crsp_age > `med_age' & !missing(crsp_age), margins debug
    runmainspec c.CG_PercInsider                  crsp_age if crsp_age > `med_age' & !missing(crsp_age), margins debug
    runmainspec i.no_heir age age2 tenure new_ceo crsp_age if crsp_age > `med_age' & !missing(crsp_age), margins debug

    noisily ///
    esttab, label compress nogaps nobase noconst ///
            ${stars} eqlabels(none) varwidth(30) ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
            order(*Founder* *PercInsider *heir*) ///
            stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Obs.")) ///
            indicate("CEO Controls=age* tenure new_ceo " $min_indicate)

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_crsp_age_controls.tex", replace ///
        booktabs type label nogaps nobase nomtitle nomtitles noomitted nocons ///
        ${stars} eqlabels(none) collabels(none) ///
        order(*Founder* *PercInsider *heir*) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate("CEO Controls=age* tenure new_ceo " ${max_indicate}, labels(Y N)) ///
        mgroup("Full Sample" "Above Median Firm Age",  ///
                span pattern(1 0 0 0 0 0 1 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
                ) ///
        substitute("=1" "" "\midrule" "" "\toprule" "\toprule &\multicolumn{12}{c}{Dependent Variable = CMR Clause} \\\cmidrule(lr){2-13}" ///
                   "Founder CEO     " "\midrule Founder CEO" ///
                   "CEO Controls" "\midrule CEO Controls")


} // end quietly
