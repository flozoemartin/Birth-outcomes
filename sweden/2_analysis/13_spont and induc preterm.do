
/*******************************************************************************

	Generate table showing spontaneous and induced preterm compared to term delivery

	Author: Flo Martin

	Date: 04/12/2023

	Table generated by this script
	
		- spontaneous and induced preterm.txt supplementary analysis logisitic regression models for comparing spontaneous and induced preterm delivery with term deliveries
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\13_spontaneous and induced preterm", name(spontaneous_and_induced_preterm) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\spontaneous and induced preterm.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Total" _tab "Exposed n/N (%)" _tab "Unexposed n/N (%)" _tab "OR" _tab "aOR*" _n
	
	use "$Deriveddir\maternal_analysis_dataset_reduced.dta", clear
	
	* Ensure complete case analysis
	gen cc = 1 if birth_yr!=. & mother_age_cat!=. & mother_educ!=. & dispink5atbirth!=. & mother_birth_country_nonsverige!=. & mother_bmi_cat!=. & smoke_beg!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=.
	keep if cc==1
		
	* Recode new users after risk period as unexposed
	
	recode any_preg 1=0 if flag_37wk_initiators==1
	
	foreach outcome in spont_preterm induc_preterm { 
			
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
						
		file write `myhandle' "`outcome'" _tab %9.0fc (`total') _tab %7.0fc (`n_exp') ("/") %7.0fc (`total_exp') (" (") %4.2f (`percent_exp') (")") _tab %7.0fc (`n_unexp') ("/") %9.0fc (`total_unexp') (" (") %4.2f (`percent_unexp') (")")
								
		* Unadjusted	
			
		logistic `outcome' i.any_preg, vce(cluster mother_id) or
			
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'
						
		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") 
		
		* Adjusted for all covariates
		
		logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.mother_educ i.dispink5atbirth i.mother_birth_country_nonsverige i.mother_bmi_cat i.smoke_beg i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo depression anxiety, vce(cluster mother_id) or
		
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") _n
						
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close spontaneous_and_induced_preterm
	
	translate "$Logdir\2_analysis\13_spontaneous and induced preterm.smcl" "$Logdir\2_analysis\13_spontaneous and induced preterm.pdf", replace
	
	erase "$Logdir\2_analysis\13_spontaneous and induced preterm.smcl"
	
********************************************************************************