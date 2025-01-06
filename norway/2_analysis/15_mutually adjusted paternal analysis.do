/*******************************************************************************

	Generate table showing the adjusted and mutually adjusted paternal negative control analyses for the supplement

	Author: Flo Martin

	Date: 11/12/2023

	Tables generated by this script
	
		- mutually adjusted pat.txt mutually adjusted paternal negative control logisitic regression models for each outcome
		- mutually adjusted pat data_no.txt unrounded estimates and counts for figure creation
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\15_mutually adjusted pat", name(mutually_adjusted_pat) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\mutually adjusted pat.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Total complete dads" _tab "Paternal exposed n/N (%)" _tab "Paternal unexposed n/N (%)" _tab "aOR" _tab "maOR" _n
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin { 
		
		use "$Deriveddir\paternal_analysis_dataset.dta", clear
	
		* Ensure complete case analysis
		gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_educ!=. & mother_birth_country_nonnorge!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & mat_depression!=. & mat_anxiety!=. & healthcare_util_12mo_cat!=. & pat_depression!=. & pat_anxiety!=. & father_educ!=.
		keep if cc==1
		
		* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
		local y="`outcome'"
		if "`y'"=="preterm" {
		    
			replace any_preg_pat=0 if flag_37wk_initiators==1
			tab any_preg_pat
			
		}
		
		else {
		    
			tab any_preg_pat
			
		}
		
		* Counts for the table
		count if `outcome'!=.
		local total=`r(N)'
			
		count if  `outcome'==1  & any_preg_pat==1
		local n_exp=`r(N)'
						
		count if  `outcome'==1  & any_preg_pat==0
		local n_unexp=`r(N)'
								
		count if `outcome'!=. & any_preg_pat==1
		local total_exp=`r(N)'
		local percent_exp=(`n_exp'/`total_exp')*100
						
		count if `outcome'!=. & any_preg_pat==0
		local total_unexp=`r(N)'
		local percent_unexp=(`n_unexp'/`total_unexp')*100
						
		file write `myhandle' _tab %7.0fc (`total') _tab %7.0fc (`n_exp') ("/") %7.0fc (`total_exp') (" (") %4.2f (`percent_exp') (")") _tab %7.0fc (`n_unexp') ("/") %7.0fc (`total_unexp') (" (") %4.2f (`percent_unexp') (")")
		
		* Unadjusted - paternal model
		
		logistic `outcome' i.any_preg_pat birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo mat_depression mat_anxiety pat_depression pat_anxiety father_educ, or vce(cluster father_id)
		
		lincom 1.any_preg_pat, or
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")")
		
		* Adjusted for all covariates - paternal model
		
		logistic `outcome' i.any_preg_pat birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo mat_depression mat_anxiety pat_depression pat_anxiety father_educ i.any_preg_mat, or vce(cluster father_id)
		
		local tot=`e(N)'
		lincom 1.any_preg_pat, or
		local minadjor=`r(estimate)'
		local minadjuci=`r(ub)'
		local minadjlci=`r(lb)'

		file write `myhandle' _tab %4.2f (`minadjor') (" (") %4.2f (`minadjlci') ("-") %4.2f (`minadjuci') (")") _n
						
	}
	
	file close `myhandle'
	
********************************************************************************

* FIGURE DATA	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\mutually adjusted pat data_no.txt", write replace
	
	file write `myhandle' "outcome" _tab "model" _tab "country" _tab "total" _tab "total_exp" _tab "total_unexp" _tab "or" _tab "lci" _tab "uci" _n
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin { 

		use "$Deriveddir\paternal_analysis_dataset.dta", clear
		
		gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_educ!=. & mother_birth_country_nonnorge!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & healthcare_util_12mo_cat!=. & mat_depression!=. & mat_anxiety!=. & pat_depression!=. & pat_anxiety!=. & father_educ!=.
		
		file write `myhandle' "`outcome'" _tab "paternal" _tab "no"
		
		* Adjusted for all covariates
		
		* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
		local y="`outcome'"
		if "`y'"=="preterm" {
		    
			replace any_preg_pat=0 if flag_37wk_initiators==1
			tab any_preg_pat
			
		}
		
		else {
		    
			tab any_preg_pat
			
		}
		
		* Counts for the table	
		count if `outcome'==1 & any_preg_pat==1
		local exp_n=`r(N)' 
			
		count if any_preg_pat==1 & `outcome'!=.
		local exp=`r(N)'
			
		count if `outcome'==1 & any_preg_pat==0
		local unexp_n=`r(N)' 
			
		count if any_preg_pat==0 & `outcome'!=.
		local unexp=`r(N)'
		
		logistic `outcome' i.any_preg_pat birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo mat_depression mat_anxiety pat_depression pat_anxiety father_educ i.any_preg_mat, or vce(cluster father_id)
		
		lincom 1.any_preg_pat, or 
		local or=`r(estimate)'
		local uci=`r(ub)'
		local lci=`r(lb)'
		
		file write `myhandle' _tab (`tot') _tab %6.0fc (`exp_n') ("/") %6.0fc (`exp') _tab %6.0fc (`unexp_n') ("/") %7.0fc (`unexp') _tab (`or') _tab (`lci') _tab (`uci') _n
		
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close mutually_adjusted_pat
	
	translate "$Logdir\2_analysis\15_mutually adjusted pat.smcl" "$Logdir\2_analysis\15_mutually adjusted pat.pdf", replace
	
	erase "$Logdir\2_analysis\15_mutually adjusted pat.smcl"
	
********************************************************************************