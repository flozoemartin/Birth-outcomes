
********************************************************************************

* Identifying time-varying exposure windows for Cox models

* Author: Flo Martin 

* Date started: 12/10/2023

********************************************************************************

* Start logging

	log using "$Logdir\9_time varying exposure", name(time_varying_exposure) replace
	
********************************************************************************	

	use "$Datadir\clean_mbr_reduced.dta", clear
	
	tab pregnum
	summ pregnum, det
	local max=`r(max)'

	forvalues a=1/`max' {

			use "$Datadir\clean_mbr_reduced.dta", clear
			keep mother_id pregnum start_date deliv_date
		
			keep if pregnum==`a'
			
			merge 1:m mother_id using "$Deriveddir\clean_maternal_antidepressants_pdr.dta", keep(3) nogen keepusing(disp_date prescr_end_date)
			
			keep if (prescr_end_date>=start_date-84 & prescr_end_date<deliv_date) | (disp_date>start_date-84 & disp_date<deliv_date)
			
			/*replace prescr_end_date=prescr_end_date-start_date
			replace disp_date=disp_date-start_date
			replace deliv_date= deliv_date-start_date
			replace start_date=0*/
			
			if _N>0 {
			
				count
				
				sort mother_id disp_date
				
				bysort mother_id: egen seq=seq()
				summ seq
				
				local n=`r(max)'
				disp `n'
				
				reshape wide disp_date prescr_end_date, i(mother_id deliv_date start_date) j(seq)
				order mother_id start_date deliv_date
				
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
					replace cycle_`x'_end = prescr_end_date`x' if prescr_end_date`y'<prescr_end_date`x'
					
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
				
				/*forvalues x=1/10 {
					
					replace cycle_`x'_end =. if cycle_`x'_start==.
					
				}*/
				
			* Drop all the variables that are empty
				
				foreach var of varlist _all {
						
					capture assert mi(`var')
					
					if !_rc {

						drop `var'
					
					}
				}
				
			keep mother_id start_date deliv_date cycle*
		
		}
		
		else if _N==0 {
			
			keep mother_id start_date deliv_date
			
		}
		
		save "$Tempdatadir\time_varying_x_preg`a'.dta", replace
	
	}
		
	use "$Tempdatadir\time_varying_x_preg1.dta", replace
	
	forvalues a=2/`max' {
		
		append using "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
	duplicates report mother_id deliv_date
	count
	
	merge 1:1 mother_id deliv_date using "$Datadir\clean_mbr_reduced.dta", keep(3) keepusing(gest_age_days) nogen
	
	* To get rid of the people who discontinued just before pregnancy
	
	gen start_date_num = 0
	gen deliv_date_num = deliv_date-start_date
	
	forvalues x=1/4 {
		
		gen cycle_`x'_start_num=.
		replace cycle_`x'_start_num=cycle_`x'_start-start_date
		
		gen cycle_`x'_end_num=.
		replace cycle_`x'_end_num=cycle_`x'_end-start_date
		
	}
	
	replace cycle_1_start_num =. if cycle_1_start_num<0 & cycle_1_end_num<0
	replace cycle_1_end_num =. if cycle_1_start_num==.
	
	* And shift back any subsequent cycles if they resumed more than 84 days during pregnancy
	
	forvalues x=1/3 {
		
		local y=`x'+1
		
		replace cycle_`x'_start_num = cycle_`y'_start_num if cycle_`x'_start_num==. & cycle_`y'_start_num!=.
		replace cycle_`x'_end_num = cycle_`y'_end_num if cycle_`x'_end_num==. & cycle_`y'_end_num!=.
		
		replace cycle_`y'_start_num =. if cycle_`y'_start_num==cycle_`x'_start_num 
		replace cycle_`y'_end_num =. if cycle_`y'_end_num==cycle_`x'_end_num
		
	}
	
	replace cycle_1_start_num = 0 if cycle_1_start_num<0 & cycle_1_end_num>0
	
	forvalues x=1/4 {
		
		replace cycle_`x'_end_num = deliv_date_num if cycle_`x'_end_num>deliv_date_num & cycle_`x'_end_num!=.
		
	}
	
	drop cycle_*_start cycle_*_end
	
	forvalues x=1/4 {
		
		rename cycle_`x'_start_num cycle_`x'_start
		rename cycle_`x'_end_num cycle_`x'_end
		
	}
	
	drop if cycle_1_start ==.
	
	save "$Deriveddir\time_varying_exposure.dta", replace
	
********************************************************************************

