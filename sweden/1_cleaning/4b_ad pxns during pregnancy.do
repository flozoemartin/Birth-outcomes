
********************************************************************************

* Identifying prescriptions that overlap with each trimester 

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

	* Load in the pregnancy dataset

	use "$Deriveddir\preg_cohort.dta", clear
	
	* Merge on to prescription information and define exposure information for each pregnancy a mother has
	
	tab pregnum // n=11 pregnancies max
	summ pregnum
	local max=`r(max)'
	
	forvalues x=1/`max' {
		
		use "$Deriveddir\preg_cohort.dta", clear
		
		tab pregnum
		
		bysort deliv_date (mother_id): keep if pregnum==`x'
		count
		
		merge 1:m mother_id using "$Deriveddir\clean_maternal_antidepressants_pdr.dta", keep(3) nogen
		
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
			keep mother_id deliv_date disp_date prescr_end_date drugsubstance drugsubstance_num class_pdr
			sort mother_id deliv_date disp_date
			count
			
			if _N>0 { // some datasets with no observations
	
				* Keep only the first prescription of each drug at one dose (retaining duplicate pxns of different doses)
				sort mother_id disp_date
				duplicates drop mother_id drugsubstance_num, force
		
				* Create index variable for reshaping
				bysort mother_id: egen _presseq=seq()
				summ _presseq
				local _presseqmax = r(max)
					
				* Reshape data to one row per person
				reshape wide drugsubstance drugsubstance_num class_pdr disp_date prescr_end_date, i(mother_id deliv_date) j(_presseq)
					
				forvalues n = 1/`_presseqmax' {

					rename drugsubstance`n' drugsubstance`n'`y'
					rename drugsubstance_num`n' drugsubstance_num`n'`y'
					rename class_pdr`n' class_pdr`n'`y'
					rename disp_date`n' disp_date`n'`y'
					rename prescr_end_date`n' prescr_end_date`n'`y'
					
				}
						
				gen any_`y' = 1 if drugsubstance_num1`y'!=.
					
			}
			
			else if _N==0 {	// populate variables even if no data exists 
			
				keep mother_id deliv_date
					
			}
					
			* save data for period y of pregnancy x 
			save "$Tempdatadir\preg_`x'_period`y'.dta", replace
				
		}
		
	}
	
	forvalues x = 1/`max' {
	
	use "$Deriveddir\preg_cohort.dta", clear
	keep mother_id deliv_date pregnum
	bysort deliv_date (mother_id): keep if pregnum==`x'
	
		foreach y in a b c { // pregnancy
	
			merge 1:1 mother_id deliv_date using "$Tempdatadir\preg_`x'_period`y'.dta", keep(1 3) 
			assert inlist(_merge, 1, 3) // check that only those in the cohort for pregnancy x are being merged
			drop _merge 
		
		}
		
		save "$Tempdatadir\prescr_preg_`x'", replace
	
	}
	
	use "$Tempdatadir\prescr_preg_1", clear

	forvalues x=2/`max' {
		
		append using "$Tempdatadir\prescr_preg_`x'"

	}

	sort mother_id deliv_date
	duplicates drop	
	
	* Merge onto full pregnancy cohort to check - all matched
	merge 1:1 mother_id deliv_date using "$Deriveddir\preg_cohort.dta", nogen 

	keep mother_id deliv_date pregnum *a *b *c
	order mother_id deliv_date pregnum *a *b *c 
	
	count
	
* Browse and check these data

	foreach x in a b c {
		
		count if drugsubstance_num1`x' !=.
		recode any_`x' .=0
		tab any_`x'
	
	}
	
	gen any_preg = 1 if any_a==1 | any_b==1 | any_c==1
	replace any_preg = 0 if any_preg==.
	tab any_preg
	
* Save the dataset for patterns analysis

	save "$Deriveddir\pregnancy_cohort_patternsinpregnancy.dta", replace