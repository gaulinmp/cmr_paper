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

    // Main test
    local rest (i.restrict)
    local marg I.restrict

    // Controls
    local acctperf l_ebit_at
    local ceocontrols l.ceo_high_ownership l.ceo_retirement_age l.ceo_tenure
    local ifst if (year > 1994) & (year <= 2014) & (l.ceo_tenure>=24) & !missing(l.ceo_tenure)

    foreach n in 1 3 {
        local stockperf (l.TSR_`n')

        local controls `stockperf' `acctperf' `ceocontrols'

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
    esttab using "${tdir}/table_6_ceo_turnover.tex", replace ///
        booktabs type label compress nogaps nobase noomitted nomtitles noconst nonote ///
        ${stars} eqlabels(none) collabels(none) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        order(*restrict* *TSR*) ///
        varlabels(1.restrict "CMR Clause Binding$ _{t} $" ///
                  L.TSR_1 "TSR 1 year$ _{t-1} $" ///
                  L.TSR_3 "TSR 3 year$ _{t-1} $" ///
                  l_ebit_at "ROA$ _{t-1} $"  ///
                  L.ceo_high_ownership "CEO High Ownership$ _{t-1} $"  ///
                  L.ceo_retirement_age "CEO Retirement Age$ _{t-1} $"  ///
                  L.ceo_tenure "CEO Tenure$ _{t-1} $" ///
                  1.has_cmr_ever "CMR Firm" ) ///
        indicate("\midrule Year F.E.=*year", labels(Y N)) ///
        substitute("\toprule" "\toprule &\multicolumn{6}{c}{Dependent Variable = CEO Turnover$ _t $ } \\")
    /* After writing out, add \addlinespace \textit{CMR Clause Binding:} & & & & & & \\ \textit{Average Marginal Effect} \addlinespace
    in front of the first \textit{}, and move it to the last line. */

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


    /* Now print out turnover stats for EXCEL spreadsheet figures. More copy and paste. */
    noisily display _n "Running for graphs: probit turnover l.TSR_1 `acctperf' `ceocontrols' i.year `ifst' & (has_cmr_ever==1), cluster(${firm_id})""
    probit turnover l.TSR_1 `acctperf' `ceocontrols' i.year `ifst' & (has_cmr_ever==1), cluster(${firm_id})

    predict predict_turnover, p
    gen deviation_predict = turnover - predict_turnover

    gen DROP_CMR=cond((restrict==0) & (l.restrict==1),1,0) if missing(l.restrict)==0 & missing(restrict)==0
    gen ADD_CMR=cond((restrict==1) & (l.restrict==0),1,0) if missing(l.restrict)==0 & missing(restrict)==0


    gen DropF3andF4=cond(restrict==1 & (F3.DROP_CMR==1|F4.DROP_CMR==1),1,0)
    gen DropFandF2=cond(restrict==1 & (F.DROP_CMR==1|F2.DROP_CMR==1),1,0)

    gen DropandL=cond(restrict==0 & (DROP_CMR==1|L.DROP_CMR==1),1,0)
    gen DropL2andL3=cond(restrict==0 & (L2.DROP_CMR==1|L3.DROP_CMR==1),1,0)

    gen AddF3andF4=cond(restrict==0 & (F3.ADD_CMR==1|F4.ADD_CMR==1),1,0)
    gen AddFandF2=cond(restrict==0 & (F.ADD_CMR==1|F2.ADD_CMR==1),1,0)

    gen AddandL=cond(restrict==1 & (ADD_CMR==1|L.ADD_CMR==1),1,0)
    gen AddL2andL3=cond(restrict==1 & (L2.ADD_CMR==1|L3.ADD_CMR==1),1,0)

    noisily display _n "Making figures: Copy the following into the {txt}Data{res} tab of the {txt}turnover_figures.xlsx{res} excel sheet." _n

    foreach v in DropF3andF4 DropFandF2 DropandL DropL2andL3 {
        sum deviation_predict `ifst' & (has_cmr_ever==1) & (`v' == 1)
            noisily display "`v'  " r(mean)
    }
    foreach v in AddF3andF4 AddFandF2 AddandL AddL2andL3 {
        sum deviation_predict `ifst' & (has_cmr_ever==1) & (`v' == 1)
            noisily display "`v'  " r(mean)
    }

} // end $quietly
