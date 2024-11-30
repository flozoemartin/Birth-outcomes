********************************************************************************

* Identifying time-varying exposure windows for Cox models and defining periods of exposure

* Author: Flo Martin 

* Date: 08/04/2024

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\2_time varying exposure", name(time_varying_exposure) replace
	
********************************************************************************	

	use "$Datadir\eligible_outcomes.dta", clear
	
	tab pregnum_new
	summ pregnum_new, det
	local max=`r(max)'

	forvalues a=1/`max' {

			use "$Datadir\eligible_outcomes.dta", clear
			keep patid pregid pregnum_new pregstart_num pregend_num
		
			keep if pregnum_new==`a'
			
			merge 1:m patid using "$Deriveddir\derived_data\AD_pxn_events_from_All_Therapy_clean_doses.dta", keep(3) nogen keepusing(presc_startdate_num presc_enddate_num)
			
			sort patid presc_startdate_num
			
			keep if (presc_enddate_num>=pregstart_num-84 & presc_enddate_num<pregend_num) | (presc_startdate_num>pregstart_num-84 & presc_startdate_num<pregend_num)
			
			if _N>0 {
			
				duplicates drop
				
				replace presc_enddate_num=presc_enddate_num-pregstart_num
				replace presc_startdate_num=presc_startdate_num-pregstart_num
				replace pregend_num= pregend_num-pregstart_num
				replace pregstart_num=0
				
				format *num %4.0f
		
				count
				
				sort patid presc_enddate_num
				
				bysort patid: egen seq=seq()
				summ seq
				
				local n=`r(max)'
				disp `n'
				
				reshape wide presc_startdate_num presc_enddate_num, i(patid pregid pregend_num pregstart_num) j(seq)
				order patid pregid pregstart_num pregend_num
				
				local o=`n'+1
				
				gen cycle_1_start =.
				gen presc_startdate_num`o'=.
				gen presc_enddate_num`o'=.
				
				forvalues x=1/`n' {
					
					local y=`x'+1
					
					replace cycle_1_start = 0 if presc_startdate_num`x'<=0 & presc_enddate_num`x'>0
					
					replace cycle_1_start = presc_startdate_num`x' if presc_startdate_num`x'>=-84 & cycle_1_start==. 
					
					replace cycle_1_start = -84 if presc_startdate_num`x'<=-84 & cycle_1_start==.
					
				}
					
				*gen cycle_1_start = presc_startdate_num1 // if presc_startdate_num1>pregstart_num
				*replace cycle_1_start = pregstart_num if presc_startdate_num1<=pregstart_num
				
				forvalues x=1/`o' {
					
					gen cycle_`x'_end =.
					
				}
				
			* The cycle needs to end if: 
			
				* There are no more prescriptions in the pregnancy
				* There is a gap of >84 days between the end of the prescrition and the start of the next one
				
				forvalues x=1/`n' {
					
					local y=(`x')+1
					local z=(`x')+2
					
					replace cycle_`x'_end = presc_enddate_num`x' if presc_startdate_num`y'==. & presc_enddate_num`x'!=. & presc_enddate_num`x'>cycle_1_start
					
					replace cycle_`x'_end = presc_enddate_num`x' if presc_enddate_num`x'+84<presc_startdate_num`y' & presc_startdate_num`y'!=. & presc_enddate_num`x'>cycle_1_start
					
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
				
					replace cycle_`x'_start = presc_startdate_num`x' if presc_startdate_num`x'>(presc_enddate_num`y'+84) & presc_startdate_num`x'!=.
				
				}
				
				forvalues z=1/`n' {
					forvalues x=`n'(-1)`z' {
						
						local y=(`x')+1
						
						replace cycle_`x'_start = cycle_`y'_start if cycle_`x'_start==. & cycle_`y'_start!=.
						replace cycle_`y'_start =. if cycle_`y'_start==cycle_`x'_start
						replace cycle_`z'_start =. if cycle_`z'_end==.
						
					}
				}
				
				forvalues x=`n'(-1)1 {
					foreach y in end start {
				
						order cycle_`x'_`y', after(presc_enddate_num`n')
						
					}
				}
				
			* Drop all the variables that are empty
				
				foreach var of varlist _all {
						
					capture assert mi(`var')
					
					if !_rc {

						drop `var'
					
					}
				}
				
			keep patid pregid cycle*
		
		}
		
		else if _N==0 {
			
			keep patid pregid
			
		}
		
		save "$Tempdatadir\time_varying_x_preg`a'.dta", replace
	
	}
		
	use "$Tempdatadir\time_varying_x_preg1.dta", replace
	
	forvalues a=2/`max' {
		
		append using "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
	duplicates report
	count
	
	merge 1:1 patid pregid using "$Datadir\eligible_outcomes.dta", keep(3) nogen
	
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
	
	drop cycle_4*
	
	replace cycle_1_start = 0 if cycle_1_start<0
	
	save "$Datadir\time_varying_exposure.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	forvalues a=1/`max' {
	    
		erase "$Tempdatadir\time_varying_x_preg`a'.dta"
		
	}
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close time_varying_exposure
	
	translate "$Logdir\1_cleaning\2_time varying exposure.smcl" "$Logdir\1_cleaning\2_time varying exposure.pdf", replace
	
	erase "$Logdir\1_cleaning\2_time varying exposure.smcl"
	
********************************************************************************
