
/*******************************************************************************

	Combine data from each country

	Author: Flo Martin

	Date: 29/11/2023

	Data generated by this script
	
		- drug analyses data uk.txt drug-specific analyses data in UK
		
*******************************************************************************/

* Start logging

	log using "$Logdir\meta analysis\4b_combining drug analysis data", name(combining_drug_analysis_data) replace
	
********************************************************************************	

* Norway

	* Drug counts 

	import delimited "$NOTabledir\drug analyses data no.txt", clear
	
	keep outcome drug or lci uci total*
	
	gen country="no"
	
	save "$Graphdir\data\no_counts_drug.dta", replace

********************************************************************************

* Sweden
* Maternal model counts

	import delimited using "$SETabledir\data for figures\drug analyses data se.txt", varnames(1) clear
	
	replace outcome="sga" if outcome=="sga_pct"
	
	/*rename or total_exp
	rename lci or 
	rename uci lci
	rename risk uci*/
	
	/*replace total = subinstr(total, ",", "", .)
	gen total_num=real(total)
	drop total
	rename total_num total*/
	
	order outcome drug country
	keep outcome drug-uci
	
	save "$Graphdir\data\se_counts_drug.dta", replace
	
********************************************************************************

* Combining the summary level data from the three countries

	import delimited using "$Graphdir\data\drug analyses data uk.txt", varnames(1) clear
	
	keep outcome-uci

	append using "$Graphdir\data\no_counts_drug.dta"
	append using "$Graphdir\data\se_counts_drug.dta"
	
	replace outcome="sga" if outcome=="sga_pct"
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	
	gen seq=1 if country=="uk"
	replace seq=2 if country=="no"
	replace seq=3 if country=="se"
	
	save "$Graphdir\data\drug analyses data_all3.dta", replace
	
********************************************************************************

* Norway

	* Drug counts

	import delimited "$NOTabledir\drug analyses data no.txt", clear
	
	keep outcome drug risk* total* 
	
	gen country="no"
	
	save "$Graphdir\data\no_risk_drug.dta", replace

********************************************************************************

* Sweden
* Maternal model counts

	import delimited using "$SETabledir\data for figures\drug analyses data se.txt", varnames(1) clear
	
	replace outcome="sga" if outcome=="sga_pct"
	
	/*rename or total_exp
	rename lci or 
	rename uci lci
	rename risk uci
	
	replace total = subinstr(total, ",", "", .)
	gen total_num=real(total)
	drop total
	rename total_num total*/
	
	keep outcome drug risk* total* country
	
	save "$Graphdir\data\se_risk_drug.dta", replace
	
********************************************************************************

* Combining the summary level data from the three countries

	import delimited using "$Graphdir\data\drug analyses data uk.txt", varnames(1) clear
	
	keep outcome drug risk* total* country

	append using "$Graphdir\data\no_risk_drug.dta"
	append using "$Graphdir\data\se_risk_drug.dta"
	
	replace outcome="sga" if outcome=="sga_pct"
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	
	gen seq=1 if country=="uk"
	replace seq=2 if country=="no"
	replace seq=3 if country=="se"
	
	save "$Graphdir\data\drug analyses risk data_all3.dta", replace
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close combining_drug_analysis_data
	
	translate "$Logdir\meta analysis\4b_combining drug analysis data.smcl" "$Logdir\meta analysis\4b_combining drug analysis data.pdf", replace
	
	erase "$Logdir\meta analysis\4b_combining drug analysis data.smcl"
	
********************************************************************************
