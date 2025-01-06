/*******************************************************************************

	Linear regression and logisitic regression models of birthweight / small for gestational age by drug

	Author: Flo Martin

	Date: 03/10/2023

	Table generated by this script
	
		- sga by drug.txt - birthweight percentile and small for gestational age by drug 
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\8_sga by drug", name(sga_by_drug) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\sga by drug.txt", write replace
	
	file write `myhandle' "" _tab "Birth weight (in grams)" _tab "Small for gestational age (SGA) (<10th percentile)" _n

	file write `myhandle' "" _tab "Total" _tab "Marginal mean birthweight" _tab "Adjusted mean difference" _tab "95% confidence interval" _tab "P-value" _tab "Total" _tab "Marginal risk of SGA" _tab "Adjusted odds ratio" _tab "95% confidence interval" _tab "P-value" _n

	use "$Deriveddir\maternal_analysis_dataset.dta", clear
	
	forvalues n=0/11 {
	    
		count if drug_preg==`n' & sga_pct!=.
		local total=`r(N)'
		
		file write `myhandle' "`n'" _tab %7.0fc (`total')
		
		regress birth_weight i.drug_preg birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo depression anxiety, or vce(cluster mother_id)
		
		margins `n'.drug_preg
		matrix mean_table = r(table)
		local mean=mean_table[1,1]
		disp `mean'
		
		lincom `n'.drug_preg
		local rd=`r(estimate)'
		local uci=`r(ub)'
		local lci=`r(lb)'
		local p=`r(p)'
		
		if `rd'==0 {
					
			file write `myhandle' _tab %4.2f (`mean') _tab ("0") _tab ("reference") _tab ("-")
					
		}
				
		else if `rd'!=0 {
					
			file write `myhandle' _tab %4.2f (`mean') _tab %4.2f (`rd') _tab %4.2f (`lci') (",") (" ") %4.2f (`uci') _tab %4.3f (`p')
					
		}
				
		logit sga_pct i.drug_preg birth_yr i.mother_age_cat i.mother_educ i.mother_birth_country_nonnorge i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo healthcare_util_12mo depression anxiety, or vce(cluster mother_id)
		
		margins `n'.drug_preg
		matrix risk_table = r(table)
		local risk=risk_table[1,1]
		disp `risk'
		local risk_percent=(`risk')*100
		
		lincom `n'.drug_preg, or 
		local or=`r(estimate)'
		local uci=`r(ub)'
		local lci=`r(lb)'
		local p=`r(p)'
		
		if `or'==1 {
					
			file write `myhandle' _tab %7.0fc (`total') _tab %4.2f (`risk_percent') _tab ("1.00") _tab ("reference") _tab ("-") _n
					
		}
				
		else if `or'!=1 {
					
			file write `myhandle' _tab %7.0fc (`total') _tab %4.2f (`risk_percent') _tab %4.2f (`or') _tab %4.2f (`lci') ("-") %4.2f (`uci') _tab %4.3f (`p') _n
					
		}
		
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close sga_by_drug
	
	translate "$Logdir\2_analysis\8_sga by drug.smcl" "$Logdir\2_analysis\8_sga by drug.pdf", replace
	
	erase "$Logdir\2_analysis\8_sga by drug.smcl"
	
********************************************************************************
