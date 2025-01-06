
********************************************************************************

* Cleaning the variables in the population dataset

* Author: Flo Martin

* Date: 23/01/2024

********************************************************************************

* Start logging

	log using "$Logdir\1_data management\2_cleaning mbr", name(cleaning_mbr) replace
	
********************************************************************************

* Load in the data

	use "$Datadir\DOHAD_ANALYTICAL_V2_eligible.dta", clear
	
	count
	codebook mother_id
	
********************************************************************************
	
* Number of pregnancies in these data for looping over later

	bysort mother_id (deliv_date): egen pregnum=seq()
	tab pregnum
	
* Pregnancy dates

	* Birth year
	
	gen birth_yr_cat = 1 if birth_yr<2000
	replace birth_yr_cat = 2 if birth_yr<2005 & birth_yr_cat==.
	replace birth_yr_cat = 3 if birth_yr<2010 & birth_yr_cat==.
	replace birth_yr_cat = 4 if birth_yr<2016 & birth_yr_cat==.
	replace birth_yr_cat = 5 if birth_yr>2015
	
	label define birth_yr_lb 1"1995-1999" 2"2000-2004" 3"2005-2009" 4"2010-2015" 5"2016-2020"
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

	tab mother_age, m
	
	gen mother_age_cat = 0 if mother_age<20
	replace mother_age_cat = 1 if mother_age>19 & mother_age<25
	replace mother_age_cat = 2 if mother_age>24 & mother_age<30
	replace mother_age_cat = 3 if mother_age>29 & mother_age<35
	replace mother_age_cat = 4 if mother_age>34 & mother_age<40
	replace mother_age_cat = 5 if mother_age>39 & mother_age<45
	replace mother_age_cat = 6 if mother_age>44 & mother_age!=.
	
	label define age_cat_lb 0"<20" 1"20-24" 2"25-29" 3"30-34" 4"35-39" 5"40-44" 6">=45"
	label values mother_age_cat age_cat_lb
	tab mother_age_cat, m // 0.08% missing in maternal age
	
	* Maternal bmi
	summ bmi, det

	gen mother_bmi_cat = 0 if bmi<18.5
	replace mother_bmi_cat = 1 if bmi>=18.5 & bmi<25
	replace mother_bmi_cat = 2 if bmi>=25 & bmi<30
	replace mother_bmi_cat = 3 if bmi>30 & bmi!=.
	tab mother_bmi_cat
	
	label define bmi_lb 0"Underweight <18.5" 1"Healthy weight 18.5-24.9" 2"Overweight 25-29.9" 3"Obese >30"
	label values mother_bmi_cat bmi_lb
	tab mother_bmi_cat, m // 9.6% missing data in BMI
	
	* Maternal educational attainment
	tab edu7txt_bm
	
	gen mother_educ = 0 if edu7atbirth_bm==4 | edu7atbirth_bm==5 // primary
	replace mother_educ = 1 if edu7atbirth_bm==6 | edu7atbirth_bm==7 // secondary
	replace mother_educ = 2 if edu7atbirth_bm==1 | edu7atbirth_bm==2 // post-secondary
	replace mother_educ = 3 if edu7atbirth_bm==3
	replace mother_educ = 4 if edu7atbirth_bm==.
	
	label define edu_lb 0"Compulsory or less" 1"Secondary" 2"Post-secondary" 3"Postgradute" 4"Missing - majority immigrants"
	label values mother_educ edu_lb
	tab mother_educ
	
	* Country of birth
	tab mother_birth_country, m
	
	gen mother_birth_country_nonsverige = 1 if mother_birth_country!="SVERIGE" & mother_birth_country!=""
	replace mother_birth_country_nonsverige = 0 if mother_birth_country=="SVERIGE"
	
	label define nonsverige_lb 0"Sweden born" 1"Non-Sweden born"
	label values mother_birth_country_nonsverige nonsverige_lb
	tab mother_birth_country_nonsverige, m
	
	* Maternal parity
	tab parity, m
	
	* Previous stillbirths
	
		* [NEED TO DERIVE]
	
	* Smoking
	label define smok_lb 0"0 cig" 1"1-9 cig" 2"10+ cig"
	
	tab smoke_beg, m
	encode smoke_beg, gen(smoke_beg_num)
	tab smoke_beg_num, nol
	recode smoke_beg_num 1=0 2=1 3=2
	drop smoke_beg
	rename smoke_beg_num smoke_beg
	label values smoke_beg smok_lb
	label variable smoke_beg"Smoking at the first visit"
	
	tab smoke_end, m
	encode smoke_end, gen(smoke_end_num)
	tab smoke_end_num, nol
	recode smoke_end_num 1=0 2=1 3=2
	drop smoke_end
	rename smoke_end_num smoke_end
	label values smoke_end smok_lb
	label variable smoke_end"Smoking at 30-32 weeks'"
	
********************************************************************************

* Paternal characteristics

	* Paternal educational attainment
	tab edu7txt_bf
	
	gen father_educ = 0 if edu7atbirth_bf==4 | edu7atbirth_bf==5 // primary
	replace father_educ = 1 if edu7atbirth_bf==6 | edu7atbirth_bf==7 // secondary
	replace father_educ = 2 if edu7atbirth_bf==1 | edu7atbirth_bf==2 // post-secondary
	replace father_educ = 3 if edu7atbirth_bf==3
	replace father_educ = 4 if edu7atbirth_bf==.

	label values father_educ edu_lb
	tab father_educ

********************************************************************************

