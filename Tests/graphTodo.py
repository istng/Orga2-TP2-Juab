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



######

resultadosCc_dst = []
resultadosASMc_dst = []

resultadosCl_dst = []
resultadosASMl_dst = []

resultadosCc_TxP_dst = []
resultadosASMc_TxP_dst = []

resultadosCl_TxP_dst = []
resultadosASMl_TxP_dst = []




funcion1 = "ASM_convertRGBtoYUV"
funcion2 = "ASM_convertRGBtoYUV_phaddd"



for file in os.listdir("ResultadosO3/" + funcion1):
	f = open("ResultadosO3/" + funcion1 + "/" + file,"r")
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
	size = n*n
	mediciones = []
	for line in f:
		mediciones.append(int(line))
	mediciones.sort()
	mediciones = mediciones[0:80]
	TICKSxPIXEL = numpy.average(mediciones) / size
	TICKS = numpy.average(mediciones) 
	desvio = numpy.std(mediciones)
	desvioTPX = numpy.std([e/size for e in mediciones])

	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosCl.append( ( n , TICKS ) )
		resultadosCl_TxP.append( ( n , TICKSxPIXEL ) )

		resultadosCl_dst.append( desvio ) 
		resultadosCl_TxP_dst.append( desvioTPX) 

	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosCc.append( ( n , TICKS ) )
		resultadosCc_TxP.append( ( n , TICKSxPIXEL ) ) 

		resultadosCc_dst.append( desvio) 
		resultadosCc_TxP_dst.append(  desvioTPX ) 


for file in os.listdir("ResultadosO3/" + funcion2):
	f = open("ResultadosO3/" + funcion2 + "/" + file,"r")
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))

	size = n*n
	mediciones = []
	for line in f:
		mediciones.append(int(line))
	mediciones.sort()
	mediciones = mediciones[0:80]
	TICKSxPIXEL = numpy.average(mediciones) / size
	TICKS = numpy.average(mediciones)
	desvio = numpy.std(mediciones)
	desvioTPX = numpy.std([e/size for e in mediciones]) 
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosASMl.append( ( n , TICKS ) )
		resultadosASMl_TxP.append( ( n , TICKSxPIXEL ))
		
		resultadosASMl_dst.append(desvio ) 
		resultadosASMl_TxP_dst.append(  desvioTPX )

	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosASMc.append( ( n , TICKS ) )
		resultadosASMc_TxP.append( ( n , TICKSxPIXEL ))

		resultadosASMc_dst.append( desvio ) 
		resultadosASMc_TxP_dst.append( desvioTPX )


os.mkdir(funcion1 + " vs "  + funcion2 )
os.chdir(funcion1 + " vs "  + funcion2 )
# Aca pueden modifican para cambiar: tipo de grafico, variable , colores , etc..

#BARRAS MULTIPLES CON DESV EST (C vs ASM)
width = 20
plt.bar([e[0] + 20 for e in resultadosCl],  [e[1] for e in resultadosCl], width, color="blue", label="C", yerr=resultadosCl_dst, ecolor="cyan")
plt.bar([e[0] for e in resultadosASMl], [e[1] for e in resultadosASMl], width, color="red", label="ASM", yerr=resultadosASMl_dst, ecolor="magenta")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos")
plt.savefig("lenaCic.png")
plt.close()

width = 20
plt.bar([e[0] + 20 for e in resultadosCc],  [e[1] for e in resultadosCc], width, color="blue", label="C", yerr=resultadosCc_dst, ecolor="cyan")
plt.bar([e[0] for e in resultadosASMc], [e[1] for e in resultadosASMc], width, color="red", label="ASM", yerr=resultadosASMc_dst, ecolor="magenta")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos")
plt.savefig("coloresCic.png")
plt.close()

width = 20
plt.bar([e[0] + 20 for e in resultadosCl_TxP],  [e[1] for e in resultadosCl_TxP], width, color="blue", label="C", yerr=resultadosCl_TxP_dst, ecolor="cyan")
plt.bar([e[0] for e in resultadosASMl_TxP], [e[1] for e in resultadosASMl_TxP], width, color="red", label="ASM", yerr=resultadosASMl_TxP_dst, ecolor="magenta")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos/Pixel")
plt.savefig("lenaCicPix.png")
plt.close()


width = 20
plt.bar([e[0] + 20 for e in resultadosCc_TxP],  [e[1] for e in resultadosCc_TxP], width, color="blue", label="C", yerr=resultadosCc_TxP_dst, ecolor="cyan")
plt.bar([e[0] for e in resultadosASMc_TxP], [e[1] for e in resultadosASMc_TxP], width, color="red", label="ASM", yerr=resultadosASMc_TxP_dst, ecolor="magenta")
plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
plt.xlabel("Dimension")
plt.ylabel("#Ciclos/Pixel")
plt.savefig("coloresCicPix.png")
plt.close()


#BOLAS CON DESV EST (varios, es el "normal")

#plt.errorbar([e[0] + 20 for e in resultadosCl],  [e[1] for e in resultadosCl], resultadosCl_dst, linestyle='None', marker='^', label="C")
#plt.errorbar([e[0] for e in resultadosASMl], [e[1] for e in resultadosASMl], resultadosASMl_dst, linestyle='None', marker='^', label="ASM")
#plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
#plt.xlabel("Dimension")
#plt.ylabel("#Ciclos")
#plt.savefig("lenaCic.png")
#plt.close()
#
#plt.errorbar([e[0] + 20 for e in resultadosCc],  [e[1] for e in resultadosCc], resultadosCc_dst, linestyle='None', marker='^', label="C")
#plt.errorbar([e[0] for e in resultadosASMc], [e[1] for e in resultadosASMc], resultadosASMc_dst, linestyle='None', marker='^', label="ASM")
#plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
#plt.xlabel("Dimension")
#plt.ylabel("#Ciclos")
#plt.savefig("coloresCic.png")
#plt.close()
#
#plt.errorbar([e[0] + 20 for e in resultadosCl_TxP],  [e[1] for e in resultadosCl_TxP], resultadosCl_TxP_dst, linestyle='None', marker='^', label="C")
#plt.errorbar([e[0] for e in resultadosASMl_TxP], [e[1] for e in resultadosASMl_TxP], resultadosASMl_TxP_dst, linestyle='None', marker='^', label="ASM")
#plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
#plt.xlabel("Dimension")
#plt.ylabel("#Ciclos/Pixel")
#plt.savefig("lenaCicPix.png")
#plt.close()
#
#plt.errorbar([e[0] + 20 for e in resultadosCc_TxP],  [e[1] for e in resultadosCc_TxP], resultadosCc_TxP_dst, linestyle='None', marker='^', label="C")
#plt.errorbar([e[0] for e in resultadosASMc_TxP], [e[1] for e in resultadosASMc_TxP], resultadosASMc_TxP_dst, linestyle='None', marker='^', label="ASM")
#plt.legend(bbox_to_anchor=(0, 0), loc=1, borderaxespad=0.)
#plt.xlabel("Dimension")
#plt.ylabel("#Ciclos/Pixel")
#plt.savefig("coloresCicPix.png")
#plt.close()