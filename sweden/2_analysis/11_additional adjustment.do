
/*******************************************************************************

	Sensitivity analysis of additionally adjusting for country of birth and smoking at the beginning of pregnancy

	Author: Flo Martin

	Date: 03/10/2023

	Table generated by this script
	
		- sens additional adjustment.txt - additionally adjusting 
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\11_sens additional adjustment", name(sens_additional_adjustment) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\sens additional adjustment.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Total" _tab "Exposed n/N (%)" _tab "Unexposed n/N (%)" _tab "OR" _tab  "aOR*" _n

	use "$Deriveddir\maternal_analysis_dataset_reduced.dta", clear

	gen cc_eth = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_educ!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=. & mother_birth_country_nonsverige!=. & smoke_beg!=. & prev_sb_bin!=. & mother_bmi_cat!=.
	
	keep if cc_eth==1
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin { 
		
			* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
			local y="`outcome'"
			if "`y'"=="preterm" {
				
				gen any_preg_preterm = 1 if any_preg==1
				replace any_preg_preterm = 0 if any_preg==0
				replace any_preg_preterm=0 if flag_37wk_initiators==1
				tab any_preg_preterm
				
				count if `outcome'!=.
				local total=`r(N)'
				
				count if  `outcome'==1  & any_preg_preterm==1
				local n_exp=`r(N)'
							
				count if  `outcome'==1  & any_preg_preterm==0
				local n_unexp=`r(N)'
									
				count if `outcome'!=. & any_preg_preterm==1
				local total_exp=`r(N)'
				local percent_exp=(`n_exp'/`total_exp')*100
							
				count if `outcome'!=. & any_preg_preterm==0
				local total_unexp=`r(N)'
				local percent_unexp=(`n_unexp'/`total_unexp')*100
				
			}
			
			else {
				
				tab any_preg
				
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
				
			}
						
		file write `myhandle' "`outcome'" _tab %9.0fc (`total') _tab %7.0fc (`n_exp') ("/") %7.0fc (`total_exp') (" (") %4.2f (`percent_exp') (")") _tab %7.0fc (`n_unexp') ("/") %9.0fc (`total_unexp') (" (") %4.2f (`percent_unexp') (")")
								
		* Unadjusted
		
		if "`y'"=="preterm" {
			
			logistic `outcome' i.any_preg_preterm, vce(cluster mother_id) or
			
			local tot=`e(N)'
			lincom 1.any_preg_preterm, or 
			local minadjor=`r(estimate)'
			local minadjuci=`r(ub)'
			local minadjlci=`r(lb)'
			
		}
		
		else {
			
			logistic `outcome' i.any_preg, vce(cluster mother_id) or
			
			local tot=`e(N)'
			lincom 1.any_preg, or 
			local minadjor=`r(estimate)'
			local minadjuci=`r(ub)'
			local minadjlci=`r(lb)'
			
		}
						
		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") 
		
		* Adjusted for all covariates + smoking + country of birth
		
		if "`y'"=="preterm" {
		
			logistic `outcome' i.any_preg_preterm birth_yr i.mother_age_cat i.mother_educ i.parity i.ap_12mo i.asm_12mo depression anxiety mother_birth_country_nonsverige i.smoke_beg i.prev_sb_bin i.mother_bmi_cat, or vce(cluster mother_id)
		
			local tot=`e(N)'
			lincom 1.any_preg_preterm, or  
			local minadjor=`r(estimate)'
			local minadjuci=`r(ub)'
			local minadjlci=`r(lb)'
			
		}
		
		else {
			
			logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.mother_educ i.parity i.ap_12mo i.asm_12mo depression anxiety mother_birth_country_nonsverige i.smoke_beg i.prev_sb_bin i.mother_bmi_cat, or vce(cluster mother_id)
		
			local tot=`e(N)'
			lincom 1.any_preg, or  
			local minadjor=`r(estimate)'
			local minadjuci=`r(ub)'
			local minadjlci=`r(lb)'
			
		}

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") _n
						
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close sens_additional_adjustment
	
	translate "$Logdir\2_analysis\11_sens additional adjustment.smcl" "$Logdir\2_analysis\11_sens additional adjustment.pdf", replace
	
	erase "$Logdir\2_analysis\11_sens additional adjustment.smcl"
	
********************************************************************************