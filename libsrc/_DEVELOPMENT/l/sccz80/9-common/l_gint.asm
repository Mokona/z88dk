;       Z88 Small C+ Run time Library
;       l_gint variant to be used sometimes by the peephole optimizer
;

SECTION code_clib
SECTION code_l_sccz80

PUBLIC l_gint

l_gint:

   ld a,(hl+)
   ld h,(hl)
   ld l,a
   
   ret
