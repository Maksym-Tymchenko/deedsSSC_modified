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

vox_size=2

# Resample images into a common reference frame and isotropic voxel size of 0.5x0.5x0.5 mm
c3d $mri_image $output_folder/clean_MRI.nii.gz -reslice-identity -o $output_folder/Case${case_num}-clean_MRI_resliced.nii.gz
# c3d $mri_image -resample-mm ${vox_size}x${vox_size}x${vox_size}mm -o $output_folder/Case${case_num}-MRI_2.nii.gz
