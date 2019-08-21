***Program to estimate three stage heckman corrected difference regression
capture program drop basereg

program basereg, rclass
  version 13
  syntax varlist(min=1 fv) [if] [in], [INTeraction(varname) ///
          vif cluster(varname) margins(string asis) ///
          noyfe noife nosfe nolfe noffe nosave ///
          debug * ]

  if "`debug'" != "" local noisily noisily
  `noisily' {

    preserve

    *** This formats the inputs and sets up local variables.
    tokenize `varlist'
    * fvunab varlist : varlist

    // Extract variables from the argument.
    local depvar: word 1 of `varlist'
    local indvar: list uniq varlist
    local indvar: list indvar - depvar

    local textyfe "N"
    local textife "N"
    local textsfe "N"
    local textlfe "N"
    local textffe "N"
    if "`yfe'" == "" {
      /* fvunab varyfe : yr_* */
      local varyfe i.year
      local indvar : list indvar | varyfe
      local textyfe "Y"
    }
    if "`ife'" == "" {
      /* fvunab varife : ${ff12}_* */
      local varife i.${ff12}
      local indvar : list indvar | varife
      local textife "Y"
    }
    if "`sfe'" == "" local textsfe "Y"
    if "`lfe'" == "" local textlfe "Y"
    if "`ffe'" == "" local textffe "Y"

    *** This is just some code to calculate VIF and put them in the table output
    if "`vif'" != "" {
      regress `depvar' `indvar' `if', cluster(`cluster')
      estat vif
      local ave_vif = 0
      local max_vif = 0
      local hi_vif = 0
      forvalues vn = 1/`=e(rank)-1'{
        local ave_vif = `ave_vif' + r(vif_`vn')
        if r(vif_`vn') > `max_vif' local max_vif = r(vif_`vn')
        if r(vif_`vn') > 10 local hi_vif = `hi_vif' + 1
      }
      local ave_vif = `ave_vif'/(e(rank)-1)
    }

    *** This is the main regression. Everything else is for formatting.
    display "{txt}Running: {res}probit `depvar' `indvar' `if', cluster(`cluster')"
    probit `depvar' `indvar' `if', cluster(`cluster')
    if "`save'" == "" {
      *** This calculates the margins, and stores them in an esttab output.
      if "`margins'" != "" {
        estadd margins, dydx(`margins')
      }
      eststo

      *** This adds all those fixed effect Y/N flags and the VIF stats from above
      if "`vif'" != "" {
        estadd scalar ave_vif=`ave_vif', replace
        estadd scalar max_vif=`max_vif', replace
        estadd scalar hi_vif=`hi_vif', replace
      }
      estadd local yfe="`textyfe'", replace
      estadd local ife="`textife'", replace
      estadd local sfe="`textsfe'", replace
      estadd local lfe="`textlfe'", replace
      estadd local ffe="`textffe'", replace
    }

    if "`vif'" != "" {
      `noisily' display "Average VIF: `ave_vif'"
      `noisily' display "Maximum VIF: `max_vif'"
      `noisily' display "# >= 10 VIF: `hi_vif'"
    }

    *** Revert back to the original file, where the 'if' observations aren't dropped.
    restore
  } // end noisily
end


// runmainspec
capture program drop runmainspec
program runmainspec, rclass
  version 11
  syntax varlist(min=1 fv) [if] [in], [noyfe noife margins debug dv(varname fv ts) nospec1 nospec2 omitcont(varlist fv ts) *]

  tokenize `varlist'
  local intvar : list uniq varlist
  if "`dv'" == "" local dv ${depvar}
  if "`margins'" != "" local margins margins(`intvar')

  local controls1 $controls1
  local controls2 $controls2
  if "`omitcont'" != "" {
      local controls1: list controls1 - omitcont
      local controls2: list controls2 - omitcont
  }

  if "`spec1'" == "" {
    if "`debug'" != "" noisily display `"basereg `dv' `intvar' `controls1' `if', cluster(gvkey) `margins' `ife' `yfe' `debug'"'
    basereg `dv' `intvar' `controls1' `if', cluster(gvkey) `margins' `ife' `yfe' `debug'
  }

  if "`spec2'" == "" {
    if "`debug'" != "" noisily display `"basereg `dv' `intvar' `controls2' `if', cluster(gvkey) `margins' `ife' `yfe' `debug'"'
    basereg `dv' `intvar' `controls2' `if', cluster(gvkey) `margins' `ife' `yfe' `debug'
  }
end
// end runmainspec



capture program drop mgsto
program mgsto, eclass
    syntax , [noyfe marg(varname fv ts) *]

    if "`marg'" != "" {
    estadd margins, dydx(`marg')
    }
    eststo
end
