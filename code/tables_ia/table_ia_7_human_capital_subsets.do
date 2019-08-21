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

    /* For severity, set to 0 if missing */
    replace a123=0 if missing(a123)
    replace a4=0 if missing(a4)

    eststo clear

    runmainspec i.CEO_Founder, margins nospec1 dv(a123)
    runmainspec i.CEO_Founder, margins nospec1 dv(a4)
    runmainspec c.CG_PercInsider, margins nospec1 dv(a123)
    runmainspec c.CG_PercInsider, margins nospec1 dv(a4)
    runmainspec i.no_heir age age2 tenure new_ceo, margins nospec1 dv(a123)
    runmainspec i.no_heir age age2 tenure new_ceo, margins nospec1 dv(a4)

    noisily ///
    esttab, varwidth(30) ///
        compress nogaps nobase nomtitle nomtitles noomitted ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" `"margins_b(fmt(${fmt3}) par("{" "}"))"') ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate(${max_indicate}, labels(Y N)) ///
        keep(*CEO* *CG* *heir*) ///
        mgroup("A1,A2,A3" "A4" "A1,A2,A3" "A4" "A1,A2,A3" "A4" "A1,A2,A3" "A4",  ///
                span pattern(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ) )

    #delimit ;
    if $writeout
    esttab using "${tdir}/ia/table_ia_7_human_capital_subsets.tex", replace
        booktabs type compress nogaps nobase nomtitle nomtitles noomitted
        ${stars} eqlabels(none) collabels(none)
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins})
        rename(1.CEO_Founder X CG_PercInsider X 1.no_heir X)
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations"))
        indicate(${max_indicate}, labels(Y N))
        keep(X)
        mgroup("A1,A2,A3" "A4" "A1,A2,A3" "A4" "A1,A2,A3" "A4" "A1,A2,A3" "A4",
                span pattern(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 )
                prefix("\mc{@span}{")
                suffix("}")
                erepeat(\cmidrule(lr){@span})
            )
        substitute("$firm_tex_sub"
                    _ \_
                    "\toprule"
                    "\toprule
                    & \mc{6}{Dependent Variable = CMR Clause} \\ \cmidrule(lr){2-7} \addlinespace
                    X= & \mc{2}{Founder CEO} & \mc{2}{\% Insider (Ind.)} & \mc{2}{No Heir Apparent} \\
                    \cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7} "
                    )
    ;
    #delimit cr

} // end $quietly
