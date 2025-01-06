********************************************************************************

* Exploring the birth outcomes data

* Author: Flo Martin 

* Date started: 20/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\2_cleaning mbrn", name(cleaning_mbrn) replace
	
********************************************************************************	

* Load in the data

	use "$Datadir\eligible_mbrn.dta", clear
	
	count 				// n=906,251 children in this dataset...
	codebook preg_id 	// ...among n=906,251 pregnancies

********************************************************************************

* Number of pregnancies in these data for looping over later

	bysort mother_id: egen pregnum=seq()
	tab pregnum

* Pregnancy dates

	* Birth year
	
	gen birth_yr_cat = 1 if birth_yr<2010
	replace birth_yr_cat = 2 if birth_yr<2016 & birth_yr_cat!=1
	replace birth_yr_cat = 3 if birth_yr>2015
	
	label define birth_yr_lb 1"2005-2009" 2"2010-2015" 3"2016-2020"
	label values birth_yr_cat birth_yr_lb
	tab birth_yr_cat
	
	list deliv_date in 1/10
		
	count if gest_age_days==.
	count if gest_age_wks==.
	
	gen secondtrim = (start_date + 91) if ((start_date+91)<deliv_date) & deliv_date!=.
	gen thirdtrim = (start_date + 189) if ((start_date+189)<deliv_date) & deliv_date!=.
	
********************************************************************************	

* Maternal characteristics

	* Maternal age
	tab mother_age_cat 
	
	label define age_cat_lb 0"<20" 1"20-24" 2"25-29" 3"30-34" 4"35-39" 5"40-44" 6">=45"
	label values mother_age_cat age_cat_lb
	tab mother_age_cat, m
	
	* Maternal BMI
	summ bmi, det

	gen mother_bmi_cat = 0 if bmi<18.5
	replace mother_bmi_cat = 1 if bmi>=18.5 & bmi<25
	replace mother_bmi_cat = 2 if bmi>=25 & bmi<30
	replace mother_bmi_cat = 3 if bmi>30 & bmi!=.
	tab mother_bmi_cat
	
	label define bmi_lb 0"Underweight <18.5" 1"Healthy weight 18.5-24.9" 2"Overweight 25-29.9" 3"Obese >30"
	label values mother_bmi_cat bmi_lb
	tab mother_bmi_cat, m // 45% missing data in BMI - only started to be collected recently
	
	* Country of birth
	tab mother_birth_country_nonnordic, m
	
		* For comparability with Sweden, recoding variable for Norway and non-Norway born
	gen mother_birth_country_nonnorge = 1 if mother_birth_country!="Norge" & mother_birth_country!=""
	replace mother_birth_country_nonnorge = 0 if mother_birth_country=="Norge"
	
	label define nonnorge_lb 0"Norway born" 1"Non-Norway born"
	label values mother_birth_country_nonnorge nonnorge_lb
	tab mother_birth_country_nonnorge, m
		
	* Maternal parity
	tab parity, m // complete
	
	* Previous stillbirths
	tab prev_still_births, m // 4% missing
	
	gen prev_sb_bin = 1 if prev_still_births>0 & prev_still_births!=.
	replace prev_sb_bin = 0 if prev_still_births==0
	
	* Chronic illness - all complete probably for the same reason as CPRD, absence of a code = not diagnosed
	tab chronic_asthma, m 
	tab chronic_htn, m
	tab chronic_epilepsy, m
	tab chronic_diabetes, m
	
	* Smoking
	tab smoke_beg, m 		// 14% missing - smoking in early pregnancy y/n
	label variable smoke_beg"Smoking during early pregnancy"
	
	tab smoke_beg_num, m 	// 15% missing and not labelled
	label define smok_lb 0"Non-smoker" 1"1-9 cigs/day" 2"10+ cigs/day"
	label values smoke_beg_num smok_lb
	
	tab smoke_end, m 		// 17% missing
	label variable smoke_end"Smoking at the end pregnancy"
	
	* Folic acid use - all complete
	tab folate_before, m
	tab folate_during, m

********************************************************************************

