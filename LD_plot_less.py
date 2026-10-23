import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv('ld_less.txt',  sep=' ', header=None)  

x = data[0]  
y1 = data[1]  
y2 = data[2]  
y3 = data[3]  


plt.figure(figsize=(8, 6))
plt.plot(x, y1, marker='o', linestyle='-', color='#34B233')  
# plt.plot(x, y2, marker='o', linestyle='-', color='r') 
# plt.plot(x, y3, marker='o', linestyle='-', color='g')  


plt.ylim(0, 0.8)  # y??0?0.8

plt.xlabel('Genetic length (cM)')  # ?? X ???
plt.ylabel(r'Linkage disequilibrium ($r^2$)')  
## plt.title('Plot of Column 2 vs Column 1')  # ????
## plt.grid(True)  # ????
plt.savefig('ld_less.svg')
plt.show()  