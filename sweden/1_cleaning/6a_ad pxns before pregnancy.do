
********************************************************************************

* Identifying prescriptions that overlap with each period of interest prior to pregnancy in dad

* Author: Flo Martin 

* Date started: 13/11/2023

********************************************************************************

	* Load in the pregnancy dataset

	use "$Datadir\clean_mbr_reduced.dta", clear
	
	* Define periods of interest
	
	gen prepreg_3month_num  = round(start_date-3*30.5)
	gen prepreg_6month_num  = round(start_date-6*30.5)
	gen prepreg_9month_num  = round(start_date-9*30.5)
	gen prepreg_12month_num = round(start_date-12*30.5)
	
	keep father_id deliv_date start_date secondtrim thirdtrim prepreg_*
	
	drop if father_id==.
	
	* Number of pregnancies per dad since 2005
	sort father_id deliv_date
	bysort father_id: egen pregnum_dad=seq()
	tab pregnum_dad // 11 max
	
	tab pregnum_dad // n=11 pregnancies max
	summ pregnum_dad
	local max=`r(max)'
	
	*save "$Deriveddir\preg_cohort_pat.dta", replace
	
	* Merge on to paternal prescription information and define exposure information for each pregnancy a mother has
	
	forvalues x=1/`max' {
		
		use "$Deriveddir\preg_cohort_pat.dta", clear
		
		tab pregnum_dad
		
		bysort deliv_date (father_id): keep if pregnum_dad==`x'
		count
		
		merge 1:m father_id using "$Deriveddir\clean_paternal_antidepressants_pdr.dta", keep(3) nogen
		
		drop if missing(disp_date)==1
		
		* Generate flags for prescriptions in each window
		* Trimesters of pregnancy need special consideration here as second/third trimester start date are often missing where pregnancies terminated early. Pregnancy start and delivery date are never missing	

		* Pre-pregnancy period
		
		gen flagl_prepreg_12_9 		= 1 if (prepreg_12month_num <= disp_date & disp_date < prepreg_9month_num) | (prepreg_12month_num <= prescr_end_date & prescr_end_date < prepreg_9month_num) | (disp_date <= prepreg_12month_num & prepreg_9month_num <= prescr_end_date) 	
	gen flagm_prepreg_9_6  		= 1 if (prepreg_9month_num <= disp_date & disp_date < prepreg_6month_num) | (prepreg_9month_num <= prescr_end_date & prescr_end_date < prepreg_6month_num) | (disp_date <= prepreg_9month_num & prepreg_6month_num <= prescr_end_date) 	
	gen flagn_prepreg_6_3  		= 1 if (prepreg_6month_num <= disp_date & disp_date < prepreg_3month_num) | (prepreg_6month_num <= prescr_end_date & prescr_end_date < prepreg_3month_num) | (disp_date <= prepreg_6month_num & prepreg_3month_num <= prescr_end_date) 	
	gen flago_prepreg_3_0  		= 1 if (prepreg_3month_num <= disp_date & disp_date < start_date) | (prepreg_3month_num <= prescr_end_date & prescr_end_date < start_date) | (disp_date <= prepreg_3month_num & start_date <= prescr_end_date) 
	
		/*gen flagl_prepreg_12_9 		= 1 if (prepreg_12month_num <= disp_date & disp_date < prepreg_9month_num) | (prepreg_12month_num <= prescr_end_date & prescr_end_date < prepreg_9month_num) 	
		gen flagm_prepreg_9_6  		= 1 if (prepreg_9month_num <= disp_date & disp_date < prepreg_6month_num) | (prepreg_9month_num <= prescr_end_date & prescr_end_date < prepreg_6month_num)
		gen flagn_prepreg_6_3  		= 1 if (prepreg_6month_num <= disp_date & disp_date < prepreg_3month_num) | (prepreg_6month_num <= prescr_end_date & prescr_end_date < prepreg_3month_num)
		gen flago_prepreg_3_0  		= 1 if (prepreg_3month_num <= disp_date & disp_date < start_date) | (prepreg_3month_num <= prescr_end_date & prescr_end_date < start_date)*/

		gen anytime_prepreg = 1 if flagl_==1 | flagm_==1 | flagn_==1 | flago_==1
		count if anytime_prepreg == 1
		drop if anytime_prepreg != 1
	
		save "$Tempdatadir\prepregpresc_`x'.dta", replace
		
		foreach y in l m n o { // pregnancy
	
			use "$Tempdatadir\prepregpresc_`x'.dta", clear
	
			keep if flag`y'_== 1 // keep prescriptions in period only
			keep father_id deliv_date disp_date prescr_end_date drugsubstance drugsubstance_num class_pdr
			sort father_id deliv_date disp_date
			count
			
			if _N>0 { // some datasets with no observations
	
				* Keep only the first prescription of each drug at one dose (retaining duplicate pxns of different doses)
				sort father_id disp_date
				duplicates drop father_id drugsubstance, force
		
				* Create index variable for reshaping
				bysort father_id: egen _presseq=seq()
				summ _presseq
				local _presseqmax = r(max)
					
				* Reshape data to one row per person
				reshape wide drugsubstance drugsubstance_num class_pdr disp_date prescr_end_date, i(father_id deliv_date) j(_presseq)
					
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
			
				keep father_id deliv_date
					
			}
					
			* save data for period y of pregnancy x 
			save "$Tempdatadir\prepreg_`x'_period`y'.dta", replace
				
		}
		
	}
	
	forvalues x = 1/`max' {
	
	use "$Deriveddir\preg_cohort_pat.dta", clear
	keep father_id deliv_date pregnum_dad
	bysort deliv_date (father_id): keep if pregnum_dad==`x'
	
		foreach y in l m n o { // pregnancy
	
			merge 1:1 father_id deliv_date using "$Tempdatadir\prepreg_`x'_period`y'.dta", keep(1 3) 
			assert inlist(_merge, 1, 3) // check that only those in the cohort for pregnancy x are being merged
			drop _merge 
		
		}
		
		save "$Tempdatadir\prescr_prepreg_`x'", replace
	
	}
	
	use "$Tempdatadir\prescr_prepreg_1", clear

	forvalues x=2/`max' {
		
		append using "$Tempdatadir\prescr_prepreg_`x'"

	}

	sort father_id deliv_date
	duplicates drop	
	
	* Merge onto full pregnancy cohort to check - all matched
	merge 1:1 father_id pregnum_dad deliv_date using "$Deriveddir\preg_cohort_pat.dta", nogen 

	keep father_id deliv_date pregnum *l *m *n *o
	order father_id deliv_date pregnum *l *m *n *o
	
	count
	
* Browse and check these data

	foreach x in l m n o {
		
		count if drugsubstance_num1`x' !=.
		recode any_`x' .=0
		tab any_`x'
	
	}
	
	gen any_prepreg_pat = 1 if any_l==1 | any_m==1 | any_n==1 | any_o==1 
	replace any_prepreg_pat = 0 if any_prepreg_pat==.
	tab any_prepreg_pat
	
* Save the dataset for patterns analysis

	keep father_id deliv_date pregnum any_o any_n any_m any_l any_prepreg_pat
	
	foreach x in o n m l {
	    
		rename any_`x' any_`x'_pat
		
	}
	
	save "$Tempdatadir\pat_prepregnancy_cohort_patternsinpregnancy.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	forvalues a=1/`max' {
	    
		erase "$Tempdatadir\prescr_prepreg_`a'.dta"
		
	}
	
********************************************************************************