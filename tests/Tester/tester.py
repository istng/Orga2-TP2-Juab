import os
import subprocess

if not os.path.exists("Resultados"):
    os.makedirs("Resultados")
os.chdir("Resultados")

#funcion = input("Ingrese la función: ")
#repeticiones = input("Ingrese la cantidad de repeticiones por cada imagen: ")
#val = input("Ingrese un valor: ")

#funcionesRGB = ["C_convertRGBtoYUV","ASM_convertRGBtoYUV","ASM_convertRGBtoYUV_phaddd","ASM_convertRGBtoYUV_macros","ASM_convertRGBtoYUV_loopUnrolling","C_linearZoom", "ASM_linearZoom","ASM_linearZoom_tres_pasadas","ASM_linearZoom_mem_alineada"]
#funcionesYUV = ["C_convertYUVtoRGB","ASM_convertYUVtoRGB","ASM_convertYUVtoRGB_phaddd","ASM_convertYUVtoRGB_macros","ASM_convertYUVtoRGB_loopUnrolling"]
funcionesRGB = ["C_convertRGBtoYUV","ASM_convertRGBtoYUV","ASM_convertRGBtoYUV_phaddd","ASM_convertRGBtoYUV_macros","ASM_convertRGBtoYUV_loopUnrolling","C_fourCombine","ASM_fourCombine","C_maxCloser","ASM_maxCloser","ASM_maxCloser_cache"]


repeticiones = "200"
val = "0"

for funcion in funcionesRGB:
    print ("Corriendo tests para: %s" %funcion)
    if not os.path.exists(funcion):
        os.makedirs(funcion)
    os.chdir(funcion)
    for src in os.listdir("../../../data/imagenes_nuestras/RGB"):
        print( "Corriendo tests sobre %s:" %src)
        subprocess.call(["../../../../src/benchmark", funcion, repeticiones, val, "../../../data/imagenes_nuestras/RGB/"+src, funcion+"."+src+".txt"])
    os.chdir("..")

#for funcion in funcionesYUV:
#    print ("Corriendo tests para: %s" %funcion)
#    if not os.path.exists(funcion):
#        os.makedirs(funcion)
#    os.chdir(funcion)
#    for src in os.listdir("../../../data/imagenes_nuestras/YUV"):
#        print( "Corriendo tests sobre %s:" %src)
#        subprocess.call(["../../../../src/benchmark", funcion, repeticiones, val, "../../../data/imagenes_nuestras/YUV/"+src, funcion+"."+src+".txt"])
#    os.chdir("..")
