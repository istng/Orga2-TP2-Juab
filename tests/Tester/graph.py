import os
import re
import numpy
import matplotlib.pyplot as plt

resultadosC = []
resultadosASM = []
resultadosASMp = []
resultadosASMm = []
resultadosASMlu = []

for file in os.listdir("ResultadosO3MC/ASM_maxCloser"):
	f = open("ResultadosO3MC/ASM_maxCloser/" + file,"r")
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
	resultadosC.append( ( n , TICKSxPIXEL ) )


for file in os.listdir("ResultadosO3/ASM_maxCloser_cache"):
	f = open("ResultadosO3/ASM_maxCloser_cache/" + file,"r")
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
	resultadosASM.append( ( n , TICKSxPIXEL ) )
	

plt.plot([e[0] for e in resultadosC],  [e[1] for e in resultadosC],"bo")
plt.plot([e[0] for e in resultadosASM], [e[1] for e in resultadosASM],"ro")




plt.show()

