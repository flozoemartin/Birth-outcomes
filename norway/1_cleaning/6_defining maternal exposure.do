********************************************************************************

* Identifying prescriptions that overlap with each period of of interest

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\6_defining maternal exposure", name(defining_maternal_exposure) replace
	
********************************************************************************	

* Do-files for defining antidepressant use before and during pregnancy

	do "$Dodir\1_data management\6a_ad pxns before pregnancy.do"
	do "$Dodir\1_data management\6b_ad pxns during pregnancy.do"
	
/* Add the class info to the pregnancies

	foreach y in a b c {
		forvalues x=1/4 {
		
			use "$Codesdir\ad_codelist.dta", clear
			rename class class`x'`y'
			rename drugsubstance drugsubstance`x'`y'
			save "$Tempdatadir\ad_codelist_for_patterns`x'`y'.dta", replace
		
		}
	}*/
	
	use "$Deriveddir\pregnancy_cohort_patternsinpregnancy.dta", clear
	
	gen drugsubstance5a =""
	gen drugsubstance_num5a =.
	gen class5a =.
	gen drugsubstance5c =""
	gen drugsubstance_num5c =.
	gen class5c =.
	
	/*forvalues x=1/4 {
		foreach y in a b c {
	
			merge m:1 drugsubstance`x'`y' using "$Tempdatadir\ad_codelist_for_patterns`x'`y'.dta", keep(1 3)
			drop _merge
			
			label values class`x'`y' class_lb
			
		}
	}*/
	
	order mother_id preg_id pregnum *1a *2a *3a *4a *5a *1b *2b *3b *4b *5b *1c *2c *3c *4c *5c
	
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
		
		/* Old approach to generating other - didn't apply the same mutual exclusivity of exposure to other as for the named drugs
		gen other =.
		
		forvalues x=1/5 {
			foreach y in a b c {
				
					replace other = 1 if regexm(drugsubstance`x'`y', "bupropion") | regexm(drugsubstance`x'`y', "doxepin") | regexm(drugsubstance`x'`y', "clomipramine") | regexm(drugsubstance`x'`y', "fluvoxamine") | regexm(drugsubstance`x'`y', "phenelzine") | regexm(drugsubstance`x'`y', "tranylcypromine") | regexm(drugsubstance`x'`y', "moclobemide") | regexm(drugsubstance`x'`y', "oxitriptan") | regexm(drugsubstance`x'`y', "tryptophan") | regexm(drugsubstance`x'`y', "mianserin") | regexm(drugsubstance`x'`y', "trazodone") | regexm(drugsubstance`x'`y', "nefazodone")  | regexm(drugsubstance`x'`y', "tianeptine") | regexm(drugsubstance`x'`y', "reboxetine") | regexm(drugsubstance`x'`y', "agomelatine") | regexm(drugsubstance`x'`y', "lofepramine") | regexm(drugsubstance`x'`y', "nortriptyline") | regexm(drugsubstance`x'`y', "trimipramine") | regexm(drugsubstance`x'`y', "vortioxetine") 

				}
			}*/
			
		foreach w in bupropion doxepin clomipramine fluvoxamine phenelzine tranylcypromine moclobemide oxitriptan tryptophan mianserin trazodone nefazodone tianeptine reboxetine agomelatine lofepramine nortriptyline trimipramine vortioxetine {
		
		gen `w' =.
		
		forvalues x=1/5 {
			foreach y in a b c {
				
					replace `w' = 1 if regexm(drugsubstance`x'`y', "`w'")

				}
			}
		}
		
		* Generate an other variable that only includes those who only use their "other" medication and not any others
		gen other = 1 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==1 & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 2 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==1 & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 3 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==1 & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 4 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==1 & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 5 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==1 & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 6 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==1 & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 7 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==1 & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==.
		replace other = 8 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==1 & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==.
		replace other = 9 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==1 & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 10 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==1 & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 11 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==1 & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 12 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==1 & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 13 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==1 & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 14 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==1 & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==.
		replace other = 15 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==1 & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==. 
		replace other = 16 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==1 & nortriptyline==. & trimipramine==. & vortioxetine==.
		replace other = 17 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==1 & trimipramine==. & vortioxetine==. 
		replace other = 18 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==1 & vortioxetine==. 
		replace other = 19 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & bupropion==. & doxepin==. & clomipramine==. & fluvoxamine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & oxitriptan==. & tryptophan==. & mianserin==. & trazodone==. & nefazodone==. & tianeptine==. & reboxetine==. & agomelatine==. & lofepramine==. & nortriptyline==. & trimipramine==. & vortioxetine==1
		
		* Find those who are using polypharmacy of other and named medications
		foreach w in sertraline fluoxetine escitalopram venlafaxine mirtazapine amitriptyline paroxetine duloxetine citalopram bupropion doxepin clomipramine fluvoxamine phenelzine tranylcypromine moclobemide oxitriptan tryptophan mianserin trazodone nefazodone tianeptine reboxetine agomelatine lofepramine nortriptyline trimipramine vortioxetine {
		
			replace other = 20 if any_preg==1 & other==. & (bupropion==1 | doxepin==1 | clomipramine==1 | fluvoxamine==1 | phenelzine==1 | tranylcypromine==1 | moclobemide==1 | oxitriptan==1 | tryptophan==1 | mianserin==1 | trazodone==1 | nefazodone==1 | tianeptine==1 | reboxetine==1 | agomelatine==1 | lofepramine==1 | nortriptyline==1 | trimipramine==1 | vortioxetine==1) & `w'==1
			
		}
		
	* Variable mimicking that of Sweden analysis (top 10 medications) 
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
	replace drug_preg = 10 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other<20
	replace drug_preg = 11 if any_preg==1 & drug_preg==. // polypharmacy 
	
	tab drug_preg
	
	label define drug_preg_lb 0"Unexposed" 1"Sertraline exposed" 2"Citalopram exposed" 3"Fluoxetine exposed" 4"Escitalopram exposed" 5"Venlafaxine exposed" 6"Mirtazapine exposed" 7"Amitriptyline exposed" 8"Paroxetine exposed" 9"Duloxetine exposed" 10"Other exposed" 11"Polypharmacy exposed"
	label values drug_preg drug_preg_lb
	tab drug_preg
	
* Add on the pre-pregnancy dataset

	merge 1:1 mother_id preg_id using "$Tempdatadir\prepregnancy_cohort_patternsinpregnancy.dta", nogen
	
* Add the pregnancy dates

	merge 1:1 mother_id preg_id using "$Datadir\clean_mbrn.dta", nogen
	
	order mother_id preg_id start_date
	
	tab pregnum // n=11 pregnancies max
	summ pregnum
	local max=`r(max)'
	
********************************************************************************	

* Code in some patterns 

	* Prevalent users of antidepressants 
	
	gen cf_unexp_prev = 1 if any_preg==1 & any_o==1
	replace cf_unexp_prev=0 if any_preg==0
	tab cf_unexp_prev, m
	br start_date any_o any_a disp_date1a any_b any_c if cf_unexp_prev==.
	
	* Incident users of antidepressants by trimester
	
	gen cf_unexp_incid=1 if any_a==1 & any_o==0 & disp_date1a>=start_date & disp_date1a<start_date+91
	replace cf_unexp_incid=2 if any_b==1 & any_a==0 & any_o==0 & disp_date1b>=start_date+91 & disp_date1b<start_date+189
	replace cf_unexp_incid=3 if any_c==1 & any_b==0 & any_a==0 & any_o==0 & disp_date1c>=start_date+188 & disp_date1c<deliv_date
	replace cf_unexp_incid=0 if any_preg==0 
	tab cf_unexp_incid, m
	br start_date any_o any_a disp_date1a any_b any_c cf_unexp_prev if cf_unexp_incid==. 
	
	* Prevalent and incident users 
	
	gen cf_prev_incid = 0 if any_preg==0
	replace cf_prev_incid = 1 if cf_unexp_prev==1
	replace cf_prev_incid = 2 if cf_unexp_incid>0 & cf_unexp_incid!=.
	tab cf_prev_incid, m
	
********************************************************************************	
	
* Save maternal pregnancy exposure dataset
	
	keep mother_id preg_id any_* drug_preg cf_*
	
	save "$Deriveddir\maternal_ad_exposure.dta", replace
	
********************************************************************************	

* Erase unnecessary datasets

	erase "$Tempdatadir\prepregnancy_cohort_patternsinpregnancy.dta"

	forvalues x=1/`max' {
	    
		erase "$Tempdatadir\prepregpresc_`x'.dta"
		
	}
	
	forvalues x=1/`max' {
	    foreach y in l m n o {
		    
			erase "$Tempdatadir\prepreg_`x'_period`y'.dta"
			
		}
	}

	forvalues x=1/`max' {
	    
		erase "$Tempdatadir\pregpresc_`x'.dta"
		
	}
	
	forvalues x=1/`max' {
	    foreach y in a b c {
		    
			erase "$Tempdatadir\preg_`x'_period`y'.dta"
			
		}
	}
	
* Stop logging, translate .smcl into .pdf and erase .smcl

	log close defining_maternal_exposure
	
	translate "$Logdir\1_cleaning\6_defining maternal exposure.smcl" "$Logdir\1_cleaning\6_defining maternal exposure.pdf", replace
	
	erase "$Logdir\1_cleaning\6_defining maternal exposure.smcl"
	
********************************************************************************
