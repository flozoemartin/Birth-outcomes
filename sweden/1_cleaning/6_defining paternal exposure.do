
********************************************************************************

* Identifying paternal prescriptions that overlap with each period of of interest

* Author: Flo Martin 

* Date started: 26/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\6_defining paternal exposure", name(defining_paternal_exposure) replace
	
********************************************************************************

* Do-files for defining antidepressant use before and during pregnancy

	do "$Dodir\1_data management\6a_ad pxns before pregnancy.do"
	do "$Dodir\1_data management\6b_ad pxns during pregnancy.do"	
	
* Use these data	
	
	use "$Deriveddir\pat_pregnancy_cohort_patternsinpregnancy.dta", clear
	
	count
	
	foreach x in 6a 6b {
		
		gen drugsubstance`x' =""
		gen drugsubstance_num`x' =.
		gen class_pdr`x' =.
		gen disp_date`x' =.
		gen prescr_end_date`x' =.
		
	}
	
	order father_id deliv_date pregnum_dad *a *b *c
	
	* Products exposure during pregnancy - top products
			
	foreach w in sertraline fluoxetine escitalopram venlafaxine mirtazapine amitriptyline paroxetine duloxetine {
		
		gen `w' =.
		
		forvalues x=1/6 {
			foreach y in a b c {
				
					replace `w' = 1 if regexm(drugsubstance`x'`y', "`w'")

				}
			}
		}
		
	gen citalopram =.
		
	forvalues x=1/6 {
		foreach y in a b c {
				
			replace citalopram = 1 if drugsubstance_num`x'`y'==4

		}
		
	}
		
	foreach w in citalopram sertraline fluoxetine escitalopram venlafaxine mirtazapine amitriptyline paroxetine duloxetine {
		
		tab `w'
		
	}
	
	* Other products
			
	foreach w in alaproclate etoperidone fluvoxamine zimeldine amineptine amoxapine butriptyline clomipramine desipramine dibenzepin dimetacrine dosulepin doxepin imipramine iprindole lofepramine maprotiline melitracen nortriptyline opipramol protriptyline quinupramine trimipramine iproclozide iproniazide isocarboxazid nialamide phenelzine tranylcypromine moclobemide toloxatone agomelatine bifemelane brexanolone bupropion desvenlafaxine esketamine gepirone levomilnacipran medifoxamine mianserin milnacipran minaprine nefazodone nomifensine oxaflozane oxitriptan pivagabine reboxetine tianeptine trazodone tryptophan vilazodone viloxazine vortioxetine {
		
		gen `w' =.
		
		forvalues x=1/6 {
			foreach y in a b c {
				
					replace `w' = 1 if regexm(drugsubstance`x'`y', "`w'")

				}
			}
	
			tab `w'
			
		}
		
	* Drop empty variables
	
		foreach var of varlist _all {
			
			capture assert mi(`var')
			
			if !_rc {
				
				drop `var'
			
			}
		}
		
	* Generate an other variable that only includes those who only use their "other" medication and not any others
		gen other = 1 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==1 & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 2 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==1 & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 3 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==1 & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 4 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==1 & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 5 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==1 & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 6 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==1 & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==. 
		replace other = 7 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==1 & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==.
		replace other = 8 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==1 & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==. 
		replace other = 9 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==1 & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==. 
		replace other = 10 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==1 & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==. 
		replace other = 11 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==1 & mianserin==. & reboxetine==. & vortioxetine==. 
		replace other = 12 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==1 & reboxetine==. & vortioxetine==. 
		replace other = 13 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==1 & vortioxetine==. 
		replace other = 14 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & fluvoxamine==. & clomipramine==. & imipramine==. & maprotiline==. & nortriptyline==. & trimipramine==. & phenelzine==. & tranylcypromine==. & moclobemide==. & agomelatine==. & bupropion==. & mianserin==. & reboxetine==. & vortioxetine==1
		
	* Find those who are using polypharmacy of other and named medications
		foreach w in sertraline citalopram fluoxetine escitalopram venlafaxine mirtazapine amitriptyline paroxetine duloxetine fluvoxamine clomipramine imipramine maprotiline nortriptyline trimipramine phenelzine tranylcypromine moclobemide agomelatine bupropion mianserin reboxetine vortioxetine {
		
			replace other = 17 if any_preg==1 & other==. & (fluvoxamine==1 | clomipramine==1 | imipramine==1 | maprotiline==1 | nortriptyline==1 | trimipramine==1 | phenelzine==1 | tranylcypromine==1 | moclobemide==1 | agomelatine==1 | bupropion==1 | mianserin==1 | reboxetine==1 | vortioxetine==1) & `w'==1
			
		}
		
	* Variable for top 10 medications
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
	replace drug_preg = 10 if sertraline==. & citalopram==. & fluoxetine==. & escitalopram==. & venlafaxine==. & mirtazapine==. & amitriptyline==. & paroxetine==. & duloxetine==. & other<15
	replace drug_preg = 11 if any_preg==1 & drug_preg==. // polypharmacy 
	
	tab drug_preg
	
	label define drug_preg_lb 0"Unexposed" 1"Sertraline exposed" 2"Citalopram exposed" 3"Fluoxetine exposed" 4"Escitalopram exposed" 5"Venlafaxine exposed" 6"Mirtazapine exposed" 7"Amitriptyline exposed" 8"Paroxetine exposed" 9"Duloxetine exposed" 10"Other exposed" 11"Polypharmacy exposed"
	label values drug_preg drug_preg_lb
	tab drug_preg
	
* Add on the pre-pregnancy dataset

	merge 1:1 father_id deliv_date pregnum_dad using "$Tempdatadir\pat_prepregnancy_cohort_patternsinpregnancy.dta", nogen
	
* Add the pregnancy dates

	merge 1:1 father_id pregnum_dad using "$Datadir\clean_mbr_reduced_pat.dta", nogen
	
	order mother_id father_id start_date deliv_date
	sort mother_id deliv_date
	
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
	keep father_id mother_id pregnum* start_date deliv_date any_* drug_preg cf_*
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
	
	translate "$Logdir\6_defining paternal exposure.smcl" "$Logdir\6_defining paternal exposure.pdf", replace
	
	erase "$Logdir\6_defining paternal exposure.smcl"
	
********************************************************************************