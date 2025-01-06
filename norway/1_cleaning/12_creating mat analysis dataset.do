********************************************************************************

* Creating the maternal analysis dataset

* Author: Flo Martin 

* Date started: 22/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\12_creating_mat_analysis_datset", name(creating_mat_analysis_datset) replace
	
********************************************************************************	

* Load in the MBRN data

	use "$Datadir\clean_mbrn.dta", clear
	
	count				// 906,251 children...
	codebook preg_id	// ... from 906,251 pregnancies
	
	duplicates report preg_id 
	
	tab pregnum
	summ pregnum // max number of pregnancies within the study period is 11
	local max = `r(max)'
	
	* Merge with education data
	merge 1:1 preg_id mother_id using "$Datadir\maternal_edu.dta", keep(3) nogen
	
	* Merge with healthcare utilisation data
	merge 1:1 child_id mother_id using "$Datadir\maternal_healthcare_util.dta", keep(1 3) nogen
	
	replace healthcare_util_12mo = 0 if healthcare_util_12mo==.
	replace healthcare_util_12mo_cat = 0 if healthcare_util_12mo_cat==.
	
	tab healthcare_util_12mo_cat
	
	count // 906,251 singleton pregnancies 
	
	* Merge with the maternal exposure dataset
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_ad_exposure.dta", keep(3) nogen
	
	* Merge with the other prescriptions datasets
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_asm_12mo.dta", keep(1 3) nogen
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_ap_12mo.dta", keep(1 3) nogen
	
	recode asm_12mo .=0
	recode ap_12mo .=0
	
	* Merge with the maternal indication datasets
	
	foreach indic in depression anxiety affective dn ed migraine narco pain stress_incont tt_headache {
	
		merge 1:1 preg_id mother_id using "$Deriveddir\maternal_`indic'.dta", keep(1 3) nogen
		
	}
	
	count
	
	gen any_indication =.
	
	foreach indic in depression anxiety affective dn ed migraine narco pain stress_incont tt_headache {
	    
		replace `indic'_ever = 0 if `indic'_ever==.
		replace `indic'_12mo = 0 if `indic'_12mo==.
		replace `indic'_preg = 0 if `indic'_preg==.
		replace `indic' = 0 if `indic'==.
		tab `indic'
		replace any_indication = 1 if `indic'==1
		
	}
	
	replace any_indication = 0 if any_indication==.
	tab any_indication
	
	count

********************************************************************************	

* COVARIATE DERIVATIONS

********************************************************************************	

* Cox proportional hazards models

	* General start of follow up variable 22 weeks (start of risk period for most of the outcomes)
	
	gen start_fup = 153

	* Follow-up for Cox models - stillbirth
	
	gen end_fup_sb=gest_age_days

	* Follow-up for Cox models - neonatal death
	
	gen age_28days=gest_age_days+28
	gen end_fup_neonatal=age_28days

	* Follow-up for Cox models - preterm delivery
	
	gen gestage_37wks=(7*37)
	gen end_fup_preterm=min(gest_age_days, gestage_37wks)
	
		* Follow-up for Cox models - moderate-to-late preterm delivery
		
		gen gestage_32wks=(7*32)
		gen start_fup_modpreterm=gestage_32wks
		
		gen end_fup_modpreterm=min(gest_age_days, gestage_37wks)
		
		* Follow-up for Cox models - very preterm delivery
		
		gen gestage_28wks=(7*28)
		gen start_fup_verypreterm=gestage_28wks
		
		gen end_fup_verypreterm=min(gest_age_days, gestage_32wks)
		
		* Follow-up for Cox models - extremely preterm delivery
		
		gen end_fup_expreterm=min(gest_age_days, gestage_28wks)
	
	* Follow-up for Cox models - postterm delivery
	
	gen gestage_36plus6wks=(7*37)-1
	gen start_fup_postterm=gestage_36plus6wks
	
	gen end_fup_postterm=gest_age_days
	
	drop gestage*
	
