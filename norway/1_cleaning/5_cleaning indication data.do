********************************************************************************

* Indication data cleaning for mothers and fathers

* Author: Flo Martin 

* Date started: 22/09/2023

/* Notes

	Information on ICD-10 obtained from https://icd.who.int/browse10/2019/
	Information on ICPC obtained from https://www.ehelse.no/kodeverk-og-terminologi/ICPC-2/icpc-2e-english-version
	
*/

********************************************************************************

* Start logging

	log using "$Logdir\1_cleaning\5_cleaning indication data", name(cleaning_indication_data) replace

********************************************************************************

	foreach var in maternal paternal {

		* Diagnosis dataset

		use "$Datadir\raw_`var'_indications.dta", clear
			
			preserve

				keep if diag_code_sys=="ICPC2"
				tab diag_code
				
				gen icpc = substr(diag_code, 1, 3)
				tab icpc
				
				keep person_id icpc diag_date
				merge m:1 icpc using "$Codesdir\indications_icpc.dta", keep(3) nogen
				
				keep if depression==1 | anxiety==1 | ed==1
				
				save "$Tempdatadir\indications_icpc_diag.dta", replace
				
			restore
			
			preserve

				keep if diag_code_sys=="ICD10"
				tab diag_code
				
				gen icd10 = substr(diag_code, 1, 4)
				tab icd10
				
				replace icd10 = subinstr(icd10, ".", "",.) if regexm(icd10, ".")
				replace icd10 = subinstr(icd10, "i", "1",.) if regexm(icd10, "i") // check this
				tab icd10
				
				keep person_id icd10 diag_date
				merge m:1 icd10 using "$Codesdir\indications_icd10.dta", keep(3) nogen
				
				save "$Tempdatadir\indications_icd10_diag.dta", replace
				
			restore
			
		use "$Tempdatadir\indications_icpc_diag.dta", clear
		append using "$Tempdatadir\indications_icd10_diag.dta"
			
		save "$Deriveddir\clean_`var'_indications.dta", replace
		
	}
	
	use "$Deriveddir\clean_maternal_indications.dta", clear
	rename person_id mother_id
	save "$Deriveddir\clean_maternal_indications.dta", replace
	
	use "$Deriveddir\clean_paternal_indications.dta", clear
	rename person_id father_id
	save "$Deriveddir\clean_paternal_indications.dta", replace
	
/*******************************************************************************

	THIS ISN'T TO BE INCLUDED - DIAGNOSIS ONLY RECORDED FOR THOSE PRESCRIPTIONS THAT WERE REIMBURSED SO LARGELY MISSING AND INCLUDING THEM RUN THE RISK OF INTRODUCING SELECTION BIAS BY OVERSAMPLING DIAGNOSES AMONG THOSE WHOSE PRESCRIPTIONS ARE REIMBURSED

* We can get diagnoses from two places - the diagnoses dataset and the NorPD from 2008 where adding a diagnosis to a prescription was mandatory. So we can create an indications dataset that pulls from these two places 

	* Load in the clean prescription data

	use "$Deriveddir\clean_maternal_prescriptions.dta", clear
	
	* So I'm not introducing selection bias by looking at all the diagnoses affiliated with all the prescriptions I have here (as not all the prescriptions period) I should only at the diagnoses associated with antidepressant use right? Need to figure out what to do with the specific anxieties (phobias, etc.)
	
	keep if class!=.
	
	rename indication_icd10 icd10
	rename indication_icpc icpc
	
	merge m:1 icd10 using "$Codesdir\indications_all.dta", keep(1 3) gen(matched_icd10)
	merge m:1 icpc using "$Codesdir\indications_icpc.dta", update replace keep(1 4) gen(matched_icpc)
	
	keep if matched_icd10==3 | matched_icpc==4
	count // 148,918 prescriptions with a relevant diagnosis
	
	rename disp_date diag_date
	
	keep mother_id diag_date icd10 icpc icd10_desc icpc_desc depression anxiety affective dn ed migraine narco pain stress_incont tt_headache
	
	save "$Tempdatadir\indications_norpd.dta", replace
	
*******************************************************************************/		

* Erase unnecessary datasets

	erase "$Tempdatadir\indications_icpc_diag.dta"
	erase "$Tempdatadir\indications_icd10_diag.dta"

* Stop logging, translate .smcl into .pdf and erase .smcl

	log close cleaning_indication_data
	
	translate "$Logdir\1_cleaning\5_cleaning indication data.smcl" "$Logdir\1_cleaning\5_cleaning indication data.pdf", replace
	
	erase "$Logdir\1_cleaning\5_cleaning indication data.smcl"
	
********************************************************************************
