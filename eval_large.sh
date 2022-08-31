#!/bin/sh

# Input arguments


us_image="../data/bucket/US_reconstruction/US_padded.nii.gz"
mri_image="../data/bucket/US_reconstruction/Case7-FLAIR.nii.gz"
output_folder="../data/bucket/US_reconstruction/output"
case_num="7"

vox_size=1

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $mri_image $us_image -reslice-identity -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}_US_in_MRI.nii.gz
c3d $mri_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-MRI_res.nii.gz

# Calculate linear rigid pre-registration using deeds
./linearBCV -F $output_folder/Case${case_num}-US_in_MRI.nii.gz \
 -M $output_folder/Case${case_num}-MRI_res.nii.gz \
 -R 1 \
 -O $output_folder/affine

# Generate zero dispalcements
python3 ./generate_zero_displacements.py $output_folder $output_folder/Case${case_num}-MRI_res.nii.gz


 # Apply rigid preregistration to MRI
  ./applyBCV -M $output_folder/Case${case_num}-MRI_res.nii.gz \
 -O $output_folder/zero \
 -D $output_folder/Case${case_num}-MRI_res_linear.nii.gz \
 -A $output_folder/affine_matrix.txt

 # Extract US background (pixels with 0 intensity exactly)
# c3d $output_folder/Case${case_num}-US.nii.gz -threshold 0 0 0 1 -o $output_folder/mask_US.nii.gz

# Remove background from MRI
# c3d $output_folder/Case${case_num}-MRI_in_US_linear.nii.gz $output_folder/mask_US.nii.gz -multiply -o $output_folder/clean_MRI.nii.gz
