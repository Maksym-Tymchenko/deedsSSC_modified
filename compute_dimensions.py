import numpy as np
import sys

import nibabel as nib

input_image = sys.argv[1]

img = nib.load(input_image)

dimensions = img.header['dim']

print(dimensions)
# print(img.header)