/*******************************************************************************

	Generate data to include in the figure of prescribing over time for UK

	Author: Flo Martin

	Date: 29/11/2023

	Table generated by this script
	
		- counts.dta prescribing over time in UK
		
	Figures generated by this script
	
		- prescribing_over_time_all3.pdf prescribing over time in each country
		
*******************************************************************************/

* Start logging

	log using "$Logdir\meta analysis\1_prescribing over time", name(prescribing_over_time) replace
	
********************************************************************************

	* UK

	use "$Datadir\primary_analysis_dataset.dta", clear
	
	bysort birth_yr any_preg: egen seq=seq()
	bysort birth_yr any_preg: egen count=max(seq)
	drop seq
	
	bysort birth_yr: egen seq=seq()
	bysort birth_yr: egen denom=max(seq)
	
	keep birth_yr any_preg count denom 
	duplicates drop
	
	gen pct = (count/denom)*100
	
	drop if any_preg==0
	
	* Confidence intervals
	
		gen p = pct/100
		
		gen se = sqrt((p*(1-p))/denom) 
		
		gen lci = (p - (1.96*se))*100
		gen uci = (p + (1.96*se))*100
		
	keep birth_yr pct lci uci
	
	rename pct pct_uk
	rename lci lci_uk
	rename uci uci_uk
	
	save "$Graphdir\data\counts_uk.dta", replace
	
* Merge with the other countries

	use "$Graphdir\data\counts_uk.dta", clear
	merge 1:1 birth_yr using "$Graphdir\data\counts_no.dta", nogen
	
	forvalues x=2005/2008 {
		foreach y in pct_no lci_no uci_no {
		
			replace `y' =. if birth_yr==`x' 
		
		}
	}
	
	merge 1:1 birth_yr using "$SETabledir\data for figures\prescribing over time se.dta", nogen
	
	sort birth_yr

* Create the graph showing the proportion of pregnancies prescribed antidepressants over time 1995 - 2020
	
	gen x=2020
	gen y=0
	
	/* Colors
	
	net install schemepack, from("https://raw.githubusercontent.com/asjadnaqvi/stata-schemepack/main/installation/") replace
	ssc install schemepack
	
	set scheme tab3, perm
	gr_setscheme
	classutil des .__SCHEME
	classutil des .__SCHEME.color
	di "`.__SCHEME.color.p3'" */
	
	* Two-way graph code
	
	tw /// 
	(rarea lci_uk uci_uk birth_yr, color("`.__SCHEME.color.p1'") fintensity(inten30) lcolor("`.__SCHEME.color.p1'%30")) /// uk confidence interval
	(rarea lci_no uci_no birth_yr, color("`.__SCHEME.color.p2'") fintensity(inten30) lcolor("`.__SCHEME.color.p2'%30")) /// norway confidence interval
	(rarea lci_se uci_se birth_yr, color("`.__SCHEME.color.p3'") fintensity(inten30) lcolor("`.__SCHEME.color.p3'%30")) /// sweden confidence interval
	(line pct_uk birth_yr, color("`.__SCHEME.color.p1'")) /// uk line
	(line pct_no birth_yr, color("`.__SCHEME.color.p2'")) /// norway line
	(line pct_se birth_yr, color("`.__SCHEME.color.p3'")), /// sweden line
	legend(order(4 "UK (prescriptions)" 5 "Norway (dispensations)" 6 "Sweden (dispensations)") size(vsmall) col(1) position(3)) /// legend labels
	xtitle("{bf:Year of birth}", size(vsmall) color(black)) xscale(range(1995 2020)) xlabel(1995(5)2020, nogrid labsize(vsmall)) /// x axis
	ytitle("{bf:Proportion of pregnancies (%)}", size(vsmall) color(black)) ylabel(, labsize(vsmall)) /// y axis 
	title("{bf:Antidepressant use during pregnancy between 1996 and 2020 in three countries}", color(black) size(small)) /// title
	subtitle("{bf:UK} from 1996 to 2019, {bf:Norway} from 2009 to 2020, and {bf:Sweden} from 2006 to 2020", size(vsmall)) || /// subtitle
	scatter y x, msymbol(i) yaxis(2) xaxis(2) ylab(, axis(2) notick nolab) xlab(, axis(2) notick nolab) ytitle("", axis(2)) xtitle("", axis(2)) /// box around graph
	plotregion(margin(0 0 1 1)) /// overall
	name(prescribing_over_time_all3, replace)
	
	* Save the graph
	
	cd "$Graphdir"
	graph export prescribing_over_time_all3.pdf, replace 
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close prescribing_over_time
	
	translate "$Logdir\meta analysis\1_prescribing over time.smcl" "$Logdir\meta analysis\1_prescribing over time.pdf", replace
	
	erase "$Logdir\meta analysis\1_prescribing over time.smcl"
	
********************************************************************************
