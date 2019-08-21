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

    local extra_control I.seniority_i excesscfsweep assetsalessweep debtissuancesweep equityissuancesweep insuranceproceedssweep I.dividendrestrictions_i I.borrowerbasetype_i

    runmainspec i.CEO_Founder                        `extra_control', margins nospec1
    runmainspec c.CG_PercInsider                     `extra_control', margins nospec1
    runmainspec i.no_heir age age2 tenure new_ceo    `extra_control', margins nospec1
    runmainspec c.ceo_shrown_pct                     `extra_control', margins nospec1
    runmainspec I.ceo_no_unvested                    `extra_control', margins nospec1
    runmainspec I.NonCompete_low                     `extra_control', margins nospec1
    runmainspec I.ceo_preret age age2 tenure new_ceo `extra_control', margins nospec1

    noisily ///
    esttab,  ${stars} ///
            nolabel compress nogaps nobase noconst ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" "margins_b(fmt(${fmt3}) par({ }))") ///
            eqlabels(none) varwidth(30) ///
            stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Obs.")) ///
            order(*CEO* *Insider* *heir* *ceo_*_* *NonComp* *preret*) ///
            indicate("Extra Loan Controls=*_i *sweep" "CEO Controls=age* tenure new_ceo" $max_indicate )

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_9_with_loan_controls.tex", replace ///
        booktabs type label compress nogaps nobase noomitted nomtitles noconst nonote ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2 $ " "Observations") ) ///
        order(*CEO* *Insider* *heir* *ceo_*_* *NonComp* *preret*) ///
        indicate("\addlinespace Extra Loan Controls=*_i *sweep" ///
                 "CEO Controls=age* tenure new_ceo" $max_indicate, labels(Y N)) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
                ) ///
        substitute("=1" "" "\midrule" "" "Founder CEO" "\midrule Founder CEO" ///
                   "CEO Controls" "\addlinespace \midrule CEO Controls")

}
