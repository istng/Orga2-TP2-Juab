#ifndef FILTERAUX_HH
#define FILTERAUX_HH

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include "../bmp/bmp.h"

void C_convertRGBtoYUV_defines(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void C_convertYUVtoRGB_defines(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertYUVtoRGB_loopUnrolling(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertRGBtoYUV_loopUnrolling(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertYUVtoRGB_phaddd(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertRGBtoYUV_phaddd(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertYUVtoRGB_macros(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_convertRGBtoYUV_macros(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_maxCloser_cache(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth, float val);

void ASM_fourCombine_unrolling(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_linearZoom_mem_alineada(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);

void ASM_linearZoom_tres_pasadas(uint8_t* src, uint32_t srcw, uint32_t srch,
                         uint8_t* dst, uint32_t dstw, uint32_t dsth);


#endif
