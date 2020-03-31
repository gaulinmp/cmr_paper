/* -*- coding: utf-8 -*- */
quietly { // load data
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_ceo_turnover_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }
} // end load data

$quietly {

    eststo clear

    // Controls
    local acctperf l_ebit_at
    local ceocontrols l.ceo_high_ownership l.ceo_retirement_age l.ceo_tenure
    local ifst if (year > 1994) & (year <= 2014) & (l.ceo_tenure>=24) & !missing(l.ceo_tenure)

    foreach n in 1 3 {
        local stockperf (l.TSR_`n')
        local rest (i.restrict)##C.(`stockperf')

        local controls `acctperf' `ceocontrols'

        noisily display "{txt}Running: {res}probit turnover `rest' `controls' `ifst', cluster(${firm_id})"
        probit turnover `rest' `controls' `ifst', cluster(${firm_id})
        mgsto, noyfe marg(`marg')

        noisily display "{txt}Running: {res}probit turnover `rest' `controls' I.year `ifst', cluster(${firm_id})"
        probit turnover `rest' `controls' I.year `ifst', cluster(${firm_id})
        mgsto, marg(`marg')
            capture gen samp2 = e(sample)

        noisily display "{txt}Running: {res}probit turnover `rest'  `controls' I.has_cmr_ever I.year `ifst', cluster(${firm_id})"
        probit turnover `rest'  `controls' I.has_cmr_ever I.year `ifst', cluster(${firm_id})
        mgsto, marg(`marg')
    }

    noisily ///
    esttab, label compress nomtitles nogaps nobase noomitted noconst ///
            modelwidth(18) ///
            ${stars} eqlabels(none) collabels(none) ///
            cells("b(fmt(%4.3f) star)" "t(par fmt(${fmt2}))" ${plain_margins}) ///
            order(*restrict* *TSR*) ///
            stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Observations" )) ///
            indicate("Year FE = *year")

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_ceo_turnover_and_performance.tex", replace ///
        booktabs type compress nogaps nobase nomtitle nomtitles noomitted nolabel noconst ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations" )) ///
        indicate("Year F.E.=*year" , labels(Y N)) ///
        order(*restrict* *TSR*) ///
        varlabels(1.restrict "CMR Binding$ _{t} $" ///
                  1.restrict#cL.TSR_1 "CMR Binding$ _{t} \times $ TSR 1 year$ _{t-1} $" ///
                  1.restrict#cL.TSR_3 "CMR Binding$ _{t} \times $ TSR 3 year$ _{t-1} $" ///
                  L.TSR_1 "TSR 1 year$ _{t-1} $" ///
                  L.TSR_3 "TSR 3 year$ _{t-1} $" ///
                  l_ebit_at "ROA$ _{t-1} $"  ///
                  L.ceo_high_ownership "CEO High Ownership$ _{t-1} $"  ///
                  L.ceo_retirement_age "CEO Retirement Age$ _{t-1} $"  ///
                  L.ceo_tenure "CEO Tenure$ _{t-1} $" ///
                  1.has_cmr_ever "CMR Firm" ) ///
        substitute("=1" "" "\midrule" "" "CMR Binding$ _{t} $" "\midrule CMR Binding$ _{t} $" "Year F.E." "\midrule Year F.E." ///
                   "\toprule" "\toprule &\mc{6}{Dependent Variable = CEO Turnover$ _t $} \\  \cmidrule(lr){2-7} ")

    quietly count if samp2==1 & has_cmr_ever==1 & restrict==0
    local tot=r(N)
    quietly count if samp2==1 & has_cmr_ever==1 & restrict==0 & turnover==1
    local turn=r(N)
    noisily display "CMR (non-restrict): `turn' / `tot'  =  " ${fmt1} (100*`turn'/`tot') "%"

    quietly count if samp2==1 & has_cmr_ever==1 & restrict==1
    local tot=r(N)
    quietly count if samp2==1 & has_cmr_ever==1 & restrict==1 & turnover==1
    local turn=r(N)
    noisily display "CMR (restrict): `turn' / `tot'  =  " ${fmt1} (100*`turn'/`tot') "%"

    quietly count if samp2==1 & has_cmr_ever==0
    local tot=r(N)
    quietly count if samp2==1 & has_cmr_ever==0 & turnover==1
    local turn=r(N)
    noisily display "Non-CMR: `turn' / `tot'  =  " ${fmt1} (100*`turn'/`tot') "%"

    quietly count if samp2==1
    local tot=r(N)
    quietly count if samp2==1 & turnover==1
    local turn=r(N)
    noisily display "All: `turn' / `tot'  =  " ${fmt2} (100*`turn'/`tot') "%"

} // end $quietly
