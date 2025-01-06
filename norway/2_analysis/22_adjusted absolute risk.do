********************************************************************************

* Adjusted absolute risk for all of the outcomes

* Author: Flo Martin 

* Date: 08/04/24

********************************************************************************

* adjusted_absolute_risk.txt

********************************************************************************

* Start logging

	log using "$Logdir\2_analysis\22_adjusted absolute risk", name(sibling_discordance) replace

********************************************************************************

  tempname myhandle	
	file open `myhandle' using "$Tabledir\adjusted_absolute_risk.txt", write replace
	
	file write `myhandle' "Outcome" _tab "Exposed 1/0" _tab "risk" _tab "lci" _tab "uci" _n
	
	use "$Deriveddir\maternal_analysis_dataset.dta", clear
	
	* Ensure complete case analysis
	gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_educ!=. & mother_birth_country_nonnorge!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & healthcare_util_12mo_cat!=. & depression!=. & anxiety!=. 
	keep if cc==1
	
	foreach outcome in stillborn neonatal_death preterm postterm sga_pct lga_pct apgar5_bin { 
		
		* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
		local y="`outcome'"
		if "`y'"=="preterm" {
		    
			gen any_preg_preterm=1 if any_preg==1
			replace any_preg_preterm=0 if any_preg==0
			replace any_preg_preterm=0 if flag_37wk_initiators==1
			tab any_preg_preterm
			
		}
		
		else {
		    
			tab any_preg
				
		}
						
		file write `myhandle' "`outcome'"
		
		* Adjusted for all covariates
		
		forvalues x=0/1 {
		
			if "`y'"=="preterm" {
			
				logistic `outcome' i.any_preg_preterm birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo depression anxiety, vce(cluster mother_id) or
				
				margins `x'.any_preg_preterm
				matrix risk_table = r(table)
				local risk=risk_table[1,1]
				local lci=risk_table[5,1]
				local uci=risk_table[6,1]
				local risk_percent=(`risk')*100
				local risk_lci=(`lci')*100
				local risk_uci=(`uci')*100
				
				lincom `n'.drug_preg, or 
				local or=`r(estimate)'
				local uci=`r(ub)'
				local lci=`r(lb)'
				local p=`r(p)'
				
			}
			
			else {
				
				logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo depression anxiety, vce(cluster mother_id) or
			
				margins `x'.any_preg
				matrix risk_table = r(table)
				local risk=risk_table[1,1]
				local lci=risk_table[5,1]
				local uci=risk_table[6,1]
				local risk_percent=(`risk')*100
				local risk_lci=(`lci')*100
				local risk_uci=(`uci')*100
				
			}

			file write `myhandle' _tab (`x') _tab (`risk_percent') _tab (`risk_lci') _tab (`risk_uci') _n
			
		}
	
	}
	
	file close `myhandle'

********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close sibling_discordance
	
	translate "$Logdir\2_analysis\22_adjusted absolute risk.smcl" "$Logdir\2_analysis\22_adjusted absolute risk_sibling discordance.pdf", replace
	
	erase "$Logdir\2_analysis\22_adjusted absolute risk_sibling discordance.smcl"
	
********************************************************************************