* Some have fallen out so need to get their cycle dates

	use "$Deriveddir\maternal_analysis_dataset.dta", clear	
	
	merge 1:1 mother_id deliv_date using "$Deriveddir\time_varying_exposure.dta", nogen
	
	tab any_preg_pdr
	count if any_preg_pdr==1 & cycle_1_start==. // 613 who should have a cycle start but don't
	
	keep if any_preg_pdr==1 & cycle_1_start==.
	
	bysort mother_id (deliv_date): egen seq=seq()
	tab seq
	summ seq
	local max=`r(max)'
	
	forvalues a=1/`max' {

		preserve
		
			keep mother_id pregnum start_date deliv_date seq
		
			keep if seq==`a'
			
			merge 1:m mother_id using "$Deriveddir\clean_maternal_antidepressants_pdr.dta", keep(3) nogen keepusing(disp_date prescr_end_date)
			
			keep if (prescr_end_date>=start_date-84 & prescr_end_date<deliv_date) | (disp_date>start_date-84 & disp_date<deliv_date)
			
			/*replace prescr_end_date=prescr_end_date-start_date
			replace disp_date=disp_date-start_date
			replace deliv_date= deliv_date-start_date
			replace start_date=0*/
			
			if _N>0 {
			
				format prescr_end_date %td
				count
				drop seq
				
				sort mother_id disp_date
				
				bysort mother_id: egen seq=seq()
				summ seq
				
				local n=`r(max)'
				disp `n'
				
				reshape wide disp_date prescr_end_date, i(mother_id deliv_date start_date) j(seq)
				order mother_id start_date deliv_date
				
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
					replace cycle_`x'_end = prescr_end_date`x' if prescr_end_date`y'<prescr_end_date`x'
					
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
				
				/*forvalues x=1/10 {
					
					replace cycle_`x'_end =. if cycle_`x'_start==.
					
				}*/
				
			* Drop all the variables that are empty
				
				foreach var of varlist _all {
						
					capture assert mi(`var')
					
					if !_rc {

						drop `var'
					
					}
				}
				
			keep mother_id start_date deliv_date cycle*
		
		}
		
		else if _N==0 {
			
			keep mother_id start_date deliv_date
			
		}
		
		save "$Tempdatadir\time_varying_x_preg`a'.dta", replace
		
	restore
	
	}
	
	use "$Tempdatadir\time_varying_x_preg1.dta", clear
	append using "$Tempdatadir\time_varying_x_preg2.dta"
	
	gen cycle_1_start_actual = cycle_1_start
	gen cycle_1_end_actual =.
	
	forvalues x=1/5 {
		
		replace cycle_1_end_actual = cycle_`x'_end if cycle_`x'_end>start_date & cycle_`x'_end!=.
		
	}

	format *actual %td
	
	keep mother_id start_date deliv_date *actual
	rename cycle_1_start_actual cycle_1_start
	rename cycle_1_end_actual cycle_1_end
	
	* To get rid of the people who discontinued just before pregnancy
	
	gen start_date_num = 0
	gen deliv_date_num = deliv_date-start_date
	
	forvalues x=1/1 {
		
		gen cycle_`x'_start_num=.
		replace cycle_`x'_start_num=cycle_`x'_start-start_date
		
		gen cycle_`x'_end_num=.
		replace cycle_`x'_end_num=cycle_`x'_end-start_date
		
	}
	
	replace cycle_1_start_num =. if cycle_1_start_num<0 & cycle_1_end_num<0
	replace cycle_1_end_num =. if cycle_1_start_num==.
	
	replace cycle_1_start_num = 0 if cycle_1_start_num<0 & cycle_1_end_num>0
	
	forvalues x=1/1 {
		
		replace cycle_`x'_end_num = deliv_date_num if cycle_`x'_end_num>deliv_date_num & cycle_`x'_end_num!=.
		
	}
	
	drop cycle_*_start cycle_*_end
	
	forvalues x=1/1 {
		
		rename cycle_`x'_start_num cycle_`x'_start
		rename cycle_`x'_end_num cycle_`x'_end
		
	}
	
	drop if cycle_1_start ==.
	
	save "$Deriveddir\time_varying_exposure_additional.dta", replace
	
	* These ones had a several long prescriptions so the original alorithm wasn't recognising the end date of a secondary or tertiary prescription as a relevant cycle end date where it's start date had overlappe with the end of the previous prescription
	
********************************************************************************	

* Erase unnecessary datasets

	forvalues a=1/`max' {
	    
		erase "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close time_varying_exposure
	
	translate "$Logdir\9_time varying exposure.smcl" "$Logdir\9_time varying exposure.pdf", replace
	
	erase "$Logdir\9_time varying exposure.smcl"
	
********************************************************************************