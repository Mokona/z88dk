
#include "m32_math.h"

float m32_asinf (float x) __z88dk_fastcall
{
    float y;

    y = m32_sqrtf(1 - m32_sqr(x));
    return m32_atanf(x/y);
}

