********************************************************************************

* Exploring the other data sources

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\3_cleaning other data", name(cleaning_other_data) replace
	
********************************************************************************	

* Load in the maternal healthcare utilisation data

	use "$Datadir\maternal_healthcare_util.dta", clear
	
	drop if child_id==.
	rename preg pregnum
	
	gen healthcare_util_12mo = 0 if reg_prim_care==0
	replace healthcare_util_12mo = 1 if reg_prim_care>0 & reg_prim_care<4
	replace healthcare_util_12mo = 2 if reg_prim_care>3 & reg_prim_care<11
	replace healthcare_util_12mo = 3 if reg_prim_care>10
	
	label define healthcare_util_12mo_lb 0"0" 1"1-3" 2"4-10" 3">10"
	label values healthcare_util_12mo healthcare_util_12mo_lb
	
	tab healthcare_util_12mo
	
	rename healthcare_util_12mo healthcare_util_12mo_cat
	rename reg_prim_care healthcare_util_12mo
	
	keep mother_id pregnum child_id healthcare*
	
	save "$Datadir\maternal_healthcare_util.dta", replace

* Load in the maternal education data

	use "$Datadir\maternal_edu.dta", clear
	
	tab mother_educ, m 
	
	recode mother_educ .=4
	
	label define edu_lb 0"Compulsory or less" 1"Secondary" 2"Post-secondary" 3"Postgradute" 4"Missing - majority immigrants"
	label values mother_educ edu_lb
	label drop edu_lb
	
	save "$Datadir\maternal_edu.dta", replace
	
********************************************************************************	

* Load in the paternal education data

	use "$Datadir\paternal_edu.dta", clear
	
	tab father_edu, m 
	
	recode father_edu .=4
	
	label define edu_lb 0"Compulsory or less" 1"Secondary" 2"Post-secondary" 3"Postgradute" 4"Missing - majority immigrants"
	label values father_edu edu_lb
	label drop edu_lb
	
	save "$Datadir\paternal_edu.dta", replace
	
********************************************************************************

* Create a parental education dataset

	use "$Datadir\maternal_edu.dta", clear
	merge 1:1 preg_id using "$Datadir\paternal_edu.dta", keep(3) nogen
	
	save "$Datadir\parental_edu.dta", replace

********************************************************************************
	
* Load in the paternal characteristic data

	use "$Datadir\paternal_charac.dta", clear
	
		* Nothing to do with this
		
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_other_data
	
	translate "$Logdir\3_cleaning other data.smcl" "$Logdir\3_cleaning other data.pdf", replace
	
	erase "$Logdir\3_cleaning other data.smcl"
	
********************************************************************************
