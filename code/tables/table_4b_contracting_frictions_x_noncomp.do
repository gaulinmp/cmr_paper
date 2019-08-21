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

    runmainspec I.NonCompete_low#I.CEO_Founder,
    runmainspec I.NonCompete_low#c.CG_PercInsider,
    runmainspec I.NonCompete_low#I.no_heir,

    noisily ///
    esttab, label compress nogaps noomitted nomtitle noconstant ///
        varwidth(50) ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate($min_indicate, labels(Y N)) ///
        order(0.NonCompete_low#1.CEO_Founder* *NonCompete*)


    if $writeout ///
    esttab using "${tdir}/table_4b_contracting_frictions_x_noncompete.tex", replace ///
        booktabs type label compress nogaps noomitted nomtitle noconstant ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        indicate("\midrule Firm Controls / Year \& Industry F.E. = log_at *.year *.${ff12} *_spread" ///
                 "Syndicate \& Loan Controls=scaled_amount" , labels(Y N)) ///
        keep(*NonCompete_low*) ///
        drop("0.NonCompete_low#0.CEO_Founder" "0.NonCompete_low#0.no_heir") ///
        order(0.NonCompete_low#1.CEO_Founder*) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0 0 0 0 0 0) ///
                prefix("\multicolumn{@span}{c}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ) ///
        varlabels(0.NonCompete_low#0.CEO_Founder "High NC Enforcement $ \times$ Non-Founder CEO" ///
                  0.NonCompete_low#1.CEO_Founder "High NC Enforcement $ \times$ Founder CEO" ///
                  1.NonCompete_low#0.CEO_Founder "Low NC Enforcement $ \times$ Non-Founder CEO" ///
                  1.NonCompete_low#1.CEO_Founder "Low NC Enforcement $ \times$ Founder CEO" ///
                  0.NonCompete_low#c.CG_PercInsider "High NC Enforcement $ \times$  \% Insider (Ind.)" ///
                  1.NonCompete_low#c.CG_PercInsider "Low NC Enforcement $ \times$  \% Insider (Ind.)" ///
                  0.NonCompete_low#0.no_heir "High NC Enforcement $ \times$ Heir Apparent" ///
                  0.NonCompete_low#1.no_heir "High NC Enforcement $ \times$ No Heir Apparent" ///
                  1.NonCompete_low#0.no_heir "Low NC Enforcement $ \times$ Heir Apparent" ///
                  1.NonCompete_low#1.no_heir "Low NC Enforcement $ \times$ No Heir Apparent" ) ///
        prehead(" ")  postfoot(" ")

} // end $quietly
