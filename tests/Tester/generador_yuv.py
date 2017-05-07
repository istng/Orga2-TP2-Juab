import os
import subprocess

if not os.path.exists("Resultados"):
    os.makedirs("Resultados")
os.chdir("Resultados")

destino = input("Ingrese destino: ")

for src in os.listdir("../../data/imagenes_nuestras"):
        print( "Corriendo tests sobre %s:" %src)
        subprocess.call(["../../../src/tp2", "c", "rgb2yuv", "../../data/imagenes_nuestras/"+src, destino+"/"+"YUV"+"."+src])
