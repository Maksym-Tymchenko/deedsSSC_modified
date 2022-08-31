#!/bin/sh

# Input arguments

case_num=${1-"1"}
image_folder=${2:-"bucket/RESECT/RESECT/NIFTI/Case${case_num}"}
us_image=${3:-"$image_folder/US/Case${case_num}-US-before.nii.gz"}
mri_image=${4:-"$image_folder/MRI/Case${case_num}-FLAIR.nii.gz"}
tag_file=${5:-"$image_folder/Landmarks/Case${case_num}-MRI-beforeUS.tag"}

# Create directory to store the outputs
mkdir -p $image_folder/output/deeds

output_folder="$image_folder/output/deeds"

vox_size=0.5

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $mri_image $us_image -reslice-identity -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-US_in_MRI.nii.gz
c3d $mri_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-MRI.nii.gz

# Calculate linear rigid pre-registration using deeds
./linearBCV -F $output_folder/Case${case_num}-MRI.nii.gz \
 -M $output_folder/Case${case_num}-US_in_MRI.nii.gz \
 -R 1 \
 -O $output_folder/affine


# Apply linear preregistration to landmarks
python3 ./generate_zero_displacements.py $output_folder $output_folder/Case${case_num}-US_in_MRI.nii.gz


 ./applyBCV -M $output_folder/Case${case_num}-US_in_MRI.nii.gz \
 -O $output_folder/zero \
 -D $output_folder/Case${case_num}-US_in_MRI_linear.nii.gz \
 -A $output_folder/affine_matrix.txt


# Perform non linear registration
./deedsBCV -F $output_folder/Case${case_num}-US.nii.gz \
-M $output_folder/Case${case_num}-US_in_MRI.nii.gz \
-O $output_folder/Case${case_num}-deeds \
-A $output_folder/affine_matrix.txt \
-a 0.45 # make a smoother but less accurate registration


# Remove unnecessary files
rm $output_folder/mask_US.nii.gz
rm $output_folder/Case${case_num}_lm*
rm $output_folder/Case${case_num}-results*