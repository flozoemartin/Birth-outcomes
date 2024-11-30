********************************************************************************

* Script to be called on during the child data cleaning script for externally validating birthweight against the Intergrowth-21 standards 

* Author: Flo Martin 

* Date started: 08/04/2024

********************************************************************************

* Load in the data 

	use "$Tempdatadir\eligble_sample_prebw.dta", clear

	keep patid pregid birth_weight child_male gestdays gest_age_wks
	
	summ birth_weight
	
	gen birweit_kg = birth_weight/1000
	
********************************************************************************

* Externally validating 

	* International male newborn size references for Very Preterm Infants (24-32+6 weeks) - 10th centile (for SGA)

	local cut_1_168_10_vpt = 0.50
	local cut_1_169_10_vpt = 0.51
	local cut_1_170_10_vpt = 0.52
	local cut_1_171_10_vpt = 0.53
	local cut_1_172_10_vpt = 0.54
	local cut_1_173_10_vpt = 0.55
	local cut_1_174_10_vpt = 0.56
	local cut_1_175_10_vpt = 0.57
	local cut_1_176_10_vpt = 0.58
	local cut_1_177_10_vpt = 0.59
	local cut_1_178_10_vpt = 0.60
	local cut_1_179_10_vpt = 0.61
	local cut_1_180_10_vpt = 0.63
	local cut_1_181_10_vpt = 0.64
	local cut_1_182_10_vpt = 0.65
	local cut_1_183_10_vpt = 0.66
	local cut_1_184_10_vpt = 0.67
	local cut_1_185_10_vpt = 0.69
	local cut_1_186_10_vpt = 0.70
	local cut_1_187_10_vpt = 0.71
	local cut_1_188_10_vpt = 0.72
	local cut_1_189_10_vpt = 0.74
	local cut_1_190_10_vpt = 0.75
	local cut_1_191_10_vpt = 0.77
	local cut_1_192_10_vpt = 0.78
	local cut_1_193_10_vpt = 0.79
	local cut_1_194_10_vpt = 0.81
	local cut_1_195_10_vpt = 0.82
	local cut_1_196_10_vpt = 0.84
	local cut_1_197_10_vpt = 0.85
	local cut_1_198_10_vpt = 0.87
	local cut_1_199_10_vpt = 0.88
	local cut_1_200_10_vpt = 0.90
	local cut_1_201_10_vpt = 0.92
	local cut_1_202_10_vpt = 0.93
	local cut_1_203_10_vpt = 0.95
	local cut_1_204_10_vpt = 0.97
	local cut_1_205_10_vpt = 0.98
	local cut_1_206_10_vpt = 1.00
	local cut_1_207_10_vpt = 1.02
	local cut_1_208_10_vpt = 1.03
	local cut_1_209_10_vpt = 1.05
	local cut_1_210_10_vpt = 1.07
	local cut_1_211_10_vpt = 1.09
	local cut_1_212_10_vpt = 1.11
	local cut_1_213_10_vpt = 1.13
	local cut_1_214_10_vpt = 1.15
	local cut_1_215_10_vpt = 1.17
	local cut_1_216_10_vpt = 1.19
	local cut_1_217_10_vpt = 1.21
	local cut_1_218_10_vpt = 1.23
	local cut_1_219_10_vpt = 1.25
	local cut_1_220_10_vpt = 1.27
	local cut_1_221_10_vpt = 1.29
	local cut_1_222_10_vpt = 1.31
	local cut_1_223_10_vpt = 1.34
	local cut_1_224_10_vpt = 1.36
	local cut_1_225_10_vpt = 1.38
	local cut_1_226_10_vpt = 1.41
	local cut_1_227_10_vpt = 1.43
	local cut_1_228_10_vpt = 1.45
	local cut_1_229_10_vpt = 1.48
	local cut_1_230_10_vpt = 1.50
	
	* International male newborn size references for Very Preterm Infants (24-32+6 weeks) - 90th centile (for LGA)

	local cut_1_168_90_vpt = 0.82
	local cut_1_169_90_vpt = 0.83
	local cut_1_170_90_vpt = 0.85
	local cut_1_171_90_vpt = 0.87
	local cut_1_172_90_vpt = 0.88
	local cut_1_173_90_vpt = 0.90
	local cut_1_174_90_vpt = 0.92
	local cut_1_175_90_vpt = 0.93
	local cut_1_176_90_vpt = 0.95
	local cut_1_177_90_vpt = 0.97
	local cut_1_178_90_vpt = 0.99
	local cut_1_179_90_vpt = 1.01
	local cut_1_180_90_vpt = 1.03
	local cut_1_181_90_vpt = 1.04
	local cut_1_182_90_vpt = 1.06
	local cut_1_183_90_vpt = 1.08
	local cut_1_184_90_vpt = 1.10
	local cut_1_185_90_vpt = 1.13
	local cut_1_186_90_vpt = 1.15
	local cut_1_187_90_vpt = 1.17
	local cut_1_188_90_vpt = 1.19
	local cut_1_189_90_vpt = 1.21
	local cut_1_190_90_vpt = 1.23
	local cut_1_191_90_vpt = 1.26
	local cut_1_192_90_vpt = 1.28
	local cut_1_193_90_vpt = 1.30
	local cut_1_194_90_vpt = 1.33
	local cut_1_195_90_vpt = 1.35
	local cut_1_196_90_vpt = 1.37
	local cut_1_197_90_vpt = 1.40
	local cut_1_198_90_vpt = 1.42
	local cut_1_199_90_vpt = 1.45
	local cut_1_200_90_vpt = 1.48
	local cut_1_201_90_vpt = 1.50
	local cut_1_202_90_vpt = 1.53
	local cut_1_203_90_vpt = 1.56
	local cut_1_204_90_vpt = 1.58
	local cut_1_205_90_vpt = 1.61
	local cut_1_206_90_vpt = 1.64
	local cut_1_207_90_vpt = 1.67
	local cut_1_208_90_vpt = 1.70
	local cut_1_209_90_vpt = 1.73
	local cut_1_210_90_vpt = 1.76
	local cut_1_211_90_vpt = 1.79
	local cut_1_212_90_vpt = 1.82
	local cut_1_213_90_vpt = 1.85
	local cut_1_214_90_vpt = 1.88
	local cut_1_215_90_vpt = 1.92
	local cut_1_216_90_vpt = 1.95
	local cut_1_217_90_vpt = 1.98
	local cut_1_218_90_vpt = 2.02
	local cut_1_219_90_vpt = 2.05
	local cut_1_220_90_vpt = 2.09
	local cut_1_221_90_vpt = 2.12
	local cut_1_222_90_vpt = 2.16
	local cut_1_223_90_vpt = 2.19
	local cut_1_224_90_vpt = 2.23
	local cut_1_225_90_vpt = 2.27
	local cut_1_226_90_vpt = 2.31
	local cut_1_227_90_vpt = 2.35
	local cut_1_228_90_vpt = 2.38
	local cut_1_229_90_vpt = 2.42
	local cut_1_230_90_vpt = 2.46
	
	* International female newborn size references for Very Preterm Infants (24-32+6 weeks) - 10th centile (for SGA)

	local cut_0_168_10_vpt = 0.47
	local cut_0_169_10_vpt = 0.48
	local cut_0_170_10_vpt = 0.49
	local cut_0_171_10_vpt = 0.50
	local cut_0_172_10_vpt = 0.51
	local cut_0_173_10_vpt = 0.52
	local cut_0_174_10_vpt = 0.53
	local cut_0_175_10_vpt = 0.54
	local cut_0_176_10_vpt = 0.55
	local cut_0_177_10_vpt = 0.56
	local cut_0_178_10_vpt = 0.57
	local cut_0_179_10_vpt = 0.58
	local cut_0_180_10_vpt = 0.59
	local cut_0_181_10_vpt = 0.60
	local cut_0_182_10_vpt = 0.61
	local cut_0_183_10_vpt = 0.62
	local cut_0_184_10_vpt = 0.64
	local cut_0_185_10_vpt = 0.65
	local cut_0_186_10_vpt = 0.66
	local cut_0_187_10_vpt = 0.67
	local cut_0_188_10_vpt = 0.68
	local cut_0_189_10_vpt = 0.70
	local cut_0_190_10_vpt = 0.71
	local cut_0_191_10_vpt = 0.72
	local cut_0_192_10_vpt = 0.74
	local cut_0_193_10_vpt = 0.75
	local cut_0_194_10_vpt = 0.76
	local cut_0_195_10_vpt = 0.78
	local cut_0_196_10_vpt = 0.79
	local cut_0_197_10_vpt = 0.81
	local cut_0_198_10_vpt = 0.82
	local cut_0_199_10_vpt = 0.83
	local cut_0_200_10_vpt = 0.85
	local cut_0_201_10_vpt = 0.86
	local cut_0_202_10_vpt = 0.88
	local cut_0_203_10_vpt = 0.90
	local cut_0_204_10_vpt = 0.91
	local cut_0_205_10_vpt = 0.93
	local cut_0_206_10_vpt = 0.94
	local cut_0_207_10_vpt = 0.96
	local cut_0_208_10_vpt = 0.98
	local cut_0_209_10_vpt = 0.99
	local cut_0_210_10_vpt = 1.01
	local cut_0_211_10_vpt = 1.03
	local cut_0_212_10_vpt = 1.05
	local cut_0_213_10_vpt = 1.07
	local cut_0_214_10_vpt = 1.08
	local cut_0_215_10_vpt = 1.10
	local cut_0_216_10_vpt = 1.12
	local cut_0_217_10_vpt = 1.14
	local cut_0_218_10_vpt = 1.16
	local cut_0_219_10_vpt = 1.18
	local cut_0_220_10_vpt = 1.20
	local cut_0_221_10_vpt = 1.22
	local cut_0_222_10_vpt = 1.24
	local cut_0_223_10_vpt = 1.26
	local cut_0_224_10_vpt = 1.28
	local cut_0_225_10_vpt = 1.31
	local cut_0_226_10_vpt = 1.33
	local cut_0_227_10_vpt = 1.35
	local cut_0_228_10_vpt = 1.37
	local cut_0_229_10_vpt = 1.40
	local cut_0_230_10_vpt = 1.42
	
	* International female newborn size references for Very Preterm Infants (24-32+6 weeks) - 90th centile (for LGA)

	local cut_0_168_90_vpt = 0.77
	local cut_0_169_90_vpt = 0.79
	local cut_0_170_90_vpt = 0.80
	local cut_0_171_90_vpt = 0.82
	local cut_0_172_90_vpt = 0.83
	local cut_0_173_90_vpt = 0.85
	local cut_0_174_90_vpt = 0.87
	local cut_0_175_90_vpt = 0.88
	local cut_0_176_90_vpt = 0.90
	local cut_0_177_90_vpt = 0.92
	local cut_0_178_90_vpt = 0.93
	local cut_0_179_90_vpt = 0.95
	local cut_0_180_90_vpt = 0.97
	local cut_0_181_90_vpt = 0.99
	local cut_0_182_90_vpt = 1.01
	local cut_0_183_90_vpt = 1.02
	local cut_0_184_90_vpt = 1.04
	local cut_0_185_90_vpt = 1.06
	local cut_0_186_90_vpt = 1.08
	local cut_0_187_90_vpt = 1.10
	local cut_0_188_90_vpt = 1.12
	local cut_0_189_90_vpt = 1.14
	local cut_0_190_90_vpt = 1.16
	local cut_0_191_90_vpt = 1.19
	local cut_0_192_90_vpt = 1.21
	local cut_0_193_90_vpt = 1.23
	local cut_0_194_90_vpt = 1.25
	local cut_0_195_90_vpt = 1.27
	local cut_0_196_90_vpt = 1.30
	local cut_0_197_90_vpt = 1.32
	local cut_0_198_90_vpt = 1.34
	local cut_0_199_90_vpt = 1.37
	local cut_0_200_90_vpt = 1.39
	local cut_0_201_90_vpt = 1.42
	local cut_0_202_90_vpt = 1.44
	local cut_0_203_90_vpt = 1.47
	local cut_0_204_90_vpt = 1.50
	local cut_0_205_90_vpt = 1.52
	local cut_0_206_90_vpt = 1.55
	local cut_0_207_90_vpt = 1.58
	local cut_0_208_90_vpt = 1.60
	local cut_0_209_90_vpt = 1.63
	local cut_0_210_90_vpt = 1.66
	local cut_0_211_90_vpt = 1.69
	local cut_0_212_90_vpt = 1.72
	local cut_0_213_90_vpt = 1.75
	local cut_0_214_90_vpt = 1.78
	local cut_0_215_90_vpt = 1.81
	local cut_0_216_90_vpt = 1.84
	local cut_0_217_90_vpt = 1.87
	local cut_0_218_90_vpt = 1.90
	local cut_0_219_90_vpt = 1.94
	local cut_0_220_90_vpt = 1.97
	local cut_0_221_90_vpt = 2.00
	local cut_0_222_90_vpt = 2.04
	local cut_0_223_90_vpt = 2.07
	local cut_0_224_90_vpt = 2.11
	local cut_0_225_90_vpt = 2.14
	local cut_0_226_90_vpt = 2.18
	local cut_0_227_90_vpt = 2.21
	local cut_0_228_90_vpt = 2.25
	local cut_0_229_90_vpt = 2.29
	local cut_0_230_90_vpt = 2.33
	
