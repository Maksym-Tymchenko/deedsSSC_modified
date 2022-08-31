#!/bin/sh

# Input arguments

image_folder="bucket/US_collection"
us_image="$image_folder/lateral_best_reversed_aligned.nii.gz"
mri_image="$image_folder/MRI_cube_Case7_aligned.nii.gz"

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds"

vox_size=0.5

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $us_image $mri_image -reslice-identity -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/MRI_in_US.nii.gz
c3d $us_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/US.nii.gz

# Add a black frame of 1 voxel around the MRI and US as a workaround for artifacts
c3d $output_folder/MRI_in_US.nii.gz -pad 1x1x1 1x1x1 0 -o $output_folder/MRI_in_US.nii.gz
c3d $output_folder/US.nii.gz -pad 1x1x1 1x1x1 0 -o $output_folder/US.nii.gz

# Calculate linear rigid pre-registration using deeds
./linearBCV -F $output_folder/US.nii.gz \
 -M $output_folder/MRI_in_US.nii.gz \
 -R 1 \
 -O $output_folder/affine

# Apply linear preregistration to landmarks
python3 ./generate_zero_displacements.py $output_folder $output_folder/MRI_in_US.nii.gz

 ./applyBCV -M $output_folder/MRI_in_US.nii.gz \
 -O $output_folder/zero \
 -D $output_folder/MRI_in_US_linear.nii.gz \
 -A $output_folder/affine_matrix.txt


# Perform non linear registration
./deedsBCV -F $output_folder/US.nii.gz \
-M $output_folder/MRI_in_US.nii.gz \
-O $output_folder/deeds \
-A $output_folder/affine_matrix.txt \
-a 0.45 # make a smoother but less accurate registration


# Extract US background (pixels with 0 intensity exactly)
c3d $output_folder/US.nii.gz -threshold 0 0 0 1 -o $output_folder/mask_US.nii.gz

# Remove background from MRI
c3d $output_folder/deeds_deformed.nii.gz $output_folder/mask_US.nii.gz -multiply -o $output_folder/clean_MRI.nii.gz


# Remove unnecessary files
rm $output_folder/mask_US.nii.gz
rm $output_folder/results*