* Outcomes
	
	* Stillbirth
	
		tab stillborn 					// 0.35% prevalence of stillbirth
		tab gest_age_wks if stillborn==1
		
	* Gestational age
	
		list gest_age_child in 1/100 	// in days
		sum gest_age_child, det			// 154 - 335 gestational days 
		
		* Preterm delivery <37 weeks' gestation (259 days) and post-term >=42 weeks' gestation
		gen term_cat = 0 if gest_age_child<259
		replace term_cat = 1 if gest_age_child>=259 & gest_age_child<294 & gest_age_child!=.
		replace term_cat = 2 if gest_age_child>=294 & gest_age_child!=.
		
		label define term_cat_lb 0"Preterm delivery" 1"Term delivery" 2"Post-term delivery"
		label values term_cat term_cat_lb
		
		tab term_cat, m
		
		gen preterm = 1 if term_cat==0
		replace preterm = 0 if term_cat!=0
		
		gen postterm = 1 if term_cat==2
		replace postterm = 0 if term_cat==1
		
		gen postterm_sens = 1 if gest_age_child>=287 & gest_age_child!=.
		replace postterm_sens = 0 if gest_age_child>=259 & gest_age_child<287 & gest_age_child!=.
		
		* Classes of preterm delivery - moderate-to-late preterm (32-37 weeks'), very preterm (28-32 weeks') and extremely preterm (<28 weeks')
		gen preterm_class = 0 if preterm==0
		replace preterm_class = 1 if preterm==1
		replace preterm_class = 2 if gest_age_child<224
		replace preterm_class = 3 if gest_age_child<196
		tab preterm_class, m
		
		label define preterm_class_lb 3"Extremely preterm" 2"Very preterm" 1"Moderate-to-late preterm" 0"Term (>=37 weeks')"
		label values preterm_class preterm_class_lb
		tab preterm_class
		
			* Moderate-to-late preterm
			gen modpreterm = 1 if preterm_class==1
			replace modpreterm = 0 if preterm_class==0 
			tab preterm_class modpreterm, m
			
			* Very preterm
			gen verypreterm = 1 if preterm_class==2
			replace verypreterm = 0 if preterm_class!=3 & preterm_class!=2 & preterm_class!=.
			tab preterm_class verypreterm, m
			
			* Extremely preterm
			gen expreterm = 1 if preterm_class==3
			replace expreterm = 0 if preterm_class!=3 & preterm_class!=.
			tab preterm_class expreterm, m
			
		* Delivery-type of preterm
		
		gen spont_preterm = 1 if spont_labour==1 & preterm==1
		replace spont_preterm = 0 if preterm==0
		tab spont_preterm
		
		gen induc_preterm = 1 if spont_labour==0 & preterm==1
		replace induc_preterm = 0 if preterm==0
		tab induc_preterm
		
		// n=3 preterm babies who are missing spont_labour
		
	* Apgar score
	
		tab apgar1, m
		tab apgar5, m
		tab apgar10, m
			
		foreach x in 1 5 10 {
			
			gen apgar`x'_bin = 1 if apgar`x'<7
			replace apgar`x'_bin = 0 if apgar`x'>=7 & apgar`x'!=.
			tab apgar`x'_bin, m
		
		}
		
	* Neonatal death - should be within the first 28 days of life
	
		tab neonatal_death, m // 0.3% missing
	
********************************************************************************

* Save the dataset

	save "$Tempdatadir\eligble_sample_prebw.dta", replace
	
********************************************************************************

* Birthweight
	
		sum birth_weight, det // 0 - 6370 grams
		br if birth_weight==0 // n=1 with birthweight of 0
		br if birth_weight==. // n=239 with missing birthweight
		
		tab child_male, m // 44 without a sex therefore won't have a birthweight Z-score
		
		summ gest_age_wks, det
		local wk=`r(max)'
		
		forvalues x=22/`wk' {
			foreach sex in 0 1 {

				use "$Tempdatadir\eligble_sample_prebw.dta", clear
				
				drop if birth_weight==. | birth_weight==0
				count
				
				tab gest_age_wks
				
				keep if gest_age_wks==`x'
				keep if child_male==`sex'
			
				if _N>1 {
			
					egen zbweight = std(birth_weight)
					egen bweight_10 = pctile(birth_weight), p(10)
					egen bweight_90 = pctile(birth_weight), p(90)
				
				}
				
				else if _N==1 {
				
					egen zbweight = std(birth_weight)
					egen bweight_10 = pctile(birth_weight), p(10)
					egen bweight_90 = pctile(birth_weight), p(90)
				
				}
			
				save "$Tempdatadir\birthweight_`x'wks_`sex'.dta", replace
			
			}
		}
	
	use "$Tempdatadir\birthweight_22wks_0.dta", clear
	append using "$Tempdatadir\birthweight_22wks_1.dta"
	
	forvalues x=22/`wk' {
		foreach sex in 0 1 {
		
			append using "$Tempdatadir\birthweight_`x'wks_`sex'.dta"
		
		}
	}
	
	duplicates drop
	
	twoway /*
	*/ histogram zbweight if child_male==0, blcolor(red) bfcolor(none) fraction || /*
	*/ histogram zbweight if child_male==1, bfcolor(none) blcolor(blue) fraction legend(order(0 "Female" 1 "Male"))
	
	/* Small for gestational age (SGA) is defined as birth weight of less than 10th percentile for gestational age - for these data I have created percentiles within each week of gestational age
 https://www.ncbi.nlm.nih.gov/books/NBK563247/#:~:text=Small%20for%20gestational%20age%20(SGA,the%20neonatal%20period%20and%20beyond. */

	gen sga_z = 1 if zbweight < invnormal(0.1)
	replace sga_z = 0 if zbweight >= invnormal(0.1) & zbweight<=invnormal(0.9) & zbweight!=.
	
	tab sga_z
	label variable sga_z"Small for gestational age - <10th percentile in birthweight Z-score for gestational age (weeks)"
	
	gen sga_pct = 1 if birth_weight < bweight_10
	replace sga_pct = 0 if birth_weight >= bweight_10 & birth_weight<=bweight_90 & birth_weight!=.
	
	tab sga_pct
	label variable sga_pct"Small for gestational age - <10th percentile in birthweight for gestational age (weeks)"
	
