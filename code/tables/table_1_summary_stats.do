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

    local firmvars $controls1only p0_tobinsq ///
            NonCompete_low CG_PercInsider ///
            CEO_Founder ceo_shrown_pct ///
            ceo_preret no_heir ///
            age new_ceo tenure

    local loanvars allindrawn num_lenders scaled_amount maturity ///
                collat num_fincovs ppricing lead_perc same_state

    // sumstats
    eststo clear
    eststo: diffsumstat has_cmr_ever `firmvars' ${depvar} `loanvars'

    local d "(fmt(${fmtc}))"
    local f "(fmt(${fmt2}))"
    noisily ///
    esttab, nomtitle nonumbers noobs label varwidth(30) ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f' ") ///
        collabels("N" "Mean" "Median" "Std. Dev.") ///
        ${stars}

    if $writeout ///
    esttab using "$tdir/table_1a_summary_stats.tex", replace type ///
        nomtitle nonumbers noobs booktabs label ///
        ${stars} ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f'") ///
        collabels("N" "Mean" "Median" "Std. Dev.", ///
                begin("\multicolumn{5}{c}{\small \centering \textbf{Panel A}: Summary Statistics}\\ \midrule") ///
                ) ///
        varlabels(,blist(has_cmr_ever "\multicolumn{5}{l}{\textbf{Firm Characteristics}} \\ " ///
                        ${depvar} "\addlinespace \multicolumn{5}{l}{\textbf{Loan Characteristics}} \\ "))
    // end sumstats


    // begin univariates
    eststo clear
    eststo: diffsumstat `firmvars' `loanvars', by(${depvar})

    local d "(fmt(${fmtc}))"
    local f "(fmt(${fmt2}))"
    noisily ///
    esttab, nomtitle nonumbers noobs label ///
        cells( "N_2`d' mu_2`f' med_2`f' N_1`d' mu_1`f' med_1`f' d(star pvalue(d_p) fmt(%9.2fc)) d_t`f' d_med_z(star pvalue(d_med_p) fmt(%9.2fc))") ///
        collabels("N" "Mean" "Median" "N" "Mean"  "Median" ///
                "Difference" "T-stat" "Z-stat") ///
                ${stars}

    #delimit ;
    if $writeout
    esttab using "$tdir/table_1b_univariate_analysis.tex",
        replace booktabs type
        nomtitle nonumbers noobs  label
        ${stars}
        cells( "mu_2`f' med_2`f'
                mu_1`f' med_1`f'
                d(star pvalue(d_p) fmt(%9.2fc))
                d_t(fmt(%9.2fc))
                d_med_z(star pvalue(d_med_p) fmt(%9.2fc))")
        collabels("Mean" "Median" "Mean"  "Median"
                "Difference" "T-stat" "Z-stat",
                    begin("
                    \multicolumn{8}{c}{\small \centering \textbf{Panel B}: Univariate Analysis} \\ \midrule
                    & \multicolumn{2}{c}{Loan Contract} & \multicolumn{2}{c}{Loan Contract} & \multicolumn{2}{c}{Difference} & Wilcoxon \\
                    & \multicolumn{2}{c}{with a CMR} &  \multicolumn{2}{c}{with no CMR} &  \multicolumn{2}{c}{in Mean} &  \multicolumn{1}{c}{Rank-Sum Test} \\
                        \cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}\cmidrule(lr){8-8}"
                    ))
        varlabels(,blist(log_at "\multicolumn{8}{l}{\textbf{Firm Characteristics}} \\ "
                        allindrawn "\addlinespace \multicolumn{8}{l}{\textbf{Loan Characteristics}} \\ "))
    ;
    #delimit cr
    // end univariates

    quietly sum ${depvar}
    noisily display "{txt}Number of Packages: {res}`=r(N)'"
    noisily display "{txt}Number of Packages CMR: {res}`=r(N)*r(mean)'"
    noisily display "{txt}Percent of Packages CMR: {res}`=round(1000*r(mean))/10'"
    noisily display "{txt}Number of Packages NoCMR: {res}`=r(N)*(1-r(mean))'" _n

    preserve
    collapse (max) ${depvar}, by(${firm_id})
    quietly sum ${depvar}
    noisily display "{txt}Number of Firms: {res}`=r(N)'"
    noisily display "{txt}Number of Firms CMR: {res}`=r(N)*r(mean)'"
    noisily display "{txt}Percent of Firms CMR: {res}`=round(1000*r(mean))/10'"
    noisily display "{txt}Number of Firms NoCMR: {res}`=r(N)*(1-r(mean))'" _n
    restore

    preserve
    keep if at <= 26.47 & !missing(at)
    sum ${depvar}
    noisily display "{txt}Percent of <26M Packages CMR: {res}`=round(1000*r(mean))/10'"
    sum has_cmr_ever
    noisily display "{txt}Percent of <26M Packages CMR ever: {res}`=round(1000*r(mean))/10'"
    collapse (max) ${depvar} has_cmr_ever, by(${firm_id})
    sum ${depvar}
    noisily display "{txt}Percent of <26M Firm CMR: {res}`=round(1000*r(mean))/10'"
    sum has_cmr_ever
    noisily display "{txt}Percent of <26M Firm CMR ever: {res}`=round(1000*r(mean))/10'" _n
    restore



    preserve
    quietly sum crsp_age, d
    gen young_CEO_Founder = CEO_Founder if crsp_age <= r(p50) & !missing(crsp_age)
    gen old_CEO_Founder   = CEO_Founder if crsp_age >  r(p50) & !missing(crsp_age)

    eststo clear
    eststo: ///
    diffsumstat num_lenders num_leads lead_perc crsp_age *o*CEO_Founder, by(${depvar})

    local d "(fmt(${fmtc}))"
    local f "${fmt2}"
    local ff "fmt(`f')"
    local pf "(`ff')"
    noisily ///
    esttab, nomtitle nonumbers noobs label ///
        cells( "N_2`d' mu_2`pf' med_2`pf' N_1`d' mu_1`pf' med_1`pf' d(star pvalue(d_p) `ff') d_t`pf' d_med_z(star pvalue(d_med_p) `ff')") ///
        collabels("N" "Mean" "Median" "N" "Mean"  "Median" ///
                "Difference" "T-stat" "Z-stat") ///
                ${stars}
    restore

    ttest num_lenders, by(${depvar})
    ttest num_leads, by(${depvar})
    ttest lead_perc, by(${depvar})

    ttest crsp_age, by(${depvar})
    quietly sum crsp_age, d
    display _n "Age test for Young Firms" _n
    ttest CEO_Founder if crsp_age <= r(p50), by(${depvar})
    quietly sum crsp_age, d
    display _n "T-test for Old Firms" _n
    ttest CEO_Founder if crsp_age > r(p50), by(${depvar})

} // end quietly
