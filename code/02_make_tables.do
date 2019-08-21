/* -*- coding: utf-8 -*- */

quietly {
    /* Assumes zip was extracted to the desktop.
    If not, replace the cd below with the location of the cmr_paper folder. */
    cd "~/Desktop/cmr_paper/
    run code/00_global_variables.do

    capture do "${cdir}/01_load_data.do"
    if _rc {
        noisily display "{err}Error loading data!"
        exit _rc
    }

    noisily display "{txt}Dep. Var.: {res}${depvar}"
    noisily display "{txt}Controls1: {res}$controls1"
    noisily display "{txt}Controls2: {res}$controls2"
    noisily display "{txt}Table Out: {res}$tdir"
    noisily display "{txt}Write Out: {res}$writeout"
}

/* Make tables in the main paper */
noisily do ${cdir}/tables/table_1_summary_stats
noisily do ${cdir}/tables/table_2_baseline_specifications
noisily do ${cdir}/tables/table_3_human_capital
noisily do ${cdir}/tables/table_4_contracting_frictions
noisily do ${cdir}/tables/table_4b_contracting_frictions_x_noncomp
noisily do ${cdir}/tables/table_4c_contracting_frictions_x_retage
noisily do ${cdir}/tables/table_5_pricing
noisily do ${cdir}/tables/table_6_ceo_turnover
noisily do ${cdir}/tables/table_7_firm_outcomes

/* Make tables in the IA */
noisily do ${cdir}/tables_ia/table_ia_2_cmr_type
    set more on
    more // for copy and pasting
    set more off
noisily do ${cdir}/tables_ia/table_ia_3_summary_stats
    set more on
    more // for copy and pasting
    set more off
noisily do ${cdir}/tables_ia/table_ia_4_determinants_plus
noisily do ${cdir}/tables_ia/table_ia_5_robust_human_capital
noisily do ${cdir}/tables_ia/table_ia_6_crsp_age_controls
noisily do ${cdir}/tables_ia/table_ia_7_human_capital_subsets
noisily do ${cdir}/tables_ia/table_ia_8_with_cic
noisily do ${cdir}/tables_ia/table_ia_9_with_loan_controls
noisily do ${cdir}/tables_ia/table_ia_10_facility_pricing
noisily do ${cdir}/tables_ia/table_ia_11_cmr_severity_pricing
noisily do ${cdir}/tables_ia/table_ia_12_alternate_ceo_turnover
noisily do ${cdir}/tables_ia/table_ia_13_ceo_turnover_delta_roa
noisily do ${cdir}/tables_ia/table_ia_14_ceo_turnover_no_roa
noisily do ${cdir}/tables_ia/table_ia_15_ceo_turnover_industry_returns
noisily do ${cdir}/tables_ia/table_ia_16_ceo_turnover_and_performance
noisily do ${cdir}/tables_ia/table_ia_17_ceo_turnover_cov_viol
noisily do ${cdir}/tables_ia/table_ia_18_firm_outcome_loan_controls
noisily do ${cdir}/tables_ia/table_ia_19_keyman_insurance
noisily do ${cdir}/tables_ia/table_ia_20_pre_post_loan_tests
