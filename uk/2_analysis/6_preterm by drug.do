/*******************************************************************************

	Linear regression and logisitic regression models of gestational age / preterm delivery by drug

	Author: Flo Martin

	Date: 02/07/2024

	Table generated by this script
	
		- preterm by drug.txt - gestational age and preterm delivery by drug
		
*******************************************************************************/

* Start logging

	log using "$Logdir\2_analysis\6_preterm by drug", name(preterm_by_drug) replace
	
********************************************************************************	

	tempname myhandle	
	file open `myhandle' using "$Tabledir\preterm by drug.txt", write replace
	
	file write `myhandle' "" _tab "Gestational weeks" _tab "Prematurity (delivery <37 weeks' gestation)" _n

	file write `myhandle' "" _tab "Total" _tab "Marginal mean gestational age" _tab "Adjusted* mean difference" _tab "95% confidence interval" _tab "P-value" _tab "Total" _tab "Marginal risk of prematurity" _tab "Adjusted* odds ratio" _tab "95% confidence interval" _tab "P-value" _n

	use "$Datadir\primary_analysis_dataset.dta", clear
	
	forvalues n=0/11 {
		
		replace drug_preg=0 if flag_37wk_initiators==1
	    
		count if drug_preg==`n' & preterm!=.
		local total=`r(N)'
		
		file write `myhandle' "`n'" _tab %7.0fc (`total')
		
		regress gest_age_wks i.drug_preg birth_yr i.mother_age_cat i.mother_ethn i.smoke_preg i.grav_hist_sb i.imd_practice i.parity i.asm_12mo i.ap_12mo CPRD_consultation_events_cat depression anxiety, vce(cluster patid)
		
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
				
		logit preterm i.drug_preg birth_yr i.mother_age_cat i.smoke_preg i.mother_ethn i.grav_hist_sb i.imd_practice i.parity i.asm_12mo i.ap_12mo CPRD_consultation_events_cat depression anxiety, or vce(cluster patid)
		
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

	log close preterm_by_drug
	
	translate "$Logdir\2_analysis\6_preterm by drug.smcl" "$Logdir\2_analysis\6_preterm by drug.pdf", replace
	
	erase "$Logdir\2_analysis\6_preterm by drug.smcl"
	
********************************************************************************
