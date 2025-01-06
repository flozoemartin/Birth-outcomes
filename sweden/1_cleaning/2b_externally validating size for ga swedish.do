
********************************************************************************

* Script to be called on during the child data cleaning script for externally validating birthweight against the New Swedish standards 

* Author: Flo Martin 

* Date started: 23/01/2024

********************************************************************************

* Load in the data 

	use "$Tempdatadir\eligble_sample_prebw.dta", clear

	keep mother_id child_id deliv_date birth_weight child_male gest_age_wks
	
	tab gest_age_wks
	
	summ birth_weight
	
********************************************************************************

* Externally validating 

	* International male newborn size references from the New Swedish Standard (Lindstrom et al 2021)

	* 10th percentile
	local cut_1_12_10 = 49
	local cut_1_13_10 = 64
	local cut_1_14_10 = 83
	local cut_1_15_10 = 106
	local cut_1_16_10 = 134
	local cut_1_17_10 = 167
	local cut_1_18_10 = 207
	local cut_1_19_10 = 254
	local cut_1_20_10 = 309
	local cut_1_21_10 = 373
	local cut_1_22_10 = 446
	local cut_1_23_10 = 531
	local cut_1_24_10 = 626
	local cut_1_25_10 = 733
	local cut_1_26_10 = 851
	local cut_1_27_10 = 983
	local cut_1_28_10 = 1126
	local cut_1_29_10 = 1281
	local cut_1_30_10 = 1447
	local cut_1_31_10 = 1623
	local cut_1_32_10 = 1808
	local cut_1_33_10 = 2000
	local cut_1_34_10 = 2196
	local cut_1_35_10 = 2394
	local cut_1_36_10 = 2590
	local cut_1_37_10 = 2782
	local cut_1_38_10 = 2965
	local cut_1_39_10 = 3136
	local cut_1_40_10 = 3292
	local cut_1_41_10 = 3427
	local cut_1_42_10 = 3540
	
	* 95th percentile
	local cut_1_12_90 = 57
	local cut_1_13_90 = 75
	local cut_1_14_90 = 97
	local cut_1_15_90 = 124
	local cut_1_16_90 = 157
	local cut_1_17_90 = 197
	local cut_1_18_90 = 245
	local cut_1_19_90 = 302
	local cut_1_20_90 = 370
	local cut_1_21_90 = 448
	local cut_1_22_90 = 539
	local cut_1_23_90 = 644
	local cut_1_24_90 = 763
	local cut_1_25_90 = 897
	local cut_1_26_90 = 1047
	local cut_1_27_90 = 1213
	local cut_1_28_90 = 1395
	local cut_1_29_90 = 1594
	local cut_1_30_90 = 1808
	local cut_1_31_90 = 2036
	local cut_1_32_90 = 2277
	local cut_1_33_90 = 2530
	local cut_1_34_90 = 2791
	local cut_1_35_90 = 3058
	local cut_1_36_90 = 3328
	local cut_1_37_90 = 3958
	local cut_1_38_90 = 3863
	local cut_1_39_90 = 4120
	local cut_1_40_90 = 4365
	local cut_1_41_90 = 4594
	local cut_1_42_90 = 4802
	
	* International female newborn size references from the New Swedish Standard (Lindstrom et al 2021)

	* 10th percentile
	local cut_0_12_10 = 50
	local cut_0_13_10 = 65
	local cut_0_14_10 = 83
	local cut_0_15_10 = 106
	local cut_0_16_10 = 133
	local cut_0_17_10 = 166
	local cut_0_18_10 = 205
	local cut_0_19_10 = 251
	local cut_0_20_10 = 304
	local cut_0_21_10 = 366
	local cut_0_22_10 = 437
	local cut_0_23_10 = 518
	local cut_0_24_10 = 610
	local cut_0_25_10 = 712
	local cut_0_26_10 = 826
	local cut_0_27_10 = 952
	local cut_0_28_10 = 1089
	local cut_0_29_10 = 1237
	local cut_0_30_10 = 1395
	local cut_0_31_10 = 1563
	local cut_0_32_10 = 1739
	local cut_0_33_10 = 1921
	local cut_0_34_10 = 2107
	local cut_0_35_10 = 2295
	local cut_0_36_10 = 2481
	local cut_0_37_10 = 2663
	local cut_0_38_10 = 2837
	local cut_0_39_10 = 2999
	local cut_0_40_10 = 3147
	local cut_0_41_10 = 3277
	local cut_0_42_10 = 3385
	
	* 95th percentile
	local cut_0_12_90 = 57
	local cut_0_13_90 = 75
	local cut_0_14_90 = 97
	local cut_0_15_90 = 124
	local cut_0_16_90 = 157
	local cut_0_17_90 = 196
	local cut_0_18_90 = 243
	local cut_0_19_90 = 299
	local cut_0_20_90 = 365
	local cut_0_21_90 = 442
	local cut_0_22_90 = 531
	local cut_0_23_90 = 633
	local cut_0_24_90 = 749
	local cut_0_25_90 = 880
	local cut_0_26_90 = 1026
	local cut_0_27_90 = 1188
	local cut_0_28_90 = 1366
	local cut_0_29_90 = 1560
	local cut_0_30_90 = 1770
	local cut_0_31_90 = 1995
	local cut_0_32_90 = 2233
	local cut_0_33_90 = 2484
	local cut_0_34_90 = 2744
	local cut_0_35_90 = 3013
	local cut_0_36_90 = 3286
	local cut_0_37_90 = 3561
	local cut_0_38_90 = 3834
	local cut_0_39_90 = 4102
	local cut_0_40_90 = 4361
	local cut_0_41_90 = 4607
	local cut_0_42_90 = 4835
	
	* Create variable 
		
	gen sga_ex =. 
	gen lga_ex =.

	foreach sex in 0 1 {
	    forvalues week = 12(1)42 {
		   
		   replace sga_ex = 1 if gest_age_wks==(`week') & birth_weight<(`cut_`sex'_`week'_10') & child_male==(`sex')
		   replace lga_ex = 1 if gest_age_wks==(`week') & birth_weight>(`cut_`sex'_`week'_90') & child_male==(`sex')
		
		} 
	}
	
	replace sga_ex = 0 if sga_ex==. & lga_ex!=1
	replace lga_ex = 0 if lga_ex==. & sga_ex!=1
	
	tab sga_ex
	tab lga_ex
	
	gen nga_ex = 1 if sga_ex!=1 & lga_ex!=1
	
	keep mother_id child_id deliv_date birth_weight child_male sga_ex lga_ex nga_ex
	
	rename sga_ex sga_ex_swedish
	rename nga_ex nga_ex_swedish
	rename lga_ex lga_ex_swedish
	
	save "$Datadir\externally_valid_sizeforga_swedish.dta", replace
	
********************************************************************************