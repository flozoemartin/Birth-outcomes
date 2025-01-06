********************************************************************************

* Identifying prescriptions that overlap with each trimester 

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

	* Load in the pregnancy dataset

	use "$Deriveddir\preg_cohort_pat.dta", replace
	
	tab pregnum_dad // n=11 pregnancies max
	summ pregnum_dad
	local max=`r(max)'
	
	* Merge on to prescription information and define exposure information for each pregnancy a mother has
	
	forvalues x=1/`max' {
		
		use "$Deriveddir\preg_cohort_pat.dta", clear
		
		tab pregnum_dad
		
		bysort preg_id (father_id): keep if pregnum_dad==`x'
		count
		
		merge 1:m father_id using "$Deriveddir\clean_paternal_antidepressants.dta", keep(3) nogen
		
		drop if missing(disp_date)==1
		
		* Generate flags for prescriptions in each window
		* Trimesters of pregnancy need special consideration here as second/third trimester start date are often missing where pregnancies terminated early. Pregnancy start and delivery date are never missing	

		* Pregnancy period
	
		gen flaga_preg_firsttrim  	= 1 if ((secondtrim!=. & start_date <= disp_date & disp_date < secondtrim) | (secondtrim!=. & start_date <= prescr_end_date & prescr_end_date < secondtrim)) | ((secondtrim==. & start_date <= disp_date & disp_date < deliv_date) | (secondtrim==. & start_date <= prescr_end_date & prescr_end_date < deliv_date))
		gen flagb_preg_secondtrim 	= 1 if ((secondtrim!=. & thirdtrim!=. & secondtrim <= disp_date & disp_date < thirdtrim) | (secondtrim!=. & thirdtrim!=. & secondtrim <= prescr_end_date & prescr_end_date < thirdtrim)) | ((secondtrim!=. & thirdtrim==. & secondtrim <= disp_date & disp_date < deliv_date) | (secondtrim!=. & thirdtrim==. & secondtrim <= prescr_end_date & prescr_end_date < deliv_date))
		gen flagc_preg_thirdtrim  	= 1 if (thirdtrim!=. & thirdtrim <= disp_date & disp_date < deliv_date) | (thirdtrim!=. & thirdtrim <= prescr_end_date & prescr_end_date < deliv_date)
		
		gen anytime_preg = 1 if flaga_==1 | flagb_==1 | flagc_==1
		count if anytime_preg == 1
		drop if anytime_preg != 1
	
		save "$Tempdatadir\pregpresc_`x'.dta", replace
		
		foreach y in a b c { // pregnancy
	
			use "$Tempdatadir\pregpresc_`x'.dta", clear
	
			keep if flag`y'_== 1 // keep prescriptions in period only
			keep father_id preg_id disp_date prescr_end_date drugsubstance drugsubstance_num class
			sort father_id preg_id disp_date
			count
			
			if _N>0 { // some datasets with no observations
	
				* Keep only the first prescription of each drug at one dose (retaining duplicate pxns of different doses)
				sort father_id disp_date
				duplicates drop father_id drugsubstance_num, force
		
				* Create index variable for reshaping
				bysort father_id: egen _presseq=seq()
				summ _presseq
				local _presseqmax = r(max)
					
				* Reshape data to one row per person
				reshape wide drugsubstance drugsubstance_num class disp_date prescr_end_date, i(father_id preg_id) j(_presseq)
					
				forvalues n = 1/`_presseqmax' {

					rename drugsubstance`n' drugsubstance`n'`y'
					rename drugsubstance_num`n' drugsubstance_num`n'`y'
					rename class`n' class`n'`y'
					rename disp_date`n' disp_date`n'`y'
					rename prescr_end_date`n' prescr_end_date`n'`y'
					
				}
						
				gen any_`y' = 1 if drugsubstance_num1`y'!=.
					
			}
			
			else if _N==0 {	// populate variables even if no data exists 
			
				keep father_id preg_id
					
			}
					
			* save data for period y of pregnancy x 
			save "$Tempdatadir\preg_`x'_period`y'.dta", replace
				
		}
		
	}
	
	forvalues x = 1/`max' {
	
	use "$Deriveddir\preg_cohort_pat.dta", clear
	keep father_id preg_id pregnum_dad
	bysort preg_id (father_id): keep if pregnum_dad==`x'
	
		foreach y in a b c { // pregnancy
	
			merge 1:1 father_id preg_id using "$Tempdatadir\preg_`x'_period`y'.dta", keep(1 3) 
			assert inlist(_merge, 1, 3) // check that only those in the cohort for pregnancy x are being merged
			drop _merge 
		
		}
		
		save "$Tempdatadir\prescr_preg_`x'", replace
	
	}
	
	use "$Tempdatadir\prescr_preg_1", clear

	forvalues x=2/`max' {
		
		append using "$Tempdatadir\prescr_preg_`x'"

	}

	sort father_id preg_id
	duplicates drop	
	
	* Merge onto full pregnancy cohort to check - all matched
	merge 1:1 father_id preg_id using "$Deriveddir\preg_cohort_pat.dta", nogen 

	keep father_id preg_id pregnum_dad *a *b *c
	order father_id preg_id pregnum_dad *a *b *c 
	
	count
	
* Browse and check these data

	foreach x in a b c {
		
		count if drugsubstance_num1`x' !=.
		recode any_`x' .=0
		tab any_`x'
	
	}
	
	gen any_preg_pat = 1 if any_a==1 | any_b==1 | any_c==1
	replace any_preg_pat = 0 if any_preg_pat==.
	tab any_preg_pat
	
	foreach x in a b c {
	    
		rename any_`x' any_`x'_pat
		
	}
	
* Save the dataset for patterns analysis

	save "$Deriveddir\pat_pregnancy_cohort_patternsinpregnancy.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	forvalues a=1/11 {
	    
		erase "$Tempdatadir\prescr_preg_`a'.dta"
		
	}
	
********************************************************************************
