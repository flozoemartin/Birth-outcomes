********************************************************************************

* Creating codelists for each of my indication groups for ICD-10 and ICPC to run against the diagnoses and NorPD files - can also run ICD-10 in CPRD and pass onto Micke to run against the Swedish registry data

* Author: Flo Martin 

* Date started: 22/09/2023

********************************************************************************
	
* ICPC and ICD-10 codelists

	use "$Codesdir\icpc_codes.dta", clear
	replace icd10=trim(icd10)
	
	merge m:1 icd10 using "$Codesdir\icd10_codes.dta", keep(3) nogen
	
	* Depression
	
	preserve 
	
		list icd10 icd10_desc if icpc=="P03" | icpc=="P76"
		keep if icpc=="P03" | icpc=="P76"
		
		gen depression = 1
		
		save "$Codesdir\depression.dta", replace
		
	restore
	
	* Affective disorders other
	
	preserve 
	
		list icd10 icd10_desc if icpc=="P73"
		keep if (icpc=="P73" & regexm(icd10_desc, "depress")) | icd10=="F25.1"
		
		gen affective = 1
		
		save "$Codesdir\affective.dta", replace
		
	restore
	
	* Anxiety, phobias, and compulsive disorders
	
	preserve 
	
		list icd10 icd10_desc if icpc=="P74" | icpc=="P79" | icpc=="P82" | icpc=="P02" | icpc=="P01"
		keep if icpc=="P74" | icpc=="P79" | icpc=="P82" | icpc=="P02" | icpc=="P01"
		
		gen anxiety = 1 
		
		save "$Codesdir\anxiety.dta", replace
		
	restore
		
	* Eating disorders
	
	preserve 
	
		list icd10 icd10_desc if icpc=="P86" 
		keep if icpc=="P86"
		
		gen ed = 1 
		
		save "$Codesdir\ed.dta", replace
		
	restore
	
	* Pain
	
	preserve 
	
		list icd10 icd10_desc if icpc=="L86" | icpc=="L18" | icpc=="A01"
		keep if icpc=="L86" | icpc=="L18" | icpc=="A01"
		
		drop if icd10=="M79.3" | icd10=="M79.0" | icd10=="M60.9" | icd10=="M60.8" | icd10=="M60.1" | icd10=="M51.4" // Rheumatism, panniculitis, myolitis and Schmorl's nodes removed following AS check
		
		gen pain = 1
		
		save "$Codesdir\pain.dta", replace
		
	restore	
	
	* Chronic tension-type headache
	
	preserve 
	
		list icd10 icd10_desc if icpc=="N95" 
		keep if icpc=="N95"
		
		gen tt_headache = 1
		
		save "$Codesdir\tt_headache.dta", replace
		
	restore	
	
	* Migraine
	
	preserve 
	
		list icd10 icd10_desc if icpc=="N89" 
		keep if icpc=="N89"
		
		gen migraine = 1
		
		save "$Codesdir\migraine.dta", replace
		
	restore	
	
	* Stress incontinence
	
	preserve 
	
		list icd10 icd10_desc if icpc=="U04" 
		keep if icd10=="N39.3"
		
		gen stress_incont = 1 
		
		save "$Codesdir\stress_incont.dta", replace
		
	restore	
	
	* Diabetic neuropathy
	
	preserve 
	
		list icd10 icd10_desc if icpc=="N94" & regexm(icd10_desc, "Diabet")
		keep if icpc=="N94" & regexm(icd10_desc, "Diabet")
		
		gen dn = 1
		
		save "$Codesdir\dn.dta", replace
		
	restore	
	
	* Narcolepsy with cataplexy
	
	preserve 
	
		list icd10 icd10_desc if regexm(icd10, "G47.4")
		keep if icd10=="G47.4"
		
		gen narco = 1
		
		save "$Codesdir\narco.dta", replace
		
	restore
	
********************************************************************************

* Now create an indications master codelist for merging with NorPD and the diagnoses data

	use "$Codesdir\depression.dta", clear
	append using "$Codesdir\anxiety.dta"
	append using "$Codesdir\affective.dta"
	append using "$Codesdir\dn.dta"
	append using "$Codesdir\ed.dta"
	append using "$Codesdir\migraine.dta"
	append using "$Codesdir\narco.dta"
	append using "$Codesdir\pain.dta"
	append using "$Codesdir\stress_incont.dta"
	append using "$Codesdir\tt_headache.dta"
	
	save "$Codesdir\indications.dta", replace
	
	preserve 
	
		drop icd10 icd10_desc
		duplicates drop
		
		save "$Codesdir\indications_icpc.dta", replace
		
	restore
	
	replace icd10 = subinstr(icd10, ".", "",.)
	
	save "$Codesdir\indications_icd10.dta", replace
	
	cd "$Codesdir\to check"
	
	export excel indications_icd10, firstrow(variables) replace
	
	cd "$Codesdir"
	
	export excel indications_icd10, firstrow(variables) replace
	
********************************************************************************
