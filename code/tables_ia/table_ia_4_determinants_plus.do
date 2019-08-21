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

    runmainspec debt_mat_3 xrd0_at VIXClose                                                         , margins nospec1
    runmainspec block13_num1                                                                        , margins nospec1
    runmainspec delist_pct_3yrs delist_in_7yrs                                                      , margins nospec1
    runmainspec relationship                                                                        , margins nospec1
    runmainspec debt_mat_3 xrd0_at VIXClose block13_num1 relationship delist_pct_3yrs delist_in_7yrs, margins nospec1

    noisily ///
    esttab,  ${stars} ///
            label compress nogaps nobase noconst ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" "margins_b(fmt(${fmt3}) par({ }))") ///
            eqlabels(none) varwidth(30) ///
            stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Obs.")) /// varwidth(30) ///
            indicate($max_indicate)

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_4_determinants_plus.tex", replace booktabs type ///
        label compress nogaps nobase noomitted nomtitles noconst nonote ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))"  `"margins_b(fmt(${fmt3}) par("\textit{" "}"))"') ///
        ${stars} ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2 $ " "Observations") ) ///
        eqlabels(none) collabels(none) ///
        indicate($max_indicate, labels(Y N)) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
                ) ///
        substitute(_ \_ "\midrule" "" "${firm_tex_sub}" "Debt Matures" "\midrule Debt Matures")

}
