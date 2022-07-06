import numpy as np

with open('bucket/RESECT/RESECT/NIFTI/Case1/output/affine1_matrix.txt') as f:
    
    matrix = []
    for line in f:
        num_list = []
        for num in line.split():
            num_list.append(float(num))

        matrix.append(num_list)

    np_matrix = np.matrix(matrix).transpose()
    print(np_matrix)

# Write transposed matrix to file

with open('bucket/RESECT/RESECT/NIFTI/Case1/output/affine1_matrix_t.txt', 'w') as f:
    for line in np_matrix:
        np.savetxt(f, line, fmt='%.8f')