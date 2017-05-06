import os
import re
import numpy
import matplotlib.pyplot as plt


resultados = []

for file in os.listdir("Resultados"):
    f = open("Resultados/" + file,"r")
    size = re.search("x(.+?).bmp",file).group(1)
    mediciones = []
    for line in f:
        x,y = line.split()
        mediciones.append(long(y))
        TICKSxPIXEL = numpy.average(mediciones) / int(size)
    resultados.append( ( int(size) , TICKSxPIXEL ) )

plt.plot([e[0] for e in resultados], [e[1] for e in resultados],"ro")
plt.show()
