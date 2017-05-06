import matplotlib.pyplot as plt

f = open('info.txt', 'r')

mediciones = []
for line in f:
	x,y = line.split()
	mediciones.append( (int(x), float(y)) )

plt.plot([e[0] for e in mediciones], [e[1] for e in mediciones])
plt.show()