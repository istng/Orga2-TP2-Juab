import os
import re
import numpy
import matplotlib.pyplot as plt


x = [96 , 192 , 288, 384 , 480 , 576 , 672 , 768 , 864 , 960 , 1056 , 1152 , 1248 , 1344 , 1440 , 1536]

resultadosCc = []
resultadosASMc = []

resultadosCl = []
resultadosASMl = []

resultadosCc_TxP = []
resultadosASMc_TxP = []

resultadosCl_TxP = []
resultadosASMl_TxP = []

resultadosCc_e = []
resultadosASMc_e = []

resultadosCl_e = []
resultadosASMl_e = []

######

resultadosCc_dst = []
resultadosASMc_dst = []

resultadosCl_dst = []
resultadosASMl_dst = []

resultadosCc_TxP_dst = []
resultadosASMc_TxP_dst = []

resultadosCl_TxP_dst = []
resultadosASMl_TxP_dst = []


resultadosCc_TxP_e = []
resultadosASMc_TxP_e = []

resultadosCl_TxP_e = []
resultadosASMl_TxP_e = []



funcion1 = "C_linearZoom"
funcion2 = "ASM_linearZoom"



for file in os.listdir("ResultadosO3/" + funcion1):
	f = open("ResultadosO3/" + funcion1 + "/" + file,"r")
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
	size = n*n
	mediciones = []
	for line in f:
		mediciones.append(long(line))
	mediciones.sort()
	mediciones = mediciones[0:159]
	TICKSxPIXEL = numpy.average(mediciones) / size
	TICKS = numpy.average(mediciones) 

	desvio = numpy.std(mediciones)
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosCl.append( ( n , TICKS ) )
		resultadosCl_TxP.append( ( n , TICKSxPIXEL ) )

		resultadosCl_dst.append( ( n , desvio + TICKS) )
		resultadosCl_TxP_dst.append( ( n , desvio + TICKSxPIXEL) )
		resultadosCl_e.append( ( n , desvio ) )
		resultadosCl_TxP_e.append( ( n , desvio ) )

	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosCc.append( ( n , TICKS ) )
		resultadosCc_TxP.append( ( n , TICKSxPIXEL ) )

		resultadosCc_dst.append((n, desvio + TICKS))
		resultadosCc_TxP_dst.append((n, desvio + TICKSxPIXEL))
		resultadosCc_e.append( ( n , desvio ) )
		resultadosCc_TxP_e.append( ( n , desvio ) )


for file in os.listdir("ResultadosO3/" + funcion2):
	f = open("ResultadosO3/" + funcion2 + "/" + file,"r")
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))

	size = n*n
	mediciones = []
	for line in f:
		mediciones.append(long(line))
	mediciones.sort()
	mediciones = mediciones[0:159]
	TICKSxPIXEL = numpy.average(mediciones) / size
	TICKS = numpy.average(mediciones) 
	desvio = numpy.std(mediciones)
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosASMl.append( ( n , TICKS ) )
		resultadosASMl_TxP.append( ( n , TICKSxPIXEL ))

		resultadosASMl_dst.append( ( n , desvio + TICKS) )
		resultadosASMl_TxP_dst.append( ( n , desvio + TICKSxPIXEL))
		resultadosASMl_TxP_e.append( ( n , desvio))
		resultadosASMl_e.append( ( n , desvio))


	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosASMc.append( ( n , TICKS ) )
		resultadosASMc_TxP.append( ( n , TICKSxPIXEL ))

		resultadosASMc_dst.append( ( n , desvio  + TICKS) )
		resultadosASMc_TxP_dst.append( ( n , desvio + TICKSxPIXEL))
		resultadosASMc_TxP_e.append( ( n , desvio))
		resultadosASMc_e.append( ( n , desvio))


os.mkdir(funcion1 + " vs "  + funcion2 )
os.chdir(funcion1 + " vs "  + funcion2 )

# Aca pueden modifican para cambiar: tipo de grafico, variable , colores , etc..
#BARRAS CON DESV EST
width = 5
plt.bar([e[0] + 28 for e in resultadosCl_dst],  [e[1] for e in resultadosCl_dst], width, color="blue")
plt.bar([e[0] + 8 for e in resultadosASMl_dst], [e[1] for e in resultadosASMl_dst], width, color="red")

width = 20
plt.bar([e[0] + 20 for e in resultadosCl],  [e[1] for e in resultadosCl], width, color="blue", label="C")
plt.bar([e[0] for e in resultadosASMl], [e[1] for e in resultadosASMl], width, color="red", label="ASM")

#PUNTOS
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos")

plt.savefig("lenaCic.png")
plt.close()


plt.plot([e[0] for e in resultadosCc],  [e[1] for e in resultadosCc],"bv", label="C")
plt.plot([e[0] for e in resultadosASMc], [e[1] for e in resultadosASMc],"rv", label="ASM")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos")

plt.savefig("coloresCic.png")
plt.close()
# ticks por pixel
resultadosCl_TxP.sort()
resultadosCl_TxP_e.sort()

plt.errorbar(x, [e[1] for e in resultadosCl_TxP],[e[1] for e in resultadosCl_TxP_e],linestyle='None', marker='^')
#plt.errorbar([e[0] for e in resultadosASMl_TxP], [e[1] for e in resultadosASMl_TxP],[e[0] for e in resultadosASMl_TxP_e],"ro", label="ASM")

plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos/pixel")
plt.savefig("lenaCicpix.png")
plt.close()


plt.plot([e[0] for e in resultadosCc_TxP],  [e[1] for e in resultadosCc_TxP],"bv", label="C")
plt.plot([e[0] for e in resultadosASMc_TxP], [e[1] for e in resultadosASMc_TxP],"rv", label="ASM")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos/pixel")
plt.savefig("coloresCicpix.png")
plt.close()


