

cd "$Graphdir"

* Make the maternal meta-analysis figure for supplementary material and generate the summary effect estimate for the primary figure

	use "$Graphdir\data\indic sample analyses data_all3.dta", clear
	
	gen logor = log(or)
	gen loglci = log(lci)
	gen loguci = log(uci)
	
	metan logor loglci loguci, eform by(outcome) lcols(outcome total_exp total_unexp) saving(indicsample_ma, replace)
	
	* Use the data from metan to make a nicer forest plot
	
	use indicsample_ma, clear
	
	bys _BY _USE : egen grp_wt = sum(_WT)
	gen pct_grp_wt = 100 * _WT / grp_wt
	
	drop _WT
	rename pct_grp_wt _WT
	
	drop if _USE>=4 & _USE<6
	*drop if _BY==2 & _USE==3
	
	replace _LABELS = "Stillborn" if _LABELS=="a_stillborn"
	replace _LABELS = "Neonatal death" if _LABELS=="b_neonatal_death"
	replace _LABELS = "Preterm delivery" if _LABELS=="c_preterm"
	replace _LABELS = "Post-term delivery" if _LABELS=="d_postterm"
	replace _LABELS = "Small for gestational age" if _LABELS=="e_sga"
	replace _LABELS = "Large for gestational age" if _LABELS=="f_lga"
	replace _LABELS = "Apgar score < 7 at 5 minutes" if _LABELS=="g_apar5_bin"
	
	replace _LABELS = "UK" if _STUDY==1 | _STUDY==6 | _STUDY==9 | _STUDY==12 | _STUDY==15
	replace _LABELS = "Norway" if _STUDY==2 | _STUDY==4 | _STUDY==7 | _STUDY==10 | _STUDY==13 | _STUDY==16 | _STUDY==18
	replace _LABELS = "Sweden" if _STUDY==3 | _STUDY==5 | _STUDY==8 | _STUDY==11 | _STUDY==14 | _STUDY==17 | _STUDY==19
	
	replace _LABELS = `"{bf:"' + _LABELS + `"}"' if _USE==0
	label variable _LABELS `"`"{bf: Birth outcomes}"'"'
	label variable total_exp `"`"{bf: Exposed n/N}"'"'
	label variable total_unexp `"`"{bf: Unexposed n/N}"'"'
	label variable _WT `"`"{bf: Weight}"' `"(%)"'"'
	
	format _ES %4.1fc
	format _WT %4.1fc
	
	*drop if _USE==1
	
	gen country=1 if _LABELS=="UK"
	replace country=2 if _LABELS=="Norway"
	replace country=3 if _LABELS=="Sweden"

	forestplot, eform lcols(total_exp total_unexp) effect("{bf}Odds ratio") null(1) olineopts(lcolor(none)) nlineopts(lcolor(cranberry) lpattern(dash)) xlabel(0.5(0.25)2.5) title("{bf}Indication-based sample sensitivity analysis", size(small)) ///
	plotid(country, list) point1opts(msymbol(triangle) msize(0.75)) point2opts(msymbol(circle) msize(0.75)) point4opts(msymbol(diamond) msize(0.75)) textsize(85) ///
	name(indicsample_ma, replace)
	
	cd "$Graphdir"
	graph export indicsample_ma.pdf, replace
	
	replace _LABELS = "UK" if _STUDY==1 | _STUDY==6 | _STUDY==9 | _STUDY==12 | _STUDY==15
	replace _LABELS = "Norway" if _STUDY==2 | _STUDY==4 | _STUDY==7 | _STUDY==10 | _STUDY==13 | _STUDY==16 | _STUDY==18
	replace _LABELS = "Sweden" if _STUDY==3 | _STUDY==5 | _STUDY==8 | _STUDY==11 | _STUDY==14 | _STUDY==17 | _STUDY==19
	
	egen seq=seq()
	drop if seq>39
	
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
	
	
	forvalues x=2/39 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %4.2fc ``y'_`x'' 
			
		}		
	}
	
	replace _ES=. if _ES==10
	replace _LCI=. if _LCI==10
	replace _UCI=. if _UCI==10
	
	forvalues x=2/39 {
	
		local total_exp_`x' = total_exp[`x']
		di "`total_exp_`x''"
		
	}
	
	forvalues x=2/39 {
	
		local total_unexp_`x' = total_unexp[`x']
		di "`total_unexp_`x''"
		
	}
	
	forvalues x=2/39 {
	
		local _LABELS`x' = _LABELS[`x']
		di "`_LABELS`x''"
		
	}
	
	replace _WT=10 if _WT==.
	
	forvalues x=2/39 {
	
		sum _WT if seq==`x'
		local WT_`x' = `r(mean)'
		local WT_`x'_f : display %4.1fc `WT_`x''
		disp "`WT_`x'_f'"
		
	}
	
	replace _WT=. if _WT==10
	
	* Macros to create the null line
	local t1=0
	local t2=40
	
	tw ///
	(scatteri `t1' 1 `t2' 1, recast(line) yaxis(1) lpatter(dash) lcolor(cranberry)) /// null line
	(rcap _LCI _UCI seq, horizontal lcolor(black) mlw(thin) msize(*0.5)) ///
	(rcap _LCI _UCI seq if _USE==3, horizontal lcolor(cranberry) mlw(thin) msize(*0.5)) ///
	(scatter seq _ES if _LABELS=="UK", mcolor("85 119 135") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _LABELS=="Norway", mcolor("217 142 98") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _LABELS=="Sweden", mcolor("168 210 218") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _USE==3, mcolor(cranberry) ms(d) msize(small) mcolor(white) mlcolor(cranberry) mlw(thin)), ///
	yscale(range(-1.5 40) reverse noline) ylab("", angle(0) labsize(*0.6) notick nogrid nogextend) /// 
	legend(order(4 "UK" 5 "Norway" 6 "Sweden" 7 "Overall") col(1) region(lcolor(black)) pos(5) size(*0.75)) ///
	yline(-2) yline(0) yline(6, lcolor(gray) lpattern(dot)) yline(11, lcolor(gray) lpattern(dot)) yline(17, lcolor(gray) lpattern(dot)) yline(23, lcolor(gray) lpattern(dot)) yline(29, lcolor(gray) lpattern(dot)) yline(35, lcolor(gray) lpattern(dot)) ///
	xscale(range(0.1 5.7) log) xlab(0.4(0.2)2.9, labsize(*0.4) format(%3.1fc) angle(45))  ///
	graphregion(color(white) fcolor(white) ifcolor(white) lcolor(white)) plotregion(margin(1 1 0 1)) ///
	title("{bf}Fixed-effect meta-analysis of maternal antidepressant use" "{bf}during pregnancy and birth outcomes in the UK, Norway, & Sweden" "in an indication-based sample", size(*0.5)) ///
	text(-1 2.9 "{bf}aOR* (95% CI)", size(*0.35) justification(left) placement(e)) ///
	text(-1 4.4 "{bf}Weight (%)", size(*0.35) justification(left) placement(e)) ///
	text(-1 0.1 "{bf}Outcome" "	Country", size(*0.35) justification(left) placement(e)) ///
	text(-1 0.21 "{bf}Exposed" "{it:n} / N", size(*0.35) justification(right) placement(w)) ///
	text(-1 0.39 "{bf}Unexposed" "{it:n} / N", size(*0.35) justification(right) placement(w)) ///
	text(1 0.1 "{bf:Stillborn}", size(*0.35) justification(left) placement(e)) ///
		text(2 0.11 "`_LABELS2'", size(*0.35) justification(left) placement(e)) ///
	text(2 0.21 "`total_exp_2'", size(*0.35) justification(right) placement(w)) ///
	text(2 0.39 "`total_unexp_2'", size(*0.35) justification(right) placement(w)) ///
	text(2 2.9 "`_ES_2_f' (`_LCI_2_f' – `_UCI_2_f')", size(*0.35) justification(left) placement(e)) ///
	text(2 5.5 "`WT_2_f'", size(*0.35) justification(right) placement(w)) ///
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
		text(5 0.1 "`_LABELS5'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(5 2.9 "`_ES_5_f' (`_LCI_5_f' – `_UCI_5_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(5 5.5 "`WT_5_f'", size(*0.35) justification(right) placement(w)) ///
	text(7 0.1 "{bf:Neonatal death{sup:‡}}", size(*0.35) justification(left) placement(e)) ///
		text(8 0.11 "`_LABELS8'", size(*0.35) justification(left) placement(e)) ///
	text(8 0.21 "`total_exp_8'", size(*0.35) justification(right) placement(w)) ///
	text(8 0.39 "`total_unexp_8'", size(*0.35) justification(right) placement(w)) ///
	text(8 2.9 "`_ES_8_f' (`_LCI_8_f' – `_UCI_8_f')", size(*0.35) justification(left) placement(e)) ///
	text(8 5.5 "`WT_8_f'", size(*0.35) justification(right) placement(w)) ///
		text(9 0.11 "`_LABELS9'", size(*0.35) justification(left) placement(e)) ///
	text(9 0.21 "`total_exp_9'", size(*0.35) justification(right) placement(w)) ///
	text(9 0.39 "`total_unexp_9'", size(*0.35) justification(right) placement(w)) ///
	text(9 2.9 "`_ES_9_f' (`_LCI_9_f' – `_UCI_9_f')", size(*0.35) justification(left) placement(e)) ///
	text(9 5.5 "`WT_9_f'", size(*0.35) justification(right) placement(w)) ///
		text(10 0.1 "`_LABELS10'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(10 2.9 "`_ES_10_f' (`_LCI_10_f' – `_UCI_10_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(10 5.5 "`WT_10_f'", size(*0.35) justification(right) placement(w)) ///
	text(12 0.1 "{bf:Preterm delivery}", size(*0.35) justification(left) placement(e)) ///
		text(13 0.11 "`_LABELS13'", size(*0.35) justification(left) placement(e)) ///
	text(13 0.21 "`total_exp_13'", size(*0.35) justification(right) placement(w)) ///
	text(13 0.39 "`total_unexp_13'", size(*0.35) justification(right) placement(w)) ///
	text(13 2.9 "`_ES_13_f' (`_LCI_13_f' – `_UCI_13_f')", size(*0.35) justification(left) placement(e)) ///
	text(13 5.5 "`WT_13_f'", size(*0.35) justification(right) placement(w)) ///
		text(14 0.11 "`_LABELS14'", size(*0.35) justification(left) placement(e)) ///
	text(14 0.21 "`total_exp_14'", size(*0.35) justification(right) placement(w)) ///
	text(14 0.39 "`total_unexp_14'", size(*0.35) justification(right) placement(w)) ///
	text(14 2.9 "`_ES_14_f' (`_LCI_14_f' – `_UCI_14_f')", size(*0.35) justification(left) placement(e)) ///
	text(14 5.5 "`WT_14_f'", size(*0.35) justification(right) placement(w)) ///
		text(15 0.11 "`_LABELS15'", size(*0.35) justification(left) placement(e)) ///
	text(15 0.21 "`total_exp_15'", size(*0.35) justification(right) placement(w)) ///
	text(15 0.39 "`total_unexp_15'", size(*0.35) justification(right) placement(w)) ///
	text(15 2.9 "`_ES_15_f' (`_LCI_15_f' – `_UCI_15_f')", size(*0.35) justification(left) placement(e)) ///
	text(15 5.5 "`WT_15_f'", size(*0.35) justification(right) placement(w)) ///
		text(16 0.1 "`_LABELS16'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(16 2.9 "`_ES_16_f' (`_LCI_16_f' – `_UCI_16_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(16 5.5 "`WT_16_f'", size(*0.35) justification(right) placement(w)) ///
	text(18 0.1 "{bf:Post-term delivery}", size(*0.35) justification(left) placement(e)) ///
		text(19 0.11 "`_LABELS19'", size(*0.35) justification(left) placement(e)) ///
	text(19 0.21 "`total_exp_19'", size(*0.35) justification(right) placement(w)) ///
	text(19 0.39 "`total_unexp_19'", size(*0.35) justification(right) placement(w)) ///
	text(19 2.9 "`_ES_19_f' (`_LCI_19_f' – `_UCI_19_f')", size(*0.35) justification(left) placement(e)) ///
	text(19 5.5 "`WT_19_f'", size(*0.35) justification(right) placement(w)) ///
		text(20 0.11 "`_LABELS20'", size(*0.35) justification(left) placement(e)) ///
	text(20 0.21 "`total_exp_20'", size(*0.35) justification(right) placement(w)) ///
	text(20 0.39 "`total_unexp_20'", size(*0.35) justification(right) placement(w)) ///
	text(20 2.9 "`_ES_20_f' (`_LCI_20_f' – `_UCI_20_f')", size(*0.35) justification(left) placement(e)) ///
	text(20 5.5 "`WT_20_f'", size(*0.35) justification(right) placement(w)) ///
		text(21 0.11 "`_LABELS21'", size(*0.35) justification(left) placement(e)) ///
	text(21 0.21 "`total_exp_21'", size(*0.35) justification(right) placement(w)) ///
	text(21 0.39 "`total_unexp_21'", size(*0.35) justification(right) placement(w)) ///
	text(21 2.9 "`_ES_21_f' (`_LCI_21_f' – `_UCI_21_f')", size(*0.35) justification(left) placement(e)) ///
	text(21 5.5 "`WT_21_f'", size(*0.35) justification(right) placement(w)) ///
		text(22 0.1 "`_LABELS22'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(22 2.9 "`_ES_22_f' (`_LCI_22_f' – `_UCI_22_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(22 5.5 "`WT_22_f'", size(*0.35) justification(right) placement(w)) ///
	text(24 0.1 "{bf:Small for gestational age}", size(*0.35) justification(left) placement(e)) ///
		text(25 0.11 "`_LABELS25'", size(*0.35) justification(left) placement(e)) ///
	text(25 0.21 "`total_exp_25'", size(*0.35) justification(right) placement(w)) ///
	text(25 0.39 "`total_unexp_25'", size(*0.35) justification(right) placement(w)) ///
	text(25 5.5 "`WT_25_f'", size(*0.35) justification(right) placement(w)) ///
	text(25 2.9 "`_ES_25_f' (`_LCI_25_f' – `_UCI_25_f')", size(*0.35) justification(left) placement(e)) ///
		text(26 0.11 "`_LABELS26'", size(*0.35) justification(left) placement(e)) ///
	text(26 0.21 "`total_exp_26'", size(*0.35) justification(right) placement(w)) ///
	text(26 0.39 "`total_unexp_26'", size(*0.35) justification(right) placement(w)) ///
	text(26 2.9 "`_ES_26_f' (`_LCI_26_f' – `_UCI_26_f')", size(*0.35) justification(left) placement(e)) ///
	text(26 5.5 "`WT_26_f'", size(*0.35) justification(right) placement(w)) ///
		text(27 0.11 "`_LABELS27'", size(*0.35) justification(left) placement(e)) ///
	text(27 0.21 "`total_exp_27'", size(*0.35) justification(right) placement(w)) ///
	text(27 0.39 "`total_unexp_27'", size(*0.35) justification(right) placement(w)) ///
	text(27 2.9 "`_ES_27_f' (`_LCI_27_f' – `_UCI_27_f')", size(*0.35) justification(left) placement(e)) ///
	text(27 5.5 "`WT_27_f'", size(*0.35) justification(right) placement(w)) ///
		text(28 0.1 "`_LABELS28'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(28 2.9 "`_ES_28_f' (`_LCI_28_f' – `_UCI_28_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(28 5.5 "`WT_28_f'", size(*0.35) justification(right) placement(w)) ///
	text(30 0.1 "{bf:Large for gestational age}", size(*0.35) justification(left) placement(e)) ///
		text(31 0.11 "`_LABELS31'", size(*0.35) justification(left) placement(e)) ///
	text(31 0.21 "`total_exp_31'", size(*0.35) justification(right) placement(w)) ///
	text(31 0.39 "`total_unexp_31'", size(*0.35) justification(right) placement(w)) ///
	text(31 2.9 "`_ES_31_f' (`_LCI_31_f' – `_UCI_31_f')", size(*0.35) justification(left) placement(e)) ///
	text(31 5.5 "`WT_31_f'", size(*0.35) justification(right) placement(w)) ///
		text(32 0.11 "`_LABELS32'", size(*0.35) justification(left) placement(e)) ///
	text(32 0.21 "`total_exp_32'", size(*0.35) justification(right) placement(w)) ///
	text(32 0.39 "`total_unexp_32'", size(*0.35) justification(right) placement(w)) ///
	text(32 2.9 "`_ES_32_f' (`_LCI_32_f' – `_UCI_32_f')", size(*0.35) justification(left) placement(e)) ///
	text(32 5.5 "`WT_32_f'", size(*0.35) justification(right) placement(w)) ///
		text(33 0.11 "`_LABELS33'", size(*0.35) justification(left) placement(e)) ///
	text(33 0.21 "`total_exp_33'", size(*0.35) justification(right) placement(w)) ///
	text(33 0.39 "`total_unexp_33'", size(*0.35) justification(right) placement(w)) ///
	text(33 2.9 "`_ES_33_f' (`_LCI_33_f' – `_UCI_33_f')", size(*0.35) justification(left) placement(e)) ///
	text(33 5.5 "`WT_33_f'", size(*0.35) justification(right) placement(w)) ///
	text(34 0.1 "`_LABELS34'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(34 2.9 "`_ES_34_f' (`_LCI_34_f' – `_UCI_34_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(34 5.5 "`WT_34_f'", size(*0.35) justification(right) placement(w)) ///
	text(36 0.1 "{bf:Low Apgar score{sup:‡}}", size(*0.35) justification(left) placement(e)) ///
		text(37 0.11 "`_LABELS37'", size(*0.35) justification(left) placement(e)) ///
	text(37 0.21 "`total_exp_37'", size(*0.35) justification(right) placement(w)) ///
	text(37 0.39 "`total_unexp_37'", size(*0.35) justification(right) placement(w)) ///
	text(37 2.9 "`_ES_37_f' (`_LCI_37_f' – `_UCI_37_f')", size(*0.35) justification(left) placement(e)) ///
	text(37 5.5 "`WT_37_f'", size(*0.35) justification(right) placement(w)) ///
		text(38 0.11 "`_LABELS38'", size(*0.35) justification(left) placement(e)) ///
	text(38 0.21 "`total_exp_38'", size(*0.35) justification(right) placement(w)) ///
	text(38 0.39 "`total_unexp_38'", size(*0.35) justification(right) placement(w)) ///
	text(38 2.9 "`_ES_38_f' (`_LCI_38_f' – `_UCI_38_f')", size(*0.35) justification(left) placement(e)) ///
	text(38 5.5 "`WT_38_f'", size(*0.35) justification(right) placement(w)) ///
		text(39 0.1 "`_LABELS39'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(39 2.9 "`_ES_39_f' (`_LCI_39_f' – `_UCI_39_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(39 5.5 "`WT_39_f'", size(*0.35) justification(right) placement(w)) ///
	text(44 1.2 "{bf:Odds ratio* (95% confidence interval)}" "from logistic regression", size(*0.45)) ///
	text(45.5 1.2 "from fixed effects meta-analysis", size(*0.45) color(cranberry)) ///
	text(44 0.1 "*Adjusted for year of birth, maternal age," "previous stillbirth, parity, antipsychotic and" "anti-seizure medication use before pregnancy," "depression, anxiety, practice-level IMD and" "ethnicity (UK), maternal educational attainment" "and country of birth (Norway and Sweden)," "household disposable income (Sweden)," "smoking during pregnancy (UK and Sweden)," "maternal BMI (Sweden), number of primary care" "consultations before pregnancy (UK and Norway)", size(*0.35) justification(left) placement(e)) ///
	text(48 0.1 "{sup:‡}Norway and Sweden only", size(*0.35) justification(left) placement(e)) ///
	xsize(90) ysize(100) name(indic_sample, replace)
	
	* Save graph
	
	graph export "C:\Users\ti19522\OneDrive - University of Bristol\Flo Martin Supervisory Team\Year 4\6_Birth outcomes\supplementary figures\indic_sample_ma.pdf", replace
	
	erase indicsample_ma.dta