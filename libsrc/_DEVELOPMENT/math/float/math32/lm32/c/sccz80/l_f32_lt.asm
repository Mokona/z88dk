
SECTION	code_fp_math32
PUBLIC	l_f32_lt
EXTERN	m32_compare_callee


l_f32_lt:
	call	m32_compare_callee
	ccf
	ret	c
	dec	hl
	ret