/********************************************************************************	

* EXPOSURE DERIVATIONS
	
	save "$Tempdatadir\pre_dates_new_users.dta", replace

* TIME UPDATED EXPOSURE
 	
* Get data to define time-update exposure status

	forvalues y=1/3 {
		
		* Trimester `y'
		use "$Tempdatadir\pre_dates_new_users.dta", clear
		
		gen tri`y'_new_user = 1 if cf_unexp_incid==`y' // not in the 3 months before pregnancy but in T1
		label variable tri`y'_new_user"Flags new antidepressant use in T`y'"
		
		save "$Tempdatadir\predates_t`y'_new_users.dta", replace
		
	* Get dates of 1st trimester prescription for new users

		bysort mother_id (pregnum): egen seq=seq()
		summ seq // max number of pregnancies within the study period is 14
		local max = `r(max)'
		
		forvalues x=1/`max' {
			
			*duplicates drop patid, force - do I want to do this? Some patients initiate ADs in T1 for multiple pregnancies
			use "$Tempdatadir\predates_t`y'_new_users.dta", clear
			keep if tri`y'_new_user==1
			keep if pregnum==`x'
			merge 1:m mother_id using "$Deriveddir\pregnancy_cohort_patternsinpregnancy.dta", keep(master match) nogen
			
			if _N>0 & `y'==1 {
			
				keep mother_id preg_id start_date any_o any_a disp_date1a cf_unexp_incid
				sort mother_id preg_id disp_date1a
				br
				gen flag_1st_trim_presc=1 if disp_date1a>=start_date & disp_date1a<start_date+91
				keep if flag_1st==1
				bysort preg_id (disp_date1a): keep if _n==1
				codebook preg_id
				rename disp_date1a first_tri_initiation_date
				keep mother_id preg_id flag_1st_trim_presc first_tri_initiation_date
				label var first_tri_initiation_date "Date of antidepressant initiation in 1st trim new users"
				
			}
			
			if _N>0 & `y'==2 {
			
				keep mother_id preg_id start_date any_o any_b disp_date1b cf_unexp_incid
				sort mother_id preg_id disp_date1b
				br
				gen flag_2nd_trim_presc=1 if disp_date1b>=start_date+91 & disp_date1b<start_date+189
				keep if flag_2nd==1
				bysort preg_id (disp_date1b): keep if _n==1
				codebook preg_id
				rename disp_date1b second_tri_initiation_date
				keep mother_id preg_id flag_2nd_trim_presc second_tri_initiation_date
				label var second_tri_initiation_date "Date of antidepressant initiation in 2nd trim new users"
				
			}
			
			if _N>0 & `y'==3 {
			
				keep mother_id preg_id start_date any_o any_c disp_date1c cf_unexp_incid deliv_date
				sort mother_id preg_id disp_date1c
				br
				gen flag_3rd_trim_presc=1 if disp_date1c>=start_date+189 & disp_date1c<deliv_date
				keep if flag_3rd==1
				bysort preg_id (disp_date1c): keep if _n==1
				codebook preg_id
				rename disp_date1c third_tri_initiation_date
				keep mother_id preg_id flag_3rd_trim_presc third_tri_initiation_date
				label var third_tri_initiation_date "Date of antidepressant initiation in 3rd trim new users"
				
			}
			
			else if _N==0 {
				
				keep mother_id preg_id
				
			}
			
			save "$Tempdatadir\dates_t`y'_new_users_`x'.dta", replace

		}
	}
		
	use "$Tempdatadir\dates_t1_new_users_1.dta", clear
	
	forvalues x=2/`max' {
		
		append using "$Tempdatadir\dates_t1_new_users_`x'.dta"
		
	}
	
	forvalues x=1/`max' {
		
		append using "$Tempdatadir\dates_t2_new_users_`x'.dta"
		append using "$Tempdatadir\dates_t3_new_users_`x'.dta"
		
	}
	
	duplicates drop mother_id preg_id, force

	merge 1:1 mother_id preg_id using "$Tempdatadir\pre_dates_new_users.dta", nogen // 3,018 with dates
	
	foreach x in first second third {
	    
		replace `x'_tri_initiation_date = `x'_tri_initiation_date - start_date if `x'_tri_initiation_date!=.
		
	}
	
	* if first trimester initiation date is pregnancy start date, add one day to intiation dates
	replace first_tri_initiation_date=1 if first_tri_initiation_date==0
	
	gen first_preg_initiation = first_tri_initiation_date if first_tri_initiation_date!=.
	replace first_preg_initiation = second_tri_initiation_date if second_tri_initiation_date!=.
	replace first_preg_initiation = third_tri_initiation_date if third_tri_initiation_date!=.*/
	
