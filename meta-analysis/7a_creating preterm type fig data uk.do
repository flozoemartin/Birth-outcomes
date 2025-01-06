
	tempname myhandle	
	file open `myhandle' using "$Graphdir\data\preterm type data_uk.txt", write replace
	
	file write `myhandle' "outcome" _tab "country" _tab "total" _tab "total_exp" _tab "total_unexp" _tab "or" _tab "lci" _tab "uci" _n
	
	foreach outcome in modpreterm verypreterm expreterm { 
	    
		use "$Datadir\primary_analysis_dataset.dta", clear
	
		* Ensure complete case analysis
		gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_ethn!=. & imd_practice!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=. & CPRD_consultation_events_cat!=. & smoke_preg!=.
		keep if cc==1
		
		file write `myhandle' "`outcome'" _tab "uk"
		
		* Recode incident users after 37 weeks' unexposed for the moderate preterm delivery models, 32 weeks for very models etc.
		local y="`outcome'"
		
		if "`y'"=="modpreterm" {
		    
			replace any_preg=0 if flag_37wk_initiators==1
			tab any_preg
			
		}
		
		else if "`y'"=="verypreterm" {
		    
			replace any_preg=0 if flag_32wk_initiators==1
			tab any_preg
			
		}
		
		else {
		    
			replace any_preg=0 if flag_28wk_initiators==1
			tab any_preg
			
		}
		
		* Counts for the table	
		count if `outcome'==1 & any_preg==1
		local exp_n=`r(N)' 
			
		count if any_preg==1 & `outcome'!=.
		local exp=`r(N)'
			
		count if `outcome'==1 & any_preg==0
		local unexp_n=`r(N)' 
			
		count if any_preg==0 & `outcome'!=.
		local unexp=`r(N)'
		
		logistic `outcome' i.any_preg birth_yr i.mother_age_cat i.mother_ethn i.smoke_preg i.grav_hist_sb i.imd_practice i.parity i.ap_12mo i.asm_12mo CPRD_consultation_events_cat depression anxiety, vce(cluster patid) or
		
		local tot=`e(N)'
		lincom 1.any_preg, or 
		local or=`r(estimate)'
		local uci=`r(ub)'
		local lci=`r(lb)'
		
		file write `myhandle' _tab (`tot') _tab %6.0fc (`exp_n') ("/") %6.0fc (`exp') _tab %6.0fc (`unexp_n') ("/") %7.0fc (`unexp') _tab (`or') _tab (`lci') _tab (`uci') _n
		
	}
	
	file close `myhandle'
	
	import delimited using "$Graphdir\data\preterm type data_uk.txt", clear
	
	save "$Graphdir\data\uk_counts_stratpreterm.dta", replace