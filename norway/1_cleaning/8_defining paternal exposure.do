********************************************************************************

* Identifying paternal prescriptions that overlap with each period of of interest

* Author: Flo Martin 

* Date started: 26/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\8_defining paternal exposure", name(defining_paternal_exposure) replace
	
********************************************************************************

* Do-files for defining antidepressant use before and during pregnancy

	do "$Dodir\1_cleaning\8a_ad pxns before pregnancy.do"
	do "$Dodir\1_cleaning\8b_ad pxns during pregnancy.do"	
	
* Use these data	
	
	use "$Deriveddir\pat_pregnancy_cohort_patternsinpregnancy.dta", clear
	
	count
	
	order father_id preg_id pregnum_dad *1a *2a *3a *4a *5a *1b *2b *3b *4b *5b *1c *2c *3c *4c *5c
	
	* Products exposure during pregnancy
			
	foreach w in sertraline fluoxetine escitalopram venlafaxine mirtazapine amitriptyline paroxetine duloxetine {
		
		gen `w' =.
		
		forvalues x=1/5 {
			foreach y in a b c {
				
					replace `w' = 1 if regexm(drugsubstance`x'`y', "`w'")

				}
			}
		}
		
		gen citalopram =.
		
		forvalues x=1/5 {
			foreach y in a b c {
				
					replace citalopram = 1 if drugsubstance_num`x'`y'==4

				}
			}
		
		gen other =.
		
		forvalues x=1/5 {
			foreach y in a b c {
				
					replace other = 1 if regexm(drugsubstance`x'`y', "bupropion") | regexm(drugsubstance`x'`y', "doxepin") | regexm(drugsubstance`x'`y', "clomipramine") | regexm(drugsubstance`x'`y', "fluvoxamine") | regexm(drugsubstance`x'`y', "phenelzine") | regexm(drugsubstance`x'`y', "tranylcypromine") | regexm(drugsubstance`x'`y', "moclobemide") | regexm(drugsubstance`x'`y', "oxitriptan") | regexm(drugsubstance`x'`y', "tryptophan") | regexm(drugsubstance`x'`y', "mianserin") | regexm(drugsubstance`x'`y', "trazodone") | regexm(drugsubstance`x'`y', "nefazodone")  | regexm(drugsubstance`x'`y', "tianeptine") | regexm(drugsubstance`x'`y', "reboxetine") | regexm(drugsubstance`x'`y', "agomelatine") | regexm(drugsubstance`x'`y', "lofepramine") | regexm(drugsubstance`x'`y', "nortriptyline") | regexm(drugsubstance`x'`y', "trimipramine") | regexm(drugsubstance`x'`y', "vortioxetine") 

				}
			}
		
	* Variable mimicking that of Sweden analysis (top 10 medications) but this is missing the tricyclics for now
	gen drug_preg = 0 if any_preg==0
	replace drug_preg = 1 if sertraline==1 & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 2 if sertraline==. & citalopram==1 & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 3 if sertraline==. & citalopram==. & fluoxetine==1 & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 4 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==1 & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 5 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==1 & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 6 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==1 & amitriptyline==. & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 7 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==1 & paroxetine==. & duloxetine==. & other==.
	replace drug_preg = 8 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==1 & duloxetine==. & other==.
	replace drug_preg = 9 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==1 & other==.
	replace drug_preg = 10 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other==1
	replace drug_preg = 11 if any_preg==1 & drug_preg==.
	
	tab drug_preg
	
	label define drug_preg_lb 0"Unexposed" 1"Sertraline exposed" 2"Citalopram exposed" 3"Fluoxetine exposed" 4"Escitalopram exposed" 5"Venlafaxine exposed" 6"Mirtazapine exposed" 7"Amitriptyline exposed" 8"Paroxetine exposed" 9"Duloxetine exposed" 10"Other exposed" 11"Polypharmacy exposed"
	label values drug_preg drug_preg_lb
	tab drug_preg
	
* Add on the pre-pregnancy dataset

	merge 1:1 father_id preg_id using "$Tempdatadir\pat_prepregnancy_cohort_patternsinpregnancy.dta", nogen
	
* Add the pregnancy dates

	merge 1:1 father_id preg_id using "$Datadir\clean_mbrn.dta", nogen
	
	order mother_id father_id preg_id start_date
	
	tab pregnum // n=11 pregnancies max
	summ pregnum
	local max=`r(max)'
	
********************************************************************************	

* Code in some patterns 

	* Prevalent users of antidepressants 
	
	gen cf_unexp_prev_pat = 1 if any_preg_pat==1 & any_o_pat==1
	replace cf_unexp_prev_pat=0 if any_preg_pat==0
	tab cf_unexp_prev_pat, m
	br start_date any_o_pat any_a_pat disp_date1a any_b_pat any_c_pat if cf_unexp_prev_pat==.
	
	* Incident users of antidepressants by trimester
	
	gen cf_unexp_incid_pat=1 if any_a_pat==1 & any_o_pat==0 & disp_date1a>=start_date & disp_date1a<start_date+91
	replace cf_unexp_incid_pat=2 if any_b_pat==1 & any_a_pat==0 & any_o_pat==0 & disp_date1b>=start_date+91 & disp_date1b<start_date+189
	replace cf_unexp_incid_pat=3 if any_c_pat==1 & any_b_pat==0 & any_a_pat==0 & any_o_pat==0 & disp_date1c>=start_date+188 & disp_date1c<deliv_date
	replace cf_unexp_incid_pat=0 if any_preg_pat==0 
	tab cf_unexp_incid_pat, m
	br start_date any_o_pat any_a_pat disp_date1a any_b_pat any_c_pat cf_unexp_prev_pat if cf_unexp_incid_pat==. 
	
	* Prevalent and incident users 
	
	gen cf_prev_incid_pat = 0 if any_preg_pat==0
	replace cf_prev_incid_pat = 1 if cf_unexp_prev_pat==1
	replace cf_prev_incid_pat = 2 if cf_unexp_incid_pat>0 & cf_unexp_incid_pat!=.
	tab cf_prev_incid_pat, m
	
********************************************************************************		
	
* Save paternal exposure dataset
	
	rename drug_preg drug_preg_pat
	keep father_id mother_id preg_id any_* cf_* drug_preg
	count
	
	save "$Deriveddir\paternal_ad_exposure.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	erase "$Tempdatadir\pat_prepregnancy_cohort_patternsinpregnancy.dta"
	
	forvalues x=1/`max' {
	    
		erase "$Tempdatadir\pregpresc_`x'.dta"
		
	}
	
	forvalues x=1/`max' {
	    foreach y in a b c {
		    
			erase "$Tempdatadir\preg_`x'_period`y'.dta"
			
		}
	}

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close defining_paternal_exposure
	
	translate "$Logdir\1_cleaning\8_defining paternal exposure.smcl" "$Logdir\1_cleaning\8_defining paternal exposure.pdf", replace
	
	erase "$Logdir\1_cleaning\8_defining paternal exposure.smcl"
	
********************************************************************************