/* Large for gestational age (LGA) is defined as birth weight of more than 90th percentile for gestational age - for these data I have created percentiles within each week of gestational agehttps://www.esneft.nhs.uk/leaflet/large-for-gestational-age-babies-information-for-parents/#:~:text=What%20is%20considered%20a%20large,babies%20are%20identified%20as%20LGA. */

	gen lga_z = 1 if zbweight > invnormal(0.9) & zbweight!=. 
	replace lga_z = 0 if zbweight <= invnormal(0.9) & sga_z!=1
	
	tab lga_z
	label variable lga_z"Large for gestational age - >90th percentile in birthweight Z-score gestational age (weeks)"
	
	gen lga_pct = 1 if birth_weight > bweight_90 & birth_weight!=. 
	replace lga_pct = 0 if birth_weight <= bweight_90 & sga_pct!=1
	
	tab lga_pct
	label variable lga_pct"Large for gestational age - >90th percentile in birthweight gestational age (weeks)"
	
	gen aga_z = 1 if lga_z!=1 & sga_z!=1
	replace aga_z = 0 if lga_z==1 | sga_z==1
	label variable aga_z"Adequate for gestational age - <=90th  or >=10th percentile in birthweight Z-score for gestational age (weeks)"
	
	gen aga_pct = 1 if lga_pct!=1 & sga_pct!=1
	replace aga_pct = 0 if lga_pct==1 | sga_pct==1
	label variable aga_pct"Adequate for gestational age - <=90th  or >=10th percentile in birthweight for gestational age (weeks)"
	
********************************************************************************

* Externally validate size for gestational age against the Intergrowth-21 standard and the New Swedish standard
		
	preserve 	
		
		do "$Dodir\1_data management\2a_externally validating size for ga intergrowth.do"
		do "$Dodir\1_data management\2b_externally validating size for ga swedish.do"
		
	restore

	merge 1:1 child_id using "$Datadir\externally_valid_sizeforga_intergrowth.dta", nogen
	merge 1:1 child_id using "$Datadir\externally_valid_sizeforga_swedish.dta", nogen
	
	merge 1:1 child_id using "$Tempdatadir\eligble_sample_prebw.dta", update replace nogen
	
	count
	
	save "$Datadir\clean_mbrn.dta", replace

********************************************************************************	

* Erase temporary datasets

	erase "$Tempdatadir\eligble_sample_prebw.dta"
	
	forvalues x=22/`wk' {
		foreach sex in 0 1 {
			    
			erase "$Tempdatadir\birthweight_`x'wks_`sex'.dta"
				
		}
	}
	

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_mbrn
	
	translate "$Logdir\1_cleaning\2_cleaning mbrn.smcl" "$Logdir\1_cleaning\2_cleaning mbrn.pdf", replace
	
	erase "$Logdir\1_cleaning\2_cleaning mbrn.smcl"
	
********************************************************************************
