<h1 style="text-align:center">Debt Contracting on Management</h1>
<p style="text-align:center">By Brian Akins, David De Angelis, and Maclean Gaulin.</p>
<p style="text-align:center">August 12, 2019</p>
<p style="text-align:center">Forthcoming at <a href='https://onlinelibrary.wiley.com/journal/15406261' target=_blank>Journal of Finance</a>.</p>


[SSRN Link](https://papers.ssrn.com/abstract=2757508)

## Code
The `code/` folder contains all the stata code required to create the tables in the main paper and the Internet Appendix (IA).
The main files are:

* `00_global_variables.do`: File for loading global variables such as specification controls, and flags for whether to write result to disk, etc.
* `01_load_*.do`: Files to load the datasets for the various tests. Also load the programs used in the tests.
* `02_make_tables.do`: File to run the whole set of test, resulting in latex tables which can be used to generate the full paper.
* `tables/*.do`: Files to run each table in the main paper
* `tables_ia/*.do`: Files to run each table in the IA
* `programs/`: Programs which are called in the files above, which facilitate the analysis and formatting of tables.


### Instructions on running:

The following steps can be performed to run the code to generate all the tables:

1. Clone the repo to the desktop (so the files are at `Desktop/cmr_paper/`).
2. Open Stata, and run `02_make_tables.do`

To run an individual table, the steps are:

1. Clone the repo to the desktop (so the files are at `Desktop/cmr_paper/`).
2. Open Stata, and run `01_load_data.do`
3. Run the table you wish to run, e.g. `code/tables/table_2_baseline_specifications.do`

The code assumes it is running from `Desktop/cmr_paper/`, so this is the simplest method.
To run from another directory, change all mentions in the code from `Desktop/cmr_paper` to `directory of git repo`.

## Data
The `data/` folder includes the excel file `cmr_hand_collected_data.xlsx`, which contains the full set of hand-collected CMR data, with the identifiers: CIK and loan_date, for matching to publically available datasets.

We also include the following datasets, to facilitate running the code and generating tables in Latex format.
The included datasets contain simulated data, which was simulated by running the `simulate_data` on all our variables (for simulation code, see `code/programs/simulate_data.ado`).
These simulated datasets are:

1. `loan_level.dta`: Dataset containing all the variables found in the main tables and IA tables, excluding those for the CEO turnover tests and the facility level test.
2. `turnover.dta`: Dataset containing all the variables for the CEO turnover tests, excluding the test of turnover and covenant violations.
3. `facility_level.dta`: Dataset containing all variables for the facility level test in the IA.
4. `cov_viol.dta`: Dataset containing all the variables for the covenant violation test in the IA.

## Latex
The `paper/` folder contains our Latex code to generate the paper.
The files in the `paper/tables/` subfolder contain tables which were generated by running the `02_make_tables.do` file on the simulated data, for comparison.
The included Stata code automatically generates the .tex output files, which are read in by the main paper files: `akins_de-angelis_gaulin_CMR.tex` and `ia_akins_de-angelis_gaulin_CMR.tex`.
The figures were generated by copying the output from running `code/tables/table_6_ceo_turnover.do` into the excel file `code/turnover_figures.xlsx` and exporting the two figures as PDF into the `paper/figures/` subfolder.



## File Structure
The full file-structure is outlined below:

```
├── code
│   ├── programs
│   │   └──> Folder containing programs for running code
│   ├── tables
│   │   └──> Stata files to run main tables
│   ├── tables_ia
│   │   └──> Stata files to run IA tables
│   ├── 00_global_variables.do
│   ├── 00_label_variables.do
│   ├── 01_load_data.do
│   ├── 01_load_ceo_turnover_data.do
│   ├── 01_load_facility_data.do
│   ├── 01_load_cov_viol_data.do
│   ├── 02_make_tables.do
│   └── turnover_figures.xlsx
├── data
│   ├── cmr_hand_collected_data.xlsx
│   ├── cov_viol.dta
│   ├── facility_level.dta
│   ├── loan_level.dta
│   └── turnover.dta
├── paper
│   ├── akins_de-angelis_gaulin_CMR.pdf
│   ├── akins_de-angelis_gaulin_CMR.tex
│   ├── ia_akins_de-angelis_gaulin_CMR.pdf
│   ├── ia_akins_de-angelis_gaulin_CMR.tex
│   ├── figures
│   │   ├── cmr_end.pdf
│   │   └── cmr_start.pdf
│   ├── resources
│   │   ├── CMR.bib
│   │   ├── commands.tex
│   │   ├── environments.tex
│   │   ├── includes.tex
│   │   ├── jf.bst
│   │   ├── jf.sty
│   │   └── title_abstract_pages.tex
│   └── tables
│       ├── ia
│       │   ├── ia_variable_definitions.tex
│       │   ├── table_ia_1-20.tex
│       ├── table_1-7.tex
│       └── variable_definitions.tex
└── README.md
```