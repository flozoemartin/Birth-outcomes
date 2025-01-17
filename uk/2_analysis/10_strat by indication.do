/*******************************************************************************

	Generate table showing the primary analysis models of antidepressant use during pregnancy and the outcomes of interest

	Author: Flo Martin

	Date: 26/09/2023

	Table generated by this script
	
		- primary analysis.txt primary analysis logisitic regression models for each outcome
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\10_strat by indication", name(sens_strat_by_indic) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\sens strat by indication.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Total complete mums" _tab "Maternal exposed n/N (%)" _tab "Maternal unexposed n/N (%)" _tab "OR" _tab "aOR" _n
	
	foreach outcome in stillborn preterm postterm sga_pct lga_pct { 
		
		use "$Datadir\primary_analysis_dataset.dta", clear
		
		keep if depression==1 | anxiety==1
		
		* Ensure complete case analysis
		gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & imd_practice!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & CPRD_consultation_events_cat!=. & smoke_preg!=.
		keep if cc==1
		
		* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
		local y="`outcome'"
		if "`y'"=="preterm" {
		    
			replace any_preg=0 if flag_37wk_initiators==1
			tab any_preg
			
		}
		
		else {
		    
			tab any_preg
			
		}
			
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
			
		logistic `outcome' i.any_preg, vce(cluster patid) or
			
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'
						
		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") 
		
		* Adjusted for all covariates
		
		logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.smoke_preg i.grav_hist_sb i.imd_practice i.parity i.ap_12mo i.asm_12mo CPRD_consultation_events_cat, vce(cluster patid) or
		
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") _n
						
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close sens_strat_by_indic
	
	translate "$Logdir\2_analysis\10_strat by indication.smcl" "$Logdir\2_analysis\10_strat by indication.pdf", replace
	
	erase "$Logdir\2_analysis\10_strat by indication.smcl"
	
********************************************************************************
