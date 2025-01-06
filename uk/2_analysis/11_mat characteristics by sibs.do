/********************************************************************************

* Creating table 1 for birth outcomes paper - characteristics of patients in the study

* Author: Flo Martin 

* Date: 06/04/2023

********************************************************************************

* Supplementary table of maternal characteristics by sibling groups in birth outcomes paper is created by this script

********************************************************************************/

* Start logging 

	log using "$Logdir\2_analysis\11_characteristics by sibs", name(characteristics_by_sibs) replace
	
********************************************************************************

	* Generic code to output one row of table
	cap prog drop generaterow

	program define generaterow
		
		syntax, variable(varname) condition(string) outcome(string)
	
		* Put the varname and condition to left so that alignment can be checked vs shell
		file write tablecontent "" _tab 
		
		cou
		local overalldenom=r(N)
		
		cou if `variable' `condition'
		local rowdenom = r(N)
		local colpct = 100*(r(N)/`overalldenom')
		file write tablecontent %11.0fc (`rowdenom') (" (") %4.1f (`colpct') (")") _tab

		cou if family_exposed==2
		local coldenom = r(N)
		cou if family_exposed==2 & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		file write tablecontent %11.0fc (r(N)) (" (") %4.1f (`pct') (")") _tab
		
		cou if family_exposed==1 
		local coldenom = r(N)
		cou if family_exposed==1 & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		file write tablecontent %11.0fc (r(N)) (" (") %4.1f (`pct') (")") _tab

		cou if family_exposed==0 
		local coldenom = r(N)
		cou if family_exposed==0 & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		file write tablecontent %11.0fc (r(N)) (" (") %4.1f (`pct') (")") _n
	
	end


********************************************************************************

* Generic code to output one section (varible) within table (calls above)

	cap prog drop tabulatevariable
	prog define tabulatevariable
		
		syntax, variable(varname) start(real) end(real) [missing] outcome(string)

		foreach varlevel of numlist `start'/`end'{ 
		
			generaterow, variable(`variable') condition("==`varlevel'") outcome(family_exposed)
	
		}
	
		if "`missing'"!="" generaterow, variable(`variable') condition(">=.") outcome(family_exposed)

	end

********************************************************************************

* Set up output file

		use "$Deriveddir\sibling_analysis.dta", clear
		
		preserve
		
			keep patid pregid any_preg
			sort patid pregid
			
			bysort patid: egen pregnum = seq()
			bysort patid: egen max_pregs = max(pregnum)
			bysort patid: egen exposed_pregs = sum(any_preg)
			
			keep patid pregid max_pregs exposed_pregs
			duplicates drop
			
			gen family_exposed =.
			replace family_exposed = 0 if exposed_pregs==0
			replace family_exposed = 1 if exposed_pregs>0 & exposed_pregs<max_pregs
			replace family_exposed = 2 if exposed_pregs==max_pregs
			
			tab family_exposed
			
			save "$Tempdatadir\family_exposure.dta", replace
			
		restore 
		
		merge 1:1 patid pregid using "$Tempdatadir\family_exposure.dta", nogen
		
		drop if max_pregs==1
		
		recode mother_ethn .=9
		recode mother_bmi_cat .=9
		recode smoke_preg .=9
		recode grav_hist_sb .=9
		recode spont_labour .=9 

*********************************************************************************
* 2 - Prepare formats for data for output
*********************************************************************************

		cap file close tablecontent
		file open tablecontent using "$Tabledir\maternal characteristics by sibs.txt", write text replace

		file write tablecontent "Variable" _tab "Total" _tab "Always used antidepressants during pregnancy" _tab "Sometimes used antidepressants during pregnancy" _tab "Never used antidepressants during pregnancy" _n
		
		file write tablecontent "Total" 
		gen byte total=1
		tabulatevariable, variable(total) start(1) end(1) outcome(family_exposed)
		
*********************************************************************************

* Year of pregnancy
		
		file write tablecontent "Year of birth" _n

		file write tablecontent "1996-1999" 
		tabulatevariable, variable(birth_yr_cat) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "2000-2004" 
		tabulatevariable, variable(birth_yr_cat) start(2) end(2) outcome(family_exposed) 
		
		file write tablecontent "2005-2009" 
		tabulatevariable, variable(birth_yr_cat) start(3) end(3) outcome(family_exposed)
		
		file write tablecontent "2010-2015" 
		tabulatevariable, variable(birth_yr_cat) start(4) end(4) outcome(family_exposed) 
		
		file write tablecontent "2016-2019" 
		tabulatevariable, variable(birth_yr_cat) start(5) end(5) outcome(family_exposed) 
	
*********************************************************************************

* Maternal age
	
		file write tablecontent "Maternal age at start of pregnancy" _n
		
		file write tablecontent "<20" 
		tabulatevariable, variable(mother_age_cat) start(0) end(0) outcome(family_exposed) 
		
		file write tablecontent "20-24" 
		tabulatevariable, variable(mother_age_cat) start(1) end(1) outcome(family_exposed) 
		
		file write tablecontent "25-29" 
		tabulatevariable, variable(mother_age_cat) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "30-34" 
		tabulatevariable, variable(mother_age_cat) start(3) end(3) outcome(family_exposed) 
		
		file write tablecontent "35-39" 
		tabulatevariable, variable(mother_age_cat) start(4) end(4) outcome(family_exposed)
		
		file write tablecontent "40-44" 
		tabulatevariable, variable(mother_age_cat) start(5) end(5) outcome(family_exposed)
		
		file write tablecontent "45+" 
		tabulatevariable, variable(mother_age_cat) start(6) end(6) outcome(family_exposed)
		
*********************************************************************************

* Maternal educational attainment - not available in UK

	file write tablecontent "Maternal educational attainment at the start of pregnancy" _n
	file write tablecontent "Compulsory or less" _n
	file write tablecontent "Secondary" _n
	file write tablecontent "Post-secondary" _n
	file write tablecontent "Post-graduate" _n
	file write tablecontent "Missing (likely educated overseas)" _n

*********************************************************************************

* Practice index of multiple deprivation
		
		file write tablecontent "Practice IMD (in quintiles)" _n

		file write tablecontent "1" 
		tabulatevariable, variable(imd_practice) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "2" 
		tabulatevariable, variable(imd_practice) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "3" 
		tabulatevariable, variable(imd_practice) start(3) end(3) outcome(family_exposed)
		
		file write tablecontent "4" 
		tabulatevariable, variable(imd_practice) start(4) end(4) outcome(family_exposed)
		
		file write tablecontent "5" 
		tabulatevariable, variable(imd_practice) start(5) end(5) outcome(family_exposed)
	
*********************************************************************************

* Maternal country of birth - not available in UK

	file write tablecontent "Maternal country of birth" _n
	file write tablecontent "Non-UK-born" _n
	file write tablecontent "Missing" _n

*********************************************************************************

* Maternal ethnicity		
		
		file write tablecontent "Maternal ethnicity" _n

		file write tablecontent "White" 
		tabulatevariable, variable(mother_ethn) start(0) end(0) outcome(family_exposed)
		
		file write tablecontent "South Asian" 
		tabulatevariable, variable(mother_ethn) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Black" 
		tabulatevariable, variable(mother_ethn) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "Other" 
		tabulatevariable, variable(mother_ethn) start(3) end(3) outcome(family_exposed)
		
		file write tablecontent "Mixed" 
		tabulatevariable, variable(mother_ethn) start(4) end(4) outcome(family_exposed)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(mother_ethn) start(9) end(9) outcome(family_exposed)
		
*********************************************************************************

* Maternal body mass index
		
		file write tablecontent "Maternal body mass index (BMI)" _n

		file write tablecontent "Underweight (<18.5 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(0) end(0) outcome(family_exposed)
		
		file write tablecontent "Healthy weight (18.5-24.9 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Overweight (25.0-29.9 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "Obese (>=30.0 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(3) end(3) outcome(family_exposed)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(mother_bmi_cat) start(9) end(9) outcome(family_exposed)
		
*********************************************************************************

* Smoking status during pregnancy

		file write tablecontent "Maternal smoking during pregnancy" _n
		
		file write tablecontent "Smoker"
		tabulatevariable, variable(smoke_preg) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "Missing"
		tabulatevariable, variable(smoke_preg) start(9) end(9) outcome(family_exposed)
		
*********************************************************************************
		
* History of stillbirth
		
		file write tablecontent "Maternal history of stillbirth at the start of pregnancy" _n

		file write tablecontent "History of stillbirth" 
		tabulatevariable, variable(grav_hist_sb) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(grav_hist_sb) start(9) end(9) outcome(family_exposed)
		
*********************************************************************************

* Parity

		file write tablecontent "Maternal parity at the start of pregnancy" _n
		
		file write tablecontent "0"
		tabulatevariable, variable(parity) start(0) end(0) outcome(family_exposed)
		
		file write tablecontent "1"
		tabulatevariable, variable(parity) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "2"
		tabulatevariable, variable(parity) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent "3"
		tabulatevariable, variable(parity) start(3) end(3) outcome(family_exposed)
		
		file write tablecontent "4+"
		tabulatevariable, variable(parity) start(4) end(4) outcome(family_exposed)
		
*********************************************************************************

* Maternal indications for antidepressants
		
		file write tablecontent "Maternal antidepressant indications ever before pregnancy" _n

		file write tablecontent "Depression" 
		tabulatevariable, variable(depression) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Anxiety" 
		tabulatevariable, variable(anxiety) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Eating disorders" 
		tabulatevariable, variable(ed) start(1) end(1) outcome(family_exposed)
		
*********************************************************************************

* Other indications for antidepressants
		
		file write tablecontent "Other possible indications for antidepressants" _n

		file write tablecontent "Other affective disorders" 
		tabulatevariable, variable(mood) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Diabetic neuropathy" 
		tabulatevariable, variable(dn) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Migraine prophylaxis" 
		tabulatevariable, variable(migraine) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Narcolepsy with cataplexy" _n
		
		file write tablecontent "Pain" 
		tabulatevariable, variable(pain) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Stress incontinence" 
		tabulatevariable, variable(incont) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Tension-type headache" 
		tabulatevariable, variable(headache) start(1) end(1) outcome(family_exposed)
		
*********************************************************************************

/* Other maternal comorbidities
		
		file write tablecontent "Chronic illness ever before pregnancy" _n

		file write tablecontent "Asthma" _n 
		
		file write tablecontent "Chronic hypertension" 
		tabulatevariable, variable(hypbp) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Chronic renal disease" _n 
		
		file write tablecontent "Epilepsy" _n 
		
		file write tablecontent "Chronic diabetes" 
		tabulatevariable, variable(diab) start(1) end(1) outcome(family_exposed)
		
*********************************************************************************/

* Other prescriptions in the 12 months prior to pregnancy

		file write tablecontent "Other mental health-related prescriptions in 12 months before pregnancy" _n
		
		file write tablecontent "Antipsychotics" 
		tabulatevariable, variable(ap_12mo) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Anti-seizure medications" 
		tabulatevariable, variable(asm_12mo) start(1) end(1) outcome(family_exposed) 
		
*********************************************************************************

* Number of CPRD consultations in the 12 months prior to pregnancy
		
		file write tablecontent "Primary care consultations in the 12 months before pregnancy" _n
		
		file write tablecontent "0" 
		tabulatevariable, variable(healthcare_util_12mo_cat) start(0) end(0) outcome(family_exposed)
		
		file write tablecontent "1-3" 
		tabulatevariable, variable(healthcare_util_12mo_cat) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "4-10" 
		tabulatevariable, variable(healthcare_util_12mo_cat) start(2) end(2) outcome(family_exposed)
		
		file write tablecontent ">10" 
		tabulatevariable, variable(healthcare_util_12mo_cat) start(3) end(3) outcome(family_exposed)
	
*********************************************************************************

* Supplement use pre-pregnancy

		file write tablecontent "Supplement use reported before pregnancy" _n
		
		file write tablecontent "Folic acid" 
		tabulatevariable, variable(folate_before) start(1) end(1) outcome(family_exposed)
		
*********************************************************************************

* Iniiation of labour
		
		file write tablecontent "Initiation of labour" _n
		
		file write tablecontent "Induced" 
		tabulatevariable, variable(spont_labour) start(1) end(1) outcome(family_exposed)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(spont_labour) start(9) end(9) outcome(family_exposed)
		
*********************************************************************************

* End of table
		
		file close tablecontent
		
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close characteristics_by_sibs
	
	translate "$Logdir\2_analysis\11_characteristics by sibs.smcl" "$Logdir\2_analysis\11_characteristics by sibs.pdf", replace
	
	erase "$Logdir\2_analysis\11_characteristics by sibs.smcl"
	
*********************************************************************************
