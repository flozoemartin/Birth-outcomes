
********************************************************************************

* Creating the paternal analysis dataset

* Author: Flo Martin 

* Date started: 22/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\2_analysis\2_creating_pat_analysis_datset", name(creating_pat_analysis_datset) replace
	
********************************************************************************	

* Load in the MBRN data

	use "$Datadir\clean_mbr_full.dta", clear
	
	drop if father_id==.
	
	count				// 2,615,676 babies
	
	tab pregnum
	summ pregnum // max number of pregnancies within the study period is 31
	local max = `r(max)'
	
	* Merge with the maternal exposure dataset
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_ad_exposure.dta", keep(3) nogen
	
	rename any_prepreg any_prepreg_mat
	rename any_preg any_preg_mat
	
	foreach x in l m n o a b c {
	
		rename any_`x' any_`x'_mat
	
	}
	
	rename drug_preg drug_preg_mat
	
	* Merge with the paternal exposure dataset
	merge 1:1 mother_id deliv_date using "$Deriveddir\paternal_ad_exposure.dta", keep(3) nogen
	
	* Merge with the other prescriptions datasets
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_n05a_12mo.dta", keep(1 3) nogen
	merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_n03_12mo.dta", keep(1 3) nogen
	
	recode n03_12mo .=0
	tab n03_12mo
	label variable n03_12mo"Anti-seizure medication use in the 12 months before pregnancy"
	
	recode n05a_12mo .=0
	tab n05a_12mo
	label variable n05a_12mo"Antipsychotic use in the 12 months before pregnancy"
	
	* Merge with the maternal indication dataset
	merge 1:1 father_id start_date deliv_date using "$Deriveddir\paternal_depression.dta", keep(1 3) nogen
	merge 1:1 father_id start_date deliv_date using "$Deriveddir\paternal_anxiety.dta", keep(1 3) nogen
	
	foreach indic in depression anxiety {
		
		recode pat_`indic'_ever .=0
		recode pat_`indic'_12mo .=0
		recode pat_`indic'_preg .=0
		recode pat_`indic' .=0
		
	}
	
	* Merge with the maternal indication datasets
	
	foreach indic in depression anxiety bipolar ed migraine incont headache {
	
		merge 1:1 mother_id deliv_date using "$Deriveddir\maternal_`indic'.dta", keep(1 3) nogen
		
		rename `indic' mat_`indic'
		replace mat_`indic' = 0 if mat_`indic'==.
		tab mat_`indic'
		
		replace `indic'_ever = 0 if `indic'_ever==.
		replace `indic'_12mo = 0 if `indic'_12mo==.
		replace `indic'_preg = 0 if `indic'_preg==.
		
	}
	
	count
	
	* Previous stillbirth
	
	merge 1:1 mother_id pregnum using "$Datadir\covariates\previous stillbirth.dta", keep(1 3) nogen
	recode prev_sb_bin .=0
	
* Covariates

	* Birth year
	tab birth_yr_cat
	
	* Maternal age
	tab mother_age_cat
	
	* Maternal educational attainment
	tab mother_educ
	
	* Maternal educational attainment
	tab edu7txt_bf
	
	/*gen father_educ = 0 if edu7atbirth_bf==4 | edu7atbirth_bf==5 // primary
	replace father_educ = 1 if edu7atbirth_bf==6 | edu7atbirth_bf==7 // secondary
	replace father_educ = 2 if edu7atbirth_bf==1 | edu7atbirth_bf==2 // post-secondary
	replace father_educ = 3 if edu7atbirth_bf==3
	replace father_educ = 4 if edu7atbirth_bf==.*/
	tab father_educ
	
	* Maternal disposable income
	tab dispink_atbirth5gr_bm
	
	* Maternal birth country
	tab mother_birth_country_nonsverige
	
	* Maternal BMI
	tab mother_bmi_cat
	
	* Maternal smoking
	tab smoke_beg
	
	* Maternal addiction
	tab addicted_bm

	* Previous stillbirth
	tab prev_sb_bin
	
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
	tab mat_depression
	tab mat_anxiety
	tab mat_ed
	
	* Paternal indications
	tab pat_depression
	tab pat_anxiety
	
	* Other indications
	tab mat_bipolar
	tab mat_migraine
	tab mat_incont
	tab mat_headache
	
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
	
	* Follow-up for Cox models - postterm delivery
	
	gen gestage_36plus6wks=(7*37)-1
	gen start_fup_postterm=gestage_36plus6wks
	
	gen end_fup_postterm=gest_age_days
	
	drop gestage*
	
********************************************************************************/	

* EXPOSURE DERIVATIONS
	
	save "$Tempdatadir\pre_dates_new_users_pat.dta", replace

* TIME UPDATED EXPOSURE
 	
