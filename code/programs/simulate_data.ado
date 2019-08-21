
capture program drop simulate_data

program simulate_data, rclass
    version 10
    syntax varlist, [ debug ]

  if "`debug'" == "" local quietly quietly

  if "`compress'" == "" compress

  local varlist: list uniq varlist

  foreach v of local varlist {
    `quietly' sum `v', detail
    local p_min=r(min)
    local p_ave=r(mean)
    local p_std=r(sd)
    local p_max=r(max)
    `quietly' display "`p_min' -- `p_ave' (`p_std') -- `p_max'"

    if (("`: type `v''" == "float") | ("`: type `v''" == "double")) {
      display "{res}Continuous var `v' (`: type `v'')"

      `quietly' replace `v' = rnormal(`p_ave', `p_std')
      `quietly' replace `v' = `p_max' if `v' > `p_max'
      if `p_min' > 0 {
          `quietly' replace `v' = abs(`v')
      }
      `quietly' replace `v' = `p_min' if `v' < `p_min'
    }
    else { // integers
      display "{res}Integer `v' (`: type `v'')", _continue
      if (`p_min' == `p_max') { // constants, ignore
        display " is constant because {txt}`p_min' == `p_max'"
      }
      else if (`p_max' - `p_min'==1) { // 0/1 vars
        display " is binary because {txt}`p_max' - `p_min' == 1"
        `quietly' replace `v' = runiformint(0, 1)
      }
      else if (`p_max' - `p_min' < 50) { // small sample vars
        display " is small continuous because {txt}`p_max' - `p_min' == `=`p_max' - `p_min''"
        `quietly' replace `v' = runiformint(`p_min', `p_max')
      }
      else { // other vars, like gvkey/datadate
        display " is continuous, shuffling"
        `quietly' replace `v' = `p_min' if missing(`v')
        /* shufflevar from: https://ideas.repec.org/c/boc/bocode/s457116.html */
        shufflevar `v', inplace
      }
    }
  }

end
