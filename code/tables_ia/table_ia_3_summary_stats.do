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
    /*
     █████╗        ██╗   ██╗██████╗     ██╗██╗███╗   ██╗██████╗
    ██╔══██╗██╗    ╚██╗ ██╔╝██╔══██╗   ██╔╝██║████╗  ██║██╔══██╗
    ███████║╚═╝     ╚████╔╝ ██████╔╝  ██╔╝ ██║██╔██╗ ██║██║  ██║
    ██╔══██║██╗      ╚██╔╝  ██╔══██╗ ██╔╝  ██║██║╚██╗██║██║  ██║
    ██║  ██║╚═╝       ██║   ██║  ██║██╔╝   ██║██║ ╚████║██████╔╝
    ╚═╝  ╚═╝          ╚═╝   ╚═╝  ╚═╝╚═╝    ╚═╝╚═╝  ╚═══╝╚═════╝
    */
    eststo clear
    preserve
    sort ${depvar}

    noisily display "Copy and paste the following into ${tdir}\tables\ia\table_ia_3_year_industry.tex:." _n
    noisily display "\begin{tabular}{lcccccc} \toprule
    noisily display "\multicolumn{7}{c}{\small \centering \textbf{Panel A}: Year and Industry Distributions} \\ \midrule "
    noisily display "& \multicolumn{2}{c}{Firms (Packages) with CMR} & \multicolumn{2}{c}{Firms (Packages) without CMR} & & \\ "
    noisily display "& Frequency & Percent & Frequency & Percent & Difference & T-stat \\
    noisily display "\cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}
    noisily display "\textbf{Year}& & & & & & \\"
    noisily display "% Var,N CMR,% CMR,N noCMR,% noCMR,Difference,t-stat difference"

    foreach vv of numlist 1995/2015 {
        gen yr_`vv' = cond(year==`vv', 1, 0, .) if !missing(year)
        prtest yr_`vv', by(${depvar})
        noisily display  "{txt}`vv' &" ///
            %4.0fc r(P_2)*r(N_2) "  &  " %5.2f r(P_2)*100  "  &  "   ///
            %5.0fc r(P_1)*r(N_1) "  &  " %5.2f r(P_1)*100  "  &  "  ///
            %5.2f (r(P_2)-r(P_1))*100 "  &  ", _continue
        /* Clustered t-stat */
        regress yr_`vv' ${depvar}, cluster(${firm_id})
        noisily display "  " %5.2f _b[${depvar}]/_se[${depvar}] " \\ {res}"

    }
    restore


    preserve
    drop if missing(${ff12})
    local flab1  " 1–-NonDurb  "
    local flab2  " 2–-Durbl    "
    local flab3  " 3–-Manuf    "
    local flab4  " 4–-Energy   "
    local flab5  " 5–-Chems    "
    local flab6  " 6–-BusEqp   "
    local flab7  " 7–-Telcm    "
    local flab8  " 8–-Utils    "
    local flab9  " 9–-Shops    "
    local flab10 "10–-Health   "
    local flab11 "11–-REIT     "
    local flab12 "12–-Other    "

    noisily display " \addlinespace \multicolumn{7}{l}{\textbf{Industry (FF 12)}} \\ "
    noisily display "% All packages firm industry results:"
    noisily display "% Var,N CMR,% CMR,N noCMR,% noCMR,Difference,t-stat difference"

    foreach iff12 of numlist 1/12 {
        local v ${ff12}_`iff12'
        capture drop `v'
        gen `v' = cond(${ff12}==`iff12', 1, 0)
        prtest `v', by(${depvar})

        noisily display  "{txt}`flab`iff12''   &   " ///
            %4.0fc r(P_2)*r(N_2) "   &   " %5.2f r(P_2)*100  "   &   "   ///
            %5.0fc r(P_1)*r(N_1) "   &   " %5.2f r(P_1)*100  "   &   "  ///
            %5.2f (r(P_2)-r(P_1))*100 "   &   ", _continue

        /* Clustered t-stat */
        regress `v' ${depvar}, cluster(${firm_id})
        noisily display %5.2f _b[${depvar}]/_se[${depvar}] "   \\ {res}"
    }
    restore

    noisily display "\bottomrule" _n "\end{tabular}"




    /*
    ██████╗        ████████╗██╗   ██╗██████╗ ███╗   ██╗ ██████╗ ██╗   ██╗███████╗██████╗
    ██╔══██╗██╗    ╚══██╔══╝██║   ██║██╔══██╗████╗  ██║██╔═══██╗██║   ██║██╔════╝██╔══██╗
    ██████╔╝╚═╝       ██║   ██║   ██║██████╔╝██╔██╗ ██║██║   ██║██║   ██║█████╗  ██████╔╝
    ██╔══██╗██╗       ██║   ██║   ██║██╔══██╗██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗
    ██████╔╝╚═╝       ██║   ╚██████╔╝██║  ██║██║ ╚████║╚██████╔╝ ╚████╔╝ ███████╗██║  ██║
    ╚═════╝           ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝
    */
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_ceo_turnover_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }

    foreach v in TSR_1 TSR_3 ceo_high_ownership ceo_retirement_age ceo_tenure {
        capture drop tmp
        gen tmp = l.`v'
        replace `v' = tmp
        local lab: variable label `v'
        label variable `v' "`lab'$ _{t-1}$"
    }
    label variable turnover "CEO Turnover$ _t $ "

    local firmvars restrict override_restrict l_ebit_at TSR_1 TSR_3
    local ceovars turnover ceo_high_ownership ceo_retirement_age ceo_tenure

    reg turnover restrict TSR_1 l_ebit_at ceo_high_ownership ceo_retirement_age ceo_tenure if (year > 1994) & (year <= 2014) & (ceo_tenure>=24) & !missing(ceo_tenure)
    keep if e(sample)==1

    // sumstats
    eststo clear
    eststo: diffsumstat `firmvars' `ceovars' `ifst'

    local d "(fmt(${fmtc}))"
    local f "(fmt(${fmt2}))"
    noisily ///
    esttab, nomtitle nonumbers noobs label varwidth(30) ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f' ") ///
        collabels("N" "Mean" "Median" "Std. Dev.") ///
        ${stars}

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_3b_ceo_turnover_summary_stats.tex", replace type ///
        nomtitle nonumbers noobs booktabs label ///
        ${stars} substitute("%" "\%") ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f'") ///
        collabels("N" "Mean" "Median" "Std. Dev.", ///
                begin("\multicolumn{5}{c}{\small \centering \textbf{Panel B}: CEO Turnover Dataset -- Summary Statistics} \\ \midrule") ///
                ) ///
        varlabels(,blist(restrict "\multicolumn{5}{l}{\textbf{Firm Characteristics}} \\ " ///
                         turnover "\addlinespace \multicolumn{5}{l}{\textbf{CEO Characteristics}} \\ "))
    // end sumstats




    /*
     ██████╗       ███████╗██╗   ██╗███████╗██╗
    ██╔════╝██╗    ██╔════╝██║   ██║██╔════╝██║
    ██║     ╚═╝    ███████╗██║   ██║█████╗  ██║
    ██║     ██╗    ╚════██║██║   ██║██╔══╝  ██║
    ╚██████╗╚═╝    ███████║╚██████╔╝██║     ██║
     ╚═════╝       ╚══════╝ ╚═════╝ ╚═╝     ╚═╝
    */
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_cov_viol_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }

    local firmvars has_cmr_ever restrict turnoverq new_viol atq_log oic_at lev int_exp_at networth_to_at current_ratio mtb

    // sumstats
    eststo clear
    eststo: diffsumstat `firmvars'

    local d "(fmt(${fmtc}))"
    local f "(fmt(${fmt2}))"
    noisily ///
    esttab, nomtitle nonumbers noobs label varwidth(30) ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f' ") ///
        collabels("N" "Mean" "Median" "Std. Dev.") ///
        ${stars}

    if $writeout ///
    esttab using "${tdir}/ia/table_ia_3c_ceo_turnover_cov_viol_summary_stats.tex", replace type ///
        nomtitle nonumbers noobs booktabs label ///
        ${stars} ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f'") ///
        collabels("N" "Mean" "Median" "Std. Dev.", ///
                begin("\multicolumn{5}{c}{\small \centering \textbf{Panel C}: CEO Turnover and Covenant Violation Test -- Summary Statistics} \\ \midrule") ///
                )
    // end sumstats




    /*
    ██████╗        ███████╗████████╗ █████╗ ████████╗███████╗
    ██╔══██╗██╗    ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
    ██║  ██║╚═╝    ███████╗   ██║   ███████║   ██║   ███████╗
    ██║  ██║██╗    ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
    ██████╔╝╚═╝    ███████║   ██║   ██║  ██║   ██║   ███████║
    ╚═════╝        ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝
    */
    /* If running from Desktop, the following absolute path will work: */
    /* capture do "~/Desktop/cmr_paper/code/01_load_data.do" */
    /* If running from 02_make_tables.do, only that file should be changed to point to where these files reside. */
    capture do "${cdir}/01_load_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }

    local firmvars crsp_age debt_mat_3 block13_num1 xrd0_at VIXClose delist_pct_3yrs delist_in_7yrs khc_dummy khc_insure khc_intensity
    local loanvars has_cic relationship seniority_i excesscfsweep assetsalessweep debtissuancesweep equityissuancesweep dividendrestrictions_i insuranceproceedssweep borrowerbasetype_i

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
    esttab using "${tdir}/ia/table_ia_3d_summary_stats.tex", replace type ///
        nomtitle nonumbers noobs booktabs label ///
        ${stars} ///
        cells( "N_1`d' mu_1`f' med_1`f' sd_1`f'") ///
        collabels("N" "Mean" "Median" "Std. Dev.", ///
                begin("\multicolumn{5}{c}{\small \centering \textbf{Panel D}: Internet Appendix Variables -- Summary Statistics}\\ \midrule") ///
                ) ///
        varlabels(,blist(has_cmr_ever "\multicolumn{5}{l}{\textbf{Firm Characteristics}} \\ " ///
                        ${depvar} "\addlinespace \multicolumn{5}{l}{\textbf{Loan Characteristics}} \\ "))



} // end $quietly
