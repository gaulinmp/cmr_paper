/* -*- coding: utf-8 -*- */

// wsum program, sum but wiiiiiiiiiiide labels so you can see your whole variable name.
capture program drop wsum
program wsum, rclass
    version 12
    syntax varlist(min=1 fv ts) [using] [if] [in], ///
            [ sort ///
            Detail ///
            stat_format(string asis) ///
            count_format(string asis) ///
            * ]

    *** This formats the inputs and sets up local variables.
    tokenize varlist
    fvunab varlist: `varlist'
    local varlist: list uniq varlist

    if "`sort'" != "" local varlist: list sort varlist

    local max_str_len = 1
    foreach v of local varlist {
        local i_str_len = strlen("`v'")
        if `i_str_len' > `max_str_len' local max_str_len `i_str_len'
    }

    if `"`statslabels'"' == `""' local statslabels `"`stats'"'

    quietly ///
    estpost summarize `varlist' `if' `in', detail

    if "`stat_format'"=="" local stat_format "(fmt(%12.3gc))"
    else local stat_format "(fmt(`stat_format'))"
    if "`count_format'"=="" local count_format "(fmt(%12.0gc))"
    else local count_format "(fmt(`count_format'))"

    local sf `"`stat_format'"'
    local cf `"`count_format'"'

    if "`detail'" == "" {
        local cols `"collabels("Obs"  "Mean"  "Std. Dev" Min  25%     Median  75%     Max ,) "'
        local cols `"`cols' cells("count`cf' mean`sf' sd`sf' min`sf' p25`sf' p50`sf' p75`sf' max`sf' ") "'
    }
    else {
        local cols `"collabels("Obs"  "Mean"  "Std. Dev" Min  1%     10%     25%     Median  75%     90%     99%     Max ,) "'
        local cols `"`cols' cells("count`cf' mean`sf' sd`sf' min`sf' p1`sf' p10`sf' p25`sf' p50`sf' p75`sf' p90`sf' p99`sf' max`sf' ") "'
    }

    esttab . , varwidth(`max_str_len') ///
        noobs nomtitles nonote nonumber ///
        `cols' `options'

    if `"`using'"' != `""' ///
    esttab . `using', varwidth(`max_str_len') ///
        noobs nomtitles nonote nonumber ///
        `cols' `options'

end
// end wsum program