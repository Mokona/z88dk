
; void dzx1_smart_rcs_back_callee(void *src, void *dst)

SECTION code_clib
SECTION code_compress_zx1

PUBLIC dzx1_smart_rcs_back_callee

EXTERN asm_dzx1_smart_rcs_back

dzx1_smart_rcs_back_callee:

   pop hl
   pop de
   ex (sp),hl

   jp asm_dzx1_smart_rcs_back
