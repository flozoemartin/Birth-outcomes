
use "$Graphdir\data\right trunc analyses data_all3.dta", clear

	gen logor = log(or)
	gen loglci = log(lci)
	gen loguci = log(uci)
	
	metan logor loglci loguci, eform by(outcome) lcols(country total_exp total_unexp) saving(supp_righttrunc_ma, replace)
	
	cd "$Graphdir"
	use supp_righttrunc_ma, clear
	
	bys _BY _USE : egen grp_wt = sum(_WT)
	gen pct_grp_wt = 100 * _WT / grp_wt
	
	drop _WT
	rename pct_grp_wt _WT
	
	drop if _USE>=4 & _USE<6
	*drop if _BY==2 & _USE==3
	
	replace _LABELS = "Post-term delivery" if _LABELS=="a_postterm"
	
	replace _LABELS = "UK" if _LABELS=="uk"
	replace _LABELS = "Norway" if _LABELS=="no"
	replace _LABELS = "Sweden" if _LABELS=="se"
	
	replace _LABELS = `"{bf:"' + _LABELS + `"}"' if _USE==0
	label variable _LABELS `"`"{bf: Post-term among those with full follow-up}"'"'
	label variable total_exp `"`"{bf:Exposed n/N}"'"'
	label variable total_unexp `"`"{bf:Unexposed n/N}"'"'
	label variable _WT `"`"{bf: Weight}"' `"(%)"'"'
	
	format _ES %4.1fc
	format _WT %4.1fc
	
	*drop if _USE==1
	
	gen country=1 if _LABELS=="UK"
	replace country=2 if _LABELS=="Norway"
	replace country=3 if _LABELS=="Sweden"

	forestplot, eform effect("{bf}Odds ratio") null(1) olineopts(lcolor(none)) nlineopts(lcolor(cranberry) lpattern(dash)) xlabel(0.5(0.25)2.5) lcols(total_exp total_unexp) title("{bf}Post-term delivery those with full follow-up sensitivity analysis", size(small)) ///
	plotid(country, list) point1opts(msymbol(triangle) msize(0.75)) point2opts(msymbol(circle) msize(0.75)) point3opts(msymbol(diamond) msize(0.75)) ///
	noadjust savedims(A) name(righttrunc_ma, replace)
	
	cd "$Graphdir"
	graph export righttrunc_ma.pdf, replace
	
	erase "$Graphdir\supp_righttrunc_ma.dta"