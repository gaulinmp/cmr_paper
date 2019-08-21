/* -*- coding: utf-8 -*- */
quietly { // load data
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_facility_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }
} // end load data

$quietly {

    eststo clear

    /* Outcome variable */
    local y log_allindrawn

    ** Z: leave out loan purpose and maturity from the CMR regressions
    local zonly1 log_num_lenders
    local zonly2 log_num_lenders lead_per
    local zonly3 log_num_lenders lead_per same_state

    /* Variables always in X matrix are the loan level variables, $controls2only
    But we have to remove the loan variables in Z we use as identification
    Uncomment the local declaration below to  */
    local controls2 $controls2only
    local xonly: list controls2 - zonly1
    local xonly: list xonly - zonly2
    local xonly: list xonly - zonly3

    /* The variables that are in both X and Z
    are the firm level controls, or $controls1only */
    local xzboth $controls1only

    noisily display "{res}Z only 1: {txt}`zonly1'"
    noisily display "{res}Z only 2: {txt}`zonly2'"
    noisily display "{res}Z only 3: {txt}`zonly3'"
    noisily display "{res}X only:   {txt}`xonly'"
    noisily display "{res}Both:     {txt}`xzboth'"


    /* Run pricing regressions */
    pricingreg ${depvar} `xzboth', y(`y') x(`xonly') z(`zonly1') cluster(${firm_id})
    pricingreg ${depvar} `xzboth', y(`y') x(`xonly') z(`zonly2') cluster(${firm_id})
    pricingreg ${depvar} `xzboth', y(`y') x(`xonly') z(`zonly3') cluster(${firm_id})

    noisily ///
    esttab, nolabel compress nogaps nobase ///
        varwidth(25) ${stars} eqlabels(none) collabels(none) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R2" "Obs.")) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${plain_margins}) ///
        order(Y_hat  $controls1only) ///
        indicate("Industry F.E.= *.${ff12}" "Year F.E.=*year") ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0))

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_10_facility_pricing.tex", replace ///
        booktabs type label compress nogaps nobase noomitted nomtitles noconst nonote ///
        ${stars} eqlabels(none) collabels(none) ///
        stats(r2_p N, fmt(${fmt2} ${fmtc}) labels("Pseudo R$ ^2$" "Observations")) ///
        cells("b(fmt(${fmt3}) star)" "t(par fmt(${fmt2}))" ${tex_margins}) ///
        order(Y_hat $controls1only) ///
        indicate("\addlinespace \midrule Firm Controls=$controls1only" ///
                 "Loan/Syndicate Controls=log_num_lenders lead_per same_state" ///
                 "Industry F.E.=*12*" "Year F.E.=*year", labels(Y N)) ///
        mgroup("Dependent Variable = CMR Clause",  ///
                span pattern(1 0 0 0 0 0) ///
                prefix("\mc{@span}{") ///
                suffix("}") ///
                erepeat(\cmidrule(lr){@span}) ///
            ) ///
        substitute("Y_hat" "$ \widehat{LogYield}_{NoCMR}-\widehat{LogYield}_{CMR} $ " )
    /* After writing out, add \addlinespace \textit{Average Marginal Effect}  in front of first \textit */

}
