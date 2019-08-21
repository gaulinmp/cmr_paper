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

    runmainspec c.ceo_shrown_pct, margins
    runmainspec I.ceo_no_unvested, margins
    runmainspec I.NonCompete_low, margins
    runmainspec I.ceo_preret age age2 tenure new_ceo, margins

    noisily ///
    esttab, label compress nogaps nobase nomtitle  noomitted ///
            order(*shrown* *unvest* *NonCompete* *ceo_preret*) ///
            varwidth(25) ${stars} eqlabels(none) collabels(none) ///
            stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R2" "Obs.")) ///
            indicate(${min_indicate} , labels(Y N))

    if $writeout ///
    esttab using "${tdir}/table_4_contracting_frictions.tex", replace ///
            booktabs type compress nogaps nobase nomtitle nomtitles noomitted ///
            ${stars} eqlabels(none) collabels(none) ///
            cells("b(fmt(%4.3f) star)" "t(par fmt(a2))" ${tex_margins}) ///
            rename(ceo_shrown_pct X 1.ceo_no_unvested X 1.NonCompete_low X 1.ceo_preret X) ///
            stats(r2_p N, fmt(a2 %18.0gc) labels("Pseudo R$ ^2$" "Observations")) ///
            indicate(${max_indicate}, labels(Y N)) ///
            keep(X) ///
            mgroup("CEO Ownership \%" "CEO No Unvested Equity" "Low NC Enforcement" "CEO Retirement Age",  ///
                            span pattern(1 0 1 0 1 0 1 0) ///
                            prefix("\mc{@span}{") ///
                            suffix("}") ///
                            erepeat(\cmidrule(lr){@span}) ///
                ) ///
            substitute("\midrule" "" "X   " "\midrule X" ///
                        "\toprule" "\toprule \multicolumn{9}{c}{\small  \textbf{Panel A}: CMR Inclusion and Contracting Frictions} \\ \midrule &\multicolumn{8}{c}{Dependent Variable = CMR Clause} \\ \addlinespace X = " ///
                       "Firm Controls" "\addlinespace \midrule Firm Controls")
    /* After writing out, add the \addlinespace \textit{Average Marginal Effect} to the line in front of the first &\textit */

}
