/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>
uint8_t saturar(float a){
  if (a > 255) {
    return 0;
  }
  else {return a;}
}

// kernelValue: calculo el valor del kernel para el pixel pasado por parametro
// ** Asumimos que hay por lo menos 3 pixeles de padding
// ** src <-- puntero al pixel de la imagen original
uint8_t* kernelValues(uint8_t* src, uint32_t srcw, uint32_t srch, float val){

  uint8_t* max = malloc(3); // Pedimos memoria para un arreglo de 3 bytes [ maxR,maxG,maxB]
  max[0] = 0; //maxRed
  max[1] = 0; //maxGreen
  max[2] = 0; //maxBlue
  for ( int i = 0 ; i <= 6 ; i++) {
    for (int j = 0; j <= 6; j++) {
      if ( *(src + 4*i*srcw + 4*j + 3) > max[0] ) {max [0] = *(src + 4*i*srcw + 4*j + 3); };
      if ( *(src + 4*i*srcw + 4*j + 2) > max[1] ) {max [1] = *(src + 4*i*srcw + 4*j + 2); };
      if ( *(src + 4*i*srcw + 4*j + 1) > max[2] ) {max [2] = *(src + 4*i*srcw + 4*j + 1); };
    }
  }

  float maxR =  (float) max[0];
  float maxG =  (float) max[1];
  float maxB =  (float) max[2];
  float R =  (float) *(src + 4*3*srcw + 4*3 + 3);
  float G =  (float) *(src + 4*3*srcw + 4*3 + 2);
  float B =  (float) *(src + 4*3*srcw + 4*3 + 1);


  max[0] = saturar( R * (1-val) + maxR * (val)); // valueR = src[R] *val + maxR*(1-val)
  max[1] = saturar( G * (1-val) + maxG * (val)); // valueR = src[G] *val + maxG*(1-val)
  max[2] = saturar( B * (1-val) + maxB * (val)); // valueR = src[B] *val + maxB*(1-val)



  return max;

}

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch,
                 uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {


    for (uint32_t i = 0; i < srcw ; i++) {
      for (uint32_t j = 0; j < srch; j++) {

        if ( (3 <= i) && (i < srcw-3) && (3 <= j) && (j < srcw-3 ) ) {
          //uint8_t* pixelKernel = kernelValues(src + 4*i*srcw + 4*j - 4*3*srcw - 4*3 ,srcw,srch,val);

          uint8_t* tempsrc = src;
          src = src + 4*i*srcw + 4*j - 4*3*srcw - 4*3;

          uint8_t maxRed = 0; //maxRed
          uint8_t maxGreen = 0; //maxGreen
          uint8_t maxBlue = 0; //maxBlue

          for ( int i = 0 ; i <= 6 ; i++) {
            for (int j = 0; j <= 6; j++) {
              if ( *(src + 4*i*srcw + 4*j + 3) > maxRed )   {maxRed  = *(src + 4*i*srcw + 4*j + 3); };
              if ( *(src + 4*i*srcw + 4*j + 2) > maxGreen ) {maxGreen = *(src + 4*i*srcw + 4*j + 2); };
              if ( *(src + 4*i*srcw + 4*j + 1) > maxBlue )  {maxBlue = *(src + 4*i*srcw + 4*j + 1); };
            }
          }

          float maxR =  (float) maxRed;
          float maxG =  (float) maxGreen;
          float maxB =  (float) maxBlue;
          float R =  (float) *(src + 4*3*srcw + 4*3 + 3);
          float G =  (float) *(src + 4*3*srcw + 4*3 + 2);
          float B =  (float) *(src + 4*3*srcw + 4*3 + 1);


          maxRed = saturar( R * (1-val) + maxR * (val)); // valueR = src[R] *val + maxR*(1-val)
          maxGreen = saturar( G * (1-val) + maxG * (val)); // valueR = src[G] *val + maxG*(1-val)
          maxBlue = saturar( B * (1-val) + maxB * (val)); // valueR = src[B] *val + maxB*(1-val)

          *(dst) = *(dst + 4*i*srcw + 4*j); // Copiamos el valor A
          *(dst + 4*i*srcw + 4*j + 1) = maxBlue; // Copiamos el valor del Azul
          *(dst + 4*i*srcw + 4*j + 2) = maxGreen; // Copiamos el valor del Verde
          *(dst + 4*i*srcw + 4*j + 3) = maxRed; // Copiamos el valor del Rojo

          //recuperamos el valor de src
          src = tempsrc;


        }

        else{
          *(dst + 4*i*srcw + 4*j) = 255;
          *(dst + 4*i*srcw + 4*j + 1) = 255;
          *(dst + 4*i*srcw + 4*j + 2) = 255;
          *(dst + 4*i*srcw + 4*j + 3) = 255;
        }


      }
    }


}