* Outcomes

	* Stillbirth
	
	tab stillborn, m	// X% prevalence of stillbirth
	tab gest_age_wks if stillborn==1
	
	* Gestational age
	
		* Preterm delivery <37 weeks' gestation (259 days) and post-term >=42 weeks' gestation
			
		gen term_cat = 0 if gest_age_days<259
		replace term_cat = 1 if gest_age_days>=259 & gest_age_days<294 & gest_age_days!=.
		replace term_cat = 2 if gest_age_days>=294 & gest_age_days!=.
	
		label define term_cat_lb 0"Preterm delivery" 1"Term delivery" 2"Post-term delivery"
		label values term_cat term_cat_lb
		
		tab term_cat, m
		
		* Binary variables
		
		gen preterm = 1 if term_cat==0
		replace preterm = 0 if term_cat!=0
		
		gen postterm = 1 if term_cat==2
		replace postterm = 0 if term_cat==1
		
		gen postterm_sens = 1 if gest_age_days>=287 & gest_age_days!=.
		replace postterm_sens = 0 if gest_age_days>=259 & gest_age_days<287 & gest_age_days!=.
		
		* Classes of preterm delivery - moderate-to-late preterm (32-37 weeks'), very preterm (28-32 weeks') and extremely preterm (<28 weeks')
		gen preterm_class = 0 if preterm==0
		replace preterm_class = 1 if preterm==1
		replace preterm_class = 2 if gest_age_days<224
		replace preterm_class = 3 if gest_age_days<196
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
		
		gen spont_labour=1 if induction==0
		replace spont_labour=0 if induction==1
		
		gen spont_preterm = 1 if spont_labour==1 & preterm==1
		replace spont_preterm = 0 if preterm==0
		tab spont_preterm
		
		gen induc_preterm = 1 if spont_labour==0 & preterm==1
		replace induc_preterm = 0 if preterm==0
		tab induc_preterm
		
	* Apgar score
	
	tab apgar5, m
	encode apgar5, gen(apgar5_num)
	tab apgar5_num, nol
	recode apgar5_num 1=0 2=1 3=2 4=3 5=4 6=5 7=6 8=7 9=8 10=9 11=10
	label drop apgar5_num
	tab apgar5_num
	drop apgar5
	rename apgar5_num apgar5
	
	* Neonatal death
	
	tab neonatal_death, m
	
********************************************************************************

* Save the dataset

	save "$Tempdatadir\eligble_sample_prebw.dta", replace
	
********************************************************************************

* Birthweight

	sum birth_weight, det
	count if birth_weight==0 
	count if birth_weight==.
	
	tab child_male, m
	
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

	merge 1:1 mother_id deliv_date using "$Datadir\externally_valid_sizeforga_intergrowth.dta", nogen
	merge 1:1 mother_id deliv_date using "$Datadir\externally_valid_sizeforga_swedish.dta", nogen
	
	merge 1:1 mother_id deliv_date using "$Tempdatadir\eligble_sample_prebw.dta", update replace nogen
	
	count
	
	save "$Datadir\clean_mbr_full.dta", replace
	
	drop addicted_date_ip addicted_ip adhd_date_ip adhd_ip asd_date_ip asd_ip id_date_ip id_ip migraine_date_ip migraine_ip bipolar_date_ip bipolar_ip eating_disorder_date_ip eating_disorder_ip anxiety_date_ip anxiety_ip depression_date_ip depression_ip psych_history_date_ip psych_history_ip tension_headache_date_ip tension_headache_ip other_psych_date_ip other_psych_ip addicted_date_bm addicted_bm adhd_date_bm adhd_bm asd_date_bm asd_bm id_date_bm id_bm migraine_date_bm migraine_bm bipolar_date_bm bipolar_bm eating_disorder_date_bm eating_disorder_bm anxiety_date_bm anxiety_bm depression_date_bm depression_bm psych_history_date_bm psych_history_bm stress_incont_date_bm stress_incont_bm tension_headache_date_bm tension_headache_bm other_psych_date_bm other_psych_bm addicted_date_bf addicted_bf adhd_date_bf adhd_bf asd_date_bf asd_bf id_date_bf id_bf migraine_date_bf migraine_bf bipolar_date_bf bipolar_bf eating_disorder_date_bf eating_disorder_bf anxiety_date_bf anxiety_bf depression_date_bf depression_bf psych_history_date_bf psych_history_bf tension_headache_date_bf tension_headache_bf other_psych_date_bf other_psych_bf
	
	* Father pregnum for merging with paternal exposures
	sort father_id deliv_date
	bysort father_id: egen pregnum_dad=seq() if father_id!=.
	tab pregnum_dad
	
	save "$Datadir\clean_mbr_reduced.dta", replace
	
	preserve
	
	use "$Datadir\clean_mbr_reduced.dta", clear
	
	drop if father_id==.
	
	save "$Datadir\clean_mbr_reduced_pat.dta", replace
	
	restore
	
********************************************************************************	

* Erase temporary datasets

	erase "$Tempdatadir\eligble_sample_prebw.dta"
	
	forvalues x=22/`wk' {
		foreach sex in 0 1 {
			    
			erase "$Tempdatadir\birthweight_`x'wks_`sex'.dta"
				
		}
	}
	

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_mbr
	
	translate "$Logdir\1_data management\2_cleaning mbr.smcl" "$Logdir\1_data management\2_cleaning mbr.pdf", replace
	
	erase "$Logdir\1_data management\2_cleaning mbr.smcl"
	
********************************************************************************