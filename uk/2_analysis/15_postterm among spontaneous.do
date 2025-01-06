/*******************************************************************************

	Generate table showing the post-term analysis among those whose labour started spontaneously

	Author: Flo Martin

	Date: 11/12/2023

	Table generated by this script
	
		- postterm among spontaneous.txt supplementary analysis logisitic regression model for post-term delivery among those who delivered spontaneously
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\15_postterm among spontaneous", name(postterm_among_spontaneous) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\postterm among spontaneous.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Total" _tab "Exposed n/N (%)" _tab "Unexposed n/N (%)" _tab "OR" _tab "aOR*" _n
	
	foreach outcome in postterm { 
	    
		use "$Datadir\primary_analysis_dataset.dta", clear
	
		* Ensure complete case analysis
		gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & imd_practice!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=. & CPRD_consultation_events_cat!=. & smoke_preg!=.
		keep if cc==1
			
		* Counts for the table	
		count if `outcome'!=.
		local total=`r(N)'
			
		count if  `outcome'==1  & any_preg==1
		local n_exp=`r(N)'
						
		count if  `outcome'==1  & any_preg==0
		local n_unexp=`r(N)'
								
		count if `outcome'!=. & any_preg==1
		local total_exp=`r(N)'
		local percent_exp=(`n_exp'/`total_exp')*100
						
		count if `outcome'!=. & any_preg==0
		local total_unexp=`r(N)'
		local percent_unexp=(`n_unexp'/`total_unexp')*100
						
		file write `myhandle' "`outcome'" _tab %7.0fc (`total') _tab %7.0fc (`n_exp') ("/") %7.0fc (`total_exp') (" (") %4.2f (`percent_exp') (")") _tab %7.0fc (`n_unexp') ("/") %7.0fc (`total_unexp') (" (") %4.2f (`percent_unexp') (")")
								
		* Unadjusted	
			
		logistic `outcome' i.any_preg if spont_labour==1, vce(cluster patid) or
			
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'
						
		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") 
		
		* Adjusted for all covariates
		
		logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.smoke_preg i.smoke_preg i.grav_hist_sb i.imd_practice i.parity i.ap_12mo i.asm_12mo CPRD_consultation_events_cat depression anxiety if spont_labour==1, vce(cluster patid) or
		
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") _n
						
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close postterm_among_spontaneous
	
	translate "$Logdir\2_analysis\15_postterm among spontaneous.smcl" "$Logdir\2_analysis\15_postterm among spontaneous.pdf", replace
	
	erase "$Logdir\2_analysis\15_postterm among spontaneous.smcl"
	
********************************************************************************