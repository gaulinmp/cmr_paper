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

    local laba1 "A1)  Any change triggers default                    "
    local laba2 "A2)  Voluntary change triggers default              "
    local laba3 "A3)  Approval required prior to change              "
    local laba4 "A4)  No prior approval required                     "
    local labb1 "B1)  Explicit replacement approval required         "
    local labc1 "C1)  General (unspecified or inclusive of both)     "
    local labc2 "C2)  Firm Initiated (removal/termination)           "
    local labc3 "C3)  Manager Initiated (leaving/failing to retain)  "
    local labd1 "D1)  Named individual(s)                            "
    local labd2 "D2)  Named management position(s)                   "
    local labd3 "D3)  Named individuals(s) and position(s)           "
    local labd4 "D4)  Vague position (unnamed, e.g. management)      "
    local labcovers_ceo "Covers CEO position                                 "

    noisily display "{txt}Copy and paste the following into ${tdir}\tables\ia\table_ia_CMR_categories.tex:" _n
    noisily display "{txt}\begin{tabular}{l*{6}{D{.}{.}{-1}}}"
    noisily display "{txt}    \toprule"
    noisily display "{txt}    & \multicolumn{2}{c}{Loans} & \multicolumn{2}{c}{Firms} & \multicolumn{2}{c}{Banks} \\ %"
    noisily display "{txt}    \cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}"
    noisily display "{txt}    Clauses                                            & \#         & \%         & \#        & \%      & \#     & \%    \\"
    noisily display "{txt}    \midrule"
    noisily display "{txt}    \addlinespace"
    noisily display "{txt}    \multicolumn{7}{l}{\textbf{A) Clause Restrictiveness }} \\"

    foreach v of varlist a1-a4 b1 c1-c3 d1-d4 covers_ceo {
        sum `v'
        noisily display "{res}    `lab`v'' & " ${fmtc} `=r(mean)*r(N)'  "  &  " ${fmtc} 100*r(mean) "\%  &  ", _c

        preserve
        collapse (max) `v', by(${firm_id})
        sum `v'
        noisily display " " ${fmtc} `=r(mean)*r(N)'  "  &  " ${fmtc} 100*r(mean) "\%  &  ", _c
        restore

        preserve
        collapse (max) `v', by(bankid)
        sum `v'
        noisily display " " ${fmtc} `=r(mean)*r(N)'  "  &  " ${fmtc} 100*r(mean) "\%  \\  "
        restore

        if "`v'"=="a4" noisily display "{txt}    \addlinespace \multicolumn{7}{l}{\textbf{B) Replacement Approval}} \\ "
        if "`v'"=="b1" noisily display "{txt}    \addlinespace \multicolumn{7}{l}{\textbf{C) Source of the Change}} \\ "
        if "`v'"=="c3" noisily display "{txt}    \addlinespace \multicolumn{7}{l}{\textbf{D) Management Definition}} \\ "
    }
    noisily display "{txt}    \bottomrule"
    noisily display "{txt}\end{tabular}"

} // end $quietly
