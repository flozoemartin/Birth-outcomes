********************************************************************************

* Creating the paternal analysis dataset

* Author: Flo Martin 

* Date started: 26/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\13_creating_pat_analysis_datset", name(creating_pat_analysis_datset) replace
	
********************************************************************************	

* Load in the child data

	use "$Datadir\clean_mbrn.dta", clear
	
	count				// 906,251 children...
	codebook preg_id	// ... from 906,251 pregnancies

	duplicates report preg_id 
	
	* Drop pregnancies without a father ID
	drop if father_id==. // 17,951 without a father ID
	
	count // 888,300 singleton babies with linked dads for the negative control analysis
	
	* Merge with education data
	merge 1:1 preg_id using "$Datadir\parental_edu.dta", keep(3) nogen
	
	count // 888,044 singleton pregnancies 
	
	* Merge with healthcare utilisation data
	merge 1:1 child_id mother_id using "$Datadir\maternal_healthcare_util.dta", keep(1 3) nogen
	
	replace healthcare_util_12mo = 0 if healthcare_util_12mo==.
	replace healthcare_util_12mo_cat = 0 if healthcare_util_12mo_cat==.
	
	tab healthcare_util_12mo_cat
	
	* Merge with the other prescriptions datasets
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_asm_12mo.dta", keep(1 3) nogen
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_ap_12mo.dta", keep(1 3) nogen
	
	recode asm_12mo .=0
	recode ap_12mo .=0
	
	* Merge with the paternal exposure dataset
	merge 1:1 preg_id mother_id using "$Deriveddir\paternal_ad_exposure.dta", keep(3) nogen
	
	* Merge with the maternal exposure dataset
	merge 1:1 preg_id mother_id using "$Deriveddir\maternal_ad_exposure.dta", keep(3) nogen
	
	rename any_prepreg any_prepreg_mat
	rename any_preg any_preg_mat

	foreach x in l m n o a b c {
	
		rename any_`x' any_`x'_mat
	
	}
	
	rename drug_preg drug_preg_mat
	
	* Merge with the maternal indication dataset
	merge 1:1 preg_id father_id using "$Deriveddir\paternal_depression.dta", keep(1 3) nogen
	merge 1:1 preg_id father_id using "$Deriveddir\paternal_anxiety.dta", keep(1 3) nogen
	
	foreach indic in depression anxiety {
		
		recode pat_`indic'_ever .=0
		recode pat_`indic'_12mo .=0
		recode pat_`indic'_preg .=0
		recode pat_`indic' .=0
		
	}
	
	* Merge with the maternal indication datasets
	
	foreach indic in depression anxiety affective dn ed migraine narco pain stress_incont tt_headache {
	
		merge 1:1 preg_id mother_id using "$Deriveddir\maternal_`indic'.dta", keep(1 3) nogen
		
		rename `indic' mat_`indic'
		replace mat_`indic' = 0 if mat_`indic'==.
		tab mat_`indic'
		
		replace `indic'_ever = 0 if `indic'_ever==.
		replace `indic'_12mo = 0 if `indic'_12mo==.
		replace `indic'_preg = 0 if `indic'_preg==.
		
	}
	
	count // 888,300
	
	save "$Tempdatadir\pre_dates_new_users.dta", replace
	
********************************************************************************

* TIME UPDATED EXPOSURE
 	
