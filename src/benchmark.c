#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "run.h"
#include "bmp/bmp.h"
#include "filters/filters.h"
#include "filters/filtersAux.h"
#include "rdtsc.h"



#define PATH_OUTPUT "/tmp/lena_out.bmp"


/***********************************
PARAMTROS: ./benchmark_maxCloser FUNCION REPETICIONES VAL SRC DESTINO

************************************/

int main(int argc __attribute__((unused)), char* argv[]){
  double VAL;
  char* FUNCION = argv[1];
  unsigned int REPETICIONES = atoi(argv[2]);
  VAL = atof(argv[3]);
  char* SRC = argv[4];
  char* DESTINO = argv[5];

  char* src = SRC;
  char* dst = PATH_OUTPUT;

  uint8_t* dataSrc;
  uint8_t* dataDst;
  uint32_t h;
  uint32_t w;
  BMP* bmp;
  unsigned long start, end, delta;
  uint64_t i;

  remove(DESTINO);
  FILE* datos;
  datos = fopen(DESTINO,"w");

  for(i = 0; i < REPETICIONES ; i++){

    if(open(src,&bmp,&dataSrc,&w,&h)) { return -1;}  // open error
    dataDst = malloc(sizeof(uint8_t)*4*h*w);

    //CONVERT:
    if(strcmp(FUNCION, "C_convertYUVtoRGB") == 0){
      RDTSC_START(start);
      C_convertYUVtoRGB(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
	  else if(strcmp(FUNCION, "C_convertRGBtoYUV") == 0){
      RDTSC_START(start);
      C_convertRGBtoYUV(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }

    else if(strcmp(FUNCION, "ASM_convertYUVtoRGB") == 0){
      RDTSC_START(start);
      ASM_convertYUVtoRGB(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_convertRGBtoYUV") == 0){
      RDTSC_START(start);
      ASM_convertRGBtoYUV(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    
    else if(strcmp(FUNCION, "ASM_convertYUVtoRGB_phaddd") == 0){
      RDTSC_START(start);
      ASM_convertYUVtoRGB_phaddd(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_convertYUVtoRGB_macros") == 0){
      RDTSC_START(start);
      ASM_convertYUVtoRGB_macros(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_convertYUVtoRGB_loopUnrolling") == 0){
      RDTSC_START(start);
      ASM_convertYUVtoRGB_loopUnrolling(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "C_convertRGBtoYUV_defines") == 0){
      RDTSC_START(start);
      C_convertRGBtoYUV_defines(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }

    //FOUR COMBINE:
    else if(strcmp(FUNCION, "C_fourCombine") == 0){
      RDTSC_START(start);
      C_fourCombine(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }

    else if(strcmp(FUNCION, "ASM_fourCombine") == 0){
      RDTSC_START(start);
      ASM_fourCombine(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_fourCombine_unrolling") == 0){
      RDTSC_START(start);
      ASM_fourCombine_unrolling(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }

    //LINEAR ZOOM
    else if(strcmp(FUNCION, "C_linearZoom") == 0){
      RDTSC_START(start);
      C_linearZoom(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_linearZoom") == 0){
      RDTSC_START(start);
      ASM_linearZoom(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_linearZoom_tres_pasadas") == 0){
      RDTSC_START(start);
      ASM_linearZoom_tres_pasadas(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_linearZoom_mem_alineada") == 0){
      RDTSC_START(start);
      ASM_linearZoom_mem_alineada(dataSrc,w,h,dataDst,w,h);
      RDTSC_STOP(end);
    }

    //MAX CLOSER:
    else if(strcmp(FUNCION, "C_maxCloser") == 0){
      RDTSC_START(start);
      C_maxCloser(dataSrc,w,h,dataDst,w,h,VAL);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_maxCloser") == 0){
      RDTSC_START(start);
      ASM_maxCloser(dataSrc,w,h,dataDst,w,h,VAL);
      RDTSC_STOP(end);
    }
    else if(strcmp(FUNCION, "ASM_maxCloser_cache") == 0){
      RDTSC_START(start);
      ASM_maxCloser_cache(dataSrc,w,h,dataDst,w,h,VAL);
      RDTSC_STOP(end);
    }


    else {return -1;}

    delta = end - start;
    if (i < REPETICIONES - 1) {
      fprintf(datos, "%ld\n", delta);
    } else {
      fprintf(datos, "%ld", delta);
    }
    free(dataSrc);
    if(save(dst,&bmp,&dataDst,&w,&h)) { return -1;}  // save error
    bmp_delete(bmp);
  }
    fclose(datos);
  return 0;
}
