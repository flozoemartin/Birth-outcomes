
********************************************************************************

* Cleaning the prescription data

* Author: Flo Martin

* Date: 23/01/2024

********************************************************************************

* Start logging

	log using "$Logdir\3_cleaning prescription data", name(cleaning_prescription_data) replace
	
********************************************************************************

* Load in the antidepressant codelist & pre-clean

	import excel "$Codesdir\AD ATC codelist.xlsx", firstrow clear
	
	drop D E F G
	
	rename GROUP group
	rename ATCcode atc_code
	rename Name drugsubstance
	
	gen atc_code_format = substr(atc_code, 1, 7)
	tab atc_code_format
		
	drop atc_code
	rename atc_code_format atc_code
	
	save "$Codesdir\ad_codelist.dta", replace
	
	
********************************************************************************

* Load in the antidepressant prescription data from the PDR

	foreach var in maternal paternal {
		
		use "$Datadir\exposure\n06a_pdr_`var'_compress.dta", clear
		
		count
		tab atc_code
		
		gen atc_code_format = substr(atc_code, 1, 7)
		tab atc_code_format
			
		drop atc_code
		rename atc_code_format atc_code
		
		tab total_ddd, m
		
		gen total_ddd_rounded = round(total_ddd)
		replace total_ddd_rounded = ceil(total_ddd) if total_ddd_rounded==.
		tab total_ddd_rounded, m
		
		replace total_ddd_rounded =. if total_ddd_rounded<1 | total_ddd_rounded>1096
		tab total_ddd_rounded, m
		
		gen prescr_end_date = disp_date + total_ddd_rounded
		
********************************************************************************

	* Add the information from the codelist
		
		merge m:1 atc_code using "$Codesdir\ad_codelist.dta", keep(3) nogen
		
		tab drugsubstance
		encode drugsubstance, gen(drugsubstance_num)
		tab drugsubstance_num, nol
		
		tab atc_code, m // they all have an ATC code
		tab drugsubstance
		tab group
		
		* Selective-serotonin reuptake inhibitors
				tab drugsubstance if 		regexm(group, "N06AB")
				gen alaproclate_pdr = 1 if		regexm(drugsubstance, "alaproclate")
				gen citalopram_pdr = 1 if 		regexm(drugsubstance, "citalopram")
				gen escitalopram_pdr = 1 if		regexm(drugsubstance, "escitalopram")
				gen etoperidone_pdr = 1 if		regexm(drugsubstance, "etoperidone")
				gen fluoxetine_pdr = 1 if 		regexm(drugsubstance, "fluoxetine")
				gen fluvoxamine_pdr = 1 if		regexm(drugsubstance, "fluvoxamine")
				gen paroxetine_pdr = 1 if 		regexm(drugsubstance, "paroxetine")
				gen sertraline_pdr = 1 if 		regexm(drugsubstance, "sertraline")
				gen zimeldine_pdr = 1 if		regexm(drugsubstance, "zimeldine")
				
			* Non-selective monoamine reuptake inhibitors (aka TCAs)
				tab drugsubstance if 		regexm(group, "N06AA")
				gen amineptine_pdr = 1 if 		regexm(drugsubstance, "amineptine")
				gen amitriptyline_pdr = 1 if 	regexm(drugsubstance, "amitriptyline")
				gen amoxapine_pdr = 1 if 		regexm(drugsubstance, "amoxapine")
				gen butriptyline_pdr = 1 if 	regexm(drugsubstance, "butriptyline")
				gen clomipramine_pdr = 1 if 	regexm(drugsubstance, "clomipramine")
				gen desipramine_pdr = 1 if 		regexm(drugsubstance, "desipramine")
				gen dibenzepin_pdr = 1 if 		regexm(drugsubstance, "dibenzepin")
				gen dimetacrine_pdr = 1 if 		regexm(drugsubstance, "dimetacrine")
				gen dosulepin_pdr = 1 if 		regexm(drugsubstance, "dosulepin")
				gen doxepin_pdr = 1 if 			regexm(drugsubstance, "doxepin")
				gen imipramine_pdr = 1 if 		regexm(drugsubstance, "imipramine")
				gen iprindole_pdr = 1 if 		regexm(drugsubstance, "iprindole")
				gen lofepramine_pdr = 1 if 		regexm(drugsubstance, "lofepramine")
				gen maprotiline_pdr = 1 if 		regexm(drugsubstance, "maprotiline")
				gen melitracen_pdr = 1 if 		regexm(drugsubstance, "melitracen")
				gen nortriptyline_pdr = 1 if 	regexm(drugsubstance, "nortriptyline")
				gen opipramol_pdr = 1 if 		regexm(drugsubstance, "opipramol")
				gen protriptyline_pdr = 1 if 	regexm(drugsubstance, "protriptyline")
				gen quinupramine_pdr = 1 if 	regexm(drugsubstance, "quinupramine")
				gen trimipramine_pdr = 1 if 	regexm(drugsubstance, "trimipramine")
			
			* Monoamine oxidase inhibitors, non-selective
				tab drugsubstance if 		regexm(group, "N06AF")
				gen iproclozide_pdr = 1 if 		regexm(drugsubstance, "iproclozide")
				gen iproniazide_pdr = 1 if 		regexm(drugsubstance, "iproniazide")
				gen isocarboxazid_pdr = 1 if 	regexm(drugsubstance, "isocarboxazid")
				gen nialamide_pdr = 1 if 		regexm(drugsubstance, "nialamide")
				gen phenelzine_pdr = 1 if 		regexm(drugsubstance, "phenelzine")
				gen tranylcypromine_pdr = 1 if 	regexm(drugsubstance, "tranylcypromine")
			
			* Monoamine oxidase A inhibitors 
				tab drugsubstance if 		regexm(group, "N06AG")
				gen moclobemide_pdr = 1 if 		regexm(drugsubstance, "moclobemide")
				gen toloxatone_pdr = 1 if 		regexm(drugsubstance, "toloxatone")
			
			* Other antidepressants
				tab drugsubstance if 		regexm(group, "N06AX")
				gen agomelatine_pdr = 1 if 		regexm(drugsubstance, "agomelatine")
				gen bifemelane_pdr = 1 if 		regexm(drugsubstance, "bifemelane")
				gen brexanolone_pdr = 1 if 		regexm(drugsubstance, "brexanolone")
				gen bupropion_pdr = 1 if 		regexm(drugsubstance, "bupropion")
				gen desvenlafaxine_pdr = 1 if 	regexm(drugsubstance, "desvenlafaxine")
				gen duloxetine_pdr = 1 if 		regexm(drugsubstance, "duloxetine")
				gen esketamine_pdr = 1 if 		regexm(drugsubstance, "esketamine")
				gen geprione_pdr = 1 if 		regexm(drugsubstance, "geprione")
				gen levomilnacipran_pdr = 1 if 	regexm(drugsubstance, "levomilnacipran")
				gen medifoxamine_pdr = 1 if 	regexm(drugsubstance, "medifoxamine")
				gen mianserin_pdr = 1 if 		regexm(drugsubstance, "mianserin")
				gen milnacipran_pdr = 1 if 		regexm(drugsubstance, "milnacipran")
				gen minaprine_pdr = 1 if 		regexm(drugsubstance, "minaprine")
				gen mirtazapine_pdr = 1 if		regexm(drugsubstance, "mirtazapine")
				gen nefazodone_pdr = 1 if 		regexm(drugsubstance, "nefazodone")
				gen nomifensine_pdr = 1 if 		regexm(drugsubstance, "nomifensine")
				gen oxaflozane_pdr = 1 if 		regexm(drugsubstance, "oxflozane")
				gen oxitriptan_pdr = 1 if		regexm(drugsubstance, "oxitriptan")
				gen pivagabine_pdr = 1 if		regexm(drugsubstance, "pivagabine")
				gen reboxetine_pdr = 1 if		regexm(drugsubstance, "reboxetine")
				gen tianeptine_pdr = 1 if		regexm(drugsubstance, "tianeptine")
				gen trazodone_pdr = 1 if		regexm(drugsubstance, "trazodone")
				gen tryptophan_pdr = 1 if 		regexm(drugsubstance, "tryptophan")
				gen venlafaxine_pdr = 1 if 		regexm(drugsubstance, "venlafaxine")
				gen vilazodone_pdr = 1 if 		regexm(drugsubstance, "vilazodone")
				gen viloxazine_pdr = 1 if 		regexm(drugsubstance, "viloxazine")
				gen vortioxetine_pdr = 1 if		regexm(drugsubstance, "vortioxetine")
		
		* Classes coded up as per UK & Swedish data 
		
			gen ssri_pdr = 1 if fluoxetine_pdr==1 | citalopram_pdr==1 | paroxetine_pdr==1 | sertraline_pdr==1 | fluvoxamine_pdr==1 | escitalopram_pdr==1 | regexm(group, "N06AB")
			
			gen tca_pdr = 1 if amitriptyline_pdr==1 | amoxapine_pdr==1 | butriptyline_pdr==1 | clomipramine_pdr==1 | desipramine_pdr==1 | dosulepin_pdr==1 | doxepin_pdr==1 | imipramine_pdr==1 | lofepramine_pdr==1 | maprotiline_pdr==1 | nortriptyline_pdr==1 | protriptyline_pdr==1 | trimipramine_pdr==1 | regexm(group, "N06AA")
			
			gen snri_pdr = 1 if venlafaxine_pdr==1 | duloxetine_pdr==1 | reboxetine_pdr==1  
			
			gen other_pdr = 1 if ssri_pdr==. & tca_pdr==. & snri_pdr==.
			
		tab ssri_pdr 
		tab tca_pdr
		tab snri_pdr
		tab other_pdr
		
		gen class_pdr = 1 if ssri_pdr==1
		replace class_pdr = 2 if tca_pdr==1
		replace class_pdr = 3 if snri_pdr==1
		replace class_pdr = 4 if other_pdr==1
				
		label define class_lb 1"SSRI" 2"TCA" 3"SNRI" 4"Other"
		label values class_pdr class_lb
		tab class_pdr, m
				
		drop if prescr_end_date==.
		
		* Save the datasets with the new variables
			
		save "$Deriveddir\clean_`var'_antidepressants_pdr.dta", replace

	}
	
