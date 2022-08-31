import numpy as np
import sys

import nibabel as nib

output_folder = sys.argv[1]
input_image = sys.argv[2]

img = nib.load(input_image)

dimensions = img.header['dim']

dim0 = dimensions[0]
dim1 = dimensions[1]
dim2 = dimensions[2]
dim3 = dimensions[3]


# print("DIMENSIONS:")
# print(dim0)
# print(dim1)
# print(dim2)
# print(dim3)


output_file = open(f'{output_folder}/zero_displacements.dat', 'wb')
float_array = np.zeros((dim1//4, dim2//4, dim3//4,3)).astype('float32') #insert correct dimensions here
float_array.tofile(output_file)
output_file.close() 