/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion convertRGBtoYUV y convertYUVtoRGB          */
/*                                                                           */
/* ************************************************************************* */

#define convertToY(R,G,B) ((66*R + 129*G + 25*B +128) >> 8) + 16
#define convertToU(R,G,B) (((-38)*R - 74*G + 112*B + 128) >> 8) + 128
#define convertToV(R,G,B) ((112*R - 94*G - 18*B + 128) >> 8) + 128
#define convertToR(Y,U,V) (298*(Y-16) + 409*(V-128) + 128) >> 8
#define convertToG(Y,U,V) (298*(Y-16) - 100*(U-128) - 208*(V-128) +128) >> 8
#define convertToB(Y,U,V) (298*(Y-16) + 516*(U-128) + 128) >> 8

#include "filtersAux.h"
#include "filters.h"
#include <math.h>

uint8_t saturateDef(int32_t converted) {
	if (converted > 255) {
		converted = 255;
	}
	if (converted < 0)
	{
		converted = 0;
	}

	return (uint8_t)converted;
}

void C_convertRGBtoYUV_defines(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)), uint32_t dsth __attribute__((unused))) {

	unsigned int i = 0;
	while(i < 4*srcw*srch) {
		int32_t B = src[i+1];
		int32_t G = src[i+2];
		int32_t R = src[i+3];

		dst[i] = src[i];
		dst[i+1] = saturateDef(convertToV(R,G,B));
		dst[i+2] = saturateDef(convertToU(R,G,B));
		dst[i+3] = saturateDef(convertToY(R,G,B));

		i = i + 4;
	}
}

void C_convertYUVtoRGB_defines(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)), uint32_t dsth __attribute__((unused))) {

	YUVA ( * matrix_src)[srcw] = (YUVA( * )[srcw])src;
	RGBA ( * matrix_dst)[dstw] = (RGBA( * )[dstw])dst;
	//matrix_src[fila][columna]

	for (unsigned int i = 0; i < srcw; ++i)	{
		for (unsigned int j = 0; j < srch; ++j) {
			matrix_dst[i][j].r = saturateDef(convertToR(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].g = saturateDef(convertToG(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].b = saturateDef(convertToB(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].a = matrix_src[i][j].a;
		}
	}
}
