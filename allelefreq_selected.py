import matplotlib.pyplot as plt
import pandas as pd
import glob


file_pattern = 'markerfreq_Currentpop*'
file_list = glob.glob(file_pattern)

if len(file_list) == 0:
    print(f"No files matching the pattern '{file_pattern}' were found.")
else:
    # ?????????
    file_name = file_list[0]
    data = pd.read_csv(file_name, header=None)

    plt.hist(data[0], bins=100, range=[0, 1], edgecolor='black')
    plt.title('Histogram of Data')
    plt.xlabel('Allele frequency')
    plt.ylabel('Frequency')

    plt.savefig('Selected_mrk_shape.svg')
    plt.show()