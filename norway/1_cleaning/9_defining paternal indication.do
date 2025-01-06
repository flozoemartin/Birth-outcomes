********************************************************************************

* Identifying indications in mum

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\9_defining paternal dep anx", name(defining_paternal_dep_anx) replace
	
********************************************************************************	
	
	* Creat binary variables for each patient's pregnancies whether they had a code for depression or anxiety in the periods of interest
	
	* Load in the pregnancy dataset

	use "$Deriveddir\preg_cohort_dad.dta", clear
	
	tab pregnum_dad // n=11 pregnancies max
	summ pregnum_dad
	local max=`r(max)'
	
	foreach indic in depression anxiety {
		
		* Ever
	
		forvalues n=1/`max' {
			
			use "$Deriveddir\preg_cohort_dad.dta", clear
			keep father_id preg_id start_date pregnum_dad
			
			keep if pregnum_dad==`n'
			
			merge 1:m father_id using "$Deriveddir\clean_paternal_indications.dta", keep(3) nogen
			
			keep if `indic'==1
			keep if diag_date<=start_date-365
			
			if _N>0 {
			
				sort father_id diag_date
				by father_id: egen _seq = seq()
				
				gsort + father_id - diag_date
				by father_id: egen count_`indic'_ever = seq()
				label variable count_`indic'_ever "Number of `indic' codes ever before the 12 months prior to pregnancy"

				keep if _seq==1 // keeping first diagnosis only but have created count of total depression codes
				drop _seq
				
				gen `indic'_ever=1
				
				keep father_id preg_id `indic'_ever count_`indic'_ever
				duplicates drop
				
			}
			
			else if _N==0 {	
				
				keep father_id preg_id
				
			}
			
			save "$Tempdatadir\ever_prepreg_`n'.dta", replace
		
		}
		
		use "$Tempdatadir\ever_prepreg_1.dta", clear
		
		forvalues n=2/`max' {
			
			append using "$Tempdatadir\ever_prepreg_`n'.dta"
			
		}
		
		count
		save "$Tempdatadir\ever_prepreg_`indic'.dta", replace
		
		* 12 months pre-pregnancy
		
		forvalues n=1/`max' {
			
			use "$Deriveddir\preg_cohort_dad.dta", clear
			keep father_id preg_id start_date pregnum_dad 
			
			keep if pregnum_dad==`n'
			
			merge 1:m father_id using "$Deriveddir\clean_paternal_indications.dta", keep(3) nogen
			
			keep if `indic'==1
			
			keep if diag_date<start_date & diag_date>=start_date-365
			
			sort father_id diag_date
			by father_id: egen _seq = seq()
			
			if _N>0 {
			
				gsort + father_id - diag_date
				by father_id: egen count_`indic'_12mo = seq()
				label variable count_`indic'_12mo "Number of `indic' codes in the 12 months prior to pregnancy"
				
				keep if _seq==1 // keeping first diagnosis only but have created count of total depression codes
				drop _seq
				
				gen `indic'_12mo=1
				
				keep father_id preg_id `indic'_12mo count_`indic'_12mo
				duplicates drop
				
			}
			
			else if _N==0 {	
				
				keep father_id preg_id
				
			}
			
			save "$Tempdatadir\12mo_prepreg_`n'.dta", replace
		
		}
		
		use "$Tempdatadir\12mo_prepreg_1.dta", clear
		
		forvalues n=2/`max' {
			
			append using "$Tempdatadir\12mo_prepreg_`n'.dta"
			
		}
		
		count
		save "$Tempdatadir\12mo_prepreg_`indic'.dta", replace
		
		* During pregnancy
		
		forvalues n=1/`max' {
			
			use "$Deriveddir\preg_cohort_dad.dta", clear
			keep father_id preg_id start_date pregnum_dad deliv_date
			
			keep if pregnum_dad==`n'
			
			merge 1:m father_id using "$Deriveddir\clean_paternal_indications.dta", keep(3) nogen
			
			keep if `indic'==1
			
			keep if diag_date>=start_date & diag_date<deliv_date
			
			sort father_id diag_date
			by father_id: egen _seq = seq()
			
			if _N>0 {
			
				gsort + father_id - diag_date
				by father_id: egen count_`indic'_preg = seq()
				label variable count_`indic'_preg "Number of `indic' codes during pregnancy"
				
				keep if _seq==1 // keeping first diagnosis only but have created count of total depression codes
				drop _seq
				
				gen `indic'_preg=1
				
				keep father_id preg_id `indic'_preg count_`indic'_preg
				duplicates drop
				
			}
			
			else if _N==0 {	
				
				keep father_id preg_id
				
			}
			
			save "$Tempdatadir\preg_`n'.dta", replace
		
		}
		
		use "$Tempdatadir\preg_1.dta", clear
		
		forvalues n=2/`max' {
			
			append using "$Tempdatadir\preg_`n'.dta"
			
		}
		
		count
		save "$Tempdatadir\preg_`indic'.dta", replace
		
		* Create depression and anxiety dataset
		
		use "$Tempdatadir\ever_prepreg_`indic'.dta", clear
		merge 1:1 father_id preg_id using "$Tempdatadir\12mo_prepreg_`indic'.dta", nogen
		merge 1:1 father_id preg_id using "$Tempdatadir\preg_`indic'.dta", nogen
		
		recode `indic'_ever .=0
		recode `indic'_12mo .=0
		recode `indic'_preg .=0
		
		gen `indic' = 1 if `indic'_ever==1 | `indic'_12mo==1 | `indic'_preg==1
		replace `indic' = 0 if `indic'_ever==0 & `indic'_12mo==0 & `indic'_preg==0
		
		rename `indic' pat_`indic'
		rename `indic'_ever pat_`indic'_ever
		rename `indic'_12mo pat_`indic'_12mo
		rename `indic'_preg pat_`indic'_preg
		
		save "$Deriveddir\paternal_`indic'.dta", replace
		
	}
	
********************************************************************************	

* Erase unnecessary datasets

	foreach indic in depression anxiety {

		erase "$Tempdatadir\12mo_prepreg_`indic'.dta"
		erase "$Tempdatadir\ever_prepreg_`indic'.dta"
		erase "$Tempdatadir\ever_prepreg_`indic'.dta"
		
	}

	forvalues n=1/`max' {
	    
		erase "$Tempdatadir\ever_prepreg_`n'.dta"
		erase "$Tempdatadir\12mo_prepreg_`n'.dta"
		erase "$Tempdatadir\preg_`n'.dta"
		
		
	}
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close defining_paternal_dep_anx
	
	translate "$Logdir\1_cleaning\9_defining paternal dep anx.smcl" "$Logdir\1_cleaning\9_defining paternal dep anx.pdf", replace
	
	erase "$Logdir\1_cleaning\9_defining paternal dep anx.smcl"
	
********************************************************************************