********************************************************************************	

* Cleaning the self-report medication data from the MBR

	use "$Datadir\exposure\n06a_mbr_maternal_compress.dta", clear
	
	bysort mother_id (deliv_date): egen seq=seq()
	tab seq
	summ seq
	local seq=`r(max)'
	
	count
	tab atc_code, m
		
	gen atc_code_format = substr(atc_code, 1, 7)
	tab atc_code_format
			
	drop atc_code
	rename atc_code_format atc_code
	
	merge m:1 atc_code using "$Codesdir\ad_codelist.dta", keep(3) nogen // some have codes that are not the codelist - mistyped?
	
	tab drugsubstance
	encode drugsubstance, gen(drugsubstance_num)
	tab drugsubstance_num, nol
		
	tab atc_code, m // they all have an ATC code
	tab drugsubstance
	tab group
	
	forvalues x=1/`seq' {
		
		preserve
		
			keep if seq==`x'
		
		* Selective-serotonin reuptake inhibitors
				tab drugsubstance if 		regexm(group, "N06AB")
				gen alaproclate_mbr = 1 if		regexm(drugsubstance, "alaproclate")
				gen citalopram_mbr = 1 if 		drugsubstance_num==4
				gen escitalopram_mbr = 1 if		regexm(drugsubstance, "escitalopram")
				gen etoperidone_mbr = 1 if		regexm(drugsubstance, "etoperidone")
				gen fluoxetine_mbr = 1 if 		regexm(drugsubstance, "fluoxetine")
				gen fluvoxamine_mbr = 1 if		regexm(drugsubstance, "fluvoxamine")
				gen paroxetine_mbr = 1 if 		regexm(drugsubstance, "paroxetine")
				gen sertraline_mbr = 1 if 		regexm(drugsubstance, "sertraline")
				gen zimeldine_mbr = 1 if		regexm(drugsubstance, "zimeldine")
				
			* Non-selective monoamine reuptake inhibitors (aka TCAs)
				tab drugsubstance if 		regexm(group, "N06AA")
				gen amineptine_mbr = 1 if 		regexm(drugsubstance, "amineptine")
				gen amitriptyline_mbr = 1 if 	regexm(drugsubstance, "amitriptyline")
				gen amoxapine_mbr = 1 if 		regexm(drugsubstance, "amoxapine")
				gen butriptyline_mbr = 1 if 	regexm(drugsubstance, "butriptyline")
				gen clomipramine_mbr = 1 if 	regexm(drugsubstance, "clomipramine")
				gen desipramine_mbr = 1 if 		regexm(drugsubstance, "desipramine")
				gen dibenzepin_mbr = 1 if 		regexm(drugsubstance, "dibenzepin")
				gen dimetacrine_mbr = 1 if 		regexm(drugsubstance, "dimetacrine")
				gen dosulepin_mbr = 1 if 		regexm(drugsubstance, "dosulepin")
				gen doxepin_mbr = 1 if 			regexm(drugsubstance, "doxepin")
				gen imipramine_mbr = 1 if 		drugsubstance_num==10
				gen iprindole_mbr = 1 if 		regexm(drugsubstance, "iprindole")
				gen lofepramine_mbr = 1 if 		regexm(drugsubstance, "lofepramine")
				gen maprotiline_mbr = 1 if 		regexm(drugsubstance, "maprotiline")
				gen melitracen_mbr = 1 if 		regexm(drugsubstance, "melitracen")
				gen nortriptyline_mbr = 1 if 	regexm(drugsubstance, "nortriptyline")
				gen opipramol_mbr = 1 if 		regexm(drugsubstance, "opipramol")
				gen protriptyline_mbr = 1 if 	regexm(drugsubstance, "protriptyline")
				gen quinupramine_mbr = 1 if 	regexm(drugsubstance, "quinupramine")
				gen trimipramine_mbr = 1 if 	regexm(drugsubstance, "trimipramine")
			
			* Monoamine oxidase inhibitors, non-selective
				tab drugsubstance if 		regexm(group, "N06AF")
				gen iproclozide_mbr = 1 if 		regexm(drugsubstance, "iproclozide")
				gen iproniazide_mbr = 1 if 		regexm(drugsubstance, "iproniazide")
				gen isocarboxazid_mbr = 1 if 	regexm(drugsubstance, "isocarboxazid")
				gen nialamide_mbr = 1 if 		regexm(drugsubstance, "nialamide")
				gen phenelzine_mbr = 1 if 		regexm(drugsubstance, "phenelzine")
				gen tranylcypromine_mbr = 1 if 	regexm(drugsubstance, "tranylcypromine")
			
			* Monoamine oxidase A inhibitors 
				tab drugsubstance if 		regexm(group, "N06AG")
				gen moclobemide_mbr = 1 if 		regexm(drugsubstance, "moclobemide")
				gen toloxatone_mbr = 1 if 		regexm(drugsubstance, "toloxatone")
			
			* Other antidepressants
				tab drugsubstance if 		regexm(group, "N06AX")
				gen agomelatine_mbr = 1 if 		regexm(drugsubstance, "agomelatine")
				gen bifemelane_mbr = 1 if 		regexm(drugsubstance, "bifemelane")
				gen brexanolone_mbr = 1 if 		regexm(drugsubstance, "brexanolone")
				gen bupropion_mbr = 1 if 		regexm(drugsubstance, "bupropion")
				gen desvenlafaxine_mbr = 1 if 	regexm(drugsubstance, "desvenlafaxine")
				gen duloxetine_mbr = 1 if 		regexm(drugsubstance, "duloxetine")
				gen esketamine_mbr = 1 if 		regexm(drugsubstance, "esketamine")
				gen gepirone_mbr = 1 if 		regexm(drugsubstance, "gepirone")
				gen levomilnacipran_mbr = 1 if 	regexm(drugsubstance, "levomilnacipran")
				gen medifoxamine_mbr = 1 if 	regexm(drugsubstance, "medifoxamine")
				gen mianserin_mbr = 1 if 		regexm(drugsubstance, "mianserin")
				gen milnacipran_mbr = 1 if 		regexm(drugsubstance, "milnacipran")
				gen minaprine_mbr = 1 if 		regexm(drugsubstance, "minaprine")
				gen mirtazapine_mbr = 1 if		regexm(drugsubstance, "mirtazapine")
				gen nefazodone_mbr = 1 if 		regexm(drugsubstance, "nefazodone")
				gen nomifensine_mbr = 1 if 		regexm(drugsubstance, "nomifensine")
				gen oxaflozane_mbr = 1 if 		regexm(drugsubstance, "oxflozane")
				gen oxitriptan_mbr = 1 if		regexm(drugsubstance, "oxitriptan")
				gen pivagabine_mbr = 1 if		regexm(drugsubstance, "pivagabine")
				gen reboxetine_mbr = 1 if		regexm(drugsubstance, "reboxetine")
				gen tianeptine_mbr = 1 if		regexm(drugsubstance, "tianeptine")
				gen trazodone_mbr = 1 if		regexm(drugsubstance, "trazodone")
				gen tryptophan_mbr = 1 if 		regexm(drugsubstance, "tryptophan")
				gen venlafaxine_mbr = 1 if 		regexm(drugsubstance, "venlafaxine")
				gen vilazodone_mbr = 1 if 		regexm(drugsubstance, "vilazodone")
				gen viloxazine_mbr = 1 if 		regexm(drugsubstance, "viloxazine")
				gen vortioxetine_mbr = 1 if		regexm(drugsubstance, "vortioxetine")
				
				keep mother_id deliv_date *_mbr
				
			save "$Deriveddir\clean_maternal_antidepressants_mbr_`x'.dta", replace
			
		restore
		
	}
	
	use "$Deriveddir\clean_maternal_antidepressants_mbr_1.dta", clear
	
	forvalues x=2/`seq' {
		
		merge 1:1 mother_id deliv_date using "$Deriveddir\clean_maternal_antidepressants_mbr_`x'.dta", update replace nogen
		
	}
	
	egen drugs = rowtotal(*_mbr)
	tab drugs
	
	drop if drugs==0 // drop bupropion as not included in the present study
	
	* Classes coded up as per UK & Swedish data 
		
		gen ssri_mbr = 1 if fluoxetine_mbr==1 | citalopram_mbr==1 | paroxetine_mbr==1 | sertraline_mbr==1 | fluvoxamine_mbr==1 | escitalopram_mbr==1
			
		gen tca_mbr = 1 if amitriptyline_mbr==1 | amoxapine_mbr==1 | butriptyline_mbr==1 | clomipramine_mbr==1 | desipramine_mbr==1 | dosulepin_mbr==1 | doxepin_mbr==1 | imipramine_mbr==1 | lofepramine_mbr==1 | maprotiline_mbr==1 | nortriptyline_mbr==1 | protriptyline_mbr==1 | trimipramine_mbr==1
			
		gen snri_mbr = 1 if venlafaxine_mbr==1 | duloxetine_mbr==1 | reboxetine_mbr==1  
			
		gen other_mbr = 1 if ssri_mbr==. & tca_mbr==. & snri_mbr==.
			
		tab ssri_mbr 
		tab tca_mbr
		tab snri_mbr
		tab other_mbr
			
		gen class_mbr = 1 if ssri_mbr==1
		replace class_mbr = 2 if tca_mbr==1
		replace class_mbr = 3 if snri_mbr==1
		replace class_mbr = 4 if other_mbr==1
					
		label values class_mbr class_lb
		tab class_mbr, m
			
		gen any_preg_mbr = 1 
			
		save "$Deriveddir\clean_maternal_antidepressants_mbr.dta", replace
	
********************************************************************************	

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_prescription_data
	
	translate "$Logdir\3_cleaning prescription data.smcl" "$Logdir\3_cleaning prescription data.pdf", replace
	
	erase "$Logdir\3_cleaning prescription data.smcl"
	
********************************************************************************
	