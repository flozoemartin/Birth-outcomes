
	/*import delimited using "$NOTabledir\august 24\primary analysis_mat.txt", clear
	
	egen seq=seq()
	replace outcome = "stillborn" if seq==2
	replace outcome = "neonatal_death" if seq==4
	replace outcome = "preterm" if seq==6
	replace outcome = "postterm" if seq==8
	replace outcome = "sga" if seq==10
	replace outcome = "lga" if seq==12
	replace outcome = "apgar5_bin" if seq==14
	
	drop if exposed10==0
	drop seq
	
	rename exposed10 drug
	rename lci risk_lci
	rename uci risk_uci
	
	gen country = "no"
	
	save "$Graphdir\data\exposed risk_no.dta", replace
	
	import delimited using "$SETabledir\data for figures\august 24\primary analysis_mat.txt", clear
	
	egen seq=seq()
	replace outcome = "stillborn" if seq==2
	replace outcome = "neonatal_death" if seq==4
	replace outcome = "postterm" if seq==6
	replace outcome = "sga" if seq==8
	replace outcome = "lga" if seq==10
	replace outcome = "apgar5_bin" if seq==12
	replace outcome = "preterm" if seq==14
	
	drop if exposed10==0
	drop seq
	
	rename exposed10 drug
	rename lci risk_lci
	rename uci risk_uci
	
	gen country = "se"
	
	save "$Graphdir\data\exposed risk_se.dta", replace 
	
	import delimited using "$Graphdir\data\any drug risk uk.txt", clear
	
	drop or lci uci
	
	save "$Graphdir\data\exposed risk_uk.dta", replace */

	use "$Graphdir\data\drug analyses risk data_all3.dta", clear
	
	drop if drug==0 & country=="uk"
	
	replace drug = drug + 1 if drug>0
	
	append using "$Graphdir\data\exposed risk_no.dta"
	append using "$Graphdir\data\exposed risk_se.dta"
	append using "$Graphdir\data\exposed risk_uk.dta"
	
	* Preterm by drug meta-analysis
	
	keep if outcome=="preterm"
	
	* Sort out the counts that aren't right
	
	replace total_exp = subinstr(total_exp, ",", "", .) if drug==0 & country!="uk"
	gen events = regexs(1) if regexm(total_exp, "^([0-9]+) *(/*)") & drug==0 & country!="uk"
	gen tot = regexs(3) if regexm(total_exp, "^([0-9]+) *(/*) ([0-9]+)") & drug==0 & country!="uk"
	
	gen event_num = real(events)
	gen tot_num = real(tot)
	
	gen unexposed_event = tot_num - event_num
	
	format *_num unexposed_event %9.0fc
	
	foreach var in event_num tot_num unexposed_event {
		foreach country in no se {
		
			sum `var' if country=="`country'"
			local `var'_`country' = `r(mean)'
			local `var'_`country'_f : display %9.0fc ``var'_`country'' 
			
		}
	}
	
	replace total_exp = "`event_num_no_f' / `tot_num_no_f'" if country=="no" & drug==1
	replace total_exp = "`event_num_se_f' / `tot_num_se_f'" if country=="se" & drug==1
	
	replace total_exp = "`unexposed_event_no_f' / `tot_num_no_f'" if country=="no" & drug==0
	replace total_exp = "`unexposed_event_se_f' / `tot_num_se_f'" if country=="se" & drug==0
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	
	drop events tot event_num tot_num unexposed_event seq
	
	foreach country in no se {
	
		sum total if country=="`country'"
		local total = `r(mean)'
		replace total = `total' if total==. & country=="`country'" 
		
	}
	
	* Sort out the labelling
	
	gen drug_str=""
	replace drug_str= "a_unexposed" if drug==0
	replace drug_str= "b_exposed" if drug==1
	replace drug_str= "c_sertraline" if drug==2
	replace drug_str= "d_citalopram" if drug==3
	replace drug_str= "e_fluoxetine" if drug==4
	replace drug_str= "f_escitalopram" if drug==5
	replace drug_str= "g_venlafaxine" if drug==6
	replace drug_str= "h_mirtazapine" if drug==7
	replace drug_str= "i_amitriptyline" if drug==8
	replace drug_str= "j_paroxetine" if drug==9
	replace drug_str= "k_duloxetine" if drug==10
	replace drug_str= "l_other" if drug==11
	replace drug_str= "m_Polytherapy" if drug==12
	
	sort country drug
	
	gen logrisk = log(risk)
	gen loglci = log(risk_lci)
	gen loguci = log(risk_uci)
	
	metan logrisk loglci loguci, eform by(drug_str) lcols(country total_exp) saving(preterm_risk_ma, replace) 
	
	use preterm_risk_ma, clear
	
	drop if _USE==0 | _USE==6
	
	keep if _USE!=1 & _USE!=4 & _USE!=5
	
	replace _ES = exp(_ES)
	replace _LCI = exp(_LCI)
	replace _UCI = exp(_UCI)
	
	egen seq=seq()
	
	format _ES %2.0fc
	
	forvalues x=1/13 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %3.1fc ``y'_`x'' 
			
		}		
	}
	
	* Generate variables for second axis (to make box around the graph using scatter)
	gen x=6
	gen y=0
	
	replace seq = seq+0.5 if seq>2
	replace seq = seq+0.5 if seq>11.5
	replace seq = seq+0.5 if seq>13
	
	set scheme white_w3d
	gr_setscheme
	classutil des .__SCHEME
	classutil des .__SCHEME.color
	di "`.__SCHEME.color.p3'"
	
	twoway ///
	(bar _ES seq if _BY==1, fcolor("white") horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// unexposed
	(bar _ES seq if _BY==2, fcolor(gs12) fintensity(inten50) horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// any antidepressant
	(bar _ES seq if _BY==3, fcolor("`.__SCHEME.color.p2bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p2bar'" inten100) lwidth(medium) barwidth(0.5)) /// sertraline
	(bar _ES seq if _BY==4, fcolor("`.__SCHEME.color.p3bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p3bar'" inten100) lwidth(medium) barwidth(0.5)) /// citalopram
	(bar _ES seq if _BY==5, fcolor("`.__SCHEME.color.p4bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p4bar'" inten100) lwidth(medium) barwidth(0.5)) /// fluoxetine
	(bar _ES seq if _BY==6, fcolor("`.__SCHEME.color.p11bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p11bar'" inten100) lwidth(medium) barwidth(0.5)) /// escitalopram
	(bar _ES seq if _BY==7, fcolor("`.__SCHEME.color.p10bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p10bar'" inten100) lwidth(medium) barwidth(0.5)) /// venlafaxine
	(bar _ES seq if _BY==8, fcolor("`.__SCHEME.color.p7bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p7bar'" inten100) lwidth(medium) barwidth(0.5)) /// mirtazapine
	(bar _ES seq if _BY==9, fcolor("`.__SCHEME.color.p9bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p9bar'" inten100) lwidth(medium) barwidth(0.5)) /// amitriptyline
	(bar _ES seq if _BY==10, fcolor("`.__SCHEME.color.p1bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p1bar'" inten100) lwidth(medium) barwidth(0.5)) /// paroxetine
	(bar _ES seq if _BY==11, fcolor("`.__SCHEME.color.p12bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p12bar'" inten100) lwidth(medium) barwidth(0.5)) /// duloxetine
	(bar _ES seq if _BY==12, fcolor("`.__SCHEME.color.p5bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p5bar'" inten100) lwidth(medium) barwidth(0.5)) /// other
	(bar _ES seq if _BY==13, fcolor("`.__SCHEME.color.p6bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p6bar'" inten100) lwidth(medium) barwidth(0.5)) /// polypharmacy
	(rcap _LCI _UCI seq, lcolor(black) horizontal), /// code for NO 95% CI
	text(1 13 "`_ES_1_f'% (`_LCI_1_f' – `_UCI_1_f'%)", size(*0.5) box bcolor("white") margin(t+1.25 b+1.5)) ///
	text(2 13 "`_ES_2_f'% (`_LCI_2_f' – `_UCI_2_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(3.5 13 "`_ES_3_f'% (`_LCI_3_f' – `_UCI_3_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(4.5 13 "`_ES_4_f'% (`_LCI_4_f' – `_UCI_4_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(5.5 13 "`_ES_5_f'% (`_LCI_5_f' – `_UCI_5_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(6.5 13 "`_ES_6_f'% (`_LCI_6_f' – `_UCI_6_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(7.5 13 "`_ES_7_f'% (`_LCI_7_f' – `_UCI_7_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(8.5 13 "`_ES_8_f'% (`_LCI_8_f' – `_UCI_8_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(9.5 13 "`_ES_9_f'% (`_LCI_9_f' – `_UCI_9_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(10.5 13 "`_ES_10_f'% (`_LCI_10_f' – `_UCI_10_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(11.5 13 "`_ES_11_f'% (`_LCI_11_f' – `_UCI_11_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(13 13 "`_ES_12_f'% (`_LCI_12_f' – `_UCI_12_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(14.5 13 "`_ES_13_f'% (`_LCI_13_f' – `_UCI_13_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(16.65 -8 "*Adjusted for year of birth, maternal age, previous stillbirth, parity, antipsychotic and anti-seizure medication" "use before pregnancy, depression, anxiety, practice-level IMD and ethnicity (UK), maternal educational" "attainment and country of birth (Norway and Sweden), household disposable income (Sweden), smoking" "during pregnancy (UK and Sweden), maternal BMI (Sweden), number of primary care consultations before pregnancy (UK and Norway)", size(*0.5) justification(left) placement(e)) ///
	yscale(range(1 13) reverse noline) ylabel(1 "{bf}Unexposed" 2 "{bf}Any antidepressant" 3.5 "Sertraline" 4.5 "Citalopram" 5.5 "Fluoxetine" 6.5 "Escitalopram" 7.5 "Venlafaxine" 8.5 "Mirtazapine" 9.5 "Amitriptyline" 10.5 "Paroxetine" 11.5 "Duloxetine" 13 "Other" 14.5 "Polytherapy", nogrid labsize(*0.75)) ytitle("") ///
	xscale(range(0 16) lcolor(black)) xlabel(0(2)16, labsize(*0.6) angle(45) tlcolor(black) glpattern(solid) glcolor(gs12) glwidth(0.05)) xtitle("{bf:Pooled absolute risk* (%)}", size(*0.75)) ///
	title("{bf}Preterm delivery", size(*0.5)) plotregion(margin(0 1 1 1)) ///
	yline(0, lpattern(solid) lcolor(black)) yline(0.565, lpattern(solid) lcolor(black)) ///
	legend(off) ///
	name(preterm_risk, replace) 
	
	* SGA by drug meta-analysis
	
	use "$Graphdir\data\drug analyses risk data_all3.dta", clear
	
	drop if drug==0 & country=="uk"
	
	replace drug = drug + 1 if drug>0
	
	append using "$Graphdir\data\exposed risk_no.dta"
	append using "$Graphdir\data\exposed risk_se.dta"
	append using "$Graphdir\data\exposed risk_uk.dta"
	
	foreach size in sga lga {
		
		replace outcome = "`size'" if outcome=="`size'_pct"
	
	}
	
	keep if outcome=="sga"
	
	* Sort out the counts that aren't right
	
	replace total_exp = subinstr(total_exp, ",", "", .) if drug==0 & country!="uk"
	gen events = regexs(1) if regexm(total_exp, "^([0-9]+) *(/*)") & drug==0 & country!="uk"
	gen tot = regexs(3) if regexm(total_exp, "^([0-9]+) *(/*) ([0-9]+)") & drug==0 & country!="uk"
	
	gen event_num = real(events)
	gen tot_num = real(tot)
	
	gen unexposed_event = tot_num - event_num
	
	format *_num unexposed_event %9.0fc
	
	foreach var in event_num tot_num unexposed_event {
		foreach country in no se {
		
			sum `var' if country=="`country'"
			local `var'_`country' = `r(mean)'
			local `var'_`country'_f : display %9.0fc ``var'_`country'' 
			
		}
	}
	
	replace total_exp = "`event_num_no_f' / `tot_num_no_f'" if country=="no" & drug==1
	replace total_exp = "`event_num_se_f' / `tot_num_se_f'" if country=="se" & drug==1
	
	replace total_exp = "`unexposed_event_no_f' / `tot_num_no_f'" if country=="no" & drug==0
	replace total_exp = "`unexposed_event_se_f' / `tot_num_se_f'" if country=="se" & drug==0
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	
	drop events tot event_num tot_num unexposed_event seq
	
	foreach country in no se {
	
		sum total if country=="`country'"
		local total = `r(mean)'
		replace total = `total' if total==. & country=="`country'" 
		
	}
	
	* Sort out the labelling
	
	gen drug_str=""
	replace drug_str= "a_unexposed" if drug==0
	replace drug_str= "b_exposed" if drug==1
	replace drug_str= "c_sertraline" if drug==2
	replace drug_str= "d_citalopram" if drug==3
	replace drug_str= "e_fluoxetine" if drug==4
	replace drug_str= "f_escitalopram" if drug==5
	replace drug_str= "g_venlafaxine" if drug==6
	replace drug_str= "h_mirtazapine" if drug==7
	replace drug_str= "i_amitriptyline" if drug==8
	replace drug_str= "j_paroxetine" if drug==9
	replace drug_str= "k_duloxetine" if drug==10
	replace drug_str= "l_other" if drug==11
	replace drug_str= "m_Polytherapy" if drug==12
	
	sort country drug
	
	gen logrisk = log(risk)
	gen loglci = log(risk_lci)
	gen loguci = log(risk_uci)
	
	metan logrisk loglci loguci, eform by(drug_str) lcols(country total_exp) saving(sga_risk_ma, replace)
	
	use sga_risk_ma, clear
	
	drop if _USE==0 | _USE==6
	
	keep if _USE!=1 & _USE!=4 & _USE!=5
	
	replace _ES = exp(_ES)
	replace _LCI = exp(_LCI)
	replace _UCI = exp(_UCI)
	
	egen seq=seq()
	
	format _ES %2.0fc
	
	forvalues x=1/13 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %3.1fc ``y'_`x'' 
			
		}		
	}
	
	* Generate variables for second axis (to make box around the graph using scatter)
	gen x=6
	gen y=0
	
	replace seq = seq+0.5 if seq>2
	replace seq = seq+0.5 if seq>11.5
	replace seq = seq+0.5 if seq>13
	
	twoway ///
	(bar _ES seq if _BY==1, fcolor("white") horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// unexposed
	(bar _ES seq if _BY==2, fcolor(gs12) fintensity(inten50) horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// any antidepressant
	(bar _ES seq if _BY==3, fcolor("`.__SCHEME.color.p2bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p2bar'" inten100) lwidth(medium) barwidth(0.5)) /// sertraline
	(bar _ES seq if _BY==4, fcolor("`.__SCHEME.color.p3bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p3bar'" inten100) lwidth(medium) barwidth(0.5)) /// citalopram
	(bar _ES seq if _BY==5, fcolor("`.__SCHEME.color.p4bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p4bar'" inten100) lwidth(medium) barwidth(0.5)) /// fluoxetine
	(bar _ES seq if _BY==6, fcolor("`.__SCHEME.color.p11bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p11bar'" inten100) lwidth(medium) barwidth(0.5)) /// escitalopram
	(bar _ES seq if _BY==7, fcolor("`.__SCHEME.color.p10bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p10bar'" inten100) lwidth(medium) barwidth(0.5)) /// venlafaxine
	(bar _ES seq if _BY==8, fcolor("`.__SCHEME.color.p7bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p7bar'" inten100) lwidth(medium) barwidth(0.5)) /// mirtazapine
	(bar _ES seq if _BY==9, fcolor("`.__SCHEME.color.p9bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p9bar'" inten100) lwidth(medium) barwidth(0.5)) /// amitriptyline
	(bar _ES seq if _BY==10, fcolor("`.__SCHEME.color.p1bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p1bar'" inten100) lwidth(medium) barwidth(0.5)) /// paroxetine
	(bar _ES seq if _BY==11, fcolor("`.__SCHEME.color.p12bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p12bar'" inten100) lwidth(medium) barwidth(0.5)) /// duloxetine
	(bar _ES seq if _BY==12, fcolor("`.__SCHEME.color.p5bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p5bar'" inten100) lwidth(medium) barwidth(0.5)) /// other
	(bar _ES seq if _BY==13, fcolor("`.__SCHEME.color.p6bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p6bar'" inten100) lwidth(medium) barwidth(0.5)) /// polypharmacy
	(rcap _LCI _UCI seq, lcolor(black) horizontal), /// code for NO 95% CI
	text(1 3.5 "`_ES_1_f'% (`_LCI_1_f' – `_UCI_1_f'%)", size(*0.5)) ///
	text(2 3.5 "`_ES_2_f'% (`_LCI_2_f' – `_UCI_2_f'%)", size(*0.5)) ///
	text(3.5 3.5 "`_ES_3_f'% (`_LCI_3_f' – `_UCI_3_f'%)", size(*0.5)) ///
	text(4.5 3.5 "`_ES_4_f'% (`_LCI_4_f' – `_UCI_4_f'%)", size(*0.5)) ///
	text(5.5 3.5 "`_ES_5_f'% (`_LCI_5_f' – `_UCI_5_f'%)", size(*0.5)) ///
	text(6.5 3.5 "`_ES_6_f'% (`_LCI_6_f' – `_UCI_6_f'%)", size(*0.5)) ///
	text(7.5 3.5 "`_ES_7_f'% (`_LCI_7_f' – `_UCI_7_f'%)", size(*0.5)) ///
	text(8.5 3.5 "`_ES_8_f'% (`_LCI_8_f' – `_UCI_8_f'%)", size(*0.5)) ///
	text(9.5 3.5 "`_ES_9_f'% (`_LCI_9_f' – `_UCI_9_f'%)", size(*0.5)) ///
	text(10.5 3.5 "`_ES_10_f'% (`_LCI_10_f' – `_UCI_10_f'%)", size(*0.5)) ///
	text(11.5 3.5 "`_ES_11_f'% (`_LCI_11_f' – `_UCI_11_f'%)", size(*0.5)) ///
	text(13 3.5 "`_ES_12_f'% (`_LCI_12_f' – `_UCI_12_f'%)", size(*0.5)) ///
	text(14.5 3.5 "`_ES_13_f'% (`_LCI_13_f' – `_UCI_13_f'%)", size(*0.5)) ///
	yscale(range(1 12) reverse) ylabel("") ytitle("") yline(0, lpattern(solid) lcolor(black)) yline(0.565, lpattern(solid) lcolor(black)) ///
	xscale(range(0 16) lc(black)) xlabel(0(2)16, labsize(*0.6) angle(45) tlcolor(black) glpattern(solid) glcolor(gs12) glwidth(0.05)) xtitle("{bf:Pooled absolute risk* (%)}", size(*0.75)) ///
	title("{bf}Small for gestational age", size(*0.5)) plotregion(margin(0 1 1 1)) ///
	legend(off) ///
	fxsize(36.5) fysize(100) name(sga_risk, replace)
	
	* Apgar by drug meta-analysis
	
	use "$Graphdir\data\drug analyses risk data_all3.dta", clear
	
	drop if drug==0 & country=="uk"
	
	replace drug = drug + 1 if drug>0
	
	append using "$Graphdir\data\exposed risk_no.dta"
	append using "$Graphdir\data\exposed risk_se.dta"
	append using "$Graphdir\data\exposed risk_uk.dta"
	
	* Preterm by drug meta-analysis
	
	keep if outcome=="apgar5_bin"
	
	* Sort out the counts that aren't right
	
	replace total_exp = subinstr(total_exp, ",", "", .) if drug==0 & country!="uk"
	gen events = regexs(1) if regexm(total_exp, "^([0-9]+) *(/*)") & drug==0 & country!="uk"
	gen tot = regexs(3) if regexm(total_exp, "^([0-9]+) *(/*) ([0-9]+)") & drug==0 & country!="uk"
	
	gen event_num = real(events)
	gen tot_num = real(tot)
	
	gen unexposed_event = tot_num - event_num
	
	format *_num unexposed_event %9.0fc
	
	foreach var in event_num tot_num unexposed_event {
		foreach country in no se {
		
			sum `var' if country=="`country'"
			local `var'_`country' = `r(mean)'
			local `var'_`country'_f : display %9.0fc ``var'_`country'' 
			
		}
	}
	
	replace total_exp = "`event_num_no_f' / `tot_num_no_f'" if country=="no" & drug==1
	replace total_exp = "`event_num_se_f' / `tot_num_se_f'" if country=="se" & drug==1
	
	replace total_exp = "`unexposed_event_no_f' / `tot_num_no_f'" if country=="no" & drug==0
	replace total_exp = "`unexposed_event_se_f' / `tot_num_se_f'" if country=="se" & drug==0
	
	replace total_exp = subinstr(total_exp, " ", "", .)
	replace total_exp = subinstr(total_exp, "/", " / ", .)
	
	drop events tot event_num tot_num unexposed_event seq
	
	foreach country in no se {
	
		sum total if country=="`country'"
		local total = `r(mean)'
		replace total = `total' if total==. & country=="`country'" 
		
	}
	
	* Sort out the labelling
	
	gen drug_str=""
	replace drug_str= "a_unexposed" if drug==0
	replace drug_str= "b_exposed" if drug==1
	replace drug_str= "c_sertraline" if drug==2
	replace drug_str= "d_citalopram" if drug==3
	replace drug_str= "e_fluoxetine" if drug==4
	replace drug_str= "f_escitalopram" if drug==5
	replace drug_str= "g_venlafaxine" if drug==6
	replace drug_str= "h_mirtazapine" if drug==7
	replace drug_str= "i_amitriptyline" if drug==8
	replace drug_str= "j_paroxetine" if drug==9
	replace drug_str= "k_duloxetine" if drug==10
	replace drug_str= "l_other" if drug==11
	replace drug_str= "m_Polytherapy" if drug==12
	
	sort country drug
	
	gen logrisk = log(risk)
	gen loglci = log(risk_lci)
	gen loguci = log(risk_uci)
	
	metan logrisk loglci loguci, eform by(drug_str) lcols(country total_exp) saving(apgar_risk_ma, replace)
	
	use apgar_risk_ma, clear
	
	drop if _USE==0 | _USE==6
	
	keep if _USE!=1 & _USE!=4 & _USE!=5
	
	replace _ES = exp(_ES)
	replace _LCI = exp(_LCI)
	replace _UCI = exp(_UCI)
	
	egen seq=seq()
	
	format _ES %2.0fc
	
	forvalues x=1/13 {
		foreach y in _ES _LCI _UCI {
		
			sum `y' if seq==`x'
			local `y'_`x' = `r(mean)'
			local `y'_`x'_f : display %3.1fc ``y'_`x'' 
			
		}		
	}
	
	* Generate variables for second axis (to make box around the graph using scatter)
	gen x=6
	gen y=0
	
	replace seq = seq+0.5 if seq>2
	replace seq = seq+0.5 if seq>11.5
	replace seq = seq+0.5 if seq>13
	
	twoway ///
	(bar _ES seq if _BY==1, fcolor("white") horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// unexposed
	(bar _ES seq if _BY==2, fcolor(gs12) fintensity(inten50) horizontal lcolor(gs12 inten100) lwidth(medium) barwidth(0.5)) /// any antidepressant
	(bar _ES seq if _BY==3, fcolor("`.__SCHEME.color.p2bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p2bar'" inten100) lwidth(medium) barwidth(0.5)) /// sertraline
	(bar _ES seq if _BY==4, fcolor("`.__SCHEME.color.p3bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p3bar'" inten100) lwidth(medium) barwidth(0.5)) /// citalopram
	(bar _ES seq if _BY==5, fcolor("`.__SCHEME.color.p4bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p4bar'" inten100) lwidth(medium) barwidth(0.5)) /// fluoxetine
	(bar _ES seq if _BY==6, fcolor("`.__SCHEME.color.p11bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p11bar'" inten100) lwidth(medium) barwidth(0.5)) /// escitalopram
	(bar _ES seq if _BY==7, fcolor("`.__SCHEME.color.p10bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p10bar'" inten100) lwidth(medium) barwidth(0.5)) /// venlafaxine
	(bar _ES seq if _BY==8, fcolor("`.__SCHEME.color.p7bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p7bar'" inten100) lwidth(medium) barwidth(0.5)) /// mirtazapine
	(bar _ES seq if _BY==9, fcolor("`.__SCHEME.color.p9bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p9bar'" inten100) lwidth(medium) barwidth(0.5)) /// amitriptyline
	(bar _ES seq if _BY==10, fcolor("`.__SCHEME.color.p1bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p1bar'" inten100) lwidth(medium) barwidth(0.5)) /// paroxetine
	(bar _ES seq if _BY==11, fcolor("`.__SCHEME.color.p12bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p12bar'" inten100) lwidth(medium) barwidth(0.5)) /// duloxetine
	(bar _ES seq if _BY==12, fcolor("`.__SCHEME.color.p5bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p5bar'" inten100) lwidth(medium) barwidth(0.5)) /// other
	(bar _ES seq if _BY==13, fcolor("`.__SCHEME.color.p6bar'") fintensity(inten50) horizontal lcolor("`.__SCHEME.color.p6bar'" inten100) lwidth(medium) barwidth(0.5)) /// polypharmacy
	(rcap _LCI _UCI seq, lcolor(black) horizontal), /// code for NO 95% CI
	yscale(range(1 12) reverse) ylabel("") ytitle("") yline(0, lpattern(solid) lcolor(black)) yline(0.565, lpattern(solid) lcolor(black)) ///
	xscale(range(0 16) lc(black)) xlabel(0(2)16, labsize(*0.6) angle(45) tlcolor(black) glpattern(solid) glcolor(gs12) glwidth(0.05)) xtitle("{bf:Pooled absolute risk* (%)}", size(*0.75)) ///
	title("{bf}Apgar score < 7{sup:‡}", size(*0.5)) plotregion(margin(0 1 1 1)) ///
	text(1 13 "`_ES_1_f'% (`_LCI_1_f' – `_UCI_1_f'%)", size(*0.5) box bcolor("white") margin(t+1.25 b+1.5)) ///
	text(2 13 "`_ES_2_f'% (`_LCI_2_f' – `_UCI_2_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(3.5 13 "`_ES_3_f'% (`_LCI_3_f' – `_UCI_3_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(4.5 13 "`_ES_4_f'% (`_LCI_4_f' – `_UCI_4_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(5.5 13 "`_ES_5_f'% (`_LCI_5_f' – `_UCI_5_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(6.5 13 "`_ES_6_f'% (`_LCI_6_f' – `_UCI_6_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(7.5 13 "`_ES_7_f'% (`_LCI_7_f' – `_UCI_7_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(8.5 13 "`_ES_8_f'% (`_LCI_8_f' – `_UCI_8_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(9.5 13 "`_ES_9_f'% (`_LCI_9_f' – `_UCI_9_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(10.5 13 "`_ES_10_f'% (`_LCI_10_f' – `_UCI_10_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(11.5 13 "`_ES_11_f'% (`_LCI_11_f' – `_UCI_11_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(13 13 "`_ES_12_f'% (`_LCI_12_f' – `_UCI_12_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(14.5 13 "`_ES_13_f'% (`_LCI_13_f' – `_UCI_13_f'%)", size(*0.5) box bcolor("white") margin(t+1.5 b+1.5)) ///
	text(16.5 0 "{sup:‡}Norway and Sweden only", size(*0.5) justification(left) placement(e)) ///
	legend(off) ///
	fxsize(36.5) fysize(100) name(apgar_risk, replace)
	
	graph combine preterm_risk sga_risk apgar_risk, col(3) title("{bf}Drug-specific adjusted absolute risk pooled across the UK, Norway, & Sweden", size(*0.65)) name(risk_all3, replace)
	
	graph export "C:\Users\ti19522\OneDrive - University of Bristol\Flo Martin Supervisory Team\Year 4\6_Birth outcomes\ch6_drug_risk_fig.pdf", replace

	
	/* Erase unnecessary datasets

	erase "$Graphdir\preterm_risk_ma.dta"
	erase "$Graphdir\sga_risk_ma.dta"
	erase "$Graphdir\apgar_risk_ma.dta" */