
SECTION	code_fp_math32
PUBLIC	l_f32_ge
EXTERN	m32_compare_callee


l_f32_ge:
	call	m32_compare_callee
	ccf
	ret	nc
	scf
	ret	z
	ccf
	dec	hl
	ret
