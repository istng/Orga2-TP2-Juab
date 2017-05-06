import os
import subprocess

if not os.path.exists("Resultados"):
    os.makedirs("Resultados")
os.chdir("Resultados")

funcion = input("Ingrese la función: ")
repeticiones = input("Ingrese la cantidad de repeticiones por cada imagen: ")
val = input("Ingrese un valor: ")

for src in os.listdir("../../data/imagenes_nuestras"):
        print( "Corriendo tests sobre %s:" %src)
        subprocess.call(["../../../src/benchmark", funcion, repeticiones, val, "../../data/imagenes_nuestras/"+src, funcion+"."+src+".txt"])
