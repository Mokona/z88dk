
; unsigned long hbios_get_offset(void *p)
; fastcall

SECTION code_clib
SECTION code_arch

PUBLIC hbios_get_offset

EXTERN asm_hbios_get_offset

defc hbios_get_offset = asm_hbios_get_offset
