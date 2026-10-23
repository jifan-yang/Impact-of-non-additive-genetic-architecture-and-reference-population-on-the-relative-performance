import matplotlib.pyplot as plt
import pandas as pd
import glob

data = pd.read_csv('allelefreq_Currentpop_16.dat', header=None)
plt.hist(data[0], bins=100, range=[0.000001, 0.999999], edgecolor='black')
plt.title('Histogram of Data')
plt.xlabel('Allele frequency')
plt.ylabel('Frequency')

plt.savefig('Ushape_marker_nonfixed.svg')
plt.show()