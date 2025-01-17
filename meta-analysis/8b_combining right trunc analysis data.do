
/*******************************************************************************

	Combine the data and counts from the UK, Norway, and Sweden

	Author: Flo Martin

	Date: 27/11/2023

	Table generated by this script
	
		- $Graphdir\data\family analyses data_all3.dta drug-specific analyses results in Norway
		
*******************************************************************************/

* Start logging

	log using "$Logdir\meta analysis\8b_combining right trunc data", name(combining_right_trunc_data) replace
	
********************************************************************************	
* Norway
* Maternal model counts

	import delimited using "$NOTabledir\right trunc data_no.txt", varnames(1) clear
	
	save "$Graphdir\data\no_counts_righttrunc.dta", replace
	
********************************************************************************	
	
* Sweden
* Maternal model counts

	import delimited using "$SETabledir\data for figures\right trunc data se.txt", varnames(1) clear
	
	replace total = subinstr(total, ",", "", .)
	gen total_num=real(total)
	drop total
	rename total_num total
	
	save "$Graphdir\data\se_counts_righttrunc.dta", replace
	
********************************************************************************

* Combining the summary level data from the three countries

	use "$Graphdir\data\no_counts_righttrunc.dta", clear
	append using "$Graphdir\data\uk_counts_righttrunc.dta"
	append using "$Graphdir\data\se_counts_righttrunc.dta"
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_unexp = subinstr(total_unexp, " ", "", .)
	
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	replace total_unexp = subinstr(total_unexp, "/", " / ", .)
	
	gen seq=1 if country=="uk"
	replace seq=2 if country=="no"
	replace seq=3 if country=="se"
	
	sort outcome seq
	
	save "$Graphdir\data\right trunc analyses data_all3.dta", replace
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close combining_right_trunc_data
	
	translate "$Logdir\meta analysis\8b_combining right trunc data.smcl" "$Logdir\meta analysis\8b_combining right trunc data.pdf", replace
	
	erase "$Logdir\meta analysis\8b_combining right trunc data.smcl"
	
********************************************************************************
