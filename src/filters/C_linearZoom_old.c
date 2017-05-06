/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

#define ALPHA 0
#define BLUE 1
#define GREEN 2
#define RED 3
#define PIXEL_SIZE 4

// El orden de las filas esta invertido, pero el de las columnas es el correcto
// Este algoritmo comienza desde la fila inferior de la imagen y va subiendo

void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    uint8_t *dst_pos = dst;
    uint8_t *dst_pos_temp = dst;
    uint32_t i, j;

    // Fila inferior de la imagen
    for (j = 0; j < srcw - 1; j++)
    {
        *dst_pos++ = *(src + j * PIXEL_SIZE + ALPHA);
        *dst_pos++ = *(src + j * PIXEL_SIZE + BLUE);
        *dst_pos++ = *(src + j * PIXEL_SIZE + GREEN);
        *dst_pos++ = *(src + j * PIXEL_SIZE + RED);

        *dst_pos++ = (*(src + j * PIXEL_SIZE + ALPHA) + *(src + (j + 1) * PIXEL_SIZE + ALPHA)) / 2;
        *dst_pos++ = (*(src + j * PIXEL_SIZE + BLUE)  + *(src + (j + 1) * PIXEL_SIZE + BLUE))  / 2;
        *dst_pos++ = (*(src + j * PIXEL_SIZE + GREEN) + *(src + (j + 1) * PIXEL_SIZE + GREEN)) / 2;
        *dst_pos++ = (*(src + j * PIXEL_SIZE + RED)   + *(src + (j + 1) * PIXEL_SIZE + RED))   / 2;
    }

    // Ultimas dos columnas de la fila infeior
    *dst_pos++ = *(src + j * PIXEL_SIZE + ALPHA);
    *dst_pos++ = *(src + j * PIXEL_SIZE + BLUE);
    *dst_pos++ = *(src + j * PIXEL_SIZE + GREEN);
    *dst_pos++ = *(src + j * PIXEL_SIZE + RED);

    *dst_pos++ = *(src + j * PIXEL_SIZE + ALPHA);
    *dst_pos++ = *(src + j * PIXEL_SIZE + BLUE);
    *dst_pos++ = *(src + j * PIXEL_SIZE + GREEN);
    *dst_pos++ = *(src + j * PIXEL_SIZE + RED);

    // La ultima y anteultima fila son identicas
    for (j = 0; j < dstw; j++)
    {
        *dst_pos++ = *dst_pos_temp++; // ALPHA
        *dst_pos++ = *dst_pos_temp++; // BLUE
        *dst_pos++ = *dst_pos_temp++; // GREEN
        *dst_pos++ = *dst_pos_temp++; // RED
    }

    for(i = 1; i < srch; i++){
        for(j = 0; j < srcw - 1; j++){
            *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + ALPHA) + *(src + (i * srcw  + j) * PIXEL_SIZE + ALPHA)) / 2;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + BLUE)  + *(src + (i * srcw  + j) * PIXEL_SIZE + BLUE))  / 2;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + GREEN) + *(src + (i * srcw  + j) * PIXEL_SIZE + GREEN)) / 2;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + RED)   + *(src + (i * srcw  + j) * PIXEL_SIZE + RED))   / 2;

            *dst_pos++ = (*(src + ((i - 1) * srcw + j      )  * PIXEL_SIZE + ALPHA) + *(src + (i * srcw  + j      ) * PIXEL_SIZE + ALPHA) + 
                          *(src + ((i - 1) * srcw + (j + 1))  * PIXEL_SIZE + ALPHA) + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + ALPHA)) / 4;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j      )  * PIXEL_SIZE + BLUE)  + *(src + (i * srcw  + j      ) * PIXEL_SIZE + BLUE)  + 
                          *(src + ((i - 1) * srcw + (j + 1))  * PIXEL_SIZE + BLUE)  + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + BLUE))  / 4;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j      )  * PIXEL_SIZE + GREEN) + *(src + (i * srcw  + j      ) * PIXEL_SIZE + GREEN) + 
                          *(src + ((i - 1) * srcw + (j + 1))  * PIXEL_SIZE + GREEN) + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + GREEN)) / 4;
            *dst_pos++ = (*(src + ((i - 1) * srcw + j      )  * PIXEL_SIZE + RED)   + *(src + (i * srcw  + j      ) * PIXEL_SIZE + RED)   + 
                          *(src + ((i - 1) * srcw + (j + 1))  * PIXEL_SIZE + RED)   + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + RED))   / 4;
        }

        dst_pos_temp = dst_pos;

        *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + ALPHA) + *(src + (i * srcw  + j) * PIXEL_SIZE + ALPHA)) / 2;
        *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + BLUE)  + *(src + (i * srcw  + j) * PIXEL_SIZE + BLUE))  / 2;
        *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + GREEN) + *(src + (i * srcw  + j) * PIXEL_SIZE + GREEN)) / 2;
        *dst_pos++ = (*(src + ((i - 1) * srcw + j) * PIXEL_SIZE + RED)   + *(src + (i * srcw  + j) * PIXEL_SIZE + RED))   / 2;

        *dst_pos++ = *dst_pos_temp++; // ALPHA
        *dst_pos++ = *dst_pos_temp++; // BLUE
        *dst_pos++ = *dst_pos_temp++; // GREEN
        *dst_pos++ = *dst_pos_temp++; // RED


        for(j = 0; j < srcw - 1; j++){
            *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + ALPHA);
            *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + BLUE);
            *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + GREEN);
            *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + RED);

            *dst_pos++ = (*(src + (i * srcw + j) * PIXEL_SIZE + ALPHA) + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + ALPHA)) / 2;
            *dst_pos++ = (*(src + (i * srcw + j) * PIXEL_SIZE + BLUE)  + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + BLUE))  / 2;
            *dst_pos++ = (*(src + (i * srcw + j) * PIXEL_SIZE + GREEN) + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + GREEN)) / 2;
            *dst_pos++ = (*(src + (i * srcw + j) * PIXEL_SIZE + RED)   + *(src + (i * srcw  + (j + 1)) * PIXEL_SIZE + RED))   / 2;
        }

        dst_pos_temp = dst_pos;

        // Ultimas dos columnas de la fila
        *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + ALPHA);
        *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + BLUE);
        *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + GREEN);
        *dst_pos++ = *(src + (i * srcw + j) * PIXEL_SIZE + RED);

        *dst_pos++ = *dst_pos_temp++; // ALPHA
        *dst_pos++ = *dst_pos_temp++; // BLUE
        *dst_pos++ = *dst_pos_temp++; // GREEN
        *dst_pos++ = *dst_pos_temp++; // RED
    }
}

