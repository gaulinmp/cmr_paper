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

    runmainspec i.CEO_Founder, margins
    runmainspec c.CG_PercInsider, margins
    runmainspec i.no_heir age age2 tenure new_ceo, margins

    noisily ///
    esttab, label compress nogaps nobase nomtitle  noomitted ///
            ${stars} eqlabels(none) collabels(none) ///
            cells("b(fmt(%4.3f) star)" "t(par fmt(a2))" ${plain_margins}) ///
            stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R2" "Obs.")) ///
            order(*CEO* *CG* *no_heir*) ///
            indicate(${min_indicate} , labels(Y N))

    if $writeout ///
    esttab using "${tdir}/table_3_human_capital.tex", replace ///
            booktabs type compress nogaps nobase nomtitle nomtitles noomitted ///
            ${stars} eqlabels(none) collabels(none) ///
            cells("b(fmt(%4.3f) star)" "t(par fmt(a2))" ${tex_margins}) ///
            rename(1.CEO_Founder X CG_PercInsider X 1.no_heir X shrown_excl_opts_pct X) ///
            stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R$ ^2$" "Observations")) ///
            indicate(${max_indicate}, labels(Y N)) ///
            keep(X) ///
            mgroup("Founder CEO" "\% Insider (Ind.)" "No Heir-Apparent" "CEO Ownership \%",  ///
                            span pattern(1 0 1 0 1 0 1 0) ///
                            prefix("\mc{@span}{") ///
                            suffix("}") ///
                            erepeat(\cmidrule(lr){@span}) ///
                ) ///
            substitute("\toprule" "\toprule &\multicolumn{6}{c}{Dependent Variable = CMR Clause} \\ \cmidrule(lr){2-7} \addlinespace X = " ///
                       "\midrule" "" "X   " "\midrule X" ///
                       "Firm Controls" "\addlinespace \midrule Firm Controls")
    /* After writing out, add the \addlinespace \textit{Average Marginal Effect} to the line in front of the first &\textit */
} // end $quietly
