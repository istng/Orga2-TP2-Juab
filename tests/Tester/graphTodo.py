import os
import re
import numpy
import matplotlib.pyplot as plt

resultadosCc = []
resultadosASMc = []

resultadosCl = []
resultadosASMl = []

resultadosCc_TxP = []
resultadosASMc_TxP = []

resultadosCl_TxP = []
resultadosASMl_TxP = []


funcion1 = "C_maxCloser"
funcion2 = "ASM_maxCloser"



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
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosCc.append( ( n , TICKS ) )
		resultadosCc_TxP.append( ( n , TICKSxPIXEL ) )



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
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosASMc.append( ( n , TICKS ) )
		resultadosASMc_TxP.append( ( n , TICKSxPIXEL ))



# Aca pueden modifican para cambiar: tipo de grafico, variable , colores , etc..

os.mkdir(funcion1 + " vs "  + funcion2 )
os.chdir(funcion1 + " vs "  + funcion2 )

plt.plot([e[0] for e in resultadosCl],  [e[1] for e in resultadosCl],"bo", label="C")
plt.plot([e[0] for e in resultadosASMl], [e[1] for e in resultadosASMl],"ro", label="ASM")
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

plt.plot([e[0] for e in resultadosCl_TxP],  [e[1] for e in resultadosCl_TxP],"bo", label="C")
plt.plot([e[0] for e in resultadosASMl_TxP], [e[1] for e in resultadosASMl_TxP],"ro", label="ASM")
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


