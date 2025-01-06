

cd "$Graphdir"

* Make the maternal meta-analysis figure for supplementary material and generate the summary effect estimate for the primary figure

	use "$Graphdir\data\strat preterm analyses data_all3.dta", clear
	
	append using "$Graphdir\data\spont induc pt analyses data_all3.dta"
	
	replace outcome = "d_spont_preterm" if outcome== "a_spont_preterm"
	replace outcome = "e_induc_preterm" if outcome== "b_induc_preterm"
	
	gen logor = log(or)
	gen loglci = log(lci)
	gen loguci = log(uci)
	
	metan logor loglci loguci, eform by(outcome) lcols(outcome total_exp total_unexp) saving(stratpreterm_ma, replace)
	
	* Use the data from metan to make a nicer forest plot
	
	use stratpreterm_ma, clear
	
	bys _BY _USE : egen grp_wt = sum(_WT)
	gen pct_grp_wt = 100 * _WT / grp_wt
	
	drop _WT
	rename pct_grp_wt _WT
	
	drop if _USE>=4 & _USE<6
	*drop if _BY==2 & _USE==3
	
	replace _LABELS = "Moderate-to-late preterm delivery" if _LABELS=="a_modpreterm"
	replace _LABELS = "Very preterm delivery" if _LABELS=="b_verypreterm"
	replace _LABELS = "Extremely preterm delivery" if _LABELS=="c_expreterm"
	
	replace _LABELS = "UK" if _STUDY==1 | _STUDY==4 | _STUDY==7 
	replace _LABELS = "Norway" if _STUDY==2 | _STUDY==5 | _STUDY==8
	replace _LABELS = "Sweden" if _STUDY==3 | _STUDY==6 | _STUDY==9
	
	replace _LABELS = `"{bf:"' + _LABELS + `"}"' if _USE==0
	label variable _LABELS `"`"{bf: Types of preterm delivery}"'"'
	label variable total_exp `"`"{bf: Exposed n/N}"'"'
	label variable total_unexp `"`"{bf: Unexposed n/N}"'"'
	label variable _WT `"`"{bf: Weight}"' `"(%)"'"'
	
	format _ES %4.1fc
	format _WT %4.1fc
	
	*drop if _USE==1
	
	gen country=1 if _LABELS=="UK"
	replace country=2 if _LABELS=="Norway"
	replace country=3 if _LABELS=="Sweden"

	forestplot, eform lcols(total_exp total_unexp) effect("{bf}Odds ratio") null(1) olineopts(lcolor(none)) nlineopts(lcolor(cranberry) lpattern(dash)) xlabel(0.5(0.5)2.5) title("{bf}Types of preterm delivery sensitivity analysis", size(small)) ///
	plotid(country, list) point1opts(msymbol(triangle) msize(0.75)) point2opts(msymbol(circle) msize(0.75)) point4opts(msymbol(diamond) msize(0.75)) textsize(105) ///
	name(stratpreterm_ma, replace)
	
	cd "$Graphdir"
	graph export stratpreterm_ma.pdf, replace
	
	replace _LABELS = "UK" if _STUDY==1 | _STUDY==4 | _STUDY==7 | _STUDY==10 | _STUDY==13
	replace _LABELS = "Norway" if _STUDY==2 | _STUDY==5 | _STUDY==8 | _STUDY==11| _STUDY==14
	replace _LABELS = "Sweden" if _STUDY==3 | _STUDY==6 | _STUDY==9 | _STUDY==12 | _STUDY==15
	
	egen seq=seq()
	drop if seq>29
	replace seq = seq+1
	replace seq = seq+1 if seq>19
	set obs `=_N+1'
	replace seq = 20 if seq==.
	set obs `=_N+1'
	replace seq = 1 if seq==.
	sort seq
	
	replace _LABELS = `"{bf:"' + _LABELS + `"}"' if _USE==0
	label variable _LABELS `"`"{bf: Birth outcomes}"'"'
	label variable total_exp `"`"{bf:Pooled}"' `"{bf}exposed n/N"'"'
	label variable _WT `"`"{bf: Weight}"' `"(%)"'"'
	
	replace _ES = exp(_ES)
	replace _LCI = exp(_LCI)
	replace _UCI = exp(_UCI) 
	
	replace _ES=10 if _ES==.
	replace _LCI=10 if _LCI==.
	replace _UCI=10 if _UCI==.
	
	
	forvalues x=2/31 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %4.2fc ``y'_`x'' 
			
		}		
	}
	
	replace _ES=. if _ES==10
	replace _LCI=. if _LCI==10
	replace _UCI=. if _UCI==10

	forvalues x=2/31 {
	
		local total_exp_`x' = total_exp[`x']
		di "`total_exp_`x''"
		
	}
	
	forvalues x=2/31 {
	
		local total_unexp_`x' = total_unexp[`x']
		di "`total_unexp_`x''"
		
	}
	
	forvalues x=2/31 {
	
		local _LABELS`x' = _LABELS[`x']
		di "`_LABELS`x''"
		
	}
	
	replace _WT=10 if _WT==.
	
	forvalues x=2/31 {
	
		sum _WT if seq==`x'
		local WT_`x' = `r(mean)'
		local WT_`x'_f : display %4.1fc `WT_`x''
		disp "`WT_`x'_f'"
		
	}
	
	replace _WT=. if _WT==10
	
	* Macros to create the null line
	local t1=0
	local t2=32
	
	tw ///
	(scatteri `t1' 1 `t2' 1, recast(line) yaxis(1) lpatter(dash) lcolor(cranberry)) /// null line
	(rcap _LCI _UCI seq, horizontal lcolor(black) mlw(thin) msize(*0.5)) ///
	(rcap _LCI _UCI seq if _USE==3, horizontal lcolor(cranberry) mlw(thin) msize(*0.5)) ///
	(scatter seq _ES if _LABELS=="UK", mcolor("85 119 135") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _LABELS=="Norway", mcolor("217 142 98") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _LABELS=="Sweden", mcolor("168 210 218") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _USE==3, mcolor(cranberry) ms(d) msize(small) mcolor(white) mlcolor(cranberry) mlw(thin)), ///
	yscale(range(-1.5 31) reverse noline) ylab("", angle(0) labsize(*0.6) notick nogrid nogextend) /// 
	legend(order(4 "UK" 5 "Norway" 6 "Sweden" 7 "Overall") col(1) region(lcolor(black)) pos(5) size(*0.75)) ///
	yline(-2) yline(0) yline(7, lcolor(gray) lpattern(dot)) yline(13, lcolor(gray) lpattern(dot)) yline(26, lcolor(gray) lpattern(dot)) yline(0.8, lcolor(gs14) lwidth(*17)) yline(19.8, lcolor(gs14) lwidth(*17)) ///
	xscale(range(0.1 5.7) log) xlab(0.4(0.2)2.9, labsize(*0.4) format(%3.1fc) angle(45))  ///
	graphregion(color(white) fcolor(white) ifcolor(white) lcolor(white)) plotregion(margin(1 1 0 1)) ///
	title("{bf}Fixed-effect meta-analysis of maternal antidepressant use" "{bf}during pregnancy and preterm delivery in the UK, Norway, & Sweden" "stratified by type of preterm and initiation of labour", size(*0.5)) ///
	text(-1 2.9 "{bf}aOR* (95% CI)", size(*0.35) justification(left) placement(e)) ///
	text(-1 4.4 "{bf}Weight (%)", size(*0.35) justification(left) placement(e)) ///
	text(-1 0.1 "{bf}Outcome" "	Country", size(*0.35) justification(left) placement(e)) ///
	text(-1 0.21 "{bf}Exposed" "{it:n} / N", size(*0.35) justification(right) placement(w)) ///
	text(-1 0.39 "{bf}Unexposed" "{it:n} / N", size(*0.35) justification(right) placement(w)) ///
	text(0.75 0.1 "{bf:Types of preterm delivery}", size(*0.35) justification(left) placement(e)) ///
	text(2 0.1 "{bf:Moderate-to-late preterm delivery{sup:a}}", size(*0.35) justification(left) placement(e)) ///
		text(3 0.11 "`_LABELS3'", size(*0.35) justification(left) placement(e)) ///
	text(3 0.21 "`total_exp_3'", size(*0.35) justification(right) placement(w)) ///
	text(3 0.39 "`total_unexp_3'", size(*0.35) justification(right) placement(w)) ///
	text(3 2.9 "`_ES_3_f' (`_LCI_3_f' – `_UCI_3_f')", size(*0.35) justification(left) placement(e)) ///
	text(3 5.5 "`WT_3_f'", size(*0.35) justification(right) placement(w)) ///
		text(4 0.11 "`_LABELS4'", size(*0.35) justification(left) placement(e)) ///
	text(4 0.21 "`total_exp_4'", size(*0.35) justification(right) placement(w)) ///
	text(4 0.39 "`total_unexp_4'", size(*0.35) justification(right) placement(w)) ///
	text(4 2.9 "`_ES_4_f' (`_LCI_4_f' – `_UCI_4_f')", size(*0.35) justification(left) placement(e)) ///
	text(4 5.5 "`WT_4_f'", size(*0.35) justification(right) placement(w)) ///
		text(5 0.11 "`_LABELS5'", size(*0.35) justification(left) placement(e)) ///
	text(5 0.21 "`total_exp_5'", size(*0.35) justification(right) placement(w)) ///
	text(5 0.39 "`total_unexp_5'", size(*0.35) justification(right) placement(w)) ///
	text(5 2.9 "`_ES_5_f' (`_LCI_5_f' – `_UCI_5_f')", size(*0.35) justification(left) placement(e)) ///
	text(5 5.5 "`WT_5_f'", size(*0.35) justification(right) placement(w)) ///
		text(6 0.1 "`_LABELS6'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(6 2.9 "`_ES_6_f' (`_LCI_6_f' – `_UCI_6_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(6 5.5 "`WT_6_f'", size(*0.35) justification(right) placement(w)) ///
	text(8 0.1 "{bf:Very preterm delivery{sup:b}}", size(*0.35) justification(left) placement(e)) ///
		text(9 0.11 "`_LABELS9'", size(*0.35) justification(left) placement(e)) ///
	text(9 0.21 "`total_exp_9'", size(*0.35) justification(right) placement(w)) ///
	text(9 0.39 "`total_unexp_9'", size(*0.35) justification(right) placement(w)) ///
	text(9 2.9 "`_ES_9_f' (`_LCI_9_f' – `_UCI_9_f')", size(*0.35) justification(left) placement(e)) ///
	text(9 5.5 "`WT_9_f'", size(*0.35) justification(right) placement(w)) ///
		text(10 0.11 "`_LABELS10'", size(*0.35) justification(left) placement(e)) ///
	text(10 0.21 "`total_exp_10'", size(*0.35) justification(right) placement(w)) ///
	text(10 0.39 "`total_unexp_10'", size(*0.35) justification(right) placement(w)) ///
	text(10 2.9 "`_ES_10_f' (`_LCI_10_f' – `_UCI_10_f')", size(*0.35) justification(left) placement(e)) ///
	text(10 5.5 "`WT_10_f'", size(*0.35) justification(right) placement(w)) ///
		text(11 0.11 "`_LABELS11'", size(*0.35) justification(left) placement(e)) ///
	text(11 0.21 "`total_exp_11'", size(*0.35) justification(right) placement(w)) ///
	text(11 0.39 "`total_unexp_11'", size(*0.35) justification(right) placement(w)) ///
	text(11 2.9 "`_ES_11_f' (`_LCI_11_f' – `_UCI_11_f')", size(*0.35) justification(left) placement(e)) ///
	text(11 5.5 "`WT_11_f'", size(*0.35) justification(right) placement(w)) ///
		text(12 0.1 "`_LABELS12'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(12 2.9 "`_ES_12_f' (`_LCI_12_f' – `_UCI_12_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(12 5.5 "`WT_12_f'", size(*0.35) justification(right) placement(w)) ///
	text(14 0.1 "{bf:Extremely preterm delivery{sup:c}}", size(*0.35) justification(left) placement(e)) ///
		text(15 0.11 "`_LABELS15'", size(*0.35) justification(left) placement(e)) ///
	text(15 0.21 "`total_exp_15'", size(*0.35) justification(right) placement(w)) ///
	text(15 0.39 "`total_unexp_15'", size(*0.35) justification(right) placement(w)) ///
	text(15 2.9 "`_ES_15_f' (`_LCI_15_f' – `_UCI_15_f')", size(*0.35) justification(left) placement(e)) ///
	text(15 5.5 "`WT_15_f'", size(*0.35) justification(right) placement(w)) ///
		text(16 0.11 "`_LABELS16'", size(*0.35) justification(left) placement(e)) ///
	text(16 0.21 "`total_exp_16'", size(*0.35) justification(right) placement(w)) ///
	text(16 0.39 "`total_unexp_16'", size(*0.35) justification(right) placement(w)) ///
	text(16 2.9 "`_ES_16_f' (`_LCI_16_f' – `_UCI_16_f')", size(*0.35) justification(left) placement(e)) ///
	text(16 5.5 "`WT_16_f'", size(*0.35) justification(right) placement(w)) ///
		text(17 0.11 "`_LABELS17'", size(*0.35) justification(left) placement(e)) ///
	text(17 0.21 "`total_exp_17'", size(*0.35) justification(right) placement(w)) ///
	text(17 0.39 "`total_unexp_17'", size(*0.35) justification(right) placement(w)) ///
	text(17 2.9 "`_ES_17_f' (`_LCI_17_f' – `_UCI_17_f')", size(*0.35) justification(left) placement(e)) ///
	text(17 5.5 "`WT_17_f'", size(*0.35) justification(right) placement(w)) ///
		text(18 0.1 "`_LABELS18'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(18 2.9 "`_ES_18_f' (`_LCI_18_f' – `_UCI_18_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(18 5.5 "`WT_18_f'", size(*0.35) justification(right) placement(w)) ///
	text(19.75 0.1 "{bf:Preterm by intiation of labour}", size(*0.35) justification(left) placement(e)) ///
	text(21 0.1 "{bf:Spontaneous preterm delivery}", size(*0.35) justification(left) placement(e)) ///
		text(22 0.11 "`_LABELS22'", size(*0.35) justification(left) placement(e)) ///
	text(22 0.21 "`total_exp_22'", size(*0.35) justification(right) placement(w)) ///
	text(22 0.39 "`total_unexp_22'", size(*0.35) justification(right) placement(w)) ///
	text(22 5.5 "`WT_22_f'", size(*0.35) justification(right) placement(w)) ///
	text(22 2.9 "`_ES_23_f' (`_LCI_22_f' – `_UCI_22_f')", size(*0.35) justification(left) placement(e)) ///
		text(23 0.11 "`_LABELS23'", size(*0.35) justification(left) placement(e)) ///
	text(23 0.21 "`total_exp_23'", size(*0.35) justification(right) placement(w)) ///
	text(23 0.39 "`total_unexp_23'", size(*0.35) justification(right) placement(w)) ///
	text(23 2.9 "`_ES_23_f' (`_LCI_23_f' – `_UCI_23_f')", size(*0.35) justification(left) placement(e)) ///
	text(23 5.5 "`WT_23_f'", size(*0.35) justification(right) placement(w)) ///
		text(24 0.11 "`_LABELS24'", size(*0.35) justification(left) placement(e)) ///
	text(24 0.21 "`total_exp_24'", size(*0.35) justification(right) placement(w)) ///
	text(24 0.39 "`total_unexp_24'", size(*0.35) justification(right) placement(w)) ///
	text(24 2.9 "`_ES_24_f' (`_LCI_24_f' – `_UCI_24_f')", size(*0.35) justification(left) placement(e)) ///
	text(24 5.5 "`WT_24_f'", size(*0.35) justification(right) placement(w)) ///
		text(25 0.1 "`_LABELS25'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(25 2.9 "`_ES_25_f' (`_LCI_25_f' – `_UCI_25_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(25 5.5 "`WT_25_f'", size(*0.35) justification(right) placement(w)) ///
	text(27 0.1 "{bf:Induced preterm delivery}", size(*0.35) justification(left) placement(e)) ///
		text(28 0.11 "`_LABELS28'", size(*0.35) justification(left) placement(e)) ///
	text(28 0.21 "`total_exp_28'", size(*0.35) justification(right) placement(w)) ///
	text(28 0.39 "`total_unexp_28'", size(*0.35) justification(right) placement(w)) ///
	text(28 2.9 "`_ES_28_f' (`_LCI_28_f' – `_UCI_28_f')", size(*0.35) justification(left) placement(e)) ///
	text(28 5.5 "`WT_28_f'", size(*0.35) justification(right) placement(w)) ///
		text(29 0.11 "`_LABELS29'", size(*0.35) justification(left) placement(e)) ///
	text(29 0.21 "`total_exp_29'", size(*0.35) justification(right) placement(w)) ///
	text(29 0.39 "`total_unexp_29'", size(*0.35) justification(right) placement(w)) ///
	text(29 2.9 "`_ES_29_f' (`_LCI_29_f' – `_UCI_29_f')", size(*0.35) justification(left) placement(e)) ///
	text(29 5.5 "`WT_29_f'", size(*0.35) justification(right) placement(w)) ///
		text(30 0.11 "`_LABELS30'", size(*0.35) justification(left) placement(e)) ///
	text(30 0.21 "`total_exp_30'", size(*0.35) justification(right) placement(w)) ///
	text(30 0.39 "`total_unexp_30'", size(*0.35) justification(right) placement(w)) ///
	text(30 2.9 "`_ES_30_f' (`_LCI_30_f' – `_UCI_30_f')", size(*0.35) justification(left) placement(e)) ///
	text(30 5.5 "`WT_30_f'", size(*0.35) justification(right) placement(w)) ///
	text(31 0.1 "`_LABELS31'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(31 2.9 "`_ES_31_f' (`_LCI_31_f' – `_UCI_31_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(31 5.5 "`WT_31_f'", size(*0.35) justification(right) placement(w)) ///
	text(35 1.2 "{bf:Odds ratio* (95% confidence interval)}" "from logistic regression", size(*0.45)) ///
	text(36.5 1.2 "from fixed effects meta-analysis", size(*0.45) color(cranberry)) ///
	text(35 0.1 "*Adjusted for year of birth, maternal age," "previous stillbirth, parity, antipsychotic and" "anti-seizure medication use before pregnancy," "depression, anxiety, practice-level IMD and" "ethnicity (UK), maternal educational attainment" "and country of birth (Norway and Sweden)," "household disposable income (Sweden)," "smoking during pregnancy (UK and Sweden)," "maternal BMI (Sweden), number of primary care" "consultations before pregnancy (UK and Norway)", size(*0.35) justification(left) placement(e)) ///
	text(38.75 0.1 "{sup:a}In the moderate-to-late preterm models, those" "who initiated antidepressants after 36+6 weeks'" "gestation were considered unexposed", size(*0.35) justification(left) placement(e)) ///
	text(40.5 0.1 "{sup:b}In the very preterm models those initiated" "after 31+6 weeks' gestation were considered unexposed", size(*0.35) justification(left) placement(e)) ///
	text(42 0.1 "{sup:c}In the extremely preterm models those who" "initiated after 27+6 weeks' gestation were considered unexposed", size(*0.35) justification(left) placement(e)) ///
	xsize(90) ysize(100) name(preterm, replace)
	
	* Save graph
	
	graph export "C:\Users\ti19522\OneDrive - University of Bristol\Flo Martin Supervisory Team\Year 4\6_Birth outcomes\supplementary figures\strat_preterm_ma.pdf", replace
	
	erase stratpreterm_ma.dta