* Get data to define time-update exposure status

	forvalues y=3/3 {
		
		* Trimester `y'
		use "$Tempdatadir\pre_dates_new_users_pat.dta", clear
		
		gen tri`y'_new_user = 1 if cf_unexp_incid_pat==`y' // not in the 3 months before pregnancy but in pregnancy
		label variable tri`y'_new_user"Flags new antidepressant use in T`y'"
		
		save "$Tempdatadir\predates_t`y'_new_users.dta", replace
		
	* Get dates of 1st trimester prescription for new users*/

		use "$Tempdatadir\predates_t`y'_new_users.dta", clear
		bysort father_id (pregnum_dad): egen seq=seq()
		summ seq // max number of pregnancies within the study period is 14
		local max = `r(max)'
		
		forvalues x=1/`max' {
			
			*duplicates drop patid, force - do I want to do this? Some patients initiate ADs in T1 for multiple pregnancies
			use "$Tempdatadir\predates_t`y'_new_users.dta", clear
			keep if tri`y'_new_user==1
			keep if pregnum_dad==`x'
			merge 1:m father_id using "$Deriveddir\pat_pregnancy_cohort_patternsinpregnancy.dta", keep(master match) nogen
			
			if _N>0 & `y'==3 {
			
				keep father_id start_date deliv_date any_o_pat any_c_pat disp_date1c cf_unexp_incid deliv_date
				sort father_id start_date deliv_date disp_date1c
				br
				gen flag_3rd_trim_presc=1 if disp_date1c>=start_date+189 & disp_date1c<deliv_date
				keep if flag_3rd==1
				bysort father_id start_date deliv_date (disp_date1c): keep if _n==1
				codebook deliv_date
				rename disp_date1c third_tri_initiation_date
				keep father_id start_date deliv_date flag_3rd_trim_presc third_tri_initiation_date
				label var third_tri_initiation_date "Date of antidepressant initiation in 3rd trim new users"
				
			}
			
			else if _N==0 {
				
				keep father_id start_date deliv_date
				
			}
			
			save "$Tempdatadir\dates_t`y'_new_users_`x'_pat.dta", replace

		}
	}
		
	use "$Tempdatadir\dates_t3_new_users_1_pat.dta", clear
	
	forvalues x=2/`max' {
		
		append using "$Tempdatadir\dates_t3_new_users_`x'_pat.dta"
		
	}
	
	duplicates drop father_id deliv_date, force

	merge 1:1 father_id start_date deliv_date using "$Tempdatadir\pre_dates_new_users_pat.dta", nogen // 12,992 with dates
	
	foreach x in third {
	    
		replace `x'_tri_initiation_date = `x'_tri_initiation_date - start_date if `x'_tri_initiation_date!=.
		
	}
	
	gen start_date_num = 0
	gen deliv_date_num = gest_age_days
	
	* New-users after 37 weeks for the preterm delivery logistic regression
	
	gen flag_37wk_initiators = 1 if third_tri_initiation_date>start_fup_postterm & third_tri_initiation_date!=.
	tab flag_37wk_initiators // should be considered unexposed in the preterm model
	
********************************************************************************/

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
	
	gen smoke_preg = 0 if smoke_beg==0 | smoke_end==0
	replace smoke_preg = 1 if smoke_beg==1 | smoke_beg==2
	replace smoke_preg = 1 if smoke_end==1 | smoke_end==2

* Save dataset for maternal analysis 

	save "$Deriveddir\paternal_analysis_dataset.dta", replace
	
	keep mother_id father_id child_id start_date deliv_date start_date_num deliv_date_num ///
	stillborn neonatal_death *preterm* postterm* sga* lga* apgar5_bin gest_age* birth_weight bweight* ///
	birth_yr* mother_age_cat father_educ mother_educ parity dispink5atbirth ap_12mo asm_12mo pat_depression pat_anxiety mat_depression mat_anxiety mat_ed mat_bipolar mat_migraine mat_incont mat_headache mother_birth_country_nonsverige mother_bmi_cat smoke_preg prev_sb_bin spont_labour ///
	any_preg_pat any_preg_mat flag* any_o* any_a* any_b* any_c* drug_preg* *fup* trunc_flag
	
	save "$Deriveddir\paternal_analysis_dataset_reduced.dta", replace
	
********************************************************************************

/* Erase unnecessary datasets

	erase "$Tempdatadir\pre_dates_new_users_pat.dta"

	forvalues y=3/3 {
		forvalues x=1/`max' {
			
			erase "$Tempdatadir\dates_t`y'_new_users_`x'.dta"
			
		}
	}*/
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close creating_pat_analysis_datset
	
	translate "$Logdir\2_analysis\2_creating_pat_analysis_datset.smcl" "$Logdir\2_analysis\2_creating_pat_analysis_datset.pdf", replace
	
	erase "$Logdir\2_analysis\2_creating_pat_analysis_datset.smcl"
	
********************************************************************************