* Time varying exposure switching on and off

	merge 1:1 mother_id preg_id using "$Deriveddir\time_varying_exposure.dta", keep(1 3) nogen
	sort mother_id preg_id
	
********************************************************************************
	
	* Trimester-specific exposures
	
	* Data management getting everything on the gestational age axis
	gen t1=.
	gen t2=.
	gen t3=.
	
	gen pregstart_num = 0
	gen pregend_num = gest_age_days
	
	* Data check
	count if cycle_1_start==pregend_num-1 // n=1
	count if cycle_1_start==pregend_num-2 // n=5
	
	forvalues x=1/3 {
		
		replace cycle_`x'_end = pregend_num if cycle_`x'_end>=pregend_num & cycle_`x'_end!=.
		
	}
	
	order mother_id preg_id pregstart_num secondtrim thirdtrim pregend_num cycle* t1 t2 t3
	replace secondtrim = secondtrim - start_date
	replace thirdtrim = thirdtrim - start_date
	
	forvalues x=1/3 {
		
		
		replace t1 = 1 if (cycle_`x'_end>=pregstart_num & cycle_`x'_end<secondtrim & cycle_`x'_end!=.) | (cycle_`x'_start>=pregstart_num & cycle_`x'_start<secondtrim & cycle_`x'_start!=.)  & secondtrim!=.
		
		
		replace t2 = 1 if (cycle_`x'_end>=secondtrim & cycle_`x'_end<thirdtrim & cycle_`x'_end!=.) | (cycle_`x'_start>=secondtrim & cycle_`x'_start<thirdtrim & cycle_`x'_start!=.) & secondtrim!=. & thirdtrim!=.
		replace t2 = 1 if (cycle_`x'_start>=pregstart_num & cycle_`x'_start<secondtrim & cycle_`x'_start!=.) & (cycle_`x'_end>=thirdtrim & cycle_`x'_end<=pregend_num & cycle_`x'_end!=.)  & secondtrim!=. & thirdtrim!=.
		
		
		replace t3 = 1 if (cycle_`x'_end>=thirdtrim & cycle_`x'_end<=pregend_num & cycle_`x'_end!=.) | (cycle_`x'_start>=thirdtrim & cycle_`x'_start<=pregend_num & cycle_`x'_start!=.) & thirdtrim!=.
		
		replace t`x' = 0 if t`x'==. 
		
	}

	* Exposure status at 22 weeks'
	
	gen any_22wk =.
	
	forvalues x=1/3 {
	
		replace any_22wk = 1 if cycle_`x'_start<start_fup & cycle_`x'_end<=start_fup 
	
	}
	
	forvalues x=1/3 {
	
		replace any_22wk = 2 if cycle_`x'_start<start_fup & cycle_`x'_end>start_fup & cycle_`x'_start!=. & cycle_`x'_end!=.
	
	}
	
	gen diff1 = cycle_2_start - cycle_1_end
	gen diff2 = cycle_3_start - cycle_2_end
	
	replace any_22wk = 0 if any_22wk==.
	
	tab any_22wk, m
	
	br pregstart_num secondtrim thirdtrim pregend_num cycle* t1 t2 t3 any_22wk
	
	* Cycles from 22 weeks for the Cox models
	
	gen cycle_1_start_cox=. 
	gen cycle_1_end_cox=. 
	gen cycle_2_start_cox=. 
	gen cycle_2_end_cox=. 
	gen cycle_3_start_cox=. 
	gen cycle_3_end_cox=.
	
	* For those with an overlapping prescription with 22 weeks, they are exposed from 22 weeks
	replace cycle_1_start_cox = start_fup if any_22wk==2
	replace cycle_1_end_cox = cycle_1_end if cycle_1_end>start_fup & cycle_1_end!=. & any_22wk==2
	replace cycle_1_end_cox = cycle_2_end if cycle_2_end>start_fup & cycle_1_end_cox==. & any_22wk==2
	
	forvalues x=2/3 {
		
		replace cycle_`x'_start_cox = cycle_`x'_start if any_22wk==2 & cycle_`x'_start!=. & cycle_`x'_start>cycle_1_end_cox
		replace cycle_`x'_end_cox = cycle_`x'_end if cycle_`x'_start_cox!=. & any_22wk==2
		
	}
	
	* For those who discontinued at some point prior to 22 weeks
	replace cycle_1_start_cox = cycle_1_start if cycle_1_start>=start_fup & any_22wk==1 // n=0
	
	replace cycle_1_start_cox = cycle_2_start if cycle_2_start>=start_fup & any_22wk==1
	replace cycle_1_end_cox = cycle_2_end if cycle_1_start_cox!=. & any_22wk==1
	
	replace cycle_1_start_cox = cycle_3_start if cycle_3_start>=start_fup & cycle_1_start_cox==. & any_22wk==1
	replace cycle_1_end_cox = cycle_3_end if cycle_1_start_cox!=. & cycle_1_end_cox==. & any_22wk==1
	
	replace cycle_2_start_cox = cycle_3_start if cycle_3_start>cycle_2_end & cycle_3_start!=. & cycle_1_start_cox!=cycle_3_start & any_22wk==1
	replace cycle_2_end_cox = cycle_3_end if cycle_2_start_cox!=. & any_22wk==1
	
	* For those who were unexposed prior to 22 weeks
	replace cycle_1_start_cox = cycle_1_start if cycle_1_start>=start_fup & any_22wk==0
	replace cycle_1_end_cox = cycle_1_end if cycle_1_start_cox!=. & any_22wk==0
	
	replace cycle_2_start_cox = cycle_2_start if cycle_2_start>=cycle_1_end & cycle_2_start!=. & any_22wk==0 // n=0
	
	* Exposure status at 37 weeks'
	
	gen any_37wk =.
	
	forvalues x=1/3 {
	
		replace any_37wk = 1 if cycle_`x'_start<start_fup_postterm & cycle_`x'_end<=start_fup_postterm 
	
	}
	
	forvalues x=1/3 {
	
		replace any_37wk = 2 if cycle_`x'_start<start_fup_postterm & cycle_`x'_end>start_fup_postterm & cycle_`x'_start!=. & cycle_`x'_end!=.
	
	}
	
	replace any_37wk = 0 if any_37wk==.
	
	* Cycles from 37 weeks for the Cox models 
	
	gen cycle_1_start_postcox =.
	gen cycle_1_end_postcox =.
	
	replace cycle_1_start_postcox = cycle_1_start if cycle_1_start>start_fup_postterm & cycle_1_start!=.
	replace cycle_1_end_postcox = cycle_1_end if cycle_1_start_postcox!=.
	
	* Binary exposure for Cox
	
	rename any_22wk any_22wk_cat
	rename any_37wk any_37wk_cat
	
	* New-users after 37 weeks for the preterm delivery logistic regression
	
	gen flag_37wk_initiators = 1 if cycle_1_start>start_fup_postterm & cycle_1_start!=.
	tab flag_37wk_initiators // should be considered unexposed in the preterm model
	
	* Exposures for the stratified preterm analysis - depending on the model, these flagged will be changed to unexposed, as they're unexposed until the end of the risk window for the outcome to occur
	
	gen date_32wk = (32*7)
	gen flag_32wk_initiators = 1 if cycle_1_start>date_32wk & cycle_1_start!=.
	tab flag_32wk_initiators
	
	gen date_28wk = (28*7)
	gen flag_28wk_initiators = 1 if cycle_1_start>date_28wk & cycle_1_start!=.
	tab flag_28wk_initiators
	
********************************************************************************

* Truncation

	gen trunc_flag =.
	replace trunc_flag = 1 if start_date+(42*7)>23377 // latest start date in my data
	
	br if trunc_flag==1
	
	tab birth_yr if trunc_flag==1 // accounts for about 50% of the births in the year 2020
	
********************************************************************************

* Save dataset for maternal analysis 

	save "$Deriveddir\maternal_analysis_dataset.dta", replace
	
********************************************************************************

/* Erase unnecessary datasets

	forvalues y=1/3 {
		forvalues x=1/`max' {
			
			erase "$Tempdatadir\dates_t`y'_new_users_`x'.dta"
			
		}
	}*/
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close creating_mat_analysis_datset
	
	translate "$Logdir\1_cleaning\12_creating_mat_analysis_datset.smcl" "$Logdir\1_cleaning\12_creating_mat_analysis_datset.pdf", replace
	
	erase "$Logdir\1_cleaning\12_creating_mat_analysis_datset.smcl"
	
********************************************************************************
