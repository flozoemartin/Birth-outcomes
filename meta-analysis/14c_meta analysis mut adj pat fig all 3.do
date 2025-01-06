		cd "$Graphdir"

* Make the maternal meta-analysis figure for supplementary material and generate the summary effect estimate for the primary figure

		use "$Graphdir\data\mut adj pat analyses data_all3.dta", clear
		
		gen logor = log(or)
		gen loglci = log(lci)
		gen loguci = log(uci)
		
		metan logor loglci loguci, eform by(outcome) lcols(outcome total_exp total_unexp) saving(mutadjpat_ma, replace)
		
		* Use the data from metan to make a nicer forest plot
		
		use mutadjpat_ma, clear
		
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
		
		replace _LABELS = "Norway" if _STUDY==1 | _STUDY==3 | _STUDY==5 | _STUDY==7 | _STUDY==9 | _STUDY==11 | _STUDY==13
		replace _LABELS = "Sweden" if _STUDY==2 | _STUDY==4 | _STUDY==6 | _STUDY==8 | _STUDY==10 | _STUDY==12 | _STUDY==14
		
		replace _LABELS = `"{bf:"' + _LABELS + `"}"' if _USE==0
		label variable _LABELS `"`"{bf: Birth outcomes}"'"'
		label variable total_exp `"`"{bf: Exposed n/N}"'"'
		label variable total_unexp `"`"{bf: Unexposed n/N}"'"'
		label variable _WT `"`"{bf: Weight}"' `"(%)"'"'
		
		format _ES %4.1fc
		format _WT %4.1fc
		
		*drop if _USE==1
		drop if _USE==3 & _BY==1
		
		gen country=1 if _LABELS=="UK"
		replace country=2 if _LABELS=="Norway"
		replace country=3 if _LABELS=="Sweden"

		forestplot, eform lcols(total_exp total_unexp) effect("{bf}Odds ratio") null(1) olineopts(lcolor(none)) nlineopts(lcolor(cranberry) lpattern(dash)) xlabel(0.5(0.25)2.5) title("{bf}Mutally adjusted paternal antidepressant use sensitivity analysis", size(small)) ///
		plotid(country, list) point1opts(msymbol(circle) msize(0.75)) point3opts(msymbol(diamond) msize(0.75)) textsize(85) ///
		name(mutadjpat_ma, replace)
		
		cd "$Graphdir"
		graph export mutadjpat_ma.pdf, replace
		
		egen seq=seq()
		drop if seq>32
	
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
	
	
	forvalues x=2/32 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %4.2fc ``y'_`x'' 
			
		}		
	}
	
	replace _ES=. if _ES==10
	replace _LCI=. if _LCI==10
	replace _UCI=. if _UCI==10
	
	forvalues x=2/32 {
	
		local total_exp_`x' = total_exp[`x']
		di "`total_exp_`x''"
		
	}
	
	forvalues x=2/32 {
	
		local total_unexp_`x' = total_unexp[`x']
		di "`total_unexp_`x''"
		
	}
	
	forvalues x=2/32 {
	
		local _LABELS`x' = _LABELS[`x']
		di "`_LABELS`x''"
		
	}
	
	replace _WT=10 if _WT==.
	
	forvalues x=2/32 {
	
		sum _WT if seq==`x'
		local WT_`x' = `r(mean)'
		local WT_`x'_f : display %4.1fc `WT_`x''
		disp "`WT_`x'_f'"
		
	}
	
	replace _WT=. if _WT==10
	
	* Macros to create the null line
	local t1=0
	local t2=33
	
	tw ///
	(scatteri `t1' 1 `t2' 1, recast(line) yaxis(1) lpatter(dash) lcolor(cranberry)) /// null line
	(rcap _LCI _UCI seq, horizontal lcolor(black) mlw(thin) msize(*0.5)) ///
	(rcap _LCI _UCI seq if _USE==3, horizontal lcolor(cranberry) mlw(thin) msize(*0.5)) ///
	(scatter seq _ES if _LABELS=="Norway", mcolor("217 142 98") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _LABELS=="Sweden", mcolor("168 210 218") ms(o) msize(small) mlcolor(black) mlw(thin)) ///
	(scatter seq _ES if _USE==3, mcolor(cranberry) ms(d) msize(small) mcolor(white) mlcolor(cranberry) mlw(thin)), ///
	yscale(range(-1.5 33) reverse noline) ylab("", angle(0) labsize(*0.6) notick nogrid nogextend) /// 
	legend(order(4 "Norway" 5 "Sweden" 6 "Overall") col(1) region(lcolor(black)) pos(5) size(*0.75)) ///
	yline(-2) yline(0) yline(3, lcolor(gray) lpattern(dot)) yline(8, lcolor(gray) lpattern(dot)) yline(13, lcolor(gray) lpattern(dot)) yline(18, lcolor(gray) lpattern(dot)) yline(23, lcolor(gray) lpattern(dot)) yline(28, lcolor(gray) lpattern(dot)) ///
	xscale(range(0.1 5.7) log) xlab(0.4(0.2)2.9, labsize(*0.4) format(%3.1fc) angle(45))  ///
	graphregion(color(white) fcolor(white) ifcolor(white) lcolor(white)) plotregion(margin(1 1 0 1)) ///
	title("{bf}Fixed-effect meta-analysis of paternal antidepressant use" "{bf}during pregnancy and birth outcomes in Norway & Sweden" "mutually adjusted for maternal antidepressant use during pregnancy", size(*0.5)) ///
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
	text(4 0.1 "{bf:Neonatal death}", size(*0.35) justification(left) placement(e)) ///
		text(5 0.11 "`_LABELS5'", size(*0.35) justification(left) placement(e)) ///
	text(5 0.21 "`total_exp_5'", size(*0.35) justification(right) placement(w)) ///
	text(5 0.39 "`total_unexp_5'", size(*0.35) justification(right) placement(w)) ///
	text(5 2.9 "`_ES_5_f' (`_LCI_5_f' – `_UCI_5_f')", size(*0.35) justification(left) placement(e)) ///
	text(5 5.5 "`WT_5_f'", size(*0.35) justification(right) placement(w)) ///
		text(6 0.11 "`_LABELS6'", size(*0.35) justification(left) placement(e)) ///
	text(6 0.21 "`total_exp_6'", size(*0.35) justification(right) placement(w)) ///
	text(6 0.39 "`total_unexp_6'", size(*0.35) justification(right) placement(w)) ///
	text(6 2.9 "`_ES_6_f' (`_LCI_6_f' – `_UCI_6_f')", size(*0.35) justification(left) placement(e)) ///
	text(6 5.5 "`WT_6_f'", size(*0.35) justification(right) placement(w)) ///
		text(7 0.1 "`_LABELS7'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(7 2.9 "`_ES_7_f' (`_LCI_7_f' – `_UCI_7_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(7 5.5 "`WT_7_f'", size(*0.35) justification(right) placement(w)) ///
	text(9 0.1 "{bf:Preterm delivery}", size(*0.35) justification(left) placement(e)) ///
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
	text(14 0.1 "{bf:Post-term delivery}", size(*0.35) justification(left) placement(e)) ///
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
		text(17 0.1 "`_LABELS17'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(17 2.9 "`_ES_17_f' (`_LCI_17_f' – `_UCI_17_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(17 5.5 "`WT_17_f'", size(*0.35) justification(right) placement(w)) ///
	text(19 0.1 "{bf:Small for gestational age}", size(*0.35) justification(left) placement(e)) ///
		text(20 0.11 "`_LABELS20'", size(*0.35) justification(left) placement(e)) ///
	text(20 0.21 "`total_exp_20'", size(*0.35) justification(right) placement(w)) ///
	text(20 0.39 "`total_unexp_20'", size(*0.35) justification(right) placement(w)) ///
	text(20 5.5 "`WT_20_f'", size(*0.35) justification(right) placement(w)) ///
	text(20 2.9 "`_ES_20_f' (`_LCI_20_f' – `_UCI_20_f')", size(*0.35) justification(left) placement(e)) ///
		text(21 0.11 "`_LABELS21'", size(*0.35) justification(left) placement(e)) ///
	text(21 0.21 "`total_exp_21'", size(*0.35) justification(right) placement(w)) ///
	text(21 0.39 "`total_unexp_21'", size(*0.35) justification(right) placement(w)) ///
	text(21 2.9 "`_ES_21_f' (`_LCI_21_f' – `_UCI_21_f')", size(*0.35) justification(left) placement(e)) ///
	text(21 5.5 "`WT_21_f'", size(*0.35) justification(right) placement(w)) ///
		text(22 0.1 "`_LABELS22'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(22 2.9 "`_ES_22_f' (`_LCI_22_f' – `_UCI_22_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(22 5.5 "`WT_22_f'", size(*0.35) justification(right) placement(w)) ///
	text(24 0.1 "{bf:Large for gestational age}", size(*0.35) justification(left) placement(e)) ///
		text(25 0.11 "`_LABELS25'", size(*0.35) justification(left) placement(e)) ///
	text(25 0.21 "`total_exp_25'", size(*0.35) justification(right) placement(w)) ///
	text(25 0.39 "`total_unexp_25'", size(*0.35) justification(right) placement(w)) ///
	text(25 2.9 "`_ES_25_f' (`_LCI_25_f' – `_UCI_25_f')", size(*0.35) justification(left) placement(e)) ///
	text(25 5.5 "`WT_25_f'", size(*0.35) justification(right) placement(w)) ///
		text(26 0.11 "`_LABELS26'", size(*0.35) justification(left) placement(e)) ///
	text(26 0.21 "`total_exp_26'", size(*0.35) justification(right) placement(w)) ///
	text(26 0.39 "`total_unexp_26'", size(*0.35) justification(right) placement(w)) ///
	text(26 2.9 "`_ES_26_f' (`_LCI_26_f' – `_UCI_26_f')", size(*0.35) justification(left) placement(e)) ///
	text(26 5.5 "`WT_26_f'", size(*0.35) justification(right) placement(w)) ///
		text(27 0.1 "`_LABELS27'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(27 2.9 "`_ES_27_f' (`_LCI_27_f' – `_UCI_27_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(27 5.5 "`WT_27_f'", size(*0.35) justification(right) placement(w)) ///
	text(29 0.1 "{bf:Low Apgar score}", size(*0.35) justification(left) placement(e)) ///
		text(30 0.11 "`_LABELS30'", size(*0.35) justification(left) placement(e)) ///
	text(30 0.21 "`total_exp_30'", size(*0.35) justification(right) placement(w)) ///
	text(30 0.39 "`total_unexp_30'", size(*0.35) justification(right) placement(w)) ///
	text(30 2.9 "`_ES_30_f' (`_LCI_30_f' – `_UCI_30_f')", size(*0.35) justification(left) placement(e)) ///
	text(30 5.5 "`WT_30_f'", size(*0.35) justification(right) placement(w)) ///
		text(31 0.11 "`_LABELS31'", size(*0.35) justification(left) placement(e)) ///
	text(31 0.21 "`total_exp_31'", size(*0.35) justification(right) placement(w)) ///
	text(31 0.39 "`total_unexp_31'", size(*0.35) justification(right) placement(w)) ///
	text(31 2.9 "`_ES_31_f' (`_LCI_31_f' – `_UCI_31_f')", size(*0.35) justification(left) placement(e)) ///
	text(31 5.5 "`WT_31_f'", size(*0.35) justification(right) placement(w)) ///
		text(32 0.1 "`_LABELS32'", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(32 2.9 "`_ES_32_f' (`_LCI_32_f' – `_UCI_32_f')", size(*0.35) justification(left) placement(e) color(cranberry)) ///
	text(32 5.5 "`WT_32_f'", size(*0.35) justification(right) placement(w)) ///
	text(36 1.2 "{bf:Odds ratio* (95% confidence interval)}" "from logistic regression", size(*0.45)) ///
	text(37.15 1.2 "from fixed effects meta-analysis", size(*0.45) color(cranberry)) ///
	text(36.5 0.1 "*Adjusted for year of birth, maternal age," "previous stillbirth, parity, antipsychotic and" "anti-seizure medication use before pregnancy," "maternal and paternal depression, maternal and" "paternal anxiety, maternal and paternal educational" "attainment, country of birth, household disposable" "income (Sweden), smoking during pregnancy" "(Sweden), maternal BMI (Sweden), number of" "primary care consultations before pregnancy" "(Norway), maternal antidepressant use during" "pregnancy", size(*0.35) justification(left) placement(e)) ///
	xsize(90) ysize(100) name(mut_adj_pat, replace)
	
	* Save graph
	
	graph export "C:\Users\ti19522\OneDrive - University of Bristol\Flo Martin Supervisory Team\Year 4\6_Birth outcomes\supplementary figures\mut_adj_pat_ma.pdf", replace
		
		erase mutadjpat_ma.dta