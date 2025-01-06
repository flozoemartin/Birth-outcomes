/*******************************************************************************

	Combine data from each country

	Author: Flo Martin

	Date: 29/11/2023

	Data generated by this script
	
		- "spont induc pt analyses data_all3.dta"
		
*******************************************************************************/

* Start logging

	log using "$Logdir\meta analysis\11b_combining induc spont preterm analysis data", name(combining_stratpreterm_analysis_data) replace
	
********************************************************************************

* Norway
* Maternal model counts

	import delimited using "$NOTabledir\spont induc pt data_no.txt", varnames(1) clear
	
	save "$Graphdir\data\no_counts_spontinducpt.dta", replace
	
********************************************************************************		
* Sweden
* Maternal model counts

	import delimited using "$SETabledir\data for figures\spont induc preterm analyses data se.txt", varnames(1) clear
	
	replace total = subinstr(total, ",", "", .)
	gen total_num=real(total)
	drop total
	rename total_num total
	
	save "$Graphdir\data\se_counts_spontinducpt.dta", replace
	
********************************************************************************

* Combining the summary level data from the three countries

	use "$Graphdir\data\no_counts_spontinducpt.dta", clear
	append using "$Graphdir\data\spont induc pt data_uk.dta"
	append using "$Graphdir\data\se_counts_spontinducpt.dta"
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_unexp = subinstr(total_unexp, " ", "", .)
	
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	replace total_unexp = subinstr(total_unexp, "/", " / ", .)
	
	replace outcome= "b_induc_preterm" if outcome=="induc_preterm"
	replace outcome= "a_spont_preterm" if outcome=="spont_preterm"
	
	gen seq=1 if country=="uk"
	replace seq=2 if country=="no"
	replace seq=3 if country=="se"
	
	sort outcome seq
	
	save "$Graphdir\data\spont induc pt analyses data_all3.dta", replace

********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close combining_stratpreterm_analysis_data
	
	translate "$Logdir\meta analysis\11b_combining induc spont preterm analysis data.smcl" "$Logdir\meta analysis\11b_combining induc spont preterm analysis data.pdf", replace
	
	erase "$Logdir\meta analysis\11b_combining induc spont preterm analysis data.smcl"
	
********************************************************************************
