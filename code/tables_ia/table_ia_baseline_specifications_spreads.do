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

    basereg ${depvar} log_at zscore_modified                     , cluster(${firm_id})
    basereg ${depvar} log_at zscore_modified log_tangibility mtb , cluster(${firm_id})
    basereg ${depvar} ${controls1}                               , cluster(${firm_id})
    basereg ${depvar} ${controls1} log_num_lenders               , cluster(${firm_id})
    basereg ${depvar}                               ${controls2} , cluster(${firm_id})

    noisily ///
    esttab, nolabel compress nogaps nobase noconst ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
            ${stars} eqlabels(none) collabels(none) varwidth(30) ///
            stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R2" "Obs.")) ///
            indicate($min_indicate, labels(Y N))

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_baseline_specifications_spreads.tex", replace booktabs type ///
        label compress nogaps nobase noomitted nomtitles noconst nonote ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
        ${stars} eqlabels(none) collabels(none) ///
        stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R$ ^2 $ " "Observations") ) ///
        indicate($min_indicate, labels(Y N)) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
                ) ///
        substitute("\midrule" "" "Loan Purpose" "\midrule Loan Purpose" "Log(AT)" "\midrule Log(AT)")

} // end $quietly
