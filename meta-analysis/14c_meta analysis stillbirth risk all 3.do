/*******************************************************************************

	Creating a meta-analysis figure for all three countries for adjusted absolute risk 

	Author: Flo Martin

	Date: 02/12/2023
		
*******************************************************************************/

* Stillbirth 

	import delimited using "$NOTabledir\august 24\primary analysis_mat.txt", clear
	
	egen seq=seq()
	replace outcome = "stillborn" if seq==2
	replace outcome = "neonatal_death" if seq==4
	replace outcome = "preterm" if seq==6
	replace outcome = "postterm" if seq==8
	replace outcome = "sga" if seq==10
	replace outcome = "lga" if seq==12
	replace outcome = "apgar5_bin" if seq==14

	drop seq
	
	rename exposed10 drug
	rename lci risk_lci
	rename uci risk_uci
	
	gen country = "no"
	
	save "$Graphdir\data\exposed unexposed risk_no.dta", replace
	
	import delimited using "$SETabledir\data for figures\august 24\primary analysis_mat.txt", clear
	
	egen seq=seq()
	replace outcome = "stillborn" if seq==2
	replace outcome = "neonatal_death" if seq==4
	replace outcome = "postterm" if seq==6
	replace outcome = "sga" if seq==8
	replace outcome = "lga" if seq==10
	replace outcome = "apgar5_bin" if seq==12
	replace outcome = "preterm" if seq==14

	drop seq
	
	rename exposed10 drug
	rename lci risk_lci
	rename uci risk_uci
	
	gen country = "se"
	
	save "$Graphdir\data\exposed unexposed risk_se.dta", replace
	
	use "$Graphdir\data\drug analyses risk data_all3.dta", clear
	
	drop if drug==0 & country=="uk"
	
	replace drug = drug + 1 if drug>0
	
	append using "$Graphdir\data\exposed unexposed risk_no.dta"
	append using "$Graphdir\data\exposed unexposed risk_se.dta"
	append using "$Graphdir\data\exposed risk_uk.dta"
	
	* Preterm by drug meta-analysis
	
	keep if outcome=="stillborn"
	
	gen logrisk = log(risk)
	gen loglci = log(risk_lci)
	gen loguci = log(risk_uci)
	
	metan logrisk loglci loguci, eform by(drug) lcols(country total_exp) saving(stillborn_risk_ma, replace) 

*******************************************************************************
