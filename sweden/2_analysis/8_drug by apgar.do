
/*******************************************************************************

	Logisitic regression models of Apgar score / Apgar < 7 by drug

	Author: Flo Martin

	Date: 03/10/2023

	Table generated by this script
	
		- apgar5 by drug.txt - continuous Apgar and Apgar < 7 by drug 
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\8_apgar5 by drug", name(apgar5_by_drug) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\apgar5 by drug.txt", write replace
	
	file write `myhandle' "" _tab "Apgar score < 7" _n

	file write `myhandle' "" _tab "Total" _tab "Marginal risk of Apgar score < 7" _tab "Adjusted* odds ratio" _tab "95% confidence interval" _tab "P-value" _n

	*use "$Deriveddir\maternal_analysis_dataset_reduced.dta", clear
	
	* Ensure complete case analysis
	*gen cc = 1 if birth_yr!=. & mother_age_cat!=. & mother_educ!=. & dispink5atbirth!=. & mother_birth_country_nonsverige!=. & mother_bmi_cat!=. & smoke_preg!=. & prev_sb_bin!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=.
	keep if cc==1
	
	forvalues n=0/11 {
	    
		file write `myhandle' "`n'"
	    
		count if drug_preg==`n' & apgar5!=.
		local total=`r(N)'
				
		logit apgar5_bin i.drug_preg birth_yr i.mother_age_cat i.mother_educ i.dispink5atbirth i.mother_birth_country_nonsverige i.mother_bmi_cat i.smoke_preg i.prev_sb_bin i.parity i.ap_12mo i.asm_12mo depression anxiety, or vce(cluster mother_id)
		
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
					
			file write `myhandle' _tab %9.0fc (`total') _tab %4.2f (`risk_percent') _tab ("1.00") _tab ("reference") _tab ("-") _n
					
		}
				
		else if `or'!=1 {
					
			file write `myhandle' _tab %9.0fc (`total') _tab %4.2f (`risk_percent') _tab %4.2f (`or') _tab %4.2f (`lci') ("-") %4.2f (`uci') _tab %4.3f (`p') _n
					
		}
	}
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close apgar5_by_drug
	
	translate "$Logdir\2_analysis\8_apgar5 by drug.smcl" "$Logdir\2_analysis\8_apgar5 by drug.pdf", replace
	
	erase "$Logdir\2_analysis\8_apgar5 by drug.smcl"
	
********************************************************************************/
