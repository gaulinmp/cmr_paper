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

    /* Date-checking CEO founder turnover.
    If the left office date is before dealactive date, they changed jobs before the
    loan covered them, so the new CEO is no longer the founder. */
    gen CEO_Founder_datecheck=CEO_Founder
    replace CEO_Founder_datecheck = 0 if (leftofc < dealactivedate) & !missing(leftofc)
    capture label variable CEO_Founder_datecheck "Founder CEO (alternative)"


    eststo clear

    runmainspec i.CEO_Founder, margins
    runmainspec i.CEO_Founder_datecheck, margins
    runmainspec i.CEO_Founder c.CG_PercInsider i.no_heir age age2 tenure new_ceo, margins
    runmainspec i.CEO_Founder_datecheck c.CG_PercInsider i.no_heir age age2 tenure new_ceo, margins

    noisily ///
    esttab, label compress nogaps nobase noconst ///
            ${stars} eqlabels(none) varwidth(30) ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
            order(*Founder* *PercInsider *heir*) ///
            stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Obs.")) ///
            indicate("CEO Controls=age* tenure new_ceo " $min_indicate)

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_5_robust_human_capital.tex", replace ///
        booktabs type label nogaps nobase nomtitle nomtitles noomitted nocons ///
        ${stars} eqlabels(none) collabels(none) ///
        order(*Founder* *PercInsider *heir*) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate("CEO Controls=age* tenure new_ceo " ${max_indicate}, labels(Y N)) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
                ) ///
        substitute("=1" "" "\midrule" "" "Founder CEO     " "\midrule Founder CEO" ///
                   "CEO Controls" "\midrule CEO Controls")


} // end quietly
