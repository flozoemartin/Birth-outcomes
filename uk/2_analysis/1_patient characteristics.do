********************************************************************************

* Creating table 1 for the UK-arm of the birth outcomes paper - characteristics of the UK individuals in the study

* Author: Flo Martin 

* Date: 30/08/2024

********************************************************************************

* Columns two and three of table 1 in birth outcomes paper is created by this script

********************************************************************************

* Start logging 

	log using "$Logdir\2_analysis\1_patient characteristics", name(patient_characteristics) replace
	
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

		cou if any_preg==1 
		local coldenom = r(N)
		cou if any_preg==1 & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		file write tablecontent %11.0fc (r(N)) (" (") %4.1f (`pct') (")") _tab

		cou if any_preg==0 
		local coldenom = r(N)
		cou if any_preg==0 & `variable' `condition'
		local pct = 100*(r(N)/`coldenom')
		file write tablecontent %11.0fc (r(N)) (" (") %4.1f (`pct') (")") _n
	
	end


********************************************************************************

* Generic code to output one section (varible) within table (calls above)

	cap prog drop tabulatevariable
	prog define tabulatevariable
		
		syntax, variable(varname) start(real) end(real) [missing] outcome(string)

		foreach varlevel of numlist `start'/`end'{ 
		
			generaterow, variable(`variable') condition("==`varlevel'") outcome(any_preg)
	
		}
	
		if "`missing'"!="" generaterow, variable(`variable') condition(">=.") outcome(any_preg)

	end

********************************************************************************

* Set up output file

		use "$Datadir\primary_analysis_dataset.dta", clear
		recode mother_ethn .=9
		recode mother_bmi_cat .=9
		recode smoke_preg .=9
		recode grav_hist_sb .=9
		recode spont_labour .=9 

********************************************************************************
* 2 - Prepare formats for data for output
********************************************************************************

		cap file close tablecontent
		file open tablecontent using "$Tabledir\characteristics table.txt", write text replace

		file write tablecontent "Variable" _tab "Total" _tab "Exposed to antidepressants during pregnancy" _tab "Unexposed to antidepressants during pregnancy" _n
		
		file write tablecontent "Total" 
		gen byte total=1
		tabulatevariable, variable(total) start(1) end(1) outcome(any_preg)
		
********************************************************************************

* Year of pregnancy
		
		file write tablecontent "Year of birth" _n

		file write tablecontent "1996-1999" 
		tabulatevariable, variable(birth_yr_cat) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "2000-2004" 
		tabulatevariable, variable(birth_yr_cat) start(2) end(2) outcome(any_preg) 
		
		file write tablecontent "2005-2009" 
		tabulatevariable, variable(birth_yr_cat) start(3) end(3) outcome(any_preg)
		
		file write tablecontent "2010-2015" 
		tabulatevariable, variable(birth_yr_cat) start(4) end(4) outcome(any_preg) 
		
		file write tablecontent "2016-2019" 
		tabulatevariable, variable(birth_yr_cat) start(5) end(5) outcome(any_preg) 
	
********************************************************************************

* Maternal age
	
		file write tablecontent "Maternal age at start of pregnancy" _n
		
		file write tablecontent "<20" 
		tabulatevariable, variable(mother_age_cat) start(0) end(0) outcome(any_preg) 
		
		file write tablecontent "20-24" 
		tabulatevariable, variable(mother_age_cat) start(1) end(1) outcome(any_preg) 
		
		file write tablecontent "25-29" 
		tabulatevariable, variable(mother_age_cat) start(2) end(2) outcome(any_preg)
		
		file write tablecontent "30-34" 
		tabulatevariable, variable(mother_age_cat) start(3) end(3) outcome(any_preg) 
		
		file write tablecontent "35-39" 
		tabulatevariable, variable(mother_age_cat) start(4) end(4) outcome(any_preg)
		
		file write tablecontent "40-44" 
		tabulatevariable, variable(mother_age_cat) start(5) end(5) outcome(any_preg)
		
		file write tablecontent "45+" 
		tabulatevariable, variable(mother_age_cat) start(6) end(6) outcome(any_preg)
		
********************************************************************************

* Maternal educational attainment - not available in UK

	file write tablecontent "Maternal educational attainment at the start of pregnancy" _n
	file write tablecontent "Compulsory or less" _n
	file write tablecontent "Secondary" _n
	file write tablecontent "Post-secondary" _n
	file write tablecontent "Post-graduate" _n
	file write tablecontent "Missing (likely educated overseas)" _n

********************************************************************************

* Practice index of multiple deprivation
		
		file write tablecontent "Practice IMD (in quintiles)" _n

		file write tablecontent "1" 
		tabulatevariable, variable(imd_practice) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "2" 
		tabulatevariable, variable(imd_practice) start(2) end(2) outcome(any_preg)
		
		file write tablecontent "3" 
		tabulatevariable, variable(imd_practice) start(3) end(3) outcome(any_preg)
		
		file write tablecontent "4" 
		tabulatevariable, variable(imd_practice) start(4) end(4) outcome(any_preg)
		
		file write tablecontent "5" 
		tabulatevariable, variable(imd_practice) start(5) end(5) outcome(any_preg)
	
********************************************************************************

* Maternal country of birth - not available in UK

	file write tablecontent "Maternal country of birth" _n
	file write tablecontent "Non-UK-born" _n
	file write tablecontent "Missing" _n

********************************************************************************

* Maternal ethnicity		
		
		file write tablecontent "Maternal ethnicity" _n

		file write tablecontent "White" 
		tabulatevariable, variable(mother_ethn) start(0) end(0) outcome(any_preg)
		
		file write tablecontent "South Asian" 
		tabulatevariable, variable(mother_ethn) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Black" 
		tabulatevariable, variable(mother_ethn) start(2) end(2) outcome(any_preg)
		
		file write tablecontent "Other" 
		tabulatevariable, variable(mother_ethn) start(3) end(3) outcome(any_preg)
		
		file write tablecontent "Mixed" 
		tabulatevariable, variable(mother_ethn) start(4) end(4) outcome(any_preg)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(mother_ethn) start(9) end(9) outcome(any_preg)
		
********************************************************************************

* Maternal body mass index
		
		file write tablecontent "Maternal body mass index (BMI)" _n

		file write tablecontent "Underweight (<18.5 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(0) end(0) outcome(any_preg)
		
		file write tablecontent "Healthy weight (18.5-24.9 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Overweight (25.0-29.9 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(2) end(2) outcome(any_preg)
		
		file write tablecontent "Obese (>=30.0 kg/m^2)" 
		tabulatevariable, variable(mother_bmi_cat) start(3) end(3) outcome(any_preg)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(mother_bmi_cat) start(9) end(9) outcome(any_preg)
		
********************************************************************************

* Smoking status during pregnancy

		file write tablecontent "Maternal smoking during pregnancy" _n
		
		file write tablecontent "Smoker"
		tabulatevariable, variable(smoke_preg) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Missing"
		tabulatevariable, variable(smoke_preg) start(9) end(9) outcome(any_preg)
		
********************************************************************************
		
* History of stillbirth
		
		file write tablecontent "Maternal history of stillbirth at the start of pregnancy" _n

		file write tablecontent "History of stillbirth" 
		tabulatevariable, variable(grav_hist_sb) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(grav_hist_sb) start(9) end(9) outcome(any_preg)
		
********************************************************************************

* Parity

		file write tablecontent "Maternal parity at the start of pregnancy" _n
		
		file write tablecontent "0"
		tabulatevariable, variable(parity) start(0) end(0) outcome(any_preg)
		
		file write tablecontent "1"
		tabulatevariable, variable(parity) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "2"
		tabulatevariable, variable(parity) start(2) end(2) outcome(any_preg)
		
		file write tablecontent "3"
		tabulatevariable, variable(parity) start(3) end(3) outcome(any_preg)
		
		file write tablecontent "4+"
		tabulatevariable, variable(parity) start(4) end(4) outcome(any_preg)
		
********************************************************************************

* Maternal indications for antidepressants
		
		file write tablecontent "Maternal antidepressant indications ever before pregnancy" _n

		file write tablecontent "Depression" 
		tabulatevariable, variable(depression) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Anxiety" 
		tabulatevariable, variable(anxiety) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Eating disorders" 
		tabulatevariable, variable(ed) start(1) end(1) outcome(any_preg)
		
********************************************************************************

* Other indications for antidepressants
		
		file write tablecontent "Other possible indications for antidepressants" _n

		file write tablecontent "Other affective disorders" 
		tabulatevariable, variable(mood) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Diabetic neuropathy" 
		tabulatevariable, variable(dn) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Migraine prophylaxis" 
		tabulatevariable, variable(migraine) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Narcolepsy with cataplexy" _n
		
		file write tablecontent "Pain" 
		tabulatevariable, variable(pain) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Stress incontinence" 
		tabulatevariable, variable(incont) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Tension-type headache" 
		tabulatevariable, variable(headache) start(1) end(1) outcome(any_preg)
		
********************************************************************************

* Other prescriptions in the 12 months prior to pregnancy

		file write tablecontent "Other mental health-related prescriptions in 12 months before pregnancy" _n
		
		file write tablecontent "Antipsychotics" 
		tabulatevariable, variable(ap_12mo) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "Anti-seizure medications" 
		tabulatevariable, variable(asm_12mo) start(1) end(1) outcome(any_preg) 
		
********************************************************************************

* Number of CPRD consultations in the 12 months prior to pregnancy
		
		file write tablecontent "Primary care consultations in the 12 months before pregnancy" _n
		
		file write tablecontent "0" 
		tabulatevariable, variable(CPRD_consultation_events_cat) start(0) end(0) outcome(any_preg)
		
		file write tablecontent "1-3" 
		tabulatevariable, variable(CPRD_consultation_events_cat) start(1) end(1) outcome(any_preg)
		
		file write tablecontent "4-10" 
		tabulatevariable, variable(CPRD_consultation_events_cat) start(2) end(2) outcome(any_preg)
		
		file write tablecontent ">10" 
		tabulatevariable, variable(CPRD_consultation_events_cat) start(3) end(3) outcome(any_preg)
	
********************************************************************************

* Supplement use pre-pregnancy

		file write tablecontent "Supplement use reported before pregnancy" _n
		
		file write tablecontent "Folic acid" 
		tabulatevariable, variable(folate_before) start(1) end(1) outcome(any_preg)
		
********************************************************************************

* Iniiation of labour
		
		file write tablecontent "Initiation of labour" _n
		
		file write tablecontent "Induced" 
		tabulatevariable, variable(spont_labour) start(0) end(0) outcome(any_preg)
		
		file write tablecontent "Missing" 
		tabulatevariable, variable(spont_labour) start(9) end(9) outcome(any_preg)
		
********************************************************************************

* End of table
		
		file close tablecontent
		
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close patient_characteristics
	
	translate "$Logdir\2_analysis\1_patient characteristics.smcl" "$Logdir\2_analysis\1_patient characteristics.pdf", replace
	
	erase "$Logdir\2_analysis\1_patient characteristics.smcl"
	
********************************************************************************
