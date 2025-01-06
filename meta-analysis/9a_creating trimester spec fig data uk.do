

	tempname myhandle	
	file open `myhandle' using "$Graphdir\data\trimester specific data uk.txt", write replace
	
	file write `myhandle' "outcome" _tab "country" _tab "trimester" _tab "total" _tab "total_exp" _tab "total_unexp" _tab "or" _tab  "lci" _tab  "uci" _n

	use "$Datadir\primary_analysis_dataset.dta", clear

	gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_ethn!=. & imd_practice!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=. & CPRD_consultation_events_cat!=. & smoke_preg!=.
	
	keep if cc==1
	
	foreach outcome in stillborn preterm postterm sga_pct lga_pct { 
		
		replace t3 =. if gest_age_wks<27
		
		* Recode incident users after 37 weeks' unexposed for the preterm delivery modesls
		local y="`outcome'"
		if "`y'"=="preterm" {
		    
			replace t3=0 if flag_37wk_initiators==1
			tab t3
			
		}
		
		else {
		    
			tab any_preg
			
		}
		
		forvalues x=1/3 {
		    
			count if t`x'==1 & `outcome'==1
			local exp_n=`r(N)'
			
			count if t`x'==1 & `outcome'!=.
			local exp=`r(N)'
			
			count if t`x'==0 & `outcome'==1
			local unexp_n=`r(N)'
			
			count if t`x'==0 & `outcome'!=.
			local unexp=`r(N)'
		
			* Adjusted for all covariates
		
			logistic `outcome' i.t`x' birth_yr i.mother_age_cat i.mother_ethn i.smoke_preg i.grav_hist_sb i.imd_practice i.parity i.ap_12mo i.asm_12mo CPRD_consultation_events_cat depression anxiety, or
		
			local tot=`e(N)'
			lincom 1.t`x', or 
			local minadjor=`r(estimate)'
			local minadjuci=`r(ub)'
			local minadjlci=`r(lb)'

			file write `myhandle' "`outcome'" _tab "uk" _tab (`x') _tab (`tot') _tab %6.0fc (`exp_n') ("/") %6.0fc (`exp') _tab %6.0fc (`unexp_n') ("/") %7.0fc (`unexp') _tab (`minadjor') _tab (`minadjlci') _tab (`minadjuci') _n
			
		}
						
	}
	
	import delimited using "$Graphdir\data\trimester specific data uk.txt", clear
	
	replace outcome="sga" if outcome=="sga_pct"
	replace outcome="lga" if outcome=="lga_pct"
	
	save "$Graphdir\data\trimester specific data uk.dta", replace