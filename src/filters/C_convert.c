/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion convertRGBtoYUV y convertYUVtoRGB          */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

uint8_t saturate(int32_t converted) {
	if (converted > 255) {
		converted = 255;
	}
	if (converted < 0)
	{
		converted = 0;
	}

	return (uint8_t)converted;
}

int32_t convertToY(int32_t R, int32_t G, int32_t B) {
	int32_t converted = ((66*R + 129*G + 25*B +128) >> 8) + 16;
	return converted;
}

int32_t convertToU(int32_t R, int32_t G, int32_t B) {
	int32_t converted = (((-38)*R - 74*G + 112*B + 128) >> 8) + 128;
	return converted;
}

int32_t convertToV(int32_t R, int32_t G, int32_t B) {
	int32_t converted = ((112*R - 94*G - 18*B + 128) >> 8) + 128;
	return converted;
}

int32_t convertToR(int32_t Y, int32_t U __attribute__((unused)), int32_t V) {
	int32_t converted = (298*(Y-16) + 409*(V-128) + 128) >> 8;
	return converted;
}

int32_t convertToG(int32_t Y, int32_t U, int32_t V ) {
	int32_t converted = (298*(Y-16) - 100*(U-128) - 208*(V-128) +128) >> 8;
	return converted;
}

int32_t convertToB(int32_t Y, int32_t U, int32_t V __attribute__((unused))) {
	int32_t converted = (298*(Y-16) + 516*(U-128) + 128) >> 8;
	return converted;
}

void C_convertRGBtoYUV(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)), uint32_t dsth __attribute__((unused))) {

	/*unsigned int i = 0;
	while(i < 4*srcw*srch) {
		int32_t B = src[i+1];
		int32_t G = src[i+2];
		int32_t R = src[i+3];

		dst[i] = src[i];
		dst[i+1] = saturate(convertToV(R,G,B));
		dst[i+2] = saturate(convertToU(R,G,B));
		dst[i+3] = saturate(convertToY(R,G,B));

		i = i + 4;
	}*/

	RGBA ( * matrix_src)[srcw] = (RGBA( * )[srcw])src;
	YUVA ( * matrix_dst)[dstw] = (YUVA( * )[dstw])dst;
	//matrix_src[fila][columna]

	for (unsigned int i = 0; i < srcw; ++i)	{
		for (unsigned int j = 0; j < srch; ++j) {
			matrix_dst[i][j].y = saturate(convertToY(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].u = saturate(convertToU(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].v = saturate(convertToV(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].a = matrix_src[i][j].a;
		}
	}
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw __attribute__((unused)), uint32_t dsth __attribute__((unused))) {

	YUVA ( * matrix_src)[srcw] = (YUVA( * )[srcw])src;
	RGBA ( * matrix_dst)[dstw] = (RGBA( * )[dstw])dst;
	//matrix_src[fila][columna]

	/*for (unsigned int i = 0; i < srcw; ++i)	{
		for (unsigned int j = 0; j < srch; ++j) {
			matrix_dst[i][j].r = saturate(convertToR(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].g = saturate(convertToG(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].b = saturate(convertToB(matrix_src[i][j].y, matrix_src[i][j].u, matrix_src[i][j].v));
			matrix_dst[i][j].a = matrix_src[i][j].a;
		}
	}*/
	unsigned int i = 0;
	while(i < 4*srcw*srch) {
		int32_t B = src[i+1];
		int32_t G = src[i+2];
		int32_t R = src[i+3];

		dst[i] = src[i];
		dst[i+1] = saturate(convertToB(R,G,B));
		dst[i+2] = saturate(convertToG(R,G,B));
		dst[i+3] = saturate(convertToR(R,G,B));

		i = i + 4;
	}
}
