
********************************************************************************

* Creating the maternal analysis dataset

* Author: Flo Martin 

* Date started: 22/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\2_analysis\1_creating_mat_analysis_datset", name(creating_mat_analysis_datset) replace
	
********************************************************************************	

* Load in the MBRN data

	use "$Datadir\clean_mbr_full.dta", clear
	
	count				// 2,615,676 babies
	
	tab pregnum
	summ pregnum // max number of pregnancies within the study period is 15
	local max = `r(max)'
	
	* Merge with education data
	*merge 1:1 preg_id mother_id using "$Datadir\maternal_edu.dta", keep(3) nogen
	
	* Merge with healthcare utilisation data
	/*merge 1:1 child_id mother_id using "$Datadir\maternal_healthcare_util.dta", keep(1 3) nogen
	
	replace healthcare_util_12mo = 0 if healthcare_util_12mo==.
	replace healthcare_util_12mo_cat = 0 if healthcare_util_12mo_cat==.
	
	tab healthcare_util_12mo_cat*/
	
	count // 906,251 singleton pregnancies
	
	* Merge with the maternal exposure dataset
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_ad_exposure.dta", keep(3) nogen
	
	* Merge with the other prescriptions datasets
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_n05a_12mo.dta", keep(1 3) nogen
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_n03_12mo.dta", keep(1 3) nogen
	
	recode n03_12mo .=0
	tab n03_12mo
	label variable n03_12mo"Anti-seizure medication use in the 12 months before pregnancy"
	
	recode n05a_12mo .=0
	tab n05a_12mo
	label variable n05a_12mo"Antipsychotic use in the 12 months before pregnancy"
	
	* Merge with the maternal indication datasets
	
	foreach indic in depression anxiety bipolar ed migraine incont headache {
	
		merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_`indic'.dta", keep(1 3) nogen
		
	}
	
	count
	
	gen any_indication =.
	
	foreach indic in depression anxiety bipolar ed migraine incont headache {
	    
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
	
* Covariates

	* Birth year
	tab birth_yr_cat
	
	* Maternal age
	tab mother_age_cat
	
	* Maternal educational attainment
	tab mother_educ
	
	* Maternal disposable income
	tab dispink_atbirth5gr_bm
	
	* Maternal birth country
	tab mother_birth_country_nonsverige
	
	* Maternal BMI
	tab mother_bmi_cat
	
	* Maternal smoking
	tab smoke_beg
	
	gen smoke_preg = 0 if smoke_beg==0 | smoke_end==0
	replace smoke_preg = 1 if smoke_beg==1 | smoke_beg==2
	replace smoke_preg = 1 if smoke_end==1 | smoke_end==2
	
	* Maternal addiction
	tab addicted_bm

	* Previous stillbirth
	tab stillborn
	
	/*preserve
	
		sort mother_id deliv_date
		keep mother_id stillborn pregnum
		
		summ pregnum
		local max=`r(max)'
		
		reshape wide stillborn, i(mother_id) j(pregnum)
		
		forvalues x=1/`max' {
			
			gen prev_sb_bin`x' =.
			
		}
		
		forvalues x=2/`max' {
			
			local y=`x'-1
			
			replace prev_sb_bin`x' = 1 if stillborn`y'==1 & stillborn`x'!=.
			
		}
		
		forvalues x=2/`max' {
			
			local y=`x'-1
			
			replace prev_sb_bin`x' = 1 if prev_sb_bin`y'==1 & stillborn`x'!=.
			
		}
		
		reshape long stillborn prev_sb_bin, i(mother_id) j(pregnum)
		
		drop if stillborn==.
		
		keep mother_id pregnum prev_sb_bin
		
		replace prev_sb_bin = 0 if prev_sb_bin ==.
		
		save "$Datadir\covariates\previous stillbirth.dta", replace
		
	restore*/
	
	merge 1:1 mother_id pregnum using "$Datadir\covariates\previous stillbirth.dta", keep(1 3) nogen
	
	recode prev_sb_bin .=0
	
	* Maternal parity
	tab parity
	rename parity parity_num
	
	gen parity = 0 if parity_num==1
	replace parity = 1 if parity_num==2
	replace parity = 2 if parity_num==3
	replace parity = 3 if parity_num==4
	replace parity = 4 if parity_num>5 & parity_num!=.
	
	label define parity_lb 4"4+"
	label values parity parity_lb
	tab parity
	
	* Maternal indications
	tab depression
	tab anxiety
	tab ed
	
	* Other indications
	tab bipolar
	tab migraine
	tab incont
	tab headache
	
	* Prescriptions pre-pregnancy
	rename n05a_12mo ap_12mo
	tab ap_12mo
	
	rename n03_12mo asm_12mo
	tab asm_12mo
	
	* Initiation of labour
	tab spont_labour
	
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
	
********************************************************************************

* EXPOSURE DERIVATIONS

	gen t1 = 1 if any_a==1
	replace t1 = 0 if any_a==0
	
	gen t2 = 1 if any_b==1
	replace t2 = 0 if any_b==0
	
	gen t3 = 1 if any_c==1
	replace t3 = 0 if any_c==0
	
	save "$Tempdatadir\pre_dates_new_users.dta", replace

/* TIME UPDATED EXPOSURE
 	
* Get data to define time-update exposure status

	*forvalues y=1/3 {
		
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
			
				keep mother_id start_date deliv_date any_o any_a disp_date1a cf_unexp_incid
				sort mother_id deliv_date disp_date1a
				br
				gen flag_1st_trim_presc=1 if disp_date1a>=start_date & disp_date1a<start_date+91
				keep if flag_1st==1
				bysort mother_id deliv_date (disp_date1a): keep if _n==1
				codebook mother_id 
				rename disp_date1a first_tri_initiation_date
				keep mother_id deliv_date flag_1st_trim_presc first_tri_initiation_date
				label var first_tri_initiation_date "Date of antidepressant initiation in 1st trim new users"
				
			}
			
			if _N>0 & `y'==2 {
			
				keep mother_id start_date deliv_date any_o any_b disp_date1b cf_unexp_incid
				sort mother_id deliv_date disp_date1b
				br
				gen flag_2nd_trim_presc=1 if disp_date1b>=start_date+91 & disp_date1b<start_date+189
				keep if flag_2nd==1
				bysort mother_id deliv_date (disp_date1b): keep if _n==1
				codebook mother_id
				rename disp_date1b second_tri_initiation_date
				keep mother_id deliv_date flag_2nd_trim_presc second_tri_initiation_date
				label var second_tri_initiation_date "Date of antidepressant initiation in 2nd trim new users"
				
			}
			
			if _N>0 & `y'==3 {
			
				keep mother_id start_date deliv_date any_o any_c disp_date1c cf_unexp_incid deliv_date
				sort mother_id deliv_date disp_date1c
				br
				gen flag_3rd_trim_presc=1 if disp_date1c>=start_date+189 & disp_date1c<deliv_date
				keep if flag_3rd==1
				bysort mother_id deliv_date (disp_date1c): keep if _n==1
				codebook deliv_date
				rename disp_date1c third_tri_initiation_date
				keep mother_id deliv_date flag_3rd_trim_presc third_tri_initiation_date
				label var third_tri_initiation_date "Date of antidepressant initiation in 3rd trim new users"
				
			}
			
			else if _N==0 {
				
				keep mother_id deliv_date
				
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
	
	duplicates drop mother_id deliv_date, force

	merge 1:1 mother_id deliv_date using "$Tempdatadir\pre_dates_new_users.dta", nogen // 12,992 with dates
	
	foreach x in first second third {
	    
		replace `x'_tri_initiation_date = `x'_tri_initiation_date - start_date if `x'_tri_initiation_date!=.
		
	}
	
	* if first trimester initiation date is pregnancy start date, add one day to intiation dates
	replace first_tri_initiation_date=1 if first_tri_initiation_date==0
	
	gen first_preg_initiation = first_tri_initiation_date if first_tri_initiation_date!=.
	replace first_preg_initiation = second_tri_initiation_date if second_tri_initiation_date!=.
	replace first_preg_initiation = third_tri_initiation_date if third_tri_initiation_date!=.
	
	gen start_date_num = 0
	gen deliv_date_num = gest_age_days
	
	* New-users after 37 weeks for the preterm delivery logistic regression
	
	gen flag_37wk_initiators = 1 if third_tri_initiation_date>start_fup_postterm & third_tri_initiation_date!=.
	tab flag_37wk_initiators // should be considered unexposed in the preterm model
	
	* Exposures for the stratified preterm analysis - depending on the model, these flagged will be changed to unexposed, as they're unexposed until the end of the risk window for the outcome to occur
	
	gen date_32wk = (32*7)
	gen flag_32wk_initiators = 1 if third_tri_initiation_date>date_32wk & third_tri_initiation_date!=.
	tab flag_32wk_initiators
	
	gen date_28wk = (28*7)
	gen flag_28wk_initiators = 1 if third_tri_initiation_date>date_28wk & third_tri_initiation_date!=.
	tab flag_28wk_initiators
	
	gen start_fup = 153*/
	
	*merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_analysis_dataset.dta",  nogen
	
	forvalues x=1/3 {
		
		rename t`x' t`x'_old
		
	}
	
* Time varying exposure switching on and off

	merge 1:1 mother_id deliv_date using "$Deriveddir\time_varying_exposure.dta", keep(1 3) nogen
	merge 1:1 mother_id deliv_date using "$Deriveddir\time_varying_exposure_additional.dta", update replace keep(1 4) nogen
	
		* n=10 have cycle dates that don't have exposures from the prescription cleaning phase - change to missing
	
	foreach x in start end {
	
		replace cycle_1_`x' =. if cycle_1_`x' !=. & any_preg_pdr ==0
		
	}
	
	sort mother_id deliv_date
	
********************************************************************************
	
	* Trimester-specific exposures
	
	* Data management getting everything on the gestational age axis
	gen t1=.
	gen t2=.
	gen t3=.
	
	gen pregstart_num = 0
	gen pregend_num = gest_age_days
	
	* Data check
	count if cycle_1_start==pregend_num-1 // n=22
	count if cycle_1_start==pregend_num-2 // n=16
	
	forvalues x=1/4 {
		
		replace cycle_`x'_end = pregend_num if cycle_`x'_end>=pregend_num & cycle_`x'_end!=.
		
	}
	
	order mother_id deliv_date pregstart_num secondtrim thirdtrim pregend_num cycle* t1 t2 t3
	replace secondtrim = secondtrim - start_date
	replace thirdtrim = thirdtrim - start_date
	
	forvalues x=1/4 {
		
		
		replace t1 = 1 if (cycle_`x'_end>=pregstart_num & cycle_`x'_end<secondtrim & cycle_`x'_end!=.) | (cycle_`x'_start>=pregstart_num & cycle_`x'_start<secondtrim & cycle_`x'_start!=.)  & secondtrim!=.
		
		
		replace t2 = 1 if (cycle_`x'_end>=secondtrim & cycle_`x'_end<thirdtrim & cycle_`x'_end!=.) | (cycle_`x'_start>=secondtrim & cycle_`x'_start<thirdtrim & cycle_`x'_start!=.) & secondtrim!=. & thirdtrim!=.
		replace t2 = 1 if (cycle_`x'_start>=pregstart_num & cycle_`x'_start<secondtrim & cycle_`x'_start!=.) & (cycle_`x'_end>=thirdtrim & cycle_`x'_end<=pregend_num & cycle_`x'_end!=.)  & secondtrim!=. & thirdtrim!=.
		
		
		replace t3 = 1 if (cycle_`x'_end>=thirdtrim & cycle_`x'_end<=pregend_num & cycle_`x'_end!=.) | (cycle_`x'_start>=thirdtrim & cycle_`x'_start<=pregend_num & cycle_`x'_start!=.) & thirdtrim!=.
		
	}
	
	replace t1 = 0 if t1==. 
	replace t2 = 0 if t2==. 
	replace t3 = 0 if t3==. 

	* Exposure status at 22 weeks'
	
	gen any_22wk =.
	
	forvalues x=1/4 {
	
		replace any_22wk = 1 if cycle_`x'_start<start_fup & cycle_`x'_end<=start_fup 
	
	}
	
	forvalues x=1/4 {
	
		replace any_22wk = 2 if cycle_`x'_start<start_fup & cycle_`x'_end>start_fup & cycle_`x'_start!=. & cycle_`x'_end!=.
	
	}
	
	gen diff1 = cycle_2_start - cycle_1_end
	gen diff2 = cycle_3_start - cycle_2_end
	gen diff3 = cycle_4_start - cycle_3_end
	
	replace any_22wk = 0 if any_22wk==.
	
	tab any_22wk, m
	
	br pregstart_num secondtrim thirdtrim pregend_num cycle* t1 t2 t3 any_22wk
	
	* Cycles from 22 weeks for the Cox models
	
	forvalues x=1/4 {
	
		gen cycle_`x'_start_cox=. 
		gen cycle_`x'_end_cox=. 

	}
	
	* For those with an overlapping prescription with 22 weeks, they are exposed from 22 weeks
	replace cycle_1_start_cox = start_fup if any_22wk==2
	replace cycle_1_end_cox = cycle_1_end if cycle_1_end>start_fup & cycle_1_end!=. & any_22wk==2
	replace cycle_1_end_cox = cycle_2_end if cycle_2_end>start_fup & cycle_1_end_cox==. & any_22wk==2
	
	forvalues x=2/4 {
		
		replace cycle_`x'_start_cox = cycle_`x'_start if any_22wk==2 & cycle_`x'_start!=. & cycle_`x'_start>cycle_1_end_cox
		replace cycle_`x'_end_cox = cycle_`x'_end if cycle_`x'_start_cox!=. & any_22wk==2
		
	}
	
	* For those who discontinued at some point prior to 22 weeks
	replace cycle_1_start_cox = cycle_1_start if cycle_1_start>=start_fup & any_22wk==1 // n=0
	
	forvalues x=2/4 {
		
		replace cycle_1_start_cox = cycle_`x'_start if cycle_`x'_start>=start_fup & cycle_1_start_cox==. & cycle_`x'_start!=. & any_22wk==1
		replace cycle_1_end_cox = cycle_`x'_end if cycle_`x'_start_cox!=. & any_22wk==1
		
	}
	
	forvalues x=3/4 {
	
		replace cycle_2_start_cox = cycle_`x'_start if cycle_`x'_start>cycle_2_end & cycle_`x'_start!=. & cycle_1_start_cox!=cycle_`x'_start & any_22wk==1
		replace cycle_2_end_cox = cycle_`x'_end if cycle_2_start_cox!=. & any_22wk==1
	
	}
	
	* For those who were unexposed prior to 22 weeks
	replace cycle_1_start_cox = cycle_1_start if cycle_1_start>=start_fup & any_22wk==0
	replace cycle_1_end_cox = cycle_1_end if cycle_1_start_cox!=. & any_22wk==0
	
	replace cycle_2_start_cox = cycle_2_start if cycle_2_start>=cycle_1_end & cycle_2_start!=. & any_22wk==0 // n=2
	
	* Exposure status at 37 weeks'
	
	gen any_37wk =.
	
	forvalues x=1/4 {
	
		replace any_37wk = 1 if cycle_`x'_start<start_fup_postterm & cycle_`x'_end<=start_fup_postterm 
	
	}
	
	forvalues x=1/4 {
	
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
	
	gen flag_37wk_initiators_cycle = 1 if cycle_1_start>start_fup_postterm & cycle_1_start!=.
	tab flag_37wk_initiators_cycle // should be considered unexposed in the preterm model
	
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
	replace trunc_flag = 1 if start_date+(42*7)>22116 // latest start date in my data
	
	br if trunc_flag==1
	
	tab birth_yr
	tab birth_yr if trunc_flag==1 // accounts for about 50% of the births in the year 2020
	
********************************************************************************

* Data management 

	order mother_id father_id child_id start_date deliv_date
	sort mother_id start_date

* Save dataset for maternal analysis 

	save "$Deriveddir\maternal_analysis_dataset.dta", replace
	
	keep mother_id father_id child_id start_date deliv_date start_date_num deliv_date_num ///
	stillborn neonatal_death *preterm* postterm* sga* lga* apgar5_bin gest_age* birth_weight bweight* ///
	birth_yr* mother_age_cat mother_educ parity smoke_preg ap_12mo asm_12mo depression anxiety dispink5atbirth ed bipolar migraine incont headache mother_birth_country_nonsverige mother_bmi_cat prev_sb_bin spont_labour induction ///
	any* *flag* any_o any_a any_b any_c t1 t2 t3 drug_preg *fup* cycle*
	
	save "$Deriveddir\maternal_analysis_dataset_reduced.dta", replace
	
********************************************************************************

/* Erase unnecessary datasets

	forvalues y=1/3 {
		forvalues x=1/`max' {
			
			erase "$Tempdatadir\dates_t`y'_new_users_`x'.dta"
			
		}
	}*/
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close creating_mat_analysis_datset
	
	translate "$Logdir\2_analysis\1_creating_mat_analysis_datset.smcl" "$Logdir\2_analysis\1_creating_mat_analysis_datset.pdf", replace
	
	erase "$Logdir\2_analysis\1_creating_mat_analysis_datset.smcl"
	
********************************************************************************