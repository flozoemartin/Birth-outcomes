********************************************************************************

* Exposure and outcome discordant counts in the sibling analysis

* Author: Flo Martin 

* Date: 08/04/24

********************************************************************************

* sibling discordance.txt

********************************************************************************

* Start logging

	log using "$Logdir\2_analysis\19_sibling discordance", name(sibling_discordance) replace

********************************************************************************

	use "$Deriveddir\sibling_analysis.dta", clear
	
	gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_educ!=. & mother_birth_country_nonnorge!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & healthcare_util_12mo_cat!=. & depression!=. & anxiety!=.
	keep if cc==1
	
	label define family_ex_labels 0"Concordant, all unexposed" 1"Discordant" 2"Concordant, all exposed"
	label define family_labels 0"Concordant, all unaffected" 1"Discordant" 2"Concordant, all affected"
	
	preserve
		
			keep mother_id preg_id any_preg
			sort mother_id preg_id
			
			cap drop pregnum
			
			bysort mother_id: egen pregnum = seq()
			bysort mother_id: egen max_pregs = max(pregnum)
			bysort mother_id: egen exposed_pregs = sum(any_preg)
			
			keep mother_id preg_id max_pregs exposed_pregs
			duplicates drop
			
			gen family_exposed =.
			replace family_exposed = 0 if exposed_pregs==0
			replace family_exposed = 1 if exposed_pregs>0 & exposed_pregs<max_pregs
			replace family_exposed = 2 if exposed_pregs==max_pregs
			
			label values family_`outcome' family_ex_labels
			
			tab family_exposed
			
			save "$Tempdatadir\family_exposure.dta", replace
			
		restore 
		
		foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
			
			preserve
		
				keep mother_id preg_id `outcome'
				sort mother_id preg_id
				
				drop if `outcome'==.
				
				bysort mother_id: egen pregnum = seq()
				bysort mother_id: egen max_pregs = max(pregnum)
				bysort mother_id: egen `outcome'_pregs = sum(`outcome')
				
				keep mother_id preg_id max_pregs `outcome'_pregs
				
				duplicates drop
				
				gen family_`outcome' =.
				replace family_`outcome' = 0 if `outcome'_pregs==0
				replace family_`outcome' = 1 if `outcome'_pregs>0 & `outcome'_pregs<max_pregs
				replace family_`outcome' = 2 if `outcome'_pregs==max_pregs
				
				label values family_`outcome' family_labels
				
				tab family_`outcome'
				
				save "$Tempdatadir\family_`outcome'.dta", replace
			
			restore 
			
		}
		
		use "$Deriveddir\sibling_analysis.dta", clear
		merge 1:1 mother_id preg_id using "$Tempdatadir\family_exposure.dta", nogen
		
		foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
		
			merge 1:1 mother_id preg_id using "$Tempdatadir\family_`outcome'.dta", nogen
			
		}
		
		drop if max_pregs==1 // no siblings
		
	tempname myhandle	
	file open `myhandle' using "$Tabledir\sibling discordance.txt", write replace
	
	file write `myhandle' "Outcome pattern" _tab "Exposure pattern" _tab "Stillbirth" _tab "Preterm delivery" _tab "Post-term delivery" _tab "SGA" _tab "LGA" _n
	
	file write `myhandle' "Concordant, all affected" _tab "Concordant, all unexposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==2 & family_exposed==0
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Concordant, all affected" _tab "Concordant, all exposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==2 & family_exposed==2
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Concordant, all affected" _tab "Discordant" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==2 & family_exposed==1
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Concordant, all unaffected" _tab "Concordant, all unexposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==0 & family_exposed==0
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Concordant, all unaffected" _tab "Concordant, all exposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==0 & family_exposed==2
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Concordant, all unaffected" _tab "Discordant" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==0 & family_exposed==1
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Discordant" _tab "Concordant, all unexposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==1 & family_exposed==0
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Discordant" _tab "Concordant, all exposed" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==1 & family_exposed==2
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
	file write `myhandle' _n
	
	file write `myhandle' "Discordant" _tab "Discordant" 
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin {
	
		count if family_`outcome'==1 & family_exposed==1
		local total=`r(N)'
		
		file write `myhandle' _tab %7.0fc (`total') 
		
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close sibling_discordance
	
	translate "$Logdir\2_analysis\19_sibling discordance.smcl" "$Logdir\2_analysis\19_sibling discordance.pdf", replace
	
	erase "$Logdir\2_analysis\19_sibling discordance.smcl"
	
********************************************************************************
