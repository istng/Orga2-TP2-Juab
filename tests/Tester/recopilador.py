import os
import math

imagenes = input("Ingrese la carpeta contenedora de mediciones: ")

for dirTXT in os.listdir(imagenes):
	resultados = []
	#creo un nuevo archivo txt con nombre de la función (dirTXT), y lo abro
	funcionRecopilada = open(str(dirTXT) + ".txt", "w")
	#recorro los txts de cada dimTXTensión
	for dimTXT in os.listdir(imagenes+"/"+dirTXT):
		#me guardo en resActual cada valor dado en cada repetición
		resActual = []
		mediciones  = open(imagenes+"/"+dirTXT+"/"+dimTXT, "r")
		for medicion in mediciones:
			resActual.append(int(medicion))
		mediciones.close()
		#aca paso a calcular muy a lo macho el promedio y la desviacón estandar:
		#promedio:
		promLine = 0
		cant = 0
		for x in resActual:
			promLine = promLine + x
			cant = cant + 1
		promLine = promLine / cant
	
		#desviación estandar:
		desvLine = 0
		for x in resActual:
			for y in resActual:
				if y != x:
					desvLine = desvLine + y*y
		desvLine = desvLine / cant
		desvLine = math.sqrt(desvLine)

		#creo la tupla donde van a ir los tres valores: [DIM, PROM, DESV]
		nuevo = []
		nuevo.append(dimTXT[-17:-8]) #esto guarda cachos que no son dimensión, habría que afinarlo un poco
		nuevo.append(promLine)
		nuevo.append(desvLine)
		#lo guardo en resultados
		resultados.append(nuevo)

	#una vez tengo todos los resultados, los escribo en el mediciones de salida
	#-------->justo antes de hacer esto habría que ordenar resultados por la coordenada de la DIM
	for res in resultados:
		if res != resultados[-1]:
			funcionRecopilada.write(str(res) + "\n")
		else:
			funcionRecopilada.write(str(res))
	funcionRecopilada.close()
