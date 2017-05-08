import os
import subprocess

if not os.path.exists("ResultadosO3"):
    os.makedirs("ResultadosO3")
os.chdir("ResultadosO3")

#funcion = input("Ingrese la función: ")
#repeticiones = input("Ingrese la cantidad de repeticiones por cada imagen: ")
#val = input("Ingrese un valor: ")

funcionesRGB = ["ASM_maxCloser","ASM_maxCloser_cache"]
#funcionesYUV = ["C_convertYUVtoRGB"]
#funcionesRGB = ["ASM_fourCombine","ASM_fourCombine_unrolling"]


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

for funcion in funcionesYUV:
    print ("Corriendo tests para: %s" %funcion)
    if not os.path.exists(funcion):
        os.makedirs(funcion)
    os.chdir(funcion)
    for src in os.listdir("../../../data/imagenes_nuestras/YUV"):
        print( "Corriendo tests sobre %s:" %src)
        subprocess.call(["../../../../src/benchmark", funcion, repeticiones, val, "../../../data/imagenes_nuestras/YUV/"+src, funcion+"."+src+".txt"])
    os.chdir("..")
