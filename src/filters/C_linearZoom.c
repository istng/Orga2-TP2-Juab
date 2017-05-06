/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
    
    // En el formato BMP las lineas de la imagen se encuentran almacenadas de
    // forma invertida. Es decir, en la primera fila de la matriz se encuentra la última lı́nea de la
    // imagen, en la segunda fila se encuentra la anteúltima y ası́ sucesivamente.

    // La ultima fila de la imagen es una copia de la anteúltima fila y 
    // la ultima columna es una copia de la anteúltima columna

    // El algoritmo primero calcula las dos ultimas filas de la imagen (las dos primeras en el formato BMP)
    // El algoritmo calcula dos filas en cada iteración del ciclo principal
    // Las dos últimas columnas de cada fila se calculan por separado, fuera del ciclo secundario
    // que calcula los elementos de cada fila.

    RGBA (*src_RGBA)[srcw] = (RGBA (*)[srcw]) src;
    RGBA (*dst_RGBA)[dstw] = (RGBA (*)[dstw]) dst;

    uint32_t src_fil = 0;
    uint32_t src_col = 0;
    uint32_t dst_fil = 0;
    uint32_t dst_col = 0;
    uint16_t alpha16, blue16, green16, red16;

    // Fila inferior de la imagen
    for (dst_col = 0, src_col = 0; dst_col < dstw - 2; dst_col++, src_col++)
    {
        dst_RGBA[dst_fil][dst_col].a = src_RGBA[src_fil][src_col].a;
        dst_RGBA[dst_fil][dst_col].b = src_RGBA[src_fil][src_col].b;
        dst_RGBA[dst_fil][dst_col].g = src_RGBA[src_fil][src_col].g;
        dst_RGBA[dst_fil][dst_col].r = src_RGBA[src_fil][src_col].r;

        dst_col++;

        alpha16 = src_RGBA[src_fil][src_col].a + src_RGBA[src_fil][src_col+1].a;
        blue16  = src_RGBA[src_fil][src_col].b + src_RGBA[src_fil][src_col+1].b;
        green16 = src_RGBA[src_fil][src_col].g + src_RGBA[src_fil][src_col+1].g;
        red16   = src_RGBA[src_fil][src_col].r + src_RGBA[src_fil][src_col+1].r;

        dst_RGBA[dst_fil][dst_col].a = (uint8_t) (alpha16 >> 1);
        dst_RGBA[dst_fil][dst_col].b = (uint8_t) (blue16  >> 1);
        dst_RGBA[dst_fil][dst_col].g = (uint8_t) (green16 >> 1);
        dst_RGBA[dst_fil][dst_col].r = (uint8_t) (red16   >> 1);
    }

    // Ultimas dos columnas de la fila infeior
    dst_RGBA[dst_fil][dst_col].a = src_RGBA[src_fil][src_col].a;
    dst_RGBA[dst_fil][dst_col].b = src_RGBA[src_fil][src_col].b;
    dst_RGBA[dst_fil][dst_col].g = src_RGBA[src_fil][src_col].g;
    dst_RGBA[dst_fil][dst_col].r = src_RGBA[src_fil][src_col].r;

    dst_RGBA[dst_fil][dst_col+1].a = src_RGBA[src_fil][src_col].a;
    dst_RGBA[dst_fil][dst_col+1].b = src_RGBA[src_fil][src_col].b;
    dst_RGBA[dst_fil][dst_col+1].g = src_RGBA[src_fil][src_col].g;
    dst_RGBA[dst_fil][dst_col+1].r = src_RGBA[src_fil][src_col].r;

    dst_fil++;

    // La ultima y anteultima fila son identicas
    for(dst_col = 0; dst_col < dstw; dst_col++){
        dst_RGBA[dst_fil][dst_col].a = dst_RGBA[dst_fil-1][dst_col].a;
        dst_RGBA[dst_fil][dst_col].b = dst_RGBA[dst_fil-1][dst_col].b;
        dst_RGBA[dst_fil][dst_col].g = dst_RGBA[dst_fil-1][dst_col].g;
        dst_RGBA[dst_fil][dst_col].r = dst_RGBA[dst_fil-1][dst_col].r;
    }

    dst_fil++;
    src_fil++;

    for( ; src_fil < srch; src_fil++){
        // Fila 1
        for(dst_col = 0, src_col = 0; dst_col < dstw - 2; dst_col++, src_col++){
            alpha16 = src_RGBA[src_fil-1][src_col].a + src_RGBA[src_fil][src_col].a;
            blue16  = src_RGBA[src_fil-1][src_col].b + src_RGBA[src_fil][src_col].b;
            green16 = src_RGBA[src_fil-1][src_col].g + src_RGBA[src_fil][src_col].g;
            red16   = src_RGBA[src_fil-1][src_col].r + src_RGBA[src_fil][src_col].r;

            dst_RGBA[dst_fil][dst_col].a = (uint8_t) (alpha16 >> 1);
            dst_RGBA[dst_fil][dst_col].b = (uint8_t) (blue16  >> 1);
            dst_RGBA[dst_fil][dst_col].g = (uint8_t) (green16 >> 1);
            dst_RGBA[dst_fil][dst_col].r = (uint8_t) (red16   >> 1);

            dst_col++;

            alpha16 += src_RGBA[src_fil-1][src_col+1].a + src_RGBA[src_fil][src_col+1].a;
            blue16  += src_RGBA[src_fil-1][src_col+1].b + src_RGBA[src_fil][src_col+1].b;
            green16 += src_RGBA[src_fil-1][src_col+1].g + src_RGBA[src_fil][src_col+1].g;
            red16   += src_RGBA[src_fil-1][src_col+1].r + src_RGBA[src_fil][src_col+1].r;

            dst_RGBA[dst_fil][dst_col].a = (uint8_t) (alpha16 >> 2);
            dst_RGBA[dst_fil][dst_col].b = (uint8_t) (blue16  >> 2);
            dst_RGBA[dst_fil][dst_col].g = (uint8_t) (green16 >> 2);
            dst_RGBA[dst_fil][dst_col].r = (uint8_t) (red16   >> 2);
        }

        // Últimas dos columnas de la fila
        alpha16 = src_RGBA[src_fil-1][src_col].a + src_RGBA[src_fil][src_col].a;
        blue16  = src_RGBA[src_fil-1][src_col].b + src_RGBA[src_fil][src_col].b;
        green16 = src_RGBA[src_fil-1][src_col].g + src_RGBA[src_fil][src_col].g;
        red16   = src_RGBA[src_fil-1][src_col].r + src_RGBA[src_fil][src_col].r;

        dst_RGBA[dst_fil][dst_col].a = (uint8_t) (alpha16 >> 1);
        dst_RGBA[dst_fil][dst_col].b = (uint8_t) (blue16  >> 1);
        dst_RGBA[dst_fil][dst_col].g = (uint8_t) (green16 >> 1);
        dst_RGBA[dst_fil][dst_col].r = (uint8_t) (red16   >> 1);

        // Ultima elemento es una copia del anteúltimo
        dst_RGBA[dst_fil][dst_col+1].a = dst_RGBA[dst_fil][dst_col].a;
        dst_RGBA[dst_fil][dst_col+1].b = dst_RGBA[dst_fil][dst_col].b;
        dst_RGBA[dst_fil][dst_col+1].g = dst_RGBA[dst_fil][dst_col].g;
        dst_RGBA[dst_fil][dst_col+1].r = dst_RGBA[dst_fil][dst_col].r;

        dst_fil++;
        // Fila 2
        for (dst_col = 0, src_col = 0; dst_col < dstw - 2; dst_col++, src_col++)
        {
            dst_RGBA[dst_fil][dst_col].a = src_RGBA[src_fil][src_col].a;
            dst_RGBA[dst_fil][dst_col].b = src_RGBA[src_fil][src_col].b;
            dst_RGBA[dst_fil][dst_col].g = src_RGBA[src_fil][src_col].g;
            dst_RGBA[dst_fil][dst_col].r = src_RGBA[src_fil][src_col].r;

            dst_col++;

            alpha16 = src_RGBA[src_fil][src_col].a + src_RGBA[src_fil][src_col+1].a;
            blue16  = src_RGBA[src_fil][src_col].b + src_RGBA[src_fil][src_col+1].b;
            green16 = src_RGBA[src_fil][src_col].g + src_RGBA[src_fil][src_col+1].g;
            red16   = src_RGBA[src_fil][src_col].r + src_RGBA[src_fil][src_col+1].r;

            dst_RGBA[dst_fil][dst_col].a = (uint8_t) (alpha16 >> 1);
            dst_RGBA[dst_fil][dst_col].b = (uint8_t) (blue16  >> 1);
            dst_RGBA[dst_fil][dst_col].g = (uint8_t) (green16 >> 1);
            dst_RGBA[dst_fil][dst_col].r = (uint8_t) (red16   >> 1);
        }

        // Ultimas dos columnas de la fila
        dst_RGBA[dst_fil][dst_col].a = src_RGBA[src_fil][src_col].a;
        dst_RGBA[dst_fil][dst_col].b = src_RGBA[src_fil][src_col].b;
        dst_RGBA[dst_fil][dst_col].g = src_RGBA[src_fil][src_col].g;
        dst_RGBA[dst_fil][dst_col].r = src_RGBA[src_fil][src_col].r;

        dst_RGBA[dst_fil][dst_col+1].a = src_RGBA[src_fil][src_col].a;
        dst_RGBA[dst_fil][dst_col+1].b = src_RGBA[src_fil][src_col].b;
        dst_RGBA[dst_fil][dst_col+1].g = src_RGBA[src_fil][src_col].g;
        dst_RGBA[dst_fil][dst_col+1].r = src_RGBA[src_fil][src_col].r;

        dst_fil++;
    }
}