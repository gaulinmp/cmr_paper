/* -*- coding: utf-8 -*- */
quietly { // load data
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_cov_viol_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }
} // end load data

$quietly {
    eststo clear

    local indvar f1_new_viol new_viol l1_new_viol l2_new_viol l3_new_viol l4_new_viol
    local firm_controls atq_log oic_at lev int_exp_at networth_to_at current_ratio mtb
    local FE Ib12.${ff12} Ib19982.fyq I.cyq

    eststo: reg turnoverq I.(`indvar')##I.$depvar `firm_controls' `FE', cluster(gvkey)
    eststo: reg turnoverq I.(`indvar')##I.$depvar I.has_cmr_ever `firm_controls' `FE', cluster(gvkey)

    noisily ///
    esttab, nolabel compress nogaps nolines noconst noomitted nobase ///
            varwidth(25) ${stars} eqlabels(none) collabels(none) ///
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))") ///
            stats(r2_p N, fmt(${fmt3} ${fmtc}) labels("R^2" "Obs.")) ///
            order(*viol* *$depvar*) ///
            indicate("Firm Controls= atq_log oic_at lev int_exp_at networth_to_at current_ratio mtb"  ///*.int_exp_at *.networth_to_at *.current_ratio *.mtb"  ///
                     "Fiscal \& Calendar Quarter F.E. = *yq" "Industry F.E. = *.${ff12}" )

    #delimit ;
    if $writeout noisily
    esttab using "${tdir}/ia/table_ia_ceo_turnover_cov_viol.tex", replace
            booktabs type label compress nogaps noomitted nobase nomtitle noconstant
            ${stars} eqlabels(none) collabels(none)
            cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))")
            stats(r2 N, fmt(${fmt2} ${fmtc}) labels("R$ ^2$" "Observations"))
            indicate("Firm Controls=1.restrict atq_log oic_at lev int_exp_at networth_to_at current_ratio mtb"
                     "Fiscal \& Calendar Quarter F.E. = *yq"
                     "Industry F.E. = *.${ff12}", labels(Y N) )
            order(*new_viol* *cmr*)
            varlabels(1.f1_new_viol "New Covenant Violation$ _{t+1} $"
                         1.new_viol "New Covenant Violation$ _{t}$"
                      1.l1_new_viol "New Covenant Violation$ _{t-1}$"
                      1.l2_new_viol "New Covenant Violation$ _{t-2}$"
                      1.l3_new_viol "New Covenant Violation$ _{t-3}$"
                      1.l4_new_viol "New Covenant Violation$ _{t-4}$"
                      1.f1_new_viol#1.restrict "New Covenant Violation$ _{t+1}$  $ \times $ CMR Clause Binding$ _t $"
                         1.new_viol#1.restrict "New Covenant Violation$ _{t}$    $ \times $ CMR Clause Binding$ _t $"
                      1.l1_new_viol#1.restrict "New Covenant Violation$ _{t-1}$  $ \times $ CMR Clause Binding$ _t $"
                      1.l2_new_viol#1.restrict "New Covenant Violation$ _{t-2}$  $ \times $ CMR Clause Binding$ _t $"
                      1.l3_new_viol#1.restrict "New Covenant Violation$ _{t-3}$  $ \times $ CMR Clause Binding$ _t $"
                      1.l4_new_viol#1.restrict "New Covenant Violation$ _{t-4}$  $ \times $ CMR Clause Binding$ _t $"
                      1.has_cmr_ever "CMR Firm"
                      )
            substitute("\midrule" "" "\toprule" "\toprule \multicolumn{3}{c}{Dependent Variable = CEO Turnover} \\ "
                       "New Covenant Violation$ _{t+1} $" "\midrule New Covenant Violation$ _{t+1} $"
                       "Firm Controls" "\midrule Firm Controls" )
    ;
    #delimit cr
}
