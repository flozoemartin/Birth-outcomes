********************************************************************************

* Identifying time-varying exposure windows for Cox models

* Author: Flo Martin 

* Date started: 12/10/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\10_time varying exposure", name(time_varying_exposure) replace
	
********************************************************************************	

	use "$Datadir\clean_mbrn.dta", clear
	
	tab pregnum
	summ pregnum, det
	local max=`r(max)'

	forvalues a=1/`max' {

			use "$Datadir\clean_mbrn.dta", clear
			keep mother_id preg_id pregnum start_date deliv_date
		
			keep if pregnum==`a'
			
			merge 1:m mother_id using "$Deriveddir\clean_maternal_antidepressants.dta", keep(3) nogen keepusing(disp_date prescr_end_date)
			
			keep if (prescr_end_date>=start_date-84 & prescr_end_date<deliv_date) | (disp_date>start_date-84 & disp_date<deliv_date)
			
			replace prescr_end_date=prescr_end_date-start_date
			replace disp_date=disp_date-start_date
			replace deliv_date= deliv_date-start_date
			replace start_date=0
			
			if _N>0 {
			
				count
				
				sort mother_id disp_date
				
				bysort mother_id: egen seq=seq()
				summ seq
				
				local n=`r(max)'
				disp `n'
				
				reshape wide disp_date prescr_end_date, i(mother_id preg_id deliv_date start_date) j(seq)
				order mother_id preg_id start_date deliv_date
				
				local o=`n'+1
					
				gen disp_date`o' =.
				gen prescr_end_date`o' =.
					
				gen cycle_1_start = disp_date1 // if disp_date1>start_date
				*replace cycle_1_start = start_date if disp_date1<=start_date
				
				forvalues x=1/`o' {
					
					gen cycle_`x'_end =.
					
				}
				
			* The cycle needs to end if: 
			
				* There are no more prescriptions in the pregnancy
				* There is a gap of >84 days between the end of the prescrition and the start of the next one
				
				forvalues x=1/`n' {
					
					local y=(`x')+1
					local z=(`x')+2
					
					replace cycle_`x'_end = prescr_end_date`x' if disp_date`y'==. & prescr_end_date`x'!=.
					
					replace cycle_`x'_end = prescr_end_date`x' if prescr_end_date`x'+84<disp_date`y' & disp_date`y'!=.
					
				}
				
				forvalues z=1/`n' {
					forvalues x=`n'(-1)`z' {
						
						local y=(`x')+1
						
						replace cycle_`x'_end = cycle_`y'_end if cycle_`x'_end==. & cycle_`y'_end!=.
						replace cycle_`y'_end =. if cycle_`y'_end==cycle_`x'_end
						
					}
				}
				
			* The next cycle starts if:
			
				* Another prescrition is initiated >84 days after the last cycle ended
				
				forvalues x=2/`o' {
					
					gen cycle_`x'_start =.
					
				}
				
				forvalues x=2/`n' {
					
					local y=(`x')-1
				
					replace cycle_`x'_start = disp_date`x' if disp_date`x'>(prescr_end_date`y'+84) & disp_date`x'!=.
				
				}
				
				forvalues z=1/`n' {
					forvalues x=`n'(-1)`z' {
						
						local y=(`x')+1
						
						replace cycle_`x'_start = cycle_`y'_start if cycle_`x'_start==. & cycle_`y'_start!=.
						replace cycle_`y'_start =. if cycle_`y'_start==cycle_`x'_start
						
					}
				}
				
				forvalues x=`n'(-1)1 {
					foreach y in end start {
				
						order cycle_`x'_`y', after(prescr_end_date`n')
						
					}
				}
				
			* Drop all the variables that are empty
				
				foreach var of varlist _all {
						
					capture assert mi(`var')
					
					if !_rc {

						drop `var'
					
					}
				}
				
			keep mother_id preg_id cycle*
		
		}
		
		else if _N==0 {
			
			keep mother_id preg_id
			
		}
		
		save "$Tempdatadir\time_varying_x_preg`a'.dta", replace
	
	}
		
	use "$Tempdatadir\time_varying_x_preg1.dta", replace
	
	forvalues a=2/`max' {
		
		append using "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
	duplicates report
	count
	
	merge 1:1 mother_id preg_id using "$Datadir\clean_mbrn.dta", keep(3) keepusing(gest_age_days) nogen
	
	* To get rid of the people who discontinued just before pregnancy
	
	replace cycle_1_start =. if cycle_1_start<0 & cycle_1_end<0
	replace cycle_1_end =. if cycle_1_start==.
	
	* And shift back any subsequent cycles if they resumed more than 84 days during pregnancy
	
	forvalues x=1/3 {
		
		local y=`x'+1
		
		replace cycle_`x'_start = cycle_`y'_start if cycle_`x'_start==. & cycle_`y'_start!=.
		replace cycle_`x'_end = cycle_`y'_end if cycle_`x'_end==. & cycle_`y'_end!=.
		
		replace cycle_`y'_start =. if cycle_`y'_start==cycle_`x'_start 
		replace cycle_`y'_end =. if cycle_`y'_end==cycle_`x'_end
		
	}
	
	replace cycle_1_start = 0 if cycle_1_start<0 & cycle_1_end>0
	
	drop cycle_4*
	
	save "$Deriveddir\time_varying_exposure.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	forvalues a=1/`max' {
	    
		erase "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close time_varying_exposure
	
	translate "$Logdir\1_cleaning\10_time varying exposure.smcl" "$Logdir\1_cleaning\10_time varying exposure.pdf", replace
	
	erase "$Logdir\1_cleaning\10_time varying exposure.smcl"
	
********************************************************************************
