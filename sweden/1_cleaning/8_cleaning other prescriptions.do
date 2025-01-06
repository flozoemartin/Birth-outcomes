
********************************************************************************

* Identifying other prescriptions that overlap with the periods of interest

* Author: Flo Martin 

* Date started: 11/10/2023

********************************************************************************

* Start logging

	log using "$Logdir\8_cleaning other prescriptions", name(cleaning_other_prescriptions) replace
	
********************************************************************************	
	
	use "$Deriveddir\preg_cohort.dta", clear
	
	tab pregnum // n=11 pregnancies max
	summ pregnum
	local max=`r(max)'
	
	foreach drug in a04 n03 n05a {
		forvalues n=1/`max' {
			
			use "$Deriveddir\preg_cohort.dta", clear
			keep mother_id start_date deliv_date pregnum
			
			keep if pregnum==`n'
			
			merge 1:m mother_id using "$Datadir\exposure\\`drug'_pdr_maternal_compress.dta", keep(3) nogen
			
			sort mother_id disp_date
			
			gen _dist= start_date-disp_date
			keep if _dist<=0 & _dist>-365
			
			sort mother_id disp_date
			by mother_id: egen _seq = seq()
			
			if _N>0 {
			
				gsort + mother_id - disp_date
				by mother_id: egen count_`drug'_12mo = seq()
				label variable count_`drug'_12mo "Number of `drug' dispensations in the 12 months prior to pregnancy"
				
				keep if _seq==1 // keeping first dispensation only but have created count of total dispensations
				drop _seq
				
				gen `drug'_12mo=1
				
				keep mother_id start_date deliv_date `drug'_12mo count_`drug'_12mo
				duplicates drop
				
			}
			
			else if _N==0 {	
				
				keep mother_id start_date deliv_date
				
			}
			
			save "$Tempdatadir\12mo_prepreg_`n'.dta", replace
		
		}
		
		use "$Tempdatadir\12mo_prepreg_1.dta", clear
		
		forvalues n=2/`max' {
			
			append using "$Tempdatadir\12mo_prepreg_`n'.dta"
			
		}
		
		count
		save "$Tempdatadir\12mo_prepreg_`drug'.dta", replace
		
		* Create dispensation dataset

		recode `drug'_12mo .=0
		save "$Deriveddir\maternal_`drug'_12mo.dta", replace
		
	}

********************************************************************************	

* Erase unnecessary datasets

	foreach drug in a04 n03 n05a {
	    
		erase "$Tempdatadir\12mo_prepreg_`drug'.dta"
		
	}
	
	forvalues n=1/`max' {
	    
		erase "$Tempdatadir\12mo_prepreg_`n'.dta"
		
	}

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_other_prescriptions
	
	translate "$Logdir\8_cleaning other prescriptions.smcl" "$Logdir\8_cleaning other prescriptions.pdf", replace
	
	erase "$Logdir\8_cleaning other prescriptions.smcl"
	
********************************************************************************