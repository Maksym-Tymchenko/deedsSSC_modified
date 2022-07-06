# Resample images

"""
c3d bucket/Abdomen/RawData/Training/img/img0002.nii.gz -flip y -resample-mm 2x2x2mm -region 0x0x10vox 180x140x190vox -origin-voxel 0x0x0vox -o bucket/Abdomen/RawData/Training/img/img2_res.nii.gz
c3d bucket/Abdomen/RawData/Training/img/img0004.nii.gz -flip y -resample-mm 2x2x2mm -region 0x0x20vox 180x140x190vox -origin-voxel 0x0x0vox -pad 14x0x0vox 14x0x0vox -1024 -o bucket/Abdomen/RawData/Training/img/img4_res.nii.gz
c3d bucket/Abdomen/RawData/Training/label/label0002.nii.gz -flip y -int 0 -resample-mm 2x2x2mm -region 0x0x10vox 180x140x190vox -origin-voxel 0x0x0vox -o bucket/Abdomen/RawData/Training/label/seg2_res.nii.gz
c3d bucket/Abdomen/RawData/Training/label/label0004.nii.gz -flip y -int 0 -resample-mm 2x2x2mm -region 0x0x20vox 180x140x190vox -origin-voxel 0x0x0vox -pad 14x0x0vox 14x0x0vox  0 -o bucket/Abdomen/RawData/Training/label/seg4_res.nii.gz
"""

mkdir -p bucket/Abdomen/RawData/Training/img/output

./preprocessAbdomen bucket/Abdomen/RawData/Training/img/img0002.nii.gz bucket/Abdomen/RawData/Training/img/img2_res.nii.gz
./preprocessAbdomen bucket/Abdomen/RawData/Training/img/img0004.nii.gz bucket/Abdomen/RawData/Training/img/img4_res.nii.gz bucket/Abdomen/RawData/Training/label/label0004.nii.gz bucket/Abdomen/RawData/Training/label/seg4_res.nii.gz

# Run affine registration
./linearBCV -F bucket/Abdomen/RawData/Training/img/img2_res.nii.gz -M bucket/Abdomen/RawData/Training/img/img4_res.nii.gz -O bucket/Abdomen/RawData/Training/img/output/affine_2_4

# Run deformable registration
./deedsBCV -F bucket/Abdomen/RawData/Training/img/img2_res.nii.gz -M bucket/Abdomen/RawData/Training/img/img4_res.nii.gz \
-O bucket/Abdomen/RawData/Training/img/output/nonlinear_2_4 -A bucket/Abdomen/RawData/Training/img/output/affine_2_4_matrix.txt -S bucket/Abdomen/RawData/Training/label/seg4_res.nii.gz

# Apply the same transformation to another image
./applyBCV -M bucket/Abdomen/RawData/Training/label/seg4_res.nii.gz -O bucket/Abdomen/RawData/Training/img/output/nonlinear_2_4 -D bucket/Abdomen/RawData/Training/img/output/second_warp.nii.gz -A bucket/Abdomen/RawData/Training/img/output/affine_2_4_matrix.txt