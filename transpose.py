import numpy as np
import sys


input_matrix = sys.argv[1]
output_matrix = sys.argv[2]
 

with open(input_matrix) as f:
    
    matrix = []
    for line in f:
        num_list = []
        for num in line.split():
            num_list.append(float(num))

        matrix.append(num_list)

    np_matrix = np.matrix(matrix).transpose()
    print(np_matrix)

# Write transposed matrix to file

with open(output_matrix, 'w') as f:
    for line in np_matrix:
        np.savetxt(f, line, fmt='%.8f')