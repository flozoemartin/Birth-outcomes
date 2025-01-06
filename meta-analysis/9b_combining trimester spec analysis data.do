
/*******************************************************************************

	Combine the data and counts from the UK, Norway, and Sweden

	Author: Flo Martin

	Date: 27/11/2023

	Table generated by this script
	
		- $Graphdir\data\trimester specific analyses data_all3.dta
		
*******************************************************************************/

* Start logging

	log using "$Logdir\meta analysis\9b_combining trimester spec data", name(combining_trimester_spec_data) replace
	
********************************************************************************	

* Norway
* Maternal model counts

	import delimited using "$NOTabledir\trimester specific data.txt", varnames(1) clear
	
	replace outcome="sga" if outcome=="sga_pct"
	replace outcome="lga" if outcome=="lga_pct"
	
	save  "$Graphdir\data\no_counts_trimesterspec.dta", replace
	
********************************************************************************		
* Sweden
* Maternal model counts

	import delimited using "$SETabledir\data for figures\trimester spec data se.txt", varnames(1) clear
	
	replace outcome="sga" if outcome=="sga_pct"
	replace outcome="lga" if outcome=="lga_pct"
	
	replace total = subinstr(total, ",", "", .)
	gen total_num=real(total)
	drop total
	rename total_num total
	
	save "$Graphdir\data\se_counts_trimesterspec.dta", replace
	
********************************************************************************

* Combining the summary level data from the three countries

	use "$Graphdir\data\no_counts_trimesterspec.dta", clear
	append using "$Graphdir\data\trimester specific data uk.dta"
	append using "$Graphdir\data\se_counts_trimesterspec.dta"
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_unexp = subinstr(total_unexp, " ", "", .)
	
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	replace total_unexp = subinstr(total_unexp, "/", " / ", .)
	
	replace outcome= "a_stillborn" if outcome=="stillborn"
	replace outcome= "b_neonatal_death" if outcome=="neonatal_death"
	replace outcome= "c_preterm" if outcome=="preterm"
	replace outcome= "d_postterm" if outcome=="postterm"
	replace outcome= "e_sga" if outcome=="sga"
	replace outcome= "f_lga" if outcome=="lga"
	replace outcome= "g_apar5_bin" if outcome=="apgar5_bin"
	
	gen seq=1 if country=="uk"
	replace seq=2 if country=="no"
	replace seq=3 if country=="se"
	
	sort outcome trimester seq
	
	save "$Graphdir\data\trimester specific analyses data_all3.dta", replace
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close combining_trimester_spec_data
	
	translate "$Logdir\meta analysis\9b_combining trimester spec data.smcl" "$Logdir\meta analysis\9b_combining trimester spec data.pdf", replace
	
	erase "$Logdir\meta analysis\9b_combining trimester spec data.smcl"
	
********************************************************************************
