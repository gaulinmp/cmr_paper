***Program to estimate three stage heckman corrected difference regression
capture program drop pricingreg
* macro drop _all
* capture prog drop _all

program pricingreg, rclass
  version 11
  syntax varlist(min=1 fv ts) [if] [in], ///
      Yieldvar(varname) ///
      [ /// optional arguments
        Zvec(varlist fv ts) ///
        Xvec(varlist fv ts) ///
        INTeraction(varname) ///
        cluster(varname) ///
        y_hat_name(string) ///
        noYFE noIFE ///
        debug ///
        * ///
      ]

  if "`debug'" != "" local noisily noisily
  else local noisily quietly

  quietly {
    marksample touse, strok
    count if `touse'
    if r(N) == 0 {
      error 2000
    }
    preserve
    keep if `touse'

    tokenize `varlist'
    tokenize `xvec'
    *fvunab xvec : xvec
    tokenize `zvec'
    *fvunab zvec : zvec

    // Extract variables from the argument.
    local yescov: word 1 of `varlist'
    local varXZ : list uniq varlist
    local varXZ : list varXZ - yescov
    if "`interaction'" != "" {
      local varXZ : list varXZ | interaction
    }
    local varX  : list uniq xvec
    local varX  : list varX - varXZ
    local varZ  : list uniq zvec
    local varZ  : list varZ - varXZ
    local varY "`yieldvar'"

    if "`y_hat_name'"=="" {
      local y_hat_name "Y_hat"
    }

    if "`yfe'" == "" {
      local varyfe i.year
      local varXZ : list varXZ | varyfe
    }
    if "`ife'" == "" {
      /* fvunab varife : ff12_* */
      local varife i.${ff12}
      local varXZ : list varXZ | varife
    }
  }
  display "Y/N Cov: " "`yescov'"
  display "    Y_i: " "`varY'"
  display "    X_i: " "`varX'"
  display "   XZ_i: " "`varXZ'"
  display "    Z_i: " "`varZ'"


  * (i)  First stage
  display "{res}(i) Running first stage based on:"
  display "{txt}`yescov' ~ `varX' `varZ' `varXZ'"
  quietly probit `yescov' `varX' `varZ' `varXZ', cluster(`cluster')

  * (ii)  Construct IMR -- Selection correction
  display "{res}(ii) Generating IMR based on `yescov'..."
  `noisily' {
    predict i_hat, xb
    gen IMR=cond(`yescov'==0, ///
                 normalden(i_hat)/(1-normal(i_hat)), /// /* IMR for 0 */
                 -normalden(i_hat)/normal(i_hat)) /* IMR for 1 */
  }


  * (iii) & (iv)  Predict Yield corrected for the selection
  display "{res}(iii) `y_hat_name'_nocov where `yescov'==0 based on:"
  display "{txt}`varY' ~ IMR `varX' `varXZ'"
  `noisily' {
    reg `varY' IMR `varX' `varXZ' if `yescov'==0, cluster(`cluster')
    predict `y_hat_name'_nocov_tmp, xb
    gen `y_hat_name'_nocov=`y_hat_name'_nocov_tmp -_b[IMR]*IMR
  }
  `noisily' sum `y_hat_name'_nocov, d

  display "{res}(iv) `y_hat_name'_cov where `yescov'==1..."
  `noisily' {
    reg `varY' IMR `varX' `varXZ' if `yescov'==1, cluster(`cluster')
    predict `y_hat_name'_cov_tmp, xb
    gen `y_hat_name'_cov=`y_hat_name'_cov_tmp-_b[IMR]*IMR
  }
  `noisily' sum `y_hat_name'_cov, d


  * (v)  Get the predicted difference in yield
  display "{res}(v) Generating predicted difference..."
  `noisily' gen `y_hat_name'=`y_hat_name'_nocov-`y_hat_name'_cov
  `noisily' sum `y_hat_name', d

  // Print out VIF
  /* display "VIF of model:"
  quietly reg `yescov' `y_hat_name' `varZ' `varXZ', cluster(`cluster')
  noisily: estat vif */


  * (vi) Run the main regression (covenant decision) with the predicted difference in yield
  display "{res}(vi) Running corrected model based on"
  display "{txt}`yescov' ~ `y_hat_name' `varZ' `varXZ'"
  `noisily' eststo: probit `yescov' `y_hat_name' `varZ' `varXZ', cluster(`cluster')

  /*quietly local tmpr2=e(r2_p)+0
  eststo `title': margins, dydx(*) post
  quietly estadd scalar r2_p=`tmpr2', replace*/
  quietly estadd margins, dydx(`y_hat_name')
  quietly estadd local yfe "`textyfe'" , replace
  quietly estadd local ife "`textife'" , replace
  // estat classification


  if "`interaction'" != "" {
    display "{res}(vii) Running interaction for model:"
    display "{txt}`yescov' ~ `y_hat_name' Yhat_X_`interaction' `varZ' `varXZ'"
    quietly {
      local yhati "`y_hat_name'_X_`interaction'"
      gen `yhati' = `y_hat_name' * `interaction'

      probit `yescov' `y_hat_name' `yhati' `varZ' `varXZ', cluster(`cluster')
      local tmpr2=e(r2_p)+0
    }
    eststo `title': margins, dydx(`y_hat_name') post
    estadd scalar r2_p=`tmpr2', replace
    estadd local yfe "`textyfe'" , replace
    estadd local ife "`textife'" , replace
    eststo: regress `yescov' `y_hat_name' `yhati' `varZ' `varXZ', cluster(`cluster')
  }
  ttest `y_hat_name'_nocov, by(`yescov')
  ttest `y_hat_name'_cov  , by(`yescov')
  ttest `y_hat_name'      , by(`yescov')

  restore
end
