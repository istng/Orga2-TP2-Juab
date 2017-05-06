/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion fourCombine                                */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

/*

Dibujo ilustrando la idea del algoritmo:

Dado que indexamos desde 0, vamos a decir que la primer fila es una fila par, por ejemplo.

00 01 02 03 04 05 06 07
10 11 12 13 14 15 16 17
20 21 22 23 24 25 26 27
30 31 32 33 34 35 36 37
4 . . .				 .
5					 .
6					 .
7

La idea es dividir en cuatro, viendo el ejemplo anterior nos queda:

00 02 04 06 | 01 03 05 07
20 22 24 26 | 21 23 25 27
4 . . .
6 . . . 
10 12 14 16 | 11 13 15 17
30 32 34 36 | 31 33 35 37
5 . . .
7 . . .

Esto se puede ver como:
(donde C es cuadrante)
1ºC: filas pares, comlumnas pares  | 2ºC: filas pares, columnas impares
3ºC: filas impares, columnas pares | 4ºC: filas impares, columnas impares

Luego, la idea es conseguir esta matriz.

Para que los numeros cierren bien, vamos a suponer que la matriz pasada es de dimensión multiplo de 4.

*/

void C_fourCombine(uint8_t* src, uint32_t srcw, uint32_t srch,
                   uint8_t* dst, uint32_t dstw __attribute__((unused)), uint32_t dsth __attribute__((unused))) {

	//use tipo RGBA para poder tipar las matrices, pero no utilizo el contenido de los pixeles
	RGBA ( * matrix_src)[srcw] = (RGBA( * )[srcw])src;
	RGBA ( * matrix_dst)[dstw] = (RGBA( * )[dstw])dst;

	unsigned int mitad = (unsigned int)(((float)(dstw))/((float)(2)));
	unsigned int i = 0;
	while(i < srcw) {
		unsigned int j = 0;
		while(j < srch) {
			if (i % 2 == 0) {
				if (j % 2 == 0) {

				//1ºC: filas pares, columnas pares
					unsigned int I = i - (unsigned int)(((float)(i))/((float)(2)));
					unsigned int J = j - (unsigned int)(((float)(j))/((float)(2)));
					matrix_dst[I][J] = matrix_src[i][j];
					//observar que 0-(1/2)*0=, 2-(1/2)*2=1, 4-(1/2)*4=2, ...
				} else {
				//2ºC: filas pares, columnas impares
					unsigned int I = i - (unsigned int)(((float)(i))/((float)(2)));
					unsigned int J = j - (unsigned int)(ceil(((float)(j))/((float)(2)))) + mitad;
					matrix_dst[I][J] = matrix_src[i][j];
					//misma cuenta para filas, pero lo corro la mitad de la matriz
					//observar que (para impares):
					//	1-[1*1/2]=1-1=0, 3-[3*1/2]=1, 5-[5*1/2]=2, 7-[7*1/2]=3, ...
					//y lo corro la mitad de la matriz, en columnas
				}
			} else {
				if (j % 2 == 0) {
				//3ºC: filas impares, columnas pares
					unsigned int I = i - (unsigned int)(ceil(((float)(i))/((float)(2)))) + mitad;
					unsigned int J = j - (unsigned int)(((float)(j))/((float)(2)));
					matrix_dst[I][J] = matrix_src[i][j];
					
				} else {
				//4ºC: filas impares, columnas impares
					unsigned int I = i - (unsigned int)(ceil(((float)(i))/((float)(2)))) + mitad;
					unsigned int J = j - (unsigned int)(ceil(((float)(j))/((float)(2)))) + mitad;
					matrix_dst[I][J] = matrix_src[i][j];
				}
			}
			j++;
		}
		i++;
	}

}