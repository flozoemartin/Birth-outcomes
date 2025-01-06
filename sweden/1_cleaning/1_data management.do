********************************************************************************

* Data management - compressing the files and creating duplicates in the data directory, as well as creating 15% samples for writing scripts

* Author: Flo Martin

* Date: 21/01/2024

********************************************************************************

* Prescription data from the Medical Birth Register (mums) and the Prescription Drug Register (mums and dads)

	* Maternal exposures from the Medical Birth Register

	foreach x in a04 n03 n05a n06a {

		use "$Newdatadir\Drug_data\\`x'_mbr_mother01.dta", replace
		
		compress
		
		rename lopnr_bm mother_id
		rename ATC atc_code
		rename birthdate_mbr_month_ip deliv_date
		
		save "$Datadir\exposure\\`x'_mbr_maternal_compress.dta", replace
		
		sample 15
		
		save "$Datadir\exposure\samples\\`x'_mbr_maternal_sample15.dta", replace
	
	}
	
	* Maternal exposures from the Prescription Drug Register
	
	foreach x in a04 n03 n05a {

		use "$Newdatadir\Drug_data\\`x'_pdr_mother01.dta", replace
		
		compress
		
		rename lopnr_bm mother_id
		rename ATC atc_code
		rename ddd total_ddd
		rename date disp_date
		
		save "$Datadir\exposure\\`x'_pdr_maternal_compress.dta", replace
		
		sample 15
		
		save "$Datadir\exposure\samples\\`x'_pdr_maternal_sample15.dta", replace
	
	}
	
	use "$Newdatadir\Drug_data\n06a_pdr_mother01.dta", replace
		
	compress
	
	rename lopnr_bm mother_id
	rename ATC atc_code
	rename fddd total_ddd
	rename date disp_date
		
	save "$Datadir\exposure\n06a_pdr_maternal_compress.dta", replace
		
	sample 15
		
	save "$Datadir\exposure\samples\n06a_pdr_maternal_sample15.dta", replace
	
	* Paternal exposure from the Prescription Drug Register
	
	foreach x in a04 n03 n05a {

		use "$Newdatadir\Drug_data\\`x'_pdr_father01.dta", replace
		
		compress
		
		rename lopnr_bf father_id
		rename ATC atc_code
		rename ddd total_ddd
		rename date disp_date
		
		save "$Datadir\exposure\\`x'_pdr_paternal_compress.dta", replace
		
		sample 15
		
		save "$Datadir\exposure\samples\\`x'_pdr_paternal_sample15.dta", replace
	
	}

	use "$Newdatadir\Drug_data\n06a_pdr_father01.dta", replace
		
	compress
		
	rename lopnr_bf father_id
	rename ATC atc_code
	rename fddd total_ddd
	rename date disp_date
		
	save "$Datadir\exposure\n06a_pdr_paternal_compress.dta", replace
		
	sample 15
		
	save "$Datadir\exposure\samples\n06a_pdr_paternal_sample15.dta", replace
	
********************************************************************************
	
