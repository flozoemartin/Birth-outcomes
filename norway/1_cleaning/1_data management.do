********************************************************************************

* Data management - creating copes of the files in .dta form to retain the original data in "$Projectdir\data"

* Author: Flo Martin 

* Date started: 20/09/2023

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\1_data management", name(data_management) replace
	
********************************************************************************

	* Maternal data
	
	import delimited using "$Originaldir\socio_no_v2.csv", clear
	
		* Maternal education
		
	save "$Datadir\maternal_edu.dta", replace
	
	use "$Originaldir\NorPD_antidepressants_antianxiety_meds_moms.dta", clear
	
		* Maternal antidepressant prescription from NorPD

	save "$Datadir\raw_maternal_prescriptions.dta", replace
	
	use "$Originaldir\Diagnoses_depression_anxiety_moms.dta", clear
	
		* Maternal antidepressant indication 
		
	save "$Datadir\raw_maternal_indications.dta", replace
	
		* Maternal healthcare utilisation
		
	use "$Originaldir\Num_prim_care_contact_each_birth.dta", clear
	
	save "$Datadir\maternal_healthcare_util.dta", replace

********************************************************************************

	* Paternal data
	
	import delimited using "$Originaldir\socio_no_father_v2.1.csv", clear
	
		* Paternal education
		
	save "$Datadir\paternal_edu.dta", replace
	
	import delimited using "$Originaldir\additional_info_father_no_v2.1.csv", clear
	
		* Paternal characteristics: age, marital status, & country of birth
		
	save "$Datadir\paternal_charac.dta", replace
	
	use "$Originaldir\NorPD_antidepressants_antianxiety_meds_dads.dta", clear
	
		* Paternal antidepressant prescription from NorPD

	save "$Datadir\raw_paternal_prescriptions.dta", replace
	
	use "$Originaldir\Diagnoses_depression_anxiety_dads.dta", clear
	
		* Paternal antidepressant indication 
		
	save "$Datadir\raw_paternal_indications.dta", replace

********************************************************************************	
	
	* Pregnancy data
	
	import delimited using "$Originaldir\preg_no_v2.1.csv", clear
	
		* These are maternal data in reference to pregnancy: maternal age, parity, smoking, comorbidities, etc.
	
	save "$Datadir\maternal_pregnancy_charac.dta", replace

********************************************************************************	
	
	* Child data
	
	import delimited using "$Originaldir\child_no_v2.csv", clear
	
		* These are all baby outcomes: stillbirth, gestational age, Apgar score, etc.
		
	save "$Datadir\child_outcomes.dta", replace
	
	duplicates report mother_id preg_id
	duplicates tag mother_id preg_id, gen(dup)
	tab dup
	drop if dup!=0
	drop dup
	
	drop father_id // as per Jackie's instructions based on the error in the child data
	
	save "$Datadir\child_multirm.dta", replace
	
********************************************************************************

* Codelists

	* ICD-10 codes
	
	import excel using "$Codesdir\raw\ICD-10_MIT_2021_Excel_16-March_2021.xlsx", firstrow clear
	
	keep ICD10_Code WHO_Full_Desc
	rename ICD10_Code icd10 
	rename WHO_Full_Desc icd10_desc
	order icd10 icd10_desc
	
	save "$Codesdir\icd10_codes.dta", replace

	* ICPC codes
	
	import excel using "$Codesdir\raw\icpc-2e-v7.0.xlsx", firstrow clear
	
	rename Code code
	keep code preferred icd10
	
	foreach var of varlist preferred {
		
		gen Z=lower(`var')
		drop `var'
		rename Z `var'
		
	}
	sort code 
	order code preferred icd10
	
	split icd10, parse(;) gen(indiv_icd)
	
	drop icd10

	reshape long indiv_icd, i(code preferred) j(num)
	
	rename code icpc
	rename indiv_icd icd10
	rename preferred icpc_desc
	
	format icd10 %-7s
	
	drop if icd10==""
	drop num
	
	save "$Codesdir\icpc_codes.dta", replace
	
	* Generate codelists from full ICD-10 and ICPC lists to run against diagnoses and NorPD
	
	do "$Dodir\1_data management\1a_generating icd10 and icpc codelists.do"
	
********************************************************************************

* Creating the eligible sample - singelton births
	
	use "$Datadir\maternal_pregnancy_charac.dta", clear
	* Drop births in 2004 as not able to retrieve prescription data for them in the 12 months prior to pregnancy
	tab birth_yr
	drop if birth_yr==2004
	
	count	// 940,259 pregnancy records
	
	* Retain only singleton births 
	drop if multiple==1
	
	* Drop old father_id
	drop father_id_old
	
	count	// 909,246 singleton pregnancy records
	
	duplicates report mother_id preg_id
	duplicates tag mother_id preg_id, gen(dup)
	drop if dup==1 & father_id==. // two completely duplicate records but one record had missing father_id therefore retained the one with a father_id
	drop dup
	
	count	// 909,246 singleton pregnancy records (no duplicates)
	count if father_id==.
	
	merge 1:1 mother_id preg_id using "$Datadir\child_multirm.dta", keep(3) nogen
	
	order preg_id mother_id father_id child_id
	
	duplicates report preg_id mother_id // no duplicate pregnancies
	duplicates report child_id			// no duplicate children
	
	tab gest_age_wks
	
	* Drop births with a gestational length incompatible with having a live birth outcomes (22 weeks' gestation)
	drop if gest_age_wks<22
	
	count	// 909,200 singleton, born >=22 weeks' gestation pregnancy records (no duplicates)
	
	* Drop if no pregnancy start date
	gen start_date = deliv_date - gest_age_days
	drop if start_date==.
	
	count // 906,251 babies
	codebook mother_id // 544,365 mothers
	
	save "$Datadir\eligible_mbrn.dta", replace
	
********************************************************************************

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close data_management
	
	translate "$Logdir\1_cleaning\1_data management.smcl" "$Logdir\1_cleaning\1_data management.pdf", replace
	
	erase "$Logdir\1_cleaning\1_data management.smcl"
	
********************************************************************************
