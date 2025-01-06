********************************************************************************

* Prescription data cleaning

* Author: Flo Martin 

* Date started: 21/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\4_cleaning prescription data", name(cleaning_prescription_data) replace
	
********************************************************************************	

	import excel "C:\Users\flma\OneDrive - Folkehelseinstituttet\Codelists\AD ATC codelist.xlsx", firstrow clear
	
	drop D E F G
	
	rename GROUP group
	rename ATCcode atc_code
	rename Name drugsubstance
	
	gen atc_code_format = substr(atc_code, 1, 7)
	tab atc_code_format
		
	drop atc_code
	rename atc_code_format atc_code
	
	save "$Codesdir\ad_codelist.dta", replace

* Load in the prescription data

	foreach var in maternal paternal {
	
		use "$Datadir\raw_`var'_prescriptions.dta", clear
		
		count
		
		tab atc_code
	
		gen atc_stem = substr(atc_code, 1, 4)
		tab atc_stem
		
		br if regexm(atc_stem, "QN") // nothing in here so drop them 
		drop if regexm(atc_stem, "QN")
		
		keep if atc_stem=="N06A" // keep only antidepressants for the exposure
		count
		
		gen atc_code_format = substr(atc_code, 1, 7)
		tab atc_code_format
		
		drop atc_code
		rename atc_code_format atc_code
		
********************************************************************************	

	* First, the prescription length - we have the dispensation date (prescr_start_date), pack size, total tablets, total defined daily dose, strength

		tab pack_size, m
		tab pack_size_units
		
			* BULK - Bulk-packages to repack as unit dose in pharmacies? Implementation guide FEST v3.0
			* DATOP 
			* ENDOS - A singular dose delivered at a time like a blister pack "Endose 28 stk" 28 pills in a blister pack
			* ENPAC - Doses delivered from a glass bottle for example
			* ML - liquid antidepressants in ml
			* MLAMP - I presume this and below are variations of liquid doses?
			* MLHGL
			* MLSETT
			* MLSPR
			* STK - this just means unit?
			
		tab total_ddd, m // the number of days prescribed as per the common data model documentation
		
			* Rounding makes sense so as to not have loads of half days
			
		gen total_ddd_rounded = round(total_ddd)
		replace total_ddd_rounded = ceil(total_ddd) if total_ddd_rounded==.
		tab total_ddd_rounded, m
		
			* Change implausible values to . - 0/minus numbers or >1,096 (3 years)? To check with pharmacoepi group
			
		replace total_ddd_rounded =. if total_ddd_rounded<1 | total_ddd_rounded>1096
		tab total_ddd_rounded, m // 3,818 missing values but only 0.11% - I can't fill these in right now because I don't have DDD - if I did I would have been able to use DDD and pack size to determine how many they would've taken each day and the compared that to the pack size they would have been given
		
		gen prescr_end_date = disp_date + total_ddd_rounded
		
********************************************************************************	

	merge m:1 atc_code using "$Codesdir\ad_codelist.dta", keep(3) nogen

	* Classes and individual products
	
		encode drugsubstance, gen(drugsubstance_num)
		tab drugsubstance_num, nol

		* Individual products - don't appear to have any of the tricyclics? To ask Maria
		
			tab atc_code, m // they all have an ATC code
			tab drugsubstance
			tab group
			
			* Selective-serotonin reuptake inhibitors
				tab drugsubstance if 		regexm(group, "N06AB")
				gen alaproclate = 1 if		regexm(drugsubstance, "alaproclate")
				gen citalopram = 1 if 		regexm(drugsubstance, "citalopram")
				gen escitalopram = 1 if		regexm(drugsubstance, "escitalopram")
				gen etoperidone = 1 if		regexm(drugsubstance, "etoperidone")
				gen fluoxetine = 1 if 		regexm(drugsubstance, "fluoxetine")
				gen fluvoxamine = 1 if		regexm(drugsubstance, "fluvoxamine")
				gen paroxetine = 1 if 		regexm(drugsubstance, "paroxetine")
				gen sertraline = 1 if 		regexm(drugsubstance, "sertraline")
				gen zimeldine = 1 if		regexm(drugsubstance, "zimeldine")
				
			* Non-selective monoamine reuptake inhibitors (aka TCAs)
				tab drugsubstance if 		regexm(group, "N06AA")
				gen amineptine = 1 if 		regexm(drugsubstance, "amineptine")
				gen amitriptyline = 1 if 	regexm(drugsubstance, "amitriptyline")
				gen amoxapine = 1 if 		regexm(drugsubstance, "amoxapine")
				gen butriptyline = 1 if 	regexm(drugsubstance, "butriptyline")
				gen clomipramine = 1 if 	regexm(drugsubstance, "clomipramine")
				gen desipramine = 1 if 		regexm(drugsubstance, "desipramine")
				gen dibenzepin = 1 if 		regexm(drugsubstance, "dibenzepin")
				gen dimetacrine = 1 if 		regexm(drugsubstance, "dimetacrine")
				gen dosulepin = 1 if 		regexm(drugsubstance, "dosulepin")
				gen doxepin = 1 if 			regexm(drugsubstance, "doxepin")
				gen imipramine = 1 if 		regexm(drugsubstance, "imipramine")
				gen iprindole = 1 if 		regexm(drugsubstance, "iprindole")
				gen lofepramine = 1 if 		regexm(drugsubstance, "lofepramine")
				gen maprotiline = 1 if 		regexm(drugsubstance, "maprotiline")
				gen melitracen = 1 if 		regexm(drugsubstance, "melitracen")
				gen nortriptyline = 1 if 	regexm(drugsubstance, "nortriptyline")
				gen opipramol = 1 if 		regexm(drugsubstance, "opipramol")
				gen protriptyline = 1 if 	regexm(drugsubstance, "protriptyline")
				gen quinupramine = 1 if 	regexm(drugsubstance, "quinupramine")
				gen trimipramine = 1 if 	regexm(drugsubstance, "trimipramine")
			
			* Monoamine oxidase inhibitors, non-selective
				tab drugsubstance if 		regexm(group, "N06AF")
				gen iproclozide = 1 if 		regexm(drugsubstance, "iproclozide")
				gen iproniazide = 1 if 		regexm(drugsubstance, "iproniazide")
				gen isocarboxazid = 1 if 	regexm(drugsubstance, "isocarboxazid")
				gen nialamide = 1 if 		regexm(drugsubstance, "nialamide")
				gen phenelzine = 1 if 		regexm(drugsubstance, "phenelzine")
				gen tranylcypromine = 1 if 	regexm(drugsubstance, "tranylcypromine")
			
			* Monoamine oxidase A inhibitors 
				tab drugsubstance if 		regexm(group, "N06AG")
				gen moclobemide = 1 if 		regexm(drugsubstance, "moclobemide")
				gen toloxatone = 1 if 		regexm(drugsubstance, "toloxatone")
			
			* Other antidepressants
				tab drugsubstance if 		regexm(group, "N06AX")
				gen agomelatine = 1 if 		regexm(drugsubstance, "agomelatine")
				gen bifemelane = 1 if 		regexm(drugsubstance, "bifemelane")
				gen brexanolone = 1 if 		regexm(drugsubstance, "brexanolone")
				gen desvenlafaxine = 1 if 	regexm(drugsubstance, "desvenlafaxine")
				gen duloxetine = 1 if 		regexm(drugsubstance, "duloxetine")
				gen esketamine = 1 if 		regexm(drugsubstance, "esketamine")
				gen geprione = 1 if 		regexm(drugsubstance, "geprione")
				gen levomilnacipran = 1 if 	regexm(drugsubstance, "levomilnacipran")
				gen medifoxamine = 1 if 	regexm(drugsubstance, "medifoxamine")
				gen mianserin = 1 if 		regexm(drugsubstance, "mianserin")
				gen milnacipran = 1 if 		regexm(drugsubstance, "milnacipran")
				gen minaprine = 1 if 		regexm(drugsubstance, "minaprine")
				gen mirtazapine = 1 if		regexm(drugsubstance, "mirtazapine")
				gen nefazodone = 1 if 		regexm(drugsubstance, "nefazodone")
				gen nomifensine = 1 if 		regexm(drugsubstance, "nomifensine")
				gen oxaflozane = 1 if 		regexm(drugsubstance, "oxflozane")
				gen oxitriptan = 1 if		regexm(drugsubstance, "oxitriptan")
				gen pivagabine = 1 if		regexm(drugsubstance, "pivagabine")
				gen reboxetine = 1 if		regexm(drugsubstance, "reboxetine")
				gen tianeptine = 1 if		regexm(drugsubstance, "tianeptine")
				gen trazodone = 1 if		regexm(drugsubstance, "trazodone")
				gen tryptophan = 1 if 		regexm(drugsubstance, "tryptophan")
				gen venlafaxine = 1 if 		regexm(drugsubstance, "venlafaxine")
				gen vilazodone = 1 if 		regexm(drugsubstance, "vilazodone")
				gen viloxazine = 1 if 		regexm(drugsubstance, "viloxazine")
				gen vortioxetine = 1 if		regexm(drugsubstance, "vortioxetine")
		
		* Classes coded up as per UK & Swedish data 
		
			gen ssri = 1 if fluoxetine==1 | citalopram==1 | paroxetine==1 | sertraline==1 | fluvoxamine==1 | escitalopram==1 | regexm(group, "N06AB")
			
			gen tca = 1 if amitriptyline==1 | amoxapine==1 | butriptyline==1 | clomipramine==1 | desipramine==1 | dosulepin==1 | doxepin==1 | imipramine==1 | lofepramine==1 | maprotiline==1 | nortriptyline==1 | protriptyline==1 | trimipramine==1 | regexm(group, "N06AA")
			
			gen snri = 1 if venlafaxine==1 | duloxetine==1 | reboxetine==1  
			
			gen other = 1 if ssri==. & tca==. & snri==.
		
			tab ssri 
			tab tca
			tab snri
			tab other
			
			gen class = 1 if ssri==1
			replace class = 2 if tca==1
			replace class = 3 if snri==1
			replace class = 4 if other==1
			
			label define class_lb 1"SSRI" 2"TCA" 3"SNRI" 4"Other"
			label values class class_lb
			tab class, m
			
			drop if prescr_end_date==.
			
		* Save the datasets with the new variables
		
		save "$Deriveddir\clean_`var'_antidepressants.dta", replace

	}
	
	use "$Deriveddir\clean_maternal_antidepressants.dta", clear
	rename person_id mother_id
	save "$Deriveddir\clean_maternal_antidepressants.dta", replace
	
	use "$Deriveddir\clean_paternal_antidepressants.dta", clear
	rename person_id father_id
	save "$Deriveddir\clean_paternal_antidepressants.dta", replace
	
********************************************************************************	

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_prescription_data
	
	translate "$Logdir\1_cleaning\4_cleaning prescription data.smcl" "$Logdir\1_cleaning\4_cleaning prescription data.pdf", replace
	
	erase "$Logdir\1_cleaning\4_cleaning prescription data.smcl"
	
********************************************************************************
