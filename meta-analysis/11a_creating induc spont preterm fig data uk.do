
/*******************************************************************************

	Generate data for the Norwegian family analyses figure

	Author: Flo Martin

	Date: 27/11/2023

	Table generated by this script
	
		- drug_figure_no.pdf drug-specific analyses results in Norway
		
*******************************************************************************/

* Start logging

	log using "$Logdir\3_figures\11a_spont and induc preterm fig data uk", name(spont_induc_pt_fig_data_uk) replace
	
********************************************************************************	

* Set up the dataframe elements

	tempname myhandle	
	file open `myhandle' using "$Graphdir\data\spont induc pt data_uk.txt", write replace
	
	file write `myhandle' "outcome" _tab "country" _tab "total" _tab "total_exp" _tab "total_unexp" _tab "or" _tab "lci" _tab "uci" _n
	
	use "$Datadir\primary_analysis_dataset.dta", clear
		
	replace any_preg=0 if flag_37wk_initiators==1
	tab any_preg
	
	gen cc = 1 if birth_yr_cat!=. & mother_age_cat!=. & mother_ethn!=. & imd_practice!=. & parity!=. & ap_12mo!=. & asm_12mo!=. & depression!=. & anxiety!=. & CPRD_consultation_events_cat!=. & smoke_preg!=.
	keep if cc==1
	
	foreach outcome in spont_preterm induc_preterm {
	    
		* Maternal primary analysis
		
		file write `myhandle' "`outcome'" _tab "uk"
		
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
	
* Get sibling analysis counts from the sibling analysis table (from tabcount)

	import delimited using "$Graphdir\data\spont induc pt data_uk.txt", varnames(1) clear
	
	save "$Graphdir\data\spont induc pt data_uk.dta", replace
	
	erase "$Graphdir\data\spont induc pt data_uk.txt"
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close spont_induc_pt_fig_data_uk
	
	translate "$Logdir\3_figures\11a_spont and induc preterm fig data uk.smcl" "$Logdir\3_figures\11a_spont and induc preterm fig data uk.pdf", replace
	
	erase "$Logdir\3_figures\11a_spont and induc preterm fig data uk.smcl"
	
********************************************************************************	