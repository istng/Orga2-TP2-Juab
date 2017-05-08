import os
import re
import numpy
import matplotlib.pyplot as plt

resultadosCc = []
resultadosASMc = []

resultadosCl = []
resultadosASMl = []





for file in os.listdir("ResultadosO3/C_fourCombine"):
	f = open("ResultadosO3/C_fourCombine/" + file,"r")
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
	desvio = numpy.std(mediciones)
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosCl.append( ( n , TICKSxPIXEL ) )
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosCc.append( ( n , TICKSxPIXEL ) )



for file in os.listdir("ResultadosO3/ASM_fourCombine"):
	f = open("ResultadosO3/ASM_fourCombine/" + file,"r")
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
	desvio = numpy.std(mediciones)
	try:
		n = int(re.search("lena.(.+?)x",file).group(1))
		resultadosASMl.append( ( n , TICKSxPIXEL ) )
	except:
		n = int(re.search("colores.(.+?)x",file).group(1))
		resultadosASMc.append( ( n , TICKSxPIXEL ) )



# Aca pueden modifican para cambiar: tipo de grafico, variable , colores , etc..
plt.plot([e[0] for e in resultadosCl],  [e[1] for e in resultadosCl],"bo")
plt.plot([e[0] for e in resultadosASMl], [e[1] for e in resultadosASMl],"ro")

plt.show()

plt.plot([e[0] for e in resultadosCc],  [e[1] for e in resultadosCc],"bv")
plt.plot([e[0] for e in resultadosASMc], [e[1] for e in resultadosASMc],"rv")



plt.show()
