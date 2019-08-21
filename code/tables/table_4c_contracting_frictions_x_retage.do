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

    runmainspec I.ceo_preret#I.CEO_Founder age age2 tenure new_ceo,
    runmainspec I.ceo_preret#c.CG_PercInsider age age2 tenure new_ceo,
    runmainspec I.ceo_preret#I.no_heir age age2 tenure new_ceo,

    noisily ///
    esttab, label compress nogaps noomitted nomtitle noconstant ///
        varwidth(50) ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate($min_indicate, labels(Y N)) ///
        order(*ceo_preret*)


    if $writeout ///
    esttab using "${tdir}/table_4c_contracting_frictions_x_retage.tex", replace ///
        booktabs type label compress nogaps noomitted nomtitle noconstant ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate("\midrule Firm Controls / Year \& Industry F.E. = log_at *.year *.${ff12} *_spread" ///
                 "Syndicate \& Loan Controls=scaled_amount" , labels(Y N)) ///
        keep(*ceo_preret*) ///
        drop("0.ceo_preret#0.CEO_Founder" "0.ceo_preret#0.no_heir") ///
        order(*ceo_preret*) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ) ///
        varlabels(0.ceo_preret#1.CEO_Founder "Not Retirement Age $ \times$ Founder CEO" ///
                  1.ceo_preret#0.CEO_Founder "Retirement Age $ \times$ Non-Founder CEO" ///
                  1.ceo_preret#1.CEO_Founder "Retirement Age $ \times$ Founder CEO" ///
                  0.ceo_preret#c.CG_PercInsider "Not Retirement Age $ \times$  \% Insider (Ind.)" ///
                  1.ceo_preret#c.CG_PercInsider "Retirement Age $ \times$  \% Insider (Ind.)" ///
                  0.ceo_preret#0.no_heir "Not Retirement Age $ \times$ Heir Apparent" ///
                  0.ceo_preret#1.no_heir "Not Retirement Age $ \times$ No Heir Apparent" ///
                  1.ceo_preret#0.no_heir "Retirement Age $ \times$ Heir Apparent" ///
                  1.ceo_preret#1.no_heir "Retirement Age $ \times$ No Heir Apparent" ) ///
        prehead(" ")  postfoot(" ")

} // end $quietly
