
	SECTION	code_fp_math32
	PUBLIC	tan
	EXTERN	_m32_tanf


tan:
	pop	bc
	pop	hl
	pop	de
	push	de
	push	hl
	push	bc
	jp	_m32_tanf
