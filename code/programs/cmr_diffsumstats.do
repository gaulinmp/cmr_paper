
/* Program to calculate summary stats with optional by group */
capture program drop diffsumstat
program diffsumstat, eclass
    version 12
    syntax varlist [if] [in], [ by(varname) median * ]
    if "`if'" == "" {
        local if if 1
    }

    tempname mu_1 mu_2 sd_1 sd_2 N_1 N_2 med_1 med_2 ///
            d d_se d_t d_p d_med d_med_z d_med_p

    foreach var of local varlist {
        if "`by'" != "" ttest `var' `if', by(`by') `options'
        else ttest `var' == 0 `if', `options'

        mat `mu_1' = nullmat(`mu_1'), r(mu_1)
        mat `sd_1' = nullmat(`sd_1'), r(sd_1)
        mat `N_1'  = nullmat(`N_1' ), r(N_1)

        if "`by'" != "" {
            mat `sd_2' = nullmat(`sd_2'), r(sd_2)
            mat `mu_2' = nullmat(`mu_2'), r(mu_2)
            mat `N_2'  = nullmat(`N_2' ), r(N_2)
            mat `d'    = nullmat(`d'   ), r(mu_2)-r(mu_1)
            mat `d_se' = nullmat(`d_se'), r(se)
            mat `d_t'  = nullmat(`d_t' ), -r(t)
            mat `d_p'  = nullmat(`d_p' ), r(p)

            summarize `var' `if' & `by' == 0, detail
            mat `med_1' = nullmat(`med_1'), r(p50)
            local varmed1 = r(p50)
            summarize `var' `if' & `by' == 1, detail
            mat `med_2' = nullmat(`med_2'), r(p50)
            mat `d_med' = nullmat(`d_med'), r(p50)-`varmed1'

            if "`median'" == "" {
                ranksum `var' `if', by(`by')
                mat `d_med_z' = nullmat(`d_med_z'), -r(z)
                mat `d_med_p' = nullmat(`d_med_p'), 2*normal(-abs(r(z)))
            }
            else {
                median `var' `if', by(`by')
                mat `d_med_z' = nullmat(`d_med_z'), r(chi2)
                mat `d_med_p' = nullmat(`d_med_p'), r(p)
            }
        }
        else {
            summarize `var' `if', detail
            mat `med_1' = nullmat(`med_1'), r(p50)
        }

    }
    display "Done with stats. Now putting things in places"
    foreach mat in mu_1 mu_2 sd_1 sd_2 N_1 N_2 med_1 med_2 ///
                    d d_se d_t d_p d_med d_med_z d_med_p {
        capture mat coln ``mat'' = `varlist'
    }
    display "Done putting things in places. Now cleaning up."
    tempname b V
    mat `b' = `mu_1'*0
    mat `V' = `b''*`b'
    eret post `b' `V'
    eret local cmd "diffsumstat"
    foreach mat in mu_1 mu_2 sd_1 sd_2 N_1 N_2 med_1 med_2 ///
                    d d_se d_t d_p d_med d_med_z d_med_p {
        capture eret mat `mat' = ``mat''
    }
end