* Indication data from the National Patient Register (NPR)

	* Addiction-related events - covariate
	
		* Dad
	
	use "$Newdatadir\NPR_data\addicted_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename addicted_date_bf diag_date
	rename addicted_bf addicted_pat
	
	save "$Datadir\covariates\addiction_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\addicted_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename addicted_date_bm diag_date
	rename addicted_bm addicted_mat
	
	save "$Datadir\covariates\addiction_maternal_compress.dta", replace
	
	* ADHD - covariate
	
		* Dad
	
	use "$Newdatadir\NPR_data\adhd_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename adhd_date_bf diag_date
	rename adhd_bf adhd_pat
	
	save "$Datadir\covariates\adhd_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\adhd_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename adhd_date_bm diag_date
	rename adhd_bm adhd_mat
	
	save "$Datadir\covariates\adhd_maternal_compress.dta", replace
	
	* Anxiety - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\Anx_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename anxiety_date_bf diag_date
	rename anxiety_bf anxiety_pat
	
	save "$Datadir\indications\anxiety_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\Anx_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename anxiety_date_bm diag_date
	rename anxiety_bm anxiety_mat
	
	save "$Datadir\indications\anxiety_maternal_compress.dta", replace
	
	* ASD - covariate
	
		* Dad
	
	use "$Newdatadir\NPR_data\asd_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename asd_date_bf diag_date
	rename asd_bf asd_pat
	
	save "$Datadir\covariates\asd_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\asd_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename asd_date_bm diag_date
	rename asd_bm asd_mat
	
	save "$Datadir\covariates\asd_maternal_compress.dta", replace
	
	* Bipolar - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\bipolar_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename bipolar_date_bf diag_date
	rename bipolar_bf bipolar_pat
	
	save "$Datadir\indications\bipolar_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\bipolar_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename bipolar_date_bm diag_date
	rename bipolar_bm bipolar_mat
	
	save "$Datadir\indications\bipolar_maternal_compress.dta", replace
	
	* Depression - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\Depr_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename depression_date_bf diag_date
	rename depression_bf depression_pat
	
	save "$Datadir\indications\depression_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\Depr_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename depression_date_bm diag_date
	rename depression_bm depression_mat
	
	save "$Datadir\indications\depression_maternal_compress.dta", replace
	
	* Eating disorders - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\Ed_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename eating_disorder_date_bf diag_date
	rename eating_disorder_bf ed_pat
	
	save "$Datadir\indications\ed_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\Ed_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename eating_disorder_date_bm diag_date
	rename eating_disorder_bm ed_mat
	
	save "$Datadir\indications\ed_maternal_compress.dta", replace
	
	* Headache - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\headache_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename tension_headache_date_bf diag_date
	rename tension_headache_bf tt_headache_pat
	
	save "$Datadir\indications\headache_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\headache_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename tension_headache_date_bm diag_date
	rename tension_headache_bm tt_headache_mat
	
	save "$Datadir\indications\headache_maternal_compress.dta", replace
	
	* ID - covariate
	
		* Dad
	
	use "$Newdatadir\NPR_data\id_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename id_date_bf diag_date
	rename id_bf id_pat
	
	save "$Datadir\covariates\id_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\id_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename id_date_bm diag_date
	rename id_bm id_mat
	
	save "$Datadir\covariates\id_maternal_compress.dta", replace
	
	* Incontinence - indication
	
		* Mum
		
	use "$Newdatadir\NPR_data\incont_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename stress_incont_date_bm diag_date
	rename stress_incont_bm stress_incont_mat
	
	save "$Datadir\indications\incont_maternal_compress.dta", replace
	
	* Migraine - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\migraine_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename migraine_date_bf diag_date
	rename migraine_bf migraine_pat
	
	save "$Datadir\indications\migraine_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\migraine_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename migraine_date_bm diag_date
	rename migraine_bm migraine_mat
	
	save "$Datadir\indications\migraine_maternal_compress.dta", replace
	
	* Other psychiatric conditions - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\other_psych_alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename other_psych_date_bf diag_date
	rename other_psych_bf other_psych_pat
	
	save "$Datadir\indications\other_psych_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\other_psych_alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename other_psych_date_bm diag_date
	rename other_psych_bm other_psych_mat
	
	save "$Datadir\indications\other_psych_maternal_compress.dta", replace
	
	* Psychosis? - indication
	
		* Dad
	
	use "$Newdatadir\NPR_data\psych_npr_icd9_10alldates_bf.dta", clear
	
	compress
	
	rename lopnr_bf father_id
	rename psych_history_date_bf diag_date
	rename psych_history_bf psych_history_pat
	
	save "$Datadir\indications\psych_paternal_compress.dta", replace
	
		* Mum
		
	use "$Newdatadir\NPR_data\psych_npr_icd9_10alldates_bm.dta", clear
	
	compress
	
	rename lopnr_bm mother_id
	rename psych_history_date_bm diag_date
	rename psych_history_bm psych_history_mat
	
	save "$Datadir\indications\psych_maternal_compress.dta", replace
	
********************************************************************************

* Population

	use "$Newdatadir\Population\pop1995_2020g5.dta", clear
	
	compress
	
	save "$Datadir\DOHAD_ANALYTICAL_V2_compress.dta", replace
	
	sample 15
	
	save "$Datadir\DOHAD_ANALYTICAL_V2_sample15.dta", replace
	
* Eligibility criteria
	
	use "$Datadir\DOHAD_ANALYTICAL_V2_compress.dta", clear
	
	count // 2,695,199 babies
	
	* Data management for common data model for chapter 6 / birth outcomes paper
	
		* Renaming variables for continuity
	
	rename lopnr_ip child_id
	rename lopnr_bm mother_id
	rename lopnr_bf father_id
	
	rename birthyear_ip birth_yr
	rename preg_start_date start_date
	rename birthdate_ip deliv_date
	rename gestational_days gest_age_days
	rename gestational_weeks gest_age_wks
	rename male child_male
	
	rename age_atbirth_bm mother_age
	rename bmi_bm bmi
	rename bcountry_bm mother_birth_country
	rename smoking_1st_visit smoke_beg
	rename smoking3032w smoke_end
	
	rename stillbirth stillborn
	rename birthweight_ip birth_weight
	rename sga sga_original
	rename lga lga_original
	rename APGAR5 apgar5
	rename apgar5min apgar5_bin
	rename death28d neonatal_death
	
	* Year of birth - Norwegian cut-off 2005, UK cut-off 1996
	tab birth_yr 
	
	drop if start_date<16983 // for the primary analysis drop pregnancies that started before July 1st 2006 as Swedish PDR started July 1st 2005 giving a year grace period for collecting covariates to mirror Norway

	count // 1,541,855
	
	* Drop if no maternal ID (because no linkage with PDR and indications) or no start date (inability to overlap prescriptions or diagnoses)
	drop if mother_id==. // 0
	drop if start_date==. // 1,468
	
	* Retain singleton births only
	tab singleton, m
	drop if singleton==0 // 43,343
	
	* Check
	duplicates report mother_id start_date // 0 duplicate pregnancies
	duplicates tag mother_id start_date, gen(dup)
	tab dup
	drop dup
	
	duplicates report mother_id start_date // no duplicates
	
	count 				// 1,497,044 pregnancies among...
	codebook mother_id 	// ...919,448 people
	
	save "$Datadir\DOHAD_ANALYTICAL_V2_eligible.dta", replace
	
********************************************************************************
