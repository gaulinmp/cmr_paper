/* Like a requirements.txt file, but for Stata. */
net install st0085_2.pkg // esttab
ssc install parmest // for rolling regression collection
ssc install shufflevar
net install lassopack, from("https://raw.githubusercontent.com/statalasso/lassopack/master/lassopack_v12/") replace
net install pdslasso, from("https://raw.githubusercontent.com/statalasso/pdslasso/master/pdslasso_v11/") replace


/* One day, I will write a program to get current do file's path, using:

tempfile results_content

translate @Results `results_content'

file open myfile using `results_content', read
file read myfile line

while r(eof)==0 {
    // Look for "do [.....].do"
    display "`=word("`line'",1)'"
    file read myfile line
}

file close myfile
 */
