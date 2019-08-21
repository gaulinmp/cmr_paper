/* -*- coding: utf-8 -*- */
/*
Global variables file, to be shared across all stata do files.
*/

/*
██╗   ██╗ █████╗ ██████╗ ███████╗
██║   ██║██╔══██╗██╔══██╗██╔════╝
██║   ██║███████║██████╔╝███████╗
╚██╗ ██╔╝██╔══██║██╔══██╗╚════██║
 ╚████╔╝ ██║  ██║██║  ██║███████║
  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
*/
/* Main dependent variable
   == restrict for most of this paper, barring sub-sample tests */
global depvar restrict

/* Controls for firm-level specifications */
global controls1only log_at zscore_modified log_tangibility mtb p0_oibdp_at lev_book rate_dum term_spread credit_spread
global controls1 $controls1only

/* Controls for loan and syndicate */
global controls2only log_num_lenders scaled_amount log_maturity collat num_fincovs ppricing I.ppurpose I.ltype
global controls2 $controls1 $controls2only

/* Industry/year variables */
global firm_id gvkey
global ff12 ff12h

/*
███████╗███████╗████████╗████████╗██╗███╗   ██╗ ██████╗ ███████╗
██╔════╝██╔════╝╚══██╔══╝╚══██╔══╝██║████╗  ██║██╔════╝ ██╔════╝
███████╗█████╗     ██║      ██║   ██║██╔██╗ ██║██║  ███╗███████╗
╚════██║██╔══╝     ██║      ██║   ██║██║╚██╗██║██║   ██║╚════██║
███████║███████╗   ██║      ██║   ██║██║ ╚████║╚██████╔╝███████║
╚══════╝╚══════╝   ╚═╝      ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
*/
/* Write outputs to disk */
global writeout 1

/* Code and data directories */
global ddir "data"
global cdir "code"

/* Output tables directory */
global tdir "paper/tables"


/* Formatting things. */
global fmt3 "%4.3f"
global fmt2 "%4.2f"
global fmt1 "%4.1f"
global fmtc "%6.0fc"

global stars "star(* 0.10 ** 0.05 *** 0.01)"
global tex_margins `"margins_b(fmt(${fmt3}) par("\textit{" "}"))"'
global plain_margins `"margins_b(fmt(${fmt3}) par({ }))"'

global min_indicate `" "Loan Purpose F.E.=*.ppurpose" "Loan Type F.E.=*.ltype" "Year F.E.=*year" "Industry F.E.=*.${ff12}" "'
global max_indicate `" "Firm Controls=$controls1only" "Loan/Syndicate Controls=log_num_lenders scaled_amount log_maturity collat num_fincovs ppricing" $min_indicate "'
global firm_tex_sub "Firm Controls" "\addlinespace \midrule Firm Controls" "=1" ""

/* Suppress output */
global quietly quietly