* Get data to define time-update exposure status

	forvalues y=1/3 {
		
		* Trimester `y'
		use "$Tempdatadir\pre_dates_new_users.dta", clear
		
		* Number of pregnancies per dad since 2005
		sort father_id preg_id
		bysort father_id: egen pregnum_dad=seq()
		tab pregnum_dad // 11 max
		
		gen tri`y'_new_user = 1 if cf_unexp_incid_pat==`y' // not in the 3 months before pregnancy but in T1
		label variable tri`y'_new_user"Flags new antidepressant use in T`y'"
		
		save "$Tempdatadir\predates_t`y'_new_users.dta", replace
		
	* Get dates of 1st trimester prescription for new users

		bysort father_id (pregnum_dad): egen seq=seq()
		summ seq // max number of pregnancies within the study period is 14
		local max = `r(max)'
		
		forvalues x=1/`max' {
			
			*duplicates drop patid, force - do I want to do this? Some patients initiate ADs in T1 for multiple pregnancies
			use "$Tempdatadir\predates_t`y'_new_users.dta", clear
			keep if tri`y'_new_user==1
			keep if pregnum_dad==`x'
			merge 1:m father_id using "$Deriveddir\pat_pregnancy_cohort_patternsinpregnancy.dta", keep(master match) nogen
			
			if _N>0 & `y'==1 {
			
				keep father_id preg_id start_date any_o_pat any_a_pat disp_date1a cf_unexp_incid_pat
				sort father_id preg_id disp_date1a
				br
				gen flag_1st_trim_presc_pat=1 if disp_date1a>=start_date & disp_date1a<start_date+91
				keep if flag_1st==1
				bysort preg_id (disp_date1a): keep if _n==1
				codebook preg_id
				rename disp_date1a first_tri_initiation_date_pat
				keep father_id preg_id flag_1st_trim_presc_pat first_tri_initiation_date_pat
				label var first_tri_initiation_date_pat "Date of antidepressant initiation in 1st trim new paternal users"
				
			}
			
			if _N>0 & `y'==2 {
			
				keep father_id preg_id start_date any_o_pat any_b_pat disp_date1b cf_unexp_incid_pat
				sort father_id preg_id disp_date1b
				br
				gen flag_2nd_trim_presc_pat=1 if disp_date1b>=start_date+91 & disp_date1b<start_date+189
				keep if flag_2nd==1
				bysort preg_id (disp_date1b): keep if _n==1
				codebook preg_id
				rename disp_date1b second_tri_initiation_date_pat
				keep father_id preg_id flag_2nd_trim_presc_pat second_tri_initiation_date_pat
				label var second_tri_initiation_date_pat "Date of antidepressant initiation in 2nd trim new paternal users"
				
			}
			
			if _N>0 & `y'==3 {
			
				keep father_id preg_id start_date any_o_pat any_c_pat disp_date1c cf_unexp_incid_pat deliv_date
				sort father_id preg_id disp_date1c
				br
				gen flag_3rd_trim_presc_pat=1 if disp_date1c>=start_date+189 & disp_date1c<deliv_date
				keep if flag_3rd==1
				bysort preg_id (disp_date1c): keep if _n==1
				codebook preg_id
				rename disp_date1c third_tri_initiation_date_pat
				keep father_id preg_id flag_3rd_trim_presc_pat third_tri_initiation_date_pat
				label var third_tri_initiation_date_pat "Date of antidepressant initiation in 3rd trim new paternal users"
				
			}
			
			else if _N==0 {
				
				keep father_id preg_id
				
			}
			
			save "$Tempdatadir\dates_t`y'_new_users_`x'.dta", replace

		}
	}
		
	use "$Tempdatadir\dates_t1_new_users_1.dta"
	
	forvalues x=2/`max' {
		
		append using "$Tempdatadir\dates_t1_new_users_`x'.dta"
		
	}
	
	forvalues x=1/`max' {
		
		append using "$Tempdatadir\dates_t2_new_users_`x'.dta"
		append using "$Tempdatadir\dates_t3_new_users_`x'.dta"
		
	}
	
	duplicates drop father_id preg_id, force

	merge 1:1 father_id preg_id using "$Tempdatadir\pre_dates_new_users.dta", nogen // 9,339 with dates
	
	* New-users after 37 weeks for the preterm delivery logistic regression
	
	gen date_37wk = start_date + (37*7)
	gen flag_37wk_initiators = 1 if third_tri_initiation_date_pat>date_37wk & third_tri_initiation_date_pat!=.
	tab flag_37wk_initiators // should be considered unexposed in the preterm model

	count

* Save dataset for paternal analysis 

	save "$Deriveddir\paternal_analysis_dataset.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	erase "$Tempdatadir\pre_dates_new_users.dta"

	forvalues y=1/3 {
		
		erase "$Tempdatadir\predates_t`y'_new_users.dta"
		
	}

	forvalues y=1/3 {
		forvalues x=1/`max' {
			
			erase "$Tempdatadir\dates_t`y'_new_users_`x'.dta"
			
		}
	}

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close creating_pat_analysis_datset
	
	translate "$Logdir\1_cleaning\13_creating_pat_analysis_datset.smcl" "$Logdir\1_cleaning\13_creating_pat_analysis_datset.pdf", replace
	
	erase "$Logdir\1_cleaning\13_creating_pat_analysis_datset.smcl"
	
********************************************************************************