*************************************************************************************
	
	* International male newborn size references (33-42+6 weeks) - 10th centile (for SGA)

	local cut_1_231_10 = 1.43
	local cut_1_232_10 = 1.47
	local cut_1_233_10 = 1.51
	local cut_1_234_10 = 1.55
	local cut_1_235_10 = 1.59
	local cut_1_236_10 = 1.63
	local cut_1_237_10 = 1.67
	local cut_1_238_10 = 1.71
	local cut_1_239_10 = 1.74
	local cut_1_240_10 = 1.78
	local cut_1_241_10 = 1.82
	local cut_1_242_10 = 1.85
	local cut_1_243_10 = 1.89
	local cut_1_244_10 = 1.92
	local cut_1_245_10 = 1.95
	local cut_1_246_10 = 1.99
	local cut_1_247_10 = 2.02
	local cut_1_248_10 = 2.05
	local cut_1_249_10 = 2.09
	local cut_1_250_10 = 2.12
	local cut_1_251_10 = 2.15
	local cut_1_252_10 = 2.18
	local cut_1_253_10 = 2.21
	local cut_1_254_10 = 2.24
	local cut_1_255_10 = 2.27
	local cut_1_256_10 = 2.30
	local cut_1_257_10 = 2.33
	local cut_1_258_10 = 2.36
	local cut_1_259_10 = 2.38
	local cut_1_260_10 = 2.41
	local cut_1_261_10 = 2.44
	local cut_1_262_10 = 2.47
	local cut_1_263_10 = 2.49
	local cut_1_264_10 = 2.52
	local cut_1_265_10 = 2.54
	local cut_1_266_10 = 2.57
	local cut_1_267_10 = 2.59
	local cut_1_268_10 = 2.62
	local cut_1_269_10 = 2.64
	local cut_1_270_10 = 2.67
	local cut_1_271_10 = 2.69
	local cut_1_272_10 = 2.71
	local cut_1_273_10 = 2.73
	local cut_1_274_10 = 2.76
	local cut_1_275_10 = 2.78
	local cut_1_276_10 = 2.80
	local cut_1_277_10 = 2.82
	local cut_1_278_10 = 2.84
	local cut_1_279_10 = 2.86
	local cut_1_280_10 = 2.88
	local cut_1_281_10 = 2.90
	local cut_1_282_10 = 2.92
	local cut_1_283_10 = 2.94
	local cut_1_284_10 = 2.96
	local cut_1_285_10 = 2.98
	local cut_1_286_10 = 2.99
	local cut_1_287_10 = 3.01
	local cut_1_288_10 = 3.03
	local cut_1_289_10 = 3.05
	local cut_1_290_10 = 3.06
	local cut_1_291_10 = 3.08
	local cut_1_292_10 = 3.09
	local cut_1_293_10 = 3.11
	local cut_1_294_10 = 3.12
	local cut_1_295_10 = 3.14
	local cut_1_296_10 = 3.15
	local cut_1_297_10 = 3.17
	local cut_1_298_10 = 3.18
	local cut_1_299_10 = 3.20
	local cut_1_300_10 = 3.21
	
	* International male newborn size references (33-42+6 weeks) - 90th centile (for LGA)

	local cut_1_231_90 = 2.52
	local cut_1_232_90 = 2.56
	local cut_1_233_90 = 2.60
	local cut_1_234_90 = 2.64
	local cut_1_235_90 = 2.67
	local cut_1_236_90 = 2.71
	local cut_1_237_90 = 2.75
	local cut_1_238_90 = 2.79
	local cut_1_239_90 = 2.82
	local cut_1_240_90 = 2.86
	local cut_1_241_90 = 2.89
	local cut_1_242_90 = 2.93
	local cut_1_243_90 = 2.96
	local cut_1_244_90 = 3.00
	local cut_1_245_90 = 3.03
	local cut_1_246_90 = 3.06
	local cut_1_247_90 = 3.09
	local cut_1_248_90 = 3.13
	local cut_1_249_90 = 3.16
	local cut_1_250_90 = 3.19
	local cut_1_251_90 = 3.22
	local cut_1_252_90 = 3.25
	local cut_1_253_90 = 3.28
	local cut_1_254_90 = 3.31
	local cut_1_255_90 = 3.34
	local cut_1_256_90 = 3.37
	local cut_1_257_90 = 3.39
	local cut_1_258_90 = 3.42
	local cut_1_259_90 = 3.45
	local cut_1_260_90 = 3.48
	local cut_1_261_90 = 3.50
	local cut_1_262_90 = 3.53
	local cut_1_263_90 = 3.55
	local cut_1_264_90 = 3.58
	local cut_1_265_90 = 3.61
	local cut_1_266_90 = 3.63
	local cut_1_267_90 = 3.65
	local cut_1_268_90 = 3.68
	local cut_1_269_90 = 3.70
	local cut_1_270_90 = 3.72
	local cut_1_271_90 = 3.75
	local cut_1_272_90 = 3.77
	local cut_1_273_90 = 3.79
	local cut_1_274_90 = 3.81
	local cut_1_275_90 = 3.83
	local cut_1_276_90 = 3.86
	local cut_1_277_90 = 3.88
	local cut_1_278_90 = 3.90
	local cut_1_279_90 = 3.92
	local cut_1_280_90 = 3.94
	local cut_1_281_90 = 3.95
	local cut_1_282_90 = 3.97
	local cut_1_283_90 = 3.99
	local cut_1_284_90 = 4.01
	local cut_1_285_90 = 4.03
	local cut_1_286_90 = 4.04
	local cut_1_287_90 = 4.06
	local cut_1_288_90 = 4.08
	local cut_1_289_90 = 4.09
	local cut_1_290_90 = 4.11
	local cut_1_291_90 = 4.13
	local cut_1_292_90 = 4.14
	local cut_1_293_90 = 4.16
	local cut_1_294_90 = 4.17
	local cut_1_295_90 = 4.19
	local cut_1_296_90 = 4.20
	local cut_1_297_90 = 4.21
	local cut_1_298_90 = 4.23
	local cut_1_299_90 = 4.24
	local cut_1_300_90 = 4.25
	
	* International female newborn size references (33-42+6 weeks) - 10th centile (for SGA)

	local cut_0_231_10 = 1.41
	local cut_0_232_10 = 1.45
	local cut_0_233_10 = 1.49
	local cut_0_234_10 = 1.53
	local cut_0_235_10 = 1.57
	local cut_0_236_10 = 1.61
	local cut_0_237_10 = 1.65
	local cut_0_238_10 = 1.68
	local cut_0_239_10 = 1.72
	local cut_0_240_10 = 1.75
	local cut_0_241_10 = 1.79
	local cut_0_242_10 = 1.82
	local cut_0_243_10 = 1.86
	local cut_0_244_10 = 1.89
	local cut_0_245_10 = 1.92
	local cut_0_246_10 = 1.96
	local cut_0_247_10 = 1.99
	local cut_0_248_10 = 2.02
	local cut_0_249_10 = 2.05
	local cut_0_250_10 = 2.08
	local cut_0_251_10 = 2.11
	local cut_0_252_10 = 2.14
	local cut_0_253_10 = 2.17
	local cut_0_254_10 = 2.20
	local cut_0_255_10 = 2.23
	local cut_0_256_10 = 2.25
	local cut_0_257_10 = 2.28
	local cut_0_258_10 = 2.31
	local cut_0_259_10 = 2.33
	local cut_0_260_10 = 2.36
	local cut_0_261_10 = 2.38
	local cut_0_262_10 = 2.41
	local cut_0_263_10 = 2.43
	local cut_0_264_10 = 2.46
	local cut_0_265_10 = 2.48
	local cut_0_266_10 = 2.50
	local cut_0_267_10 = 2.53
	local cut_0_268_10 = 2.55
	local cut_0_269_10 = 2.57
	local cut_0_270_10 = 2.59
	local cut_0_271_10 = 2.61
	local cut_0_272_10 = 2.63
	local cut_0_273_10 = 2.65
	local cut_0_274_10 = 2.67
	local cut_0_275_10 = 2.69
	local cut_0_276_10 = 2.71
	local cut_0_277_10 = 2.73
	local cut_0_278_10 = 2.74
	local cut_0_279_10 = 2.76
	local cut_0_280_10 = 2.78
	local cut_0_281_10 = 2.80
	local cut_0_282_10 = 2.81
	local cut_0_283_10 = 2.83
	local cut_0_284_10 = 2.84
	local cut_0_285_10 = 2.86
	local cut_0_286_10 = 2.87
	local cut_0_287_10 = 2.89
	local cut_0_288_10 = 2.90
	local cut_0_289_10 = 2.91
	local cut_0_290_10 = 2.93
	local cut_0_291_10 = 2.94
	local cut_0_292_10 = 2.95
	local cut_0_293_10 = 2.96
	local cut_0_294_10 = 2.98
	local cut_0_295_10 = 2.99
	local cut_0_296_10 = 3.00
	local cut_0_297_10 = 3.01
	local cut_0_298_10 = 3.02
	local cut_0_299_10 = 3.03
	local cut_0_300_10 = 3.04
	
	* International female newborn size references (33-42+6 weeks) - 90th centile (for LGA)

	local cut_0_231_90 = 2.35
	local cut_0_232_90 = 2.40
	local cut_0_233_90 = 2.44
	local cut_0_234_90 = 2.48
	local cut_0_235_90 = 2.52
	local cut_0_236_90 = 2.56
	local cut_0_237_90 = 2.60
	local cut_0_238_90 = 2.64
	local cut_0_239_90 = 2.67
	local cut_0_240_90 = 2.71
	local cut_0_241_90 = 2.75
	local cut_0_242_90 = 2.79
	local cut_0_243_90 = 2.82
	local cut_0_244_90 = 2.86
	local cut_0_245_90 = 2.89
	local cut_0_246_90 = 2.93
	local cut_0_247_90 = 2.96
	local cut_0_248_90 = 2.99
	local cut_0_249_90 = 3.03
	local cut_0_250_90 = 3.06
	local cut_0_251_90 = 3.09
	local cut_0_252_90 = 3.12
	local cut_0_253_90 = 3.15
	local cut_0_254_90 = 3.18
	local cut_0_255_90 = 3.21
	local cut_0_256_90 = 3.24
	local cut_0_257_90 = 3.27
	local cut_0_258_90 = 3.30
	local cut_0_259_90 = 3.32
	local cut_0_260_90 = 3.35
	local cut_0_261_90 = 3.38
	local cut_0_262_90 = 3.40
	local cut_0_263_90 = 3.43
	local cut_0_264_90 = 3.46
	local cut_0_265_90 = 3.48
	local cut_0_266_90 = 3.51
	local cut_0_267_90 = 3.53
	local cut_0_268_90 = 3.55
	local cut_0_269_90 = 3.58
	local cut_0_270_90 = 3.60
	local cut_0_271_90 = 3.62
	local cut_0_272_90 = 3.64
	local cut_0_273_90 = 3.66
	local cut_0_274_90 = 3.68
	local cut_0_275_90 = 3.70
	local cut_0_276_90 = 3.72
	local cut_0_277_90 = 3.74
	local cut_0_278_90 = 3.76
	local cut_0_279_90 = 3.78
	local cut_0_280_90 = 3.80
	local cut_0_281_90 = 3.82
	local cut_0_282_90 = 3.84
	local cut_0_283_90 = 3.85
	local cut_0_284_90 = 3.87
	local cut_0_285_90 = 3.89
	local cut_0_286_90 = 3.90
	local cut_0_287_90 = 3.92
	local cut_0_288_90 = 3.93
	local cut_0_289_90 = 3.95
	local cut_0_290_90 = 3.96
	local cut_0_291_90 = 3.97
	local cut_0_292_90 = 3.99
	local cut_0_293_90 = 4.00
	local cut_0_294_90 = 4.01
	local cut_0_295_90 = 4.03
	local cut_0_296_90 = 4.04
	local cut_0_297_90 = 4.05
	local cut_0_298_90 = 4.06
	local cut_0_299_90 = 4.07
	local cut_0_300_90 = 4.08
	
	* Create variable 
	
	gen sga_vpt_ex =.
	gen lga_vpt_ex =.
		
	gen sga_ex =. 
	gen lga_ex =.
	
	foreach sex in 0 1 {
	    forvalues week = 168(1)230 {
		   
		   replace sga_vpt_ex = 1 if gestdays==(`week') & birweit_kg<(`cut_`sex'_`week'_10_vpt') & child_male==(`sex')
		   replace lga_vpt_ex = 1 if gestdays==(`week') & birweit_kg>(`cut_`sex'_`week'_90_vpt') & child_male==(`sex')
		
		} 
	}
	
	foreach sex in 0 1 {
	    forvalues week = 231(1)300 {
		   
		   replace sga_ex = 1 if gestdays==(`week') & birweit_kg<(`cut_`sex'_`week'_10') & child_male==(`sex')
		   replace lga_ex = 1 if gestdays==(`week') & birweit_kg>(`cut_`sex'_`week'_90') & child_male==(`sex')
		
		} 
	}
	
	tab sga_ex
	tab sga_vpt_ex
	
	replace sga_ex = 1 if sga_vpt_ex==1
	
	tab lga_ex
	tab lga_vpt_ex
	
	replace lga_ex = 1 if lga_vpt_ex==1
	
	replace sga_ex = 0 if sga_ex==. & lga_ex!=1
	replace lga_ex = 0 if lga_ex==. & sga_ex!=1
	
	gen aga_ex = 1 if sga_ex!=1 & lga_ex!=1 & birth_weight!=.
	
	keep patid pregid sga_ex lga_ex aga_ex
	
	rename sga_ex sga_ex_intergrowth
	rename aga_ex aga_ex_intergrowth
	rename lga_ex lga_ex_intergrowth
	
	save "$Datadir\externally_valid_sizeforga_intergrowth.dta", replace
	
********************************************************************************
