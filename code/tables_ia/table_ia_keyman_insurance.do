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

    runmainspec khc_dummy khc_insure CEO_Founder, margins
    runmainspec khc_intensity, margins nospec2

    noisily ///
    esttab, nolabel compress nogaps nobase nomtitle nomtitles noomitted ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${plain_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R^2" "Observations")) ///
        indicate($max_indicate, labels(Y N)) ///
        keep(*khc* *CEO*)

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_keyman_insurance.tex", replace ///
        booktabs type label compress nogaps nobase nomtitle nomtitles noomitted ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate($max_indicate, labels(Y N)) ///
        keep(*khc* *CEO*) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                    span pattern(1 0 0 0 0 0 0 0) ///
                    prefix("\mc{@span}{") ///
                    suffix("}") ///
                    erepeat(\cmidrule(lr){@span}) ///
                    ) ///
        substitute("$firm_tex_sub" _ \_ )

}
