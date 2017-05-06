#!/bin/bash

# Parametros para el conjunto de testers 

DATADIR=./data
TESTINDIR=$DATADIR/imagenes_nuestras
CATEDRADIR=$DATADIR/resultados_catedra
ALUMNOSDIR=$DATADIR/resultados_nuestros

IMAGENES=(lena.bmp colores.bmp)
SIZES=(96x96  192x192  288x288  384x384  480x480  576x576  672x672  768x768  864x864  960x960  1056x1056  1152x1152  1248x1248  1344x1344  1440x1440  1536x1536)
SIZESMEM=(16x16 32x32)

TP2CAT=./solucion_catedra/tp2
TP2ALU=../bin/tp2
DIFFER=../bin/diff

DIFFYUV=3    # convertYUV
DIFFRGB=3    # convertRGB
DIFFFOUR=1   # fourCombine
DIFFZOOM=2   # linearZoom
DIFFMAX=3    # maxCloser

# Colores

ROJO="\e[31m"
VERDE="\e[32m"
AZUL="\e[94m"
DEFAULT="\e[39m"